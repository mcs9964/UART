library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity UART_FPGA_N4 is
  port (
  -- ne garder que les ports utiles ?
    -- les 16 switchs
    swt : in std_logic_vector (15 downto 0);
    -- les 5 boutons noirs
    btnC, btnU, btnL, btnR, btnD : in std_logic;
    -- horloge
    mclk : in std_logic;
    -- les 16 leds
    led : out std_logic_vector (15 downto 0);
    -- les anodes pour sélectionner les afficheurs 7 segments à utiliser
    an : out std_logic_vector (7 downto 0);
    -- valeur affichée sur les 7 segments (point décimal compris, segment 7)
    ssg : out std_logic_vector (7 downto 0);
    -- ligne série (à rajouter)
	 TxD : OUT STD_LOGIC;
    RxD : IN STD_LOGIC

  );
end UART_FPGA_N4;

architecture synthesis of UART_FPGA_N4 is

  -- rappel du (des) composant(s)
  -- À COMPLÉTER 
  COMPONENT UARTunit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		cs : IN std_logic;
		rd : IN std_logic;
		wr : IN std_logic;
		RxD : IN std_logic;
		addr : IN std_logic_vector(1 downto 0);
		data_in : IN std_logic_vector(7 downto 0);          
		TxD : OUT std_logic;
		IntR : OUT std_logic;
		IntT : OUT std_logic;
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT echoUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		IntR : IN std_logic;
		IntT : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);          
		cs : OUT std_logic;
		rd : OUT std_logic;
		wr : OUT std_logic;
		addr : OUT std_logic_vector(1 downto 0);
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT diviseurClk
	GENERIC(facteur: natural);
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		nclk : OUT std_logic
		);
	END COMPONENT;
	
	SIGNAL nclk : STD_LOGIC;
   SIGNAL reset : STD_LOGIC;
	SIGNAL csecho : STD_LOGIC;
	SIGNAL rdecho : STD_LOGIC;
	SIGNAL wrecho : STD_LOGIC;
	SIGNAL IntRU, IntTU : STD_LOGIC;
	SIGNAL Addrecho : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL data_uart_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL data_uart_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
	


begin

  -- valeurs des sorties (à modifier)

  -- convention afficheur 7 segments 0 => allumé, 1 => éteint
  ssg <= (others => '1');
  -- aucun afficheur sélectionné
  an(7 downto 0) <= (others => '1');
  -- 16 leds sont etteintes
  led(15 DOWNTO 0) <= (others => '0');

  -- reset est mise à 0 par le bouton btnC
  reset <= not(btnC);


  -- connexion du (des) composant(s) avec les ports de la carte
  -- À COMPLÉTER 
   inst_diviseurClk : diviseurClk
   GENERIC MAP(645) -- pour avoir une horloge de 155Khz à partir d'une horloge de 100Mhz
   PORT MAP(
          clk => mclk,
          reset => reset,
          nclk => nclk
        );
	
	
	Inst_echoUnit: echoUnit PORT MAP(
		clk => nclk,
		reset => reset,
		cs => csecho,
		rd => rdecho,
		wr => wrecho,
		IntR => IntRU,
		IntT => IntTU,
		addr => Addrecho,
		data_in => data_uart_out,
		data_out => data_uart_in
	);
	
	Inst_UARTunit: UARTunit PORT MAP(
		clk => nclk,
		reset => reset,
		cs => csecho,
		rd => rdecho,
		wr => wrecho,
		RxD => RxD,
		TxD => TxD,
		IntR => IntRU,
		IntT => IntTU,
		addr => Addrecho,
		data_in => data_uart_in,
		data_out => data_uart_out
	);
	
	

    
end synthesis;
