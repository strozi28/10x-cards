-- Migration: 20240924160003_utility_functions.sql
-- Description: Creates utility functions and extensions for the 10x-cards application
-- Author: AI Assistant
-- Date: 2024-09-24

-- ----------------------------------------------------------------------------
-- Enable pgcrypto extension for hash functions
-- Used in creating hashes for source text comparisons
-- ----------------------------------------------------------------------------
create extension if not exists pgcrypto;

-- ----------------------------------------------------------------------------
-- Create utility functions
-- ----------------------------------------------------------------------------

-- Function to calculate hash of text content
-- Used for identifying identical source texts
create or replace function hash_text(text_content text)
returns varchar as $$
begin
  return encode(digest(text_content, 'sha256'), 'hex');
end;
$$ language plpgsql security definer;

-- Function to get flashcard statistics for a user
-- Returns count of flashcards by source type
create or replace function get_user_flashcard_stats(user_uuid uuid)
returns table (
  total_count bigint,
  ai_full_count bigint,
  ai_edited_count bigint,
  manual_count bigint
) as $$
begin
  return query
  select
    count(*) as total_count,
    count(*) filter (where source = 'ai-full') as ai_full_count,
    count(*) filter (where source = 'ai-edited') as ai_edited_count,
    count(*) filter (where source = 'manual') as manual_count
  from
    flashcards
  where
    user_id = user_uuid;
end;
$$ language plpgsql security definer; 