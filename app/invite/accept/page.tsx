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
import { FieldDescription } from "@/components/ui/field";
import { Separator } from "@/components/ui/separator";

const inviteDetails = [
  ["Course", "CSC108: Introduction to Computer Science"],
  ["Role", "Student"],
  ["Invited email", "student@example.com"],
];

export default function AcceptInvitePage() {
  return (
    <div className="flex min-h-svh flex-col items-center justify-center gap-6 bg-muted p-6 md:p-10">
      <div className="flex w-full max-w-md flex-col gap-6">
        <div className="self-center">
          <BrandMark />
        </div>
        <Card>
          <CardHeader className="text-center">
            <Badge className="mx-auto" variant="secondary">
              Course invitation
            </Badge>
            <CardTitle className="text-xl">Accept your invitation</CardTitle>
            <CardDescription>
              Review the course and email before continuing.
            </CardDescription>
          </CardHeader>
          <CardContent className="grid gap-4">
            <div className="rounded-xl border bg-muted/40 p-4">
              {inviteDetails.map(([label, value], index) => (
                <div key={label}>
                  {index > 0 ? <Separator className="my-3" /> : null}
                  <div className="flex items-start justify-between gap-4">
                    <span className="text-sm text-muted-foreground">{label}</span>
                    <span className="max-w-56 text-right text-sm font-medium">
                      {value}
                    </span>
                  </div>
                </div>
              ))}
            </div>
            <Button>Continue with this email</Button>
            <Button variant="outline">Use a different invitation</Button>
          </CardContent>
        </Card>
        <FieldDescription className="px-6 text-center">
          Your official course name is managed by the institution and cannot be
          edited from the student profile.
        </FieldDescription>
      </div>
    </div>
  );
}
