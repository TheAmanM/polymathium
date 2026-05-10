create table public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  institution_id uuid references public.institutions (id) on delete cascade,
  role public.platform_role not null,
  created_at timestamptz not null default timezone('utc', now()),
  unique (user_id, institution_id, role)
);

comment on table public.user_roles is 'Global or institution-scoped RBAC memberships. Null institution_id means platform-wide.';
