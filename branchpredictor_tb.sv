//test bench for branch predictor
//Author: Armani Zuniga
//VLSI x415

`timescale 1ns/1ps

module branchpredictor_tb();
	logic clk;
	logic rst_b;

	logic [11:2] branch_address;
	logic branch_req;
	logic branch_result;
	logic prediction;

	branchpredictor
	  #(
	     .NUM_BRANCH_TABLE_ENTRIES(1024)
	   )
	dut
	  (
	    .clk(clk),
	    .rst_b(rst_b),
	    .branch_address(branch_address),
	    .branch_req(branch_req),
	    .branch_result(branch_result),
	    .prediction(prediction)
	  );
	
	// waveform dumpfile
	initial begin
		$dumpfile("waveforms.vcd");
		$dumpvars; //dump variables
	end
	
	// initialize clock
	initial begin
		clk = '0;
		forever begin
			#1 clk = ~clk;
		end
	end

	// Testbench with four test cases 
	initial begin
		// reset dut
		rst_b = '1;
		branch_address = '0;
		branch_req = '0;
		branch_result = '0;
		#1;
		rst_b = '0;
		#2;
		$display("Design Reset");

		$display("############ 1st Test Case ############");
		// Check functionality by driving address 0 to strongly taken and then driving down to strongly not taken
		for (int i = 0; i < 4; i++) begin
			branch_address = 41'b0;
			branch_req = 1'b1;
			branch_result = 1'b0;
			#2;
			$display("time = %0t addr=0x%0h p=0x0%h b_req=0x0%h b_result=0x0%h", $time, branch_address, prediction, branch_req, branch_result);
			branch_req = 1'b0; 
			branch_result = 1'b0;
			#2;
			$display("time = %0t addr=0x%0h p=0x0%h b_req=0x0%h b_result=0x0%h", $time, branch_address, prediction, branch_req, branch_result);
			branch_req = 1'b1;
			#2;
			$display("time = %0t addr=0x%0h p=0x0%h b_req=0x0%h b_result=0x0%h", $time, branch_address, prediction, branch_req, branch_result);
			branch_req = 1'b0;
			branch_result = 1'b1;
	
			#2;
			$display("time = %0t addr=0x%0h p=0x0%h b_req=0x0%h b_result=0x0%h", $time, branch_address, prediction, branch_req, branch_result);
     		end
 
     		$display("############## 2nd Test Case ##############");
      		// Checks same functionality as test case 1 but for a different address
      		for (int i=0;i<4;i++) begin
	 		branch_address = 41'b1;
			branch_req = 1'b0;
	 		branch_result = 1'b0;
	 		#2;
			$display("time = %0t addr=0x%0h p=0x0%h b_req=0x0%h b_result=0x0%h", $time, branch_address, prediction, branch_req, branch_result);
     		end
     
     		$display("############## 3rd Test Case ##############");
		for (int i = 0; i < 4; i++) begin
                        // Set the branch address, branch request, and branch result
                        branch_address = 10'h3fe;
                        branch_req = 1'b1;
                        branch_result = 1'b0;
                        #2;
			branch_req = 1'b0;
			$display("time = %0t addr=0x%0h p=0x0%h b_req=0x0%h b_result=0x0%h", $time, branch_address, prediction, branch_req, branch_result);
			#2;
                end

     		$display("############## 4th Test Case ##############");
     		for (int i = 0; i < 4; i++) begin
        		// Set the branch address, branch request, and branch result
        		branch_address = 10'h3ff;
        		branch_req = 1'b1;
        		branch_result = 1'b1;
        		#2;
			$display("time = %0t addr=0x%0h p=0x0%h b_req=0x0%h b_result=0x0%h", $time, branch_address, prediction, branch_req, branch_result);
     		end
		$finish;
	end
endmodule
