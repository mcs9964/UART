
SRC = ../clkUnit/clkUnit.vhd             \
      TxUnit.vhd \
      testTxUnit.vhd\
      ../clkUnit/diviseurClk.vhd

# for simulation:
TEST = testTxUnit
# duration (to adjust if necessary)
TIME = 4000ns
PLOT = output
