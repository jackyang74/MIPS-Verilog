`define MBUS_SLAVE_NUMBER	8
`define PBUS_SLAVE_NUMBER	8

//设备0地址范围0x1F000000-0x1F003FFF,共16KB
//拟分配给RamOnChip
`define MBUS_SLAVE_0_HADDR	18'h7C00
`define MBUS_SLAVE_0_HADDR_WIDTH	18

//设备1地址范围0x00000000-0x03FFFFFF,total 64MB
//拟分配给SDRAM
`define MBUS_SLAVE_1_HADDR	6'h0
`define MBUS_SLAVE_1_HADDR_WIDTH	6

//设备2地址范围0x040000000-0x04FFFFFF,
//拟分配给SRAM
`define MBUS_SLAVE_2_HADDR	8'h04
`define MBUS_SLAVE_2_HADDR_WIDTH	8
//设备3地址范围0x50000080-0x500000FF,total 128B
//拟分配给KeyBoard
`define MBUS_SLAVE_3_HADDR 32'hFFFFFFFF
`define MBUS_SLAVE_3_HADDR_WIDTH 32

//设备4地址范围0x00000000-0x0001FFFF,total 131.072KB
//拟分配给RAM(M4K)
`define MBUS_SLAVE_4_HADDR 32'hFFFFFFFF
`define MBUS_SLAVE_4_HADDR_WIDTH 32

//设备5地址范围0x10000000-0x10200000,total 2MB
//FOR external sram
`define MBUS_SLAVE_5_HADDR 32'hFFFFFFFF
`define MBUS_SLAVE_5_HADDR_WIDTH 32

//设备6地址范围0x20000000-0x24000000,total 64MB
//FOR external sdram
`define MBUS_SLAVE_6_HADDR 32'hFFFFFFFF
`define MBUS_SLAVE_6_HADDR_WIDTH 32

`define MBUS_SLAVE_7_HADDR 32'hFFFFFFFF
`define MBUS_SLAVE_7_HADDR_WIDTH 32




//设备0地址范围0x18000400-0x180004FF
//拟分配给GPIO
`define PBUS_SLAVE_0_HADDR	24'h180004
`define PBUS_SLAVE_0_HADDR_WIDTH	24

//设备1地址范围0x180003F8-0x180003FF,total 8B
//拟分配给UART
`define PBUS_SLAVE_1_HADDR	29'h300007F
`define PBUS_SLAVE_1_HADDR_WIDTH	29

//设备2地址范围0x18000060-0x1800006F,total 16B
//拟分配给KeyBoard
`define PBUS_SLAVE_2_HADDR	28'h1800006
`define PBUS_SLAVE_2_HADDR_WIDTH	28

//设备3地址范围0x18000070-0x1800007F,total 16B
//拟分配给RTC
`define PBUS_SLAVE_3_HADDR 28'h1800007
`define PBUS_SLAVE_3_HADDR_WIDTH 28

//设备4地址范围0x18000040-0x1800005F,total 32B
//拟分配给PIT
`define PBUS_SLAVE_4_HADDR 32'hC00002
`define PBUS_SLAVE_4_HADDR_WIDTH 27

//设备5地址范围0x18000020-0x1800002F,total 2MB
//FOR PIC Master
`define PBUS_SLAVE_5_HADDR 28'h1800002
`define PBUS_SLAVE_5_HADDR_WIDTH 28

//设备6地址范围0x180000A0-0x180000AF,total 64MB
//FOR PIC Slave
`define PBUS_SLAVE_6_HADDR 28'h180000A
`define PBUS_SLAVE_6_HADDR_WIDTH 28

`define PBUS_SLAVE_7_HADDR 32'hFFFFFFFF
`define PBUS_SLAVE_7_HADDR_WIDTH 32