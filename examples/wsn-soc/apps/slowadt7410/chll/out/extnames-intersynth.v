// Access internal signals from testbench
// Auto-generated by ../scripts/intersynth-postproc.tcl

module ExtNames (
  output I2CFSM_Done,
  output[15:0] SensorValue
);
  assign I2CFSM_Done = slowadt7410_tb.DUT.MyInterSynthModule_0.cell_81.Out3_o;
  assign SensorValue = slowadt7410_tb.DUT.MyInterSynthModule_0.cell_76.Y_o;
endmodule
