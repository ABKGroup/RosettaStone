source common_funcs.tcl
set design adaptec1 

set libDir ""
read_liberty $libDir/NangateOpenCellLibrary_typical.lib

read_db ${design}.db

# specify target FF
set ff_name "DFF_X1"

set db_ff [get_ff $ff_name]
set ff_dpin [get_ff_dpin_name $db_ff]
set ff_qpin [get_ff_qpin_name $db_ff]
set ff_clkpin [get_ff_clkpin_name $db_ff]
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
