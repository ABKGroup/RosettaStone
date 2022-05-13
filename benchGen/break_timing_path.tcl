proc get_loop_in_pins {} {
  set loop_in_pins []
  foreach edge [sta::disabled_edges_sorted] {
    if { [$edge role] == "combinational"} {
      if { [$edge is_disabled_loop] } {
        set from_pin [[$edge from] pin]
        lappend loop_in_pins $from_pin
      } 
    } 
  }
  return $loop_in_pins
}

proc get_ff {} {
  set db [ord::get_db]
  set block [[$db getChip] getBlock]

  foreach inst [$block getInsts] {
    set master [$inst getMaster]
    if { [$master isSequential] } {
      return $master
      break
    }
  }
}

proc get_ff_name {} {
  return [[get_ff] getName]
}

proc get_ff_dpin_name {} {
  foreach mTerm [[get_ff] getMTerms] {
    if {[$mTerm getSigType] == "SIGNAL"} {
      if {[$mTerm getIoType] == "INPUT"} {
        return [$mTerm getName] 
      }
    }
  }
  foreach mTerm [[get_ff] getMTerms] {
    if {[regexp [$mTerm getName] "D|d"]} {
      return [$mTerm getName]
    } 
  }
}

proc get_ff_qpin_name {} {
  foreach mTerm [[get_ff] getMTerms] {
    if {[$mTerm getSigType] == "SIGNAL"} {
      if {[$mTerm getIoType] == "OUTPUT"} {
        return [$mTerm getName] 
      }
    }
  }
  foreach mTerm [[get_ff] getMTerms] {
    if {[regexp [$mTerm getName] "Q|q"]} {
      return [$mTerm getName]
    } 
  }
}

proc get_ff_clkpin_name {} {
  foreach mTerm [[get_ff] getMTerms] {
    if {[$mTerm getSigType] == "CLOCK"} {
      return [$mTerm getName] 
    }
  }

  foreach mTerm [[get_ff] getMTerms] {
    if {[regexp [$mTerm getName] "CK|CLK|ck|clk|CLOCK|clock"]} {
      return [$mTerm getName]
    } 
  }
}

proc get_clk_net_name {} {
  set db [ord::get_db]
  set block [[$db getChip] getBlock]
  
  foreach net [$block getNets] {
    if {[$net getSigType] == "CLOCK"} {
      return [$net getName]
    }
  }
}

proc get_mterm_iopin_cnt {db_master} {
  set ipin 0
  set opin 0
  foreach mterm [$db_master getMTerms] {
    if {[$mterm getSigType] == "SIGNAL"} {
      if {[$mterm getIoType] == "INPUT"} {
        set ipin [expr $ipin+1]
      } elseif {[$mterm getIoType] == "OUTPUT"} {
        set opin [expr $opin+1]
      }
    }
  }
  # return [list $ipin $opin]
  return "$ipin/$opin"
}

# note that the following two funcs are only for "1-in/1-out" inst.
proc get_sta_inst_dir_pin {db_pin direction} {
  set db_inst [$db_pin getInst]
  foreach iterm [$db_inst getITerms] {
    if {[$iterm getSigType] == "SIGNAL" && [$iterm getIoType] == $direction} {
      set mterm_name [[$iterm getMTerm] getConstName]
      set inst_name [$db_inst getConstName]
      return [get_pins "$inst_name/$mterm_name"]
    }
  }
  return NULL
}

set design adaptec1

read_liberty $libDir/NangateOpenCellLibrary_typical.lib
read_db ${design}.loop_break.db
read_sdc ./gate/${design}.sdc
# report_checks
#
set ff_name [get_ff_name]
set ff_dpin [get_ff_dpin_name]
set ff_qpin [get_ff_qpin_name]
set ff_clkpin [get_ff_clkpin_name]
set clk_net_name [get_clk_net_name]
set lib_ff_cell [get_lib_cells $ff_name]

puts "ff_name: $ff_name"
puts "ff_dpin: $ff_dpin, ff_qpin: $ff_qpin, ff_clkpin: $ff_clkpin"
puts "clk_net_name: $clk_net_name"

set db [ord::get_db]

set max_timing_path_length 50
set new_ff_cnt 0
set timing_path_cnt 0

set max_timing_path_length [expr 2 * $max_timing_path_length]

while {1} {
  set worst_length -1e30

  foreach path_end [find_timing_paths -unique_paths_to_endpoint -group_count 50] {
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
          } elseif {$next_is_cut || $next_accm_cell_cnt >= $max_timing_path_length || $end_i == [expr $accm_length-2]} {
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
}

puts "finished"
write_def ./${design}.finish.def
write_verilog ./${design}.finish.v
write_db ./${design}.finish.db

exit
