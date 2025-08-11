                                         /************************************************
  The Verilog HDL code example is from the book
  Computer Principles and Design in Verilog HDL
  by Yamin Li, published by A JOHN WILEY & SONS
************************************************/
module mc_cpu (clk,clrn,frommem,pc,inst,alua,alub,alu,wmem,madr,tomem,state);
    input  [31:0] frommem;			  // data from memory
    input         clk, clrn;          // clock and reset
    output  [31:0] inst;              // inst from inst memory
    output  [31:0] tomem;             // data to data memory
    output [31:0] pc;                 // program counter
    output [31:0] alua;			 	 // alu input a
    output [31:0] alub;				  // alu input b
    output [31:0] alu;                // alu result
    output [31:0] madr;			 	 // memory address
    output [3:0]  state;			  // state
    output        wmem;                // write data memory
    // instruction fields
    wire    [6:0] op   = inst[6:0];               // op
    wire    [4:0] rs1   = inst[19:15];            // rs1
    wire    [4:0] rs2   = inst[25:20];             // rs2
    wire    [4:0] rd   = inst[11:7];             // rd
    wire    [2:0] func3 = inst[14:12];             // func3
    wire    [6:0] func7 = inst[31:25];             // func7
    wire   [15:0] imm  = inst[15:00];             // immediate
    wire   [25:0] addr = inst[25:00];             // address
    // control signals
    wire    [3:0] aluc;                           // alu operation control
    wire    [1:0] pcsrc;                          // select pc source
    wire          wreg;                           // write regfile
    wire          bimm;                          // control to mux for immediate value
    wire          m2reg;                          // instruction is an lw
    wire    [1:0] alui;                          // alu input b is an i32
    wire          call;                            // control to mux for pc+4 vs output wb mux
    wire          wmem;                           // write memory
	 wire	         wpc;			  // write pc
	 wire          wir;			  // write IR
	 wire          iord;			  // select memory address
    // datapath wires
    wire   [31:0] p4;                             // pc+4
    wire   [31:0] braddr;
    wire   [31:0] jalraddr;
    wire   [31:0] jaladdr;
    wire   [31:0] imme32;
    wire   [31:0] mem;
    wire   [31:0] bpc;                            // branch target address
    wire   [31:0] npc;                            // next pc
    wire   [31:0] qa;                             // regfile output port a
    wire   [31:0] qb;                             // regfile output port b
	 wire   [31:0] Aqa;                       // register qa
	 wire   [31:0] Bqb;                       // register qb
	 wire   [31:0] aluCreg;		         // register ALU
    wire   [31:0] alua;                           // alu input a
    wire   [31:0] alub;                           // alu input b
    wire   [31:0] wd;                             // regfile write port data
    wire   [31:0] r;                              // alu out or mem
    wire          z;                              // alu, zero tag
 
    // control unit
    mc_cu cu(clk,clrn,op,func7,func3,z,aluc,
    		alui,pcsrc,m2reg,bimm,call,wreg,
    		wmem,wpc,wir,iord,state); 	// control unit
    // datapath
    dffe32 pcreg (npc,clk,clrn,wpc,pc);              // pc register
    pc4 pc4func (pc,p4); // pc + 4 
	 mux2x32 addrmux (pc,aluCreg,iord,madr);         // mux to single memory
	 dffe32 ir(frommem,clk,clrn,wir,inst);                   // Instruction register
	 dff32 dr(frommem,clk,clrn,mem);                // DR register
    dff32   Aout(qa,clk,clrn,Aqa);			// A output register file
	 dff32   Bout(qb,clk,clrn,Bqb);			// B output register file
    mux2x32 alu_b (Bqb,imme32,bimm,alub);           // alu input b
    mux2x32 alu_mem (aluCreg,mem,m2reg,r);              // alu out or mem
    mux2x32 link  (r,p4,call,wd);                  // r or p4

    mux4x32 nextpc(p4,braddr,jalraddr,jaladdr,pcsrc,npc);      // next pc
    regfile rf (rs1,rs2,wd,rd,wreg,clk,clrn,qa,qb); // register file
    alu alunit (Aqa,alub,aluc,alu,z);            // alu
	 dff32 Creg(alu,clk,clrn,aluCreg);                  // C register from ALU
    jal_addr jala(pc,inst,jaladdr);
    jalr_addr jalra(pc,inst,jalraddr);
    imme immeblock(inst,alui,imme32);
    branch_addr bra(pc,inst,braddr);
    assign tomem = Bqb;                             // regfile output port b
    
    //Bad instruction detector - used in simulation to catch if the C compiler
    //generates instructions unimplemented in this variant
    //mips_bad_inst_det binstd(.inst(inst));
endmodule
