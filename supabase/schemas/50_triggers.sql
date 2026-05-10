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

-- Backfill: sync any auth.users rows that existed before the trigger was created.
insert into public.users (id, primary_email)
select au.id, au.email
  from auth.users au
on conflict (id) do update
  set primary_email = excluded.primary_email,
      updated_at = timezone('utc', now());
