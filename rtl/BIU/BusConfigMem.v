`define SLAVE_NUMBER	8

//设备0地址范围0x50000000-0x5000007F,共128B
//拟分配给Timer
`define SLAVE_0_HADDR	25'hA00000
`define SLAVE_0_HADDR_WIDTH	25

//设备1地址范围0x50000100-0x5000017F,total 128B
//拟分配给UART
`define SLAVE_1_HADDR	25'hA00002
`define SLAVE_1_HADDR_WIDTH	25

//设备2地址范围0x60000000-0x60001FFF,total 8192B
//拟分配给VGADevice 
`define SLAVE_2_HADDR	19'h30000 
`define SLAVE_2_HADDR_WIDTH	19

//设备3地址范围0x50000080-0x500000FF,total 128B
//拟分配给KeyBoard
`define SLAVE_3_HADDR 25'hA00001
`define SLAVE_3_HADDR_WIDTH 25

//设备4地址范围0x00000000-0x0001FFFF,total 131.072KB
//拟分配给RAM(M4K)
`define SLAVE_4_HADDR 15'h0
`define SLAVE_4_HADDR_WIDTH 15

//设备5地址范围0x10000000-0x10200000,total 2MB
//FOR external sram
`define SLAVE_5_HADDR 10'h40
`define SLAVE_5_HADDR_WIDTH 10

//设备6地址范围0x20000000-0x24000000,total 64MB
//FOR external sdram
`define SLAVE_6_HADDR 5'h4
`define SLAVE_6_HADDR_WIDTH 5

`define SLAVE_7_HADDR 28'hFFFFFFB
`define SLAVE_7_HADDR_WIDTH 28