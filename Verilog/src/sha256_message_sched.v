`timescale 1ns / 1ps
// This module simply contains the machinery whose work is simply to take the raw 512 bit data.
// Convert the data to 16 32-bit words and generate the other 48 works using the combination of the previous ones.
// The output would be W[word_counter]

module sha256_message_sched(
    input wire clk,
    input wire load,
    input rstn,
    input wire [511:0] message, // this is the input recieved (raw 512 bit data
    input wire [5:0] word_counter,      // this tells the word which is supposed to be shown. If word_counter = 17,
                                        // then output word will be W17         
    output wire [31:0] word        
    );
    
    integer i;
    reg [31:0] word_list [15:0];        // This keeps the track of the last 16 words.
    wire [31:0] w_next;

    // SHA-256 Recurrence: W[i] = sigma1(W[i-2]) + W[i-7] + sigma0(W[i-15]) + W[i-16]
    assign w_next = sigma1(word_list[14]) + word_list[9] + sigma0(word_list[1]) + word_list[0];
    
    assign word = (word_counter < 16) ? word_list[word_counter] : w_next;
    
    always @(posedge clk or negedge rstn) begin
        // First we check if the reset is ON or not.
        if (!rstn) begin
            for(i = 0; i < 16; i = i + 1) begin
                word_list[i] <= 32'h00000000;
            end
        end
        // Then we check if the load signal is ON or not.
        else if (load) begin
            for(i = 0; i < 16; i = i + 1) begin
                word_list[i] <= message[511-(32*i) -: 32];
            end
        end
        // If both of the signals are OFF then we start taking requests from the word_counter
        else begin
            // if word_counter is less than 16 then we don't really need to do anything
            // as we can just serve from the word_list only.
            // But after word_counter reaches 16, we have to start ,maintaining the word_list
            // such that for word_counter = i (i >= 16), word_list should have W(i-15) to W(i-1)
            if (word_counter > 15) begin
                // Now we update the word_list accordingly as we add the current_word.
                for (i = 0; i < 15; i = i + 1) begin
                    word_list[i] <= word_list[i + 1];
                end
                word_list[15] <= w_next;
            end
        end
    end
    
    function [31:0] sigma1(input [31:0] x);
        sigma1 = {x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ (x >> 10);
    endfunction
    
    function [31:0] sigma0(input [31:0] x);
        sigma0 = {x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ (x >> 3);
    endfunction
endmodule
