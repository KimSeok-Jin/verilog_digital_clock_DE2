module STOPWATCH(

    SW_SEC0, SW_SEC1, SW_MIN0, SW_MIN1, SW_HOUR0, SW_HOUR1, SW_DAY0, SW_DAY1, SW_ACTIVE,
    CLK, RSTN, SW2, SW3, KEY3

);   
    input CLK, RSTN, SW2, SW3, KEY3;

    output reg [3:0] SW_SEC0, SW_SEC1, SW_MIN0, SW_MIN1, SW_HOUR0, SW_HOUR1, SW_DAY0, SW_DAY1; 
    
    reg [12:0] SW_CNT;
   
    output reg SW_ACTIVE;
	 
	 reg SW_PAUSED;

    reg KEY3_prev, SW2_prev, SW3_prev;

    task STOPWATCH_UP;
    begin
        if ((SW_SEC1 == 5) && (SW_SEC0 == 9)) begin
            SW_SEC0 <= 0;
            SW_SEC1 <= 0;
            if ((SW_MIN1 == 5) && (SW_MIN0 == 9)) begin
                SW_MIN0 <= 0;
                SW_MIN1 <= 0;
                if ((SW_HOUR1 == 2) && (SW_HOUR0 == 3)) begin
                    SW_HOUR0 <= 0;
                    SW_HOUR1 <= 0;
                    if ((SW_DAY1 == 9) && (SW_DAY0 == 9)) begin
                        SW_DAY0 <= 0;
                        SW_DAY1 <= 0;
                    end else begin
                        if (SW_DAY0 == 9) begin
                            SW_DAY0 <= 0;
                            SW_DAY1 <= SW_DAY1 + 4'b1;
                        end else begin
                            SW_DAY0 <= SW_DAY0 + 4'b1;
                        end
                    end
                end else begin
                    if (SW_HOUR0 == 9) begin
                        SW_HOUR0 <= 0;
                        SW_HOUR1 <= SW_HOUR1 + 4'b1;
                    end else begin
                        SW_HOUR0 <= SW_HOUR0 + 4'b1;
                    end
                end
            end else begin
                if (SW_MIN0 == 9) begin
                    SW_MIN0 <= 0;
                    SW_MIN1 <= SW_MIN1 + 4'b1;
                end else begin
                    SW_MIN0 <= SW_MIN0 + 4'b1;
                end
            end
        end else begin
            if (SW_SEC0 == 9) begin
                SW_SEC0 <= 0;
                SW_SEC1 <= SW_SEC1 + 4'b1;
            end else begin
                SW_SEC0 <= SW_SEC0 + 4'b1;
            end
        end
    end
    endtask

    always @(posedge CLK or negedge RSTN) begin
        if (!RSTN) begin
            SW_SEC0 <= 0; SW_SEC1 <= 0;
            SW_MIN0 <= 0; SW_MIN1 <= 0;
            SW_HOUR0 <= 0; SW_HOUR1 <= 0;
            SW_DAY0 <= 0; SW_DAY1 <= 0;
            SW_CNT <= 0;
            SW_ACTIVE <= 0;
            SW_PAUSED <= 0;
            SW2_prev <= 0;
            KEY3_prev <= 0;
        end else if (SW2 && !SW2_prev) begin
            SW_ACTIVE <= 1;
            SW_PAUSED <= 0;
            KEY3_prev <= 0;
            SW2_prev <= SW2;
        end else if (!SW2 && SW2_prev) begin
            SW_ACTIVE <= 0;
            SW_SEC0 <= 0; SW_SEC1 <= 0;
            SW_MIN0 <= 0; SW_MIN1 <= 0;
            SW_HOUR0 <= 0; SW_HOUR1 <= 0;
            SW_DAY0 <= 0; SW_DAY1 <= 0;
            SW_CNT <= 0;
            SW_PAUSED <= 0;
            SW2_prev <= SW2;
        end else if (SW_ACTIVE && SW2) begin
            if (KEY3 && !KEY3_prev) begin
                SW_PAUSED <= ~SW_PAUSED;
            end
            KEY3_prev <= KEY3;
            if (!SW_PAUSED) begin
                if (SW3) begin
						if(SW_CNT>50) SW_CNT<=0; 
                   else if (SW_CNT == 13'd50) begin
                        SW_CNT <= 0;
                        STOPWATCH_UP;
                    end else begin
                        SW_CNT <= SW_CNT + 13'b1;
                    end
                end else begin
                    if (SW_CNT == 13'd5000) begin
                        SW_CNT <= 0;
                        STOPWATCH_UP;
                    end else begin
                        SW_CNT <= SW_CNT + 13'b1;
                    end
                end
            end
        end
    end
	
endmodule