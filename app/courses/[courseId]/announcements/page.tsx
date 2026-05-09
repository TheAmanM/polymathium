import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

const announcements = [
  ["Welcome and setup checklist", "Pinned", "Published Jan 8"],
  ["Week 3 office hour changes", "Published", "Published Jan 22"],
  ["Draft: Midterm review room", "Draft", "Not visible to students"],
];

export default function AnnouncementsPage() {
  return (
    <div className="grid gap-6">
      <section className="flex flex-col justify-between gap-4 rounded-xl border bg-card p-5 md:flex-row md:items-center">
        <div>
          <Badge variant="secondary">Course tab</Badge>
          <h1 className="mt-3 text-2xl font-semibold tracking-tight">
            Announcements
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Published updates are visible to students. Drafts are instructor-only.
          </p>
        </div>
        <Button>Create announcement</Button>
      </section>

      <Card>
        <CardHeader>
          <CardTitle>Course updates</CardTitle>
          <CardDescription>Search, pin, publish, and review announcements.</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-3">
          {announcements.map(([title, status, meta]) => (
            <a key={title} href="/courses/csc108/announcements/welcome" className="rounded-xl border p-4 hover:bg-muted/50">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <p className="font-medium">{title}</p>
                  <p className="mt-1 text-sm text-muted-foreground">{meta}</p>
                </div>
                <Badge variant={status === "Draft" ? "outline" : "secondary"}>{status}</Badge>
              </div>
            </a>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}
