//!lec
//
// Apply TR-FSM bitstreams
//
// Auto-generated by ../scripts/reconf-module-postproc.tcl
//

// TRFSM0 used by \State
setenv TRFSMBase "/MyReconfigLogic_0/MyInterSynthModule_0/cell_80/TRFSM_1"
dofile $APPCHLL_PATH/extadc-extract-intersynth-trfsm0-bitstream-lec.do
// TRFSM1 is unused
// InterSynth bitdata
setenv BitDataReg "/MyReconfigLogic_0/CfgRegbitdata"
dofile $APPCHLL_PATH/extadc-bitdata-bitstream-lec.do
// Reconf.signals config register
setenv ReconfSignalsReg "/MyReconfigLogic_0/CfgRegReconfSignals"
dofile $APPCHLL_PATH/extadc-reconfsignals-bitstream-lec.do
