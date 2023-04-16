`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/20 16:56:56
// Design Name: 
// Module Name: inst_rom
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

module inst_rom(

	
	input wire		ce,
	input wire[`InstAddrBus]	addr,
	output reg[`InstBus]	inst
);

	reg[`InstBus]  inst_mem[0:1023];

	initial $readmemh ( "D:/inst_rom.data", inst_mem );   //必须斜杠才行

	always @ (*) begin
		if (ce == 1'b0) begin
			inst <= `ZeroWord;
	  end else begin
		  inst <= inst_mem[addr[18:2]]; //指令宽度为17位
		end
	end

endmodule