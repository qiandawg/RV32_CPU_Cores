`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2025 07:53:56 PM
// Design Name: 
// Module Name: waitwpc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module waitwpc(
    input idiv,
    input idivu,
    input mdwait,
    input clk,
    input clrn,
    input enable,
    output wpcsig
    );
 
    wire nor_idiv;     // Output of NOR gate
    wire d_input;      // Input to the D flip-flop

    assign nor_idiv = ~(idiv | idivu);  // NOR gate
    assign d_input  = nor_idiv & mdwait; // AND with mdwait

    // D flip-flop with clock enable and async clear
    dffe u_dffe (
        .d    (d_input),
        .clk  (clk),
        .clrn (clrn),
        .e    (enable),
        .q    (wpcsig)
    );    
endmodule
