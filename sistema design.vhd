---------------- sistema ------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sistema is
    port (
        clk_50hz           : in std_logic;
        reset_n         : in std_logic;
        emergency       : in std_logic;
        ns_ped_button   : in std_logic;
        ew_ped_button   : in std_logic;
        ns_sensor       : in std_logic;
        ew_sensor       : in std_logic;
        
        ns_light_verde    : out std_logic;
        ns_light_amarelo  : out std_logic;
        ns_light_vermelho : out std_logic;
        ew_light_verde    : out std_logic;
        ew_light_amarelo  : out std_logic;
        ew_light_vermelho : out std_logic
    );

end entity sistema;

architecture Structural of sistema is

    -- Sinais internos para conectar o datapath e a controladora
    signal clk_1hz         : std_logic;
    signal enable_count    : std_logic;
    signal clear_count     : std_logic;
    signal load_2          : std_logic;
    signal load_10         : std_logic;
    signal load_28         : std_logic;
    signal load_40         : std_logic;
    signal load_50         : std_logic;
    signal eq_comparator   : std_logic;
    signal lt_comparator   : std_logic;

    -- Componentes (declarações existentes no seu código)
    component controladora is
        port (
            eq_comparator     : in std_logic;
            lt_comparator     : in std_logic;
            emergency         : in std_logic;
            ns_ped_button     : in std_logic;
            ew_ped_button     : in std_logic;
            ns_sensor         : in std_logic;
            ew_sensor         : in std_logic;
            clk               : in std_logic;
            reset_n           : in std_logic;
            
            enable_count      : out std_logic;
            clear_count       : out std_logic;
            load_2            : out std_logic;
            load_10           : out std_logic;
            load_28           : out std_logic;
            load_40           : out std_logic;
            load_50           : out std_logic;
            ns_light_verde    : out std_logic;
            ns_light_amarelo  : out std_logic;
            ns_light_vermelho : out std_logic;
            ew_light_verde    : out std_logic;
            ew_light_amarelo  : out std_logic;
            ew_light_vermelho : out std_logic
        );
    end component;

    component datapath is
        port (
            clk               : in std_logic;
            reset_n           : in std_logic;
            enable_count      : in std_logic;
            clear_count       : in std_logic;
            load_2            : in std_logic;
            load_10           : in std_logic;
            load_28           : in std_logic;
            load_40           : in std_logic;
            load_50           : in std_logic;
            eq_comparator     : out std_logic;
            lt_comparator     : out std_logic
        );
    end component;

    component DivisorClock is
        port (
            clk_50hz : in std_logic;
            reset  : in std_logic;
            clk    : out std_logic
        );
    end component;

begin

    -- Instância do Divisor de Clock para gerar o clk de 1Hz
    CLK_DIV_U: DivisorClock
        port map (
            clk_50hz  => clk_50hz,
            reset   => not reset_n,  -- Conecta o reset ativo baixo a um reset ativo alto
            clk     => clk_1hz
        );

    -- Instância da controladora
    U_controladora: controladora
        port map (
            clk               => clk_1hz,
            reset_n           => reset_n,
            emergency         => emergency,
            ns_ped_button     => ns_ped_button,
            ew_ped_button     => ew_ped_button,
            ns_sensor         => ns_sensor,
            ew_sensor         => ew_sensor,
            eq_comparator     => eq_comparator,
            lt_comparator     => lt_comparator,
            
            enable_count      => enable_count,
            clear_count       => clear_count,
            load_2            => load_2,
            load_10           => load_10,
            load_28           => load_28,
            load_40           => load_40,
            load_50           => load_50,
            ns_light_verde    => ns_light_verde,
            ns_light_amarelo  => ns_light_amarelo,
            ns_light_vermelho => ns_light_vermelho,
            ew_light_verde    => ew_light_verde,
            ew_light_amarelo  => ew_light_amarelo,
            ew_light_vermelho => ew_light_vermelho
        );
        
    -- Instância do datapath
    U_datapath: datapath
        port map (
            clk            => clk_1hz,
            reset_n        => reset_n,
            enable_count   => enable_count,
            clear_count    => clear_count,
            load_2         => load_2,
            load_10        => load_10,
            load_28        => load_28,
            load_40        => load_40,
            load_50        => load_50,
            eq_comparator  => eq_comparator,
            lt_comparator  => lt_comparator
        );

