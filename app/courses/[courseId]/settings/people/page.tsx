import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";

const roster = [
  ["Mina Chen", "m@example.com", "Instructor"],
  ["Jordan Patel", "jordan@example.com", "Student"],
  ["Sam Rivera", "sam@example.com", "Student"],
];

export default function PeopleSettingsPage() {
  return (
    <div className="grid gap-6">
      <section className="rounded-xl border bg-card p-5">
        <Badge>Instructor only</Badge>
        <h1 className="mt-3 text-2xl font-semibold tracking-tight">People</h1>
        <p className="mt-1 max-w-2xl text-sm text-muted-foreground">
          Add students by pasting an email list. Official names are not editable
          by students or course instructors here.
        </p>
      </section>

      <div className="grid gap-6 lg:grid-cols-[0.9fr_1.1fr]">
        <Card>
          <CardHeader>
            <CardTitle>Bulk invite</CardTitle>
            <CardDescription>Preview validation before invitations are sent.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-3">
            <Textarea placeholder="student.one@example.com&#10;student.two@example.com" />
            <Button>Preview email list</Button>
            <p className="text-xs text-muted-foreground">
              No invitation should send until the instructor confirms the preview.
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Roster</CardTitle>
            <CardDescription>Active course members and roles.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-3">
            {roster.map(([name, email, role]) => (
              <div key={email} className="flex items-center justify-between rounded-xl border p-4">
                <div>
                  <p className="font-medium">{name}</p>
                  <p className="text-sm text-muted-foreground">{email}</p>
                </div>
                <Badge variant={role === "Instructor" ? "default" : "secondary"}>{role}</Badge>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
