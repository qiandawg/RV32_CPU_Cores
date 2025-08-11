/************************************************
  The Verilog HDL code example is from the book
  Computer Principles and Design in Verilog HDL
  by Yamin Li, published by A JOHN WILEY & SONS
************************************************/

`include "mfp_ahb_const.vh"
module mccomp_sys (
    input                   SI_CLK100MHZ,
    input                   lock,
    input                   SI_ClkIn,
    input                   SI_Reset_N,
    output [3:0]            state,
    output [31:0]           a,
    output [31:0]           b,
    output [31:0]           alu,
    output [31:0]           adr,
    output [31:0]           tom,
    output [31:0]           fromm,
    output [31:0]           pc,
    output [31:0]           ir,
    input                   memclk,
    input  [`MFP_N_SW-1 :0] IO_Switch,
    input  [`MFP_N_PB-1 :0] IO_PB,
    output [`MFP_N_LED-1:0] IO_LED,
    output [ 7          :0] IO_7SEGEN_N,
    output [ 6          :0] IO_7SEG_N,
    output                  IO_BUZZ,                  
    output                  IO_RGB_SPI_MOSI,
    output                  IO_RGB_SPI_SCK,
    output                  IO_RGB_SPI_CS,
    output                  IO_RGB_DC,
    output                  IO_RGB_RST,
    output                  IO_RGB_VCC_EN,
    output                  IO_RGB_PEN,
    output                  IO_CS,
    output                  IO_SCK,
    input                   IO_SDO,
    input                   UART_RX,
    inout[4:1]              JB,
    input [26:0]            counter);

     wire[31:0] data_cpu; //data driven by cpu
     wire[31:0] data_mem; //data driven by data memory
     wire[31:0] data_gpio; //data driven by GPIO module
     wire[31:0] memout;
     
     wire dbg_resetn_cpu;
     wire dbg_halt_cpu;
     
     wire          wmem;                           // write data memory
     wire clk;
     wire clrn;
     assign clk=SI_ClkIn;
     assign clrn = SI_Reset_N & dbg_resetn_cpu;
 // Check if memory mapped I/O
     wire[2:0] HSEL;
     
    mc_cpu mc_cpu (clk,clrn, memout,pc,ir,
        a,b,alu,wmem,adr,data_cpu,state);    // cpu
    mccomp_decoder mccomp_decoder(adr,HSEL);

    //Be sure to use forward slashes '/', even on Windows
    parameter RAM_FILE = "d:/RISCV-cpu-old1/Software/Assembly/RISCVscLEDSwitches/mem.mem";
    //parameter RAM_FILE = "d:/RISCV-cpu/Software/Assembly/RISCVLEDCount/mem.mem";
    //parameter RAM_FILE = "d:/RISCV-cpu/Software/Assembly/RISCVLightSensorC/mem.mem";
    //parameter RAM_FILE = "d:/RISCV-cpu-old1/Software/Assembly/RISCVmcSwitchesLED7Seg/mem.mem";

    wire[31:0] dbg_mem_addr;
    wire[31:0] dbg_mem_din;
    wire dbg_mem_cs;
    wire dbg_mem_we;

    wire effectiveMemWE = dbg_mem_cs ? dbg_mem_we : wmem;
    wire effectiveMemCE = dbg_mem_cs | HSEL[1];
    wire[31:0] effectiveMemAddr = dbg_mem_cs ? dbg_mem_addr : adr;
    wire[31:0] effectiveRAMDataInput = dbg_mem_we ? dbg_mem_din : memout;
    uram #(.A_WIDTH(9), .INIT_FILE(RAM_FILE), .READ_DELAY(0)) system_ram
        (.clk(clk), .we(effectiveMemWE), .cs(effectiveMemCE), .addr(effectiveMemAddr), .data_in(effectiveRAMDataInput), .data_out(data_mem));
 
 
    cpugpio gpio (.clk(clk),
        .clrn(clrn),
        .dataout(data_gpio),
        .datain(memout),
        .haddr(adr[7:2]),  // This is a mod to include more I/O
        .we(wmem),
        .HSEL(HSEL[2]),
        .IO_Switch(IO_Switch),
        .IO_PB(IO_PB),
        .IO_LED(IO_LED),
        .IO_7SEGEN_N(IO_7SEGEN_N),
        .IO_7SEG_N(IO_7SEG_N),
        .IO_BUZZ(IO_BUZZ),                
        .IO_RGB_SPI_MOSI(IO_RGB_SPI_MOSI),
        .IO_RGB_SPI_SCK(IO_RGB_SPI_SCK),
        .IO_RGB_SPI_CS(IO_RGB_SPI_CS),
        .IO_RGB_DC(IO_RGB_DC),
        .IO_RGB_RST(IO_RGB_RST),
        .IO_RGB_VCC_EN(IO_RGB_VCC_EN),
        .IO_RGB_PEN(IO_RGB_PEN),
        .IO_SDO(IO_SDO),
        .IO_CS(IO_CS),
        .IO_SCK(IO_SCK));
    
    assign memout = wmem ? data_cpu :
                    HSEL[1] ? data_mem :
                    HSEL[2] ? data_gpio :
                    32'b0;
                    
    debug_control debug_if(.serial_tx(JB[2]), .serial_rx(JB[3]), .cpu_clk(clk),
        .sys_rstn(SI_Reset_N), .cpu_mem_addr(dbg_mem_addr),
        .cpu_debug_to_mem_data(dbg_mem_din), .cpu_mem_to_debug_data(memout),
        .cpu_mem_we(dbg_mem_we), .cpu_mem_ce(dbg_mem_cs),
        .cpu_mem_to_debug_data_ready(dbg_mem_cs & ~dbg_mem_we),
        .cpu_resetn_cpu(dbg_resetn_cpu), .cpu_halt_cpu(dbg_halt_cpu));

ila_0 my_ila (
    .clk(SI_CLK100MHZ),                  // Clock used for ILA
    .probe0(ir),          // Probe for data bus
    .probe1(pc),       // Probe for address bus
    .probe2(SI_ClkIn),   // Probe for control signal 1
    .probe3(SI_Reset_N),    // Probe for control signal 2
    .probe4(lock),
    .probe5(counter),
    .probe6(IO_Switch),
    .probe7(IO_LED),
    .probe8(dbg_mem_cs),
    .probe9(dbg_mem_we),
    .probe10(dbg_mem_addr),
    .probe11(dbg_mem_din),
    .probe12(dbg_halt_cpu),
    .probe13(dbg_resetn_cpu),
    .probe14(IO_7SEGEN_N),
    .probe15(IO_7SEG_N),
    .probe16(state)    
    );
                                            
endmodule
