import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { BookOpenIcon, MegaphoneIcon, ShieldCheckIcon, UploadIcon } from "lucide-react";

const teachingCourses = [
  ["CSC108", "Introduction to Computer Science", "186 students", "Instructor"],
  ["CSC148", "Software Design", "92 students", "Instructor"],
];

const enrolledCourses = [
  ["MAT135", "Calculus I", "3 new files", "Student"],
  ["PHY131", "Mechanics", "1 announcement", "Student"],
];

export default function AppDashboardPage() {
  return (
    <div className="grid gap-6">
      <section className="flex flex-col justify-between gap-4 rounded-xl border bg-card p-5 md:flex-row md:items-center">
        <div>
          <Badge variant="secondary">Signed in as m@example.com</Badge>
          <h1 className="mt-3 text-2xl font-semibold tracking-tight">
            Course dashboard
          </h1>
          <p className="mt-1 max-w-2xl text-sm text-muted-foreground">
            Manage teaching spaces, continue enrolled courses, and review recent
            course activity from one secure workspace.
          </p>
        </div>
        <Button asChild>
          <a href="/courses/csc108">Open CSC108</a>
        </Button>
      </section>

      <section className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <ShieldCheckIcon className="size-4 text-primary" /> Account status
            </CardTitle>
            <CardDescription>Email verified, OTP enabled</CardDescription>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <MegaphoneIcon className="size-4 text-primary" /> Recent activity
            </CardTitle>
            <CardDescription>4 course updates this week</CardDescription>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <UploadIcon className="size-4 text-primary" /> Instructor tools
            </CardTitle>
            <CardDescription>Invite students and organize files</CardDescription>
          </CardHeader>
        </Card>
      </section>

      <section className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Teaching</CardTitle>
            <CardDescription>Courses where instructor controls are available.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-3">
            {teachingCourses.map(([code, title, meta, role]) => (
              <a key={code} href="/courses/csc108" className="rounded-xl border p-4 hover:bg-muted/50">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="font-medium">{code}</p>
                    <p className="text-sm text-muted-foreground">{title}</p>
                  </div>
                  <Badge>{role}</Badge>
                </div>
                <p className="mt-3 text-sm text-muted-foreground">{meta}</p>
              </a>
            ))}
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Enrolled</CardTitle>
            <CardDescription>Student view without content management controls.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-3">
            {enrolledCourses.map(([code, title, meta, role]) => (
              <div key={code} className="rounded-xl border p-4">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="font-medium">{code}</p>
                    <p className="text-sm text-muted-foreground">{title}</p>
                  </div>
                  <Badge variant="secondary">{role}</Badge>
                </div>
                <p className="mt-3 text-sm text-muted-foreground">{meta}</p>
              </div>
            ))}
          </CardContent>
        </Card>
      </section>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <BookOpenIcon className="size-4 text-primary" /> Recent announcements
          </CardTitle>
          <CardDescription>Latest published updates across your courses.</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-3 text-sm">
          <div className="rounded-xl border p-4">
            CSC108 posted office hour changes for Week 3.
          </div>
          <div className="rounded-xl border p-4">
            MAT135 uploaded tutorial worksheet solutions.
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
