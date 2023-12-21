module parking_system(
    input clk, reset_n,
    input sensor_entrance, sensor_exit,
    input [1:0] password_1, password_2,
    output reg z,
    output wire GREEN_LED, RED_LED
);

    parameter IDLE = 3'b000, WAIT_PASSWORD = 3'b001, WRONG_PASS = 3'b010, RIGHT_PASS = 3'b011, STOP = 3'b100;

    // Moore FSM: output just depends on the current state
    reg [2:0] current_state, next_state;
    reg [5:0] counter_wait;
    reg red_tmp, green_tmp;
    reg [25:0] temp;
    reg clkdiv;

    initial
    begin
        temp = 0;
        clkdiv = 1'b0;
    end

    always @(posedge clk)
    begin
        temp = temp + 1;
        if (temp[25] == 1)
        begin
            clkdiv = ~clkdiv;
            temp = 0;
        end
        z = clkdiv;
    end

    // Next state
    always @(posedge clkdiv or negedge reset_n)
    begin
        if (~reset_n)
            current_state = IDLE;
        else
            current_state = next_state;
    end

    // counter_wait
    always @(posedge clkdiv or negedge reset_n)
    begin
        if (~reset_n)
            counter_wait <= 0;
        else if (current_state == WAIT_PASSWORD)
            counter_wait <= counter_wait + 1;
        else
            counter_wait <= 0;
    end

    // change state
    always @(*)
    begin
        case (current_state)
            IDLE: begin
                if (sensor_entrance == 1)
                    next_state = WAIT_PASSWORD;
                else
                    next_state = IDLE;
            end

            WAIT_PASSWORD: begin
                if (counter_wait <= 30)
                    next_state = WAIT_PASSWORD;
                else
                begin
                    if ((password_1 == 2'b01) && (password_2 == 2'b10))
                        next_state = RIGHT_PASS;
                    else
                        next_state = WRONG_PASS;
                end
            end

            WRONG_PASS: begin
                if ((password_1 == 2'b01) && (password_2 == 2'b10))
                    next_state = RIGHT_PASS;
                else
                    next_state = WRONG_PASS;
            end

            RIGHT_PASS: begin
                if (sensor_entrance == 1 && sensor_exit == 1)
                    next_state = STOP;
                else if (sensor_exit == 1)
                    next_state = IDLE;
                else
                    next_state = RIGHT_PASS;
            end

            STOP: begin
                if ((password_1 == 2'b01) && (password_2 == 2'b10))
                    next_state = RIGHT_PASS;
                else
                    next_state = STOP;
            end

            default: next_state = IDLE;
        endcase
    end

    // LEDs and output, change the period of blinking LEDs here
    always @(posedge clkdiv)
    begin
        case (current_state)
            IDLE: begin
                green_tmp = 1'b0;
                red_tmp = 1'b0;
            end

            WAIT_PASSWORD: begin
                green_tmp = 1'b0;
                red_tmp = 1'b1;
            end

            WRONG_PASS: begin
                green_tmp = 1'b0;
                red_tmp = ~red_tmp;
            end

            RIGHT_PASS: begin
                green_tmp = ~green_tmp;
                red_tmp = 1'b0;
            end

            STOP: begin
                green_tmp = 1'b0;
                red_tmp = ~red_tmp;
            end
        endcase
    end

    assign RED_LED = red_tmp;
    assign GREEN_LED = green_tmp;

endmodule
