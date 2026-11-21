`timescale 1ns / 1ps

module tb_sha256_message_sched();

// Declare inputs to the UUT as 'reg'
reg         clk;
reg         rstn;
reg         load;
reg [511:0] message;
reg [5:0]   word_counter;

// Declare outputs from the UUT as 'wire'
wire [31:0] word;
integer i;

// Instantiate the UUT
sha256_message_sched uut (
    .clk          (clk),
    .rstn         (rstn),
    .load         (load),
    .message      (message),
    .word_counter (word_counter),
    .word         (word)
);


always #5 clk = ~clk;

initial begin
    // Instantiating the initial signals
    clk <= 0;
    load <= 0;
    rstn <= 0;
    word_counter <= 0;
    // message is "a" in 512 bits padded and with the length of the message append in the end.
    message <= 512'h61800000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000008;
    
    @(posedge clk);
    rstn <= 1;
    
    @(posedge clk);
    load <= 1;
    
    @(posedge clk);
    load <= 0;
    
    // Starting the iteration of the word_counter and see the output of the words: W0, W1 .... W63
    for(i = 0; i < 64; i = i + 1) begin
        word_counter <= i;
        #1                      // Delay introduced to let the combinational circuit compute the output.
        $display("Word %02d: %08h", i, word);
        @(posedge clk);
    end
    
    #5
    @(posedge clk);
    rstn <= 0;
    
end

endmodule