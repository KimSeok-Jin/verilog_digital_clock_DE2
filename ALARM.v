module ALARM(/*AUTOARG*/
	// Outputs
	ASEC0, ASEC1, AMIN0, AMIN1, AHOUR0, AHOUR1, ADAY0, ADAY1, ENABLE,
	// Inputs
	CLK, RSTN, AL, KEY3, KEY2, KEY1, KEY0, DAY0, DAY1,HOUR1, HOUR0, MIN1, MIN0, SW5
);

   input CLK, RSTN, AL, KEY3, KEY2, KEY1, KEY0, SW5;
	
	input [3:0] DAY0, DAY1, HOUR1, HOUR0, MIN1, MIN0;

	output reg [3:0] ASEC0, ASEC1, AMIN0, AMIN1, AHOUR0, AHOUR1, ADAY0, ADAY1;
	
	output reg ENABLE;//
	
	reg AL_EN;
	
	reg [1:0] KEY_CNT;

	reg KEY3_SYNC0, KEY3_SYNC1, KEY2_SYNC0, KEY2_SYNC1;
	
	reg KEY1_SYNC0, KEY1_SYNC1, KEY0_SYNC0, KEY0_SYNC1;

	reg KEY3_PRESSED, KEY2_PRESSED, KEY1_PRESSED, KEY0_PRESSED;
	
	wire KEY3_STABLE, KEY2_STABLE, KEY1_STABLE, KEY0_STABLE;
	
	assign KEY3_STABLE = KEY3_SYNC1;
	assign KEY2_STABLE = KEY2_SYNC1;
	assign KEY1_STABLE = KEY1_SYNC1;
	assign KEY0_STABLE = KEY0_SYNC1;
	
	reg [3:0] DAY1_SAVED, DAY0_SAVED;
	reg AL_OFF;
	
	always @(posedge CLK, negedge RSTN) begin
		if (!RSTN) begin
			KEY3_SYNC0 <= 1'b0;
			KEY3_SYNC1 <= 1'b0;			
			KEY2_SYNC0 <= 1'b0;
			KEY2_SYNC1 <= 1'b0;
			KEY1_SYNC0 <= 1'b0;
			KEY1_SYNC1 <= 1'b0;
			KEY0_SYNC0 <= 1'b0;
			KEY0_SYNC1 <= 1'b0;			
		end 
		else begin
			KEY3_SYNC0 <= KEY3;  
			KEY3_SYNC1 <= KEY3_SYNC0;			
			KEY2_SYNC0 <= KEY2;
			KEY2_SYNC1 <= KEY2_SYNC0;
			KEY1_SYNC0 <= KEY1;
			KEY1_SYNC1 <= KEY1_SYNC0;
			KEY0_SYNC0 <= KEY0;
			KEY0_SYNC1 <= KEY0_SYNC0;
		end
	end
	
	//KEY INPUT 
	always @(posedge CLK, negedge RSTN) begin
		if (!RSTN) begin
			AL_OFF<=0;//
			AMIN0 <= 4'b0; AMIN1 <= 4'b0;
			AHOUR0 <= 4'b1; AHOUR1 <= 4'b0;
			ADAY0<=4'b0; ADAY1<=4'b0;
			ASEC0 <= 4'b0; ASEC1 <= 4'b0;	
			KEY_CNT <= 2'b0;		
			KEY3_PRESSED <= 1'b0;
			KEY2_PRESSED <= 1'b0;
			KEY1_PRESSED <= 1'b0;
			KEY0_PRESSED <= 1'b1;
			AL_EN<=1'b0;	
			DAY1_SAVED<=0;
			DAY0_SAVED<=0;
		end
		else if (AL) begin
			ADAY0<=4'b0; ADAY1<=4'b0;
			ASEC0 <= 4'b0; ASEC1 <= 4'b0;	
			AL_OFF<=0;//
			//key operation for time setting
			if (KEY3_STABLE && !KEY3_PRESSED) begin
				 if (KEY_CNT == 2'b10) KEY_CNT <= 2'b1;
				 else KEY_CNT <= KEY_CNT + 2'b1;
				 KEY3_PRESSED <= 1'b1;
			end 
			else if (!KEY3_STABLE) KEY3_PRESSED <= 1'b0;
			else KEY3_PRESSED <= KEY3_PRESSED;
			
			//alarm on
			if (KEY0_STABLE && !KEY0_PRESSED) begin
				if(AL_EN==1'b0) AL_EN<=1'b1;
				else AL_EN<=1'b0;
				KEY0_PRESSED <= 1'b1;
			end 
			else if (!KEY0_STABLE) KEY0_PRESSED <= 1'b0;
			else KEY0_PRESSED <= KEY0_PRESSED;

			case (KEY_CNT)				
				1: begin // Hour 
					if (KEY2_STABLE && !KEY2_PRESSED) begin
						if ((AHOUR1 == 4'b10) && (AHOUR0 == 4'b11)) begin
							AHOUR1 <= 4'b0;
							AHOUR0 <= 4'b0;
						end 
						else if (AHOUR0 == 4'b1001) begin
							AHOUR1 <= AHOUR1 + 4'b1;
							AHOUR0 <= 4'b0;
						end 
						else begin
							AHOUR0 <= AHOUR0 + 4'b1;
						end
						KEY2_PRESSED <= 1'b1;
					end 
					else if (!KEY2_STABLE) begin
						KEY2_PRESSED <= 1'b0;
					end 
					else begin
						KEY2_PRESSED <= KEY2_PRESSED;
					end

					if (KEY1_STABLE && !KEY1_PRESSED) begin
						if ((AHOUR1 == 4'b0) && (AHOUR0 == 4'b0)) begin
							AHOUR1 <= 4'b10;
							AHOUR0 <= 4'b11;
						end 
						else if (AHOUR0 == 4'b0) begin
							 AHOUR1 <= AHOUR1 - 4'b1;
							 AHOUR0 <= 4'b1001;
						end 
						else begin
							 AHOUR0 <= AHOUR0 - 4'b1;
						end
						KEY1_PRESSED <= 1'b1;
					end 
					else if (!KEY1_STABLE) begin
						KEY1_PRESSED <= 1'b0;
					end 
					else begin
						KEY1_PRESSED <= KEY1_PRESSED;
					end
				end
				2: begin // Min
					if (KEY2_STABLE && !KEY2_PRESSED) begin
						if ((AMIN1 == 4'b101) && (AMIN0 == 4'b1001)) begin
							AMIN1 <= 4'b0;
							AMIN0 <= 4'b0;
						end else if (AMIN0 == 4'b1001) begin
							AMIN1 <= AMIN1 + 4'b1;
							AMIN0 <= 4'b0;
						end else begin
							AMIN0 <= AMIN0 + 4'b1;
						end
						KEY2_PRESSED <= 1'b1;
					end 
					else if (!KEY2_STABLE) begin
						KEY2_PRESSED <= 1'b0;
					end 
					else begin
						KEY2_PRESSED <= KEY2_PRESSED;
					end

					if (KEY1_STABLE && !KEY1_PRESSED) begin
						if ((AMIN1 == 4'b0) && (AMIN0 == 4'b0)) begin
							AMIN1 <= 4'b101;
							AMIN0 <= 4'b1001;
						end 
						else if (AMIN0 == 4'b0) begin
							AMIN1 <= AMIN1 - 4'b1;
							AMIN0 <= 4'b1001;
						end 
						else begin
							AMIN0 <= AMIN0 - 4'b1;
						end
						KEY1_PRESSED <= 1'b1;
					end 
					else if (!KEY1_STABLE) begin
						KEY1_PRESSED <= 1'b0;
					end 
					else begin
						KEY1_PRESSED <= KEY1_PRESSED;
					end
				end
				default: begin
					KEY2_PRESSED <= 1'b0;	
					KEY1_PRESSED <= 1'b0;
					AMIN0 <= 4'b0; AMIN1 <= 4'b0;
					AHOUR0 <= 4'b1; AHOUR1 <= 4'b0;
				end
			endcase
		end 
		else begin
			AMIN0 <= AMIN0; AMIN1 <= AMIN1;
			AHOUR0 <= AHOUR0; AHOUR1 <= AHOUR1;
			KEY_CNT <= 2'b0;
			KEY3_PRESSED <= 1'b0;
			KEY2_PRESSED <= 1'b0;
			KEY1_PRESSED <= 1'b0;
			AL_EN<=AL_EN;
				
			if(AL_OFF==0) begin
				if (AL_EN==1'b1) begin
					if ((HOUR0==AHOUR0)&&(HOUR1==AHOUR1)&&(MIN0==AMIN0)&&(MIN1==AMIN1)) ENABLE<=1'b1;
					else ENABLE<=1'b0;
				end
				else begin
					ENABLE<=1'b0;
				end
			end
			else ENABLE<=1'b0;
			if (ENABLE) begin
				DAY1_SAVED<=DAY1;
				DAY0_SAVED<=DAY0;
			end
			else begin	
				DAY1_SAVED<=DAY1_SAVED;
				DAY0_SAVED<=DAY0_SAVED;			
			end			
			
			if(!SW5)begin
				if ((DAY1_SAVED!=DAY1)||(DAY0_SAVED!=DAY0)) begin
					if (KEY0_STABLE && !KEY0_PRESSED) begin
						if (AL_OFF==0) AL_OFF<=1;
						else AL_OFF<=0;
						KEY0_PRESSED <= 1'b1;
					end 
					else if (!KEY0_STABLE) KEY0_PRESSED <= 1'b0;
					else begin
						KEY0_PRESSED <= KEY0_PRESSED;	
						AL_OFF<=0;
					end
				end
				else begin
					if (KEY0_STABLE && !KEY0_PRESSED) begin
						if (AL_OFF==0) AL_OFF<=1;
						else AL_OFF<=0;
						KEY0_PRESSED <= 1'b1;
					end 
					else if (!KEY0_STABLE) KEY0_PRESSED <= 1'b0;
					else KEY0_PRESSED <= KEY0_PRESSED;				
				end
			end
		end
	end

endmodule
