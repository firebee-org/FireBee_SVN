LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

PACKAGE io_register_pkg IS
    TYPE access_width_t IS (LONGWORD, WORD, BYTE);
    
    COMPONENT io_register IS
    /*
        GENERIC
        (
            NULL
        );
    */
        PORT
        (
            adress          : IN UNSIGNED (31 DOWNTO 0);
            address_mask    : IN UNSIGNED (31 DOWNTO 0);
            access_type     : IN access_width_t
            
        );
    END COMPONENT;
END PACKAGE;

----------------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

ENTITY io_register IS
/*
    GENERIC
    (
        NULL
    );
*/
    PORT
    (
        adress          : IN UNSIGNED (31 DOWNTO 0);
        address_mask    : IN UNSIGNED (31 DOWNTO 0);
        access_type     : IN access_width_t
    );
END ENTITY io_register;

ARCHITECTURE rtl OF io_register IS
BEGIN
END rtl;