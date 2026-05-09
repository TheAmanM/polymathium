import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function AnnouncementDetailPage() {
  return (
    <div className="grid gap-6">
      <Card>
        <CardHeader>
          <div className="flex flex-col justify-between gap-3 md:flex-row md:items-start">
            <div>
              <Badge>Published</Badge>
              <CardTitle className="mt-3 text-2xl">
                Welcome and setup checklist
              </CardTitle>
              <CardDescription>
                Posted Jan 8 by Prof. Ada Lovelace. Visible to all enrolled
                students.
              </CardDescription>
            </div>
            <Button variant="outline">Edit announcement</Button>
          </div>
        </CardHeader>
        <CardContent className="grid gap-4 text-sm leading-6">
          <p>
            Welcome to CSC108. This course workspace contains official files,
            weekly modules, and announcements. Start by reviewing the syllabus
            and completing the setup instructions.
          </p>
          <div className="rounded-xl border bg-muted/40 p-4">
            Attachment: `csc108-syllabus.pdf` linked in Files and Week 1.
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
