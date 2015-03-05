CREATE OR REPLACE PACKAGE utp_ts_run IS
  /* Balik pro spousteni unit testu
  */

  /* Globalni promena urcujici urceni vystupu debug vypisu
  */
  gc_debug CHAR(1) := 'O'; --('O'-output,...)

  /* Procedura pro spusteni test case, identifikace pomoci ID

  %param p_id  Primarni klic do tabulky UT_TEST_CASE, identifikace test case
  */
  PROCEDURE run_testcase(p_id IN ut_test_case.id%TYPE);

  /* Procedura pro spusteni test case, identifikace pomoci CODE

  %param p_code  Unikatni klic do tabulky UT_TEST_CASE, identifikace test case
  */
  PROCEDURE run_testcase(p_code ut_test_case.code%TYPE);

  /* Procedura pro spusteni test scriptu, identifikace pomoci ID

  %param p_id  Primarni klic do tabulky UT_TEST_SCRIPT, identifikace test scriptu
  */
  PROCEDURE run_testscript(p_id ut_test_script.id%TYPE);

  /* Procedura pro spusteni test scriptu, identifikace pomoci CODE

  %param p_code  Unikatni klic do tabulky UT_TEST_SCRIPT, identifikace test scriptu
  */
  PROCEDURE run_testscript(p_code ut_test_script.code%TYPE);

  /* Procedura pro spusteni vsech evidovanych testovacich scenaru

  %param p_catch_exception  parametr typu ('Y','N') 'Y' - urcuje zda li dojde pri vyjimce
                            u testovaneho scenare k pokracovani ostatnich scenaru
  */
  PROCEDURE run_alltestscript(p_catch_exception VARCHAR2);
END utp_ts_run;
/

