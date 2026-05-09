import { CourseShell } from "@/components/course-shell";

export default function CourseLayout({ children }: { children: React.ReactNode }) {
  return <CourseShell>{children}</CourseShell>;
}
