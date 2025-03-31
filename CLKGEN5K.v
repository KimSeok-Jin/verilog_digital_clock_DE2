module CLKGEN5K(
		CLK_1,
		CLK,
		RSTN
	);
	
	input CLK, RSTN;
	output reg CLK_1;
	reg [12:0] CLK_CNT;
	
	always @(posedge CLK, negedge RSTN) begin
		if (!RSTN) begin
			CLK_CNT<=13'b1;
			CLK_1<=1'b1;
		end
		else begin
			if (CLK_CNT==13'd5000)begin
				CLK_CNT<=13'b1;
				CLK_1<=~CLK_1;
			end
			else CLK_CNT<=CLK_CNT+13'b1;
		end
	end	

endmodule
