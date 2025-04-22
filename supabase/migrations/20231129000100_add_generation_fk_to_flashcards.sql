-- migration file: 20231129000100_add_generation_fk_to_flashcards.sql
-- created on utc 2023-11-29 00:01:00
-- purpose: add generation_id column to flashcards table and establish a foreign key relationship to generations to track flashcard origin
-- note: this migration adds an optional column generation_id which references generations(uuid) with on delete set null

-- add generation_id column if it does not already exist
alter table flashcards add column if not exists generation_id uuid;

-- add foreign key constraint linking flashcards.generation_id to generations.uuid
alter table flashcards add constraint fk_flashcards_generation foreign key (generation_id) references generations(uuid) on delete set null;

-- end of migration file 