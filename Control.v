module Control (
    input  [6:0] opcode,
    input  [2:0] funct3,
    output reg   branch,
    output reg   memRead,
    output reg   memtoReg,
    output reg   [1:0] ALUOp,
    output reg   memWrite,
    output reg   ALUSrc,
    output reg   regWrite
);
    always @(*) begin
        // Default values
        branch   = 0;
        memRead  = 0;
        memtoReg = 0;
        ALUOp    = 2'b00;
        memWrite = 0;
        ALUSrc   = 0;
        regWrite = 0;
        case (opcode)
            7'b0110011: begin // R-Type (ADD, SUB)
                ALUOp    = 2'b10; // Determined by funct3 and funct7
                regWrite = 1;
            end
            7'b0010011: begin // I-Type (ADDI, SLTI, ORI) and B-extension instructions (CTZ)
                ALUSrc   = 1;
                regWrite = 1;
                case (funct3)
                    3'b000: ALUOp = 2'b00; // ADDI
                    3'b010: ALUOp = 2'b11; // SLTI
                    3'b110: ALUOp = 2'b01; // ORI
                    3'b111: ALUOp = 2'b11; // ANDI
                endcase
            end
            7'b0000011: begin // Load (LW)
                memRead  = 1;
                memtoReg = 1;
                ALUSrc   = 1;
                regWrite = 1;
            end
            7'b0100011: begin // Store (SW)
                ALUSrc   = 1;
                memWrite = 1;
            end
            7'b1100011: begin // Branch (BEQ, BGT)
                branch   = 1;
                case (funct3)
                    3'b000: ALUOp = 2'b01; // BEQ
                    3'b101: ALUOp = 2'b11; // BGT
                endcase
            end
            7'b1101111: begin // Jump (JAL)
                ALUOp    = 2'b10; 
                ALUSrc   = 1;
                regWrite = 1;
            end
			7'b0001011: begin
            ALUOp = 2'b11;  // Custom ALU Operation
            regWrite = 1;   // Write to register
            ALUSrc = 0;     // Source is register (not immediate)
            memWrite = 0;   // No memory write
            memRead = 0;    // No memory read
            memtoReg = 0;   // Output directly to register
        end // CTZ (using funct3=001 for B-extension)
            // Remove the custom 7'b1110011 opcode for CTZ as it's now handled in the I-type section
        endcase
    end
endmodule