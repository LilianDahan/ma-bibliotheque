-- Run in Supabase SQL editor. Every table is private to the signed-in user.
create table if not exists public.books (
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 title text not null, author text not null, isbn text, publisher text, imprint text,
 publication_year text, translator text, pages integer, cover_url text, notes text default '',
 owned boolean not null default false, reading_status text not null default 'unread' check (reading_status in ('unread','reading','finished','abandoned')),
 created_at timestamptz not null default now()
);
create table if not exists public.collections (
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 name text not null, created_at timestamptz not null default now(), unique(user_id,name)
);
create table if not exists public.collection_authors (
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 collection_id uuid not null references public.collections(id) on delete cascade, author text not null,
 unique(collection_id,author)
);
create table if not exists public.collection_books (
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 collection_id uuid not null references public.collections(id) on delete cascade, book_id uuid not null references public.books(id) on delete cascade,
 unique(collection_id,book_id)
);
create table if not exists public.collection_exclusions (
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 collection_id uuid not null references public.collections(id) on delete cascade, book_id uuid not null references public.books(id) on delete cascade,
 unique(collection_id,book_id)
);
-- Enforce ownership of referenced rows even when a client submits foreign UUIDs.
create or replace function public.check_library_relations() returns trigger language plpgsql set search_path = public as $$
begin
 if not exists(select 1 from public.collections where id=new.collection_id and user_id=new.user_id) then raise exception 'Invalid collection'; end if;
 if tg_table_name in ('collection_books','collection_exclusions') and not exists(select 1 from public.books where id=new.book_id and user_id=new.user_id) then raise exception 'Invalid book'; end if;
 return new;
end; $$;
create trigger check_collection_authors before insert or update on public.collection_authors for each row execute function public.check_library_relations();
create trigger check_collection_books before insert or update on public.collection_books for each row execute function public.check_library_relations();
create trigger check_collection_exclusions before insert or update on public.collection_exclusions for each row execute function public.check_library_relations();
do $$ declare t text; begin
 foreach t in array array['books','collections','collection_authors','collection_books','collection_exclusions'] loop
 execute format('alter table public.%I enable row level security',t);
 execute format('create policy "owner only" on public.%I for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))',t);
 end loop;
end $$;
create index if not exists books_user_idx on public.books(user_id);
create index if not exists collections_user_idx on public.collections(user_id);
