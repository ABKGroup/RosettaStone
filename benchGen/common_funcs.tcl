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

proc get_ff {ff_name} {
  set db [ord::get_db]
  return [$db findMaster $ff_name]
}

proc get_ff_dpin_name {db_ff} {
  foreach mTerm [$db_ff getMTerms] {
    if {[$mTerm getSigType] == "SIGNAL"} {
      if {[$mTerm getIoType] == "INPUT"} {
        return [$mTerm getName] 
      }
    }
  }
  foreach mTerm [$db_ff getMTerms] {
    if {[regexp [$mTerm getName] "D|d"]} {
      return [$mTerm getName]
    } 
  }
}

proc get_ff_qpin_name {db_ff} {
  foreach mTerm [$db_ff getMTerms] {
    if {[$mTerm getSigType] == "SIGNAL"} {
      if {[$mTerm getIoType] == "OUTPUT"} {
        return [$mTerm getName] 
      }
    }
  }
  foreach mTerm [$db_ff getMTerms] {
    if {[regexp [$mTerm getName] "Q|q"]} {
      return [$mTerm getName]
    } 
  }
}

proc get_ff_clkpin_name {db_ff} {
  foreach mTerm [$db_ff getMTerms] {
    if {[$mTerm getSigType] == "CLOCK"} {
      return [$mTerm getName] 
    }
  }

  foreach mTerm [$db_ff getMTerms] {
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

proc disable_huge_fanout_nets {fanout_limit} {
  set db [ord::get_db]
  set block [[$db getChip] getBlock]

  set huge_net_cnt 0

  foreach net [$block getNets] {
    set fanout [expr [llength [$net getITerms]] + [llength [$net getBTerms]]]
    if {$fanout >= $fanout_limit && [$net getSigType] != "CLOCK"} {
      set sta_net [get_nets [$net getConstName]]
      set ports [get_ports -of_objects $sta_net]
      set pins [get_pins -of_objects $sta_net]
      set huge_net_cnt [expr $huge_net_cnt + 1]
      set_disable_timing $pins
    }
  }
  
  puts "Disabled huge fanout nets: $huge_net_cnt"
}
