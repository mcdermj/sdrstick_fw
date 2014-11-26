# TCL File Generated by Component Editor 14.0
# Mon Nov 24 15:49:35 PST 2014
# DO NOT MODIFY


# 
# sdrstick_rx "SDR Stick Receiver" v1.0
# mcdermj 2014.11.24.15:49:34
# 
# 

# 
# request TCL package from ACDS 14.0
# 
package require -exact qsys 14.0


# 
# module sdrstick_rx
# 
set_module_property DESCRIPTION ""
set_module_property NAME sdrstick_rx
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR mcdermj
set_module_property DISPLAY_NAME "SDR Stick Receiver"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL sdrstick_rx
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file cic.v VERILOG PATH cic.v
add_fileset_file cic_comb.v VERILOG PATH cic_comb.v
add_fileset_file cic_integrator.v VERILOG PATH cic_integrator.v
add_fileset_file coefL8A.mif MIF PATH coefL8A.mif
add_fileset_file coefL8B.mif MIF PATH coefL8B.mif
add_fileset_file coefL8C.mif MIF PATH coefL8C.mif
add_fileset_file coefL8D.mif MIF PATH coefL8D.mif
add_fileset_file coefL8E.mif MIF PATH coefL8E.mif
add_fileset_file coefL8F.mif MIF PATH coefL8F.mif
add_fileset_file coefL8G.mif MIF PATH coefL8G.mif
add_fileset_file coefL8H.mif MIF PATH coefL8H.mif
add_fileset_file cordic.v VERILOG PATH cordic.v
add_fileset_file firfilt.v VERILOG PATH firfilt.v
add_fileset_file firram36.v VERILOG PATH firram36.v
add_fileset_file firromH.v VERILOG PATH firromH.v
add_fileset_file receiver.v VERILOG PATH receiver.v
add_fileset_file varcic.v VERILOG PATH varcic.v
add_fileset_file sdrstick_rx.v VERILOG PATH sdrstick_rx.v TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point ctl
# 
add_interface ctl avalon end
set_interface_property ctl addressUnits WORDS
set_interface_property ctl associatedClock clock
set_interface_property ctl associatedReset reset
set_interface_property ctl bitsPerSymbol 8
set_interface_property ctl burstOnBurstBoundariesOnly false
set_interface_property ctl burstcountUnits WORDS
set_interface_property ctl explicitAddressSpan 0
set_interface_property ctl holdTime 0
set_interface_property ctl linewrapBursts false
set_interface_property ctl maximumPendingReadTransactions 0
set_interface_property ctl maximumPendingWriteTransactions 0
set_interface_property ctl readLatency 0
set_interface_property ctl readWaitTime 1
set_interface_property ctl setupTime 0
set_interface_property ctl timingUnits Cycles
set_interface_property ctl writeWaitTime 0
set_interface_property ctl ENABLED true
set_interface_property ctl EXPORT_OF ""
set_interface_property ctl PORT_NAME_MAP ""
set_interface_property ctl CMSIS_SVD_VARIABLES ""
set_interface_property ctl SVD_ADDRESS_GROUP ""

add_interface_port ctl ctl_address address Input 3
add_interface_port ctl ctl_readdata readdata Output 32
add_interface_port ctl ctl_read read Input 1
add_interface_port ctl ctl_writedata writedata Input 32
add_interface_port ctl ctl_write write Input 1
set_interface_assignment ctl embeddedsw.configuration.isFlash 0
set_interface_assignment ctl embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment ctl embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment ctl embeddedsw.configuration.isPrintableDevice 0


# 
# connection point fifo_out
# 
add_interface fifo_out avalon start
set_interface_property fifo_out addressUnits WORDS
set_interface_property fifo_out associatedClock adc_clk
set_interface_property fifo_out associatedReset adc_reset
set_interface_property fifo_out bitsPerSymbol 8
set_interface_property fifo_out burstOnBurstBoundariesOnly false
set_interface_property fifo_out burstcountUnits WORDS
set_interface_property fifo_out doStreamReads false
set_interface_property fifo_out doStreamWrites false
set_interface_property fifo_out holdTime 0
set_interface_property fifo_out linewrapBursts false
set_interface_property fifo_out maximumPendingReadTransactions 0
set_interface_property fifo_out maximumPendingWriteTransactions 0
set_interface_property fifo_out readLatency 0
set_interface_property fifo_out readWaitTime 1
set_interface_property fifo_out setupTime 0
set_interface_property fifo_out timingUnits Cycles
set_interface_property fifo_out writeWaitTime 0
set_interface_property fifo_out ENABLED true
set_interface_property fifo_out EXPORT_OF ""
set_interface_property fifo_out PORT_NAME_MAP ""
set_interface_property fifo_out CMSIS_SVD_VARIABLES ""
set_interface_property fifo_out SVD_ADDRESS_GROUP ""

add_interface_port fifo_out fifo_writedata writedata Output 32
add_interface_port fifo_out fifo_write write Output 1


# 
# connection point adc_in
# 
add_interface adc_in conduit end
set_interface_property adc_in associatedClock adc_clk
set_interface_property adc_in associatedReset adc_reset
set_interface_property adc_in ENABLED true
set_interface_property adc_in EXPORT_OF ""
set_interface_property adc_in PORT_NAME_MAP ""
set_interface_property adc_in CMSIS_SVD_VARIABLES ""
set_interface_property adc_in SVD_ADDRESS_GROUP ""

add_interface_port adc_in adc_data data Input 16


# 
# connection point adc_clk
# 
add_interface adc_clk clock end
set_interface_property adc_clk clockRate 122880000
set_interface_property adc_clk ENABLED true
set_interface_property adc_clk EXPORT_OF ""
set_interface_property adc_clk PORT_NAME_MAP ""
set_interface_property adc_clk CMSIS_SVD_VARIABLES ""
set_interface_property adc_clk SVD_ADDRESS_GROUP ""

add_interface_port adc_clk adc_clk clk Input 1


# 
# connection point adc_reset
# 
add_interface adc_reset reset end
set_interface_property adc_reset associatedClock adc_clk
set_interface_property adc_reset synchronousEdges DEASSERT
set_interface_property adc_reset ENABLED true
set_interface_property adc_reset EXPORT_OF ""
set_interface_property adc_reset PORT_NAME_MAP ""
set_interface_property adc_reset CMSIS_SVD_VARIABLES ""
set_interface_property adc_reset SVD_ADDRESS_GROUP ""

add_interface_port adc_reset adc_clk_reset reset Input 1


# 
# connection point debug_led
# 
add_interface debug_led conduit end
set_interface_property debug_led associatedClock adc_clk
set_interface_property debug_led associatedReset adc_reset
set_interface_property debug_led ENABLED true
set_interface_property debug_led EXPORT_OF ""
set_interface_property debug_led PORT_NAME_MAP ""
set_interface_property debug_led CMSIS_SVD_VARIABLES ""
set_interface_property debug_led SVD_ADDRESS_GROUP ""

add_interface_port debug_led debug_led led Output 1

