import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";

export default function CourseHomePage() {
  return (
    <div className="grid gap-6">
      <section className="rounded-xl border bg-card p-5">
        <Badge variant="secondary">Winter 2026</Badge>
        <h1 className="mt-3 text-3xl font-semibold tracking-tight">
          CSC108: Introduction to Computer Science
        </h1>
        <p className="mt-2 max-w-3xl text-sm text-muted-foreground">
          Course home page with pinned updates, the current module, and the most
          important files surfaced for students.
        </p>
      </section>

      <div className="grid gap-6 lg:grid-cols-[1.3fr_0.7fr]">
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between gap-3">
              <CardTitle>Pinned announcement</CardTitle>
              <Badge>Published</Badge>
            </div>
            <CardDescription>Posted by Prof. Ada Lovelace</CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm leading-6">
              Welcome to CSC108. Please review the syllabus, complete the Week 1
              setup checklist, and confirm that you can access all starter files.
            </p>
            <Separator className="my-4" />
            <Button size="sm" variant="outline" asChild>
              <a href="/courses/csc108/announcements/welcome">Read announcement</a>
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Instructor actions</CardTitle>
            <CardDescription>Hidden for students.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-2">
            <Button variant="outline">Post announcement</Button>
            <Button variant="outline">Upload files</Button>
            <Button variant="outline">Invite students</Button>
          </CardContent>
        </Card>
      </div>

      <section className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle>Current module</CardTitle>
            <CardDescription>Week 3: Functions and testing</CardDescription>
          </CardHeader>
          <CardContent>
            <Button size="sm" asChild>
              <a href="/courses/csc108/modules/week-3">Open module</a>
            </Button>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Recent files</CardTitle>
            <CardDescription>4 uploads in the last 7 days</CardDescription>
          </CardHeader>
          <CardContent>
            <Button size="sm" variant="outline" asChild>
              <a href="/courses/csc108/files">Browse files</a>
            </Button>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Roster</CardTitle>
            <CardDescription>186 active students</CardDescription>
          </CardHeader>
          <CardContent>
            <Button size="sm" variant="outline" asChild>
              <a href="/courses/csc108/settings/people">Manage people</a>
            </Button>
          </CardContent>
        </Card>
      </section>
    </div>
  );
}
