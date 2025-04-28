-- Migration: 20240924165001_disable_policies.sql
-- Description: Disables all RLS policies previously defined for the application tables
-- Tables affected: flashcards, generation_sessions, generation_error_logs
-- Author: AI Assistant
-- Date: 2024-09-24

-- ----------------------------------------------------------------------------
-- Drop authenticated user policies from flashcards table
-- ----------------------------------------------------------------------------
drop policy if exists "authenticated users can select their own flashcards" on flashcards;
drop policy if exists "authenticated users can insert their own flashcards" on flashcards;
drop policy if exists "authenticated users can update their own flashcards" on flashcards;
drop policy if exists "authenticated users can delete their own flashcards" on flashcards;

-- ----------------------------------------------------------------------------
-- Drop anonymous user policies from flashcards table
-- ----------------------------------------------------------------------------
drop policy if exists "anonymous users cannot access flashcards" on flashcards;

-- ----------------------------------------------------------------------------
-- Drop authenticated user policies from generation_sessions table
-- ----------------------------------------------------------------------------
drop policy if exists "authenticated users can select their own generation sessions" on generation_sessions;
drop policy if exists "authenticated users can insert their own generation sessions" on generation_sessions;
drop policy if exists "authenticated users can update their own generation sessions" on generation_sessions;
drop policy if exists "authenticated users can delete their own generation sessions" on generation_sessions;

-- ----------------------------------------------------------------------------
-- Drop anonymous user policies from generation_sessions table
-- ----------------------------------------------------------------------------
drop policy if exists "anonymous users cannot access generation sessions" on generation_sessions;

-- ----------------------------------------------------------------------------
-- Drop authenticated user policies from generation_error_logs table
-- ----------------------------------------------------------------------------
drop policy if exists "authenticated users can select their own error logs" on generation_error_logs;
drop policy if exists "authenticated users can insert their own error logs" on generation_error_logs;
drop policy if exists "authenticated users can delete their own error logs" on generation_error_logs;

-- ----------------------------------------------------------------------------
-- Drop anonymous user policies from generation_error_logs table
-- ----------------------------------------------------------------------------
drop policy if exists "anonymous users cannot access error logs" on generation_error_logs;

-- ----------------------------------------------------------------------------
-- Disable Row Level Security at the table level
-- This completely removes security restrictions from the tables
-- ----------------------------------------------------------------------------
alter table flashcards disable row level security;
alter table generation_sessions disable row level security;
alter table generation_error_logs disable row level security;

-- ----------------------------------------------------------------------------
-- Note: Row Level Security is still enabled on all tables
-- After dropping these policies, the tables will be fully restricted
-- (no access for any users) until new policies are defined
-- ----------------------------------------------------------------------------