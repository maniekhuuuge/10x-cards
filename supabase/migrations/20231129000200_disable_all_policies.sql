-- migration file: 20231129000200_disable_all_policies.sql
-- created to disable all RLS policies from flashcards, generations, and generations_error_log tables

-- Drop policies for flashcards table
DROP POLICY IF EXISTS flashcards_select_authenticated ON flashcards;
DROP POLICY IF EXISTS flashcards_select_anon ON flashcards;
DROP POLICY IF EXISTS flashcards_insert_authenticated ON flashcards;
DROP POLICY IF EXISTS flashcards_insert_anon ON flashcards;
DROP POLICY IF EXISTS flashcards_update_authenticated ON flashcards;
DROP POLICY IF EXISTS flashcards_update_anon ON flashcards;
DROP POLICY IF EXISTS flashcards_delete_authenticated ON flashcards;
DROP POLICY IF EXISTS flashcards_delete_anon ON flashcards;

-- Drop policies for generations table
DROP POLICY IF EXISTS generations_select_authenticated ON generations;
DROP POLICY IF EXISTS generations_select_anon ON generations;
DROP POLICY IF EXISTS generations_insert_authenticated ON generations;
DROP POLICY IF EXISTS generations_insert_anon ON generations;
DROP POLICY IF EXISTS generations_update_authenticated ON generations;
DROP POLICY IF EXISTS generations_update_anon ON generations;
DROP POLICY IF EXISTS generations_delete_authenticated ON generations;
DROP POLICY IF EXISTS generations_delete_anon ON generations;

-- Drop policies for generations_error_log table
DROP POLICY IF EXISTS generror_select_authenticated ON generations_error_log;
DROP POLICY IF EXISTS generror_select_anon ON generations_error_log;
DROP POLICY IF EXISTS generror_insert_authenticated ON generations_error_log;
DROP POLICY IF EXISTS generror_insert_anon ON generations_error_log;
DROP POLICY IF EXISTS generror_update_authenticated ON generations_error_log;
DROP POLICY IF EXISTS generror_update_anon ON generations_error_log;
DROP POLICY IF EXISTS generror_delete_authenticated ON generations_error_log;
DROP POLICY IF EXISTS generror_delete_anon ON generations_error_log;

-- Note: RLS remains enabled on the tables, but all policies are removed 