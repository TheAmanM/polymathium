create table public.announcements (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null,
  author_enrollment_id uuid,
  title text not null,
  body_markdown text not null,
  published_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint announcements_course_fk
    foreign key (course_id) references public.courses (id) on delete cascade,
  constraint announcements_author_fk
    foreign key (author_enrollment_id, course_id)
    references public.enrollments (id, course_id)
    on delete set null (author_enrollment_id)
);

comment on table public.announcements is 'Course broadcast messages stored as markdown with draft/publish support.';
