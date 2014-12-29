// 
//

module c5sx_soc(

	//  Interface to the HPS

//	input  wire        reset_reset_n,                         //           reset.reset_n
//	input  wire        clk_clk,                               //             clk.clk
	output wire [14:0] memory_mem_a,                          //          memory.mem_a
	output wire [2:0]  memory_mem_ba,                         //                .mem_ba
	output wire        memory_mem_ck,                         //                .mem_ck
	output wire        memory_mem_ck_n,                       //                .mem_ck_n
	output wire        memory_mem_cke,                        //                .mem_cke
	output wire        memory_mem_cs_n,                       //                .mem_cs_n
	output wire        memory_mem_ras_n,                      //                .mem_ras_n
	output wire        memory_mem_cas_n,                      //                .mem_cas_n
	output wire        memory_mem_we_n,                       //                .mem_we_n
	output wire        memory_mem_reset_n,                    //                .mem_reset_n
	inout  wire [31:0] memory_mem_dq,                         //                .mem_dq
	inout  wire [3:0]  memory_mem_dqs,                        //                .mem_dqs
	inout  wire [3:0]  memory_mem_dqs_n,                      //                .mem_dqs_n
	output wire        memory_mem_odt,                        //                .mem_odt
	output wire [3:0]  memory_mem_dm,                         //                .mem_dm
	input  wire        memory_oct_rzqin,                      //                .oct_rzqin
	output wire        hps_0_hps_io_hps_io_emac1_inst_TX_CLK, //    hps_0_hps_io.hps_io_emac1_inst_TX_CLK
	output wire        hps_0_hps_io_hps_io_emac1_inst_TXD0,   //                .hps_io_emac1_inst_TXD0
	output wire        hps_0_hps_io_hps_io_emac1_inst_TXD1,   //                .hps_io_emac1_inst_TXD1
	output wire        hps_0_hps_io_hps_io_emac1_inst_TXD2,   //                .hps_io_emac1_inst_TXD2
	output wire        hps_0_hps_io_hps_io_emac1_inst_TXD3,   //                .hps_io_emac1_inst_TXD3
	input  wire        hps_0_hps_io_hps_io_emac1_inst_RXD0,   //                .hps_io_emac1_inst_RXD0
	inout  wire        hps_0_hps_io_hps_io_emac1_inst_MDIO,   //                .hps_io_emac1_inst_MDIO
	output wire        hps_0_hps_io_hps_io_emac1_inst_MDC,    //                .hps_io_emac1_inst_MDC
	input  wire        hps_0_hps_io_hps_io_emac1_inst_RX_CTL, //                .hps_io_emac1_inst_RX_CTL
	output wire        hps_0_hps_io_hps_io_emac1_inst_TX_CTL, //                .hps_io_emac1_inst_TX_CTL
	input  wire        hps_0_hps_io_hps_io_emac1_inst_RX_CLK, //                .hps_io_emac1_inst_RX_CLK
	input  wire        hps_0_hps_io_hps_io_emac1_inst_RXD1,   //                .hps_io_emac1_inst_RXD1
	input  wire        hps_0_hps_io_hps_io_emac1_inst_RXD2,   //                .hps_io_emac1_inst_RXD2
	input  wire        hps_0_hps_io_hps_io_emac1_inst_RXD3,   //                .hps_io_emac1_inst_RXD3
	inout  wire        hps_0_hps_io_hps_io_qspi_inst_IO0,     //                .hps_io_qspi_inst_IO0
	inout  wire        hps_0_hps_io_hps_io_qspi_inst_IO1,     //                .hps_io_qspi_inst_IO1
	inout  wire        hps_0_hps_io_hps_io_qspi_inst_IO2,     //                .hps_io_qspi_inst_IO2
	inout  wire        hps_0_hps_io_hps_io_qspi_inst_IO3,     //                .hps_io_qspi_inst_IO3
	output wire        hps_0_hps_io_hps_io_qspi_inst_SS0,     //                .hps_io_qspi_inst_SS0
	output wire        hps_0_hps_io_hps_io_qspi_inst_CLK,     //                .hps_io_qspi_inst_CLK
	inout  wire        hps_0_hps_io_hps_io_sdio_inst_CMD,     //                .hps_io_sdio_inst_CMD
	inout  wire        hps_0_hps_io_hps_io_sdio_inst_D0,      //                .hps_io_sdio_inst_D0
	inout  wire        hps_0_hps_io_hps_io_sdio_inst_D1,      //                .hps_io_sdio_inst_D1
	output wire        hps_0_hps_io_hps_io_sdio_inst_CLK,     //                .hps_io_sdio_inst_CLK
	inout  wire        hps_0_hps_io_hps_io_sdio_inst_D2,      //                .hps_io_sdio_inst_D2
	inout  wire        hps_0_hps_io_hps_io_sdio_inst_D3,      //                .hps_io_sdio_inst_D3
	inout  wire        hps_0_hps_io_hps_io_usb1_inst_D0,      //                .hps_io_usb1_inst_D0
	inout  wire        hps_0_hps_io_hps_io_usb1_inst_D1,      //                .hps_io_usb1_inst_D1
	inout  wire        hps_0_hps_io_hps_io_usb1_inst_D2,      //                .hps_io_usb1_inst_D2
	inout  wire        hps_0_hps_io_hps_io_usb1_inst_D3,      //                .hps_io_usb1_inst_D3
	inout  wire        hps_0_hps_io_hps_io_usb1_inst_D4,      //                .hps_io_usb1_inst_D4
	inout  wire        hps_0_hps_io_hps_io_usb1_inst_D5,      //                .hps_io_usb1_inst_D5
	inout  wire        hps_0_hps_io_hps_io_usb1_inst_D6,      //                .hps_io_usb1_inst_D6
	inout  wire        hps_0_hps_io_hps_io_usb1_inst_D7,      //                .hps_io_usb1_inst_D7
	input  wire        hps_0_hps_io_hps_io_usb1_inst_CLK,     //                .hps_io_usb1_inst_CLK
	output wire        hps_0_hps_io_hps_io_usb1_inst_STP,     //                .hps_io_usb1_inst_STP
	input  wire        hps_0_hps_io_hps_io_usb1_inst_DIR,     //                .hps_io_usb1_inst_DIR
	input  wire        hps_0_hps_io_hps_io_usb1_inst_NXT,     //                .hps_io_usb1_inst_NXT
	output wire        hps_0_hps_io_hps_io_spim0_inst_CLK,    //                .hps_io_spim0_inst_CLK
	output wire        hps_0_hps_io_hps_io_spim0_inst_MOSI,   //                .hps_io_spim0_inst_MOSI
	input  wire        hps_0_hps_io_hps_io_spim0_inst_MISO,   //                .hps_io_spim0_inst_MISO
	output wire        hps_0_hps_io_hps_io_spim0_inst_SS0,    //                .hps_io_spim0_inst_SS0
	output wire        hps_0_hps_io_hps_io_spim1_inst_CLK,    //                .hps_io_spim1_inst_CLK
	output wire        hps_0_hps_io_hps_io_spim1_inst_MOSI,   //                .hps_io_spim1_inst_MOSI
	input  wire        hps_0_hps_io_hps_io_spim1_inst_MISO,   //                .hps_io_spim1_inst_MISO
	output wire        hps_0_hps_io_hps_io_spim1_inst_SS0,    //                .hps_io_spim1_inst_SS0
	input  wire        hps_0_hps_io_hps_io_uart0_inst_RX,     //                .hps_io_uart0_inst_RX
	output wire        hps_0_hps_io_hps_io_uart0_inst_TX,     //                .hps_io_uart0_inst_TX
	inout  wire        hps_0_hps_io_hps_io_i2c1_inst_SDA,     //                .hps_io_i2c1_inst_SDA
	inout  wire        hps_0_hps_io_hps_io_i2c1_inst_SCL,     //                .hps_io_i2c1_inst_SCL
	inout  wire        hps_0_hps_io_hps_io_gpio_inst_GPIO00,  //                .hps_io_gpio_inst_GPIO00
	inout  wire        hps_0_hps_io_hps_io_gpio_inst_GPIO09,  //                .hps_io_gpio_inst_GPIO09
	inout  wire        hps_0_hps_io_hps_io_gpio_inst_GPIO35,  //                .hps_io_gpio_inst_GPIO35
	inout  wire        hps_0_hps_io_hps_io_gpio_inst_GPIO48,  //                .hps_io_gpio_inst_GPIO48
	inout  wire        hps_0_hps_io_hps_io_gpio_inst_GPIO53,  //                .hps_io_gpio_inst_GPIO53
	inout  wire        hps_0_hps_io_hps_io_gpio_inst_GPIO54,  //                .hps_io_gpio_inst_GPIO54
	inout  wire        hps_0_hps_io_hps_io_gpio_inst_GPIO55,  //                .hps_io_gpio_inst_GPIO55
	inout  wire        hps_0_hps_io_hps_io_gpio_inst_GPIO56,  //                .hps_io_gpio_inst_GPIO56
	inout  wire        hps_0_hps_io_hps_io_gpio_inst_GPIO61,  //                .hps_io_gpio_inst_GPIO61
	inout  wire        hps_0_hps_io_hps_io_gpio_inst_GPIO62,   //                .hps_io_gpio_inst_GPIO62

	//  Interface to the FPGA side
	
	//FPGA-GPLL-CLK------------------------//X pins
	input          clk_100m_fpga,       //2.5V    //100 MHz (2nd copy to max)
   input          clk_50m_fpga,        //2.5V    //50MHz (2nd copy to max) 
	input          clk_top1,            //2.5V    //156.25 MHz adjustable
   input          clk_bot1,            //1.5V    //100 MHz ajustable
	input          fpga_resetn,          //2.5V    //FPGA Reset Pushbutton	

	//////////////////// SiLabs Clock Generator I/F 	///////////////////  	   	   	   	   	   	
   output   wire  clk_i2c_sclk,             // I2C Clock 
   inout    wire  clk_i2c_sdat,             // I2C Data 
	
	//  The FPGA Diagnostic LEDs
	output [3:0]	user_led_fpga,

	//  Input signals from SDRStick HF2
	input wire signed [15:0] INA,
	output wire RAND,
	input wire OVFLA,
	output wire PGA,
	output wire DITHER,
	output wire DRV_CLK_OUT_N,
	input wire CLK_122_88MHz,
	input wire ADC_CLKA,
	output wire RX_SPI_DATA,
	output wire RX_SPI_CLK,
	output wire ATTN_LE
   
);
    
