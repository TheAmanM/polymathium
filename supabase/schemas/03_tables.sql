create table public.institutions (
  id uuid primary key default gen_random_uuid(),
  slug citext not null unique,
  name text not null,
  status public.institution_status not null default 'active',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

comment on table public.institutions is 'Tenant boundary for all course and access isolation.';

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

create table public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  institution_id uuid references public.institutions (id) on delete cascade,
  role public.platform_role not null,
  created_at timestamptz not null default timezone('utc', now()),
  unique (user_id, institution_id, role)
);

comment on table public.user_roles is 'Global or institution-scoped RBAC memberships. Null institution_id means platform-wide.';

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

alter table public.courses
  add constraint courses_syllabus_file_fk
  foreign key (syllabus_file_id)
  references public.files (id)
  on delete set null;

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
    foreign key (author_enrollment_id)
    references public.enrollments (id)
    on delete set null
);

comment on table public.announcements is 'Course broadcast messages stored as markdown with draft/publish support.';

create table public.module_items (
  id uuid primary key default gen_random_uuid(),
  module_id uuid not null,
  course_id uuid not null,
  item_type public.module_item_type not null,
  title text,
  content_markdown text,
  file_id uuid,
  assignment_id uuid,
  position integer not null default 0,
  is_published boolean not null default false,
  created_by uuid references public.users (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (id, course_id),
  constraint module_items_module_fk
    foreign key (module_id, course_id)
    references public.modules (id, course_id)
    on delete cascade,
  constraint module_items_file_fk
    foreign key (file_id)
    references public.files (id)
    on delete set null,
  constraint module_items_assignment_fk
    foreign key (assignment_id)
    references public.assignments (id)
    on delete set null,
  constraint module_items_position_non_negative
    check (position >= 0),
  constraint module_items_shape_check
    check (
      (
        item_type = 'rich_text'
        and content_markdown is not null
        and file_id is null
        and assignment_id is null
      ) or (
        item_type = 'file'
        and content_markdown is null
        and file_id is not null
        and assignment_id is null
      ) or (
        item_type = 'rich_text_file'
        and content_markdown is not null
        and file_id is not null
        and assignment_id is null
      ) or (
        item_type = 'assignment'
        and content_markdown is null
        and file_id is null
        and assignment_id is not null
      ) or (
        item_type = 'quiz'
        and content_markdown is null
        and file_id is null
        and assignment_id is not null
      )
    )
);

comment on table public.module_items is 'Ordered module content rows. A module item can be rich text, file-backed, rich text plus file, assignment, or quiz.';
