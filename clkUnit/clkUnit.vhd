library IEEE;
use IEEE.std_logic_1164.all;


entity clkUnit is
  
 port (
   clk, reset : in  std_logic;
   enableTX   : out std_logic;
   enableRX   : out std_logic);
    
end clkUnit;

architecture behavorial of clkUnit is

COMPONENT diviseurClk
generic(facteur : natural);
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		nclk : OUT std_logic
		);
END COMPONENT;

begin

Inst_diviseurClk: diviseurClk 
-- Instanciation du diviseur d'horloge 
  generic map(16) 
  PORT MAP(
		clk => clk, 
		reset => reset,
		nclk => enableTX --Horloge de transmission prend l'horloge divisée, facteur 16
	);
		enableRX <= clk and reset; --Horloge de réception

end behavorial;
