import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function AccessSettingsPage() {
  return (
    <div className="grid gap-6">
      <Card>
        <CardHeader>
          <Badge className="w-fit">Instructor only</Badge>
          <CardTitle className="text-2xl">Access</CardTitle>
          <CardDescription>Course entry rules and enrollment posture.</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-3 md:grid-cols-3">
          <div className="rounded-xl border p-4">
            <p className="font-medium">Join policy</p>
            <p className="mt-1 text-sm text-muted-foreground">Invite only</p>
          </div>
          <div className="rounded-xl border p-4">
            <p className="font-medium">Login method</p>
            <p className="mt-1 text-sm text-muted-foreground">Email link or OTP</p>
          </div>
          <div className="rounded-xl border p-4">
            <p className="font-medium">Student settings</p>
            <p className="mt-1 text-sm text-muted-foreground">Settings tab hidden</p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
