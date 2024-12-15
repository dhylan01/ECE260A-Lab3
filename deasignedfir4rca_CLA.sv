// ECE260A Lab 3
// keep the same input and output and the same input and output registers
// change the combinational addition part to something more optimal
// refer to Fig. 11.42(a) in W&H 
// cascade of three ripple carry adders
module deasignedfir4rca_CLA #(parameter w=16)(
  input                      clk, 
                             reset,
  input         [w-1:0] a,
  output logic  [w+1:0] s);
// delay pipeline for input a
  logic         [w-1:0] ar, br, cr, dr;


// Carry-Lookahead Adder Logic
	logic [3:0] clasum1, clasum2, clasum3, clasum4;
	logic [w-1:0] sum1, sum2, sum3;  // Sum outputs for CLA stages
	logic [w-1:0] sum11, sum22, sum33;  // Sum outputs for CLA stages
	logic carry1, carry2, carry3, carry4;      // Carry-out from CLA stages
	logic [w+1:0] intermediate_sum1, intermediate_sum2;
	logic carry11, carry22, carry33, carry44; 
	logic carryf1, carryf2, carryf3, carryf4; 	// Carry-out from CLA stages
	logic [1:0] msbs;

	logic         [w+1:0] sum;
  // CLA instances for each 4-bit chunk
	CarryLookAhead cla1 (
	  .A(ar[3:0]), 
	  .B(br[3:0]), 
	  .Cin(0),              // No carry-in for the first CLA stage
	  .S(intermediate_sum1[3:0]), 
	  .Cout(carry1)
	);

	CarryLookAhead cla2 (
	  .A(ar[7:4]), 
	  .B(br[7:4]), 
	  .Cin(carry1),        // Carry-in comes from the first CLA
	  .S(intermediate_sum1[7:4]), 
	  .Cout(carry2)
	);

	CarryLookAhead cla3 (
	  .A(ar[11:8]), 
	  .B(br[11:8]), 
	  .Cin(carry2),        // Carry-in comes from the second CLA
	  .S(intermediate_sum1[11:8]), 
	  .Cout(carry3)
	);

	CarryLookAhead cla4 (
	  .A(ar[15:12]), 
	  .B(br[15:12]), 
	  .Cin(carry3),        // Carry-in comes from the third CLA
	  .S(intermediate_sum1[15:12]), 
	  .Cout(carry4)
	);
	
	// for cr and dr: 
	
		CarryLookAhead cla5 (
	  .A(cr[3:0]), 
	  .B(dr[3:0]), 
	  .Cin(0),              // No carry-in for the first CLA stage
	  .S(intermediate_sum2[3:0]), 
	  .Cout(carry11)
	);

	CarryLookAhead cla6 (
	  .A(cr[7:4]), 
	  .B(dr[7:4]), 
	  .Cin(carry11),        // Carry-in comes from the first CLA
	  .S(intermediate_sum2[7:4]), 
	  .Cout(carry22)
	);

	CarryLookAhead cla7 (
	  .A(cr[11:8]), 
	  .B(dr[11:8]), 
	  .Cin(carry22),        // Carry-in comes from the second CLA
	  .S(intermediate_sum2[11:8]), 
	  .Cout(carry33)
	);

	CarryLookAhead cla8 (
	  .A(cr[15:12]), 
	  .B(dr[15:12]), 
	  .Cin(carry33),        // Carry-in comes from the third CLA
	  .S(intermediate_sum2[15:12]), 
	  .Cout(carry44)
	);



//put both sums together 	
		
  
  	CarryLookAhead cla9 (
	  .A(intermediate_sum1[3:0]), 
	  .B(intermediate_sum2[3:0]), 
	  .Cin(0),              // No carry-in for the first CLA stage
	  .S(sum[3:0]), 
	  .Cout(carryf1)
	);

	CarryLookAhead cla10 (
	  .A(intermediate_sum1[7:4]), 
	  .B(intermediate_sum2[7:4]), 
	  .Cin(carry1),        // Carry-in comes from the first CLA
	  .S(sum[7:4]), 
	  .Cout(carryf2)
	);

	CarryLookAhead cla11 (
	  .A(intermediate_sum1[11:8]), 
	  .B(intermediate_sum2[11:8]), 
	  .Cin(carry2),        // Carry-in comes from the second CLA
	  .S(sum[11:8]), 
	  .Cout(carryf3)
	);

	CarryLookAhead cla12 (
	  .A(intermediate_sum1[15:12]), 
	  .B(intermediate_sum2[15:12]), 
	  .Cin(carry3),        // Carry-in comes from the third CLA
	  .S(sum[15:12]), 
	  .Cout(carryf4)
	);
	
	// compute msb with carry outs and put sum together
	
	always_comb begin
		msbs = carry4 + carry44 + carryf4;
		sum[w+1:w] = msbs;

	end
  
  
  
  
  // sequential logic -- standardized for everyone
  always_ff @(posedge clk)			// or just always -- always_ff tells tools you intend D flip flops
    if(reset) begin					// reset forces all registers to 0 for clean start of test
	  ar <= 'b0;
	  br <= 'b0;
	  cr <= 'b0;
	  dr <= 'b0;
	  s  <= 'b0;
    end
    else begin					    // normal operation -- Dffs update on posedge clk
	  ar <= a;						// the chain will always hold the four most recent incoming data samples
	  br <= ar;
	  cr <= br;
	  dr <= cr;
	  s  <= sum; 
	end

endmodule
