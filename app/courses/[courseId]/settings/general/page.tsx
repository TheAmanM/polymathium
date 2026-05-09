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
import { Textarea } from "@/components/ui/textarea";

export default function GeneralSettingsPage() {
  return (
    <div className="grid gap-6">
      <Card>
        <CardHeader>
          <Badge className="w-fit">Instructor only</Badge>
          <CardTitle className="text-2xl">General settings</CardTitle>
          <CardDescription>Course identity and public description.</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4">
          <div className="grid gap-2">
            <Label htmlFor="title">Course title</Label>
            <Input id="title" defaultValue="Introduction to Computer Science" />
          </div>
          <div className="grid gap-2 md:grid-cols-2">
            <div className="grid gap-2">
              <Label htmlFor="code">Course code</Label>
              <Input id="code" defaultValue="CSC108" />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="term">Term</Label>
              <Input id="term" defaultValue="Winter 2026" />
            </div>
          </div>
          <div className="grid gap-2">
            <Label htmlFor="description">Description</Label>
            <Textarea id="description" defaultValue="Programming fundamentals, computational thinking, testing, and structured problem solving." />
          </div>
          <Button className="w-fit">Save changes</Button>
        </CardContent>
      </Card>
    </div>
  );
}
