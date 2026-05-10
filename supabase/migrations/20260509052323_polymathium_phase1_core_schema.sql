-- Phase 1 core schema for Polymathium.
-- Identity stays anchored on auth.users, while public.users stores application profile data.
-- Multi-tenancy is introduced now with institutions so course access can be isolated cleanly.

create extension if not exists pgcrypto;
create extension if not exists citext;

create schema if not exists private;

create type public.platform_role as enum ('admin', 'instructor', 'student', 'ta');
create type public.course_role as enum ('instructor', 'ta', 'student');
create type public.course_status as enum ('draft', 'published', 'archived');
create type public.institution_status as enum ('active', 'inactive', 'archived');
create type public.enrollment_status as enum ('invited', 'active', 'completed', 'dropped');
create type public.assignment_type as enum ('assignment', 'quiz');
create type public.assignment_status as enum ('draft', 'published', 'closed', 'archived');
create type public.module_item_type as enum ('rich_text', 'file', 'rich_text_file', 'assignment', 'quiz');

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

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
    foreign key (author_enrollment_id, course_id)
    references public.enrollments (id, course_id)
    on delete set null (author_enrollment_id)
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
    foreign key (file_id, course_id)
    references public.files (id, course_id)
    on delete set null (file_id),
  constraint module_items_assignment_fk
    foreign key (assignment_id, course_id)
    references public.assignments (id, course_id)
    on delete set null (assignment_id),
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

create index institutions_status_idx
  on public.institutions (status);

create index user_roles_lookup_idx
  on public.user_roles (user_id, institution_id, role);

create index user_roles_institution_role_idx
  on public.user_roles (institution_id, role, user_id);

create unique index user_roles_global_role_uidx
  on public.user_roles (user_id, role)
  where institution_id is null;

create index courses_institution_status_idx
  on public.courses (institution_id, status, created_at desc);

create index enrollments_user_status_idx
  on public.enrollments (user_id, status, created_at desc);

create index enrollments_course_role_status_idx
  on public.enrollments (course_id, role, status, created_at desc);

create index modules_course_parent_position_idx
  on public.modules (course_id, parent_module_id, position);

create index modules_course_published_idx
  on public.modules (course_id, is_published, starts_at, ends_at);

create index assignments_course_status_due_idx
  on public.assignments (course_id, status, due_at);

create index assignments_module_status_idx
  on public.assignments (course_id, assignment_type, status);

create index module_items_module_position_idx
  on public.module_items (module_id, position);

create index module_items_course_type_idx
  on public.module_items (course_id, item_type, is_published, position);

create index module_items_file_idx
  on public.module_items (file_id)
  where file_id is not null;

create index module_items_assignment_idx
  on public.module_items (assignment_id)
  where assignment_id is not null;

create index files_course_created_idx
  on public.files (course_id, created_at desc);

create index files_uploader_created_idx
  on public.files (uploader_id, created_at desc);

create index announcements_course_published_idx
  on public.announcements (course_id, published_at desc);

create trigger set_institutions_updated_at
before update on public.institutions
for each row execute function public.set_updated_at();

create trigger set_users_updated_at
before update on public.users
for each row execute function public.set_updated_at();

create trigger set_courses_updated_at
before update on public.courses
for each row execute function public.set_updated_at();

create trigger set_enrollments_updated_at
before update on public.enrollments
for each row execute function public.set_updated_at();

create trigger set_modules_updated_at
before update on public.modules
for each row execute function public.set_updated_at();

create trigger set_assignments_updated_at
before update on public.assignments
for each row execute function public.set_updated_at();

create trigger set_module_items_updated_at
before update on public.module_items
for each row execute function public.set_updated_at();

create trigger set_files_updated_at
before update on public.files
for each row execute function public.set_updated_at();

create trigger set_announcements_updated_at
before update on public.announcements
for each row execute function public.set_updated_at();

create or replace function private.sync_auth_user_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, primary_email)
  values (new.id, new.email)
  on conflict (id) do update
    set primary_email = excluded.primary_email,
        updated_at = timezone('utc', now());

  return new;
end;
$$;

create or replace function private.validate_module_item_refs()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_file_course_id uuid;
  target_assignment_course_id uuid;
  target_assignment_type public.assignment_type;
