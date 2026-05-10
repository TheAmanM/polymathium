create table public.assignments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null,
  title text not null,
  description_markdown text,
  assignment_type public.assignment_type not null default 'assignment',
  status public.assignment_status not null default 'draft',
  points_possible numeric(8,2) not null default 100.00,
  due_at timestamptz,
  available_from timestamptz,
  available_until timestamptz,
  created_by uuid references public.users (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (id, course_id),
  constraint assignments_course_fk
    foreign key (course_id)
    references public.courses (id)
    on delete cascade,
  constraint assignments_points_non_negative
    check (points_possible >= 0),
  constraint assignments_valid_window
    check (
      (available_until is null or available_from is null or available_until >= available_from)
      and (due_at is null or available_from is null or due_at >= available_from)
    )
);

comment on table public.assignments is 'Phase 1 stub for future assignments and quizzes, attached to modules through module_items.';
