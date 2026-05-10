create table public.modules (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null,
  parent_module_id uuid,
  title text not null,
  description text,
  position integer not null default 0,
  is_published boolean not null default false,
  starts_at timestamptz,
  ends_at timestamptz,
  created_by uuid references public.users (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (id, course_id),
  constraint modules_course_fk
    foreign key (course_id) references public.courses (id) on delete cascade,
  constraint modules_parent_fk
    foreign key (parent_module_id, course_id)
    references public.modules (id, course_id)
    on delete cascade,
  constraint modules_not_self_parent
    check (parent_module_id is null or parent_module_id <> id),
  constraint modules_valid_window
    check (ends_at is null or starts_at is null or ends_at >= starts_at)
);
