source common_funcs.tcl
set design adaptec1

set libDir ""
read_liberty $libDir/NangateOpenCellLibrary_typical.lib

read_db ${design}.loop_break.db
read_sdc ./gate/${design}.sdc

# specify target FF
set ff_name "DFF_X1"

# tuning parameter for logic path cutting
set max_timing_path_length 25

# 1. ignore nets where fanout >= fanout_limit (100)
# (Commercial tool's convention on prePlace timer)
set fanout_limit 100
set db [ord::get_db]

disable_huge_fanout_nets $fanout_limit

# 2. Setup FF pointers (both ODB, STA)
set db_ff [get_ff $ff_name]
set ff_dpin [get_ff_dpin_name $db_ff]
set ff_qpin [get_ff_qpin_name $db_ff]
set ff_clkpin [get_ff_clkpin_name $db_ff]
set clk_net_name [get_clk_net_name]
set lib_ff_cell [get_lib_cells $ff_name]

puts "ff_name: $ff_name"
puts "ff_dpin: $ff_dpin, ff_qpin: $ff_qpin, ff_clkpin: $ff_clkpin"
puts "clk_net_name: $clk_net_name"

# scale timing_path_length by 2 because Opin+Ipin pair awareness
set max_timing_path_length [expr 2 * $max_timing_path_length]

# loop vars
set new_ff_cnt 0
set timing_path_cnt 0
set worst_length_same_cnt 0
set prev_worst_length 0

