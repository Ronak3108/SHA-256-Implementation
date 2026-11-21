`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2026 10:12:33 PM
// Design Name: 
// Module Name: sha256_ctrl
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


module sha256_ctrl (
    // System & Global Control Interface
    input  wire        clk,            // System clock
    input  wire        rstn,           // Active-low asynchronous reset

    // Host/System Handshake Signals
    input  wire        start,          // Pulse high to begin a new SHA-256 operation (Block 0)
    input  wire        next_block,     // Pulse high to trigger processing of subsequent 512-bit block
    input  wire        is_last_block,  // High if the current block is the final block of the message
    output reg         ready,          // High when controller is ready to accept a new start/next_block
    output reg         digest_valid,   // High when full SHA-256 computation finishes (valid 256-bit hash)

    // Message Scheduler Interface (sha256_message_sched)
    output reg         load_word,         // Connects to `load` pin: latches 512-bit message into W[0..15]

    // Compression Core Interface (sha256_compression)
    output reg         init_comp,      // Connects to `init` pin: resets accumulators (Block 0 only)
    output reg         enable_comp,    // Connects to `enable` pin: advances compression round steps
    input  wire        comp_done,      // Connects to `done` pin: signals round 63 completion

    // Shared Round Counter Interface
    output reg  [5:0]  round_cnt       // Connects to `word_counter` (sched) & `round` (compression)
);
    localparam IDLE = 3'b000, INIT_BLK = 3'b001, LOAD_WORD = 3'b010, C_LOOP = 3'b011, CHECK_BLK = 3'b100, DONE = 3'b101;
    
    reg [2:0] current_state; 
    reg [2:0] next_state;
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            current_state <= IDLE;
        end
        else begin
            // Updating the state.
            current_state <= next_state;
            // Case Block driving the control signals based on the State of the FSM.            
            case (next_state)       // decoding outputs from next_state to reduce the 1 cycle latency
                IDLE: begin
                    ready <= 1'b1;
                    digest_valid <= 1'b0;
                    load_word <= 1'b0;
                    init_comp <= 1'b0;
                    enable_comp <= 1'b0;
                    round_cnt <= 1'b0;
                end
    
                INIT_BLK: begin
                    ready <= 1'b0;
                    init_comp <= 1'b1;
                end
    
                LOAD_WORD: begin
                    load_word <= 1'b1;
                    init_comp <= 1'b0;
                    round_cnt <= 6'b0;
                end
    
                C_LOOP: begin
                    enable_comp <= 1'b1;
                    round_cnt <= round_cnt + 1;
                    load_word <= 1'b0;
                end
    
                CHECK_BLK: begin
                    enable_comp <= 1'b0;
                    ready <= 1'b1;           // It tells us that if there is another block of the message then we are ready.
                end
                
                DONE: begin
                    digest_valid <= 1'b1;
                end
            endcase
        end
    end
    
    
    // Combinational Always Block which drives the next_state logic.
    always @(*) begin
        // Defining Default state when the next_state is not driven by the case block.
        next_state = current_state;
        
        // Case Block to compute the next_state.
        case (current_state)
            IDLE: begin
                if(start) begin
                    next_state = INIT_BLK;
                end
            end

            INIT_BLK: begin
                next_state = LOAD_WORD;
            end

            LOAD_WORD: begin
                next_state = C_LOOP;
            end

            C_LOOP: begin
                if(round_cnt == 6'd63) begin
                    next_state = CHECK_BLK;
                end
            end

            CHECK_BLK: begin
                if(is_last_block) begin
                    next_state = DONE;
                end
                else if(next_block) begin
                    next_state = LOAD_WORD;
                end
                else begin
                    next_state = CHECK_BLK;
                end
            end
            
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
endmodule
