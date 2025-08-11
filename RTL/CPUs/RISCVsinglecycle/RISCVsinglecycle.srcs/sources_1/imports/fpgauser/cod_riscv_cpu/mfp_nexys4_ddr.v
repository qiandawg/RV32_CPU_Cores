// mfp_nexys4_ddr.v
// January 1, 2017
// Modified by N Beser for Li Architecture 11/2/2017
//
// Instantiate the sccomp system and rename signals to
// match the GPIO, LEDs and switches on Digilent's (Xilinx)
// Nexys4 DDR board

// Outputs:
// 16 LEDs (IO_LED) 
// Inputs:
// 16 Slide switches (IO_Switch),
// 5 Pushbuttons (IO_PB): {BTNU, BTND, BTNL, BTNC, BTNR}
//

`include "mfp_ahb_const.vh"

module mfp_nexys4_ddr( 
                        input                   CLK100MHZ,
                        input                   CPU_RESETN,
                        input                   BTNU, BTND, BTNL, BTNC, BTNR, 
                        input  [`MFP_N_SW-1 :0] SW,
                        output [`MFP_N_LED-1:0] LED,
                        inout [4            :1] JA,
                        inout  [ 4          :1] JB,
                        output [ 7          :0] AN,
                        output                  CA, CB, CC, CD, CE, CF, CG,
                        output [ 10         :1] JC,
                        output [ 4          :1] JD,
                        input                   UART_TXD_IN);

  // Press btnCpuReset to reset the processor. 
        
  wire clk_out; 
  wire [31:0] pc;
  reg [23:0] delay;
  wire cpu_cpu;
  wire [31:0] inst;
  wire [31:0] aluout;
  wire [31:0] memout;
  wire locked;
 
  wire CPU_RESETX;
  wire reset;
  assign CPU_RESET = reset;
  assign CPU_RESETX =locked & ~CPU_RESET * CPU_RESETN;
  
  clk_wiz_0 clk_wiz_0(.clk_in1(CLK100MHZ), .reset(reset),.locked(locked),.clk_out1(clk_out));
  //clk_wiz_0 clk_wiz_0(.clk_in1(CLK100MHZ), .clk_out1(clk_out));
    // Instantiate the button debouncer for reset
    button_debounce #(
        .DEBOUNCE_PERIOD(1000000)  // 10ms at 100MHz
    ) reset_debouncer (
        .clk(CLK100MHZ),
        .btn_in(BTNC),
        .btn_debounced(reset)
    );


   // Simple counter to demonstrate the 50MHz clock is working
    // This can be monitored in the ILA
    reg [26:0] counter = 0;
    always @(posedge clk_out or posedge reset) begin
        if (reset)
            counter <= 0;
        else
            counter <= counter + 1;
    end
  sc_computer sc_computer(
                    .SI_CLK100MHZ(CLK100MHZ),
                    .lock(locked),
			        .SI_Reset_N(CPU_RESETX),
                    .SI_ClkIn(clk_out),
                    .inst(inst),
                    .pc(pc),
                    .aluout(aluout),
                    .memout(memout),
                    .memclk(clk_out),
                    .IO_Switch(SW),
                    .IO_PB({BTNU, BTND, BTNL, BTNC, BTNR}),
                    .IO_LED(LED),
                    .IO_7SEGEN_N(AN),
                    .IO_7SEG_N({CA,CB,CC,CD,CE,CF,CG}), 
                    .IO_BUZZ(JD[1]),
                    .IO_RGB_SPI_MOSI(JC[2]),
                    .IO_RGB_SPI_SCK(JC[4]),
                    .IO_RGB_SPI_CS(JC[1]),
                    .IO_RGB_DC(JC[7]),
                    .IO_RGB_RST(JC[8]),
                    .IO_RGB_VCC_EN(JC[9]),
                    .IO_RGB_PEN(JC[10]),
                    .IO_CS(JA[1]),
                    .IO_SCK(JA[4]),
                    .IO_SDO(JA[3]),
                    .UART_RX(UART_TXD_IN),
                    .JB(JB),
                    .counter(counter));
       
endmodule
