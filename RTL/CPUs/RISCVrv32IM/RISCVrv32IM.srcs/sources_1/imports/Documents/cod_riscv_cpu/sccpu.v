                                        /************************************************
  The Verilog HDL code example is from the book
  Computer Principles and Design in Verilog HDL
  by Yamin Li, published by A JOHN WILEY & SONS
************************************************/
module sccpu (clk,clrn,halt,inst,mem,pc,wmem,alu,data);
    input  [31:0] inst;                           // inst from inst memory
    input  [31:0] mem;                            // data from data memory
    input         clk, clrn;                      // clock and reset
    input         halt;                           // suspend the PC at current location
    output [31:0] pc;                             // program counter
    output [31:0] alu;                            // alu output
    output [31:0] data;                           // data to data memory
    output        wmem;                           // write data memory
    // instruction fields
    wire    [6:0] opcode   = inst[6:0];               // op
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
    wire    rv32m,wpc,mdwait,fuse,mul_fuse,rem_fuse;                     // signals for rv32m
    
	wire    [31:0] imme32;
	wire	[31:0] braddr;
	wire    [31:0] jalraddr;
	wire    [31:0] jaladdr;
    
    // datapath wires
    wire   [31:0] p4;                             // pc+4
    wire   [31:0] bpc;                            // branch target address
    wire   [31:0] npc;                            // next pc
    wire   [31:0] qa;                             // regfile output port a
    wire   [31:0] qb;                             // regfile output port b
    wire   [31:0] alua;                           // alu input a
    wire   [31:0] alub;                           // alu input b
    wire   [31:0] wd;                             // regfile write port data
    wire   [31:0] r;                              // alu out or mem
    wire          z;                              // alu, zero tag
    wire    [31:0] c_rv32m;   
    wire    [31:0] aluwrv32m;                    // output from rv32m
    // control unit
    sc_cu cu(
    .clk(clk),
    .clrn(clrn),
    .opcode(opcode),
    .func7(func7),
    .func3(func3),
    .z(z),
    .aluc(aluc),
    .alui(alui),
    .pcsrc(pcsrc),
    .m2reg(m2reg),
    .bimm(bimm),
    .call(call),
    .wreg(wreg),
    .wmem(wmem),
    .rv32m(rv32m),
    .wpc(wpc),
    .mdwait(mdwait),
    .fuse(fuse),
    .mul_fuse(mul_fuse),
    .rem_fuse(rem_fuse)); // control unit
    // datapath4
    dffe32 pcreg (npc,clk,clrn,wpc,pc);              // pc register
    pc4 pc4func (pc,halt,p4); // pc + 4 (pc + 0 if halt)
    mux2x32 alu_b (qb,imme32,bimm,alub);           // alu input b
    mux2x32 alu_m (aluwrv32m,mem,m2reg,r);              // alu out or mem
    mux2x32 link  (r,p4,call,wd);                  // r or p4
    mux4x32 nextpc(p4,braddr,jalraddr,jaladdr,pcsrc,npc);      // next pc
    regfile rf (rs1,rs2,wd,rd,wreg,clk,clrn,qa,qb); // register file
    alu alunit (qa,alub,aluc,alu,z);            // alu
    rv32m_fuseALU rv32MD(rv32m,qa,qb,rs1,rs2,func3,clk,clrn,mdwait,c_rv32m,fuse,mul_fuse,rem_fuse);
    //mux2x32 rv32mmux (alu,c_rv32m,aluwrv32m,rv32m);
    mux2x32 rv32mmux (alu,c_rv32m,rv32m,aluwrv32m);
    jal_addr jala(pc,inst,jaladdr);
    jalr_addr jalra(qa,inst,jalraddr);
    imme immeblock(inst,alui,imme32);
    branch_addr bra(pc,inst,braddr);
    assign data = qb;                             // regfile output port b
    
    //Bad instruction detector - used in simulation to catch if the C compiler
    //generates instructions unimplemented in this variant
    //mips_bad_inst_det binstd(.inst(inst));
endmodule
