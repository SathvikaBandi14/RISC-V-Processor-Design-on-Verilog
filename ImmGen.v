module ImmGen#(parameter Width = 32) (
    input [Width-1:0] inst,
    output reg signed [Width-1:0] imm
);
    // ImmGen generate imm value based on opcode

    wire [6:0] opcode = inst[6:0];
    always @(*) 
    begin
        case(opcode)
            
            // TODO: implement your ImmGen here
            // Hint: follow the RV32I opcode map table to set imm value
		// I-type: immediate arithmetic instructions (e.g. ADDI, SLTI), load instructions (e.g. LW),
            7'b0010011, // Immediate arithmetic
            7'b0000011: // Load instruction
                imm = {{20{inst[31]}},inst[31:20]};  // Sign-extend inst[31:20]
            // S-type: store instructions (e.g. SW)
            7'b0100011:
                imm = {{20{inst[31]}}, inst[31:25],inst[11:7]};  // Concatenate and sign-extend
            // B-type: branch instructions (e.g. BEQ, BNE, etc.)
            7'b1100011:
                imm = {{20{inst[31]}},inst[31], inst[7], inst[30:25], inst[11:8]};  
            // J-type: JAL instructions
            7'b1101111:
                imm = {{12{inst[31]}}, inst[31], inst[19:12],inst[20], inst[30:21]};  
            default:
                imm = 32'b0;
        endcase
        end
endmodule