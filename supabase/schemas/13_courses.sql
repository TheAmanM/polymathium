create table public.courses (
  id uuid primary key default gen_random_uuid(),
  institution_id uuid not null references public.institutions (id) on delete restrict,
  uid text not null,
  title text not null,
  description text,
  status public.course_status not null default 'draft',
  syllabus_body jsonb,
  syllabus_file_id uuid,
  created_by uuid references public.users (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (institution_id, uid),
  constraint courses_syllabus_body_is_structured
    check (
      syllabus_body is null
      or jsonb_typeof(syllabus_body) in ('object', 'array')
    )
);

comment on column public.courses.syllabus_body is 'Structured syllabus content. Supports future block editors without rewriting the table.';
