
module ALU ( 
    input [3:0] ALUCtl,          // ALU control signal
    input [31:0] A, B,    // Input operands
    output reg [31:0] ALUOut, // ALU result
    output zero                  // Zero flag
);
    // The zero flag is high if ALUOut equals zero.
    assign zero = (ALUOut == 32'b0);
    integer i;
    
    // Combinational logic to determine ALUOut based on ALUCtl
    always @(*) begin
        case (ALUCtl)
            4'b0010: ALUOut = A + B;                    // ADD (signed addition for R-Type, LW, SW, ADDI)
            4'b0110: ALUOut = A - B;                    // SUB (signed subtraction for BEQ, BGT)
            4'b0001: ALUOut = A | B;                    // ORI (bitwise OR for I-Type ORI)
            4'b0111: ALUOut = (A < B) ? 32'b1 : 32'b0;  // SLTI: Set on less than immediate
            4'b1000: ALUOut = (A > B) ? 32'b1 : 32'b0;  // BGT: Signed greater-than comparison
            //4'b1001: ALUOut = A + B;                    // JAL: Compute jump target via addition
            4'b1001: begin                              // CTZ: Count trailing zeros in A
                ALUOut = 32'd32;  // Default to 32 if no '1' bit is found
                begin : ctz_loop  // Named block
                    for (i = 0; i < 32; i = i + 1) begin
                        if (A[i] == 1'b1) begin
                            ALUOut = i;
                            disable ctz_loop; // Exit loop when first '1' is found
                        end
                    end
                end
            end 
            default: ALUOut = 32'b0;                   // Default: No operation
        endcase
    end
endmodule