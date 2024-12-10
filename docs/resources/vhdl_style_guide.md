# VHDL Style Guide
This is the VHDL style guide for EELE 467 (not to be confused with the VHDL Style Guide program that automatically formats your VHDL code). This style guide is fairly minimal; you have some leeway in how you format your code.

The 


## Naming Conventions
### Filenames
File names must match the entity name. File names should be `snake_case`.

`.vhd` or `.vhdl` extensions are acceptable.

### Constants
Constants should be `ALL_CAPS` to distinguish them from normal signals.

### Generics
Generics should be `ALL_CAPS` since they are essentially constants.

### Keywords
All VHDL keywords should be lowercase. 

### All others
Everything identifier besides constants should be `snake_case` (e.g., entity names, signal names, architecture names, etc.).

### Active-low signals
Active-low signals (i.e., signals where a '0' is on/true/active) should be suffixed by `_n`, e.g., `reset_n`. This way we always know if the signal is active-high or active-low.

## Formatting

### Indentation
Indent using 2 or 4 spaces, **not tabs**.

You should set your editor to use soft tabs with the tab size set to 2 (or 4) spaces. Soft tabs tell the editor to insert spaces when you press the tab key.

**Reasoning**

Using soft tabs ensures that your file looks the same in any editor; different editors display hard tabs with different numbers of spaces. Additionally, mixing of hard tabs and spaces makes your indentation very messed up in editors that display hard tabs with a different number of spaces than what you used.

VHDL code often requires a lot of nesting, so using smaller indent sizes helps keep line lengths shorter.

### (Preferred) Line length
Prefer keeping lines under 80 characters long. This is a *soft* limit, not a hard limit.

If a line is much longer than 80 characters, break the line and continue on the next line.


### Signal declarations
Only declare one signal per line:
```vhdl
-- do this
signal sig1: std_ulogic;
signal sig2: std_ulogic;

-- not this
signal sig1, sig2: std_ulogic;
```

**Reasoning**

This makes the code easier to scan because we can follow the left margin of the code and read the declarations only from top to bottom, without needing to scan the code from left to right as well. It is also easier to add, delete, comment-out, or move a declaration without affecting the others. Finally, it makes compile errors easier to locate because each line number corresponds to only one declaration.

### `rising_edge`
Use the modern `rising_edge(clk)` style instead of `clk'event and clk = '1'`.

### Conditional statements
#### (Preferred) Parentheses
Prefer not using parentheses in conditional statements. Parentheses are not required in VHDL. Not using parentheses helps us remember that we're not writing C code 🙂.

You may use parentheses to group logical conditions together for readability.

#### Indentation
Format `if` statements as follows:

```vhdl
if condition1 then
  -- indent by one level
elsif condition2 then
  -- indent by one level
else
  -- indent by one level
end if;
```

### Case statements

- Indent cases by one level
- Indent statements within a case by two levels

Example:
```vhdl
case state is

  when state_wait =>
    if input = '1' then
      state <= state_ignore_press_bounces;
    else
      state <= state_wait;
    end if;

  when state_reset_counter =>
    state <= state_ignore_release_bounces;

  when others =>
    null

end case;
```

### Entity declarations

- Put each port on its own line
- Put closing parentheses on a new line
- Indent the `generic` and `port` sections by one level
- Indent port names by two levels

Example:
```vhdl
entity timed_counter is
  generic (
    CLK_PERIOD : time;
    COUNT_TIME : time
  );
  port (
    clk    : in    std_ulogic;
    enable : in    boolean;
    done   : out   boolean
  );
end entity timed_counter;
```

### Port maps

Port maps follow the same general rules as entity declarations.

Use *named associations* in your port maps. Using named associations is more clear and less prone to bugs than using positional associations.

```vhdl
-- use named associations
dut_100ns_counter : component timed_counter
generic map (
    CLK_PERIOD => CLK_PERIOD,
    COUNT_TIME => HUNDRED_NS
)
port map (
    clk    => clk_tb,
    enable => enable_100ns_tb,
    done   => done_100ns_tb
);

-- not positional associations
dut_100ns_counter : component timed_counter
generic map (CLK_PERIOD, HUNDRED_NS)
port map (clk_tb, enable_100ns_tb, done_100ns_tb);
```