#!trfsmgen
#
# Map and replace $fsm cells by TR-FSM wrappers
#
# This script is sourced by insert-trfsm.tcl, check-exapps.tcl and some others.
#
# Required variables: $APP_NAME, $Local, $FSMInstances, $FSMs, $TRFSMs,
#   $Wrappers, $TRFSMShortNames, $APP_OUT_DIR, $APP_OUT_BASE, $APP_VLOG_OUT
#

# remove the following two lines
#puts "ERROR: You have to edit this file [info script] before executing."
#exit 1

##############################################################################
## Map and replace $fsm to TR-FSMs ###########################################
##############################################################################

# associative array, key = index into $FSMs, value = index into $TRFSMs
unset -nocomplain Mapping
if $Local {
  set Mapping(0) 0
} else {
  puts "## Automatic FSM --> TR-FSM mapping"
  map_fsms $TRFSMs $FSMs Mapping
}

if {[array size Mapping] != [llength $FSMs]} {
  puts "Error: Invalid mapping"
  exit 1
}

# report mapping
puts "## Mapping of FSMs to TR-FSMs:"
foreach {FSMIdx TRFSMIdx} [array get Mapping] {
  puts "  FSM $FSMIdx --> TR-FSM $TRFSMIdx"
}

if {!$Local} {
  set Filename "${APP_OUT_DIR}/${APP_OUT_BASE}fsms.tcl"
  puts "## Writing mapping to $Filename"

  set of [open "$Filename" "w"]
  puts $of "#!tcl"
  puts $of "#"
  puts $of "# Information on FSM<->TRFSM mapping"
  puts $of "#"
  puts $of "# Auto-generated by [info script]"
  puts $of "#"
  puts $of ""
  puts $of "# FSMs"
  puts -nonewline $of "set FSMs \[list "
  foreach FSM $FSMs {
    set Name [get_name $FSM]
    puts -nonewline $of "\{$Name\} "
  }
  puts $of "\]"
  puts $of ""
  puts $of "# \$fsm cell instances"
  puts -nonewline $of "set FSMInstances \[list "
  foreach FSM $FSMInstances {
    set CellName [get_cell_name $FSM]
    puts -nonewline $of "\{$CellName\} "
  }
  puts $of "\]"
  puts $of ""
  puts $of "# FSM -> TR-FSM mapping: associative array, key = index into \$FSMs and"
  puts $of "# \$FSMInstances, value = index into \$TRFSMs"
  for {set i 0} {$i < [llength $TRFSMShortNames]} {incr i} {
    # set as unused, denoted by -1
    set TRFSMMapping($i) -1
  }
  foreach {FSMIdx TRFSMIdx} [array get Mapping] {
    puts $of "set FSMMapping($FSMIdx) $TRFSMIdx"
    set TRFSMMapping($TRFSMIdx) $FSMIdx
  }
  puts $of ""
  puts $of "# TR-FSM -> FSM mapping: associative array, key = index into \$TRFSMs,"
  puts $of "# value = index into \$FSMs and \$FSMInstances, -1 means unused"
  foreach {TRFSMIdx FSMIdx} [array get TRFSMMapping] {
    puts $of "set TRFSMMapping($TRFSMIdx) $FSMIdx"
  }
  # TRFSMMapping is required below
  puts $of ""
  close $of
}

puts "## Replacing Yosys \$fsm cells with TR-FSM wrappers"

