----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:01:40 01/08/2025 
-- Design Name: 
-- Module Name:    ControleReception - Behavioral 
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

entity ControleReception is
    Port ( tmpclk : in  STD_LOGIC;
           tmprxd : in  STD_LOGIC;
           read : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           FErr : out  STD_LOGIC;
           OErr : out  STD_LOGIC;
           DRdy : out  STD_LOGIC;
           data : out  STD_LOGIC_VECTOR (7 downto 0));
end entity ControleReception;

architecture Behavioral of ControleReception is

   -- Définition des états de l'automate
	type t_etat IS (repos, reception, fin);
	
	-- Signal représentant l'état courant
	SIGNAL etat : t_etat;
begin

PROCESS (clk, reset)
   -- Déclaration de variables locales
   VARIABLE cpt_bit : NATURAL := 11;  -- Compteur pour suivre les bits à émettre
   VARIABLE parite : std_logic := '0'; -- Variable pour calculer la parité
   --VARIABLE FErrreg : std_logic := '0'; 
BEGIN
   IF (reset = '0') THEN
      -- Réinitialisation du système lorsque reset est activé 
      cpt_bit := 11;
      FErr <= '0';
      OErr <= '0';
      DRdy <= '0';
      data <= (OTHERS => '0');
      -- initialisation de parité par 0
      parite := '0';
      -- on passe à l'état repos
      etat <= repos;
   ELSIF (rising_edge(clk)) THEN -- Si une montée d'horloge (rising edge) est détectée
      -- Switch sur l'état courant     
      CASE etat IS
         WHEN repos =>
            FErr <= '0';
            OErr <= '0';
            DRdy <= '0';
            parite := '0';
            cpt_bit := 9;
            IF (tmpclk = '1' and tmprxd = '0') THEN
                etat <= reception;
            END IF;

         WHEN reception =>
            IF (tmpclk = '1') THEN
               IF (cpt_bit > 1) THEN
                  data(cpt_bit - 2) <= tmprxd;
                  parite := parite xor tmprxd;  -- Calculer la parité pour ce bit
                  cpt_bit := cpt_bit - 1; -- Décrémenter le compteur de bits                 
               ELSIF (cpt_bit = 1 and tmprxd /= parite) THEN
                     FErr <= '1'; -- On réclame erreur 
							cpt_bit := cpt_bit - 1; -- Décrémenter le compteur de bits 	
                     etat <= repos; 																						
               ELSIF (cpt_bit = 0 and tmprxd = '0') THEN
                     FErr <= '1';    
                     etat <= repos;                  
               ELSE 
                     DRdy <= '1';
                     etat <= fin;
               END IF;
						
           END IF;                        

         WHEN fin =>
            DRdy <= '0';
            IF (read = '0') THEN
               OErr <= '1';
            END IF;
				etat <= repos;
         WHEN OTHERS => NULL; -- Cas de sécurité si un état inconnu est atteint (ne fait rien)
      END CASE;
   END IF;
END PROCESS;
END Behavioral;