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
