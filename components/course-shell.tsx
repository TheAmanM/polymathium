import { BrandMark } from "@/components/brand-mark";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";

const courseLinks = [
  ["Home", "/courses/csc108"],
  ["Announcements", "/courses/csc108/announcements"],
  ["Modules", "/courses/csc108/modules"],
  ["Files", "/courses/csc108/files"],
  ["Settings", "/courses/csc108/settings"],
];

export function CourseShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-svh bg-muted">
      <header className="border-b bg-background/95 lg:hidden">
        <div className="flex h-14 items-center justify-between px-4">
          <BrandMark />
          <Badge variant="secondary">Instructor view</Badge>
        </div>
      </header>
      <div className="mx-auto flex w-full max-w-7xl flex-col lg:flex-row">
        <aside className="border-b bg-background px-4 py-4 lg:min-h-svh lg:w-72 lg:border-b-0 lg:border-r lg:px-5">
          <div className="hidden lg:block">
            <BrandMark />
          </div>
          <div className="mt-5 rounded-xl border bg-card p-4">
            <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
              Course
            </p>
            <h1 className="mt-1 text-lg font-semibold">CSC108</h1>
            <p className="text-sm text-muted-foreground">
              Introduction to Computer Science
            </p>
            <Badge className="mt-3" variant="secondary">
              Instructor view
            </Badge>
          </div>
          <nav className="mt-4 grid gap-1">
            {courseLinks.map(([label, href]) => (
              <Button key={href} variant="ghost" className="justify-start" asChild>
                <a href={href}>{label}</a>
              </Button>
            ))}
          </nav>
          <p className="mt-5 text-xs leading-5 text-muted-foreground">
            Settings is instructor-only. Students should only see Home,
            Announcements, Modules, and Files.
          </p>
        </aside>
        <main className="flex-1 px-4 py-6 md:px-6 lg:px-8">{children}</main>
      </div>
    </div>
  );
}
