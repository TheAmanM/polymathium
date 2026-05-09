import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function AnnouncementSettingsPage() {
  return (
    <Card>
      <CardHeader>
        <Badge className="w-fit">Instructor only</Badge>
        <CardTitle className="text-2xl">Announcement settings</CardTitle>
        <CardDescription>Defaults for publishing, pinning, and notifications.</CardDescription>
      </CardHeader>
      <CardContent className="grid gap-3 md:grid-cols-3">
        <div className="rounded-xl border p-4">
          <p className="font-medium">Default state</p>
          <p className="mt-1 text-sm text-muted-foreground">Draft until published.</p>
        </div>
        <div className="rounded-xl border p-4">
          <p className="font-medium">Pinned item</p>
          <p className="mt-1 text-sm text-muted-foreground">One prominent pinned update.</p>
        </div>
        <div className="rounded-xl border p-4">
          <p className="font-medium">Notifications</p>
          <p className="mt-1 text-sm text-muted-foreground">Email summary by default.</p>
        </div>
      </CardContent>
    </Card>
  );
}
