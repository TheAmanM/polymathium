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
