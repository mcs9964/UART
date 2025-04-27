SRC = ../clkUnit/clkUnit.vhd             \
      ../clkUnit/diviseurClk.vhd \
      ../TxUnit/TxUnit.vhd \
      echoUnit.vhd \
      ctrlUnit.vhd \
      RxUnit.vhd \
      diviseurClk.vhd \
      compteur16.vhd \
      ControleReception.vhd \
      UART.vhd \
      UART_FPGA_N4.vhd 
      


# for synthesis:
UNIT = UART_FPGA_N4
ARCH = synthesis
UCF  = UART_FPGA_N4_DDR.ucf
