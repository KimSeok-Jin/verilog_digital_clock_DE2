module TIMER (
    // Outputs
    TSEC0, TSEC1, TMIN0, TMIN1, THOUR0, THOUR1, //POWER0, POWER1, POWER2, POWER3, POWER4, POWER5, POWER6, POWER7, POWER8, POWER9, POWER10, POWER11, POWER12, POWER13, POWER14, POWER15, POWER16, POWER17,
    // Inputs
    CLK, RSTN, KEY3, KEY2, KEY1, KEY0, SW3, SW5, POWER
);

   input CLK, RSTN, KEY3, KEY2, KEY1, KEY0, SW3, SW5;
   output reg [3:0] TSEC0, TSEC1, TMIN0, TMIN1, THOUR0, THOUR1;
   //output reg POWER0, POWER1, POWER2, POWER3, POWER4, POWER5, POWER6, POWER7, POWER8, POWER9, POWER10, POWER11, POWER12, POWER13, POWER14, POWER15, POWER16, POWER17;
   output reg [17:0] POWER;
   reg [1:0] KEY_CNT;
   reg [12:0] CLK_CNT;
   reg [31:0] remaining_time, total_time;  // 초 단위로 시간을 통합하여 계산
   reg [4:0] div_time;
	reg TIMER_ACTIVE;
   reg KEY3_SYNC0, KEY3_SYNC1, KEY2_SYNC0, KEY2_SYNC1, KEY1_SYNC0, KEY1_SYNC1, KEY0_SYNC0, KEY0_SYNC1;
   reg KEY3_PRESSED, KEY2_PRESSED, KEY1_PRESSED, KEY0_PRESSED;

   wire KEY3_STABLE, KEY2_STABLE, KEY1_STABLE, KEY0_STABLE;

   assign KEY3_STABLE = KEY3_SYNC1;
   assign KEY2_STABLE = KEY2_SYNC1;
   assign KEY1_STABLE = KEY1_SYNC1;
   assign KEY0_STABLE = KEY0_SYNC1;
	
   task DECREMENT_TIME;
   begin
      if (THOUR1 == 4'b0 && THOUR0 == 4'b0 && 
          TMIN1 == 4'b0 && TMIN0 == 4'b0 && 
          TSEC1 == 4'b0 && TSEC0 == 4'b0) begin
         TIMER_ACTIVE <= 1'b0;  
      end else begin
         if (TSEC0 == 4'b0) begin
            if (TSEC1 == 4'b0) begin
               TSEC1 <= 4'b0101;
               TSEC0 <= 4'b1001;
               if (TMIN0 == 4'b0) begin
                  if (TMIN1 == 4'b0) begin
                     TMIN1 <= 4'b0101;
                     TMIN0 <= 4'b1001;
                     if (THOUR0 == 4'b0) begin
                        if (THOUR1 != 4'b0) begin
                           THOUR1 <= THOUR1 - 4'b1;
                           THOUR0 <= 4'b1001;
                        end
                     end else begin
                        THOUR0 <= THOUR0 - 4'b1;
                     end
                  end else begin
                     TMIN1 <= TMIN1 - 4'b1;
                     TMIN0 <= 4'b1001;
                  end
               end else begin
                  TMIN0 <= TMIN0 - 4'b1;
               end
            end else begin
               TSEC1 <= TSEC1 - 4'b1;
               TSEC0 <= 4'b1001;
            end
         end else begin
            TSEC0 <= TSEC0 - 4'b1;
         end
      end
   end
   endtask

   always @(posedge CLK, negedge RSTN) begin
      if (!RSTN) begin
         {KEY3_SYNC0, KEY3_SYNC1, KEY2_SYNC0, KEY2_SYNC1, KEY1_SYNC0, KEY1_SYNC1, KEY0_SYNC0, KEY0_SYNC1} <= 0;
         TMIN0 <= 4'b0; TMIN1 <= 4'b0;
         THOUR0 <= 4'b0; THOUR1 <= 4'b0;
         TSEC0 <= 4'b1; TSEC1 <= 4'b0;
         div_time<=0;
         remaining_time<=0; total_time<=0;
         TIMER_ACTIVE <= 1'b0;
         CLK_CNT <= 13'b0;
			POWER<=0;
         KEY_CNT <=0;
      end else begin
         KEY3_SYNC0 <= KEY3;
         KEY3_SYNC1 <= KEY3_SYNC0;
         KEY2_SYNC0 <= KEY2;
         KEY2_SYNC1 <= KEY2_SYNC0;
         KEY1_SYNC0 <= KEY1;
         KEY1_SYNC1 <= KEY1_SYNC0;
         KEY0_SYNC0 <= KEY0;
         KEY0_SYNC1 <= KEY0_SYNC0;
			
         if (KEY3_STABLE && !KEY3_PRESSED) begin
            KEY_CNT <= (KEY_CNT == 2'b10) ? 2'b0 : KEY_CNT + 2'b1;
            KEY3_PRESSED <= 1'b1;
         end else if (!KEY3_STABLE) begin
            KEY3_PRESSED <= 1'b0;
         end

         case (KEY_CNT)
            0: begin
               if (KEY2_STABLE && !KEY2_PRESSED) begin
                  if ((TSEC1 == 4'b0101) && (TSEC0 == 4'b1001)) begin
                     TSEC1 <= 4'b0;
                     TSEC0 <= 4'b0;
                  end else if (TSEC0 == 4'b1001) begin
                     TSEC1 <= TSEC1 + 4'b1;
                     TSEC0 <= 4'b0;
                  end else begin
                     TSEC0 <= TSEC0 + 4'b1;
                  end
                  KEY2_PRESSED <= 1'b1;
               end else if (!KEY2_STABLE) begin
                  KEY2_PRESSED <= 1'b0;
               end

               if (KEY1_STABLE && !KEY1_PRESSED) begin
                  if ((TSEC1 == 4'b0) && (TSEC0 == 4'b0)) begin
                     TSEC1 <= 4'b0101;
                     TSEC0 <= 4'b1001;
                  end else if (TSEC0 == 4'b0) begin
                     TSEC1 <= TSEC1 - 4'b1;
                     TSEC0 <= 4'b1001;
                  end else begin
                     TSEC0 <= TSEC0 - 4'b1;
                  end
                  KEY1_PRESSED <= 1'b1;
               end else if (!KEY1_STABLE) begin
                  KEY1_PRESSED <= 1'b0;
               end
            end
            1: begin
               if (KEY2_STABLE && !KEY2_PRESSED) begin
                  if ((TMIN1 == 4'b0101) && (TMIN0 == 4'b1001)) begin
                     TMIN1 <= 4'b0;
                     TMIN0 <= 4'b0;
                  end else if (TMIN0 == 4'b1001) begin
                     TMIN1 <= TMIN1 + 4'b1;
                     TMIN0 <= 4'b0;
                  end else begin
                     TMIN0 <= TMIN0 + 4'b1;
                  end
                  KEY2_PRESSED <= 1'b1;
               end else if (!KEY2_STABLE) begin
                  KEY2_PRESSED <= 1'b0;
               end

               if (KEY1_STABLE && !KEY1_PRESSED) begin
                  if ((TMIN1 == 4'b0) && (TMIN0 == 4'b0)) begin
                     TMIN1 <= 4'b0101;
                     TMIN0 <= 4'b1001;
                  end else if (TMIN0 == 4'b0) begin
                     TMIN1 <= TMIN1 - 4'b1;
                     TMIN0 <= 4'b1001;
                  end else begin
                     TMIN0 <= TMIN0 - 4'b1;
                  end
                  KEY1_PRESSED <= 1'b1;
               end else if (!KEY1_STABLE) begin
                  KEY1_PRESSED <= 1'b0;
               end
            end
            2: begin
               if (KEY2_STABLE && !KEY2_PRESSED) begin
                  if ((THOUR1 == 4'b1001) && (THOUR0 == 4'b1001)) begin
                     THOUR1 <= 4'b0;
                     THOUR0 <= 4'b0;
                  end else if (THOUR0 == 4'b1001) begin
                     THOUR1 <= THOUR1 + 4'b1;
                     THOUR0 <= 4'b0;
                  end else begin
                     THOUR0 <= THOUR0 + 4'b1;
                  end
                  KEY2_PRESSED <= 1'b1;
               end else if (!KEY2_STABLE) begin
                  KEY2_PRESSED <= 1'b0;
               end

               if (KEY1_STABLE && !KEY1_PRESSED) begin
                  if ((THOUR1 == 4'b0) && (THOUR0 == 4'b0)) begin
                     THOUR1 <= 4'b1001;
                     THOUR0 <= 4'b1001;
                  end else if (THOUR0 == 4'b0) begin
                     THOUR1 <= THOUR1 - 4'b1;
                     THOUR0 <= 4'b1001;
                  end else begin
                     THOUR0 <= THOUR0 - 4'b1;
                  end
                  KEY1_PRESSED <= 1'b1;
               end else if (!KEY1_STABLE) begin
                  KEY1_PRESSED <= 1'b0;
               end
            end
         endcase

         if (KEY0_STABLE && !KEY0_PRESSED) begin
            if (SW5) begin
               if (!TIMER_ACTIVE) begin
                  KEY_CNT<=0;
                  total_time <= (THOUR1 * 10 * 3600 + THOUR0 * 3600 + TMIN1 * 10 * 60 + TMIN0 * 60 + TSEC1 * 10 + TSEC0)/18;
               end
					TIMER_ACTIVE <= ~TIMER_ACTIVE;
            end
            KEY0_PRESSED <= 1'b1;
         end else if (!KEY0_STABLE) begin
            KEY0_PRESSED <= 1'b0;
         end

         if (!SW5) begin
            TIMER_ACTIVE <= 1'b0;
            KEY_CNT<=0;
            POWER<=0;
            TSEC0 <= 4'b0; TSEC1 <= 4'b0;
            TMIN0 <= 4'b0; TMIN1 <= 4'b0;
            THOUR0 <= 4'b0; THOUR1 <= 4'b0;
         end
         if (TIMER_ACTIVE && SW5) begin
            if (SW3) begin
					if (CLK_CNT>50) CLK_CNT<=0;
               else if (CLK_CNT == 13'd50) begin
                  CLK_CNT <= 0;
                  DECREMENT_TIME;  
                  POWER_LED;
               end else begin
                  CLK_CNT <= CLK_CNT + 13'b1;
               end
            end else begin
               if (CLK_CNT == 13'd5000) begin 
                  CLK_CNT <= 0;
                  DECREMENT_TIME;  
                  POWER_LED;
               end else begin
                  CLK_CNT <= CLK_CNT + 13'b1;
               end
            end
         end
      end
   end

   task POWER_LED;
   begin
      remaining_time = THOUR1 * 10 * 3600 + THOUR0 * 3600 + TMIN1 * 10 * 60 + TMIN0 * 60 + TSEC1 * 10 + TSEC0;
      if ((THOUR1 == 0)&&(THOUR0 == 0)&&(TMIN1 == 0)&&(TMIN0 == 0)&&(TSEC1 == 0)&&(TSEC0 == 0)) begin
			POWER<=0;
      end else begin
			if (remaining_time<= total_time) div_time=0;
			else if (remaining_time<= 2*total_time) div_time=1;
			else if (remaining_time<= 3*total_time) div_time=2;
			else if (remaining_time<= 4*total_time) div_time=3;
			else if (remaining_time<= 5*total_time) div_time=4;
			else if (remaining_time<= 6*total_time) div_time=5;
			else if (remaining_time<= 7*total_time) div_time=6;
			else if (remaining_time<= 8*total_time) div_time=7;
			else if (remaining_time<= 9*total_time) div_time=8;
			else if (remaining_time<= 10*total_time) div_time=9;
			else if (remaining_time<= 11*total_time) div_time=10;
			else if (remaining_time<= 12*total_time) div_time=11;
			else if (remaining_time<= 13*total_time) div_time=12;
			else if (remaining_time<= 14*total_time) div_time=13;
			else if (remaining_time<= 15*total_time) div_time=14;
			else if (remaining_time<= 16*total_time) div_time=15;
			else if (remaining_time<= 17*total_time) div_time=16;
			else if (remaining_time<= 18*total_time) div_time=17;
			else if (remaining_time<= 19*total_time) div_time=18;
			//else if (remaining_time<= 20*total_time) div_time=18;
			else div_time=0;
			
         case (div_time)
            18: POWER <= 18'b111111111111111111;
            17: POWER <= 18'b111111111111111110;
            16: POWER <= 18'b111111111111111100;
            15: POWER <= 18'b111111111111111000;
            14: POWER <= 18'b111111111111110000;
            13: POWER <= 18'b111111111111100000;
            12: POWER <= 18'b111111111111000000;
            11: POWER <= 18'b111111111110000000;
            10: POWER <= 18'b111111111100000000;
             9: POWER <= 18'b111111111000000000;
             8: POWER <= 18'b111111110000000000;
             7: POWER <= 18'b111111100000000000;
             6: POWER <= 18'b111111000000000000;
             5: POWER <= 18'b111110000000000000;
             4: POWER <= 18'b111100000000000000;
             3: POWER <= 18'b111000000000000000;
             2: POWER <= 18'b110000000000000000;
             1: POWER <= 18'b100000000000000000;
             0: POWER <= 18'b000000000000000000;				
				default: POWER<=0;//{POWER0, POWER1, POWER2, POWER3, POWER4, POWER5, POWER6, POWER7, POWER8, POWER9, POWER10, POWER11, POWER12, POWER13, POWER14, POWER15, POWER16, POWER17} <= 18'b000000000000000000;
         endcase
      end
   end
   endtask


endmodule
