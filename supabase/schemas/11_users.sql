create table public.users (
  id uuid primary key references auth.users (id) on delete cascade,
  primary_email citext unique,
  display_name text,
  full_name text,
  avatar_url text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

comment on table public.users is 'Application profile for a Supabase auth user.';
