`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muhammed Adel
// 
// Create Date: 08/05/2024 01:33:54 AM
// Design Name: 
// Module Name: I2C
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
module eeprom_top #(parameter N = 8) (
    input clk,              // System clock
    input rst,              // Reset signal
    input newd,             // New data signal
    input ack,              // Acknowledgment signal
    input wr,               // Write/read control signal (1 = write, 0 = read)
    output scl,             // Serial clock line for I2C
    inout sda,              // Serial data line for I2C
    input [N-1:0] wdata,      // Data to be written
    input [N-2:0] addr,       // 7-bit address (8th bit is mode)
    output reg [N-1:0] rdata, // Data read from EEPROM
    output reg done         // Operation done signal
);
    // RAM interface signals
reg ram_we, ram_re;     // RAM write and read enable signals
wire [N-1:0] ram_rdata;   // Data read from RAM

reg sda_en = 0;         // SDA enable
reg sclt, sdat, donet;  // Temporary signals
reg [N-1:0] rdatat;       // Temporary read data
reg [N-1:0] addrt;        // Temporary address
// Instantiate RAM
RAM #(.N(N)) memory (
    .clk(clk),
    .addr(addrt),
    .wdata(wdata),
    .rdata(ram_rdata),
    .we(ram_we),
    .re(ram_re)
);
    // State encoding
    localparam idle = 0, 
              check_wr = 1, 
              wstart = 2, 
              wsend_addr = 3, 
              waddr_ack = 4, 
              wsend_data = 5, 
              wdata_ack = 6, 
              wstop = 7, 
              rsend_addr = 8, 
              raddr_ack = 9, 
              rsend_data = 10,
              rdata_ack = 11, 
              rstop = 12;

    reg [3:0] state = idle; // Current state
    reg sclk_ref = 0;       // SCL reference clock
    integer count = 0;      // Clock divider counter
    integer i = 0;          // Bit counter

    // Generate SCL reference clock (100 MHz / 400 KHz = 250, so divide by 250)
    always @(posedge clk) begin
        if (count <= 9) begin
            count <= count + 1;     
        end else begin
            count <= 0; 
            sclk_ref <= ~sclk_ref;
        end
    end

    // State machine for I2C protocol
    always @(posedge sclk_ref, posedge rst) begin 
        if (rst == 1'b1) begin
            sclt <= 1'b0;
            sdat <= 1'b0;
            donet <= 1'b0;
            done <= 1'b0;
        end else begin
            case (state)
                idle: begin
                    sdat <= 1'b0;
                    done <= 1'b0;  
                    sda_en <= 1'b1;
                    sclt <= 1'b1;  
                    sdat <= 1'b1;
                    ram_we <= 1'b0;
                    ram_re <= 1'b0;
                    if (newd == 1'b1) 
                        state <= wstart;
                    else 
                        state <= idle;         
                end
         
                wstart: begin
                    sdat <= 1'b0;      
                    sclt <= 1'b1;      
                    state <= check_wr;  
                    addrt <= {addr, wr}; 
                end
            
                check_wr: begin
                    // Determine if it's a write or read operation
                    if (wr == 1'b1) begin
                        state <= wsend_addr;
                        ram_we <= 1'b1;
                        ram_re <= 1'b0;
                        sdat <= addrt[0];
                        i <= 1;
                    end else begin
                        state <= rsend_addr;
                        ram_re <= 1'b1;
                        ram_we <= 1'b0;
                        sdat <= addrt[0];
                        i <= 1;
                    end
                end

                wsend_addr: begin                
                    if (i <= 7) begin
                        sdat <= addrt[i];
                        i <= i + 1;
                    end else begin
                        i <= 0;
                        state <= waddr_ack; 
                    end   
                end
         
                waddr_ack: begin
                    if (ack == 1'b1) begin
                        state <= wsend_data;
                        sdat <= wdata[0];
                        i <= i + 1;
                        sda_en <= 1'b0;
                    end else
                        state <= waddr_ack;
                end

                wsend_data: begin
                    if (i <= N-1) begin
                        i <= i + 1;
                        sdat <= wdata[i]; 
                    end else begin
                        i <= 0;
                        state <= wdata_ack;
                    end
                end

                wdata_ack: begin
                    if (ack == 1'b1) begin
                        state <= wstop;
                        sdat <= 1'b0;
                        sclt <= 1'b1;
                    end else 
                        state <= wdata_ack;
                end
         
                wstop: begin
                    sdat <= 1'b1;
                    state <= idle;
                    done <= 1'b1;
                    ram_we <= 1'b0;  // Disable RAM write  
                end
                // Read states
                rsend_addr: begin
                    if (i <= N-1) begin
                        sdat <= addrt[i];
                        i <= i + 1;
                    end else begin
                        i <= 0;
                        state <= raddr_ack; 
                    end   
                end

                raddr_ack: begin
                    if (ack == 1'b1) begin
                        state <= rsend_data;
                        sda_en <= 1'b0;
                        ram_re <= 1'b1;  // Enable RAM read
                    end else
                        state <= raddr_ack;
                end

                rsend_data: begin
                    if (i <= N-1) begin
                        i <= i + 1;
                        state <= rsend_data;
                        rdata[i] <= sda;
                    end else begin
                        i <= 0;
                        state <= rstop;
                        sclt <= 1'b1;
                        sdat <= 1'b0;
                        ram_re <= 1'b0;  // Disable RAM read  
                    end         
                end

                rstop: begin
                    sdat <= 1'b1;
                    state <= idle;
                    done <= 1'b1;  
                end

                default: state <= idle;
            endcase
        end
    end
    // Output SCL and SDA control
    assign scl = ((state == wstart) || (state == wstop) || (state == rstop)) ? sclt : sclk_ref;
    assign sda = (sda_en == 1'b1) ? sdat : 1'bz;

endmodule
