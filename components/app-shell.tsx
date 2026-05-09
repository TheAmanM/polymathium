import { BrandMark } from "@/components/brand-mark";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";

export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-svh bg-muted">
      <header className="border-b bg-background/95">
        <div className="mx-auto flex h-14 w-full max-w-6xl items-center justify-between px-4 md:px-6">
          <BrandMark />
          <nav className="hidden items-center gap-1 text-sm md:flex">
            <Button variant="ghost" asChild>
              <a href="/app">Courses</a>
            </Button>
            <Button variant="ghost" asChild>
              <a href="/app/settings">Profile</a>
            </Button>
          </nav>
          <div className="flex items-center gap-2">
            <Badge variant="secondary">Verified</Badge>
            <Button variant="outline" size="sm">
              Account
            </Button>
          </div>
        </div>
      </header>
      <main className="mx-auto w-full max-w-6xl px-4 py-6 md:px-6">
        {children}
      </main>
    </div>
  );
}
