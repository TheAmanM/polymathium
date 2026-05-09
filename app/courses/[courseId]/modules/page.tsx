import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

const modules = [
  ["Week 1", "Python setup and course tools", "Published"],
  ["Week 2", "Variables, expressions, and types", "Published"],
  ["Week 3", "Functions and testing", "Published"],
  ["Week 4", "Lists and iteration", "Draft"],
];

export default function ModulesPage() {
  return (
    <div className="grid gap-6">
      <section className="flex flex-col justify-between gap-4 rounded-xl border bg-card p-5 md:flex-row md:items-center">
        <div>
          <Badge variant="secondary">Course tab</Badge>
          <h1 className="mt-3 text-2xl font-semibold tracking-tight">Modules</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Ordered learning materials with release status and attached files.
          </p>
        </div>
        <Button>Create module</Button>
      </section>

      <Card>
        <CardHeader>
          <CardTitle>Module sequence</CardTitle>
          <CardDescription>Students only see published modules.</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-3">
          {modules.map(([week, title, status]) => (
            <a key={week} href="/courses/csc108/modules/week-3" className="rounded-xl border p-4 hover:bg-muted/50">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <p className="font-medium">{week}</p>
                  <p className="mt-1 text-sm text-muted-foreground">{title}</p>
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
