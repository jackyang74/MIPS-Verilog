`include "CPUConstants.v"
module CU(
	input pause,
	input intr,
	input [31:0]status_out,
	input [31:0]id_instr,
	input ex_memtoreg,
	input id_bpu_wen_h,
	input [4:0]ex_regdst_addr,
	output reg pa_pc_ifid,
	output reg wash_ifid,
	output reg pa_idexmemwr,
	output reg wash_idex,
	output reg cu_intr
);

	wire [4:0] id_rt;
	wire [4:0] id_rs;
	wire [5:0] id_op;
	wire [5:0] id_tail;
	
	wire rt_en;	//rt寄存器地址是否有效
	wire rs_en;	//rs寄存器地址是否有效
	wire load_use;	//是否存在Load-Use冒险
	
	wire is_branch;	//是否为branch指令
	
	assign id_rt[4:0] = id_instr[20:16];
	assign id_rs[4:0] = id_instr[25:21];
	assign id_op[5:0] = id_instr[31:26];
	assign id_tail[5:0] = id_instr[5:0];
	
	//ADD、ADDU、SLT、SLTU、SUB、SUBU、AND、NOR、OR、XOR、SW、SLL、SLLV、SRA、SRAV、SRL、SRLV、BEQ、BNE、MTC0中的某一条
	assign rt_en = ((id_op == `OP_SPECIAL) && ((id_tail == `TAIL_ADD) || (id_tail == `TAIL_ADDU) || (id_tail == `TAIL_SUB) ||
						(id_tail == `TAIL_SUBU) || (id_tail == `TAIL_SLT) || (id_tail == `TAIL_SLTU) || (id_tail == `TAIL_AND) ||
						(id_tail == `TAIL_NOR) || (id_tail == `TAIL_OR) || (id_tail == `TAIL_XOR) || (id_tail == `TAIL_SLL) ||
						(id_tail == `TAIL_SLLV) || (id_tail == `TAIL_SRA) || (id_tail == `TAIL_SRAV) || (id_tail == `TAIL_SRL) ||
						(id_tail == `TAIL_SRLV))) || (id_op == `OP_SW) || (id_op == `OP_BEQ) || (id_op == `OP_BNE) ||
						((id_op == `OP_COP0) && (id_rs == `RS_MT));
	
	//ADD、ADDU、CLO、CLZ、SLT、SLTU、SUB、SUBU、AND、NOR、OR、XOR、Jr、LW、SW、
	//SLLV、SRAV、SRLV、BEQ、BNE、BGEZ、BLTZ、BGTZ、BLEZ、ADDI、ADDIU、SLTI、SLTIU、ANDI、ORI、XORI中的某一条
	assign rs_en = ((id_op == `OP_SPECIAL) && ((id_tail == `TAIL_ADD) || (id_tail == `TAIL_ADDU) || (id_tail == `TAIL_SUB) ||
						(id_tail == `TAIL_SUBU) || (id_tail == `TAIL_SLT) || (id_tail == `TAIL_SLTU) || (id_tail == `TAIL_AND) ||
						(id_tail == `TAIL_NOR) || (id_tail == `TAIL_OR) || (id_tail == `TAIL_XOR) || (id_tail == `TAIL_SLLV) ||
						(id_tail == `TAIL_SRAV) || (id_tail == `TAIL_SRLV) || (id_tail == `TAIL_JR))) ||
						((id_op == `OP_SPECIAL2) && ((id_tail == `TAIL_CLO) || (id_tail == `TAIL_CLZ))) ||
						((id_op == `OP_REGIMM) && ((id_rt == `RT_BGEZ) || (id_rt == `RT_BLTZ))) ||
						(id_op == `OP_LW) || (id_op == `OP_SW) || (id_op == `OP_BEQ) || (id_op == `OP_BNE) ||
						(id_op == `OP_BGTZ) || (id_op == `OP_BLEZ) || (id_op == `OP_ADDI) || (id_op == `OP_ADDIU) ||
						(id_op == `OP_SLTI) || (id_op == `OP_SLTIU) || (id_op == `OP_ANDI) || (id_op == `OP_ORI) ||
						(id_op == `OP_XORI);
	//上一条指令写入的寄存器在下一条被读出
	assign load_use = ex_memtoreg &
							(((id_rt == ex_regdst_addr) & rt_en) |
							((id_rs == ex_regdst_addr) & rs_en));
	
	//是否为branch指令
	assign is_branch = ((id_op == `OP_SPECIAL) && (id_tail == `TAIL_JR)) || (id_op == `OP_J) ||
							 ((id_op == `OP_REGIMM) && ((id_rt == `RT_BGEZ) || (id_rt == `RT_BLTZ))) ||
							 (id_op == `OP_BEQ) || (id_op == `OP_BNE) || (id_op == `OP_BGTZ) || (id_op == `OP_BLEZ) || (id_op == `OP_JAL);
	
	//pa_pcifid_o生成的优先级：外部暂停 > Load-Use > 其他
	always@(*)
	begin
		if(pause == 1'b1)
			pa_pc_ifid = 1'b1;
		else if(load_use == 1'b1)
			pa_pc_ifid = 1'b1;
		else
			pa_pc_ifid = 1'b0;
	end
	
	//pa_idexmemwr_o生成的优先级：外部暂停 > 其他
	always@(*)
	begin
		if(pause == 1'b1)
			pa_idexmemwr = 1'b1;
		else
			pa_idexmemwr = 1'b0;
	end
	
	//wash_ifid_o生成的优先级：外部暂停 > Load-Use > SYSCALL、ERET > 外部中断 > 其他
	always@(*)
	begin
		if(pause == 1'b1)
			wash_ifid = 1'b0;
		else
		begin
			if(load_use == 1'b1)
				wash_ifid = 1'b0;
			else
			begin
				if(((status_out[1] == 1'b1) && (id_op == `OP_SPECIAL) && (id_tail == `TAIL_SYSCALL)) ||
					((id_op == `OP_COP0) && (id_tail == `TAIL_ERET)))
					wash_ifid = 1'b1;
				else
				begin
					if((intr == 1'b1) && (status_out[0] == 1'b1))
						wash_ifid = 1'b1;
					else
					begin
						if((is_branch == 1'b1) && (id_bpu_wen_h == 1'b1))
							wash_ifid = 1'b1;
						else
							wash_ifid = 1'b0;
					end
				end
			end
		end
	end
	
	//wash_idex_o的生成优先级：外部暂停 > Load-Use > 其他
	always@(*)
	begin
		if(pause == 1'b1)
			wash_idex = 1'b0;
		else if(load_use == 1'b1)
			wash_idex = 1'b1;
		else
			wash_idex = 1'b0;
	end
	
	//intr_en_o的生成
	always@(*)
	begin
		if((pause == 1'b1) || (load_use == 1'b1) ||
			((status_out[1] == 1'b1) && (id_op == `OP_SPECIAL) && (id_tail == `TAIL_SYSCALL)) ||
			((id_op == `OP_COP0) && (id_tail == `TAIL_ERET)))
			cu_intr = 1'b0;
		else
		begin
			if((intr == 1'b1) && (status_out[0] == 1'b1))
				cu_intr = 1'b1;
			else
				cu_intr = 1'b0;
		end
	end
endmodule
