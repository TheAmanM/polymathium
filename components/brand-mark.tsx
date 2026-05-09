import { GalleryVerticalEndIcon } from "lucide-react";

export function BrandMark() {
  return (
    <a href="/app" className="flex items-center gap-2 font-medium">
      <div className="flex size-6 items-center justify-center rounded-xl bg-primary text-primary-foreground">
        <GalleryVerticalEndIcon className="size-4" />
      </div>
      Polymathium
    </a>
  );
}
