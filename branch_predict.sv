module branchpredictor(
	input wire clk,
	input wire rst_b,
	input wire [10-1:0] branch_address,
	input wire branch_req,
	input wire branch_result,
	output reg prediction
);

// Branch table declaration
parameter NUM_BRANCH_TABLE_ENTRIES = 1024;
parameter NUM_ADDRESS_BITS = 10;	

// 2-bit predictor table
reg [1:0] branch_table [0:NUM_BRANCH_TABLE_ENTRIES-1];

// Flip-Flop to keep track of branch_req for one clock cycle
reg [1:0] delayed_data;

// First flip flop to keep track of current value branch_req
always @(posedge clk or posedge rst_b) begin
	if (rst_b) begin
		delayed_data <= 1'b0;
	end else begin
		delayed_data[0] <= branch_req;
	end
end

// Second flip flop to hold branch_req for one clock cycle
always @(negedge clk or posedge rst_b) begin
	if (rst_b) begin
		delayed_data <= 1'b0;
	end else begin
		delayed_data[1] <= delayed_data[0];
	end
end

// Initialize branch table entries at reset to weakly taken
always @(posedge clk or rst_b) begin
	if (rst_b) begin
		// debug $display("Branch table reset");
		for (int i = 0; i < NUM_BRANCH_TABLE_ENTRIES; i = i + 1) begin
			branch_table[i] <= 2'b10;
			//$display("addr = 0x%0h content = 0x%0h", i, branch_table[i]);
		end
	end
end

// debug
always @(negedge clk) begin
	//$display("$time = %0t current addr = 0x%0h content = 0x%0h",$time, branch_address, branch_table[branch_address]);
end

// Logic to update branch address if branch result was taken or not taken
always @(posedge clk) begin
	// branch taken
	if (branch_result && delayed_data[1]) begin
		// check overflow
		if (branch_table[branch_address] == 2'b11) begin
			branch_table[branch_address] <= branch_table[branch_address] + 0;
		end
		else begin
			branch_table[branch_address] <= branch_table[branch_address] + 1;
		end
	// branch not taken
	end else if (!branch_result && delayed_data[1]) begin
		// check overflow
		if (branch_table[branch_address] == 2'b00) begin
			branch_table[branch_address] <= branch_table[branch_address] - 0;
		end
		else begin
			branch_table[branch_address] <= branch_table[branch_address] - 1;
		end
	end
end

// Case statement for prediction output based on current address table value
always_ff @(posedge clk or posedge rst_b) begin
	if (rst_b) begin
		prediction <= 1'b0;
	end else if (branch_req) begin
		// case statement for output
		case(branch_table[branch_address])
			2'b00: prediction <= 1'b0;
			2'b01: prediction <= 1'b0;
			2'b10: prediction <= 1'b1;
			2'b11: prediction <= 1'b1;
			default: prediction <= 1'b1;
		endcase
	end else begin
		prediction <= 1'b0;
	end
end
endmodule
