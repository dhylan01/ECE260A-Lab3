// Extended 4-input Carry Save Adder (CSA) for summing N-length numbers
module designed_csa #(parameter w = 16)(
  input                       clk, 
                              reset,
  input        [w-1:0] a, 		// serial input -- filter will sum 4 consecutive values
  output logic [w+1:0] s       // sum of 4 most recent values of a
);

  // Registers for input storage
  logic signed [w-1:0] ar, br, cr, dr;

  // Intermediate values for CSA and CLA stages
  logic         [w-1:0] csa4_s;   // Partial sum from first CSA
  logic         [w  :0] csa4_c;   // Partial carry from first CSA
  logic         [w  :0] csa5_s;   // Partial sum from second CSA
  logic         [w+1:0] csa5_c;   // Partial carry from second CSA
  logic         [w+1:0] sum;	    // Final sum after CLA
  logic         [w+1:0] p;        // Propagate signals for CLA
  logic         [w+1:0] g;        // Generate signals for CLA
  logic         [w+1:0] c;        // Carry signals for CLA

  // Combinational logic for CSA and CLA stages
  always_comb begin
    // Initialize carries
    csa4_c[0] = 0;                
    csa5_c[0] = 0;

    // First CSA: Sum ar, br, and cr
    for (int i = 0; i < w; i++) begin
      {csa4_c[i+1], csa4_s[i]} = ar[i] + br[i] + cr[i];
    end

    // Second CSA: Add results of first CSA with dr
    for (int i = 0; i < w; i++) begin
      {csa5_c[i+1], csa5_s[i]} = csa4_c[i] + csa4_s[i] + dr[i];
    end

    // Carry-Lookahead Adder (CLA) for final addition
    for (int i = 0; i < w+1; i++) begin
      p[i] = csa5_s[i] ^ csa5_c[i];             // Propagate
      g[i] = csa5_s[i] & csa5_c[i];             // Generate
      c[i+1] = g[i] | (p[i] & c[i]);            // Carry
    end

    // Compute final sum
    sum[0] = p[0] ^ csa5_c[0];                  // First bit
    for (int i = 1; i < w+1; i++) begin
      sum[i] = p[i] ^ c[i];                     // Remaining bits
    end
    sum[w+1] = c[w+1];                          // Final carry-out
  end

  // Sequential logic for input registers and output
  always_ff @(posedge clk) begin
    if (reset) begin
      ar <= 'b0;
      br <= 'b0;
      cr <= 'b0;
      dr <= 'b0;
      s  <= 'b0;
    end else begin
      ar <= a;
      br <= ar;
      cr <= br;
      dr <= cr;
      s  <= sum;
    end
  end

endmodule