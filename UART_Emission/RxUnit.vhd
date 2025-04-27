library IEEE;
use IEEE.std_logic_1164.all;
-- Déclaration de l'entité RxUnit, représentant un récepteur (Rx).
entity RxUnit is
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    read             : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    Ferr, OErr, DRdy : out std_logic);
end RxUnit;

architecture RxUnit_arch of RxUnit is

    -- Composant ControleReception pour la gestion des erreurs et du contrôle de réception.
	COMPONENT ControleReception
	PORT(
		tmpclk : IN std_logic;
		tmprxd : IN std_logic;
		read : IN std_logic;
		reset : IN std_logic;
		clk : IN std_logic;          
		FErr : OUT std_logic;
		OErr : OUT std_logic;
		DRdy : OUT std_logic;
		data : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	-- Composant compteur16 pour gérer le comptage d'horloge et la synchronisation des signaux.
	COMPONENT compteur16
	PORT(
		enable : IN std_logic;
		reset : IN std_logic;
		RxD : IN std_logic;          
		tmprxd : OUT std_logic;
		tmpclk : OUT std_logic
		);
	END COMPONENT;
	-- Déclaration des signaux internes pour la connexion entre les composants
signal tmprxdinter, tmpclkinter : std_logic;
begin	 
	 Inst_compteur16: compteur16 PORT MAP(
		enable => enable,
		reset => reset,
		RxD => rxd,
		tmprxd => tmprxdinter,
		tmpclk => tmpclkinter
	);

	 Inst_ControleReception: ControleReception PORT MAP(
		tmpclk => tmpclkinter,
		tmprxd => tmprxdinter,
		read => read,
		reset => reset,
		clk => clk,
		FErr => FErr,
		OErr => OErr,
		DRdy => DRdy,
		data => data
	);





end RxUnit_arch;
