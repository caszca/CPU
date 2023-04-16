`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/20 16:51:46
// Design Name: 
// Module Name: regfile
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

module regfile(

	input wire	clk,
	input wire	rst,
	
	//д�˿�
	input wire	we, //дʹ���ź�
	input wire[`RegAddrBus]	   waddr,
	input wire[`RegBus]		wdata,
	
	//���˿�1
	input wire	re1,  //��ʹ���ź�
	input wire[`RegAddrBus]	   raddr1,
	output reg[`RegBus]    rdata1,
	
	//���˿�2
	input wire	re2,    //��ʹ���ź�
	input wire[`RegAddrBus]	   raddr2,
	output reg[`RegBus]    rdata2
	
);
    //32��32λ�Ĵ���
    reg[`RegBus]  regs[0:31];
   initial begin
   regs[1] = 0;
   regs[2] = 1;
   end
   
	always @ (posedge clk) begin
		if (rst == `RstDisable) begin
			if((we == `WriteEnable) && (waddr != 5'h0)) begin
				regs[waddr] <= wdata;
			end
		end
	end
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			  rdata1 <= `ZeroWord;
	  end else if(raddr1 == 5'h0) begin  //0�Ĵ���
	  		rdata1 <= `ZeroWord;
	  end else if((raddr1 == waddr) && (we == `WriteEnable)  //����ǰ��
	  	            && (re1 == 1'b1)) begin
	  	  rdata1 <= wdata;
	  end else if(re1 == 1'b1) begin
	      rdata1 <= regs[raddr1];
	  end else begin
	      rdata1 <= `ZeroWord;
	  end
	end

	always @ (*) begin
		if(rst == `RstEnable) begin
			  rdata2 <= `ZeroWord;
	  end else if(raddr2 == 5'h0) begin
	  		rdata2 <= `ZeroWord;
	  end else if((raddr2 == waddr) && (we == `WriteEnable) 
	  	            && (re2 == 1'b1)) begin
	  	  rdata2 <= wdata;
	  end else if(re2 == 1'b1) begin
	      rdata2 <= regs[raddr2];
	  end else begin
	      rdata2 <= `ZeroWord;
	  end
	end

endmodule