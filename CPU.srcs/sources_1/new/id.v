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
	input wire[`InstBus]   inst_i,  //ָ��
    input wire[`RegBus]    reg1_data_i,//�Ĵ�����������,��ֵ��Դ������
	input wire[`RegBus]    reg2_data_i,//�Ĵ�������������
	
	//����ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
	input wire		ex_wreg_i,
	input wire[`RegBus]		ex_wdata_i,
	input wire[`RegAddrBus]     ex_wd_i,
	
	//���ڷô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
	input wire	    mem_wreg_i,  //�Ƿ�д��Ŀ�ļĴ���
	input wire[`RegBus]		mem_wdata_i,  //д��Ŀ�ļĴ�������
	input wire[`RegAddrBus]     mem_wd_i,   //д��Ŀ�ļĴ����ĵ�ַ
	
	

	//�͵�regfile����Ϣ
	output reg     reg1_read_o,  //�Ƿ��ȡreg1ʹ���ź�
	output reg     reg2_read_o,  //�Ƿ��ȡreg2ʹ���ź�
	output reg[`RegAddrBus]     reg1_addr_o,  //��ȡreg1�ĵ�ַ
	output reg[`RegAddrBus]     reg2_addr_o, 	//��ȡreg2�ĵ�ַ
	
	//�͵�ִ�н׶ε���Ϣ
	output reg[7:0]  aluop_o,   //��ָͬ�ʵ�ֹ�����ͬ������or��ori(imm����reg1)��reg1��2��λ�������Ŀ�ļĴ���
	output reg[`AluSelBus] alusel_o, //���ո���ָ����������ò�ͬ�Ѿ�������Ľ��д��Ŀ�����ݱ�����
	output reg[`RegBus]    reg1_o,  //��һ��Դ������
	output reg[`RegBus]    reg2_o, //�ڶ���Դ������
	output reg[`RegAddrBus]    wd_o,   //д��Ŀ�ļĴ����ĵ�ַ��Ĭ��ȡ11~15λ��������ָ�����Ͳ�ͬȡ��ͬλ
	output reg     wreg_o  //�Ƿ�д��Ŀ�ļĴ���
);

  wire[5:0] op = inst_i[31:26]; 
  wire[4:0] op2 = inst_i[10:6];//�п���Ϊȫ0
  wire[5:0] op3 = inst_i[5:0]; //R�����ж�

  reg[`RegBus]	imm;   //������
  reg instvalid;   //ָ���Ƿ���Ч
  
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
			wd_o <= inst_i[15:11];   //Ĭ��Ŀ�ļĴ���������ָ��ɸ���
			wreg_o <= `WriteDisable;  //Ĭ�ϲ���д��Ŀ�ļĴ���
			instvalid <= `InstInvalid;	   //ָ����Ч
			reg1_read_o <= 1'b0;         //Ĭ�ϲ��ܶ�reg1ʹ���ź�
			reg2_read_o <= 1'b0;         //Ĭ�ϲ��ܶ�reg2ʹ���ź�
			reg1_addr_o <= inst_i[25:21]; //Ĭ�϶�ȡ��reg1��ַ
			reg2_addr_o <= inst_i[20:16]; ////Ĭ�϶�ȡ��reg2��ַ
			imm <= `ZeroWord;
		  case (op)
		    6'b000000:	begin
		    	case (op2)
		    		5'b00000:	begin
		    			case (op3)
		    				`EXE_OR:  begin       //orָ��
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  						alusel_o <= `EXE_RES_LOGIC; 	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end  
		    				`EXE_AND:	begin       //andָ��
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;
		  						alusel_o <= `EXE_RES_LOGIC;	  reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end  	
		    				`EXE_XOR:	begin       //xorָ��
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end  				
		    				`EXE_NOR:	begin       //norָ��
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_NOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end 
								`EXE_SLLV: begin        //sllvָ��
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end 
								`EXE_SRLV: begin        //srlvָ��
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end 					
								`EXE_SRAV: begin        //sravָ��
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;			
		  						end			
								
								`EXE_SLT: begin     //sltָ��
								    wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLT_OP;
								 alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
								 instvalid <= `InstValid;	
								end
								
								`EXE_SLTU: begin        //sltuָ��
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLTU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								
								`EXE_ADD: begin         //addָ��
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADD_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								
								`EXE_ADDU: begin        //adduָ��
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADDU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								
								`EXE_SUB: begin     //subָ��
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SUB_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								
								`EXE_SUBU: begin        //subuָ��
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
		  	`EXE_ORI:	begin     //ORIָ��
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];//Ŀ�ļĴ���
					instvalid <= `InstValid;	
		  	end
		  	`EXE_ANDI:	begin     //andiָ��
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end	 	
		  	`EXE_XORI:	begin     //xoriָ��
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end	 		
		  	`EXE_LUI:	begin      //luiָ��
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {inst_i[15:0], 16'h0};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end		
				
				//����ָ��
				`EXE_SLTI:	begin      //sltiָ��
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLT_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end
				`EXE_SLTIU:	begin     //sltiuָ��
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLTU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end
				`EXE_ADDI:	begin      //addiָ��
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADDI_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end
				`EXE_ADDIU:	begin    //addiuָ��
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADDIU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end								  	
		    default:	begin
		    end
		  endcase		  //case op
		  
		  //��λָ��Ĵ���1��Ϊ�������Ĵ�����ע��������ָ�������λ��
		  if (inst_i[31:21] == 11'b00000000000) begin
		  	if (op3 == `EXE_SLL) begin          //sllָ��
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end else if ( op3 == `EXE_SRL ) begin   //srlָ��
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end else if ( op3 == `EXE_SRA ) begin   //sraָ��
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end
			end		  
		  
		end      
	end        
	
    //�Ĵ���һ�Ĳ���
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;//ԭ������һ	
		end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) //ִ�н׶�����ǰ�ƣ���ǰָ���ȡ�ļĴ�������ǰ��ָ��Ҫд��ļĴ�����raw���
								&& (ex_wd_i == reg1_addr_o)) begin
			reg1_o <= ex_wdata_i;    //ֱ�ӽ�Ҫд������ݽ���ԭ������һ
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) //�ô�׶�����ǰ��
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
    //�Ĵ������Ĳ���
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;//ԭ��������
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
