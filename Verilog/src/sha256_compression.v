`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2026 10:12:33 PM
// Design Name: 
// Module Name: sha256_compression
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
`include "sha256_pkg.vh"

module sha256_compression(
    input wire clk,                 // The Clock Signal
    input wire rstn,                // The Asynchronous Reset
    input wire init,                // This loads the Initial Hash Constants in the state variables. It is only pulsed for Block0.
    input wire enable,              // This basically tells us to go to the next compression round of the word.
    input wire [5:0] round,         // This keeps the round count for the 64 Words W0, W1, ... W62, W63.
    input wire [31:0] w_in,         // This gives the word as W[round]. 
    
    output wire [255:0] hash_out,   // This gives the final hashed message of 256 bit length after the compression algorithm has run.
    output reg done                // This signal basically tells if the hash_out is ready to read or not.
    );
    
        
    // Defining the reg K which helps us get the K0, K1 ... K63 constants
    wire [31:0] K;
    assign K = fetch_k(round);
    
    // Defining the working Variables
    reg [31:0] a;
    reg [31:0] b;
    reg [31:0] c;
    reg [31:0] d;
    reg [31:0] e;
    reg [31:0] f;
    reg [31:0] g;
    reg [31:0] h;
    
    // Defining the initial hash accumulators
    reg [31:0] H0;
    reg [31:0] H1;
    reg [31:0] H2;
    reg [31:0] H3;
    reg [31:0] H4;
    reg [31:0] H5;
    reg [31:0] H6;
    reg [31:0] H7;
    
    wire [31:0] T1;
    wire [31:0] T2;
    
    assign T1 = h + SIGMA1(e) + CH(e,f,g) + K + w_in;
    assign T2 = SIGMA0(a) + MAJ(a,b,c);
    
    assign hash_out = {H0, H1, H2, H3, H4, H5, H6, H7};
                       
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            // Clearing or re-initialising everything on Reset
            a <= 32'h0;
            b <= 32'h0;
            c <= 32'h0;
            d <= 32'h0;
            e <= 32'h0;
            f <= 32'h0;
            g <= 32'h0;
            h <= 32'h0;
            
            H0 <= `H0_INIT;
            H1 <= `H1_INIT;
            H2 <= `H2_INIT;
            H3 <= `H3_INIT;
            H4 <= `H4_INIT;
            H5 <= `H5_INIT;
            H6 <= `H6_INIT;
            H7 <= `H7_INIT;
        end
        else if (init) begin
            // This is only pulsed when the first block (512 bits) of a message are being loaded.
            // The Hash Constants are re-initialised.
            H0 <= `H0_INIT;
            H1 <= `H1_INIT;
            H2 <= `H2_INIT;
            H3 <= `H3_INIT;
            H4 <= `H4_INIT;
            H5 <= `H5_INIT;
            H6 <= `H6_INIT;
            H7 <= `H7_INIT;
            
            a <= `H0_INIT;
            b <= `H1_INIT;
            c <= `H2_INIT;
            d <= `H3_INIT;
            e <= `H4_INIT;
            f <= `H5_INIT;
            g <= `H6_INIT;
            h <= `H7_INIT;
        end
        else if(enable) begin
            if(round == 6'd63) begin
                // Update Hash Accumulators
                H0 <= T1 + T2 + H0;     // a63 = T1 + T2
                H1 <= a + H1;           // b63 = a62
                H2 <= b + H2;           // c63 = b62
                H3 <= c + H3;           // d63 = c62
                H4 <= d + T1 + H4;      // e63 = d62 + T1
                H5 <= e + H5;           // f63 = e62
                H6 <= f + H6;           // g63 = f62
                H7 <= g + H7;           // h63 = g62

                // Also update working registers for round 63 state completion and ready for the next 512 bit blocj
                a <= H0 + T1 + T2;
                b <= H1 + a;
                c <= H2 + b;
                d <= H3 + c;
                e <= H4 + d + T1;
                f <= H5 + e;
                g <= H6 + f;
                h <= H7 + g;
                
                done <= 1'b1;
            end
            else begin
                // Standard intermediate compression round
                a <= T1 + T2;
                b <= a;
                c <= b;
                d <= c;
                e <= d + T1;
                f <= e;
                g <= f;
                h <= g;
                done <= 1'b0;
            end
        end
    end
    
    
    // The helper functions for compression: Big Sigmas, Choice and Majority Function
    function [31:0] SIGMA0(input [31:0] x);
        SIGMA0 = {x[1:0], x[31:2]} ^
                 {x[12:0], x[31:13]} ^
                 {x[21:0], x[31:22]};
    endfunction
    
    function [31:0] SIGMA1(input [31:0] x);
        SIGMA1 = {x[5:0], x[31:6]} ^
                 {x[10:0], x[31:11]} ^
                 {x[24:0], x[31:25]};
    endfunction
    
    function [31:0] CH(input [31:0] x, input [31:0] y, input [31:0] z);
        CH = (x & y) ^ (~x & z);
    endfunction
    
    function [31:0] MAJ(input [31:0] x, input [31:0] y, input [31:0] z);
        MAJ = (x & y) ^ (x & z) ^ (y & z);
    endfunction
    
    function [31:0] fetch_k(input [5:0] round);
        case (round)
            6'd00: fetch_k = 32'h428a2f98; 6'd01: fetch_k = 32'h71374491;
            6'd02: fetch_k = 32'hb5c0fbcf; 6'd03: fetch_k = 32'he9b5dba5;
            6'd04: fetch_k = 32'h3956c25b; 6'd05: fetch_k = 32'h59f111f1;
            6'd06: fetch_k = 32'h923f82a4; 6'd07: fetch_k = 32'hab1c5ed5;
            6'd08: fetch_k = 32'hd807aa98; 6'd09: fetch_k = 32'h12835b01;
            6'd10: fetch_k = 32'h243185be; 6'd11: fetch_k = 32'h550c7dc3;
            6'd12: fetch_k = 32'h72be5d74; 6'd13: fetch_k = 32'h80deb1fe;
            6'd14: fetch_k = 32'h9bdc06a7; 6'd15: fetch_k = 32'hc19bf174;
            6'd16: fetch_k = 32'he49b69c1; 6'd17: fetch_k = 32'hefbe4786;
            6'd18: fetch_k = 32'h0fc19dc6; 6'd19: fetch_k = 32'h240ca1cc;
            6'd20: fetch_k = 32'h2de92c6f; 6'd21: fetch_k = 32'h4a7484aa;
            6'd22: fetch_k = 32'h5cb0a9dc; 6'd23: fetch_k = 32'h76f988da;
            6'd24: fetch_k = 32'h983e5152; 6'd25: fetch_k = 32'ha831c66d;
            6'd26: fetch_k = 32'hb00327c8; 6'd27: fetch_k = 32'hbf597fc7;
            6'd28: fetch_k = 32'hc6e00bf3; 6'd29: fetch_k = 32'hd5a79147;
            6'd30: fetch_k = 32'h06ca6351; 6'd31: fetch_k = 32'h14292967;
            6'd32: fetch_k = 32'h27b70a85; 6'd33: fetch_k = 32'h2e1b2138;
            6'd34: fetch_k = 32'h4d2c6dfc; 6'd35: fetch_k = 32'h53380d13;
            6'd36: fetch_k = 32'h650a7354; 6'd37: fetch_k = 32'h766a0abb;
            6'd38: fetch_k = 32'h81c2c92e; 6'd39: fetch_k = 32'h92722c85;
            6'd40: fetch_k = 32'ha2bfe8a1; 6'd41: fetch_k = 32'ha81a664b;
            6'd42: fetch_k = 32'hc24b8b70; 6'd43: fetch_k = 32'hc76c51a3;
            6'd44: fetch_k = 32'hd192e819; 6'd45: fetch_k = 32'hd6990624;
            6'd46: fetch_k = 32'hf40e3585; 6'd47: fetch_k = 32'h106aa070;
            6'd48: fetch_k = 32'h19a4c116; 6'd49: fetch_k = 32'h1e376c08;
            6'd50: fetch_k = 32'h2748774c; 6'd51: fetch_k = 32'h34b0bcb5;
            6'd52: fetch_k = 32'h391c0cb3; 6'd53: fetch_k = 32'h4ed8aa4a;
            6'd54: fetch_k = 32'h5b9cca4f; 6'd55: fetch_k = 32'h682e6ff3;
            6'd56: fetch_k = 32'h748f82ee; 6'd57: fetch_k = 32'h78a5636f;
            6'd58: fetch_k = 32'h84c87814; 6'd59: fetch_k = 32'h8cc70208;
            6'd60: fetch_k = 32'h90befffa; 6'd61: fetch_k = 32'ha4506ceb;
            6'd62: fetch_k = 32'hbef9a3f7; 6'd63: fetch_k = 32'hc67178f2;
            default: fetch_k = 32'h00000000;
        endcase
    endfunction
    
    
endmodule
