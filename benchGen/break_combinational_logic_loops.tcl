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

set design adaptec1 

read_liberty ../tech/NangateOpenCellLibrary_typical.lib

read_db ${design}.db

set ff_name [get_ff_name]
set ff_dpin [get_ff_dpin_name]
set ff_qpin [get_ff_qpin_name]
set ff_clkpin [get_ff_clkpin_name]
set clk_net_name [get_clk_net_name]
set lib_ff_cell [get_lib_cells $ff_name]

puts "ff_name: $ff_name"
puts "ff_dpin: $ff_dpin, ff_qpin: $ff_qpin, ff_clkpin: $ff_clkpin"
puts "clk_net_name: $clk_net_name"

set cnt 0
set trial 0

set loop_in_pins [get_loop_in_pins]
while {[llength $loop_in_pins] > 0} {
  foreach in_pin $loop_in_pins {
    set net [get_nets -of_objects $in_pin]
  
    make_net nr_${cnt}
    make_instance reg_${cnt} $lib_ff_cell
    connect_pin $net [get_pins reg_${cnt}/${ff_dpin}]
    connect_pin $clk_net_name [get_pins reg_${cnt}/${ff_clkpin}]
    connect_pin nr_${cnt} [get_pins reg_${cnt}/${ff_qpin}]
    disconnect_pin $net $in_pin
    connect_pin nr_${cnt} $in_pin
    incr cnt
  }
  set loop_in_pins [get_loop_in_pins]
  incr trial
  puts "(Trial $trial): $cnt nets are created"
}

puts "Total $cnt nets are created to break loops"

write_verilog ./${design}.v
write_def ./${design}.def
write_db ./${design}.loop_break.db
exit