begin
  if new.module_id is not null then
    perform 1
      from public.modules m
     where m.id = new.module_id
       and m.course_id = new.course_id;

    if not found then
      raise exception 'module_items.module_id must belong to the same course_id';
    end if;
  end if;

  if new.file_id is not null then
    select f.course_id
      into target_file_course_id
      from public.files f
     where f.id = new.file_id;

    if target_file_course_id is distinct from new.course_id then
      raise exception 'module_items.file_id must reference a file in the same course';
    end if;
  end if;

  if new.assignment_id is not null then
    select a.course_id, a.assignment_type
      into target_assignment_course_id, target_assignment_type
      from public.assignments a
     where a.id = new.assignment_id;

    if target_assignment_course_id is distinct from new.course_id then
      raise exception 'module_items.assignment_id must reference an assignment in the same course';
    end if;

    if new.item_type = 'assignment' and target_assignment_type <> 'assignment' then
      raise exception 'module_items.assignment item_type must reference an assignment record';
    end if;

    if new.item_type = 'quiz' and target_assignment_type <> 'quiz' then
      raise exception 'module_items.quiz item_type must reference a quiz assignment record';
    end if;
  end if;

  return new;
end;
$$;

create or replace function private.validate_file_scope()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_institution_id uuid;
begin
  select c.institution_id
    into target_institution_id
    from public.courses c
   where c.id = new.course_id;

  if target_institution_id is null then
    raise exception 'files.course_id must reference an existing course';
  end if;

  if target_institution_id <> new.institution_id then
    raise exception 'files.institution_id must match the institution of files.course_id';
  end if;

  return new;
end;
$$;

create or replace function private.validate_course_syllabus_file()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_course_id uuid;
begin
  if new.syllabus_file_id is null then
    return new;
  end if;

  select f.course_id
    into target_course_id
    from public.files f
   where f.id = new.syllabus_file_id;

  if target_course_id is distinct from new.id then
    raise exception 'courses.syllabus_file_id must reference a file owned by the same course';
  end if;

  return new;
end;
$$;

create or replace function private.validate_announcement_author()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_course_id uuid;
begin
  if new.author_enrollment_id is null then
    return new;
  end if;

  select e.course_id
    into target_course_id
    from public.enrollments e
   where e.id = new.author_enrollment_id;

  if target_course_id is distinct from new.course_id then
    raise exception 'announcements.author_enrollment_id must belong to the same course';
  end if;

  return new;
end;
$$;

create or replace function private.sync_auth_user_update()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.users
     set primary_email = new.email,
         updated_at = timezone('utc', now())
   where id = new.id;

  return new;
end;
$$;

create or replace function private.guard_enrollment_self_edit()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.user_id = auth.uid()
    and (
      new.role is distinct from old.role
      or new.permission_overrides is distinct from old.permission_overrides
    )
    and not private.has_role(
      array['admin']::public.platform_role[],
      (select c.institution_id from public.courses c where c.id = old.course_id)
    )
    and not exists (
      select 1 from public.enrollments e
       where e.course_id = old.course_id
         and e.user_id = auth.uid()
         and e.id <> old.id
         and e.role = 'instructor'
         and e.status = 'active'
    )
  then
    raise exception 'Cannot modify your own enrollment role or permissions';
  end if;

  return new;
end;
$$;

create trigger guard_enrollment_self_edit
before update on public.enrollments
for each row execute function private.guard_enrollment_self_edit();

create trigger validate_module_item_refs
before insert or update on public.module_items
for each row execute function private.validate_module_item_refs();

create trigger validate_file_scope
before insert or update on public.files
for each row execute function private.validate_file_scope();

create trigger validate_course_syllabus_file
before insert or update on public.courses
for each row execute function private.validate_course_syllabus_file();

create trigger validate_announcement_author
before insert or update on public.announcements
for each row execute function private.validate_announcement_author();

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function private.sync_auth_user_insert();

drop trigger if exists on_auth_user_updated on auth.users;
create trigger on_auth_user_updated
after update of email on auth.users
for each row execute function private.sync_auth_user_update();

insert into public.users (id, primary_email)
select au.id, au.email
  from auth.users au
on conflict (id) do update
  set primary_email = excluded.primary_email,
      updated_at = timezone('utc', now());

