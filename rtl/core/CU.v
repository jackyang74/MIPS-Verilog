`include "CPUConstants.v"
module CU(
	input pause,
	input [31:0]id_instr,
	input ex_memtoreg,
	input id_bpu_wen_h,
	input [4:0]ex_regdst_addr,
	output pa_pc_ifid_o,
	output wash_ifid_o,
	output pa_idexmemwr_o,
	output wash_idex_o,
	output wash_exmem_o,
	output wash_memwr_o,
	// output reg cu_intr,
	input cp0_interrupt_i,
	input cp0_exception_tlb_i,
	input cp0_exception_tlb_byinstr_i
);


reg pa_pc_ifid,pa_idexmemwr;
reg wash_idex,wash_exmem,wash_memwr,wash_ifid;



	wire rt_en;	//rt寄存器地址是否有效
	wire rs_en;	//rs寄存器地址是否有效
	wire load_use;	//是否存在Load-Use冒险
	
	wire is_branch;	//是否为branch指令
	
	wire [4:0]id_rt = id_instr[20:16];
	wire [4:0]id_rs = id_instr[25:21];
	wire [5:0]id_op = id_instr[31:26];
	wire [5:0]id_tail = id_instr[5:0];
	wire instr_ERET = (id_op == `OP_COP0 && id_tail == `TAIL_ERET);
	wire instr_SYSCALL = (id_op == `OP_SPECIAL && id_tail == `TAIL_SYSCALL);
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
				if(instr_SYSCALL || instr_ERET || cp0_exception_tlb_i)
					wash_ifid = 1'b1;
				else
				begin
					if(cp0_interrupt_i)
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
	
	//wash_idex的生成优先级：外部暂停 > Load-Use,data TLB exception > 其他
	always@(*)
	begin
		if(pause == 1'b1)
			wash_idex = 1'b0;
		else 
			if((cp0_exception_tlb_i && !cp0_exception_tlb_byinstr_i) || load_use)
				wash_idex =1'b1;
			else
				wash_idex = 1'b0;
	end
	//wash_exmem,wash_memwr的生成优先级：外部暂停 > data TLB exception > 其他
	always@(*)
	begin
		wash_exmem = 0;
		wash_memwr = 0;
		if(!pause)
			begin
				if(cp0_exception_tlb_i && !cp0_exception_tlb_byinstr_i)
					begin
						wash_exmem = 1'b1;
						wash_memwr = 1'b1;
					end
			end
	end
	
	
	//intr_en_o的生成
	// always@(*)
	// begin
		// if((pause == 1'b1) || (load_use == 1'b1) ||	instr_SYSCALL || instr_ERET)
			// cu_intr = 1'b0;
		// else
		// begin
			// if((cp0_interrupt_i == 1'b1) && (status_out[0] == 1'b1))
				// cu_intr = 1'b1;
			// else
				// cu_intr = 1'b0;
		// end
	// end
	assign pa_pc_ifid_o = pa_pc_ifid;
	assign wash_idex_o = wash_idex;
	assign wash_ifid_o = wash_ifid;
	assign pa_idexmemwr_o = pa_idexmemwr;
	assign wash_exmem_o = wash_exmem;
	assign wash_memwr_o = wash_memwr;
endmodule
