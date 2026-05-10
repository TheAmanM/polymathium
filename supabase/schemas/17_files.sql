create table public.files (
  id uuid primary key default gen_random_uuid(),
  institution_id uuid not null references public.institutions (id) on delete restrict,
  course_id uuid not null references public.courses (id) on delete cascade,
  uploader_id uuid references public.users (id) on delete set null,
  bucket_name text not null,
  s3_key text not null,
  original_filename text not null,
  file_size bigint not null,
  mime_type text not null,
  etag text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (bucket_name, s3_key),
  unique (id, course_id),
  constraint files_metadata_is_object
    check (jsonb_typeof(metadata) = 'object'),
  constraint files_size_non_negative
    check (file_size >= 0)
);

comment on table public.files is 'S3 object metadata and ownership, not the file contents.';

-- Deferred FK: courses.syllabus_file_id could not reference files until files existed.
alter table public.courses
  add constraint courses_syllabus_file_fk
  foreign key (syllabus_file_id)
  references public.files (id)
  on delete set null;
