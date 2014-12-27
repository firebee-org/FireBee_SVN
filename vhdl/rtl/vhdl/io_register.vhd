LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

PACKAGE io_register_pkg IS
    TYPE access_type_t IS (LONGWORD_ACCESS, WORD_ACCESS, BYTE_ACCESS);
    
    COMPONENT io_register IS
        GENERIC
        (
            sensitive       : IN unsigned (31 DOWNTO 0);
            address_mask    : IN unsigned (31 DOWNTO 0)
        );
        PORT
        (
            address         : IN std_logic_vector (31 DOWNTO 0);
            access_type     : IN access_type_t;
            chip_select     : OUT std_logic
        );
    END COMPONENT;
END PACKAGE;

----------------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;
LIBRARY work;
    USE work.io_register_pkg.ALL;
    
ENTITY io_register IS
    GENERIC
    (
        sensitive       : IN unsigned (31 DOWNTO 0);
        address_mask    : IN unsigned (31 DOWNTO 0)
    );
    PORT
    (
        address         : IN std_logic_vector (31 DOWNTO 0);
        access_type     : IN access_type_t;
        chip_select     : OUT std_logic
    );
END ENTITY io_register;

ARCHITECTURE rtl OF io_register IS
    SIGNAL sel          : STD_LOGIC := '0';
BEGIN
    register_select : PROCESS
    BEGIN
        /* IF (address AND address_mask) = (address AND address_mask) THEN
            sel <= '1';
        END IF; */
    END PROCESS register_select;
END rtl;
