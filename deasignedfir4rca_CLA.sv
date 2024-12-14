// ECE260A Lab 3
// keep the same input and output and the same input and output registers
// change the combinational addition part to something more optimal
// refer to Fig. 11.42(a) in W&H 
// cascade of three ripple carry adders
module deasignedfir4rca_CLA #(parameter w=16)(
  input                      clk, 
                             reset,
  input         [w-1:0] a,
  output logic  [w+1:0] s);  // Ensure that the output width is large enough

  // Delay pipeline for input a
  logic [w-1:0] ar, br, cr, dr;

  // Carry-Lookahead Adder Logic
  logic [w-1:0] sum1, sum2, sum3, sum4;  // Sum outputs for CLA stages
  logic carry1, carry2, carry3, carry4;  // Carry-out from CLA stages

  // CLA instances for adding pairs of registers

  // First pair: ar + br
  CarryLookAhead cla1 (
    .A(ar[3:0]), 
    .B(br[3:0]), 
    .Cin(0),              // No carry-in for the first CLA stage
    .S(sum1[3:0]), 
    .Cout(carry1)
  );

  CarryLookAhead cla2 (
    .A(ar[7:4]), 
    .B(br[7:4]), 
    .Cin(carry1),        // Carry-in comes from the first CLA
    .S(sum1[7:4]), 
    .Cout(carry2)
  );

  CarryLookAhead cla3 (
    .A(ar[11:8]), 
    .B(br[11:8]), 
    .Cin(carry2),        // Carry-in comes from the second CLA
    .S(sum1[11:8]), 
    .Cout(carry3)
  );

  CarryLookAhead cla4 (
    .A(ar[15:12]), 
    .B(br[15:12]), 
    .Cin(carry3),        // Carry-in comes from the third CLA
    .S(sum1[15:12]), 
    .Cout(carry4)
  );

  // Second pair: cr + dr
  CarryLookAhead cla5 (
    .A(cr[3:0]), 
    .B(dr[3:0]), 
    .Cin(0),              // No carry-in for the first CLA stage
    .S(sum2[3:0]), 
    .Cout(carry11)
  );

  CarryLookAhead cla6 (
    .A(cr[7:4]), 
    .B(dr[7:4]), 
    .Cin(carry11),        // Carry-in comes from the first CLA
    .S(sum2[7:4]), 
    .Cout(carry22)
  );

  CarryLookAhead cla7 (
    .A(cr[11:8]), 
    .B(dr[11:8]), 
    .Cin(carry22),        // Carry-in comes from the second CLA
    .S(sum2[11:8]), 
    .Cout(carry33)
  );

  CarryLookAhead cla8 (
    .A(cr[15:12]), 
    .B(dr[15:12]), 
    .Cin(carry33),        // Carry-in comes from the third CLA
    .S(sum2[15:12]), 
    .Cout(carry44)
  );

  // Now add the results from sum1 and sum2
  CarryLookAhead cla9 (
    .A(sum1[3:0]), 
    .B(sum2[3:0]), 
    .Cin(0),              // No carry-in for the first CLA stage
    .S(s[3:0]), 
    .Cout(carryf1)
  );

  CarryLookAhead cla10 (
    .A(sum1[7:4]), 
    .B(sum2[7:4]), 
    .Cin(carryf1),        // Carry-in comes from the first CLA
    .S(s[7:4]), 
    .Cout(carryf2)
  );

  CarryLookAhead cla11 (
    .A(sum1[11:8]), 
    .B(sum2[11:8]), 
    .Cin(carryf2),        // Carry-in comes from the second CLA
    .S(s[11:8]), 
    .Cout(carryf3)
  );

  CarryLookAhead cla12 (
    .A(sum1[15:12]), 
    .B(sum2[15:12]), 
    .Cin(carryf3),        // Carry-in comes from the third CLA
    .S(s[15:12]), 
    .Cout(carryf4)
  );

  // Final carry handling for MSB (most significant bits)
  always_comb begin
    s[w+1:w] = carryf4 + carry44 + carryf4;
  end

  // Sequential logic -- standardized for everyone
  always_ff @(posedge clk)  // or just always_ff for flip-flops
    if (reset) begin
      ar <= 'b0;
      br <= 'b0;
      cr <= 'b0;
      dr <= 'b0;
      s  <= 'b0;
    end else begin
      ar <= a;  // The chain will always hold the most recent incoming data samples
      br <= ar;
      cr <= br;
      dr <= cr;
      s  <= s;  // Output the final sum
    end
endmodule
