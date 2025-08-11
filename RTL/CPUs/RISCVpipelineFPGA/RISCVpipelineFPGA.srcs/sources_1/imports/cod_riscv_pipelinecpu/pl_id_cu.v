module pl_id_cu (opcode,func7,func3,rs1,rs2,wpcir,pcsrc,
    		mrd,mm2reg,mwreg,erd,em2reg,ewreg,ecancel,
    		z,cancel,wreg,m2reg,wmem,calls,aluc,bimm,fwdb,fwda,alui); // sc control unit
    input  [6:0] opcode;
    input  [6:0] func7;
    input  [2:0] func3;
    input  [4:0] rs1;         
    input  [4:0] rs2;             
    input  [4:0] mrd;
    input        mm2reg;
    input        mwreg;
    input  [4:0] erd;
    input        em2reg;
    input        ewreg;
    input        ecancel;
    
    input        z;
    output       wpcir;
    output       cancel;
    output [3:0] aluc;
    output [1:0] alui;
    output [1:0] pcsrc;
    output       m2reg;
    output       bimm;
    output       calls;
    output       wreg;
    output       wmem;
    output  [1:0] fwda;     // forward a: 00:qa; 01:exe; 10:mem; 11:mem_mem
    output  [1:0] fwdb;     // forward b: 00:qb; 01:exe; 10:mem; 11:mem_mem

        // instruction decode
            // instruction decode
    wire i_lui  = ~ecancel & (opcode == 7'b0110111);
    wire i_jal  = ~ecancel & (opcode == 7'b1101111);
    wire i_jalr = ~ecancel & (opcode == 7'b1100111) & (func3 == 3'b000);
    wire i_beq  = ~ecancel & (opcode == 7'b1100011) & (func3 == 3'b000);
    wire i_bne  = ~ecancel & (opcode == 7'b1100011) & (func3 == 3'b001);
    wire i_lw   = ~ecancel & (opcode == 7'b0000011) & (func3 == 3'b010);
    wire i_sw   = ~ecancel & (opcode == 7'b0100011) & (func3 == 3'b010);
    wire i_addi = ~ecancel & (opcode == 7'b0010011) & (func3 == 3'b000);
    wire i_xori = ~ecancel & (opcode == 7'b0010011) & (func3 == 3'b100);
    wire i_ori  = ~ecancel & (opcode == 7'b0010011) & (func3 == 3'b110);
    wire i_andi = ~ecancel & (opcode == 7'b0010011) & (func3 == 3'b111);
    wire i_slli = ~ecancel & (opcode == 7'b0010011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_srli = ~ecancel & (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_srai = ~ecancel & (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_add  = ~ecancel & (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000000);
    wire i_sub  = ~ecancel & (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0100000);
    wire i_slt  = ~ecancel & (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000000);
    wire i_xor  = ~ecancel & (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000000);
    wire i_or   = ~ecancel & (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000000);
    wire i_and  = ~ecancel & (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000000);

    wire i_rs1,i_rs2;
    
    reg [1:0] fwda, fwdb;  // forwarding, multiplexer's select signals
    always @ (ewreg, mwreg, erd, mrd, em2reg, mm2reg, rs1, rs2) begin
        // forward control signal for alu input a
	   fwda = 2'b00; // default: no hazards
	   if (ewreg & (erd != 0) & (erd == rs1) & ~em2reg) begin
	       fwda = 2'b01; // select exe_alu
	   end else begin
	       if (mwreg & (mrd != 0) & (mrd == rs1) & ~mm2reg) begin
	           fwda = 2'b10; // select mem_alu
	       end else begin
	           if (mwreg & (mrd != 0) & (mrd == rs1) & mm2reg) begin
	               fwda = 2'b11; // select mem_lw
	           end
	       end
	   end
	   // forward control signal for alu input b
	   fwdb = 2'b00; // default: no hazards
	   if (ewreg & (erd != 0) & (erd == rs2) & ~em2reg) begin
	       fwdb = 2'b01; // select exe_alu
	   end else begin
	       if (mwreg & (mrd != 0) & (mrd == rs2) & ~mm2reg) begin
	           fwdb = 2'b10; // select mem_alu
	       end else begin
	           if (mwreg & (mrd != 0) & (mrd == rs2) & mm2reg) begin
	               fwdb = 2'b11; // select mem_lw
	           end
	       end
	   end
    end

    // control signals
  	 assign aluc[0]  = i_sub  | i_xori | i_xor  | i_andi | i_add  |
							 i_slli | i_srli |  i_srai;//
    assign aluc[1]  = i_xor  | i_slli  | i_srli  | i_srai  | i_xori | i_beq | // Check i_beq and i_bne
                     i_bne  | i_lui; //
    assign aluc[2]  = i_or   | i_srli  | i_srai  | i_ori  | i_lui; //
    assign aluc[3]  = i_xori | i_xor | i_srai;
    assign m2reg    = i_lw;
  
    assign pcsrc[0] = i_beq & z | i_bne & ~z | i_jal; //
    assign pcsrc[1] = i_jal | i_jalr; //
    assign calls     = i_jal | i_jalr; //
    assign alui[0]  = i_lui | i_slli | i_srli | i_srai; //
    assign alui[1]  = i_lui | i_sw; //
    assign bimm     = i_sw | i_lw | i_addi | i_lui | i_slli | i_srli | i_srai |
    			i_xori | i_ori | i_andi; //
    			
    assign i_rs1 = i_jalr | i_beq  | i_bne  | i_lw   | i_sw   | i_addi |
	        i_xori | i_ori  | i_andi | i_slli | i_srli | i_srai |
	        i_add  | i_sub  | i_slt  | i_xor  | i_or   | i_and;

    assign i_rs2 = i_beq  | i_bne  | i_sw   |
	        i_add  | i_sub  | i_slt  | i_xor  | i_or   | i_and;

    assign wpcir = ~(ewreg & em2reg & (erd != 0) &
 	        (i_rs1 & (erd == rs1) |
 	         i_rs2 & (erd == rs2)));

    assign wreg = (i_lui  | i_jal  | i_jalr | i_lw   | i_addi | i_xori |
 	       i_ori  | i_andi | i_slli | i_srli | i_srai | i_add  |
  	       i_sub  | i_slt  | i_xor  | i_or   | i_and) & wpcir;

    assign wmem  = i_sw & wpcir; // prevent from executing twice
    // pipeline cancel if jump or branch taken
    assign cancel = pcsrc[0] | pcsrc[1];							 
endmodule
