module DIGITALCLOCK(/*AUTOARG*/
                    // Outputs
                    SEG0, SEG1, SEG2, SEG3, SEG4, SEG5, SEG6, SEG7,
                    // Inputs
                    CLK, RSTN, SET, KEY3, KEY2, KEY1
                    );

   input CLK, RSTN, SET, KEY3, KEY2, KEY1;

   output [6:0] SEG0, SEG1, SEG2, SEG3, SEG4, SEG5, SEG6, SEG7;

   reg [3:0] SEC0, SEC1, MIN0, MIN1, HOUR0, HOUR1, DAY0, DAY1;

   reg [3:0] NEXT_SEC0, NEXT_SEC1, NEXT_MIN0, NEXT_MIN1, NEXT_HOUR0, NEXT_HOUR1, NEXT_DAY0, NEXT_DAY1;

   reg [24:0]  CNT, NEXT_CNT;

	reg MODE, NEXT_MODE;
	
	wire [3:0] SSEC0, SSEC1, SMIN0, SMIN1, SHOUR0, SHOUR1, SDAY0, SDAY1;
	wire [3:0] OUT0, OUT1, OUT2, OUT3, OUT4, OUT5, OUT6, OUT7;

	TIME_SET TS (
      .SSEC0(SSEC0),
      .SSEC1(SSEC1),
      .SMIN0(SMIN0),
      .SMIN1(SMIN1),
      .SHOUR0(SHOUR0),
      .SHOUR1(SHOUR1),
      .SDAY0(SDAY0),
      .SDAY1(SDAY1),
      .CLK(CLK),
      .SET(SET),
      .RSTN(RSTN),
		.KEY3(KEY3),
	   .KEY2(KEY2),
		.KEY1(KEY1)
    );

    always @(posedge CLK, negedge RSTN) begin
		if(!RSTN) begin
			SEC0<=0; SEC1<=0;
			MIN0<=0; MIN1<=0;
			HOUR0<=0; HOUR1<=0;
			DAY0<=1; DAY1<=0;
			CNT<=1;
			MODE<=0;
		end

		else begin
			SEC0<=NEXT_SEC0; SEC1<=NEXT_SEC1;
			MIN0<=NEXT_MIN0; MIN1<=NEXT_MIN1;
			HOUR0<=NEXT_HOUR0; HOUR1<=NEXT_HOUR1;
			DAY0<=NEXT_DAY0; DAY1<=NEXT_DAY1;
			CNT<=NEXT_CNT;
			MODE<=NEXT_MODE;
		end
    end

	always @(*) begin
	
		NEXT_CNT=(CNT==25'd25000000)? 25'd1:25'd1+CNT;
		
		if (CNT==25'd25000000) begin
			if (SET==1) begin
				NEXT_MODE=1;
				NEXT_SEC0=SSEC0;
				NEXT_SEC1=SSEC1;
				NEXT_MIN0=SMIN0;
				NEXT_MIN1=SMIN1;
				NEXT_HOUR0=SHOUR0;
				NEXT_HOUR1=SHOUR1;
				NEXT_DAY0=SDAY0;
				NEXT_DAY1=SDAY1;
			end
			else begin
				NEXT_MODE=0;
				if ((SEC1==5)&&(SEC0==9)) begin
					if ((MIN1==5)&&(MIN0==9)) begin
						if((HOUR1==2)&&(HOUR0==3)) begin
							if((DAY1==3)&&(DAY0==1)) begin
								NEXT_DAY1=0;
								NEXT_DAY0=1;
								NEXT_HOUR1=0;
								NEXT_HOUR0=0;
								NEXT_MIN1=0;
								NEXT_MIN0=0;
								NEXT_SEC1=0;
								NEXT_SEC0=0;
							end
							else begin
								NEXT_HOUR1=0;
								NEXT_HOUR0=0;
								NEXT_MIN1=0;
								NEXT_MIN0=0;
								NEXT_SEC1=0;
								NEXT_SEC0=0;
								if(DAY0==9) begin
									NEXT_DAY1=DAY1+1;
									NEXT_DAY0=0;
								end
								else begin
									NEXT_DAY1=DAY1;
									NEXT_DAY0=DAY0+1;
								end
							end
						end
						else begin
							NEXT_DAY1=DAY1;
							NEXT_DAY0=DAY0;
							NEXT_MIN1=0;
							NEXT_MIN0=0;
							NEXT_SEC1=0;
							NEXT_SEC0=0;
							if(HOUR0==9) begin
								NEXT_HOUR1=HOUR1+1;
								NEXT_HOUR0=0;
							end
							else begin
								NEXT_HOUR1=HOUR1;
								NEXT_HOUR0=HOUR0+1;
							end
						end
					end
					else begin
						NEXT_DAY1=DAY1;
						NEXT_DAY0=DAY0;
						NEXT_HOUR1=HOUR1;
						NEXT_HOUR0=HOUR0;
						NEXT_SEC1=0;
						NEXT_SEC0=0;
						if(MIN0==9) begin
							NEXT_MIN1=MIN1+1;
							NEXT_MIN0=0;
						end
						else begin
							NEXT_MIN1=MIN1;
							NEXT_MIN0=MIN0+1;
						end
					end
				end
				else begin
					NEXT_DAY1=DAY1;
					NEXT_DAY0=DAY0;
					NEXT_HOUR1=HOUR1;
					NEXT_HOUR0=HOUR0;			
					NEXT_MIN1=MIN1;
					NEXT_MIN0=MIN0;
					if(SEC0==9) begin
						NEXT_SEC1=SEC1+1;
						NEXT_SEC0=0;
					end
					else begin
						NEXT_SEC1=SEC1;
						NEXT_SEC0=SEC0+1;
					end
				end
			end
		end
		else begin
			NEXT_SEC0=SEC0;
			NEXT_SEC1=SEC1;
			NEXT_MIN0=MIN0;
			NEXT_MIN1=MIN1;
			NEXT_HOUR0=HOUR0;
			NEXT_HOUR1=HOUR1;
			NEXT_DAY0=DAY0;
			NEXT_DAY1=DAY1;
			NEXT_MODE=MODE;
		end

	end
	
	assign OUT0 = (MODE)? SSEC0:SEC0;
	assign OUT1 = (MODE)? SSEC1:SEC1;
	assign OUT2 = (MODE)? SMIN0:MIN0;
	assign OUT3 = (MODE)? SMIN1:MIN1;
	assign OUT4 = (MODE)? SHOUR0:HOUR0;
	assign OUT5 = (MODE)? SHOUR1:HOUR1;
	assign OUT6 = (MODE)? SDAY0:DAY0;
	assign OUT7 = (MODE)? SDAY1:DAY1;

	SEG7 SEG_0(
		.IN(OUT0),
		.SEG(SEG0)
	);
	
	SEG7 SEG_1(
		.IN(OUT1),
		.SEG(SEG1)
	);
		
	SEG7 SEG_2(
		.IN(OUT2),
		.SEG(SEG2)
	);
		
	SEG7 SEG_3(
		.IN(OUT3),
		.SEG(SEG3)
	);
	
	SEG7 SEG_4(
		.IN(OUT4),
		.SEG(SEG4)
	);
	
	SEG7 SEG_5(
		.IN(OUT5),
		.SEG(SEG5)
	);
	
	SEG7 SEG_6(
		.IN(OUT6),
		.SEG(SEG6)
	);
	
	SEG7 SEG_7(
		.IN(OUT7),
		.SEG(SEG7)
	);
					
endmodule


