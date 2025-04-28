-- Migration: 20240924160001_initial_schema.sql
-- Description: Creates the initial database schema for 10x-cards application
-- Tables: flashcards, generation_sessions, generation_error_logs
-- Author: AI Assistant
-- Date: 2024-09-24

-- ----------------------------------------------------------------------------
-- Create the generation_sessions table
-- Stores information about flashcard generation sessions using AI
-- ----------------------------------------------------------------------------
create table if not exists generation_sessions (
    id bigserial primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    model_used varchar not null,
    generated_count integer not null default 0,
    accepted_without_edits integer null,
    accepted_with_edits integer null,
    source_text_hash varchar not null,
    source_text_length integer not null check (source_text_length between 1000 and 10000),
    generation_time_ms integer not null,
    created_at timestamptz not null default current_timestamp,
    updated_at timestamptz not null default current_timestamp
);

-- Enable row level security for generation_sessions
alter table generation_sessions enable row level security;

-- Create RLS policies for authenticated users to access their own generation sessions
-- Policy for select operations
create policy "authenticated users can select their own generation sessions"
on generation_sessions
for select
to authenticated
using (auth.uid() = user_id);

-- Policy for insert operations
create policy "authenticated users can insert their own generation sessions"
on generation_sessions
for insert
to authenticated
with check (auth.uid() = user_id);

-- Policy for update operations
create policy "authenticated users can update their own generation sessions"
on generation_sessions
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Policy for delete operations
create policy "authenticated users can delete their own generation sessions"
on generation_sessions
for delete
to authenticated
using (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- Create the flashcards table
-- Stores information about flashcards created by users
-- ----------------------------------------------------------------------------
create table if not exists flashcards (
    id bigserial primary key,
    front varchar(200) not null,
    back varchar(500) not null,
    source varchar not null check (source in ('ai-full', 'ai-edited', 'manual')),
    user_id uuid not null references auth.users(id) on delete cascade,
    generated_at timestamptz not null default current_timestamp,
    updated_at timestamptz not null default current_timestamp,
    generation_id bigint references generation_sessions(id) on delete set null
);

-- Enable row level security for flashcards
alter table flashcards enable row level security;

-- Create RLS policies for authenticated users to access their own flashcards
-- Policy for select operations
create policy "authenticated users can select their own flashcards"
on flashcards
for select
to authenticated
using (auth.uid() = user_id);

-- Policy for insert operations
create policy "authenticated users can insert their own flashcards"
on flashcards
for insert
to authenticated
with check (auth.uid() = user_id);

-- Policy for update operations
create policy "authenticated users can update their own flashcards"
on flashcards
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Policy for delete operations
create policy "authenticated users can delete their own flashcards"
on flashcards
for delete
to authenticated
using (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- Create the generation_error_logs table
-- Records errors occurring during flashcard generation
-- ----------------------------------------------------------------------------
create table if not exists generation_error_logs (
    id bigserial primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    model varchar,
    source_text_hash varchar not null,
    source_text_length integer not null check (source_text_length between 1000 and 10000),
    error_code varchar not null,
    error_message text not null,
    created_at timestamptz not null default current_timestamp
);

-- Enable row level security for generation_error_logs
alter table generation_error_logs enable row level security;

-- Create RLS policies for authenticated users to access their own error logs
-- Policy for select operations
create policy "authenticated users can select their own error logs"
on generation_error_logs
for select
to authenticated
using (auth.uid() = user_id);

-- Policy for insert operations
create policy "authenticated users can insert their own error logs"
on generation_error_logs
for insert
to authenticated
with check (auth.uid() = user_id);

-- Policy for delete operations
create policy "authenticated users can delete their own error logs"
on generation_error_logs
for delete
to authenticated
using (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- Create function for automatic updated_at timestamp
-- ----------------------------------------------------------------------------
create or replace function set_updated_at_timestamp()
returns trigger as $$
begin
  new.updated_at = current_timestamp;
  return new;
end;
$$ language plpgsql;

-- Create trigger for flashcards
create trigger set_flashcards_updated_at
before update on flashcards
for each row
execute function set_updated_at_timestamp();

-- Create trigger for generation_sessions
create trigger set_generation_sessions_updated_at
before update on generation_sessions
for each row
execute function set_updated_at_timestamp();

-- ----------------------------------------------------------------------------
-- Create indexes for better query performance
-- ----------------------------------------------------------------------------
-- Indexes for flashcards table
create index idx_flashcards_user_id on flashcards(user_id);
create index idx_flashcards_generation_id on flashcards(generation_id);
create index idx_flashcards_source on flashcards(source);

-- Indexes for generation_sessions table
create index idx_generation_sessions_user_id on generation_sessions(user_id);
create index idx_generation_sessions_created_at on generation_sessions(created_at);

-- Indexes for generation_error_logs table
create index idx_generation_error_logs_user_id on generation_error_logs(user_id);
create index idx_generation_error_logs_created_at on generation_error_logs(created_at); 