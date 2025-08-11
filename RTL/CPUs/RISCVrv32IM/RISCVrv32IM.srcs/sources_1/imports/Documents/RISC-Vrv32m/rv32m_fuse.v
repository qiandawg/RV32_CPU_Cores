`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2024 02:05:48 AM
// Design Name: 
// Module Name: rv32m_fuse
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


module rv32m_fuse(
    input clk,
    input clrn,
    input rv32m,
    input srv32m,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] srs1,
    input [4:0] srs2,
    input [2:0] func3,
    input [2:0] sfunc3,
    output reg fuse,
    output reg mul_fuse,
    output reg rem_fuse
);

    always @(*) begin
        mul_fuse = 1'b0;
        rem_fuse = 1'b0;

        // Check for MUL fusion
        if ((func3 == 3'b000) && srv32m &&
            (srs1 == rs1) && (srs2 == rs2) &&
            (sfunc3 == 3'b001 || sfunc3 == 3'b010 || sfunc3 == 3'b011)) begin
            mul_fuse = 1'b1;
        end

        // Check for REM/DIV fusion
        if ((func3[2:1] == 2'b11) && srv32m &&
            (srs1 == rs1) && (srs2 == rs2) &&
            (sfunc3 == 3'b100 || sfunc3 == 3'b101)) begin
            rem_fuse = 1'b1;
        end

        // Final fusion signal
        fuse = mul_fuse | rem_fuse;
    end

endmodule