# 3. main logic cut script
while {1} {
  set worst_length -1e30

  foreach path_end [find_timing_paths -unique_paths_to_endpoint -group_count 10] {
    set accm_list []
    set pin_list []
    set cnt 1
    set idx 0
    set path [$path_end path]
    set pins [$path pins]
    
    if {[llength $pins] >= $worst_length} {
      set worst_length [llength $pins]
    }

    # skip for smaller timing path
    if {[llength $pins] <= $max_timing_path_length} {
      continue
    }

    foreach pin [$path pins] {
      set pin_name [get_full_name $pin]
      set inst [$pin instance]
      set sta_master [$inst cell]
      set master_name [get_name $sta_master]
      set db_master [$db findMaster $master_name]
  
      if {$db_master != "NULL"} {
        set io_pins_cnt [get_mterm_iopin_cnt $db_master]
        # found cutting points
        if {$io_pins_cnt == "1/1" || [$db_master isSequential] } {
          lappend accm_list [list $idx $cnt 0]
          set cnt 1
        } else {
          set cnt [expr $cnt + 1]
          # forcely cut when cnt >= max_timing_path_length
          if {$cnt >= $max_timing_path_length} {
            set db_pin [sta::sta_to_db_pin $pin]
  
            # only when INPUT pin is detected, cut timing path
            if {[$db_pin getIoType] == "INPUT"} {
              set net [get_nets -of_objects $pin]
              make_net nc_${new_ff_cnt}
              make_instance reg_nc_${new_ff_cnt} $lib_ff_cell
              connect_pin $net [get_pins reg_nc_${new_ff_cnt}/${ff_dpin}]
              connect_pin $clk_net_name [get_pins reg_nc_${new_ff_cnt}/${ff_clkpin}]
              connect_pin nc_${new_ff_cnt} [get_pins reg_nc_${new_ff_cnt}/${ff_qpin}]
              disconnect_pin $net $pin
              connect_pin nc_${new_ff_cnt} $pin
  
              set new_ff_cnt [expr $new_ff_cnt +1]
              
              # save cutting points
              lappend accm_list [list $idx $cnt 1]
              set cnt 1
            }
          }
        }
        puts "$idx $pin_name ($master_name) $io_pins_cnt $cnt"
  
        set idx [expr $idx + 1]
        lappend pin_list $pin
      }
    }
  
    set accm_length [llength $accm_list]
    puts $accm_list
  
    # note that first/last elem is always FF
    for {set i 1} {$i <= [expr $accm_length -2]} {incr i} {
      set cur_is_cut [lindex [lindex $accm_list $i] 2]
  
      if {$cur_is_cut == 0} {
        set end_i $i
        set accm_cell_cnt 0
        # puts "happen? $end_i [expr $accm_length -1]"
        for {set start_i $i} {$end_i <= [expr $accm_length -2]} {incr end_i} {
          set accm_ptr [lindex $accm_list $end_i]
          set cnt [lindex $accm_ptr 1]
          set is_cut [lindex $accm_ptr 2]
          set accm_cell_cnt [expr $accm_cell_cnt + $cnt]
  
          set next_accm_ptr [lindex $accm_list [expr $end_i + 1]]
          set next_cnt [lindex $next_accm_ptr 1]
          set next_is_cut [lindex $next_accm_ptr 2]
          set next_accm_cell_cnt [expr $accm_cell_cnt + $next_cnt]
  
          # cut already happened
          if {$is_cut} {
            set accm_cell_cnt 0
            break
          # cut should happened here (found cut points)
          } elseif {$next_is_cut \
            || $next_accm_cell_cnt >= $max_timing_path_length \
            || $end_i == [expr $accm_length-2]} {
            #set accm_cell_cnt 0
            break
          }
        }
        if {$is_cut == 0 && $end_i <= [expr $accm_length -3]} {
          set start_accm_ptr [lindex $accm_list $start_i]
          set start_pin_idx [lindex $start_accm_ptr 0]
          set end_accm_ptr [lindex $accm_list $end_i]
          set end_pin_idx [lindex $end_accm_ptr 0]
          puts "found cut point: $start_pin_idx ~ $end_pin_idx, $accm_cell_cnt"

          # skip for outlier case
          if {$accm_cell_cnt == 1} {
            continue
          }
          set i $end_i
  
          set cut_pin [lindex $pin_list $end_pin_idx]
          set db_pin [sta::sta_to_db_pin $cut_pin]
  
          if {[$db_pin getIoType] == "INPUT"} {
            set cut_ipin $cut_pin
            set cut_opin [get_sta_inst_dir_pin $db_pin "OUTPUT"] 
          } elseif {[$db_pin getIoType] == "OUTPUT"} {
            set cut_ipin [get_sta_inst_dir_pin $db_pin "INPUT"]
            set cut_opin $cut_pin
          }
  
          set in_net [get_nets -of_objects $cut_ipin]
          set out_net [get_nets -of_objects $cut_opin]
  
          make_instance reg_nc_${new_ff_cnt} $lib_ff_cell
          disconnect_pin $in_net $cut_ipin
          disconnect_pin $out_net $cut_opin
  
          connect_pin $in_net [get_pins reg_nc_${new_ff_cnt}/${ff_dpin}]
          connect_pin $clk_net_name [get_pins reg_nc_${new_ff_cnt}/${ff_clkpin}]
          connect_pin $out_net [get_pins reg_nc_${new_ff_cnt}/${ff_qpin}]
          delete_instance [[$db_pin getInst] getConstName]
              
          set new_ff_cnt [expr $new_ff_cnt +1]
          puts "cell type changed"
        }
      # clear accm_cell_cnt
      } else {
        set accm_cell_cnt 0
      }
    }
  }

  puts "loop $timing_path_cnt: worst path length: $worst_length accumulated created FF: $new_ff_cnt"
  set timing_path_cnt [expr $timing_path_cnt +1]

  # escape condition
  if {$worst_length <= [expr $max_timing_path_length * 1.2]} {
    break
  } 

  if {$prev_worst_length == $worst_length} {
    incr worst_length_same_cnt 
  } else {
    set worst_length_same_cnt 0
  }

  # if length of timing critical path doesn't change  
  # escape the while loop
  if {$worst_length_same_cnt >= 5} { 
    break
  }

  # update the prev_worst_length var
  set prev_worst_length $worst_length
}

puts "finished"
write_def ./${design}.finish.def
write_verilog ./${design}.finish.v
write_db ./${design}.finish.db

exit
