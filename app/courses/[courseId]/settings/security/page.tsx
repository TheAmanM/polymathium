import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function SecuritySettingsPage() {
  return (
    <div className="grid gap-6">
      <Card>
        <CardHeader>
          <Badge className="w-fit">Instructor only</Badge>
          <CardTitle className="text-2xl">Security</CardTitle>
          <CardDescription>
            Course-level sensitive actions and audit-oriented controls.
          </CardDescription>
        </CardHeader>
        <CardContent className="grid gap-3">
          <div className="rounded-xl border p-4">
            <p className="font-medium">Sensitive confirmations</p>
            <p className="mt-1 text-sm text-muted-foreground">
              Removing students, deleting files, and changing access rules should
              require explicit confirmation.
            </p>
          </div>
          <div className="rounded-xl border p-4">
            <p className="font-medium">Audit metadata</p>
            <p className="mt-1 text-sm text-muted-foreground">
              Content surfaces should show created by, updated by, and published
              timestamps where relevant.
            </p>
          </div>
          <Button variant="outline" className="w-fit">Review security posture</Button>
        </CardContent>
      </Card>
    </div>
  );
}
