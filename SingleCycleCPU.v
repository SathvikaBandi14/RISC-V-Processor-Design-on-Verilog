module SingleCycleCPU (
    input clk,
    input start
    
);

// When input start is zero, cpu should reset
// When input start is high, cpu start running

// TODO: connect wire to realize SingleCycleCPU
// The following provides simple template,
wire [31:0] PCmux_out;
wire [31:0] pc_o;
wire [31:0] add_out;
wire [31:0] inst_out;
wire branch;
wire memRead;
wire memtoReg;
wire [1:0] ALUOp;
wire ALUSrc;
wire regWrite;

wire [31:0] read_data1;
wire [31:0] read_data2;
wire [31:0] imm_out;
wire [31:0] adder2_out;
wire [31:0] PCmux_out;
wire [31:0] ALUmux_out;
wire [31:0] shifted_imm_out;
wire [3:0] ALUCtl_out;
wire [31:0] ALU_out;
wire zero;
wire [31:0] read_data_out;
wire [31:0] WriteData_mux_out;
PC m_PC(
    .clk(clk),
    .rst(start),
    .pc_i(PCmux_out),
    .pc_o(pc_o)
);

Adder m_Adder_1(
    .a(pc_o),
    .b(4),
    .sum(add_out)
);

InstructionMemory m_InstMem(
    .readAddr(pc_o),
    .inst(inst_out)
);

Control m_Control(
    .opcode(inst_out[6:0]),
    .funct3(inst_out[14:12]),
    .branch(branch),
    .memRead(memRead),
    .memtoReg(memtoReg),
    .ALUOp(ALUOp),
    .memWrite(memWrite),
    .ALUSrc(ALUSrc),
    .regWrite(regWrite)
);


Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(regWrite),
    .readReg1(inst_out[19:15]),
    .readReg2(inst_out[24:20]),
    .writeReg(inst_out[11:7]),
    .writeData(WriteData_mux_out),
    .readData1(read_data1),
    .readData2(read_data2)
);


ImmGen #(.Width(32)) m_ImmGen(
    .inst(inst_out),
    .imm(imm_out)
);

ShiftLeftOne m_ShiftLeftOne(
    .i(imm_out),
    .o(shifted_imm_out)
);

Adder m_Adder_2(
    .a(pc_o),
    .b(shifted_imm_out),
    .sum(adder2_out)
);
 assign and_out=zero && branch;
 
Mux2to1 #(.size(32)) m_Mux_PC(
    .sel(and_out),
    .s0(add_out),
    .s1(adder2_out),
    .out(PCmux_out)
);

Mux2to1 #(.size(32)) m_Mux_ALU(
    .sel(ALUSrc),
    .s0(read_data2),    
    .s1(imm_out),
    .out(ALUmux_out)
);

ALUCtrl m_ALUCtrl(
    .ALUOp(ALUOp),
    .funct7(inst_out[30]),
    .funct3(inst_out[14:12]),
    .ALUCtl(ALUCtl_out)
);

ALU m_ALU(
    .ALUCtl(ALUCtl_out),
    .A(read_data1),
    .B(ALUmux_out),
    .ALUOut(ALU_out),
    .zero(zero)
);

DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memWrite),
    .memRead(memRead),
    .address(ALU_out),
    .writeData(read_data2),
    .readData(read_data_out)
);

Mux2to1 #(.size(32)) m_Mux_WriteData(
    .sel(memtoReg),
    .s0(ALU_out),
    .s1(read_data_out),
    .out(WriteData_mux_out)
);

endmodule