// internal wires and registers declaration
  wire [3:0] fpga_led_internal;
  wire       hps_fpga_reset_n;

// connection of internal logics
//  assign user_led_fpga = ~fpga_led_internal;
  assign user_led_fpga = fpga_led_internal;
	 
	 wire [15:0] signal;
	 
	siggen siggen_inst (
		.clk (ADC_CLKA),
		.reset (hps_fpga_reset_n),
		.signal (signal)
	);
	 
 
    soc_system u0 (
        .clk_clk                               (clk_bot1),                          	 //             clk.clk
        .reset_reset_n                         (hps_fpga_reset_n),                      //           reset.reset_n
        .memory_mem_a                          (memory_mem_a),                          //          memory.mem_a
        .memory_mem_ba                         (memory_mem_ba),                         //                .mem_ba
        .memory_mem_ck                         (memory_mem_ck),                         //                .mem_ck
        .memory_mem_ck_n                       (memory_mem_ck_n),                       //                .mem_ck_n
        .memory_mem_cke                        (memory_mem_cke),                        //                .mem_cke
        .memory_mem_cs_n                       (memory_mem_cs_n),                       //                .mem_cs_n
        .memory_mem_ras_n                      (memory_mem_ras_n),                      //                .mem_ras_n
        .memory_mem_cas_n                      (memory_mem_cas_n),                      //                .mem_cas_n
        .memory_mem_we_n                       (memory_mem_we_n),                       //                .mem_we_n
        .memory_mem_reset_n                    (memory_mem_reset_n),                    //                .mem_reset_n
        .memory_mem_dq                         (memory_mem_dq),                         //                .mem_dq
        .memory_mem_dqs                        (memory_mem_dqs),                        //                .mem_dqs
        .memory_mem_dqs_n                      (memory_mem_dqs_n),                      //                .mem_dqs_n
        .memory_mem_odt                        (memory_mem_odt),                        //                .mem_odt
        .memory_mem_dm                         (memory_mem_dm),                         //                .mem_dm
        .memory_oct_rzqin                      (memory_oct_rzqin),                      //                .oct_rzqin
        .hps_0_hps_io_hps_io_emac1_inst_TX_CLK (hps_0_hps_io_hps_io_emac1_inst_TX_CLK), //    hps_0_hps_io.hps_io_emac1_inst_TX_CLK
        .hps_0_hps_io_hps_io_emac1_inst_TXD0   (hps_0_hps_io_hps_io_emac1_inst_TXD0),   //                .hps_io_emac1_inst_TXD0
        .hps_0_hps_io_hps_io_emac1_inst_TXD1   (hps_0_hps_io_hps_io_emac1_inst_TXD1),   //                .hps_io_emac1_inst_TXD1
        .hps_0_hps_io_hps_io_emac1_inst_TXD2   (hps_0_hps_io_hps_io_emac1_inst_TXD2),   //                .hps_io_emac1_inst_TXD2
        .hps_0_hps_io_hps_io_emac1_inst_TXD3   (hps_0_hps_io_hps_io_emac1_inst_TXD3),   //                .hps_io_emac1_inst_TXD3
        .hps_0_hps_io_hps_io_emac1_inst_RXD0   (hps_0_hps_io_hps_io_emac1_inst_RXD0),   //                .hps_io_emac1_inst_RXD0
        .hps_0_hps_io_hps_io_emac1_inst_MDIO   (hps_0_hps_io_hps_io_emac1_inst_MDIO),   //                .hps_io_emac1_inst_MDIO
        .hps_0_hps_io_hps_io_emac1_inst_MDC    (hps_0_hps_io_hps_io_emac1_inst_MDC),    //                .hps_io_emac1_inst_MDC
        .hps_0_hps_io_hps_io_emac1_inst_RX_CTL (hps_0_hps_io_hps_io_emac1_inst_RX_CTL), //                .hps_io_emac1_inst_RX_CTL
        .hps_0_hps_io_hps_io_emac1_inst_TX_CTL (hps_0_hps_io_hps_io_emac1_inst_TX_CTL), //                .hps_io_emac1_inst_TX_CTL
        .hps_0_hps_io_hps_io_emac1_inst_RX_CLK (hps_0_hps_io_hps_io_emac1_inst_RX_CLK), //                .hps_io_emac1_inst_RX_CLK
        .hps_0_hps_io_hps_io_emac1_inst_RXD1   (hps_0_hps_io_hps_io_emac1_inst_RXD1),   //                .hps_io_emac1_inst_RXD1
        .hps_0_hps_io_hps_io_emac1_inst_RXD2   (hps_0_hps_io_hps_io_emac1_inst_RXD2),   //                .hps_io_emac1_inst_RXD2
        .hps_0_hps_io_hps_io_emac1_inst_RXD3   (hps_0_hps_io_hps_io_emac1_inst_RXD3),   //                .hps_io_emac1_inst_RXD3
        .hps_0_hps_io_hps_io_qspi_inst_IO0     (hps_0_hps_io_hps_io_qspi_inst_IO0),     //                .hps_io_qspi_inst_IO0
        .hps_0_hps_io_hps_io_qspi_inst_IO1     (hps_0_hps_io_hps_io_qspi_inst_IO1),     //                .hps_io_qspi_inst_IO1
        .hps_0_hps_io_hps_io_qspi_inst_IO2     (hps_0_hps_io_hps_io_qspi_inst_IO2),     //                .hps_io_qspi_inst_IO2
        .hps_0_hps_io_hps_io_qspi_inst_IO3     (hps_0_hps_io_hps_io_qspi_inst_IO3),     //                .hps_io_qspi_inst_IO3
        .hps_0_hps_io_hps_io_qspi_inst_SS0     (hps_0_hps_io_hps_io_qspi_inst_SS0),     //                .hps_io_qspi_inst_SS0
        .hps_0_hps_io_hps_io_qspi_inst_CLK     (hps_0_hps_io_hps_io_qspi_inst_CLK),     //                .hps_io_qspi_inst_CLK
        .hps_0_hps_io_hps_io_sdio_inst_CMD     (hps_0_hps_io_hps_io_sdio_inst_CMD),     //                .hps_io_sdio_inst_CMD
        .hps_0_hps_io_hps_io_sdio_inst_D0      (hps_0_hps_io_hps_io_sdio_inst_D0),      //                .hps_io_sdio_inst_D0
        .hps_0_hps_io_hps_io_sdio_inst_D1      (hps_0_hps_io_hps_io_sdio_inst_D1),      //                .hps_io_sdio_inst_D1
        .hps_0_hps_io_hps_io_sdio_inst_CLK     (hps_0_hps_io_hps_io_sdio_inst_CLK),     //                .hps_io_sdio_inst_CLK
        .hps_0_hps_io_hps_io_sdio_inst_D2      (hps_0_hps_io_hps_io_sdio_inst_D2),      //                .hps_io_sdio_inst_D2
        .hps_0_hps_io_hps_io_sdio_inst_D3      (hps_0_hps_io_hps_io_sdio_inst_D3),      //                .hps_io_sdio_inst_D3
        .hps_0_hps_io_hps_io_usb1_inst_D0      (hps_0_hps_io_hps_io_usb1_inst_D0),      //                .hps_io_usb1_inst_D0
        .hps_0_hps_io_hps_io_usb1_inst_D1      (hps_0_hps_io_hps_io_usb1_inst_D1),      //                .hps_io_usb1_inst_D1
        .hps_0_hps_io_hps_io_usb1_inst_D2      (hps_0_hps_io_hps_io_usb1_inst_D2),      //                .hps_io_usb1_inst_D2
        .hps_0_hps_io_hps_io_usb1_inst_D3      (hps_0_hps_io_hps_io_usb1_inst_D3),      //                .hps_io_usb1_inst_D3
        .hps_0_hps_io_hps_io_usb1_inst_D4      (hps_0_hps_io_hps_io_usb1_inst_D4),      //                .hps_io_usb1_inst_D4
        .hps_0_hps_io_hps_io_usb1_inst_D5      (hps_0_hps_io_hps_io_usb1_inst_D5),      //                .hps_io_usb1_inst_D5
        .hps_0_hps_io_hps_io_usb1_inst_D6      (hps_0_hps_io_hps_io_usb1_inst_D6),      //                .hps_io_usb1_inst_D6
        .hps_0_hps_io_hps_io_usb1_inst_D7      (hps_0_hps_io_hps_io_usb1_inst_D7),      //                .hps_io_usb1_inst_D7
        .hps_0_hps_io_hps_io_usb1_inst_CLK     (hps_0_hps_io_hps_io_usb1_inst_CLK),     //                .hps_io_usb1_inst_CLK
        .hps_0_hps_io_hps_io_usb1_inst_STP     (hps_0_hps_io_hps_io_usb1_inst_STP),     //                .hps_io_usb1_inst_STP
        .hps_0_hps_io_hps_io_usb1_inst_DIR     (hps_0_hps_io_hps_io_usb1_inst_DIR),     //                .hps_io_usb1_inst_DIR
        .hps_0_hps_io_hps_io_usb1_inst_NXT     (hps_0_hps_io_hps_io_usb1_inst_NXT),     //                .hps_io_usb1_inst_NXT
        .hps_0_hps_io_hps_io_spim0_inst_CLK    (hps_0_hps_io_hps_io_spim0_inst_CLK),    //                .hps_io_spim0_inst_CLK
        .hps_0_hps_io_hps_io_spim0_inst_MOSI   (hps_0_hps_io_hps_io_spim0_inst_MOSI),   //                .hps_io_spim0_inst_MOSI
        .hps_0_hps_io_hps_io_spim0_inst_MISO   (hps_0_hps_io_hps_io_spim0_inst_MISO),   //                .hps_io_spim0_inst_MISO
        .hps_0_hps_io_hps_io_spim0_inst_SS0    (hps_0_hps_io_hps_io_spim0_inst_SS0),    //                .hps_io_spim0_inst_SS0
        .hps_0_hps_io_hps_io_spim1_inst_CLK    (hps_0_hps_io_hps_io_spim1_inst_CLK),    //                .hps_io_spim1_inst_CLK
        .hps_0_hps_io_hps_io_spim1_inst_MOSI   (hps_0_hps_io_hps_io_spim1_inst_MOSI),   //                .hps_io_spim1_inst_MOSI
        .hps_0_hps_io_hps_io_spim1_inst_MISO   (hps_0_hps_io_hps_io_spim1_inst_MISO),   //                .hps_io_spim1_inst_MISO
        .hps_0_hps_io_hps_io_spim1_inst_SS0    (hps_0_hps_io_hps_io_spim1_inst_SS0),    //                .hps_io_spim1_inst_SS0
        .hps_0_hps_io_hps_io_uart0_inst_RX     (hps_0_hps_io_hps_io_uart0_inst_RX),     //                .hps_io_uart0_inst_RX
        .hps_0_hps_io_hps_io_uart0_inst_TX     (hps_0_hps_io_hps_io_uart0_inst_TX),     //                .hps_io_uart0_inst_TX
        .hps_0_hps_io_hps_io_i2c1_inst_SDA     (hps_0_hps_io_hps_io_i2c1_inst_SDA),     //                .hps_io_i2c1_inst_SDA
        .hps_0_hps_io_hps_io_i2c1_inst_SCL     (hps_0_hps_io_hps_io_i2c1_inst_SCL),     //                .hps_io_i2c1_inst_SCL
        .hps_0_hps_io_hps_io_gpio_inst_GPIO00  (hps_0_hps_io_hps_io_gpio_inst_GPIO00),  //                .hps_io_gpio_inst_GPIO00
        .hps_0_hps_io_hps_io_gpio_inst_GPIO09  (hps_0_hps_io_hps_io_gpio_inst_GPIO09),  //                .hps_io_gpio_inst_GPIO09
        .hps_0_hps_io_hps_io_gpio_inst_GPIO35  (hps_0_hps_io_hps_io_gpio_inst_GPIO35),  //                .hps_io_gpio_inst_GPIO35
        .hps_0_hps_io_hps_io_gpio_inst_GPIO48  (hps_0_hps_io_hps_io_gpio_inst_GPIO48),  //                .hps_io_gpio_inst_GPIO48
        .hps_0_hps_io_hps_io_gpio_inst_GPIO53  (hps_0_hps_io_hps_io_gpio_inst_GPIO53),  //                .hps_io_gpio_inst_GPIO53
        .hps_0_hps_io_hps_io_gpio_inst_GPIO54  (hps_0_hps_io_hps_io_gpio_inst_GPIO54),  //                .hps_io_gpio_inst_GPIO54
        .hps_0_hps_io_hps_io_gpio_inst_GPIO55  (hps_0_hps_io_hps_io_gpio_inst_GPIO55),  //                .hps_io_gpio_inst_GPIO55
        .hps_0_hps_io_hps_io_gpio_inst_GPIO56  (hps_0_hps_io_hps_io_gpio_inst_GPIO56),  //                .hps_io_gpio_inst_GPIO56
        .hps_0_hps_io_hps_io_gpio_inst_GPIO61  (hps_0_hps_io_hps_io_gpio_inst_GPIO61),  //                .hps_io_gpio_inst_GPIO61
        .hps_0_hps_io_hps_io_gpio_inst_GPIO62  (hps_0_hps_io_hps_io_gpio_inst_GPIO62),  //                .hps_io_gpio_inst_GPIO62
		  .adc_clk_clk                           (ADC_CLKA),
        .adc_clk_reset_reset_n                 (hps_fpga_reset_n),
        .blinker_0_led_export						  (fpga_led_internal[0]),
		  .hps_0_h2f_reset_reset_n               (hps_fpga_reset_n),
		  .sdrstick_rx_0_adc_in_data             (INA),
		  .sdrstick_rx_0_debug_led_led           (fpga_led_internal[1])
    );
	 
	 
	 
	 //  Assign hard coded values.  These should eventually be replaced with configuration from the Linux driver
	 assign PGA = 1'b0;
	 assign DITHER = 1'b0;
	 assign RAND = 1'b0;
	 assign DRV_CLK_OUT_N = 1'b0;
	 
	 // Deal with the attenuator
	 // Divide the master clock by 16 to get a clock for the attenuator
	 reg clk_div16 = 1'b0;
	 reg [3:0] clk_div16_counter = 4'h0;
	 always @(posedge clk_bot1) begin
			if(clk_div16_counter == 4'hF) begin
				clk_div16 <= ~clk_div16;
				clk_div16_counter = 4'h0;
			end else begin
				clk_div16_counter = clk_div16_counter + 1;
			end
	 end

	 reg [4:0] no_gain = 5'b0;
	 Attenuator attn (
		.clk (clk_div16),
		.data (no_gain),
		.ATTN_CLK (RX_SPI_CLK),
		.ATTN_DATA (RX_SPI_DATA),
		.ATTN_LE (ATTN_LE)
	);
	 
	 //  Assign the overflow line to the LED.  This should also have an indication to software as well
	 assign fpga_led_internal[2] = OVFLA;
	 
	 //  Use the LED to monitor the 122MHz clock.  Blink once per second.
	 reg [31:0] c122_counter = 32'b0;
	 reg c122_led;
	 
	 assign fpga_led_internal[3] = c122_led;
	 
	 always @ (posedge ADC_CLKA) begin
		if(c122_counter == 32'd122880000) begin
			c122_led = !c122_led;
			c122_counter = 32'd0;
		end
		c122_counter = c122_counter + 1;
	 end
endmodule
