LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

PACKAGE io_register_pkg IS
    TYPE access_width_t IS (LONGWORD, WORD, BYTE);
    
    COMPONENT io_register IS
        GENERIC
        (
            address         : IN UNSIGNED (31 DOWNTO 0);
            address_mask    : IN UNSIGNED (31 DOWNTO 0)
        );
        PORT
        (
            address_bus     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            access_type     : IN access_width_t            
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
        address         : IN UNSIGNED (31 DOWNTO 0);
        address_mask    : IN UNSIGNED (31 DOWNTO 0)
    );
    PORT
    (
        address_bus     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        access_type     : IN access_width_t
    );
END ENTITY io_register;

ARCHITECTURE rtl OF io_register IS
    SIGNAL sel          : STD_LOGIC := '0';
BEGIN
    register_select : PROCESS
    BEGIN
        /* IF (address_bus AND address_mask) = (address AND address_mask) THEN
            sel <= '1';
        END IF; */
    END PROCESS register_select;
END rtl;