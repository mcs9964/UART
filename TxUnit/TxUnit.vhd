library IEEE;
use IEEE.std_logic_1164.all;

entity TxUnit is
  port (
    clk, reset : in std_logic;
    enable : in std_logic;
    ld : in std_logic;
    txd : out std_logic;
    regE : out std_logic;
    bufE : out std_logic;
    data : in std_logic_vector(7 downto 0));
end TxUnit;

architecture behavorial of TxUnit is
	-- Définition des états de l'automate
	type t_etat IS (repos, etat1, etat2, etat3);
	-- Signal représentant l'état courant
	SIGNAL etat : t_etat := repos;
	-- Le registre tampon
	SIGNAL bufT : std_logic_vector(7 downto 0);
	-- Le registre d’emission 
	SIGNAL regT : std_logic_vector(7 downto 0);

begin
	PROCESS (clk, reset)
	 -- Déclaration de variables locales
    VARIABLE cpt_bit : integer;  -- Compteur pour suivre les bits à émettre
	 VARIABLE parite : std_logic; -- Variable pour calculer la parité
	 VARIABLE reg_bufE : std_logic; -- Variable pour consulter l'état du tampon(puisque bufE est en Out)
	BEGIN
    IF (reset = '0') THEN
		-- Réinitialisation du système lorsque reset est activé 
		-- Réinitialise le compteur des bits 
		cpt_bit := 8; -- justification de l'initialisation par 8 : on envoit le bit de start pour cpt_bit = 8 
		-- Initialisation du tampon avec des valeurs indéterminées ('U')
		bufT <= (OTHERS => 'U');
		-- Initialisation du registre avec des valeurs indéterminées ('U')
		regT <= (OTHERS => 'U');
		--  le registre est initialement vide 
		regE <= '1';
		-- le tampon est initialement vide
		bufE <= '1';
		-- la ligne au repos
		txd <= '1';
		-- initialisation du parité par 0
		parite := '0';
		-- on passe à l'état repos
		etat <= repos;
	 ELSIF (rising_edge(clk)) THEN -- Si une montée d'horloge (rising edge) est détectée
		-- Switch sur l'état courant		
      CASE etat IS
		  -- Si l'état est 'repos' (attente)
        WHEN repos =>
			IF (ld = '1') THEN -- Si la commande de chargement est activée (ld = '1')
				bufT <= data;  -- Charger les données dans le tampon
				reg_bufE := '0'; -- Le tampon est maintenant rempli
				bufE <= reg_bufE; -- Mettre à jour l'état du tampon
				etat <= etat1;  -- Passer à l'état 'etat1'
			END IF;
		WHEN etat1 => -- Si l'état est 'etat1'
			regT <= bufT;-- Charger les données du tampon dans le registre d'émission
			regE <= '0';-- Le registre d'émission est activé
			reg_bufE := '1';  -- Le tampon est maintenant vide
			bufE <= reg_bufE; -- Mettre à jour l'état du tampon
			cpt_bit := 8;-- Réinitialiser le compteur de bits à 8
			etat <= etat2;-- Passer à l'état 'etat2'		
		WHEN etat2 => -- Si l'état est 'etat2'
			IF (ld = '1' AND reg_bufE = '1') THEN -- Si la commande de chargement est activée et que le tampon est vide
				bufT <= data;  -- Charger de nouvelles données dans le tampon
				reg_bufE := '0';  -- le tampon est rempli
				bufE <= reg_bufE;  -- Mettre à jour l'état du tampon
			END IF;
			IF (enable = '1') THEN  -- Si l'activation de la transmission est activée
				IF (cpt_bit >= 0) THEN -- Tant qu'il reste des bits à transmettre
					IF (cpt_bit = 8) THEN -- Si c'est le premier bit à émettre (start bit)
						txd <= '0';-- Envoyer un bit de départ ('0')
						parite := '0'; -- mise à jour de la parité
						cpt_bit := cpt_bit - 1; -- Décrémenter le compteur de bits
					ELSE 
						txd <= regT(cpt_bit); -- Envoyer le bit suivant depuis le registre d'émission
						parite := parite xor regT(cpt_bit);  -- Calculer la parité pour ce bit
						cpt_bit := cpt_bit - 1; -- Décrémenter le compteur de bits
					END IF;
					etat <= etat2;  -- Rester dans l'état 'etat2' tant qu'il reste des bits
				ELSE 
				   regE <= '1'; -- Une fois les bits envoyés, le registre est vide
					txd <= parite;  -- Envoyer le bit de parité
					etat <= etat3;-- Passer à l'état 'etat3' pour envoyer le bit de stop
				END IF;
			END IF;
		WHEN etat3 =>-- Si l'état est 'etat3' (émission terminée)
			IF (ld = '1' AND reg_bufE = '1') THEN -- Si la commande de chargement est activée et que le tampon est vide
				bufT <= data;  -- Charger de nouvelles données dans le tampon
				reg_bufE := '0'; -- remplir le tampon
				bufE <= reg_bufE; -- Mettre à jour l'état du tampon
			END IF;
			IF (enable = '1') THEN -- Si l'activation de la transmission est activée
				txd <= '1'; -- Envoyer le bit de stop ('1')
				IF (reg_bufE = '0') THEN -- Si le tampon est non vide
					etat <= etat1; -- Revenir à l'état 'etat1' pour une nouvelle transmission
				ELSE 
					etat <= repos;  -- Sinon, revenir à l'état 'repos' (attente)
				END IF;
			END IF;
		END CASE;
    END IF;
  END PROCESS;
		 
end behavorial;