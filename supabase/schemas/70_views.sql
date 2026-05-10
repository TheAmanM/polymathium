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
