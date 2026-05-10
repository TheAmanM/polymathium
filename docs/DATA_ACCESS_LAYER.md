# Data Access Layer (DAL)

Polymathium keeps Supabase entirely server-side. No Supabase client, URL, or key ever reaches the browser. Every piece of data the frontend renders flows through one of two server-side entry points:

- **Queries** — plain async functions called directly inside Server Components
- **Mutations** — Server Actions (`"use server"`) called from Client Components via form actions or `startTransition`

Both entry points delegate to a shared DAL module that owns the Supabase client, auth context, and all SQL-touching code.

## Architecture

```
Browser (Client Components)
  │
  ├─ reads ──► Server Component ──► query function ──► DAL ──► Supabase
  │                                   (React.cache)
  │
  └─ writes ─► Server Action ──────────────────────► DAL ──► Supabase
                ("use server")
```

The browser never imports `@supabase/supabase-js`. The package is a server-only dependency.

## Directory layout

```
lib/
  dal/
    client.ts          # Supabase client factory (server-only)
    auth.ts            # Auth context extraction
    courses.ts         # Course queries and mutations
    enrollments.ts     # Enrollment queries and mutations
    modules.ts         # Module queries and mutations
    files.ts           # File queries and mutations
    announcements.ts   # Announcement queries and mutations
    users.ts           # User profile queries and mutations
    errors.ts          # DAL error types

app/
  actions/
    courses.ts         # "use server" — thin wrappers that call DAL + revalidate
    enrollments.ts
    modules.ts
    ...
```

## Supabase client factory

A single factory creates a Supabase client scoped to the current request's auth context. It is never exported directly — DAL functions call it internally.

```ts
// lib/dal/client.ts
import "server-only";

import { createClient } from "@supabase/supabase-js";
import { cookies } from "next/headers";

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

export async function createUserClient() {
  const cookieStore = await cookies();

  return createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: {
        cookie: cookieStore.toString(),
      },
    },
    auth: {
      flowType: "pkce",
      autoRefreshToken: false,
      persistSession: false,
      detectSessionInUrl: false,
    },
  });
}

export function createServiceClient() {
  return createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}
```

`createUserClient` runs every query through RLS with the caller's JWT. `createServiceClient` bypasses RLS for admin-only operations (user provisioning, background jobs). DAL functions choose the appropriate client.

## Auth context

Every DAL function that needs the current user calls a shared auth helper. This is wrapped in `React.cache` so multiple components in the same render tree share a single auth check.

```ts
// lib/dal/auth.ts
import "server-only";

import { cache } from "react";
import { redirect } from "next/navigation";
import { createUserClient } from "./client";

export const getCurrentUser = cache(async () => {
  const supabase = await createUserClient();
  const { data: { user }, error } = await supabase.auth.getUser();

  if (error || !user) {
    redirect("/login");
  }

  return user;
});
```

## Query functions

Query functions are plain `async` functions in the DAL. Server Components call them directly. Wrap in `cache()` when the same data is needed by multiple components in one render.

```ts
// lib/dal/courses.ts
import "server-only";

import { cache } from "react";
import { createUserClient } from "./client";
import { DALError } from "./errors";

export const getPublishedCourses = cache(async () => {
  const supabase = await createUserClient();

  const { data, error } = await supabase
    .from("view_course_catalog")
    .select("*")
    .order("created_at", { ascending: false });

  if (error) throw new DALError("courses.list", error.message);

  return data;
});

export const getCourseById = cache(async (courseId: string) => {
  const supabase = await createUserClient();

  const { data, error } = await supabase
    .from("courses")
    .select("*, enrollments(*), modules(*)")
    .eq("id", courseId)
    .single();

  if (error) throw new DALError("courses.get", error.message);

  return data;
});
```

A Server Component consumes this with zero client-side data fetching:

```tsx
// app/courses/page.tsx (Server Component)
import { getPublishedCourses } from "@/lib/dal/courses";

export default async function CoursesPage() {
  const courses = await getPublishedCourses();

  return (
    <ul>
      {courses.map((c) => (
        <li key={c.id}>{c.title}</li>
      ))}
    </ul>
  );
}
```

