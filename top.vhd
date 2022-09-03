----------------------------------------------------------------------------------
-- Engineer: Postman
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
generic(
	num_chan 		: integer := 8;
	num_btn 		: integer := 4;
	num_mode  		: integer := 4
);
port(
	sclk     : in std_logic;
	snd_chan : out std_logic_vector(num_chan-1 downto 0);
	led_chan : out std_logic_vector(num_mode-1 downto 0);
	btn_in   : in  std_logic_vector(num_btn-1 downto 0);			-- btn_in(0) = mode select, btn_in(1) = up, btn_in(2) = down, btn_in(3) = send data
	DATA_NES					: in  STD_LOGIC;
	CLK_NES						: out STD_LOGIC;
	LATCH_NES					: out STD_LOGIC
);
end top;

architecture arch of top is

	constant clk_freq : integer := 74250000;

	signal mode_cnt  	  : integer range 0 to 3 := 0;
	signal snd_chan_buf_0 : std_logic_vector(num_chan-1 downto 0) := (others => '0');
	signal snd_chan_buf_1 : std_logic_vector(num_chan-1 downto 0) := (others => '0');
	signal snd_chan_buf_2 : std_logic_vector(num_chan-1 downto 0) := (others => '0');
	signal snd_chan_buf_3 : std_logic_vector(num_chan-1 downto 0) := (others => '0');

	signal keys_data			  	: STD_LOGIC_VECTOR(15 downto 0);
	signal keys_valid  				: STD_LOGIC_VECTOR(11 downto 0);
	signal keys_in_buf  			: STD_LOGIC_VECTOR(15 downto 0);
	signal keys_in  				: STD_LOGIC_VECTOR(11 downto 0);

	--signal btn_in  		  : std_logic_vector(num_btn-1 downto 0) := (others => '0');

begin

led_chan <= "1111";

--process(sclk)
--begin
--	if(rising_edge(sclk)) then
--		if(btn_in(0) = '0') then
--			if(mode_cnt = 3) then
--				mode_cnt <= 0;
--			else
--				mode_cnt <= mode_cnt + 1;
--			end if;
--		end if;
		--if(btn_in(1) = '0') then
		--	if(mode_cnt = 0) then
		--		mode_cnt <= 3;
		--	else
		--		mode_cnt <= mode_cnt - 1;
		--	end if;
		--end if;

--		case( mode_cnt ) is
		
--			when 0 =>
--				snd_chan <= snd_chan_buf_0;
--				led_chan <= x"0";
--			when 1 =>
--				snd_chan <= snd_chan_buf_1;
--				led_chan <= x"1";
--			when 2 =>
--				snd_chan <= snd_chan_buf_2;
--				led_chan <= x"2";
--			when 3 =>
--				snd_chan <= snd_chan_buf_3;
--				led_chan <= x"4";
--			when others =>
--				snd_chan <= (others => '1');
--				led_chan <= x"8";
--		end case ;
--	end if;
--end process;

ctrl_inst: entity work.nes_controller
generic map(
	C_CLK_DIV						=> 1225
)
port map(
	clk								  => sclk,
	-- R,L,X,A,Right,Left,Down,Up,Start,Select,Y,B - SNES
	-- -,-,-,-,Right,Left,Down,Up,Start,Select,B,A - NES
	data_out						=> keys_in_buf,
	nes_clock						=> CLK_NES,
	nes_latch						=> LATCH_NES,
	nes_data						=> DATA_NES
);

keys_in <= keys_in_buf(11 downto 0);

keys_valid(11) 		<= '0';
keys_valid(10) 		<= '0';
keys_valid(9) 		<=  keys_data(11); -- R Button
keys_valid(8) 		<=  keys_data(10); -- L Button
keys_valid(7) 		<=  keys_data(8); -- A Button
keys_valid(6) 		<=  keys_data(7); -- Right Button
keys_valid(5) 		<=  keys_data(6); -- Left Button
keys_valid(4) 		<=  keys_data(5); -- Down Button
keys_valid(3) 		<=  keys_data(4); -- Up Button
keys_valid(2) 		<=  keys_data(3); -- Start Button
keys_valid(1) 		<=  keys_data(2); -- Select Button
keys_valid(0) 		<=  keys_data(0); -- B Button

keys_gen: for i in 0 to 11 generate
	keys_inst: entity work.debounce
	generic map(
		C_DB_CYCLES					=> 100
	)
	port map(
		clk_in							    => sclk,
		btn_in						  => keys_in(i),
		btn_out						  => keys_data(i)
	);
end generate;

effect_0_isnt : entity work.effect_0
generic map(
	divider => 14850,
	clk_freq => clk_freq
	)
port map(
	clk  	   => sclk,
	chan_0_out => snd_chan,
	btn_dat    => btn_in,
	snes_dat   => keys_valid
	);

end architecture ; -- arch