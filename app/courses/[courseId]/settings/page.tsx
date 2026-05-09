import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

const settings = [
  ["General", "Course identity, description, and term", "/courses/csc108/settings/general"],
  ["People", "Roster, invitations, and bulk email import", "/courses/csc108/settings/people"],
  ["Access", "Invitation rules and enrollment posture", "/courses/csc108/settings/access"],
  ["Modules", "Release defaults and ordering behavior", "/courses/csc108/settings/modules"],
  ["Files", "Categories and visibility defaults", "/courses/csc108/settings/files"],
  ["Announcements", "Notification and pinning defaults", "/courses/csc108/settings/announcements"],
  ["Security", "Sensitive actions and audit-oriented controls", "/courses/csc108/settings/security"],
];

export default function CourseSettingsPage() {
  return (
    <div className="grid gap-6">
      <section className="rounded-xl border bg-card p-5">
        <Badge>Instructor only</Badge>
        <h1 className="mt-3 text-2xl font-semibold tracking-tight">Course settings</h1>
        <p className="mt-1 max-w-2xl text-sm text-muted-foreground">
          Course-level controls are not shown to students. Identity and global
          security policy remain outside course settings.
        </p>
      </section>

      <div className="grid gap-4 md:grid-cols-2">
        {settings.map(([title, description, href]) => (
          <Card key={title}>
            <CardHeader>
              <CardTitle>{title}</CardTitle>
              <CardDescription>{description}</CardDescription>
            </CardHeader>
            <CardContent>
              <Button size="sm" variant="outline" asChild>
                <a href={href}>Open</a>
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
