import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

const items = [
  ["Read", "Functions chapter notes"],
  ["Watch", "Testing walkthrough"],
  ["Download", "week-3-starter.zip"],
  ["Submit", "Practice checkpoint"],
];

export default function ModuleDetailPage() {
  return (
    <div className="grid gap-6">
      <Card>
        <CardHeader>
          <div className="flex flex-col justify-between gap-3 md:flex-row md:items-start">
            <div>
              <Badge>Published</Badge>
              <CardTitle className="mt-3 text-2xl">Week 3: Functions and testing</CardTitle>
              <CardDescription>Released Jan 22. Visible to enrolled students.</CardDescription>
            </div>
            <Button variant="outline">Edit module</Button>
          </div>
        </CardHeader>
        <CardContent className="grid gap-3">
          {items.map(([type, title]) => (
            <div key={title} className="flex items-center justify-between rounded-xl border p-4">
              <div>
                <Badge variant="secondary">{type}</Badge>
                <p className="mt-2 font-medium">{title}</p>
              </div>
              <Button size="sm" variant="outline">Open</Button>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}
