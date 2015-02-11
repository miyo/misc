library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cam is
  generic (
    addr_width : integer := 8;
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
end cam;


architecture RTL of cam is
  
  constant addr_depth : integer := 2 ** addr_width;

  type data_array is array (0 to addr_depth-1) of std_logic_vector(addr_width-1 downto 0);
  type tag_array is array (0 to addr_depth-1) of std_logic_vector(tag_width-1 downto 0);
  
  signal tag  : tag_array;
  signal data : data_array;
  signal addr : unsigned(addr_width-1 downto 0);

  signal freelist : std_logic_vector(addr_depth-1 downto 0);

  type StateType is (IDLE, WRITE_STATE, ERASE_STATE);
  signal state : StateType := IDLE;
  
begin
  
  process(clk)
    variable addr_tmp : unsigned(addr_width downto 0);
    variable data_tmp : std_logic_vector(addr_width-1 downto 0);
    variable hit_tmp  : std_logic;
  begin
    if (clk'event and clk = '1') then
      if (reset = '1') then
        tag      <= (others => (others => '0'));
        data     <= (others => (others => '0'));
        freelist <= (others => '0');
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
              addr_tmp := (others => '1');     -- not found
              for i in 0 to addr_depth-1 loop  -- search free address
                if freelist(i) = '0' then
                  addr_tmp := to_unsigned(i, addr_tmp'length);
                end if;
              end loop;
              if addr_tmp(addr_width) = '1' then
                full <= '1';
                ack  <= '1';
              else
                full  <= '0';
                state <= WRITE_STATE;
                addr  <= addr_tmp(addr_width-1 downto 0);
                ack   <= '0';
              end if;
            ------------------------------------------------------
            -- read the data for the given tag or erase the contents
            ------------------------------------------------------
            elsif (rd = '1' or er = '1') and wr = '0' then
              hit_tmp  := '0';
              addr_tmp := (others => '1');     -- not found
              for i in 0 to addr_depth-1 loop  --   Check for data
                if tag_in = tag(i) and freelist(i) = '1' then
                  -- stored data equal the given tag and available
                  hit_tmp  := hit_tmp or '1';  -- found tag
                  data_tmp := data(i);
                  addr_tmp := to_unsigned(i, addr_tmp'length);
                end if;
              end loop;
              if rd = '1' then
                hit      <= hit_tmp;
                if hit_tmp = '1' then
                  data_out <= data_tmp;
                else
                  data_out <= (others => '0');
                end if;
                ack      <= '1';
              else                             -- er = '1'
                if hit_tmp = '1' then
                  addr  <= addr_tmp(addr_width-1 downto 0);
                  state <= ERASE_STATE;
                  ack   <= '0';
                else                           -- not found
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
            tag(to_integer(addr))      <= tag_in;
            data(to_integer(addr))     <= data_in;
            freelist(to_integer(addr)) <= '1';
            ack                        <= '1';
            state                      <= IDLE;
          when ERASE_STATE =>
            tag (to_integer(addr))     <= (others => '0');
            data(to_integer(addr))     <= (others => '0');
            freelist(to_integer(addr)) <= '0';
            ack                        <= '1';
            state                      <= IDLE;
          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;
  
end RTL;

