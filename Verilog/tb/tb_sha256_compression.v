`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2026 03:40:13 PM
// Design Name: 
// Module Name: tb_sha256_compression
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_sha256_compression;

    reg         clk;
    reg         rstn;
    reg         init;
    reg         enable;
    reg  [5:0]  round;
    wire  [31:0] w_in;
    reg load;
    reg [511:0] message;
    
    // Output from DUT must be wire
    wire [255:0] hash_out;
    wire         done;
    
    integer i;
    
    // Instantiate DUT
    sha256_compression uut (
        .clk      (clk),
        .rstn     (rstn),
        .init     (init),
        .enable   (enable),
        .round    (round),
        .w_in     (w_in),
        .hash_out (hash_out),
        .done     (done)
    );
    
    sha256_message_sched uut0 (
        .clk          (clk),
        .rstn         (rstn),
        .load         (load),
        .message      (message),
        .word_counter (round),
        .word         (w_in)
    );
    
    // 100MHz Clock Generation
    always #5 clk = ~clk;
        
    initial begin
        // Initialize signals
        clk    <= 0;
        rstn   <= 0;
        init   <= 0;
        enable <= 0;
        round  <= 0;
        load <= 0;
        message <= 512'h61800000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000008;
        
        // --- Reset Sequence ---
        #(10);
        rstn <= 1;
        
        // --- Init State Pulse ---
        @(posedge clk);
        init <= 1;
        load <= 1;
        
        @(posedge clk);
        init <= 0;
        load <= 0;
        enable <= 1;
        
        // --- Drive 64 Round Words Synchronously ---
        for (i = 0; i < 64; i = i + 1) begin
            round = i[5:0];            // Set round immediately
            
            @(posedge clk);
            #1
            $display("ROUND %0d | Word: %h | H0: %h | a: %h", round, w_in, uut.H0, uut.a);
        end

        enable <= 0;
        
        $display("--------------------------------------------------");
        $display("Final Block Hash: %h", hash_out);
        $display("--------------------------------------------------");
        $finish;
    end

endmodule