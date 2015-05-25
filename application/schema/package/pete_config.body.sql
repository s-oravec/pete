CREATE OR REPLACE PACKAGE BODY pete_config AS

    g_show_asserts        NUMBER;
    g_show_hook_methods   BOOLEAN;
    g_show_failures_only  BOOLEAN;
    g_test_package_prefix VARCHAR2(30);
    g_date_format         VARCHAR2(30);

    C_TRUE  VARCHAR2(10) := 'TRUE';
    C_FALSE VARCHAR2(10) := 'FALSE';

    --config table keys
    SHOW_ASSERTS        VARCHAR2(30) := 'SHOW_ASSERTS';
    SHOW_HOOK_METHODS   VARCHAR2(30) := 'SHOW_HOOK_METHODS';
    SHOW_FAILURES_ONLY  VARCHAR2(30) := 'SHOW_FAILURES_ONLY';
    TEST_PACKAGE_PREFIX VARCHAR2(30) := 'TEST_PACKAGE_PREFIX';
    DATE_FORMAT         VARCHAR2(30) := 'DATE_FORMAT';

    -- reads value from config table
    --------------------------------------------------------------------------------
    FUNCTION get_param
    (
        a_key_in           IN pete_configuration.key%TYPE,
        a_default_value_in IN pete_configuration.value%TYPE DEFAULT NULL
    ) RETURN pete_configuration.value%TYPE IS
    BEGIN
        FOR config IN (SELECT VALUE
                         FROM pete_configuration c
                        WHERE key = a_key_in)
        LOOP
            RETURN config.value;
        END LOOP;
        --
        RETURN a_default_value_in;
        --
    END get_param;

    --------------------------------------------------------------------------------
    FUNCTION get_boolean_param
    (
        a_key_in           IN pete_configuration.key%TYPE,
        a_default_value_in IN BOOLEAN
    ) RETURN BOOLEAN IS
        l_value pete_configuration.value%TYPE;
    BEGIN
        l_value := get_param(a_key_in);
    
        IF (l_value = C_TRUE)
        THEN
            RETURN TRUE;
        ELSIF (l_value = C_FALSE)
        THEN
            RETURN FALSE;
        ELSE
            RETURN a_default_value_in;
        END IF;
    
    END;

    --writes a value into the config table
    --------------------------------------------------------------------------------
    PROCEDURE set_param
    (
        a_key_in   IN pete_configuration.key%TYPE,
        a_value_in IN pete_configuration.value%TYPE
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

    --wrapper for boolean params
    --------------------------------------------------------------------------------
    PROCEDURE set_boolean_param
    (
        a_key_in   IN pete_configuration.key%TYPE,
        a_value_in IN BOOLEAN
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
    PROCEDURE set_show_asserts
    (
        a_value_in       IN NUMBER,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    ) IS
    
    BEGIN
        g_show_asserts := a_value_in;
        IF (a_set_as_default)
        THEN
            set_param(SHOW_ASSERTS, a_value_in);
        END IF;
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_show_asserts RETURN NUMBER IS
    BEGIN
        RETURN g_show_asserts;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE set_show_hook_methods
    (
        a_value_in       IN BOOLEAN,
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
    PROCEDURE set_show_failures_only
    (
        a_value_in       IN BOOLEAN,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    ) IS
    
    BEGIN
        g_show_failures_only := a_value_in;
        IF (a_set_as_default)
        THEN
            set_boolean_param(SHOW_FAILURES_ONLY, a_value_in);
        END IF;
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_show_failures_only RETURN BOOLEAN IS
    BEGIN
        RETURN g_show_failures_only;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE set_test_package_prefix
    (
        a_value_in       IN VARCHAR2 DEFAULT g_TEST_PACKAGE_PREFIX_DEFAULT,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    ) IS
    BEGIN
        g_test_package_prefix := a_value_in;
        IF a_set_as_default
        THEN
            set_param(TEST_PACKAGE_PREFIX, a_value_in);
        END IF;
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_test_package_prefix RETURN VARCHAR2 IS
    BEGIN
        RETURN g_test_package_prefix;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE set_date_format
    (
        a_value_in       IN VARCHAR2 DEFAULT g_DATE_FORMAT_DEFAULT,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    ) IS
    BEGIN
        g_date_format := a_value_in;
        IF a_set_as_default
        THEN
            set_param(DATE_FORMAT, a_value_in);
        END IF;
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_date_format RETURN VARCHAR2 IS
    BEGIN
        RETURN g_date_format;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE init IS
    BEGIN
        --show asserts
        g_show_asserts := get_param(a_key_in           => SHOW_ASSERTS,
                                    a_default_value_in => g_SHOW_ASSERTS_DEFAULT);
        --show hook methods
        g_show_hook_methods := get_boolean_param(a_key_in           => SHOW_HOOK_METHODS,
                                                 a_default_value_in => g_SHOW_HOOK_METHODS_DEFAULT);
        --show failures only
        g_show_failures_only := get_boolean_param(a_key_in           => SHOW_FAILURES_ONLY,
                                                  a_default_value_in => g_SHOW_FAILURES_ONLY_DEFAULT);
        --test package prefix
        g_test_package_prefix := get_param(a_key_in           => TEST_PACKAGE_PREFIX,
                                           a_default_value_in => g_TEST_PACKAGE_PREFIX_DEFAULT);
        --date format
        g_date_format := get_param(a_key_in           => DATE_FORMAT,
                                   a_default_value_in => g_DATE_FORMAT_DEFAULT);
    END init;

BEGIN
    init;
END;
/