end architecture Structural;



--------------------------- controladora ----------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  

entity controladora is
    port (
        -- entradas

        eq_comparator  : in std_logic;
        lt_comparator  : in std_logic;
        emergency      : in std_logic;
        ns_ped_button  : in std_logic;
        ew_ped_button  : in std_logic;
        ns_sensor      : in std_logic;
        ew_sensor      : in std_logic;
        clk            : in std_logic;
        reset_n        : in std_logic;
        
        --saídas
        
        enable_count      : out std_logic;
        clear_count       : out std_logic;
        load_2            : out std_logic;
        load_10           : out std_logic;
        load_28           : out std_logic;
        load_40           : out std_logic;
        load_50           : out std_logic;
        ns_light_verde    : out std_logic;
        ns_light_amarelo  : out std_logic;
        ns_light_vermelho : out std_logic;
        ew_light_verde    : out std_logic;
        ew_light_amarelo  : out std_logic;
        ew_light_vermelho : out std_logic
    );
end entity controladora;

architecture Behavioral of controladora is

    type state_type is (NS_VERDE, NS_AMARELO, LO_VERDE, LO_AMARELO, EMERGENCIA);
    signal current_state, next_state : state_type;

begin

    -- transiçãoo de estado
    process(clk,reset_n)
    begin
         if reset_n = '0' then
            current_state <= EMERGENCIA;
            elsif rising_edge(clk) then
            current_state <= next_state;
            end if;

    end process;

    -- lógica de transição
    process(current_state, lt_comparator, eq_comparator, emergency, ns_sensor, ew_sensor, ns_ped_button, ew_ped_button)
    begin
        case current_state is
            when NS_VERDE =>
                if emergency = '1' then
                    next_state <= EMERGENCIA;
                elsif eq_comparator = '1' or (ns_sensor = '0' and eq_comparator = '1') or (ns_ped_button = '1' and eq_comparator = '1') or (ns_sensor = '1' and eq_comparator = '1') then
                    next_state <= NS_AMARELO;
                elsif ew_ped_button = '1' and lt_comparator = '1' then
                    next_state <= NS_VERDE;
                else 
                    next_state <= NS_VERDE;
                end if;

            when NS_AMARELO =>
                if emergency = '1' then
                    next_state <= EMERGENCIA;
                elsif eq_comparator = '1' then
                    next_state <= LO_VERDE;
                else
                    next_state <= NS_AMARELO;
                end if;

            when LO_VERDE =>
                if emergency = '1' then
                    next_state <= EMERGENCIA;
                elsif eq_comparator = '1' or (ew_sensor = '0' and eq_comparator = '1') or (ew_ped_button = '1' and eq_comparator = '1') or (ew_sensor = '1' and eq_comparator = '1') then
                    next_state <= LO_AMARELO;
                elsif ns_ped_button = '1' and lt_comparator = '1' then
                    next_state <= LO_VERDE;
                else
                    next_state <= LO_VERDE;
                end if;

            when LO_AMARELO =>
                if emergency = '1' then
                    next_state <= EMERGENCIA;
                elsif eq_comparator = '1' then
                    next_state <= NS_VERDE;
                else
                    next_state <= LO_AMARELO;
                end if;

            when EMERGENCIA =>
                if emergency = '0' and eq_comparator = '1' then
                    next_state <= NS_VERDE;
                else
                    next_state <= EMERGENCIA;
                end if;
        end case;
    end process;

    -- controle das saídas
    process(current_state, lt_comparator, eq_comparator, emergency, ns_sensor, ew_sensor, ns_ped_button, ew_ped_button)
    begin
        -- valores padrão
        enable_count <= '1';

        ns_light_verde        <= '0';
        ns_light_amarelo      <= '0';
        ns_light_vermelho     <= '1';
        ew_light_verde        <= '0';
        ew_light_amarelo      <= '0';
        ew_light_vermelho     <= '1';
    
        load_2  <= '0';
        load_10 <= '0';
        load_28 <= '0';
        load_40 <= '0';
        load_50 <= '0';

        case current_state is
            when NS_VERDE =>
            
                ns_light_verde        <= '1';
                ns_light_amarelo      <= '0';
       		    ns_light_vermelho     <= '0';
        		ew_light_verde        <= '0';
        		ew_light_amarelo      <= '0';
        		ew_light_vermelho     <= '1';
                
                if ns_sensor = '0' then
                load_10 <= '1';
                elsif ns_ped_button = '1' then
                load_28 <= '1';
                elsif ns_sensor = '1' then 
                load_40 <= '1';
                else
                load_50 <= '1';
				end if;
                
                if eq_comparator = '1' then
                clear_count <= '1';
                else
                clear_count <= '0';
                end if;
                
                
            when NS_AMARELO =>
            
                ns_light_verde        <= '0';
                ns_light_amarelo      <= '1';
       		    ns_light_vermelho     <= '0';
        		ew_light_verde        <= '0';
        		ew_light_amarelo      <= '0';
        		ew_light_vermelho     <= '1';

                load_2 				  <= '1';
                
                if eq_comparator = '1' then
                clear_count <= '1';
                else
                clear_count <= '0';
                end if;
                
                
            when LO_VERDE =>
            
                ns_light_verde        <= '0';
                ns_light_amarelo      <= '0';
       		    ns_light_vermelho     <= '1';
        		ew_light_verde        <= '1';
        		ew_light_amarelo      <= '0';
        		ew_light_vermelho     <= '0';

                if ew_sensor = '0' then
                load_10 <= '1';
                elsif ew_ped_button = '1' then
                load_28 <= '1';
                elsif ew_sensor = '1' then 
                load_40 <= '1';
                else
                load_50 <= '1';
				end if;
                
                if eq_comparator = '1' then
                clear_count <= '1';
                else
                clear_count <= '0';
                end if;

            when LO_AMARELO =>
            
                ns_light_verde        <= '0';
                ns_light_amarelo      <= '0';
       		    ns_light_vermelho     <= '1';
        		ew_light_verde        <= '0';
        		ew_light_amarelo      <= '1';
        		ew_light_vermelho     <= '0';
                load_2                <= '1';
                
                if eq_comparator = '1' then
                clear_count <= '1';
                else
                clear_count <= '0';
                end if;
                
 

            when EMERGENCIA =>
            
                ns_light_verde        <= '0';
                ns_light_amarelo      <= '0';
       		    ns_light_vermelho     <= '1';
        		ew_light_verde        <= '0';
        		ew_light_amarelo      <= '0';
        		ew_light_vermelho     <= '1';
                load_2                <= '1';
                
                if emergency = '1' then
                clear_count <= '1';
                else
                clear_count <= '0';
                end if;
                
                
        end case;
    end process;