foreach {FSMIdx TRFSMIdx} [array get Mapping] {
  set Instance    [lindex $FSMInstances    $FSMIdx]
  set FSM         [lindex $FSMs            $FSMIdx]
  set TRFSM       [lindex $TRFSMs          $TRFSMIdx]
  set Wrapper     [lindex $Wrappers        $TRFSMIdx]
  set ShortName   [lindex $TRFSMShortNames $TRFSMIdx]
  set ShortNameLC [string tolower $ShortName]
  set CellName    [get_cell_name $Instance]
  puts "  $ShortName: $CellName"

  insert_trfsm_wrapper $Instance $FSM $Wrapper "${ShortName}_1"
  # this internally does:
  #  - set_fsm_definition $TRFSM $FSM
  #  - map_input trfsm logical physical
  #  - map_output trfsm logical physical
  #  - replace Yosys $fsm cell with $Wrapper module

  set BS [generate_bitstream $TRFSM]
  set RegName "CfgReg_${ShortName}_0"    ;# TInterSynthHandler.SetupConfigRegisters creates these registers
  print_bitstream $BS -trfsm
  write_bitstream $BS -format vhdl         ${ShortName}  ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream.vhd
  write_bitstream $BS -format verilog      ${ShortName}  ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream.v
  write_bitstream $BS -format c            ${RegName}    ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream.inc.c
  write_bitstream $BS -format text         ${ShortName}  ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream.txt
  write_bitstream $BS -format modelsim     "\$TRFSMBase" ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream-modelsim.do
  write_bitstream $BS -format lec -revised "\$TRFSMBase" ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream-lec.do
  write_bitstream $BS -format formality    "\$TRFSMBase" ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream-formality.tcl

  # LEC state register encoding
  #
  # First we have to determine the name under which the original state register
  # will be known to LEC. In LEC, the original Verilog code will be read and
  # then the design will be flattend (if it was split to submodules). The new
  # state register is named "<module><register>_reg"
  #
  # Here we have to reconstruct <module> and <register> which were mangled by
  # Yosys to name the $fsm cells.
  #
  #  - assuming Yosys naming rules of "fsm_extract"
  #     - FSM cell name: "$fsm$\<statereg>$<randomnumber>", e.g. "$fsm$\SPI_FSM_State$2481"
  #  - assuming Yosys naming rules of "flatten"
  #     - new cells are named: "$techmap\<module>.<cellname>", e.g. "$techmap\SPIFSM_1.$fsm$\SPI_FSM_State$2481"
  if {[string first "\$fsm" "$CellName"] == 0} {
    # $CellName is e.g. "$fsm$\SPI_FSM_State$2481", i.e. $fsm is in top module
    set Postfix [string last "\$" "$CellName"]
    set StateReg [string range "$CellName" 6 [expr $Postfix - 1]]
    set StateReg "${StateReg}_reg"
  } elseif {[string first "\$techmap" "$CellName"] == 0} {
    # $CellName is e.g. "$techmap\SPIFSM_1.$fsm$\SPI_FSM_State$2481", i.e. $fsm is in sub-module
    set RegIdx   [string first "\$fsm" "$CellName"]
    set Postfix  [string last "\$" "$CellName"]
    set StateReg [string range "$CellName" [expr $RegIdx + 6] [expr $Postfix - 1]]
    set DotIdx   [string last "." "$CellName"]
    set SubMod   [string range "$CellName" 9 [expr $DotIdx - 1]]
    set StateReg "${SubMod}/${StateReg}_reg"
  } else {
    puts "Cannot handle \$fsm cell name '$CellName' to guess state register name for LEC"
  }
  #puts "Guessed StateReg = +$StateReg+"
  write_encoding $TRFSM -format lec "${StateReg}" "${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-encoding-lec.txt"
}

