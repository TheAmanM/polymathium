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
