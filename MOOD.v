module MOOD(
	LED1, LED2, LED3,
	CLK,RSTN, HOUR1, HOUR0, SW6
);
	input CLK, RSTN, SW6;
	
	input [3:0] HOUR1, HOUR0;
	
	output reg LED1, LED2, LED3;
	
	reg [1:0] MOOD;
	

	always @(posedge CLK or negedge RSTN) begin
		if (!RSTN) begin
			MOOD <= 0; 
		end 
		else if (SW6)begin
			if((HOUR1==1) && (HOUR0>=4) &&(HOUR0<=9))begin
				MOOD<=1;
			end
			else if((HOUR1==2) && (HOUR0>=0) &&(HOUR0<=3))begin
				MOOD<=2;
			end
			
			else if((HOUR1==0) && (HOUR0>=0) &&(HOUR0<=3))begin
				MOOD<=3;
			end
			else begin
				MOOD<=0;
			end
		end
		else begin
			MOOD<=0;
		end
	end

	// LED Control
	always @(posedge CLK or negedge RSTN) begin
		if (!RSTN) begin
			LED1 <= 0;
			LED2 <= 0;
			LED3 <= 0;
		end else begin
			case (MOOD)
				1: begin
					LED1 <= 1;
					LED2 <= 0;
					LED3 <= 0;
				end
				2: begin
					LED1 <= 0;
					LED2 <= 1;
					LED3 <= 0;
				end
				3: begin
					LED1 <= 0;
					LED2 <= 0;
					LED3 <= 1;
				end
				default: begin
					LED1 <= 0;
					LED2 <= 0;
					LED3 <= 0;
				end
			endcase
		end
	end 

endmodule