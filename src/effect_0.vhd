----------------------------------------------------------------------------------
-- Engineer: Postman
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity effect_0 is
  generic(
  	divider  : integer := 14850;
  	clk_freq : integer := 74250000
  	);
  port (
	clk		: in std_logic;
	chan_0_out : out std_logic_vector(7 downto 0);
	btn_dat : in std_logic_vector(3 downto 0);
	snes_dat : in std_logic_vector(11 downto 0)
  ) ;
end entity ; 

architecture arch of effect_0 is

constant KEY_A				      : integer	:= 8;
constant KEY_B				      : integer	:= 0;
constant KEY_SELECT		      : integer	:= 2;
constant KEY_START		      : integer	:= 3;
constant KEY_UP				      : integer	:= 4;
constant KEY_DOWN			      : integer	:= 5;
constant KEY_LEFT			      : integer	:= 6;
constant KEY_RIGHT		      : integer	:= 7;
constant KEY_X 					  : integer := 9;
constant KEY_Y 					  : integer := 1;
constant KEY_L 					  : integer := 10;
constant KEY_R 					  : integer := 11; 	

signal CNT_LIMIT		: integer	:= 3000;
--constant CNT_ADD		: integer	:= AUDIO_RATE/100;
signal audio_cnt		: integer := 0;
signal valid_cnt  		: integer := 0;

signal clk_gen 			: std_logic := '0';
signal clk_gen_sr  		: std_logic_vector(2 downto 0) := (others => '0');

signal sound_stg_0      : unsigned(24 downto 0) := (others => '0');
signal sound_stg_1      : unsigned(24 downto 0) := (others => '0');
signal sound_stg_2      : unsigned(24 downto 0) := (others => '0');
signal sound_stg_3      : unsigned(24 downto 0) := (others => '0');
signal sound_dat        : std_logic_vector(7 downto 0) := (others => '0');

signal rom_addr1  		: unsigned(7 downto 0) := (others => '0');
signal rom_addr2  		: unsigned(7 downto 0) := (others => '0');

signal mode_sel  		: integer range 0 to 31 := 0;

signal octave  			: unsigned(7 downto 0);

type dat_lut is array (0 to 31) of std_logic_vector(15 downto 0);

signal ROM : dat_lut := (
	x"0001", --0
	x"0800", --1
	x"1000", --2
	x"1800", --3
	x"2000", --4
	x"2800", --5
	x"3000", --6
	x"3800", --7
	x"4000", --8
	x"4800", --9
	x"5000", --10
	x"5800", --11
	x"6000", --12
	x"6800", --13
	x"7000", --14
	x"7800", --15
	x"8000", --16
	x"8800", --17
	x"9000", --18
	x"9800", --19
	x"A000", --20
	x"A800", --21
	x"B000", --22
	x"B800", --23
	x"C000", --24
	x"C800", --25
	x"D000", --26
	x"D800", --27
	x"E000", --28
	x"E800", --29
	x"F000", --30
	x"F800" --31
	);

begin

clk_gen_inst : process(clk)
begin
	if rising_edge(clk) then
		if(audio_cnt = CNT_LIMIT)then
			audio_cnt		<= 0;
			clk_gen 		<= '1';
		else
			audio_cnt		<= audio_cnt + 1;
			clk_gen         <= '0';
		end if;
	end if;
end process;

shift_reg : process( clk,clk_gen )
begin
	if(rising_edge(clk)) then
		clk_gen_sr <= clk_gen_sr(1 downto 0) & clk_gen;
	end if;
end process ; -- identifier

mode_select : process( clk )
begin
	if(rising_edge(clk)) then
		if(clk_gen_sr(2 downto 1) = "01" or clk_gen_sr(2 downto 1) = "10") then
			sound_dat <= std_logic_vector(octave);
			if(snes_dat = x"008" or snes_dat = x"088") then
				if(mode_sel = 31) then
					mode_sel <= 0;
				else
					mode_sel <= mode_sel + 1;
				end if;
				if(octave > to_unsigned(255,8)) then
					octave <= to_unsigned(0,8);
				else
					octave <= octave + to_unsigned(1,8);
				end if ;
			end if;
			if(snes_dat = x"010" or snes_dat = x"090") then
				if(mode_sel = 0) then
					mode_sel <= 31;
				else
					mode_sel <= mode_sel - 1;
				end if;
				if(octave < to_unsigned(0,8)) then
					octave <= to_unsigned(255,8);
				else
					octave <= octave - to_unsigned(1,8);
				end if ;
			end if;
			if(snes_dat = x"080") then
				--if(valid_cnt = clk_freq/10) then
					valid_cnt <= 0;
					if(CNT_LIMIT > 10000) then
						CNT_LIMIT <= 100;
					else
						CNT_LIMIT <= CNT_LIMIT + 10;
					end if;
				--else
				--	valid_cnt <= valid_cnt + 1;
				--end if;
			end if;	
		end if;	
	end if;
end process ; -- mode_select

--sound_gen : process( clk,clk_gen_sr )
--begin
--	if(rising_edge(clk)) then
--		if(clk_gen_sr(2 downto 1) = "01") then
			--sound_stg_0 <= ('0' & ROM(mode_sel)(15 downto 0)) * (ROM(mode_sel)(7 downto 0));
			--sound_stg_1 <= sound_stg_0 + ROM(mode_sel)(15 downto 0);
			--sound_stg_2 <= sound_stg_1 + ROM(mode_sel)(15 downto 0);
			--sound_stg_3 <= sound_stg_2 + ROM(mode_sel)(15 downto 0);
			--sound_dat   <= ROM(mode_sel)(15 downto 0);
			--if(snes_dat = x"800") then
--				sound_dat <= std_logic_vector(octave);
			--else
			--	sound_dat <= (others => '0');
			--end if;
			--sound_loop : for i in 0 to 15 loop
			--	sound_dat(i downto i)   <= ROM(mode_sel)(i downto i);
			--end loop ; -- identifier
--		end if ;
--	end if;	
--end process ; -- identifier

--chan_0_out <= std_logic_vector(resize(unsigned(sound_dat),8));
--chan_0_out <= sound_dat(15) & sound_dat(13) & sound_dat(11) & sound_dat(9) & sound_dat(7) & sound_dat(5) & sound_dat(3) & sound_dat(1);
chan_0_out <= sound_dat;

end architecture ; -- arch