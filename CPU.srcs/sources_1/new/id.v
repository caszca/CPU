`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/20 16:51:00
// Design Name: 
// Module Name: id
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

module id(

	input wire   rst,
	input wire[31:0]   pc_i,
	input wire[`InstBus]   inst_i,  //指令
    input wire[`RegBus]    reg1_data_i,//寄存器读出数据,后赋值给源操作数
	input wire[`RegBus]    reg2_data_i,//寄存器二读出数据
	
	//处于执行阶段的指令要写入的目的寄存器信息
	input wire		ex_wreg_i,
	input wire[`RegBus]		ex_wdata_i,
	input wire[`RegAddrBus]     ex_wd_i,
	
	//处于访存阶段的指令要写入的目的寄存器信息
	input wire	    mem_wreg_i,  //是否写入目的寄存器
	input wire[`RegBus]		mem_wdata_i,  //写入目的寄存器数据
	input wire[`RegAddrBus]     mem_wd_i,   //写入目的寄存器的地址
	
	

	//送到regfile的信息
	output reg     reg1_read_o,  //是否读取reg1使能信号
	output reg     reg2_read_o,  //是否读取reg2使能信号
	output reg[`RegAddrBus]     reg1_addr_o,  //读取reg1的地址
	output reg[`RegAddrBus]     reg2_addr_o, 	//读取reg2的地址
	
	//送到执行阶段的信息
	output reg[7:0]  aluop_o,   //不同指令，实现过程相同，例如or与ori(imm赋给reg1)，reg1、2移位结果放于目的寄存器
	output reg[`AluSelBus] alusel_o, //最终根据指令的类型来用不同已经计算完的结果写入目的数据变量。
	output reg[`RegBus]    reg1_o,  //第一个源操作数
	output reg[`RegBus]    reg2_o, //第二个源操作数
	output reg[`RegAddrBus]    wd_o,   //写入目的寄存器的地址，默认取11~15位，后续跟指令类型不同取不同位
	output reg     wreg_o  //是否写入目的寄存器
);

  wire[5:0] op = inst_i[31:26]; 
  wire[4:0] op2 = inst_i[10:6];//有可能为全0
  wire[5:0] op3 = inst_i[5:0]; //R类型判断

  reg[`RegBus]	imm;   //立即数
  reg instvalid;   //指令是否有效
  
	always @ (*) begin	
		if (rst == `RstEnable) begin
			aluop_o <= 8'b00000000;
			alusel_o <= 3'b000;
			wd_o <= 5'b00000;
			wreg_o <= `WriteDisable;
			instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= 5'b00000;
			reg2_addr_o <= 5'b00000;
			imm <= 32'h0;			
	  end else begin
			aluop_o <= 8'b00000000;
			alusel_o <= 3'b000;
			wd_o <= inst_i[15:11];   //默认目的寄存器，根据指令可更改
			wreg_o <= `WriteDisable;  //默认不可写入目的寄存器
			instvalid <= `InstInvalid;	   //指令无效
			reg1_read_o <= 1'b0;         //默认不能读reg1使能信号
			reg2_read_o <= 1'b0;         //默认不能读reg2使能信号
			reg1_addr_o <= inst_i[25:21]; //默认读取的reg1地址
			reg2_addr_o <= inst_i[20:16]; ////默认读取的reg2地址
			imm <= `ZeroWord;
		  case (op)
		    6'b000000:	begin
		    	case (op2)
		    		5'b00000:	begin
		    			case (op3)
		    				`EXE_OR:  begin       //or指令
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  						alusel_o <= `EXE_RES_LOGIC; 	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end  
		    				`EXE_AND:	begin       //and指令
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;
		  						alusel_o <= `EXE_RES_LOGIC;	  reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end  	
		    				`EXE_XOR:	begin       //xor指令
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end  				
		    				`EXE_NOR:	begin       //nor指令
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_NOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end 
								`EXE_SLLV: begin        //sllv指令
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end 
								`EXE_SRLV: begin        //srlv指令
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end 					
								`EXE_SRAV: begin        //srav指令
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;			
		  						end			
								
								`EXE_SLT: begin     //slt指令
								    wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLT_OP;
								 alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
								 instvalid <= `InstValid;	
								end
								
								`EXE_SLTU: begin        //sltu指令
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLTU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								
								`EXE_ADD: begin         //add指令
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADD_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								
								`EXE_ADDU: begin        //addu指令
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADDU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								
								`EXE_SUB: begin     //sub指令
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SUB_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								
								`EXE_SUBU: begin        //subu指令
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SUBU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
										  									
						    default:	begin
						    end
						  endcase
						 end
						default: begin
						end
					endcase	
					end									  
		  	`EXE_ORI:	begin     //ORI指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];//目的寄存器
					instvalid <= `InstValid;	
		  	end
		  	`EXE_ANDI:	begin     //andi指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end	 	
		  	`EXE_XORI:	begin     //xori指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end	 		
		  	`EXE_LUI:	begin      //lui指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {inst_i[15:0], 16'h0};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end		
				
				//算术指令
				`EXE_SLTI:	begin      //slti指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLT_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end
				`EXE_SLTIU:	begin     //sltiu指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLTU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end
				`EXE_ADDI:	begin      //addi指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADDI_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end
				`EXE_ADDIU:	begin    //addiu指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADDIU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end								  	
		    default:	begin
		    end
		  endcase		  //case op
		  
		  //移位指令，寄存器1作为立即数寄存器，注意这三个指令的条件位数
		  if (inst_i[31:21] == 11'b00000000000) begin
		  	if (op3 == `EXE_SLL) begin          //sll指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end else if ( op3 == `EXE_SRL ) begin   //srl指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end else if ( op3 == `EXE_SRA ) begin   //sra指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end
			end		  
		  
		end      
	end        
	
    //寄存器一的操作
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;//原操作数一	
		end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) //执行阶段数据前推，当前指令读取的寄存器等于前面指令要写入的寄存器，raw相关
								&& (ex_wd_i == reg1_addr_o)) begin
			reg1_o <= ex_wdata_i;    //直接将要写入的数据交给原操作数一
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) //访存阶段数据前推
								&& (mem_wd_i == reg1_addr_o)) begin
			reg1_o <= mem_wdata_i; 			
	  end else if(reg1_read_o == 1'b1) begin   
	  	reg1_o <= reg1_data_i;
	  end else if(reg1_read_o == 1'b0) begin
	  	reg1_o <= imm;
	  end else begin
	    reg1_o <= `ZeroWord;
	  end
	end
    //寄存器二的操作
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;//原操作数二
		end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg2_addr_o)) begin
			reg2_o <= ex_wdata_i; 
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg2_addr_o)) begin
			reg2_o <= mem_wdata_i;			
	  end else if(reg2_read_o == 1'b1) begin
	  	reg2_o <= reg2_data_i;
	  end else if(reg2_read_o == 1'b0) begin
	  	reg2_o <= imm;
	  end else begin
	    reg2_o <= `ZeroWord;
	  end
	end

endmodule
