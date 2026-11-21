`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2026 10:12:33 PM
// Design Name: 
// Module Name: sha256_top
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


module sha256_top(
    input wire              clk,
    input wire              rstn,
    input wire              start,
    input wire              next_block,
    input wire              is_last_block,
    output wire             ready,
    output wire             digest_ready,
    
    input wire [511:0]      message,
    
    output wire [255:0]      hash
    );
    
    // Wires for internal connections.
    wire [5:0]  round_cnt;
    wire load_word;
    wire init_comp;
    wire enable_comp;
    wire comp_done;
    wire [31:0] w_data;
    
    sha256_message_sched scheduler (
        .clk(clk),
        .rstn(rstn),
        .load(load_word),
        .message(message),
        .word_counter(round_cnt),
        .word(w_data)
    );
    
    sha256_compression compressor (
        .clk(clk),
        .rstn(rstn),
        .init(init_comp),
        .enable(enable_comp),
        .round(round_cnt),
        .w_in(w_data),
        .hash_out(hash),
        .done(comp_done)
    );
    
    sha256_ctrl controller (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .next_block(next_block),
        .is_last_block(is_last_block),
        .ready(ready),
        .digest_valid(digest_ready),
        .load_word(load_word),
        .init_comp(init_comp),
        .enable_comp(enable_comp),
        .comp_done(comp_done),
        .round_cnt(round_cnt)
    );
endmodule
