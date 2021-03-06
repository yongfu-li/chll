#!flowproc
#
# Setup the application
#

# remove the following two lines
#puts "ERROR: You have to edit this file [info script] before executing."
#exit 1

puts "################################################################################"
puts "## Setup Application $APP_NAME"

create_application "$APP_NAME"

puts "## Adding ports, parameters, ..."
# system signals
app_add_port "Reset_n_i"
app_add_port "Clk_i"
# interface to CPU
app_add_port "Enable_i"      -map "ReconfModuleIn_s"   -index 0
app_add_port "CpuIntr_o"     -map "ReconfModuleIRQs_s" -index 0
# parameters
# 24000 * 10us (100kHz Clk) = 240ms
app_add_param -in -conntype "Word" -default 24000 "WaitCounterPreset_i"
app_add_param -in -conntype "Word" -default 30    "Threshold_i"
app_add_param -in -conntype "Word" -default 10    "PeriodCounterPreset_i"
# result value
app_add_param -out -conntype "Word" "SensorValue_o"
# interface to I2C master
# I2C setup
app_set_port_value "I2C_F100_400_n" '1'   ;# 100kHz
app_set_port_value "I2C_Divider800" 124   ;# datasheet: f_Clk/800000 - 1, 100MHz --> 124
# I2C control
app_add_port "I2C_ReceiveSend_n_o"    -map "I2C_ReceiveSend_n"
app_add_port "I2C_ReadCount_o"        -map "I2C_ReadCount"
app_add_port "I2C_StartProcess_o"     -map "I2C_StartProcess"
app_add_port "I2C_Busy_i"             -map "I2C_Busy"
# I2C FIFO
app_add_port "I2C_FIFOReadNext_o"     -map "I2C_FIFOReadNext"
app_add_port "I2C_FIFOWrite_o"        -map "I2C_FIFOWrite"
app_add_port "I2C_Data_o"             -map "I2C_DataIn"
app_add_port "I2C_Data_i"             -map "I2C_DataOut"
#app_add_port "I2C_FIFOEmpty_i"        -map "I2C_FIFOEmpty"
#app_add_port "I2C_FIFOFull_i"         -map "I2C_FIFOFull"
# I2C error
app_add_port "I2C_Error_i"            -map "I2C_Error"
