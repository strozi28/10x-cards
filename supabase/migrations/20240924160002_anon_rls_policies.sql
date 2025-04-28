-- Migration: 20240924160002_anon_rls_policies.sql
-- Description: Creates Row Level Security policies for anonymous users
-- Tables: flashcards, generation_sessions, generation_error_logs
-- Author: AI Assistant
-- Date: 2024-09-24

-- ----------------------------------------------------------------------------
-- RLS policies for anonymous users
-- Note: Anonymous users should not have access to most of the application data
-- These policies are mostly denying access explicitly
-- ----------------------------------------------------------------------------

-- Flashcards - anonymous policies
-- Deny all operations for anonymous users on flashcards table
create policy "anonymous users cannot access flashcards"
on flashcards
for all
to anon
using (false);

-- Generation sessions - anonymous policies
-- Deny all operations for anonymous users on generation_sessions table
create policy "anonymous users cannot access generation sessions"
on generation_sessions
for all
to anon
using (false);

-- Generation error logs - anonymous policies
-- Deny all operations for anonymous users on generation_error_logs table
create policy "anonymous users cannot access error logs"
on generation_error_logs
for all
to anon
using (false); 