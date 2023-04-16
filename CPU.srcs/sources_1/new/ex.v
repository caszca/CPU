`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/20 16:53:36
// Design Name: 
// Module Name: ex
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

module ex(

	input wire	rst,

	//译码阶段送到执行阶段的信息
	input wire[7:0]         aluop_i, 
	input wire[`AluSelBus]        alusel_i,
	input wire[`RegBus]     reg1_i, //源操作数1
	input wire[`RegBus]     reg2_i,  //源操作数2
	input wire[`RegAddrBus] wd_i,   //目的寄存器地址
	input wire   wreg_i,  //是否写入目的寄存器


	output reg[`RegAddrBus]  wd_o,  //最终写入目的寄存器地址
	output reg     wreg_o,       //执行完后最终是否写入目的寄存器，加减法溢出时，就设置为0，不写入寄存器
	output reg[`RegBus]    wdata_o  //执行完最终数据
	
);

    wire[`RegBus] reg2_i_mux;//保留寄存器Reg2的补码或者源码，看情况
    wire ov_sum;//是否存在溢出
    wire[`RegBus] result_sum;   //保留加法运算后的数据
    wire reg1_lt_reg2;  //第一个操作数是否小于第二个操作数
    
    reg[`RegBus] arithmeticres;//保存算术运算结果
	reg[`RegBus] logicout;   //逻辑运算保留值
	reg[`RegBus] shiftres;     //移位运算保留值
		
	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)//逻辑运算
				`EXE_OR_OP:			begin
					logicout <= reg1_i | reg2_i;
				end
				`EXE_AND_OP:		begin
					logicout <= reg1_i & reg2_i;
				end
				`EXE_NOR_OP:		begin
					logicout <= ~(reg1_i | reg2_i);
				end
				`EXE_XOR_OP:		begin
					logicout <= reg1_i ^ reg2_i;
				end
				default:				begin
					logicout <= `ZeroWord;
				end
			endcase
		end   
	end     

	always @ (*) begin
		if(rst == `RstEnable) begin
			shiftres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLL_OP:			begin
					shiftres <= reg2_i << reg1_i[4:0] ;
				end
				`EXE_SRL_OP:		begin
					shiftres <= reg2_i >> reg1_i[4:0];
				end
				`EXE_SRA_OP:		begin
				//需要扩展6位十进制，因为2^5=32，需要6位2进制才能表示
					shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]}))//求移动位数 
												| reg2_i >> reg1_i[4:0];
				end
				default:				begin
					shiftres <= `ZeroWord;
				end
			endcase
		end    
	end      

//如果是减法与有符号比较，那么reg2_i_mux为其本身的补码，反之保留原值。因为减法与有符号比较最终会是两个数相减，计算机中加上另一个数的补码
assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) ||
											 (aluop_i == `EXE_SLT_OP) ) 
											 ? (~reg2_i)+1 : reg2_i;

	assign result_sum = reg1_i + reg2_i_mux;
			
	//(3）计算是否溢出，加法指令(add和addi）、减法指令(sub）执行的时候，需要判断是否溢出，满足以下两种情况之一时，有溢出：
	//A. regl_i为正数, reg2_i_mux为正数,但是两者之和为负数
	//B.reg1i为负数,reg2imux为负数,但是两者之和为正数
    assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31])); 
    
    //(4)计算操作数1是否小于操作数2，分两种情况：
    //A.aluoP_i为EXE_SLT_OP表示有符号比较运算,此时又分3种情况
    //A1. regl i为负数、reg2_i为正数, 显然regl_i小于reg2_i
    //A2. regl_i为正数、reg2_i为正数,并且regl_i减去reg2_i的值小于0(即result_sum为负),此时也有regl_i小于reg2_i
    //A3. regl_i为负数、reg2_i为负数,并且regl_i减去reg2_i的值小于0(即result_sum为负),此时也有regl_i小于reg2_i
    //B、无符号数比较的时候，直接使用比较运算符比较regl_i与reg2_i
    	assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)) ?
												 ((reg1_i[31] && !reg2_i[31]) || 
												 (!reg1_i[31] && !reg2_i[31] && result_sum[31])||
			                   (reg1_i[31] && reg2_i[31] && result_sum[31]))
			                   :	(reg1_i < reg2_i);
    
    //依据不同的算术运算类型，给arithmeticres变量赋值
    always @ (*) begin
		if(rst == `RstEnable) begin
			arithmeticres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLT_OP, `EXE_SLTU_OP:		begin
					arithmeticres <= reg1_lt_reg2 ;
				end
				`EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:		begin
					arithmeticres <= result_sum; 
				end
				`EXE_SUB_OP, `EXE_SUBU_OP:		begin
					arithmeticres <= result_sum; 
				end	
				default:				begin
					arithmeticres <= `ZeroWord;
				end
			endcase
		end
	end	
    
 always @ (*) begin
	 wd_o <= wd_i;	 	
	 //如果是add、addi、sub、subi指令,且发生溢出,那么设置wreg_o为WriteDisable，表示不写目的寄存器 	
	  if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || 
	      (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
	 	wreg_o <= `WriteDisable;
	 end else begin
	  wreg_o <= wreg_i;
	 end
	 case ( alusel_i ) 
	 	`EXE_RES_LOGIC:		begin       //逻辑运算
	 		wdata_o <= logicout;
	 	end
	 	`EXE_RES_SHIFT:		begin       //移位运算
	 		wdata_o <= shiftres;
	 	end	 	
	 	`EXE_RES_ARITHMETIC:	begin  //算术运算
	 		wdata_o <= arithmeticres;
	 	end
	 	default:					begin
	 		wdata_o <= `ZeroWord;
	 	end
	 endcase
 end	

endmodule