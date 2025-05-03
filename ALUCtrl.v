module ALUCtrl (
    input  [1:0] ALUOp,
    input  funct7,
    input  [2:0] funct3,
    output reg [3:0] ALUCtl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUCtl = 4'b0010; // ADD for LW, SW, ADDI
            2'b01: begin
                case(funct3)
                    3'b000: ALUCtl = 4'b0110; // SUB for BEQ, BGT
                    3'b110: ALUCtl = 4'b0001; // ORI
                endcase
            end
            2'b10: begin // R-Type instructions (ADD, SUB)
                case ({funct7, funct3})
                    4'b0000: ALUCtl = 4'b0010; // ADD
                    4'b1000: ALUCtl = 4'b0110; // SUB
                endcase
            end
            2'b11: begin // I-Type and B-extension instructions (SLTI, ORI, CTZ)
                case (funct3)
                    3'b000: begin
                    if (funct7 == 1'b0) 
					ALUCtl = 4'b1001; // New ALU Control Code for CTZ
                        // For CTZ - check for B-extension opcode/function bits
                        // Add a condition to specifically identify CTZ instruction
						else ALUCtl = 4'b0010; // ADDI
						end
                    3'b010: ALUCtl = 4'b0111; // SLTI
                    3'b111: ALUCtl = 4'b0001; // ORI (changed from 1010 to 0001 to be consistent)
                endcase
            end
            default: ALUCtl = 4'b0000; // default case
        endcase
    end
endmodule