create or replace function private.has_role(
  roles public.platform_role[],
  target_institution_id uuid default null
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
      from public.user_roles ur
     where ur.user_id = auth.uid()
       and ur.role = any (roles)
       and (
         (target_institution_id is null and ur.institution_id is null)
         or (
           target_institution_id is not null
           and (ur.institution_id is null or ur.institution_id = target_institution_id)
         )
       )
  );
$$;

create or replace function private.is_course_member(target_course_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    exists (
      select 1
        from public.courses c
       where c.id = target_course_id
         and private.has_role(array['admin']::public.platform_role[], c.institution_id)
    )
    or exists (
      select 1
        from public.enrollments e
       where e.course_id = target_course_id
         and e.user_id = auth.uid()
         and e.status = 'active'
    );
$$;

create or replace function private.is_course_staff(target_course_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    exists (
      select 1
        from public.courses c
       where c.id = target_course_id
         and private.has_role(array['admin']::public.platform_role[], c.institution_id)
    )
    or exists (
      select 1
        from public.enrollments e
       where e.course_id = target_course_id
         and e.user_id = auth.uid()
         and e.status = 'active'
         and e.role in ('instructor', 'ta')
    );
$$;

create or replace function private.has_course_permission(
  target_course_id uuid,
  permission_key text
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    private.has_role(
      array['admin']::public.platform_role[],
      (select c.institution_id from public.courses c where c.id = target_course_id)
    )
    or exists (
      select 1
        from public.enrollments e
       where e.course_id = target_course_id
         and e.user_id = auth.uid()
         and e.status = 'active'
         and (
           e.role = 'instructor'
           or coalesce((e.permission_overrides ->> permission_key)::boolean, false)
         )
    );
$$;

create or replace function private.is_course_content_viewer(target_course_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    private.is_course_staff(target_course_id)
    or exists (
      select 1
        from public.courses c
        join public.enrollments e on e.course_id = c.id
       where c.id = target_course_id
         and c.status = 'published'
         and e.user_id = auth.uid()
         and e.status = 'active'
    );
$$;

create or replace function private.is_module_visible_to_members(
  target_module_id uuid,
  target_course_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
      from public.modules m
     where m.id = target_module_id
       and m.course_id = target_course_id
       and m.is_published = true
       and (m.starts_at is null or m.starts_at <= timezone('utc', now()))
       and (m.ends_at is null or m.ends_at >= timezone('utc', now()))
       and private.is_course_content_viewer(target_course_id)
  );
$$;

create or replace function private.is_assignment_visible_to_members(
  target_assignment_id uuid,
  target_course_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
      from public.assignments a
     where a.id = target_assignment_id
       and a.course_id = target_course_id
       and a.status = 'published'
       and private.is_course_content_viewer(target_course_id)
       and exists (
         select 1
           from public.module_items mi
          where mi.assignment_id = a.id
            and mi.course_id = target_course_id
            and mi.is_published = true
            and private.is_module_visible_to_members(mi.module_id, mi.course_id)
       )
  );
$$;

create or replace function private.is_file_visible_to_members(
  target_file_id uuid,
  target_course_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    private.is_course_staff(target_course_id)
    or (
      private.is_course_content_viewer(target_course_id)
      and (
        exists (
          select 1
            from public.courses c
           where c.id = target_course_id
             and c.syllabus_file_id = target_file_id
        )
        or exists (
          select 1
            from public.module_items mi
           where mi.file_id = target_file_id
             and mi.course_id = target_course_id
             and mi.is_published = true
             and private.is_module_visible_to_members(mi.module_id, mi.course_id)
        )
      )
    );
$$;

create or replace function private.can_view_user_profile(target_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    target_user_id = auth.uid()
    or private.has_role(array['admin']::public.platform_role[])
    or exists (
      select 1
        from public.enrollments self_enrollment
        join public.enrollments target_enrollment
          on target_enrollment.course_id = self_enrollment.course_id
       where self_enrollment.user_id = auth.uid()
         and target_enrollment.user_id = target_user_id
         and self_enrollment.status = 'active'
         and target_enrollment.status = 'active'
         and self_enrollment.role in ('instructor', 'ta')
    );
$$;

alter table public.institutions enable row level security;
alter table public.users enable row level security;
alter table public.user_roles enable row level security;
alter table public.courses enable row level security;
alter table public.enrollments enable row level security;
alter table public.modules enable row level security;
alter table public.assignments enable row level security;
alter table public.module_items enable row level security;
alter table public.files enable row level security;
alter table public.announcements enable row level security;

create policy institutions_select_access
on public.institutions
for select
to authenticated
using (
  private.has_role(array['admin', 'instructor', 'student', 'ta']::public.platform_role[], id)
  or exists (
    select 1
      from public.courses c
      join public.enrollments e on e.course_id = c.id
     where c.institution_id = institutions.id
       and e.user_id = auth.uid()
       and e.status = 'active'
  )
);

create policy institutions_select_catalog
on public.institutions
for select
to anon
using (
  status = 'active'
  and exists (
    select 1
      from public.courses c
     where c.institution_id = institutions.id
       and c.status = 'published'
  )
);

create policy institutions_write_admin
on public.institutions
for all
to authenticated
using (private.has_role(array['admin']::public.platform_role[], id))
with check (private.has_role(array['admin']::public.platform_role[], id));

create policy users_select_self_or_shared_course
on public.users
for select
to authenticated
using (
  private.can_view_user_profile(id)
);

create policy users_update_self_or_admin
on public.users
for update
to authenticated
using (
  id = auth.uid()
  or private.has_role(array['admin']::public.platform_role[])
)
with check (
  id = auth.uid()
  or private.has_role(array['admin']::public.platform_role[])
);

create policy user_roles_select_self_or_admin
on public.user_roles
for select
to authenticated
using (
  user_id = auth.uid()
  or private.has_role(array['admin']::public.platform_role[], institution_id)
);

create policy user_roles_manage_admin
on public.user_roles
for all
to authenticated
using (private.has_role(array['admin']::public.platform_role[], institution_id))
with check (private.has_role(array['admin']::public.platform_role[], institution_id));

create policy courses_public_catalog
on public.courses
for select
to anon
using (
  status = 'published'
  and exists (
    select 1
      from public.institutions i
     where i.id = courses.institution_id
       and i.status = 'active'
  )
);

create policy courses_select_member_or_admin
on public.courses
for select
to authenticated
using (
  private.is_course_member(id)
  or private.has_role(array['admin']::public.platform_role[], institution_id)
  or (
    status = 'published'
    and exists (
      select 1
        from public.institutions i
       where i.id = courses.institution_id
         and i.status = 'active'
    )
  )
);

create policy courses_insert_staff_or_admin
on public.courses
for insert
to authenticated
with check (
  private.has_role(array['admin', 'instructor']::public.platform_role[], institution_id)
);

create policy courses_update_staff_or_admin
on public.courses
for update
to authenticated
using (
  private.has_course_permission(id, 'manage_course')
  or private.has_role(array['admin', 'instructor']::public.platform_role[], institution_id)
)
with check (
  private.has_course_permission(id, 'manage_course')
  or private.has_role(array['admin', 'instructor']::public.platform_role[], institution_id)
);

create policy courses_delete_admin_only
on public.courses
for delete
to authenticated
using (private.has_role(array['admin']::public.platform_role[], institution_id));

create policy enrollments_select_self_or_staff
on public.enrollments
for select
to authenticated
using (
  user_id = auth.uid()
  or private.is_course_staff(course_id)
);

create policy enrollments_manage_staff
on public.enrollments
for all
to authenticated
using (private.has_course_permission(course_id, 'manage_enrollments'))
with check (private.has_course_permission(course_id, 'manage_enrollments'));

create policy modules_select_course_members
on public.modules
for select
to authenticated
using (
  private.is_course_staff(course_id)
  or (
    private.is_course_content_viewer(course_id)
    and is_published = true
    and (starts_at is null or starts_at <= timezone('utc', now()))
    and (ends_at is null or ends_at >= timezone('utc', now()))
  )
);

create policy modules_manage_staff
on public.modules
for all
to authenticated
using (private.has_course_permission(course_id, 'manage_course_content'))
with check (private.has_course_permission(course_id, 'manage_course_content'));

create policy module_items_select_published_or_staff
on public.module_items
for select
to authenticated
using (
  private.is_course_staff(course_id)
  or (
    private.is_course_content_viewer(course_id)
    and is_published = true
    and private.is_module_visible_to_members(module_id, course_id)
  )
);

create policy module_items_manage_staff
on public.module_items
for all
to authenticated
using (private.has_course_permission(course_id, 'manage_course_content'))
with check (private.has_course_permission(course_id, 'manage_course_content'));

create policy assignments_select_published_or_staff
on public.assignments
for select
to authenticated
using (
  private.is_course_staff(course_id)
  or private.is_assignment_visible_to_members(id, course_id)
);

create policy assignments_manage_staff
on public.assignments
for all
to authenticated
using (private.has_course_permission(course_id, 'manage_course_content'))
with check (private.has_course_permission(course_id, 'manage_course_content'));

create policy files_select_member_or_owner
on public.files
for select
to authenticated
using (
  private.has_role(array['admin']::public.platform_role[], institution_id)
  or private.is_file_visible_to_members(id, course_id)
);

create policy files_insert_owner_or_staff
on public.files
for insert
to authenticated
with check (
  private.has_course_permission(course_id, 'manage_files')
);

create policy files_update_owner_or_staff
on public.files
for update
to authenticated
using (
  private.has_course_permission(course_id, 'manage_files')
)
with check (
  private.has_course_permission(course_id, 'manage_files')
);

create policy files_delete_owner_or_staff
on public.files
for delete
to authenticated
using (
  private.has_course_permission(course_id, 'manage_files')
);

create policy announcements_select_published_or_staff
on public.announcements
for select
to authenticated
using (
  private.is_course_staff(course_id)
  or (
    private.is_course_content_viewer(course_id)
    and published_at is not null
    and published_at <= timezone('utc', now())
  )
);

create policy announcements_manage_staff
on public.announcements
for all
to authenticated
using (private.has_course_permission(course_id, 'manage_announcements'))
with check (private.has_course_permission(course_id, 'manage_announcements'));

grant select on public.institutions to anon, authenticated;
grant select on public.courses to anon, authenticated;

grant select, update
on public.users
to authenticated;

grant select, insert, update, delete
on public.user_roles,
   public.enrollments,
   public.modules,
   public.assignments,
   public.module_items,
   public.files,
   public.announcements
to authenticated;

grant insert, update, delete on public.courses to authenticated;

create or replace view public.view_course_catalog
with (security_invoker = true)
as
select
  c.id,
  c.institution_id,
  i.slug as institution_slug,
  i.name as institution_name,
  c.uid,
  c.title,
  c.description,
  c.status,
  (c.syllabus_body is not null or c.syllabus_file_id is not null) as has_syllabus,
  c.created_at
from public.courses c
join public.institutions i on i.id = c.institution_id
where c.status = 'published'
  and i.status = 'active';

comment on view public.view_course_catalog is 'Public/student-safe course browse surface. Relies on RLS through security_invoker.';

create or replace view public.view_student_dashboard
with (security_invoker = true)
as
select
  e.user_id as student_id,
  e.id as enrollment_id,
  c.id as course_id,
  c.uid as course_uid,
  c.title as course_title,
  c.status as course_status,
  coalesce(module_stats.active_module_count, 0) as active_module_count,
  coalesce(file_stats.file_count, 0) as file_count,
  coalesce(announcement_stats.recent_announcements, '[]'::jsonb) as recent_announcements
from public.enrollments e
join public.courses c on c.id = e.course_id
left join lateral (
  select count(*)::integer as active_module_count
    from public.modules m
   where m.course_id = c.id
     and m.is_published = true
     and (m.starts_at is null or m.starts_at <= timezone('utc', now()))
     and (m.ends_at is null or m.ends_at >= timezone('utc', now()))
) module_stats on true
left join lateral (
  select count(*)::integer as file_count
    from public.files f
   where f.course_id = c.id
) file_stats on true
left join lateral (
  select jsonb_agg(
           jsonb_build_object(
             'id', a.id,
             'title', a.title,
             'published_at', a.published_at
           )
           order by a.published_at desc
         ) as recent_announcements
    from (
      select a.id, a.title, a.published_at
        from public.announcements a
       where a.course_id = c.id
         and a.published_at is not null
         and a.published_at <= timezone('utc', now())
       order by a.published_at desc
       limit 5
    ) a
) announcement_stats on true
where e.status = 'active'
  and e.role = 'student';

comment on view public.view_student_dashboard is 'Student-focused aggregate of active modules, recent announcements, and file counts.';

grant select on public.view_course_catalog to anon, authenticated;
grant select on public.view_student_dashboard to authenticated;
