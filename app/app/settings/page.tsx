import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export default function AccountSettingsPage() {
  return (
    <div className="grid gap-6">
      <section className="rounded-xl border bg-card p-5">
        <Badge variant="secondary">Personal settings</Badge>
        <h1 className="mt-3 text-2xl font-semibold tracking-tight">
          Profile and account
        </h1>
        <p className="mt-1 max-w-2xl text-sm text-muted-foreground">
          Manage preferences without weakening identity controls. Official names
          and verified email are protected fields.
        </p>
      </section>

      <div className="grid gap-6 lg:grid-cols-[1.3fr_0.7fr]">
        <Card>
          <CardHeader>
            <CardTitle>Identity</CardTitle>
            <CardDescription>
              These fields are controlled by your institution or invitation.
            </CardDescription>
          </CardHeader>
          <CardContent className="grid gap-4">
            <div className="grid gap-2">
              <Label htmlFor="name">Official name</Label>
              <Input id="name" value="Mina Chen" readOnly />
              <p className="text-xs text-muted-foreground">
                Students cannot change official names from Polymathium.
              </p>
            </div>
            <div className="grid gap-2">
              <Label htmlFor="email">Verified email</Label>
              <Input id="email" value="m@example.com" readOnly />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Security</CardTitle>
            <CardDescription>Email link and OTP sign-in are active.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-3">
            <div className="rounded-xl border p-3 text-sm">Last sign-in: today</div>
            <div className="rounded-xl border p-3 text-sm">Trusted devices: 1</div>
            <Button variant="outline">Review sessions</Button>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Preferences</CardTitle>
          <CardDescription>
            Safe personal settings students and instructors can control.
          </CardDescription>
        </CardHeader>
        <CardContent className="grid gap-3 md:grid-cols-3">
          <div className="rounded-xl border p-4">
            <p className="font-medium">Notifications</p>
            <p className="mt-1 text-sm text-muted-foreground">
              Course announcements and file updates.
            </p>
          </div>
          <div className="rounded-xl border p-4">
            <p className="font-medium">Timezone</p>
            <p className="mt-1 text-sm text-muted-foreground">America/Toronto</p>
          </div>
          <div className="rounded-xl border p-4">
            <p className="font-medium">Theme</p>
            <p className="mt-1 text-sm text-muted-foreground">System default</p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
