library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cam_4x is
  generic (
    addr_width : integer := 10;
    tag_width : integer := 96
    );
  
  port (
    clk   : in std_logic;               -- clock
    reset : in std_logic;               -- reset, positive

    rd : in std_logic;                  -- Read
    wr : in std_logic;                  -- Write
    er : in std_logic;                  -- Erase

    data_in : in std_logic_vector(addr_width-1 downto 0);
    tag_in  : in std_logic_vector(tag_width-1 downto 0);
    
    data_out : out std_logic_vector(addr_width-1 downto 0);
    
    full     : out std_logic;
    hit      : out std_logic;
    ack      : out std_logic
    );
end cam_4x;


architecture RTL of cam_4x is
  
  constant addr_depth : integer := 2 ** (addr_width-2);

  type data_array is array (0 to addr_depth-1) of std_logic_vector(addr_width-1 downto 0);
  type tag_array is array (0 to addr_depth-1) of std_logic_vector(tag_width-1 downto 0);
  
  signal tag_0  : tag_array;
  signal tag_1  : tag_array;
  signal tag_2  : tag_array;
  signal tag_3  : tag_array;
  
  signal data_0 : data_array;
  signal data_1 : data_array;
  signal data_2 : data_array;
  signal data_3 : data_array;
  
  signal addr : unsigned(addr_width-1 downto 0);

  signal freelist_0 : std_logic_vector(addr_depth-1 downto 0);
  signal freelist_1 : std_logic_vector(addr_depth-1 downto 0);
  signal freelist_2 : std_logic_vector(addr_depth-1 downto 0);
  signal freelist_3 : std_logic_vector(addr_depth-1 downto 0);

  type StateType is (IDLE, WRITE_STATE, ERASE_STATE);
  signal state : StateType := IDLE;
  
