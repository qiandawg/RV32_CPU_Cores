module sc_cu (opcode,func7,func3,z,aluc,alui,pcsrc,m2reg,bimm,call,wreg,wmem); // sc control unit
    input  [6:0] opcode;
    input  [6:0] func7;
    input  [2:0] func3;
    input        z;
    
    output [3:0] aluc;
    output [1:0] alui;
    output [1:0] pcsrc;
    output       m2reg;
    output       bimm;
    output       call;
    output       wreg;
    output       wmem;

        // instruction decode
    wire i_lui = (opcode == 7'b0110111);
    wire i_jal   = (opcode == 7'b1101111);
    wire i_jalr = (opcode == 7'b1100111) & (func3 == 3'b000);
    wire i_beq   = (opcode == 7'b1100011) & (func3 == 3'b000);
    wire i_bne   = (opcode == 7'b1100011) & (func3 == 3'b001);
    wire i_lw    = (opcode == 7'b0000011) & (func3 == 3'b010);
    wire i_sw    = (opcode == 7'b0100011) & (func3 == 3'b010);
    wire i_addi  = (opcode == 7'b0010011) & (func3 == 3'b000);
    wire i_xori  = (opcode == 7'b0010011) & (func3 == 3'b100);
    wire i_ori   = (opcode == 7'b0010011) & (func3 == 3'b110);
    wire i_andi  = (opcode == 7'b0010011) & (func3 == 3'b111);
    wire i_slli  = (opcode == 7'b0010011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_srli  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_srai  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_add   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000000);
    wire i_sub   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0100000);
    wire i_slt   = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000000);
    wire i_xor   = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000000);
    wire i_or    = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000000);
    wire i_and   = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000000);

    // control signals
  	 assign aluc[0]  = i_sub  | i_xori | i_xor  | i_andi | i_add  |
							 i_slli | i_srli |  i_srai | i_beq | i_bne;//
    assign aluc[1]  = i_xor  | i_slli  | i_srli  | i_srai  | i_xori | i_beq | // Check i_beq and i_bne
                     i_bne  | i_lui; //
    assign aluc[2]  = i_or   | i_srli  | i_srai  | i_ori  | i_lui; //
    assign aluc[3]  = i_xori | i_xor | i_srai | i_beq | i_bne;
    assign m2reg    = i_lw;
    assign wmem     = i_sw;
    assign wreg     = i_lui  | i_jal | i_jalr | i_lw | i_addi | i_xori | i_ori |
							 i_andi | i_slli | i_srli | i_srai | i_add | i_sub | i_slt | 
							 i_xor | i_or | i_and;
    assign pcsrc[0] = i_beq & z | i_bne & ~z | i_jal; //
    assign pcsrc[1] = i_jal | i_jalr; //
    assign call     = i_jal | i_jalr; //
    assign alui[0]  = i_lui | i_slli | i_srli | i_srai; //
    assign alui[1]  = i_lui | i_sw; //
    assign bimm     = i_sw | i_lw | i_addi | i_lui | i_slli | i_srli | i_srai |
							 i_xori | i_ori | i_andi; //
endmodule
