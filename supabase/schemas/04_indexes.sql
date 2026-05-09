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
