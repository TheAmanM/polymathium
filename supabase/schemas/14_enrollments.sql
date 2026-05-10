create table public.enrollments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses (id) on delete cascade,
  user_id uuid not null references public.users (id) on delete cascade,
  role public.course_role not null,
  status public.enrollment_status not null default 'active',
  permission_overrides jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (course_id, user_id),
  unique (id, course_id),
  constraint enrollments_permission_overrides_is_object
    check (jsonb_typeof(permission_overrides) = 'object')
);

comment on table public.enrollments is 'Course membership and the stable FK target for future submissions and grading tables.';