## Server Actions (mutations)

Server Actions are the only way Client Components trigger writes. Each action file has `"use server"` at the top, validates input, calls the DAL, and revalidates affected caches.

```ts
// app/actions/courses.ts
"use server";

import { revalidatePath } from "next/cache";
import { getCurrentUser } from "@/lib/dal/auth";
import { updateCourse } from "@/lib/dal/courses";

export async function updateCourseAction(courseId: string, formData: FormData) {
  const user = await getCurrentUser();

  const title = formData.get("title");
  if (typeof title !== "string" || title.trim().length === 0) {
    return { error: "Title is required" };
  }

  const result = await updateCourse(courseId, { title: title.trim() });

  revalidatePath(`/courses/${courseId}`);

  return { data: result };
}
```

A Client Component calls the action through a form or `startTransition`:

```tsx
"use client";

import { updateCourseAction } from "@/app/actions/courses";

export function EditCourseForm({ courseId }: { courseId: string }) {
  return (
    <form action={updateCourseAction.bind(null, courseId)}>
      <input name="title" required />
      <button type="submit">Save</button>
    </form>
  );
}
```

## Rules

1. **`@supabase/supabase-js` is never imported outside `lib/dal/`.**  
   Every file in the DAL starts with `import "server-only"` to enforce this at build time. If a Client Component accidentally imports a DAL module, the build fails.

2. **DAL functions return plain objects, not Supabase responses.**  
   The rest of the codebase never sees `PostgrestResponse`, `PostgrestError`, or any Supabase type. DAL functions throw `DALError` on failure and return typed data on success.

3. **Auth is checked inside the DAL or action, never assumed.**  
   Every mutation re-derives the user from the cookie. Server Components can rely on `getCurrentUser()` cached per-request.

4. **RLS is the primary access control. The DAL is not a replacement.**  
   Using `createUserClient()` means every query runs through Postgres RLS with the caller's JWT. The DAL doesn't re-implement permission checks — it trusts the database policies. `createServiceClient()` is reserved for operations that genuinely need to bypass RLS (admin tooling, background jobs, auth hooks).

5. **Input validation happens in Server Actions, not in the DAL.**  
   Actions validate and sanitize user input before passing it to DAL functions. DAL functions assume they receive valid, typed arguments.

6. **Cache invalidation is explicit.**  
   After a mutation, the action calls `revalidatePath()` or `revalidateTag()` to bust the relevant Server Component caches. DAL query functions are pure — they don't manage cache state.

7. **No `fetch` wrapper around Supabase.**  
   The Supabase client already uses `fetch` internally. Wrapping it in another `fetch` call (e.g., via API routes) adds latency and complexity for no benefit. Server Components call DAL functions directly.

## Error handling

```ts
// lib/dal/errors.ts
import "server-only";

export class DALError extends Error {
  constructor(
    public readonly operation: string,
    message: string,
  ) {
    super(`[DAL:${operation}] ${message}`);
    this.name = "DALError";
  }
}
```

Server Components catch `DALError` in `error.tsx` boundaries. Server Actions return `{ error: string }` to the client instead of throwing, so the UI can render inline error messages.

## Why not API routes?

API routes (`app/api/...`) add an HTTP round-trip between the Next.js server and itself. Server Actions and direct DAL calls in Server Components skip that hop entirely — the data goes straight from Supabase to the rendered HTML or the action response. API routes are still appropriate for webhooks, third-party integrations, and non-browser clients (mobile apps, CLI tools), but not for the web frontend's own data needs.

## Why not the client-side Supabase SDK?

The `@supabase/ssr` / client-side pattern exposes the anon key and Supabase URL to the browser, relies on client-side RLS for security, and creates a second data-fetching path that competes with Server Components. By keeping Supabase server-only:

- **Credentials stay on the server.** The browser never sees any Supabase key.
- **One data path.** All data flows through Server Components or Server Actions — no split between server-rendered and client-fetched data.
- **Simpler auth.** Session management is cookie-based with `httpOnly` cookies. No client-side token refresh logic.
- **Easier to audit.** Every database interaction lives in `lib/dal/`. A security review scans one directory.
