# Generated by Yosys 0.3.0+ (git sha1 3b52121)

attribute \src "../../verilog/counter_rv1.v:1"
attribute \techmap_celltype "Counter_RV1_Timer Counter_RV1_TV1"
module \Counter_RV1

  attribute \src "../../verilog/counter_rv1.v:3"
  wire input 2 \Clk_i

  attribute \src "../../verilog/counter_rv1.v:14"
  wire width 16 \D_s

  attribute \src "../../verilog/counter_rv1.v:5"
  wire input 4 \Enable_i

  attribute \src "../../verilog/counter_rv1.v:15"
  wire \Overflow_s

  attribute \src "../../verilog/counter_rv1.v:6"
  wire width 16 input 5 \PresetVal_i

  attribute \src "../../verilog/counter_rv1.v:4"
  wire input 3 \Preset_i

  attribute \src "../../verilog/counter_rv1.v:2"
  wire input 1 \Reset_n_i

  attribute \src "../../verilog/counter_rv1.v:7"
  wire output 6 \Zero_o

  attribute \src "../../verilog/counter_rv1.v:20"
  cell \Counter \ThisCounter
    connect \Clk_i \Clk_i
    connect \D_o \D_s
    connect \Direction_i 1'1
    connect \Enable_i \Enable_i
    connect \Overflow_o \Overflow_s
    connect \PresetVal_i \PresetVal_i
    connect \Preset_i \Preset_i
    connect \ResetSig_i 1'0
    connect \Reset_n_i \Reset_n_i
    connect \Zero_o \Zero_o
  end
end

attribute \src "../../verilog/counter_tv1.v:1"
module \Counter_TV1

  attribute \src "../../verilog/counter_tv1.v:29"
  wire $0\Ovfl[0:0]

  attribute \src "../../verilog/counter_tv1.v:29"
  wire width 16 $0\Value[15:0]

  attribute \src "../../verilog/counter_tv1.v:47"
  wire width 17 $add$../../verilog/counter_tv1.v:47$11_Y

  wire $procmux$40_Y

  wire $procmux$42_Y

  wire $procmux$45_Y

  wire width 16 $procmux$52_Y

  wire width 16 $procmux$54_Y

  wire width 16 $procmux$57_Y

  attribute \src "../../verilog/counter_tv1.v:49"
  wire width 17 $sub$../../verilog/counter_tv1.v:49$12_Y

  attribute \intersynth_port "Clk_i"
  attribute \src "../../verilog/counter_tv1.v:7"
  wire input 2 \Clk_i

  attribute \intersynth_conntype "Word"
  attribute \src "../../verilog/counter_tv1.v:19"
  wire width 16 output 8 \D_o

  attribute \intersynth_conntype "Bit"
  attribute \src "../../verilog/counter_tv1.v:15"
  wire input 6 \Direction_i

  attribute \intersynth_conntype "Bit"
  attribute \src "../../verilog/counter_tv1.v:13"
  wire input 5 \Enable_i

  attribute \intersynth_conntype "Bit"
  attribute \src "../../verilog/counter_tv1.v:21"
  wire output 9 \Overflow_o

  attribute \intersynth_conntype "Word"
  attribute \src "../../verilog/counter_tv1.v:17"
  wire width 16 input 7 \PresetVal_i

  attribute \intersynth_conntype "Bit"
  attribute \src "../../verilog/counter_tv1.v:11"
  wire input 4 \Preset_i

  attribute \intersynth_conntype "Bit"
  attribute \src "../../verilog/counter_tv1.v:9"
  wire input 3 \ResetSig_i

  attribute \intersynth_port "Reset_n_i"
  attribute \src "../../verilog/counter_tv1.v:5"
  wire input 1 \Reset_n_i

  attribute \intersynth_conntype "Bit"
  attribute \src "../../verilog/counter_tv1.v:23"
  wire output 10 \Zero_o

  cell \Counter \Counter
    connect \Clk_i \Clk_i
    connect \D_o \D_o
    connect \Direction_i \Direction_i
    connect \Enable_i \Enable_i
    connect \Overflow_o \Overflow_o
    connect \PresetVal_i \PresetVal_i
    connect \Preset_i \Preset_i
    connect \ResetSig_i \ResetSig_i
    connect \Reset_n_i \Reset_n_i
    connect \Zero_o \Zero_o
  end
end
