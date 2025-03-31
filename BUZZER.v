module BUZZER (
    input wire CLK,        // 입력 클럭 (50MHz 가정)
    input wire RSTN,       // 리셋 신호 (active low)
    input wire enable,     // 부저 활성화 신호
    output reg buzzer      // 부저 출력 신호
);

    reg [2:0] counter;    // 카운터 변수 (피에조 부저용)

    // 500Hz 주파수 설정 (5KHz 클럭에서 500Hz PWM을 만들기 위한 카운터 값)
    parameter COUNTER_MAX = 3'd4;

    // 부저용 카운터 및 PWM 생성 (500Hz 주파수)
    always @(posedge CLK or negedge RSTN) begin
        if (!RSTN) begin
            counter <= 3'd0;
            buzzer <= 1'b0; // RSTN이 active low일 때 부저를 끔
        end else if (enable) begin  // enable 신호가 활성화될 때만 부저 동작
            if (counter == COUNTER_MAX) begin  // 5KHz / (2 * 500Hz) = 5
                counter <= 3'd0;
                buzzer <= ~buzzer;  // 부저 신호 토글 (500Hz PWM 생성)
            end else begin
                counter <= counter + 3'd1;
            end
        end else begin
            buzzer <= 1'b0;  // enable이 비활성화되면 부저 끔
        end
    end

endmodule
