import { BrandMark } from "@/components/brand-mark";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function Home() {
  return (
    <div className="flex min-h-svh flex-col items-center justify-center gap-6 bg-muted p-6 md:p-10">
      <div className="flex w-full max-w-4xl flex-col gap-6">
        <div className="self-center">
          <BrandMark />
        </div>
        <Card>
          <CardHeader className="items-center text-center">
            <Badge variant="secondary">UI preview</Badge>
            <CardTitle className="max-w-2xl text-3xl font-semibold tracking-tight">
              A focused, secure course workspace for instructors and students.
            </CardTitle>
            <CardDescription className="max-w-xl">
              Polymathium is being built as a professional Quercus alternative
              with secure email login, clean course navigation, modules, files,
              announcements, and role-aware settings.
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col items-center gap-3 sm:flex-row sm:justify-center">
            <Button asChild>
              <a href="/login">Sign in</a>
            </Button>
            <Button variant="outline" asChild>
              <a href="/app">View dashboard UI</a>
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