begin
  
  process(clk)
    variable addr_tmp_0 : unsigned(addr_width-2 downto 0);
    variable data_tmp_0 : std_logic_vector(addr_width-1 downto 0);
    variable hit_tmp_0  : std_logic;
    
    variable addr_tmp_1 : unsigned(addr_width-2 downto 0);
    variable data_tmp_1 : std_logic_vector(addr_width-1 downto 0);
    variable hit_tmp_1  : std_logic;
    
    variable addr_tmp_2 : unsigned(addr_width-2 downto 0);
    variable data_tmp_2 : std_logic_vector(addr_width-1 downto 0);
    variable hit_tmp_2  : std_logic;
    
    variable addr_tmp_3 : unsigned(addr_width-2 downto 0);
    variable data_tmp_3 : std_logic_vector(addr_width-1 downto 0);
    variable hit_tmp_3  : std_logic;
    
  begin
    if (clk'event and clk = '1') then
      if (reset = '1') then
        tag_0      <= (others => (others => '0'));
        data_0     <= (others => (others => '0'));
        freelist_0 <= (others => '0');
        tag_1      <= (others => (others => '0'));
        data_1     <= (others => (others => '0'));
        freelist_1 <= (others => '0');
        tag_2      <= (others => (others => '0'));
        data_2     <= (others => (others => '0'));
        freelist_2 <= (others => '0');
        tag_3      <= (others => (others => '0'));
        data_3     <= (others => (others => '0'));
        freelist_3 <= (others => '0');
        full     <= '0';
        hit      <= '0';
        ack      <= '0';
        state    <= IDLE;
        data_out <= (others => '0');
      else
        case state is
          when IDLE =>
            ------------------------------------------------------
            -- write the given tag
            ------------------------------------------------------
            if rd = '0' and er = '0' and wr = '1' then
              addr_tmp_0 := (others => '1');       -- not found
              addr_tmp_1 := (others => '1');       -- not found
              addr_tmp_2 := (others => '1');       -- not found
              addr_tmp_3 := (others => '1');       -- not found
              for i in 0 to addr_depth-1 loop      -- search free address
                if freelist_0(i) = '0' then
                  addr_tmp_0 := to_unsigned(i, addr_tmp_0'length);
                end if;
                if freelist_1(i) = '0' then
                  addr_tmp_1 := to_unsigned(i, addr_tmp_1'length);
                end if;
                if freelist_2(i) = '0' then
                  addr_tmp_2 := to_unsigned(i, addr_tmp_2'length);
                end if;
                if freelist_3(i) = '0' then
                  addr_tmp_3 := to_unsigned(i, addr_tmp_3'length);
                end if;
              end loop;
              if addr_tmp_0(addr_width-2) = '1' and addr_tmp_1(addr_width-2) = '1' and addr_tmp_2(addr_width-2) = '1' and addr_tmp_3(addr_width-2) = '1' then
                full <= '1';
                ack  <= '1';
              else
                full  <= '0';
                state <= WRITE_STATE;
                if addr_tmp_0(addr_width-2) = '0' then
                  addr <= "00" & addr_tmp_0(addr_width-1-2 downto 0);
                elsif addr_tmp_1(addr_width-2) = '0' then
                  addr <= "01" & addr_tmp_1(addr_width-1-2 downto 0);
                elsif addr_tmp_2(addr_width-2) = '0' then
                  addr <= "10" & addr_tmp_2(addr_width-1-2 downto 0);
                elsif addr_tmp_3(addr_width-2) = '0' then
                  addr <= "11" & addr_tmp_3(addr_width-1-2 downto 0);
                end if;
                ack <= '0';
              end if;
            ------------------------------------------------------
            -- read the data for the given tag or erase the contents
            ------------------------------------------------------
            elsif (rd = '1' or er = '1') and wr = '0' then
              hit_tmp_0  := '0';
              addr_tmp_0 := (others => '1');       -- not found
              hit_tmp_1  := '0';
              addr_tmp_1 := (others => '1');       -- not found
              hit_tmp_2  := '0';
              addr_tmp_2 := (others => '1');       -- not found
              hit_tmp_3  := '0';
              addr_tmp_3 := (others => '1');       -- not found
              for i in 0 to addr_depth-1 loop      --   Check for data
                if tag_in = tag_0(i) and freelist_0(i) = '1' then
                  -- stored data equal the given tag and available
                  hit_tmp_0  := hit_tmp_0 or '1';  -- found tag
                  data_tmp_0 := data_0(i);
                  addr_tmp_0 := to_unsigned(i, addr_tmp_0'length);
                end if;
                if tag_in = tag_1(i) and freelist_1(i) = '1' then
                  -- stored data equal the given tag and available
                  hit_tmp_1  := hit_tmp_1 or '1';  -- found tag
                  data_tmp_1 := data_1(i);
                  addr_tmp_1 := to_unsigned(i, addr_tmp_1'length);
                end if;
                if tag_in = tag_2(i) and freelist_2(i) = '1' then
                  -- stored data equal the given tag and available
                  hit_tmp_2  := hit_tmp_2 or '1';  -- found tag
                  data_tmp_2 := data_2(i);
                  addr_tmp_2 := to_unsigned(i, addr_tmp_2'length);
                end if;
                if tag_in = tag_3(i) and freelist_3(i) = '1' then
                  -- stored data equal the given tag and available
                  hit_tmp_3  := hit_tmp_3 or '1';  -- found tag
                  data_tmp_3 := data_3(i);
                  addr_tmp_3 := to_unsigned(i, addr_tmp_3'length);
                end if;
              end loop;
              if rd = '1' then
                hit <= hit_tmp_0 or hit_tmp_1 or hit_tmp_2 or hit_tmp_3;
                if hit_tmp_0 = '1' then
                  data_out <= data_tmp_0;
                elsif hit_tmp_1 = '1' then
                  data_out <= data_tmp_1;
                elsif hit_tmp_2 = '1' then
                  data_out <= data_tmp_2;
                elsif hit_tmp_3 = '1' then
                  data_out <= data_tmp_3;
                else
                  data_out <= (others => '0');
                end if;
                ack <= '1';
              else                                 -- er = '1'
                if hit_tmp_0 = '1' or hit_tmp_1 = '1' or hit_tmp_2 = '1' or hit_tmp_3 = '1' then
                  if hit_tmp_0 = '1' then
                    addr <= "00" & addr_tmp_0(addr_width-1-2 downto 0);
                  elsif hit_tmp_1 = '1' then
                    addr <= "01" & addr_tmp_0(addr_width-1-2 downto 0);
                  elsif hit_tmp_2 = '1' then
                    addr <= "10" & addr_tmp_0(addr_width-1-2 downto 0);
                  elsif hit_tmp_3 = '1' then
                    addr <= "11" & addr_tmp_0(addr_width-1-2 downto 0);
                  end if;
                  state <= ERASE_STATE;
                  ack   <= '0';
                else                               -- not found
                  -- nothing to do
                  ack <= '1';
                end if;
              end if;
            else
              hit  <= '0';
              full <= '0';
              ack  <= '0';
            end if;
          when WRITE_STATE =>
            case addr(addr'length-1 downto addr'length-2) is
              when "00" =>
                tag_0(to_integer(addr(addr'length-3 downto 0)))      <= tag_in;
                data_0(to_integer(addr(addr'length-3 downto 0)))     <= data_in;
                freelist_0(to_integer(addr(addr'length-3 downto 0))) <= '1';
              when "01" =>
                tag_1(to_integer(addr(addr'length-3 downto 0)))      <= tag_in;
                data_1(to_integer(addr(addr'length-3 downto 0)))     <= data_in;
                freelist_1(to_integer(addr(addr'length-3 downto 0))) <= '1';
              when "10" =>
                tag_2(to_integer(addr(addr'length-3 downto 0)))      <= tag_in;
                data_2(to_integer(addr(addr'length-3 downto 0)))     <= data_in;
                freelist_2(to_integer(addr(addr'length-3 downto 0))) <= '1';
              when "11" =>
                tag_3(to_integer(addr(addr'length-3 downto 0)))      <= tag_in;
                data_3(to_integer(addr(addr'length-3 downto 0)))     <= data_in;
                freelist_3(to_integer(addr(addr'length-3 downto 0))) <= '1';
              when others => null;
            end case;
            ack   <= '1';
            state <= IDLE;
          when ERASE_STATE =>
            case addr(addr'length-1 downto addr'length-2) is
              when "00" =>
                tag_0(to_integer(addr(addr'length-3 downto 0)))      <= (others => '0');
                data_0(to_integer(addr(addr'length-3 downto 0)))     <= (others => '0');
                freelist_0(to_integer(addr(addr'length-3 downto 0))) <= '0';
              when "01" =>
                tag_1(to_integer(addr(addr'length-3 downto 0)))      <= (others => '0');
                data_1(to_integer(addr(addr'length-3 downto 0)))     <= (others => '0');
                freelist_1(to_integer(addr(addr'length-3 downto 0))) <= '0';
              when "10" =>
                tag_2(to_integer(addr(addr'length-3 downto 0)))      <= (others => '0');
                data_2(to_integer(addr(addr'length-3 downto 0)))     <= (others => '0');
                freelist_2(to_integer(addr(addr'length-3 downto 0))) <= '0';
              when "11" =>
                tag_3(to_integer(addr(addr'length-3 downto 0)))      <= (others => '0');
                data_3(to_integer(addr(addr'length-3 downto 0)))     <= (others => '0');
                freelist_3(to_integer(addr(addr'length-3 downto 0))) <= '0';
              when others => null;
            end case;
            ack   <= '1';
            state <= IDLE;
          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;
  
end RTL;

