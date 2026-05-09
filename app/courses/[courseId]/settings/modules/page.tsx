import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function ModuleSettingsPage() {
  return (
    <Card>
      <CardHeader>
        <Badge className="w-fit">Instructor only</Badge>
        <CardTitle className="text-2xl">Module settings</CardTitle>
        <CardDescription>Defaults for release behavior and ordering.</CardDescription>
      </CardHeader>
      <CardContent className="grid gap-3 md:grid-cols-2">
        <div className="rounded-xl border p-4">
          <p className="font-medium">Default state</p>
          <p className="mt-1 text-sm text-muted-foreground">New modules start as drafts.</p>
        </div>
        <div className="rounded-xl border p-4">
          <p className="font-medium">Student visibility</p>
          <p className="mt-1 text-sm text-muted-foreground">Only published modules appear.</p>
        </div>
      </CardContent>
    </Card>
  );
}
