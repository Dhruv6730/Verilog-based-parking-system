`timescale 1ns / 1ps

module tb_parking_system;

  // Inputs
  reg clk;
  reg reset_n;
  reg sensor_entrance;
  reg sensor_exit;
  reg [1:0] password_1;
  reg [1:0] password_2;

  // Outputs
  wire GREEN_LED;
  wire RED_LED;
  wire [6:0] HEX_1;
  wire [6:0] HEX_2;

  // Instantiate the Unit Under Test (UUT)
  parking_system uut (
    .clk(clk), 
    .reset_n(reset_n), 
    .sensor_entrance(sensor_entrance), 
    .sensor_exit(sensor_exit), 
    .password_1(password_1), 
    .password_2(password_2), 
    .GREEN_LED(GREEN_LED), 
    .RED_LED(RED_LED), 
    .HEX_1(HEX_1), 
    .HEX_2(HEX_2)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  // Test scenario: entered password is correct
  initial begin
    // Initialize Inputs
    reset_n = 0;
    sensor_entrance = 0;
    sensor_exit = 0;
    password_1 = 0;
    password_2 = 0;

    // Wait 100 ns for global reset to finish
    #100;
    reset_n = 1;

    // Wait a bit and set the password to "11"
    #10;
    password_1 = 1;
    password_2 = 1;

    // Wait a bit and activate the entrance sensor
    #50;
    sensor_entrance = 1;

    // Wait a bit and deactivate the entrance sensor
    #50;
    sensor_entrance = 0;

    // Wait for the parking system to validate the password and turn on the GREEN LED
    #1500;
    if (GREEN_LED != 1'b1) $display("Test failed: GREEN_LED was not turned on");
    if (RED_LED != 1'b0) $display("Test failed: RED_LED was turned on");
  end

endmodule
