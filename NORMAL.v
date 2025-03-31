module NORMAL(
    // Outputs
    SEC0, SEC1, MIN0, MIN1, HOUR0, HOUR1, DAY0, DAY1,
    // Inputs
    CLK, RSTN, SET, SW3 , SSEC0, SSEC1, SMIN0, SMIN1, SHOUR0, SHOUR1, SDAY0, SDAY1
);
    input CLK, RSTN, SET, SW3;
	 
	 input [3:0] SSEC0, SSEC1, SMIN0, SMIN1, SHOUR0, SHOUR1, SDAY0, SDAY1;
 	 
    output reg [3:0] SEC0, SEC1, MIN0, MIN1, HOUR0, HOUR1, DAY0, DAY1;
	 
    reg [12:0] CNT; 
	 
    task TIME_UP;
    begin
        if ((SEC1 == 5) && (SEC0 == 9)) begin
            SEC0 <= 0;
            SEC1 <= 0;
            if ((MIN1 == 5) && (MIN0 == 9)) begin
                MIN0 <= 0;
                MIN1 <= 0;
                if ((HOUR1 == 2) && (HOUR0 == 3)) begin
                    HOUR0 <= 0;
                    HOUR1 <= 0;
                    if ((DAY1 == 3) && (DAY0 == 1)) begin
                        DAY0 <= 1;
                        DAY1 <= 0;
                    end else begin
                        if (DAY0 == 9) begin
                            DAY0 <= 0;
                            DAY1 <= DAY1 + 4'b1;
                        end else begin
                            DAY0 <= DAY0 + 4'b1;
                        end
                    end
                end else begin
                    if (HOUR0 == 9) begin
                        HOUR0 <= 0;
                        HOUR1 <= HOUR1 + 4'b1;
                    end else begin
                        HOUR0 <= HOUR0 + 4'b1;
                    end
                end
            end else begin
                SEC0 <= 0;
                SEC1 <= 0;
                if (MIN0 == 9) begin
                    MIN0 <= 0;
                    MIN1 <= MIN1 + 4'b1;
                end else begin
                    MIN0 <= MIN0 + 4'b1;
                end
            end
        end else begin
            if (SEC0 == 9) begin
                SEC0 <= 0;
                SEC1 <= SEC1 + 4'b1;
            end else begin
                SEC0 <= SEC0 + 4'b1;
            end
        end
    end
    endtask

	//time flow
    always @(posedge CLK or negedge RSTN) begin
        if (!RSTN) begin
            SEC0 <= 0; SEC1 <= 0;
            MIN0 <= 0; MIN1 <= 0;
            HOUR0 <= 0; HOUR1 <= 0;
            DAY0 <= 1; DAY1 <= 0;
            CNT <= 0;
        end 
		  else if (SET) begin
            SEC0 <= SSEC0; SEC1 <= SSEC1;
            MIN0 <= SMIN0; MIN1 <= SMIN1;
            HOUR0 <= SHOUR0; HOUR1 <= SHOUR1;
            DAY0 <= (SDAY1 == 3 && SDAY0 > 2) ? 4'b1 : SDAY0;
            DAY1 <= (SDAY1 == 3 && SDAY0 > 2) ? 4'b0 : SDAY1;
        end 
		  else begin
            if (SW3) begin
					if(CNT>50) CNT<=0;
                else if (CNT == 13'd50) begin
                    CNT <= 0;
                    TIME_UP;
                end else begin
                    CNT <= CNT + 13'b1;
                end
            end 
				else begin
                if (CNT == 13'd5000) begin 
                    CNT <= 0;
                    TIME_UP;
                end else begin
                    CNT <= CNT + 13'b1;
                end
            end
        end
    end
	 
endmodule
