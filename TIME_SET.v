module TIME_SET(
    // Outputs
    SSEC0, SSEC1, SMIN0, SMIN1, SHOUR0, SHOUR1, SDAY0, SDAY1,
	//SEG0, SEG1, SEG2, SEG3, SEG4, SEG5, SEG6, SEG7,
    // Inputs
    CLK, RSTN, SET, KEY3, KEY2, KEY1
);

   input CLK, RSTN, SET, KEY3, KEY2, KEY1; 
	//output [6:0] SEG0, SEG1, SEG2, SEG3, SEG4, SEG5, SEG6, SEG7;
   output reg [3:0] SSEC0, SSEC1, SMIN0, SMIN1, SHOUR0, SHOUR1, SDAY0, SDAY1;

   reg [3:0] N_SSEC0, N_SSEC1, N_SMIN0, N_SMIN1, N_SHOUR0, N_SHOUR1, N_SDAY0, N_SDAY1;

   reg [2:0] KEY_CNT;

   reg [24:0] CLK_CNT;

   reg CLK_1;

	reg KEY3_SYNC0, KEY3_SYNC1, KEY2_SYNC0, KEY2_SYNC1, KEY1_SYNC0, KEY1_SYNC1;

	wire KEY3_STABLE, KEY2_STABLE, KEY1_STABLE;

   reg KEY3_PRESSED, KEY2_PRESSED, KEY1_PRESSED;

    //50MHz to 1KHz
   always @(posedge CLK, negedge RSTN) begin
		if (!RSTN) begin
			CLK_CNT <= 25'd1;
         CLK_1 <= 1;
      end 
		else begin
            if (CLK_CNT == 25'd25000) begin
                CLK_CNT <= 25'd1;
                CLK_1 <= ~CLK_1; // 1 Hz CLK
            end 
			else CLK_CNT <= CLK_CNT + 1'b1;
        end
    end

    // Debouncing
    always @(posedge CLK, negedge RSTN) begin
        if (!RSTN) begin
            KEY3_SYNC0 <= 1'b0;
            KEY3_SYNC1 <= 1'b0;			
            KEY2_SYNC0 <= 1'b0;
            KEY2_SYNC1 <= 1'b0;
            KEY1_SYNC0 <= 1'b0;
            KEY1_SYNC1 <= 1'b0;
        end 
		else begin
            KEY3_SYNC0 <= KEY3;  
            KEY3_SYNC1 <= KEY3_SYNC0;			
            KEY2_SYNC0 <= KEY2;
            KEY2_SYNC1 <= KEY2_SYNC0;
            KEY1_SYNC0 <= KEY1;
            KEY1_SYNC1 <= KEY1_SYNC0;
        end
    end

    assign KEY3_STABLE = KEY3_SYNC1;
    assign KEY2_STABLE = KEY2_SYNC1;
    assign KEY1_STABLE = KEY1_SYNC1;

    //KEY INIPUT 
    always @(posedge CLK_1, negedge RSTN) begin
        if (!RSTN) begin
            SSEC0 <= 0; SSEC1 <= 0;
            SMIN0 <= 0; SMIN1 <= 0;
            SHOUR0 <= 0; SHOUR1 <= 0;
            SDAY0 <= 1; SDAY1 <= 0;
            KEY_CNT <= 0;
            KEY3_PRESSED <= 0;
            KEY2_PRESSED <= 0;
            KEY1_PRESSED <= 0;
        end
		  
		else if (SET) begin
            if (KEY3_STABLE && !KEY3_PRESSED) begin
                if (KEY_CNT == 4) KEY_CNT <= 1;
                else KEY_CNT <= KEY_CNT + 1;
                KEY3_PRESSED <= 1;
            end 
				else if (!KEY3_STABLE) KEY3_PRESSED <= 0;
            else KEY3_PRESSED <= KEY3_PRESSED;

            case (KEY_CNT)
						
                1: begin // Day
                    if (KEY2_STABLE && !KEY2_PRESSED) begin
                        if ((SDAY1 == 3) && (SDAY0 == 1)) begin
                            SDAY1 <= 0;
                            SDAY0 <= 1;
                        end 
						else if (SDAY0 == 9) begin
                            SDAY1 <= SDAY1 + 1;
                            SDAY0 <= 0;
                        end 
						else begin
                            SDAY0 <= SDAY0 + 1;
                        end
                        KEY2_PRESSED <= 1;
                    end 
					else if (!KEY2_STABLE) begin
                        KEY2_PRESSED <= 0;
                    end 
					else begin
                        KEY2_PRESSED <= KEY2_PRESSED;
                    end

                    if (KEY1_STABLE && !KEY1_PRESSED) begin
                        if ((SDAY1 == 0) && (SDAY0 == 1)) begin
                            SDAY1 <= 3;
                            SDAY0 <= 1;
                        end 
						else if (SDAY0 == 0) begin
                            SDAY1 <= SDAY1 - 1;
                            SDAY0 <= 9;
                        end 
						else begin
                            SDAY0 <= SDAY0 - 1;
                        end
                        KEY1_PRESSED <= 1;
                    end 
					else if (!KEY1_STABLE) begin
                        KEY1_PRESSED <= 0;
                    end 
					else begin
                        KEY1_PRESSED <= KEY1_PRESSED;
                    end
                end
                2: begin // Hour 
                    if (KEY2_STABLE && !KEY2_PRESSED) begin
                        if ((SHOUR1 == 2) && (SHOUR0 == 3)) begin
                            SHOUR1 <= 0;
                            SHOUR0 <= 0;
                        end 
						else if (SHOUR0 == 9) begin
                            SHOUR1 <= SHOUR1 + 1;
                            SHOUR0 <= 0;
                        end 
						else begin
                            SHOUR0 <= SHOUR0 + 1;
                        end
                        KEY2_PRESSED <= 1;
                    end 
					else if (!KEY2_STABLE) begin
                        KEY2_PRESSED <= 0;
                    end 
					else begin
                        KEY2_PRESSED <= KEY2_PRESSED;
                    end

                    if (KEY1_STABLE && !KEY1_PRESSED) begin
                        if ((SHOUR1 == 0) && (SHOUR0 == 0)) begin
                            SHOUR1 <= 2;
                            SHOUR0 <= 3;
                        end 
						else if (SHOUR0 == 0) begin
                            SHOUR1 <= SHOUR1 - 1;
                            SHOUR0 <= 9;
                        end 
						else begin
                            SHOUR0 <= SHOUR0 - 1;
                        end
                        KEY1_PRESSED <= 1;
                    end 
					else if (!KEY1_STABLE) begin
                        KEY1_PRESSED <= 0;
                    end 
					else begin
                        KEY1_PRESSED <= KEY1_PRESSED;
                    end
                end
                3: begin // Min
                    if (KEY2_STABLE && !KEY2_PRESSED) begin
                        if ((SMIN1 == 5) && (SMIN0 == 9)) begin
                            SMIN1 <= 0;
                            SMIN0 <= 0;
                        end else if (SMIN0 == 9) begin
                            SMIN1 <= SMIN1 + 1;
                            SMIN0 <= 0;
                        end else begin
                            SMIN0 <= SMIN0 + 1;
                        end
                        KEY2_PRESSED <= 1;
                    end 
					else if (!KEY2_STABLE) begin
                        KEY2_PRESSED <= 0;
                    end 
					else begin
                        KEY2_PRESSED <= KEY2_PRESSED;
                    end

                    if (KEY1_STABLE && !KEY1_PRESSED) begin
                        if ((SMIN1 == 0) && (SMIN0 == 0)) begin
                            SMIN1 <= 5;
                            SMIN0 <= 9;
                        end 
						else if (SMIN0 == 0) begin
                            SMIN1 <= SMIN1 - 1;
                            SMIN0 <= 9;
                        end 
						else begin
                            SMIN0 <= SMIN0 - 1;
                        end
                        KEY1_PRESSED <= 1;
                    end 
					else if (!KEY1_STABLE) begin
                        KEY1_PRESSED <= 0;
                    end 
					else begin
                        KEY1_PRESSED <= KEY1_PRESSED;
                    end
                end
                4: begin // Sec
                    if (KEY2_STABLE && !KEY2_PRESSED) begin
                        if ((SSEC1 == 5) && (SSEC0 == 9)) begin
                            SSEC1 <= 0;
                            SSEC0 <= 0;
                        end 
						else if (SSEC0 == 9) begin
                            SSEC1 <= SSEC1 + 1;
                            SSEC0 <= 0;
                        end 
						else begin
                            SSEC0 <= SSEC0 + 1;
                        end
                        KEY2_PRESSED <= 1;
                    end 
					else if (!KEY2_STABLE) begin
                        KEY2_PRESSED <= 0;
                    end 
					else begin
                        KEY2_PRESSED <= KEY2_PRESSED;
                    end

                    if (KEY1_STABLE && !KEY1_PRESSED) begin
                        if ((SSEC1 == 0) && (SSEC0 == 0)) begin
                            SSEC1 <= 5;
                            SSEC0 <= 9;
                        end 
						else if (SSEC0 == 0) begin
                            SSEC1 <= SSEC1 - 1;
                            SSEC0 <= 9;
                        end 
						else begin
                            SSEC0 <= SSEC0 - 1;
                        end
                        KEY1_PRESSED <= 1;
                    end 
					else if (!KEY1_STABLE) begin
                        KEY1_PRESSED <= 0;
                    end 
					else begin
                        KEY1_PRESSED <= KEY1_PRESSED;
                    end
                end
                default: begin
                    KEY2_PRESSED <= 0;	
                    KEY1_PRESSED <= 0;
							SSEC0 <= 0; SSEC1 <= 0;
							SMIN0 <= 0; SMIN1 <= 0;
							SHOUR0 <= 0; SHOUR1 <= 0;
							SDAY0 <= 2; SDAY1 <= 0;					  
                end
            endcase
        end 
		else begin
            SSEC0 <= 0; SSEC1 <= 0;
            SMIN0 <= 0; SMIN1 <= 0;
            SHOUR0 <= 0; SHOUR1 <= 0;
            SDAY0 <= 1; SDAY1 <= 0;
            KEY_CNT <= 0;
            KEY3_PRESSED <= 0;
            KEY2_PRESSED <= 0;
            KEY1_PRESSED <= 0;
        end
    end
	 
endmodule