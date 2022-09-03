--------------------------------------------------------------------------------
-- Engineer: Oleksandr Kiyenko
-- o.kiyenko@gmail.com
--------------------------------------------------------------------------------
library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
entity keys_proc is
generic(
	CLK_FREQ_HZ				: integer	:= 74250000
);
port (
	clk						: in  STD_LOGIC;
	key_in					: in  STD_LOGIC;
	key_out					: out STD_LOGIC						:= '0'
);
end keys_proc;
--------------------------------------------------------------------------------
architecture arch_imp of keys_proc is
--------------------------------------------------------------------------------
type sm_state_t is (ST_IDLE, ST_CHECK, ST_RPT);
signal sm_state		: sm_state_t	:= ST_IDLE;
constant DB_CYCLES	: integer		:= CLK_FREQ_HZ/100;
constant RPT_CYCLES	: integer		:= CLK_FREQ_HZ/2;
signal db_cnt		: integer range 0 to DB_CYCLES	:= 0;
signal rpt_cnt		: integer range 0 to RPT_CYCLES	:= 0;
--------------------------------------------------------------------------------
begin
--------------------------------------------------------------------------------
process(clk)
begin
	if rising_edge(clk) then
		case sm_state is
			when ST_IDLE		=>
				key_out				<= '0';
				db_cnt				<= 0;
				if(key_in = '1')then
					sm_state		<= ST_CHECK;
				end if;
			when ST_CHECK		=>
				if(key_in = '0')then
					sm_state		<= ST_IDLE;
					key_out			<= '0';
				else
					if(db_cnt = DB_CYCLES)then
						db_cnt		<= 0;
						key_out		<= '1';
						rpt_cnt		<= 0;
						sm_state	<= ST_RPT;
					else
						db_cnt		<= db_cnt + 1;
						key_out		<= '0';
					end if;
				end if;
			when ST_RPT			=>
				if(key_in = '0')then
					sm_state		<= ST_IDLE;
					key_out			<= '0';
				elsif(rpt_cnt = RPT_CYCLES)then
					rpt_cnt			<= 0;
					key_out			<= '1';
				else
					rpt_cnt			<= rpt_cnt + 1;
					key_out			<= '0';
				end if;
		end case;
	end if;
end process;
--------------------------------------------------------------------------------
end arch_imp;
