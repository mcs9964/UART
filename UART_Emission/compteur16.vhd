----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:21:45 01/08/2025 
-- Design Name: 
-- Module Name:    compteur16 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity compteur16 is
    Port ( enable : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           RxD : in  STD_LOGIC;
           tmprxd : out  STD_LOGIC;
           tmpclk : out  STD_LOGIC);
end compteur16;

architecture Behavioral of compteur16 is

   -- Définition des états de l'automate
	type t_etat IS (repos, compte, fin);
	
	-- Signal représentant l'état courant
	SIGNAL etat : t_etat;
begin

PROCESS (enable, reset)
	 -- Déclaration de variables locales
    VARIABLE cpt_bit : NATURAL;  -- Compteur pour suivre les bits à émettre
	 VARIABLE cpt_wait : NATURAL;  -- Compteur pour attendre entre les réceptions des bits
	 
	 BEGIN
    IF (reset = '0') THEN
		-- Réinitialisation du système lorsque reset est activé 
		cpt_bit := 11;
		cpt_wait := 8;
		tmprxd <= '0';
		tmpclk <= '0';
		-- on passe à l'état repos
		etat <= repos;
		 ELSIF (rising_edge(enable)) THEN -- Si une montée d'horloge (rising edge) est détectée
		-- Switch sur l'état courant		
      CASE etat IS
		  -- Si l'état est 'repos' 
        WHEN repos =>
		   cpt_wait := 8;
			cpt_bit := 11;
			tmprxd <= '0';
			tmpclk <= '0';
			IF (RxD = '0') THEN
			  etat <= compte;
			END IF;
		  WHEN compte =>
		   IF (cpt_wait = 0) THEN
			   tmprxd <= RxD; --bit de start récupéré
		      tmpclk <= '1'; 
				cpt_bit := cpt_bit - 1; -- Décrémenter le compteur de bit
			   cpt_wait := 15; -- Mise à jour du compteur pour l'attente entre bits de la trame
			   etat <= fin;
			 ELSE 
			  cpt_wait := cpt_wait - 1; -- Décrémenter le compteur d'attente
			 END IF;
			 
			 WHEN fin =>
			 tmpclk <= '0'; 
			  IF (cpt_bit = 0) THEN
			    etat <= repos;
			  ELSE 
				 cpt_wait := cpt_wait - 1; -- Décrémenter le compteur d'attente
			    etat <= compte;			 
			  END IF;
			 WHEN OTHERS => NULL;-- Cas de sécurité si un état inconnu est atteint (ne fait rien)
			 
		END CASE;
    END IF;
  END PROCESS;
		 
end Behavioral;
			     
	

