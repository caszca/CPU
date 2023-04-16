`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/20 16:29:45
// Design Name: 
// Module Name: pc_reg
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

`include "defines.v"

 module pc_reg(

	input	wire	clk,
	input wire		rst,           //复位信号
	output reg[`InstAddrBus]	pc,
	output reg   ce            //指令存储器使能信号
	
);

	always @ (posedge clk) begin
		if (ce == 1'b0) begin
			pc <= 32'h00000000;
		end else begin
	 		pc <= pc + 4'h4;
		end
	end
	
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= 1'b0;
		end else begin
			ce <= 1'b1;
		end
	end

endmodule