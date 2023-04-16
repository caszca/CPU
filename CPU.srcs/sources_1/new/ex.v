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

	//����׶��͵�ִ�н׶ε���Ϣ
	input wire[7:0]         aluop_i, 
	input wire[`AluSelBus]        alusel_i,
	input wire[`RegBus]     reg1_i, //Դ������1
	input wire[`RegBus]     reg2_i,  //Դ������2
	input wire[`RegAddrBus] wd_i,   //Ŀ�ļĴ�����ַ
	input wire   wreg_i,  //�Ƿ�д��Ŀ�ļĴ���


	output reg[`RegAddrBus]  wd_o,  //����д��Ŀ�ļĴ�����ַ
	output reg     wreg_o,       //ִ����������Ƿ�д��Ŀ�ļĴ������Ӽ������ʱ��������Ϊ0����д��Ĵ���
	output reg[`RegBus]    wdata_o  //ִ������������
	
);

    wire[`RegBus] reg2_i_mux;//�����Ĵ���Reg2�Ĳ������Դ�룬�����
    wire ov_sum;//�Ƿ�������
    wire[`RegBus] result_sum;   //�����ӷ�����������
    wire reg1_lt_reg2;  //��һ���������Ƿ�С�ڵڶ���������
    
    reg[`RegBus] arithmeticres;//��������������
	reg[`RegBus] logicout;   //�߼����㱣��ֵ
	reg[`RegBus] shiftres;     //��λ���㱣��ֵ
		
	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)//�߼�����
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
				//��Ҫ��չ6λʮ���ƣ���Ϊ2^5=32����Ҫ6λ2���Ʋ��ܱ�ʾ
					shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]}))//���ƶ�λ�� 
												| reg2_i >> reg1_i[4:0];
				end
				default:				begin
					shiftres <= `ZeroWord;
				end
			endcase
		end    
	end      

//����Ǽ������з��űȽϣ���ôreg2_i_muxΪ�䱾��Ĳ��룬��֮����ԭֵ����Ϊ�������з��űȽ����ջ��������������������м�����һ�����Ĳ���
assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) ||
											 (aluop_i == `EXE_SLT_OP) ) 
											 ? (~reg2_i)+1 : reg2_i;

	assign result_sum = reg1_i + reg2_i_mux;
			
	//(3�������Ƿ�������ӷ�ָ��(add��addi��������ָ��(sub��ִ�е�ʱ����Ҫ�ж��Ƿ���������������������֮һʱ���������
	//A. regl_iΪ����, reg2_i_muxΪ����,��������֮��Ϊ����
	//B.reg1iΪ����,reg2imuxΪ����,��������֮��Ϊ����
    assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31])); 
    
    //(4)���������1�Ƿ�С�ڲ�����2�������������
    //A.aluoP_iΪEXE_SLT_OP��ʾ�з��űȽ�����,��ʱ�ַ�3�����
    //A1. regl iΪ������reg2_iΪ����, ��Ȼregl_iС��reg2_i
    //A2. regl_iΪ������reg2_iΪ����,����regl_i��ȥreg2_i��ֵС��0(��result_sumΪ��),��ʱҲ��regl_iС��reg2_i
    //A3. regl_iΪ������reg2_iΪ����,����regl_i��ȥreg2_i��ֵС��0(��result_sumΪ��),��ʱҲ��regl_iС��reg2_i
    //B���޷������Ƚϵ�ʱ��ֱ��ʹ�ñȽ�������Ƚ�regl_i��reg2_i
    	assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)) ?
												 ((reg1_i[31] && !reg2_i[31]) || 
												 (!reg1_i[31] && !reg2_i[31] && result_sum[31])||
			                   (reg1_i[31] && reg2_i[31] && result_sum[31]))
			                   :	(reg1_i < reg2_i);
    
    //���ݲ�ͬ�������������ͣ���arithmeticres������ֵ
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
	 //�����add��addi��sub��subiָ��,�ҷ������,��ô����wreg_oΪWriteDisable����ʾ��дĿ�ļĴ��� 	
	  if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || 
	      (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
	 	wreg_o <= `WriteDisable;
	 end else begin
	  wreg_o <= wreg_i;
	 end
	 case ( alusel_i ) 
	 	`EXE_RES_LOGIC:		begin       //�߼�����
	 		wdata_o <= logicout;
	 	end
	 	`EXE_RES_SHIFT:		begin       //��λ����
	 		wdata_o <= shiftres;
	 	end	 	
	 	`EXE_RES_ARITHMETIC:	begin  //��������
	 		wdata_o <= arithmeticres;
	 	end
	 	default:					begin
	 		wdata_o <= `ZeroWord;
	 	end
	 endcase
 end	

endmodule