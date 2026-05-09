# Supabase Database Guide

This folder is the database source of truth for Polymathium.

## Layout

- [config.toml](/home/mohammad/Code/polymathium/supabase/config.toml): Supabase CLI project config
- [migrations](/home/mohammad/Code/polymathium/supabase/migrations): immutable migration history
- [schemas](/home/mohammad/Code/polymathium/supabase/schemas): readable schema definition files
- [seed.sql](/home/mohammad/Code/polymathium/supabase/seed.sql): seed entry point
- [RESET_PROTOCOL.md](/home/mohammad/Code/polymathium/supabase/RESET_PROTOCOL.md): destructive reset procedure for disposable environments

## Editing Strategy

Use the files in [schemas](/home/mohammad/Code/polymathium/supabase/schemas) for day-to-day schema work.

The readable schema is split by responsibility:

- [00_extensions.sql](/home/mohammad/Code/polymathium/supabase/schemas/00_extensions.sql)
- [01_types.sql](/home/mohammad/Code/polymathium/supabase/schemas/01_types.sql)
- [02_base_functions.sql](/home/mohammad/Code/polymathium/supabase/schemas/02_base_functions.sql)
- [03_tables.sql](/home/mohammad/Code/polymathium/supabase/schemas/03_tables.sql)
- [04_indexes.sql](/home/mohammad/Code/polymathium/supabase/schemas/04_indexes.sql)
- [05_private_functions.sql](/home/mohammad/Code/polymathium/supabase/schemas/05_private_functions.sql)
- [06_triggers.sql](/home/mohammad/Code/polymathium/supabase/schemas/06_triggers.sql)
- [07_rls.sql](/home/mohammad/Code/polymathium/supabase/schemas/07_rls.sql)
- [08_views.sql](/home/mohammad/Code/polymathium/supabase/schemas/08_views.sql)

Keep [20260509052323_polymathium_phase1_core_schema.sql](/home/mohammad/Code/polymathium/supabase/migrations/20260509052323_polymathium_phase1_core_schema.sql) as the bootstrap history entry. Do not treat it as the primary editing surface.

## Core Data Model

### Tenancy and Identity

- `institutions` is the tenant boundary.
- `auth.users` remains the identity source.
- `public.users` is the application profile table keyed 1:1 to `auth.users.id`.
- `user_roles` holds platform-wide and institution-scoped roles.

### Courses and Membership

- `courses` belongs to an institution.
- `enrollments` links users to courses and is the stable future FK target for submissions and grades.
- `permission_overrides` is a JSON object used for course-scoped write capability overrides.

### Content Structure

- `modules` are containers.
- `module_items` are the ordered content rows inside modules.

Supported `module_items.item_type` values:

- `rich_text`
- `file`
- `rich_text_file`
- `assignment`
- `quiz`

This means a module can contain:

- rich text only
- file only
- rich text plus file
- assignment
- quiz

Assignments and quizzes are stored in `assignments` and surfaced into module flows through `module_items.assignment_id`.

### Files

`files` stores metadata only:

- `bucket_name`
- `s3_key`
- `file_size`
- `mime_type`
- `uploader_id`

The table is course-scoped. File bytes belong in object storage, not Postgres.

Polymathium is using direct S3-compatible object storage for application files, not Supabase Storage buckets. In practice:

- `bucket_name` identifies the S3 bucket
- `s3_key` is the canonical object key within that bucket
- `public.files` is the metadata registry and authorization join point

Recommended object key convention:

```text
{institution_id}/{course_id}/{folder_type}/{object_name}
```

Current `folder_type` expectations:

- `content` for course-managed files
- `submissions` for future student submission uploads

Because the application is not relying on Supabase `storage.objects`, file access must be mediated by backend-issued signed URLs after database authorization checks.

Planned delivery model:

- direct S3 uploads and downloads via short-lived presigned URLs
- CloudFront in front of S3 later for distribution, caching, and edge delivery
- application-level authorization before any signing step

### Syllabus

Courses support both:

- `syllabus_body` for structured syllabus content
- `syllabus_file_id` for a course-owned syllabus file

## Security Model

### RLS

RLS is enabled on all exposed `public` tables in [07_rls.sql](/home/mohammad/Code/polymathium/supabase/schemas/07_rls.sql).

Rules to preserve:

- never authorize from user-editable JWT metadata
- keep auth helper functions in the `private` schema
- use `security_invoker` for views
- do not weaken student visibility to draft or hidden content
- do not assume object storage enforces database-level RLS for us

### Read vs Write Roles

Course read access and course write access are intentionally different.

- students can only see published and visible content
- instructors get broad write power by default
- TAs are not implicitly full-power writers
- TA write behavior must be granted through `permission_overrides`

Current permission override keys used by policy:

- `manage_course`
- `manage_enrollments`
- `manage_course_content`
- `manage_files`
- `manage_announcements`

These keys are consumed by `private.has_course_permission(...)` in [05_private_functions.sql](/home/mohammad/Code/polymathium/supabase/schemas/05_private_functions.sql).

## Direct S3 Access Model

Supabase RLS protects the `public.files` metadata table. It does not protect raw S3 objects.

That means the application contract for downloads and uploads should be:

1. Backend checks database authorization using `public.files`, course membership, and content visibility rules.
2. Backend generates a short-lived signed S3 URL for the specific object key.
3. Client uses that signed URL directly against S3.

When CloudFront is introduced, the signing boundary may move from raw S3 URLs to CloudFront-signed URLs or signed cookies for download flows, but the authorization source should remain the database.

For uploads:

1. Backend authorizes the upload target and object key.
2. Backend returns a signed upload URL or performs the upload server-side.
3. Application registers or finalizes the `public.files` metadata row immediately after the object is accepted.

Avoid exposing raw long-lived bucket credentials to clients.

## Views

[08_views.sql](/home/mohammad/Code/polymathium/supabase/schemas/08_views.sql) defines:

- `view_course_catalog`
- `view_student_dashboard`

Both are `security_invoker` views so they respect table RLS.

## Workflow

`supabase/config.toml` is the local CLI and self-hosted configuration surface. For a hosted Supabase project, database schema changes ship through migrations, but Auth provider and URL settings must also be configured in the Supabase dashboard before production rollout.

### Install and Link

```bash
npm run supabase:login
npm run supabase:link -- --project-ref <project-ref>
```

If a database password is required:

```bash
npx supabase link --project-ref <project-ref> -p '<db-password>'
```

### Review Before Push

```bash
npx supabase db push --dry-run
```

### Apply

```bash
npx supabase db push
```

### Seed Fixtures

```bash
npm run supabase:seed
```

This script uses the Supabase Auth admin API and requires:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

See [RESET_PROTOCOL.md](/home/mohammad/Code/polymathium/supabase/RESET_PROTOCOL.md) for the disposable reset flow.

## Constraints and Gaps

- The schema has been statically reviewed, but not runtime-verified against a database in this workspace session.
- Hosted Auth settings still need to be explicitly configured in the Supabase dashboard, especially site URL, redirect URLs, SMTP, and provider settings.
- Submission tables, grading tables, and student-submission file ownership are not implemented yet.
- If we add student uploads later, that should be modeled separately from course-managed content files.
- Direct S3 signing flows, background cleanup for orphaned objects, and submission-file ownership rules are still application work, not database-complete yet.
