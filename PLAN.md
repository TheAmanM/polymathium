# Polymathium UI Plan

Polymathium is a production-grade course platform and Quercus alternative. This plan covers UI only: static screens, navigation structure, page content, and role-aware surface area. Backend auth, persistence, authorization enforcement, file storage, email delivery, and auditing are intentionally out of scope for this phase.

## Portion 1: Auth Pages

Routes:
- `/login`
- `/login/verify`
- `/auth/callback`
- `/invite/accept`

Purpose:
- Establish secure, email-first access without password UI.
- Support OTP and magic-link sign-in.
- Make invite acceptance feel trustworthy and explicit.

Pages:
- `/login`: existing email entry page.
- `/login/verify`: OTP entry, magic-link reminder, resend affordance, clear security copy.
- `/auth/callback`: polished loading/confirmation state while a magic link is verified.
- `/invite/accept`: invitation review with course, role, recipient email, and next-step confirmation.

Security UI requirements:
- Always show the target email before confirmation when possible.
- Never imply password login exists unless it is actually implemented.
- Keep auth copy precise: secure link, one-time code, session, trusted device.
- Avoid collecting profile identity details during auth unless required.

## Portion 2: Global App Shell

Routes:
- `/app`
- `/app/settings`

Purpose:
- Give signed-in users a professional dashboard and account-management area.
- Keep account settings separate from course settings.

Pages:
- `/app`: course dashboard split into teaching and enrolled courses, recent announcements, security/account status, and instructor shortcuts.
- `/app/settings`: personal account settings including notification preferences, session/security controls, and immutable identity fields.

Student profile rules:
- Students cannot change official/legal name in the student UI.
- Students can change preferences like theme, timezone, notification channels, and possibly avatar.
- Email is treated as verified identity and should not be edited casually in-app.

Instructor profile rules:
- Instructors can manage their own preferences.
- Instructors cannot modify another user's account settings from their profile page.
- Identity changes should be handled by an admin/support workflow later.

## Portion 3: Course Shell And Core Tabs

Routes:
- `/courses/[courseId]`
- `/courses/[courseId]/announcements`
- `/courses/[courseId]/announcements/[announcementId]`
- `/courses/[courseId]/modules`
- `/courses/[courseId]/modules/[moduleId]`
- `/courses/[courseId]/files`
- `/courses/[courseId]/files/[fileId]`

Purpose:
- Make the course the main workspace.
- Use a Quercus-like sidebar with a more polished, focused layout.

Sidebar tabs:
- Home
- Announcements
- Modules
- Files
- Settings, instructor only

Course home:
- Course header and term context.
- Pinned announcement.
- Current module or week.
- Recent files.
- Instructor actions surfaced only for instructor view.

Announcements:
- Students see published announcements only.
- Instructors see draft/published status, create action, and edit controls.
- Detail pages show metadata, attachments, and publish state.

Modules:
- Students see released modules only.
- Instructors see draft/unpublished/release status and ordering controls.
- Module detail pages present ordered learning materials, files, links, and notes.

Files:
- Students see only files they can access.
- Instructors can upload, categorize, replace, and remove files.
- File detail pages show metadata, visibility, associated module/category, and download/preview actions.

## Portion 4: Instructor Course Settings

Routes:
- `/courses/[courseId]/settings`
- `/courses/[courseId]/settings/general`
- `/courses/[courseId]/settings/people`
- `/courses/[courseId]/settings/access`
- `/courses/[courseId]/settings/modules`
- `/courses/[courseId]/settings/files`
- `/courses/[courseId]/settings/announcements`
- `/courses/[courseId]/settings/security`

Purpose:
- Give instructors course-level controls without leaking them into student navigation.
- Separate operational settings from content pages.

Instructor can:
- Edit course title, code, description, and home-page content.
- Invite students via email list.
- Review student import validation before sending invites.
- Publish, unpublish, archive, and reorder course materials.
- Manage file categories and visibility.
- Configure announcement defaults and notification behavior.

Instructor cannot:
- Change a student's official name.
- Modify another user's personal account settings.
- Bypass security/audit-sensitive confirmations.
- Change global platform auth or security policy from a course settings page.

Settings sections:
- General: title, course code, term, description, course image later.
- People: roster, invite students, bulk email paste/import, role assignment.
- Access: invitation rules, join policy, enrollment status.
- Modules: visibility defaults, ordering, release behavior.
- Files: categories, accepted organization model, storage/visibility defaults.
- Announcements: default notification behavior, pinned announcement rules.
- Security: sensitive action confirmations, audit metadata, session/access posture.

## Portion 5: Permission And Visibility Principles

Student can:
- View enrolled courses.
- View released announcements, modules, and files.
- Manage personal preferences and notification settings.
- Use secure login methods.

Student cannot:
- Access course settings.
- Invite users.
- Upload/delete shared course files unless a future role allows it.
- Edit course home, announcements, modules, or file metadata.
- Change official identity fields.

Instructor can:
- Manage course content and settings.
- Invite and remove students from a course.
- Upload and organize files.
- Publish/unpublish course materials.
- View operational metadata needed to run the course.

Instructor cannot:
- Edit global platform policy.
- Silently impersonate students.
- Modify immutable student identity fields.
- Perform destructive actions without clear confirmation UI.

## Portion 6: Visual Direction

Principles:
- Professional, restrained, high-trust interface.
- Card-based surfaces matching the existing login page style.
- Muted backgrounds, strong hierarchy, concise labels.
- Clear role and status badges.
- Security-sensitive UI should be calm, explicit, and hard to misread.

Initial implementation target:
- Static Next.js App Router pages.
- Shared shell components for brand, app layout, and course sidebar.
- No backend integration yet.
- No real authorization yet; UI indicates intended permissions only.
