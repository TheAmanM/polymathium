# Disposable Reset Protocol

Use this protocol only while the database is still disposable and pre-launch.

Do not use this process once the environment contains real user data, audit requirements, or any state that must be preserved.

## Safe Assumptions

This protocol assumes:

- the linked Supabase project can be destroyed and rebuilt logically
- auth users can be recreated
- seeded content can replace existing content
- no production user submissions or grades need to survive

## Reset Workflow

1. Confirm the target project is the correct linked project.

```bash
npm run supabase:link -- --project-ref <project-ref>
```

2. Reset the linked database to the current migration state without running `seed.sql`.

```bash
npm run supabase:reset:linked
```

3. Seed auth-capable fixtures with the service role key.

Required environment variables:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Optional:

- `POLYMATHIUM_SEED_PASSWORD`

Run:

```bash
npm run supabase:seed
```

## Why `seed.sql` Is Not Used

Polymathium needs seeded users that work with Supabase Auth. That is more reliable through the Auth admin API than through direct SQL manipulation of `auth.users`.

For that reason:

- `supabase db reset --linked` runs with `--no-seed`
- seeded fixtures are created afterward through `scripts/seed-supabase.mjs`

## Expected Result

After the reset and seed run:

- the schema matches the current migrations
- seeded users exist in Supabase Auth
- `public.users` is populated for those auth users
- institutions, roles, courses, enrollments, modules, files, module items, assignments, and announcements exist

## Seed Accounts

The seed script creates:

- `admin.seed@polymathium.test`
- `instructor.seed@polymathium.test`
- `ta.seed@polymathium.test`
- `student.seed@polymathium.test`
- `student.two.seed@polymathium.test`

All accounts use:

- `POLYMATHIUM_SEED_PASSWORD` if provided
- otherwise `PolymathiumSeed123!`

## Exit Condition

Once the project leaves disposable mode, stop using this reset protocol.

At that point:

- treat migrations as forward-only
- preserve auth users and course state
- use scripted backfills instead of destructive resets
