import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

const categories = ["Course documents", "Module files", "Assignments", "Instructor only"];

export default function FileSettingsPage() {
  return (
    <Card>
      <CardHeader>
        <Badge className="w-fit">Instructor only</Badge>
        <CardTitle className="text-2xl">File settings</CardTitle>
        <CardDescription>Categories and file visibility defaults.</CardDescription>
      </CardHeader>
      <CardContent className="grid gap-3">
        {categories.map((category) => (
          <div key={category} className="flex items-center justify-between rounded-xl border p-4">
            <p className="font-medium">{category}</p>
            <Button size="sm" variant="outline">Edit</Button>
          </div>
        ))}
      </CardContent>
    </Card>
  );
}
