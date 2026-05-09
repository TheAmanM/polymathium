import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function FileDetailPage() {
  return (
    <div className="grid gap-6">
      <Card>
        <CardHeader>
          <div className="flex flex-col justify-between gap-3 md:flex-row md:items-start">
            <div>
              <Badge variant="secondary">Visible to students</Badge>
              <CardTitle className="mt-3 text-2xl">csc108-syllabus.pdf</CardTitle>
              <CardDescription>
                Uploaded Jan 8 by Prof. Ada Lovelace. Attached to Course Home and Week 1.
              </CardDescription>
            </div>
            <div className="flex gap-2">
              <Button variant="outline">Replace</Button>
              <Button>Download</Button>
            </div>
          </div>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-3">
          <div className="rounded-xl border p-4">
            <p className="font-medium">Category</p>
            <p className="mt-1 text-sm text-muted-foreground">Course documents</p>
          </div>
          <div className="rounded-xl border p-4">
            <p className="font-medium">Access</p>
            <p className="mt-1 text-sm text-muted-foreground">All enrolled students</p>
          </div>
          <div className="rounded-xl border p-4">
            <p className="font-medium">Version</p>
            <p className="mt-1 text-sm text-muted-foreground">Current upload</p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
