`include "mfp_ahb_const.vh"

module pl_computer (      // pipelined cpu
    input SI_CLK100MHZ,
    input lock,
    input         SI_ClkIn,             // clock                             // plus inst mem
    input         SI_Reset_N,            // reset                             // and  data mem
    output [31:0] pc,              // program counter
    output [31:0] inst,            // instruction in ID stage
    output [31:0] eal,             // alu or epc4 in EXE stage
    output [31:0] mal,             // eal in MEM stage
    output [31:0] wres,            // data to be written into register file
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
    inout [8:1] JB,
    input [26:0] counter);
    wire clk;
    wire clrn;
    wire dbg_resetn_cpu;
    wire dbg_halt_cpu;
    
    assign clk=SI_ClkIn;
    assign clrn=SI_Reset_N & dbg_resetn_cpu; 
    wire[31:0] dbg_imem_addr;
    wire[31:0] dbg_imem_din;
    wire dbg_imem_ce;
    wire dbg_imem_we;

    wire[31:0] dbg_dmem_addr;
    wire[31:0] dbg_dmem_din;
    wire dbg_dmem_ce;
    wire dbg_dmem_we;

    wire[31:0] effectiveIMemAddr = dbg_imem_ce ? dbg_imem_addr : pc;


    // signals in IF stage
    wire   [31:0] pc4;             // pc+4 in IF stage
    wire   [31:0] ins;             // instruction in IF stage
    wire   [31:0] npc;             // next pc in IF stage
    // signals in ID stage
    wire   [31:0] dpc;             // pc in ID stage
    wire   [31:0] dpc4;            // pc+4 in ID stage
    wire   [31:0] bra;             // branch target of beq and bne instructions
    wire   [31:0] jalra;           // jump target of jalr instruction
    wire   [31:0] jala;            // jump target of jal instruction
    wire   [31:0] da;              // operand a in ID stage
    wire   [31:0] db;              // operand b in ID stage
    wire   [31:0] dd;              // reg data to mem in ID stage
    wire    [4:0] rd = inst[11:7]; // destination register number in ID stage
    wire    [3:0] aluc;            // alu control in ID stage
    wire    [1:0] pcsrc;           // next pc (npc) select in ID stage
    wire          wpcir;           // pipepc and pipeir write enable
    wire          m2reg;           // memory to register in ID stage
    wire          wreg;            // register file write enable in ID stage
    wire          wmem;            // memory write in ID stage
    wire          call;            // jalr, jal in ID stage
    wire          cancel;          // cancel in ID stage
    // signals in EXE stage
    wire   [31:0] epc4;            // pc+4 in EXE stage
    wire   [31:0] ea;              // operand a in EXE stage
    wire   [31:0] eb;              // operand b in EXE stage
    wire   [31:0] ed;              // reg data to mem in EXE stage
    wire    [4:0] erd;             // destination register number in EXE stage
    wire    [3:0] ealuc;           // alu control in EXE stage
    wire          em2reg;          // memory to register in EXE stage
    wire          ewreg;           // register file write enable in EXE stage
    wire          ewmem;           // memory write in EXE stage
    wire          ecall;           // jalr, jal in EXE stage
    wire          ecancel;         // cancel in EXE stage
    // signals in MEM stage
    wire   [31:0] mm;              // memory data out in MEM stage
    wire   [31:0] md;              // reg data to mem in MEM stage
    wire    [4:0] mrd;             // destination register number in MEM stage
    wire          mm2reg;          // memory to register in MEM stage
    wire          mwreg;           // register file write enable in MEM stage
    wire          mwmem;           // memory write in MEM stage
    // signals in WB stage
    wire   [31:0] wal;             // mal in WB stage
    wire   [31:0] wm;              // memory data out in WB stage
    wire    [4:0] wrd;             // destination register number in WB stage
    wire          wm2reg;          // memory to register in WB stage
    wire          wwreg;           // register file write enable in WB stage
    // program counter
    pl_reg_pc prog_cnt (npc,wpcir,clk,clrn, pc);
    pc4 pc4func (pc,dbg_halt_cpu,pc4); // pc + 4 (pc + 0 if halt)
    mux4x32 nextpc(pc4,bra,jalra,jala,pcsrc,npc);      // next pc
    pl_reg_if pipeif(pc,ins,clk, clrn, dbg_halt_cpu,dbg_imem_we, effectiveIMemAddr, dbg_imem_din);
    //pl_stage_if if_stage (pcsrc,pc,bra,jalra,jala,npc,pc4,ins);             // IF stage
    // IF/ID pipeline register
    pl_reg_ir fd_reg ( pc, pc4,ins, wpcir,clk,clrn, dpc,dpc4,inst);
    pl_stage_id id_stage (mrd,mm2reg,mwreg,erd,em2reg,ewreg,ecancel,dpc,inst,eal,mal,mm,
                          wrd,wres,wwreg,clk,clrn,bra,jalra,jala,pcsrc,wpcir,cancel,wreg,
                          m2reg,wmem,call,aluc,da,db,dd);                   // ID stage
    // ID/EXE pipeline register
    pl_reg_de de_reg ( cancel, wreg, m2reg, wmem, call, aluc, rd,dpc4,da,db,dd,clk,clrn,
                      ecancel,ewreg,em2reg,ewmem,ecall,ealuc,erd,epc4,ea,eb,ed);
    pl_stage_exe exe_stage (ea,eb,epc4,ealuc,ecall, eal);                   // EXE stage
    // EXE/MEM pipeline register
    pl_reg_em em_reg (ewreg,em2reg,ewmem,eal,ed,erd,clk,clrn,
                      mwreg,mm2reg,mwmem,mal,md,mrd);
    pl_stage_mem mem_stage (mwmem,mal,md,clk, clrn, mm,dbg_dmem_ce, dbg_dmem_we,dbg_dmem_din,dbg_dmem_addr,IO_Switch,
                                           IO_PB,IO_LED,IO_7SEGEN_N,
                                           IO_7SEG_N,IO_BUZZ,IO_RGB_SPI_MOSI,
                                           IO_RGB_SPI_SCK,IO_RGB_SPI_CS, IO_RGB_DC,
                                           IO_RGB_RST,IO_RGB_VCC_EN, IO_RGB_PEN,
                                           IO_CS,  IO_SCK,IO_SDO,UART_RX);                          // MEM stage
    // MEM/WB pipeline register
    pl_reg_mw mw_reg (mwreg,mm2reg,mm,mal,mrd,clk,clrn,wwreg,wm2reg,wm,wal,wrd);
    pl_stage_wb wb_stage (wal,wm,wm2reg, wres);                             // WB stage
    
    
    debug_control debug_if(.serial_tx(JB[2]), .serial_rx(JB[3]), .cpu_clk(clk),
        .sys_rstn(SI_Reset_N), .cpu_imem_addr(dbg_imem_addr), 
        .cpu_debug_to_imem_data(dbg_imem_din), .cpu_imem_to_debug_data(inst),
        .cpu_imem_we(dbg_imem_we), .cpu_imem_ce(dbg_imem_ce),
        .cpu_dmem_addr(dbg_dmem_addr), .cpu_debug_to_dmem_data(dbg_dmem_din),
        .cpu_imem_to_debug_data_ready(dbg_imem_ce & ~dbg_imem_we),
        .cpu_dmem_to_debug_data_ready(dbg_dmem_ce & ~dbg_dmem_we),
        .cpu_dmem_to_debug_data(mm), .cpu_dmem_we(dbg_dmem_we),
        .cpu_dmem_ce(dbg_dmem_ce), .cpu_resetn_cpu(dbg_resetn_cpu),
        .cpu_halt_cpu(dbg_halt_cpu));

ila_0 my_ila (
    .clk(SI_CLK100MHZ),                  // Clock used for ILA
    .probe0(inst),          // Probe for data bus
    .probe1(pc),       // Probe for address bus
    .probe2(SI_ClkIn),   // Probe for control signal 1
    .probe3(SI_Reset_N),    // Probe for control signal 2
    .probe4(lock),
    .probe5(counter),
    .probe6(IO_Switch),
    .probe7(IO_LED),
    .probe8(dbg_imem_cs),
    .probe9(dbg_imem_we),
    .probe10(dbg_imem_addr),
    .probe11(dbg_imem_din),
    .probe12(dbg_dmem_cs),
    .probe13(dbg_dmem_we),
    .probe14(dbg_dmem_addr),
    .probe15(dbg_dmem_din),
    .probe16(dbg_halt_cpu),
    .probe17(IO_7SEGEN_N),
    .probe18(IO_7SEG_N)    
    );
            
endmodule
