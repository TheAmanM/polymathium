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