end architecture Behavioral;
--- contador------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  

entity tempo_counter is
    port (
        clk          : in std_logic;
        reset_n      : in std_logic;
        enable_count : in std_logic;
        clear_count  : in std_logic;
        current_time : out std_logic_vector(5 downto 0)
    );
end entity tempo_counter;

architecture Behavioral of tempo_counter is
    signal count_reg : unsigned(5 downto 0) := (others => '0');
begin

    process(clk, reset_n)
    begin
        -- reset
        if reset_n = '0' then
            count_reg <= (others => '0');
        
            -- para zerar a contagem a cada estado
        elsif rising_edge(clk) then
            if clear_count = '1' then
                count_reg <= (others => '0');
            
            elsif enable_count = '1' then
                -- conta até 63, depois fica parado em 63
                if count_reg < "111111" then
                    count_reg <= count_reg + 1;
                end if;
            end if;
        end if;
    end process;

    -- atribui a saída
    current_time <= std_logic_vector(count_reg);

end architecture Behavioral;


--- registrador------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity parallel_register is
    port (
        clk : in std_logic;
        reset_n : in std_logic;
        load_2  : in std_logic;
        load_10 : in std_logic;
        load_28 : in std_logic;
        load_40 : in std_logic;
        load_50 : in std_logic;
        q_out_register : out std_logic_vector(5 downto 0)
    );
end entity parallel_register;

architecture Behavioral of parallel_register is
    
