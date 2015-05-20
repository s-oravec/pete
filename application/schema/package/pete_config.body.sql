CREATE OR REPLACE PACKAGE BODY pete_config AS

    g_show_asserts      NUMBER;
    g_show_hook_methods BOOLEAN;

    C_TRUE  VARCHAR2(10) := 'TRUE';
    C_FALSE VARCHAR2(10) := 'FALSE';

    --config table keys
    SHOW_ASSERTS      VARCHAR2(30) := 'SHOW_ASSERTS';
    SHOW_HOOK_METHODS VARCHAR2(30) := 'SHOW_HOOK_METHODS';
    --
    gc_SHOW_ASSERTS_DEFAULT      CONSTANT NUMBER := pete_config.g_ASSERTS_FAILED;
    gc_SHOW_HOOK_METHODS_DEFAULT CONSTANT BOOLEAN := FALSE;

    /**
    * writes a value into the config table
    */
    PROCEDURE set_param
    (
        a_key_in   pete_configuration.key%TYPE,
        a_value_in pete_configuration.value%TYPE
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        MERGE INTO pete_configuration c
        USING (SELECT a_key_in key2, a_value_in value2 FROM dual) d
        ON (c.key = d.key2)
        WHEN MATCHED THEN
            UPDATE SET c.value = d.value2
        WHEN NOT MATCHED THEN
            INSERT (key, VALUE) VALUES (d.key2, d.value2);
        COMMIT;
    END set_param;

    /**
    * WRAPPER FOR BOOLEAN PARAMS
    */
    PROCEDURE set_boolean_param
    (
        a_key_in   pete_configuration.key%TYPE,
        a_value_in BOOLEAN
    ) IS
        l_table_value VARCHAR2(10);
    BEGIN
        IF (a_value_in)
        THEN
            l_table_value := C_TRUE;
        ELSE
            l_table_value := C_FALSE;
        END IF;
        set_param(a_key_in, l_table_value);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE set_show_ASSERTS
    (
        a_value_in       NUMBER,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    ) IS
    
    BEGIN
        g_show_ASSERTS := a_value_in;
        IF (a_set_as_default)
        THEN
            set_param(SHOW_ASSERTS, a_value_in);
        END IF;
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_show_ASSERTS RETURN NUMBER IS
    BEGIN
        RETURN g_show_ASSERTS;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE set_show_hook_methods
    (
        a_value_in       BOOLEAN,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    ) IS
    
    BEGIN
        g_show_hook_methods := a_value_in;
        IF (a_set_as_default)
        THEN
            set_boolean_param(SHOW_HOOK_METHODS, a_value_in);
        END IF;
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_show_hook_methods RETURN BOOLEAN IS
    BEGIN
        RETURN g_show_hook_methods;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE init IS
        l_value pete_configuration.value%TYPE;
    BEGIN
    
        --todo refactoring to read param    
        --show asserts
        BEGIN
            SELECT VALUE
              INTO g_show_ASSERTS
              FROM pete_configuration c
             WHERE c.key = SHOW_ASSERTS;
        EXCEPTION
            WHEN no_data_found THEN
                g_show_ASSERTS := gc_SHOW_ASSERTS_DEFAULT;
        END;
    
        --todo refactoring to read boolean param    
        --show hook methods
        BEGIN
            SELECT VALUE
              INTO l_value
              FROM pete_configuration c
             WHERE c.key = SHOW_HOOK_METHODS;
            --
            IF (l_value = C_TRUE)
            THEN
                g_SHOW_HOOK_METHODS := TRUE;
            ELSE
                g_SHOW_HOOK_METHODS := FALSE;
            END IF;
        
        EXCEPTION
            WHEN no_data_found THEN
                g_SHOW_HOOK_METHODS := gc_SHOW_HOOK_METHODS_DEFAULT;
        END;
    
    END init;

BEGIN
    init;
END;
/
