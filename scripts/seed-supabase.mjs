import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const seedPassword = process.env.POLYMATHIUM_SEED_PASSWORD ?? "PolymathiumSeed123!";

if (!supabaseUrl || !serviceRoleKey) {
  console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY.");
  console.error("Export both environment variables before running npm run supabase:seed.");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});

const ids = {
  institution: "11111111-1111-4111-8111-111111111111",
  publishedCourse: "22222222-2222-4222-8222-222222222221",
  draftCourse: "22222222-2222-4222-8222-222222222222",
  moduleWeek1: "33333333-3333-4333-8333-333333333331",
  moduleWeek2Draft: "33333333-3333-4333-8333-333333333332",
  assignmentEssay: "44444444-4444-4444-8444-444444444441",
  quizWeek1: "44444444-4444-4444-8444-444444444442",
  syllabusFile: "55555555-5555-4555-8555-555555555551",
  lectureFile: "55555555-5555-4555-8555-555555555552",
  guideFile: "55555555-5555-4555-8555-555555555553",
  moduleItemIntro: "66666666-6666-4666-8666-666666666661",
  moduleItemLecture: "66666666-6666-4666-8666-666666666662",
  moduleItemGuide: "66666666-6666-4666-8666-666666666663",
  moduleItemEssay: "66666666-6666-4666-8666-666666666664",
  moduleItemQuiz: "66666666-6666-4666-8666-666666666665",
  enrollmentInstructor: "77777777-7777-4777-8777-777777777771",
  enrollmentTa: "77777777-7777-4777-8777-777777777772",
  enrollmentStudent: "77777777-7777-4777-8777-777777777773",
  enrollmentStudentTwo: "77777777-7777-4777-8777-777777777774",
  announcementPublished: "88888888-8888-4888-8888-888888888881",
  announcementDraft: "88888888-8888-4888-8888-888888888882",
  roleAdmin: "99999999-9999-4999-8999-999999999991",
  roleInstructor: "99999999-9999-4999-8999-999999999992",
  roleTa: "99999999-9999-4999-8999-999999999993",
  roleStudent: "99999999-9999-4999-8999-999999999994",
  roleStudentTwo: "99999999-9999-4999-8999-999999999995",
};

const seedUsers = [
  {
    email: "admin.seed@polymathium.test",
    password: seedPassword,
    displayName: "Platform Admin",
    fullName: "Polymathium Platform Admin",
    appRole: "admin",
  },
  {
    email: "instructor.seed@polymathium.test",
    password: seedPassword,
    displayName: "Ada Instructor",
    fullName: "Ada Instructor",
    appRole: "instructor",
  },
  {
    email: "ta.seed@polymathium.test",
    password: seedPassword,
    displayName: "Theo TA",
    fullName: "Theo TA",
    appRole: "ta",
  },
  {
    email: "student.seed@polymathium.test",
    password: seedPassword,
    displayName: "Sam Student",
    fullName: "Sam Student",
    appRole: "student",
  },
  {
    email: "student.two.seed@polymathium.test",
    password: seedPassword,
    displayName: "Riley Student",
    fullName: "Riley Student",
    appRole: "student",
  },
];

async function listAllUsers() {
  const users = [];
  let page = 1;

  while (true) {
    const { data, error } = await supabase.auth.admin.listUsers({
      page,
      perPage: 200,
    });

    if (error) {
      throw error;
    }

    users.push(...data.users);

    if (data.users.length < 200) {
      break;
    }

    page += 1;
  }

  return users;
}

