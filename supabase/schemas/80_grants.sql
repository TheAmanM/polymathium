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

grant select on public.view_course_catalog to anon, authenticated;
grant select on public.view_student_dashboard to authenticated;
