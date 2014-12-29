create_clock -period 20 [get_ports clk_50m_fpga]
create_clock -period 10 [get_ports clk_100m_fpga]
create_clock -period 6.4 [get_ports clk_top1]
create_clock -period 10 [get_ports clk_bot1]
create_clock -period 8.138 [get_ports ADC_CLKA]

derive_pll_clocks
derive_clock_uncertainty

create_generated_clock -name clk_div16 -source [get_ports ADC_CLKA] -divide_by 16 clk_div16

set_clock_groups -asynchronous \
	-group { clk_50m_fpga \
		 clk_100m_fpga \
		 clk_top1 \
		 clk_bot1
	       } \
	-group { ADC_CLKA \
	       } \
	-group { memory_mem_ck \
	         memory_mem_ck_n \
				memory_mem_dqs[0]_IN \
				memory_mem_dqs[0]_OUT \
				memory_mem_dqs[1]_IN \
				memory_mem_dqs[1]_OUT \
				memory_mem_dqs[2]_IN \
				memory_mem_dqs[2]_OUT \
				memory_mem_dqs[3]_IN \
				memory_mem_dqs[3]_OUT \
				memory_mem_dqs_n[0]_OUT \
				memory_mem_dqs_n[1]_OUT \
				memory_mem_dqs_n[2]_OUT \
				memory_mem_dqs_n[3]_OUT \
				soc_system:u0|soc_system_hps_0:hps_0|soc_system_hps_0_hps_io:hps_io|soc_system_hps_0_hps_io_border:border|hps_sdram:hps_sdram_inst|hps_sdram_pll:pll|afi_clk_write_clk \
				soc_system:u0|soc_system_hps_0:hps_0|soc_system_hps_0_hps_io:hps_io|soc_system_hps_0_hps_io_border:border|hps_sdram:hps_sdram_inst|hps_sdram_pll:pll|pll_write_clk_dq_write_clk \
				u0|hps_0|hps_io|border|hps_sdram_inst|hps_sdram_p0_sampling_clock
	       }
				

set_max_delay -from clk_bot1 -to clk_bot1 12

#  These clocks should be ignored by the set_false_path, but they're not
#  So I'm going to set up some junk clocks for them
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_i2c1_inst_SCL}]
set_false_path -from [get_ports {hps_0_hps_io_hps_io_i2c1_inst_SCL}] -to *
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_usb1_inst_CLK}]
set_false_path -from [get_ports {hps_0_hps_io_hps_io_usb1_inst_CLK}] -to *
create_clock -period 200 [get_ports {hps_0_hps_io_hps_io_i2c1_inst_SCL}]
create_clock -period 41.666 [get_ports {hps_0_hps_io_hps_io_usb1_inst_CLK}]

set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_i2c1_inst_SDA}]
set_false_path -from [get_ports {hps_0_hps_io_hps_io_i2c1_inst_SDA}] -to *

#
#  These are HPS Peripherals which are hard silicon.  They do not need to be
#  analyzed for timing.
#
#  Ethernet
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_emac1_inst_MDC}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_emac1_inst_MDIO}]
set_false_path -from [get_ports {hps_0_hps_io_hps_io_emac1_inst_MDIO}] -to *
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_emac1_inst_TXD0}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_emac1_inst_TXD1}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_emac1_inst_TXD2}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_emac1_inst_TXD3}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_emac1_inst_TX_CLK}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_emac1_inst_TX_CTL}]
set_false_path -from [get_ports {hps_0_hps_io_hps_io_emac1_inst_RXD0}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_emac1_inst_RXD1}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_emac1_inst_RXD2}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_emac1_inst_RXD3}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_emac1_inst_RX_CLK}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_emac1_inst_RX_CTL}] -to *

# QSPI
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_qspi_inst_CLK}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_qspi_inst_SS0}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_qspi_inst_IO0}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_qspi_inst_IO1}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_qspi_inst_IO2}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_qspi_inst_IO3}]
set_false_path -from [get_ports {hps_0_hps_io_hps_io_qspi_inst_IO0}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_qspi_inst_IO1}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_qspi_inst_IO2}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_qspi_inst_IO3}] -to *

# SDIO
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_sdio_inst_CLK}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_sdio_inst_CMD}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_sdio_inst_D0}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_sdio_inst_D1}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_sdio_inst_D2}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_sdio_inst_D3}]
set_false_path -from [get_ports {hps_0_hps_io_hps_io_sdio_inst_CMD}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_sdio_inst_D0}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_sdio_inst_D1}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_sdio_inst_D2}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_sdio_inst_D3}] -to *

# SPIM 0
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_spim0_inst_MOSI}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_spim0_inst_SS0}]
set_false_path -from [get_ports {hps_0_hps_io_hps_io_spim0_inst_MISO}] -to *

# SPIM 1
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_spim1_inst_MOSI}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_spim1_inst_SS0}]
set_false_path -from [get_ports {hps_0_hps_io_hps_io_spim1_inst_MISO}] -to *

# UART
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_uart0_inst_TX}]
set_false_path -from [get_ports {hps_0_hps_io_hps_io_uart0_inst_RX}] -to *

# USB 1
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_usb1_inst_D0}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_usb1_inst_D1}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_usb1_inst_D2}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_usb1_inst_D3}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_usb1_inst_D4}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_usb1_inst_D5}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_usb1_inst_D6}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_usb1_inst_D7}]
set_false_path -from * -to [get_ports {hps_0_hps_io_hps_io_usb1_inst_STP}]
set_false_path -from [get_ports {hps_0_hps_io_hps_io_usb1_inst_D0}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_usb1_inst_D1}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_usb1_inst_D2}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_usb1_inst_D3}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_usb1_inst_D4}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_usb1_inst_D5}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_usb1_inst_D6}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_usb1_inst_D7}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_usb1_inst_DIR}] -to *
set_false_path -from [get_ports {hps_0_hps_io_hps_io_usb1_inst_NXT}] -to *

# LEDs
set_false_path -from * -to [get_ports {user_led_fpga[0]}]
set_false_path -from * -to [get_ports {user_led_fpga[1]}]
set_false_path -from * -to [get_ports {user_led_fpga[2]}]
set_false_path -from * -to [get_ports {user_led_fpga[3]}]