begin

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            q_out_register <= (others => '0');
        elsif rising_edge(clk) then
            if load_2 = '1' then
            q_out_register <= "000010";
        	end if;
            if load_10 = '1' then
            q_out_register <= "001010";
            end if;
            if load_28 = '1' then
            q_out_register <= "011100";
        	end if;
            if load_40 = '1' then
            q_out_register <= "101000";
        	end if;
            if load_50 = '1' then
            q_out_register <= "110010";
        	end if;
        end if;
    end process;

end architecture Behavioral;

--- comparador------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity time_comparator is
    port (
        current_time     : in std_logic_vector(5 downto 0);
        q_out_register   : in std_logic_vector(5 downto 0);
        eq_comparator    : out std_logic;
        lt_comparator    : out std_logic
        );

end entity time_comparator;

architecture Behavioral of time_comparator is
    signal current_time_int : integer range 0 to 63;
	signal q_out_register_int   : integer range 0 to 63;
begin

    -- Converte o std_logic_vector para integer
    current_time_int <= to_integer(unsigned(current_time));
    q_out_register_int  <= to_integer(unsigned(q_out_register));

    -- Comparações
    eq_comparator <= '1' when q_out_register_int = current_time_int else '0';
    lt_comparator <= '1' when current_time_int < q_out_register_int else '0';

end architecture Behavioral;

--------- datapath --------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    port (
        clk            : in std_logic;
        reset_n        : in std_logic;
        enable_count   : in std_logic;
        clear_count    : in std_logic;
        load_2          : in std_logic;
        load_10         : in std_logic;
        load_28         : in std_logic;
        load_40         : in std_logic;
        load_50         : in std_logic;
        eq_comparator  : out std_logic;
        lt_comparator  : out std_logic
    );
end entity datapath;

architecture Structural of datapath is

    -- Componentes
    component tempo_counter is
        port (
            clk          : in std_logic;
            reset_n      : in std_logic;
            enable_count : in std_logic;
            clear_count  : in std_logic;
            current_time : out std_logic_vector(5 downto 0)
        );
    end component;

    component parallel_register is
        port (
            clk             : in std_logic;
            reset_n         : in std_logic;
            load_2          : in std_logic;
            load_10         : in std_logic;
            load_28         : in std_logic;
            load_40         : in std_logic;
            load_50         : in std_logic;
            q_out_register  : out std_logic_vector(5 downto 0)
        );
    end component;

    component time_comparator is
        port (
            current_time    : in std_logic_vector(5 downto 0);
            q_out_register  : in std_logic_vector(5 downto 0);
            eq_comparator   : out std_logic;
            lt_comparator   : out std_logic
        );
    end component;

    -- Sinais internos
    signal current_time_sig    : std_logic_vector(5 downto 0);
    signal q_out_register_sig  : std_logic_vector(5 downto 0);

begin

    -- Instância do contador
    U1: tempo_counter
        port map (
            clk          => clk,
            reset_n      => reset_n,
            enable_count => enable_count,
            clear_count  => clear_count,
            current_time => current_time_sig
        );

    -- Instância do registrador de carga paralela
    U2: parallel_register
        port map (
            clk            => clk,
            reset_n        => reset_n,
            load_2        => load_2,
            load_10        => load_10,
            load_28        => load_28,
            load_40        => load_40,
            load_50        => load_50,
            q_out_register => q_out_register_sig
        );

    -- Instância do comparador
    U3: time_comparator
        port map (
            current_time    => current_time_sig,
            q_out_register  => q_out_register_sig,
            eq_comparator   => eq_comparator,
            lt_comparator   => lt_comparator
        );

end architecture Structural;

-- Divisor de clock com entrada de 50MHz e saída de 1Hz --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DivisorClock is
port ( clk_50hz : in std_logic;
       reset : in std_logic;
       clk : out std_logic
     );
end DivisorClock;

architecture Behavioral of DivisorClock is

--signal count : integer := 0;
signal b : std_logic := '0';
begin

-- Geração do Clock. Para um clock de 50MHz esse process gera um sinal de clock de 1Hz.
process(clk_50hz, b)
	variable cnt : integer range 0 to 2**26-1;
	begin
		if(rising_edge(clk_50hz)) then
		   if(reset = '1') then
			   cnt := 0;
			else
			   cnt := cnt + 1;
         end if;
			if(cnt = 24999999) then
				b <= not b;
				cnt := 0;
			end if;
		end if;
		clk <= b;
	end process;
end;