import { BrandMark } from "@/components/brand-mark";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { LoaderCircleIcon, ShieldCheckIcon } from "lucide-react";

export default function AuthCallbackPage() {
  return (
    <div className="flex min-h-svh flex-col items-center justify-center gap-6 bg-muted p-6 md:p-10">
      <div className="flex w-full max-w-sm flex-col gap-6">
        <div className="self-center">
          <BrandMark />
        </div>
        <Card>
          <CardHeader className="items-center text-center">
            <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <ShieldCheckIcon className="size-5" />
            </div>
            <CardTitle className="text-xl">Securing your session</CardTitle>
            <CardDescription>
              We are verifying your sign-in link and preparing your workspace.
            </CardDescription>
          </CardHeader>
          <CardContent className="flex items-center justify-center gap-2 text-sm text-muted-foreground">
            <LoaderCircleIcon className="size-4 animate-spin" />
            Please keep this tab open.
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
