create type public.platform_role as enum ('admin', 'instructor', 'student', 'ta');
create type public.course_role as enum ('instructor', 'ta', 'student');
create type public.course_status as enum ('draft', 'published', 'archived');
create type public.institution_status as enum ('active', 'inactive', 'archived');
create type public.enrollment_status as enum ('invited', 'active', 'completed', 'dropped');
create type public.assignment_type as enum ('assignment', 'quiz');
create type public.assignment_status as enum ('draft', 'published', 'closed', 'archived');
create type public.module_item_type as enum ('rich_text', 'file', 'rich_text_file', 'assignment', 'quiz');
