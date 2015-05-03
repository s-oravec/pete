CREATE OR REPLACE PACKAGE BODY petep_config AS

    g_show_failures_only BOOLEAN;

    C_TRUE  VARCHAR2(10) := 'TRUE';
    C_FALSE VARCHAR2(10) := 'FALSE';

    --config table keys
    SHOW_FAILURES_ONLY VARCHAR2(30) := 'SHOW_FAILURES_ONLY';
    
    --
    gc_SHOW_FAILURES_ONLY_DEFAULT constant boolean := true;

    /**
    * writes a value into konfig table
    */
    PROCEDURE set_param
    (
        a_key_in   pete_config.key%TYPE,
        a_value_in pete_config.value%TYPE
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        MERGE INTO pete_config c
        USING (SELECT a_key_in key2, a_value_in value2 FROM dual) d
        ON (c.key = d.key2)
        WHEN MATCHED THEN
            UPDATE SET c.value = d.value2
        WHEN NOT MATCHED THEN
            INSERT (key, VALUE) VALUES (d.key2, d.value2);
        COMMIT;
    END set_param;

    /**
    * Sets if result shows only failed asserts (true) or all (false).
    * 
    * %param a_value_in
    * %param a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIG and becomes sesssion default
    */
    --------------------------------------------------------------------------------
    PROCEDURE set_show_failures_only
    (
        a_value_in       BOOLEAN,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    ) IS
        l_table_value VARCHAR2(10);
    
    BEGIN
        g_show_failures_only := a_value_in;
        IF (a_set_as_default)
        THEN
            IF (a_value_in)
            THEN
                l_table_value := C_TRUE;
            ELSE
                l_table_value := C_FALSE;
            END IF;
            set_param(SHOW_FAILURES_ONLY, l_table_value);
        END IF;
    END;

    FUNCTION get_show_failures_only RETURN BOOLEAN IS
    BEGIN
        RETURN g_show_failures_only;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE init IS
        l_value pete_config.value%TYPE;
    BEGIN
    
        --show failures only
        BEGIN
            SELECT VALUE
              INTO l_value
              FROM pete_config c
             WHERE c.key = SHOW_FAILURES_ONLY;
            --
            IF (l_value = C_TRUE)
            THEN
                g_show_failures_only := TRUE;
            ELSE
                g_show_failures_only := FALSE;
            END IF;
        
        EXCEPTION
            WHEN no_data_found THEN
                g_show_failures_only := gc_SHOW_FAILURES_ONLY_DEFAULT;
        END;
    
    END init;

BEGIN
    init;
END;
/
