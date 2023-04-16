`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/21 14:17:58
// Design Name: 
// Module Name: defines
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
//全局
`define RstEnable 1'b1  //复位信号有效
`define RstDisable 1'b0 ////复位信号无效
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1   //可以写入目的寄存器
`define WriteDisable 1'b0   //禁止写目的寄存器
`define AluOpBus 7:0       //译码段输出aluop(子类型)宽度
`define AluSelBus 2:0       //译码段输出alusel(子类型)宽度
`define InstValid 1'b0      //指令有效    
`define InstInvalid 1'b1    //指令无效  

//指令的类型，根据指令的指令码或操作码来判断是哪个指令，id译码段使用
`define EXE_AND  6'b100100
`define EXE_OR   6'b100101
`define EXE_XOR 6'b100110
`define EXE_NOR 6'b100111
`define EXE_ANDI 6'b001100
`define EXE_ORI  6'b001101
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111

`define EXE_SLL  6'b000000
`define EXE_SLLV  6'b000100
`define EXE_SRL  6'b000010
`define EXE_SRLV  6'b000110
`define EXE_SRA  6'b000011
`define EXE_SRAV  6'b000111
`define EXE_SYNC  6'b001111
`define EXE_PREF  6'b110011

`define EXE_SLT  6'b101010
`define EXE_SLTU  6'b101011
`define EXE_SLTI  6'b001010
`define EXE_SLTIU  6'b001011   
`define EXE_ADD  6'b100000
`define EXE_ADDU  6'b100001
`define EXE_SUB  6'b100010
`define EXE_SUBU  6'b100011
`define EXE_ADDI  6'b001000
`define EXE_ADDIU  6'b001001





//不同指令，某些实现过程相同，例如or与ori(imm赋给reg1)，reg1、2移位结果放于目的寄存器
//就是用来根据运算子类型写运算过程，ex执行段使用
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP  8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP  8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP  8'b01011100   

`define EXE_SLL_OP  8'b01111100
`define EXE_SLLV_OP  8'b00000100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRLV_OP  8'b00000110
`define EXE_SRA_OP  8'b00000011
`define EXE_SRAV_OP  8'b00000111


`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_SLTI_OP  8'b01010111
`define EXE_SLTIU_OP  8'b01011000   
`define EXE_ADD_OP  8'b00100000
`define EXE_ADDU_OP  8'b00100001
`define EXE_SUB_OP  8'b00100010
`define EXE_SUBU_OP  8'b00100011
`define EXE_ADDI_OP  8'b01010101
`define EXE_ADDIU_OP  8'b01010110



//指令运算的类型（逻辑，移位，算术），据此来赋值给目的数据，选择一个运算结果作为最终结果
//ex执行段使用
`define EXE_RES_LOGIC 3'b001  
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_ARITHMETIC 3'b100	


//指令存储器inst_rom
`define InstAddrBus 31:0
`define InstBus 31:0

//通用寄存器regfile
`define RegAddrBus 4:0  //地址寄存器位
`define RegBus 31:0 //寄存器位


