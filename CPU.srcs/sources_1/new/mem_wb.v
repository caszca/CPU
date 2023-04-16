`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/20 16:55:15
// Design Name: 
// Module Name: mem_wb
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

module mem_wb(

	input	wire	clk,
	input wire	rst,
	

	//���Էô�׶ε���Ϣ	
	input wire[`RegAddrBus] mem_wd,
	input wire   mem_wreg,
	input wire[`RegBus]	mem_wdata,

	//�͵���д�׶ε���Ϣ
	output reg[`RegAddrBus]   wb_wd,
	output reg   wb_wreg,
	output reg[`RegBus]	 wb_wdata	       
	
);


	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			wb_wd <= 5'b00000;
			wb_wreg <= `WriteDisable;
		  wb_wdata <= `ZeroWord;	
		end else begin
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;
		end    
	end      
			

endmodule