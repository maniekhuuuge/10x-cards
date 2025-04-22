-- migration file: 20231129000000_create_schema.sql
-- created on utc 2023-11-29 00:00:00
-- purpose: create tables for flashcards, generations, and generations_error_log with enums, indexes, rls enabled and granular rls policies for each operation and role

-- create enum types for flashcards
create type flashcards_metoda as enum ('ai', 'manual');
create type flashcards_status as enum ('pending', 'accepted', 'rejected');

-- create table flashcards
create table flashcards (
    uuid uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    "przód" varchar(200) not null,
    "tył" varchar(500) not null,
    created_at timestamp not null default now(),
    metoda_tworzna flashcards_metoda not null,
    status_recenzji flashcards_status not null default 'pending',
    generation_id uuid
);

-- create indexes for flashcards to improve query performance
create index idx_flashcards_user_id on flashcards(user_id);
create index idx_flashcards_created_at on flashcards(created_at);
create index idx_flashcards_przod on flashcards("przód");

-- enable row level security (rls) for flashcards
alter table flashcards enable row level security;

-- create rls policies for flashcards

-- select policy for authenticated users: allow access only to their own flashcards
create policy flashcards_select_authenticated on flashcards
  for select
  to authenticated
  using (user_id = auth.uid());

-- select policy for anon users: deny access
create policy flashcards_select_anon on flashcards
  for select
  to anon
  using (false);  -- anon users are not permitted to select

-- insert policy for authenticated users: ensure new flashcard belongs to the user
create policy flashcards_insert_authenticated on flashcards
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- insert policy for anon users: deny insertion
create policy flashcards_insert_anon on flashcards
  for insert
  to anon
  with check (false);

-- update policy for authenticated users: allow updates only on their own flashcards
create policy flashcards_update_authenticated on flashcards
  for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- update policy for anon users: deny updates
create policy flashcards_update_anon on flashcards
  for update
  to anon
  using (false)
  with check (false);

-- delete policy for authenticated users: allow deletion only of their own flashcards
create policy flashcards_delete_authenticated on flashcards
  for delete
  to authenticated
  using (user_id = auth.uid());

-- delete policy for anon users: deny deletion
create policy flashcards_delete_anon on flashcards
  for delete
  to anon
  using (false);

-- add foreign key relationship between flashcards and generations to track from which generation each flashcard was created
alter table flashcards add constraint fk_flashcards_generation foreign key (generation_id) references generations(uuid) on delete set null;

------------------------------------------------------------------------
-- create table generations
create table generations (
    uuid uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    created_at timestamp not null default now(),
    status varchar(50) not null
);

-- create indexes for generations
create index idx_generations_user_id on generations(user_id);
create index idx_generations_created_at on generations(created_at);

-- enable rls for generations
alter table generations enable row level security;

-- create rls policies for generations

-- select policy for authenticated users
create policy generations_select_authenticated on generations
  for select
  to authenticated
  using (user_id = auth.uid());

-- select policy for anon users: deny access
create policy generations_select_anon on generations
  for select
  to anon
  using (false);

-- insert policy for authenticated users
create policy generations_insert_authenticated on generations
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- insert policy for anon users: deny insertion
create policy generations_insert_anon on generations
  for insert
  to anon
  with check (false);

-- update policy for authenticated users
create policy generations_update_authenticated on generations
  for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- update policy for anon users: deny updates
create policy generations_update_anon on generations
  for update
  to anon
  using (false)
  with check (false);

-- delete policy for authenticated users
create policy generations_delete_authenticated on generations
  for delete
  to authenticated
  using (user_id = auth.uid());

-- delete policy for anon users: deny deletion
create policy generations_delete_anon on generations
  for delete
  to anon
  using (false);

------------------------------------------------------------------------
-- create table generations_error_log
create table generations_error_log (
    uuid uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    created_at timestamp not null default now(),
    error_message text not null  -- no size limitation on error_message
);

-- create indexes for generations_error_log
create index idx_generror_user_id on generations_error_log(user_id);
create index idx_generror_created_at on generations_error_log(created_at);

-- enable rls for generations_error_log
alter table generations_error_log enable row level security;

-- create rls policies for generations_error_log

-- select policy for authenticated users
create policy generror_select_authenticated on generations_error_log
  for select
  to authenticated
  using (user_id = auth.uid());

-- select policy for anon users: deny access
create policy generror_select_anon on generations_error_log
  for select
  to anon
  using (false);

-- insert policy for authenticated users
create policy generror_insert_authenticated on generations_error_log
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- insert policy for anon users: deny insertion
create policy generror_insert_anon on generations_error_log
  for insert
  to anon
  with check (false);

-- update policy for authenticated users
create policy generror_update_authenticated on generations_error_log
  for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- update policy for anon users: deny updates
create policy generror_update_anon on generations_error_log
  for update
  to anon
  using (false)
  with check (false);

-- delete policy for authenticated users
create policy generror_delete_authenticated on generations_error_log
  for delete
  to authenticated
  using (user_id = auth.uid());

-- delete policy for anon users: deny deletion
create policy generror_delete_anon on generations_error_log
  for delete
  to anon
  using (false);

-- end of migration file 