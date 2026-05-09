import * as React from "react"

import { Avatar, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import {
  InputGroup,
  InputGroupAddon,
  InputGroupInput,
} from "@/components/ui/input-group"
import { cn } from "@/lib/utils"

function DashboardNavbar({ className, ...props }: React.ComponentProps<"nav">) {
  return (
    <nav
      data-slot="dashboard-navbar"
      className={cn(
        "mx-5 flex h-[60px] items-center justify-between rounded-b-[var(--sample-radius-lg)] bg-primary px-10 text-[11px] font-semibold tracking-[0.5px] text-white uppercase",
        className
      )}
      {...props}
    />
  )
}

function DashboardNavLinks({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="dashboard-nav-links"
      className={cn("flex gap-10", className)}
      {...props}
    />
  )
}

function DashboardNavLink({ className, ...props }: React.ComponentProps<"span">) {
  return (
    <span
      data-slot="dashboard-nav-link"
      className={cn("relative cursor-pointer", className)}
      {...props}
    />
  )
}

function DashboardNavCount({ className, ...props }: React.ComponentProps<"sup">) {
  return (
    <sup
      data-slot="dashboard-nav-count"
      className={cn("absolute -top-1 -right-2.5 text-[8px]", className)}
      {...props}
    />
  )
}

function DashboardNavIcons({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="dashboard-nav-icons"
      className={cn("flex items-center gap-5", className)}
      {...props}
    />
  )
}

function DashboardIcon({ className, ...props }: React.ComponentProps<"svg">) {
  return (
    <svg
      data-slot="dashboard-icon"
      className={cn("size-5 cursor-pointer fill-none stroke-white stroke-2", className)}
      viewBox="0 0 24 24"
      {...props}
    />
  )
}

function DashboardContainer({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="dashboard-container"
      className={cn(className)}
      {...props}
    />
  )
}

function DashboardSearch({ className, ...props }: React.ComponentProps<typeof InputGroup>) {
  return (
    <div data-slot="dashboard-search-container" className="mb-[50px] flex justify-center">
      <InputGroup
        data-slot="dashboard-search"
        className={cn("w-full max-w-[600px]", className)}
        {...props}
      />
    </div>
  )
}

function SearchIcon({ className, ...props }: React.ComponentProps<"svg">) {
  return (
    <svg
      data-slot="search-icon"
      className={cn("size-4 fill-none stroke-[var(--sample-input-placeholder)] stroke-2", className)}
      viewBox="0 0 24 24"
      {...props}
    >
      <circle cx="11" cy="11" r="8" />
      <line x1="21" y1="21" x2="16.65" y2="16.65" />
    </svg>
  )
}

function DashboardSearchInput({ className, ...props }: React.ComponentProps<typeof InputGroupInput>) {
  return (
    <>
      <InputGroupAddon>
        <SearchIcon />
      </InputGroupAddon>
      <InputGroupInput
        className={cn("placeholder:text-[var(--sample-input-placeholder)]", className)}
        placeholder="Enter discipline names"
        {...props}
      />
    </>
  )
}

function DashboardSearchButton({ className, ...props }: React.ComponentProps<typeof Button>) {
  return (
    <Button
      data-slot="dashboard-search-button"
      className={cn("h-11 rounded-none px-[30px]", className)}
      {...props}
    />
  )
}

function DashboardGrid({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="dashboard-grid" className={cn(className)} {...props} />
}

function DashboardMiddleGrid({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="dashboard-middle-grid" className={cn(className)} {...props} />
}

type DisciplineDot = "purple" | "green" | "orange"

function DisciplineDot({ color = "purple" }: { color?: DisciplineDot }) {
  return (
    <span
      data-slot="discipline-dot"
      className={cn(
        color === "purple" && "bg-[var(--sample-accent-purple)]",
        color === "green" && "bg-[var(--sample-accent-green)]",
        color === "orange" && "bg-[var(--sample-accent-orange)]"
      )}
    />
  )
}

function DisciplineCard({
  title,
  color = "purple",
  description,
  tags = [],
  date,
  className,
  ...props
}: React.ComponentProps<typeof Card> & {
  title: string
  color?: DisciplineDot
  description: string
  tags?: string[]
  date: string
}) {
  return (
    <Card data-slot="discipline-card" className={cn("gap-0", className)} {...props}>
      <CardHeader className="mb-3">
        <CardTitle className="flex items-center gap-2">
          {title}
          <DisciplineDot color={color} />
        </CardTitle>
      </CardHeader>
      <CardContent>
        <CardDescription className="mb-5">{description}</CardDescription>
        <div data-slot="discipline-tags" className="mb-5 flex gap-2">
          {tags.map((tag) => (
            <Badge key={tag} variant="tag">
              {tag}
            </Badge>
          ))}
        </div>
      </CardContent>
      <CardFooter className="border-t-0 pt-0">
        <span>{date}</span>
        <BookmarkIcon />
      </CardFooter>
    </Card>
  )
}

function BookmarkIcon({ className, ...props }: React.ComponentProps<"svg">) {
  return (
    <svg
      data-slot="bookmark-icon"
      className={cn("size-3.5 cursor-pointer fill-none stroke-muted-foreground stroke-2", className)}
      viewBox="0 0 24 24"
      {...props}
    >
      <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z" />
    </svg>
  )
}

function ResultsCard({ className, ...props }: React.ComponentProps<typeof Card>) {
  return (
    <Card
      data-slot="results-card"
      className={cn("flex-row items-center justify-between gap-4 p-6 md:h-[90px]", className)}
      {...props}
    />
  )
}

function ResultsTitle({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="results-title"
      className={cn("mb-3 text-xs font-semibold", className)}
      {...props}
    />
  )
}

function AddCard({ className, ...props }: React.ComponentProps<"button">) {
  return (
    <button
      data-slot="add-card"
      className={cn(
        "flex min-h-[90px] cursor-pointer items-center justify-center rounded-[var(--sample-radius-lg)] border border-dashed border-[var(--sample-border-dashed)] bg-transparent",
        className
      )}
      {...props}
    />
  )
}

function AddIcon({ className, ...props }: React.ComponentProps<"span">) {
  return (
    <span
      data-slot="add-icon"
      className={cn(
        "flex size-6 items-center justify-center rounded-full bg-[var(--sample-input-bg)] text-base text-[var(--sample-input-placeholder)]",
        className
      )}
      {...props}
    />
  )
}

function SourcesHeader({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="sources-header"
      className={cn("mb-5 flex items-end justify-between", className)}
      {...props}
    />
  )
}

function SourceCard({ className, ...props }: React.ComponentProps<typeof Card>) {
  return (
    <Card data-slot="source-card" className={cn("gap-0 p-0", className)} {...props} />
  )
}

function SourceHeader({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="source-header"
      className={cn(
        "flex items-center justify-between border-b border-[var(--sample-border-light)] px-6 py-5 text-sm font-semibold",
        className
      )}
      {...props}
    />
  )
}

function SourceUser({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="source-user"
      className={cn("flex items-center gap-3 px-6 py-5", className)}
      {...props}
    />
  )
}

function SourceUserInfo({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="source-user-info" className={cn(className)} {...props} />
}

function SourceUserName({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="source-user-name"
      className={cn("text-xs font-semibold text-primary", className)}
      {...props}
    />
  )
}

function SourceUserUniversity({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="source-user-university"
      className={cn("text-[11px] text-muted-foreground", className)}
      {...props}
    />
  )
}

function SourceStats({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="source-stats" className={cn("flex px-6 pb-5", className)} {...props} />
}

function SourceStat({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="source-stat" className={cn("flex-1", className)} {...props} />
}

function SourceStatValue({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="source-stat-value"
      className={cn("mb-1 text-[22px] font-semibold text-[var(--sample-link-blue)]", className)}
      {...props}
    />
  )
}

function SourceStatLabel({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="source-stat-label"
      className={cn("text-[11px] font-semibold", className)}
      {...props}
    />
  )
}

function SourceFooter({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="source-footer"
      className={cn(
        "flex border-t border-[var(--sample-border-light)] px-6 py-4 text-[10px] leading-[1.4] text-muted-foreground",
        className
      )}
      {...props}
    />
  )
}

function SourceFooterBlock({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="source-footer-block" className={cn("flex-1", className)} {...props} />
}

function CaretIcon({ className, ...props }: React.ComponentProps<"svg">) {
  return (
    <svg
      data-slot="caret-icon"
      className={cn("size-4 fill-none stroke-foreground stroke-2", className)}
      viewBox="0 0 24 24"
      {...props}
    >
      <path d="M7 15l5-5 5 5" />
      <path d="M7 9l5 5 5-5" opacity="0.3" />
    </svg>
  )
}

function SourceAvatar({ src, alt }: { src: string; alt: string }) {
  return (
    <Avatar>
      <AvatarImage src={src} alt={alt} />
    </Avatar>
  )
}

export {
  AddCard,
  AddIcon,
  BookmarkIcon,
  CaretIcon,
  DashboardContainer,
  DashboardGrid,
  DashboardIcon,
  DashboardMiddleGrid,
  DashboardNavbar,
  DashboardNavCount,
  DashboardNavIcons,
  DashboardNavLink,
  DashboardNavLinks,
  DashboardSearch,
  DashboardSearchButton,
  DashboardSearchInput,
  DisciplineCard,
  DisciplineDot,
  ResultsCard,
  ResultsTitle,
  SearchIcon,
  SourceAvatar,
  SourceCard,
  SourceFooter,
  SourceFooterBlock,
  SourceHeader,
  SourceStat,
  SourceStatLabel,
  SourceStats,
  SourceStatValue,
  SourceUser,
  SourceUserInfo,
  SourceUserName,
  SourceUserUniversity,
  SourcesHeader,
}
