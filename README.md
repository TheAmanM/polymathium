# Polymathium

Polymathium is a high-velocity LMS with a Supabase-backed relational core. The current repository state includes the initial database architecture, local Supabase CLI setup, and a readable schema layout intended for long-term maintenance.

## Project Status

- Next.js app scaffold is present
- Supabase CLI is configured in-repo
- Phase 1 database schema is defined
- No frontend product work has been started for the LMS experience yet

## Database Docs

Database documentation lives in:

- [supabase/README.md](/home/mohammad/Code/polymathium/supabase/README.md)

That guide covers:

- schema file layout
- migration strategy
- RLS model
- module and module item architecture
- course permission overrides
- hosted Supabase workflow

## Supabase Workflow

Install dependencies first:

```bash
npm install
```

Available Supabase scripts:

```bash
npm run supabase:init
npm run supabase:login
npm run supabase:link -- --project-ref <project-ref>
npm run supabase:start
npm run supabase:status
npm run supabase:stop
npm run supabase:migration:new -- <name>
```

The intended workflow is:

1. Edit readable schema files in [supabase/schemas](/home/mohammad/Code/polymathium/supabase/schemas)
2. Keep migrations as historical artifacts
3. Dry-run a hosted database push before applying it

## Development

Run the app locally:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Current Database Architecture

The current schema models:

- institutions as the tenant boundary
- users and RBAC
- courses and enrollments
- modules as content containers
- module items as ordered content rows
- assignments and quizzes
- S3-backed file metadata
- announcements
- course catalog and student dashboard views

The schema is hardened with RLS and private authorization helpers. See [supabase/README.md](/home/mohammad/Code/polymathium/supabase/README.md) for the details.

## File Storage Direction

Application file storage is expected to use direct S3-compatible object storage rather than Supabase Storage for LMS assets.

The database already reflects that direction:

- `public.files.bucket_name`
- `public.files.s3_key`

Supabase remains the database and auth layer. Object access should be mediated through backend authorization and short-lived signed S3 URLs.

## Notes

- Read `AGENTS.md` before changing Next.js application code.
- Read [supabase/README.md](/home/mohammad/Code/polymathium/supabase/README.md) before changing the database model.
