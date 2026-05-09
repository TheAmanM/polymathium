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
