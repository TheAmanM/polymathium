create table public.institutions (
  id uuid primary key default gen_random_uuid(),
  slug citext not null unique,
  name text not null,
  status public.institution_status not null default 'active',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

comment on table public.institutions is 'Tenant boundary for all course and access isolation.';