async function ensureAuthUser(spec, existingUsers) {
  const existing = existingUsers.find((user) => user.email === spec.email);

  if (existing) {
    const { data, error } = await supabase.auth.admin.updateUserById(existing.id, {
      email: spec.email,
      password: spec.password,
      email_confirm: true,
      user_metadata: {
        display_name: spec.displayName,
        full_name: spec.fullName,
        seed_fixture: true,
      },
      app_metadata: {
        platform_role: spec.appRole,
        seed_fixture: true,
      },
    });

    if (error) {
      throw error;
    }

    return data.user;
  }

  const { data, error } = await supabase.auth.admin.createUser({
    email: spec.email,
    password: spec.password,
    email_confirm: true,
    user_metadata: {
      display_name: spec.displayName,
      full_name: spec.fullName,
      seed_fixture: true,
    },
    app_metadata: {
      platform_role: spec.appRole,
      seed_fixture: true,
    },
  });

  if (error) {
    throw error;
  }

  return data.user;
}

async function upsert(table, rows, onConflict = "id") {
  const { error } = await supabase.from(table).upsert(rows, { onConflict });

  if (error) {
    throw new Error(`${table}: ${error.message}`);
  }
}

async function main() {
  const existingUsers = await listAllUsers();
  const ensuredUsers = {};

  for (const spec of seedUsers) {
    const user = await ensureAuthUser(spec, existingUsers);
    ensuredUsers[spec.email] = user;
  }

  const adminUser = ensuredUsers["admin.seed@polymathium.test"];
  const instructorUser = ensuredUsers["instructor.seed@polymathium.test"];
  const taUser = ensuredUsers["ta.seed@polymathium.test"];
  const studentUser = ensuredUsers["student.seed@polymathium.test"];
  const studentTwoUser = ensuredUsers["student.two.seed@polymathium.test"];

  await upsert("users", [
    {
      id: adminUser.id,
      primary_email: "admin.seed@polymathium.test",
      display_name: "Platform Admin",
      full_name: "Polymathium Platform Admin",
    },
    {
      id: instructorUser.id,
      primary_email: "instructor.seed@polymathium.test",
      display_name: "Ada Instructor",
      full_name: "Ada Instructor",
    },
    {
      id: taUser.id,
      primary_email: "ta.seed@polymathium.test",
      display_name: "Theo TA",
      full_name: "Theo TA",
    },
    {
      id: studentUser.id,
      primary_email: "student.seed@polymathium.test",
      display_name: "Sam Student",
      full_name: "Sam Student",
    },
    {
      id: studentTwoUser.id,
      primary_email: "student.two.seed@polymathium.test",
      display_name: "Riley Student",
      full_name: "Riley Student",
    },
  ]);

  await upsert("institutions", [
    {
      id: ids.institution,
      slug: "seed-university",
      name: "Seed University",
      status: "active",
    },
  ]);

  await upsert("user_roles", [
    {
      id: ids.roleAdmin,
      user_id: adminUser.id,
      institution_id: null,
      role: "admin",
    },
    {
      id: ids.roleInstructor,
      user_id: instructorUser.id,
      institution_id: ids.institution,
      role: "instructor",
    },
    {
      id: ids.roleTa,
      user_id: taUser.id,
      institution_id: ids.institution,
      role: "ta",
    },
    {
      id: ids.roleStudent,
      user_id: studentUser.id,
      institution_id: ids.institution,
      role: "student",
    },
    {
      id: ids.roleStudentTwo,
      user_id: studentTwoUser.id,
      institution_id: ids.institution,
      role: "student",
    },
  ]);

  await upsert("courses", [
    {
      id: ids.publishedCourse,
      institution_id: ids.institution,
      uid: "POLY-101",
      title: "Foundations of Polymathium",
      description: "Published seed course for end-to-end integration testing.",
      status: "published",
      syllabus_body: [
        {
          type: "paragraph",
          content: "This seeded course validates course browsing, enrollment, modules, files, assignments, and announcements.",
        },
      ],
      syllabus_file_id: null,
      created_by: instructorUser.id,
    },
    {
      id: ids.draftCourse,
      institution_id: ids.institution,
      uid: "POLY-EXPERIMENT",
      title: "Experimental Course Shell",
      description: "Draft course for visibility and permissions testing.",
      status: "draft",
      syllabus_body: [
        {
          type: "paragraph",
          content: "This draft course should stay hidden from students.",
        },
      ],
      syllabus_file_id: null,
      created_by: instructorUser.id,
    },
  ]);

  await upsert("enrollments", [
    {
      id: ids.enrollmentInstructor,
      course_id: ids.publishedCourse,
      user_id: instructorUser.id,
      role: "instructor",
      status: "active",
      permission_overrides: {},
    },
    {
      id: ids.enrollmentTa,
      course_id: ids.publishedCourse,
      user_id: taUser.id,
      role: "ta",
      status: "active",
      permission_overrides: {
        manage_announcements: true,
        manage_files: true,
        manage_course_content: true,
      },
    },
    {
      id: ids.enrollmentStudent,
      course_id: ids.publishedCourse,
      user_id: studentUser.id,
      role: "student",
      status: "active",
      permission_overrides: {},
    },
    {
      id: ids.enrollmentStudentTwo,
      course_id: ids.publishedCourse,
      user_id: studentTwoUser.id,
      role: "student",
      status: "active",
      permission_overrides: {},
    },
  ]);

  await upsert("modules", [
    {
      id: ids.moduleWeek1,
      course_id: ids.publishedCourse,
      parent_module_id: null,
      title: "Week 1: Orientation",
      description: "Published module with every supported module item shape.",
      position: 0,
      is_published: true,
      created_by: instructorUser.id,
    },
    {
      id: ids.moduleWeek2Draft,
      course_id: ids.publishedCourse,
      parent_module_id: null,
      title: "Week 2: Draft Module",
      description: "Unpublished module for visibility checks.",
      position: 1,
      is_published: false,
      created_by: instructorUser.id,
    },
  ]);

  await upsert("assignments", [
    {
      id: ids.assignmentEssay,
      course_id: ids.publishedCourse,
      title: "Reflection Essay",
      description_markdown: "Write a short reflection on the first week of class.",
      assignment_type: "assignment",
      status: "published",
      points_possible: 100,
      due_at: "2026-06-01T23:59:00Z",
      available_from: "2026-05-01T00:00:00Z",
      available_until: "2026-06-02T23:59:00Z",
      created_by: instructorUser.id,
    },
    {
      id: ids.quizWeek1,
      course_id: ids.publishedCourse,
      title: "Orientation Quiz",
      description_markdown: "Seed quiz used to validate quiz-linked module items.",
      assignment_type: "quiz",
      status: "published",
      points_possible: 20,
      due_at: "2026-05-20T23:59:00Z",
      available_from: "2026-05-01T00:00:00Z",
      available_until: "2026-05-21T23:59:00Z",
      created_by: instructorUser.id,
    },
  ]);

  await upsert("files", [
    {
      id: ids.syllabusFile,
      institution_id: ids.institution,
      course_id: ids.publishedCourse,
      uploader_id: instructorUser.id,
      bucket_name: "polymathium-seed-assets",
      s3_key: `${ids.institution}/${ids.publishedCourse}/content/syllabus.pdf`,
      original_filename: "syllabus.pdf",
      file_size: 102400,
      mime_type: "application/pdf",
      etag: "seed-syllabus-etag",
      metadata: {
        delivery: "s3",
        kind: "syllabus",
      },
    },
    {
      id: ids.lectureFile,
      institution_id: ids.institution,
      course_id: ids.publishedCourse,
      uploader_id: instructorUser.id,
      bucket_name: "polymathium-seed-assets",
      s3_key: `${ids.institution}/${ids.publishedCourse}/content/week-1-slides.pdf`,
      original_filename: "week-1-slides.pdf",
      file_size: 204800,
      mime_type: "application/pdf",
      etag: "seed-slides-etag",
      metadata: {
        delivery: "s3",
        kind: "module_content",
      },
    },
    {
      id: ids.guideFile,
      institution_id: ids.institution,
      course_id: ids.publishedCourse,
      uploader_id: taUser.id,
      bucket_name: "polymathium-seed-assets",
      s3_key: `${ids.institution}/${ids.publishedCourse}/content/orientation-guide.md`,
      original_filename: "orientation-guide.md",
      file_size: 8192,
      mime_type: "text/markdown",
      etag: "seed-guide-etag",
      metadata: {
        delivery: "s3",
        kind: "module_content",
      },
    },
  ]);

  await upsert("courses", [
    {
      id: ids.publishedCourse,
      institution_id: ids.institution,
      uid: "POLY-101",
      title: "Foundations of Polymathium",
      description: "Published seed course for end-to-end integration testing.",
      status: "published",
      syllabus_body: [
        {
          type: "paragraph",
          content: "This seeded course validates course browsing, enrollment, modules, files, assignments, and announcements.",
        },
      ],
      syllabus_file_id: ids.syllabusFile,
      created_by: instructorUser.id,
    },
  ]);

  await upsert("module_items", [
    {
      id: ids.moduleItemIntro,
      module_id: ids.moduleWeek1,
      course_id: ids.publishedCourse,
      item_type: "rich_text",
      title: "Welcome Message",
      content_markdown: "Welcome to Polymathium. Start here before opening the files and assignments.",
      file_id: null,
      assignment_id: null,
      position: 0,
      is_published: true,
      created_by: instructorUser.id,
    },
    {
      id: ids.moduleItemLecture,
      module_id: ids.moduleWeek1,
      course_id: ids.publishedCourse,
      item_type: "file",
      title: "Week 1 Slides",
      content_markdown: null,
      file_id: ids.lectureFile,
      assignment_id: null,
      position: 1,
      is_published: true,
      created_by: instructorUser.id,
    },
    {
      id: ids.moduleItemGuide,
      module_id: ids.moduleWeek1,
      course_id: ids.publishedCourse,
      item_type: "rich_text_file",
      title: "Orientation Guide",
      content_markdown: "Read the guide, then continue to the essay and quiz.",
      file_id: ids.guideFile,
      assignment_id: null,
      position: 2,
      is_published: true,
      created_by: taUser.id,
    },
    {
      id: ids.moduleItemEssay,
      module_id: ids.moduleWeek1,
      course_id: ids.publishedCourse,
      item_type: "assignment",
      title: "Reflection Essay",
      content_markdown: null,
      file_id: null,
      assignment_id: ids.assignmentEssay,
      position: 3,
      is_published: true,
      created_by: instructorUser.id,
    },
    {
      id: ids.moduleItemQuiz,
      module_id: ids.moduleWeek1,
      course_id: ids.publishedCourse,
      item_type: "quiz",
      title: "Orientation Quiz",
      content_markdown: null,
      file_id: null,
      assignment_id: ids.quizWeek1,
      position: 4,
      is_published: true,
      created_by: instructorUser.id,
    },
  ]);

  await upsert("announcements", [
    {
      id: ids.announcementPublished,
      course_id: ids.publishedCourse,
      author_enrollment_id: ids.enrollmentInstructor,
      title: "Welcome to the Course",
      body_markdown: "This is a published announcement visible to enrolled students.",
      published_at: "2026-05-01T12:00:00Z",
    },
    {
      id: ids.announcementDraft,
      course_id: ids.publishedCourse,
      author_enrollment_id: ids.enrollmentTa,
      title: "Staff Draft Notice",
      body_markdown: "This draft announcement should remain hidden from students.",
      published_at: null,
    },
  ]);

  console.log("Seed completed.");
  console.log("Seed accounts:");
  for (const spec of seedUsers) {
    console.log(`- ${spec.email} / ${seedPassword}`);
  }
}

main().catch((error) => {
  console.error("Seed failed.");
  console.error(error);
  process.exit(1);
});
