set_property SRC_FILE_INFO {cfile:c:/JHU_Classes/RISC_V/riscv-cpu/RTL/CPUs/RISCVsinglecycleint/RISCVsinglecycleint.gen/sources_1/ip/clk_wiz_0_1/clk_wiz_0.xdc rfile:../RISCVsinglecycleint.gen/sources_1/ip/clk_wiz_0_1/clk_wiz_0.xdc id:1 order:EARLY scoped_inst:clk_wiz_0/inst} [current_design]
set_property SRC_FILE_INFO {cfile:c:/JHU_Classes/RISC_V/riscv-cpu/RTL/CPUs/RISCVsinglecycleint/RISCVsinglecycleint.gen/sources_1/ip/ila_0/ila_v6_2/constraints/ila.xdc rfile:../RISCVsinglecycleint.gen/sources_1/ip/ila_0/ila_v6_2/constraints/ila.xdc id:2 order:EARLY scoped_inst:sc_interrupt_sys/my_ila/inst} [current_design]
set_property SRC_FILE_INFO {cfile:C:/JHU_Classes/RISC_V/riscv-cpu/RTL/CPUs/RISCVsinglecycleint/RISCVsinglecycleint.srcs/constrs_1/imports/cod_riscv_cpu/mfp_nexys4_ddr.xdc rfile:../RISCVsinglecycleint.srcs/constrs_1/imports/cod_riscv_cpu/mfp_nexys4_ddr.xdc id:3} [current_design]
current_instance clk_wiz_0/inst
set_property src_info {type:SCOPED_XDC file:1 line:54 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.100
current_instance
current_instance sc_interrupt_sys/my_ila/inst
set_property src_info {type:SCOPED_XDC file:2 line:108 export:INPUT save:INPUT read:READ} [current_design]
create_waiver -internal -quiet -type CDC -id {CDC-10} -user ila -tags "1191969" -description "CDC-10 waiver for DDR Calibration logic" -scope -from [get_pins -quiet -filter {REF_PIN_NAME=~*CLK} -of_objects [get_cells -hierarchical -filter {NAME =~*u_trig/N_DDR_TC.N_DDR_TC_INST[*].U_TC/allx_typeA_match_detection.ltlib_v1_0_2_allx_typeA_inst/DUT/u_srl_drive}]] -to [get_pins -quiet -filter {REF_PIN_NAME=~*D} -of_objects [get_cells -hierarchical -filter {NAME =~*u_trig/N_DDR_TC.N_DDR_TC_INST[*].U_TC/allx_typeA_match_detection.ltlib_v1_0_2_allx_typeA_inst/DUT/I_IS_TERMINATION_SLICE_W_OUTPUT_REG.DOUT_O_reg}]]
set_property src_info {type:SCOPED_XDC file:2 line:112 export:INPUT save:INPUT read:READ} [current_design]
create_waiver -internal -quiet -type CDC -id {CDC-10} -user system_ila -tags "1196835" -description "CDC-10 waiver for DDR Calibration logic" -scope -from [get_pins -quiet -filter {REF_PIN_NAME=~*CLK} -of_objects [get_cells -hierarchical -filter {NAME =~*u_trig/N_DDR_TC.N_DDR_TC_INST[*].U_TC/allx_typeA_match_detection.ltlib_v1_0_2_allx_typeA_inst/DUT/u_srl_drive}]] -to [get_pins -quiet -filter {REF_PIN_NAME=~*D} -of_objects [get_cells -hierarchical -filter {NAME =~*u_trig/N_DDR_TC.N_DDR_TC_INST[*].U_TC/allx_typeA_match_detection.ltlib_v1_0_2_allx_typeA_inst/DUT/I_WHOLE_SLICE.G_SLICE_IDX[*].U_ALL_SRL_SLICE/I_IS_TERMINATION_SLICE_W_OUTPUT_REG.DOUT_O_reg}]]
current_instance
set_property src_info {type:XDC file:3 line:50 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN R12   IOSTANDARD LVCMOS33 } [get_ports { LED16_B }]; #IO_L5P_T0_D06_14 Sch=led16_b
set_property src_info {type:XDC file:3 line:51 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN M16   IOSTANDARD LVCMOS33 } [get_ports { LED16_G }]; #IO_L10P_T1_D14_14 Sch=led16_g
set_property src_info {type:XDC file:3 line:52 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { LED16_R }]; #IO_L11P_T1_SRCC_14 Sch=led16_r
set_property src_info {type:XDC file:3 line:53 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { LED17_B }]; #IO_L15N_T2_DQS_ADV_B_15 Sch=led17_b
set_property src_info {type:XDC file:3 line:54 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN R11   IOSTANDARD LVCMOS33 } [get_ports { LED17_G }]; #IO_0_14 Sch=led17_g
set_property src_info {type:XDC file:3 line:55 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { LED17_R }]; #IO_L11N_T1_SRCC_14 Sch=led17_r
set_property src_info {type:XDC file:3 line:68 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { DP }]; #IO_L19N_T3_A21_VREF_15 Sch=dp
set_property src_info {type:XDC file:3 line:100 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { JA[7] }]; #IO_L16N_T2_A27_15 Sch=ja[7]
set_property src_info {type:XDC file:3 line:101 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { JA[8] }]; #IO_L16P_T2_A28_15 Sch=ja[8]
set_property src_info {type:XDC file:3 line:102 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { JA[9] }]; #IO_L22N_T3_A16_15 Sch=ja[9]
set_property src_info {type:XDC file:3 line:103 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { JA[10] }]; #IO_L22P_T3_A17_15 Sch=ja[10]
set_property src_info {type:XDC file:3 line:112 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {JB[7]}]
set_property src_info {type:XDC file:3 line:113 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports {JB[8]}]
set_property src_info {type:XDC file:3 line:114 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { JB[9] }]; #IO_0_15 Sch=jb[9]
set_property src_info {type:XDC file:3 line:115 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { JB[10] }]; #IO_L13P_T2_MRCC_15 Sch=jb[10]