# Above we have written the bitstream for each TR-FSM to files in various
# formats. The files for ModelSim and LEC use the variable $TRFSMBase to
# specify the full instance name (incl. path) of each TR-FSM.  Here we generate
# the top-level scripts which sets this variable and source the above scripts.
#
# There are three places in the design flow where TR-FSMs are inserted:
#   flowcmd insert-trfsm -fsm
#   flowcmd insert-trfsm -extract
#   flowcmd insert-trfsms
# The first two cases are handled by ./insert-trfsm.tcl while the third case is
# handled by units/reconfmodule/chll/scripts/insert-trfsms.tcl.
#
# Additionally, to verify the results of InterSynth after
#   flowcmd intersynth
#   flowcmd check-intersynth
# the new instance names of the TR-FSMs (more precisely, their wrapper modules)
# must be determined and similar scripts as here must be generated. These are
# generated by apps/<app>/chll/scripts/intersynth-postproc.tcl.
#
puts "## Creating top-level bitstream scripts for application $APP_NAME"
set mtf [open "${APP_OUT_DIR}/${APP_OUT_BASE}bitstream-modelsim.do" "w"]
puts $mtf "#!modelsim"
puts $mtf "#"
puts $mtf "# Apply TR-FSM bitstreams"
puts $mtf "#"
puts $mtf "# Auto-generated by [info script]"
puts $mtf "#"
puts $mtf ""
set ltf [open "${APP_OUT_DIR}/${APP_OUT_BASE}bitstream-lec.do" "w"]
puts $ltf "//!lec"
puts $ltf "//"
puts $ltf "// Apply TR-FSM bitstreams"
puts $ltf "//"
puts $ltf "// Auto-generated by [info script]"
puts $ltf "//"
puts $ltf ""
set lef [open "${APP_OUT_DIR}/${APP_OUT_BASE}encoding-lec.do" "w"]
puts $lef "//!lec"
puts $lef "//"
puts $lef "// Apply FSM recoding"
puts $lef "//"
puts $lef "// Auto-generated by [info script]"
puts $lef "//"
puts $lef ""
foreach {FSMIdx TRFSMIdx} [array get Mapping] {
  set TRFSM [lindex $TRFSMShortNames $TRFSMIdx]
  set TRFSMLC [string tolower $TRFSM]
  # ModelSim
  puts $mtf "# $TRFSM"
  puts $mtf "set TRFSMBase \"/${APP_NAME_LC}_tb/DUT/${TRFSM}_1/TRFSM_1\""
  puts $mtf "do ${APP_OUT_DIR}/${APP_OUT_BASE}${TRFSMLC}-bitstream-modelsim.do"
  # LEC
  puts $ltf "// $TRFSM"
  puts $ltf "setenv TRFSMBase \"/${TRFSM}_1/TRFSM_1\""
  puts $ltf "dofile \$APPCHLL_PATH/${APP_OUT_BASE}${TRFSMLC}-bitstream-lec.do"
  # LEC FSM Encoding
  puts $lef "// $TRFSM"
  puts $lef "read fsm encoding \$APPCHLL_PATH/${APP_OUT_BASE}${TRFSMLC}-encoding-lec.txt -golden"
}
close $mtf
close $ltf
close $lef

# Write updated module
puts "## Writing module $APP_NAME with \$fsm cells replaced to $APP_VLOG_OUT"
write_module $module -format verilog "$APP_VLOG_OUT"
write_module $module -format ilang   "${APP_OUT_DIR}/${APP_OUT_BASE}trfsm.il"

if {!$Local} {
  puts "## Write bitstreams for unused TR-FSMs"
  foreach {TRFSMIdx FSMIdx} [array get TRFSMMapping] {
    if {$FSMIdx < 0} {
      # unused TR-FSM instance
      set TRFSM       [lindex $TRFSMs          $TRFSMIdx]
      set ShortName   [lindex $TRFSMShortNames $TRFSMIdx]
      set ShortNameLC [string tolower $ShortName]
      puts "  Unused TR-FSM $ShortName"

      set BS [generate_bitstream $TRFSM]
      set RegName "CfgReg_${ShortName}_0"    ;# TInterSynthHandler.SetupConfigRegisters creates these register
      write_bitstream $BS -format vhdl         ${ShortName}  ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream.vhd
      write_bitstream $BS -format verilog      ${ShortName}  ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream.v
      write_bitstream $BS -format c            ${RegName}    ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream.inc.c
      write_bitstream $BS -format text         ${ShortName}  ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream.txt
      write_bitstream $BS -format modelsim     "\$TRFSMBase" ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream-modelsim.do
      write_bitstream $BS -format lec -revised "\$TRFSMBase" ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream-lec.do
      write_bitstream $BS -format formality    "\$TRFSMBase" ${APP_OUT_DIR}/${APP_OUT_BASE}${ShortNameLC}-bitstream-formality.tcl
    }
  }
  unset TRFSMMapping
}
