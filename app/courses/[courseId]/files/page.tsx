import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

const files = [
  ["csc108-syllabus.pdf", "Course documents", "Visible"],
  ["week-3-starter.zip", "Module files", "Visible"],
  ["midterm-draft-notes.pdf", "Instructor only", "Restricted"],
];

export default function FilesPage() {
  return (
    <div className="grid gap-6">
      <section className="flex flex-col justify-between gap-4 rounded-xl border bg-card p-5 md:flex-row md:items-center">
        <div>
          <Badge variant="secondary">Course tab</Badge>
          <h1 className="mt-3 text-2xl font-semibold tracking-tight">Files</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Upload once, categorize quickly, and attach files to modules.
          </p>
        </div>
        <Button>Upload files</Button>
      </section>

      <Card>
        <CardHeader>
          <CardTitle>File library</CardTitle>
          <CardDescription>Students only see files with explicit access.</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-3">
          {files.map(([name, category, status]) => (
            <a key={name} href="/courses/csc108/files/syllabus" className="rounded-xl border p-4 hover:bg-muted/50">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <p className="font-medium">{name}</p>
                  <p className="mt-1 text-sm text-muted-foreground">{category}</p>
                </div>
                <Badge variant={status === "Restricted" ? "outline" : "secondary"}>{status}</Badge>
              </div>
            </a>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}
