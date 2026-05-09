"use client";

import Link from "next/link";
import { useState } from "react";

import {
  BellIcon,
  BookOpenIcon,
  CreditCardIcon,
  FileTextIcon,
  HomeIcon,
  LogOutIcon,
  MoreVerticalIcon,
  SettingsIcon,
  SquareStackIcon,
  UserCircleIcon,
  Volume2Icon,
} from "lucide-react";

import { BrandMark } from "@/components/brand-mark";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarInset,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarProvider,
  SidebarTrigger,
  useSidebar,
} from "@/components/ui/sidebar";

const courseLinks = [
  { label: "Home", href: "/courses/csc108", icon: HomeIcon },
  {
    label: "Announcements",
    href: "/courses/csc108/announcements",
    icon: Volume2Icon,
  },
  { label: "Modules", href: "/courses/csc108/modules", icon: SquareStackIcon },
  { label: "Files", href: "/courses/csc108/files", icon: FileTextIcon },
  { label: "Settings", href: "/courses/csc108/settings", icon: SettingsIcon },
];

const courses = [
  {
    value: "csc108",
    title: "CSC108",
    description: "Introduction to Computer Science",
    color: "bg-[var(--sample-accent-purple)]",
  },
  {
    value: "mat137",
    title: "MAT137",
    description: "Calculus with Proofs",
    color: "bg-[var(--sample-accent-green)]",
  },
  {
    value: "phy151",
    title: "PHY151",
    description: "Foundations of Physics",
    color: "bg-[var(--sample-accent-orange)]",
  },
];

const user = {
  name: "Sam Rogers",
  email: "sam.rogers@university.edu",
  avatar: "https://i.pravatar.cc/100?img=1",
};

function CourseSelector() {
  const [selectedCourse, setSelectedCourse] = useState(courses[0]);

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button className="flex w-full items-center gap-3 rounded-[var(--sample-radius-lg)] bg-card p-4 text-left shadow-[var(--sample-card-shadow)] outline-none ring-1 ring-[var(--sample-border-light)] transition-colors hover:bg-muted/40 focus-visible:ring-3 focus-visible:ring-ring/20">
          <span
            className={`flex size-6 shrink-0 items-center justify-center rounded-full ${selectedCourse.color}`}
          >
            <BookOpenIcon className="size-3 text-white" />
          </span>
          <span className="min-w-0 flex-1">
            <span className="block truncate text-sm font-semibold">
              {selectedCourse.title}
            </span>
            <span className="block truncate text-xs text-muted-foreground">
              {selectedCourse.description}
            </span>
          </span>
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent
        className="w-(--radix-dropdown-menu-trigger-width) min-w-64 p-2"
        align="start"
        sideOffset={8}
      >
        <DropdownMenuLabel className="px-2 py-1 text-[10px] font-bold tracking-wide text-muted-foreground uppercase">
          Switch course
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        {courses.map((course) => (
          <DropdownMenuItem
            key={course.value}
            className="my-1 flex cursor-pointer items-center gap-3 rounded-[var(--sample-radius-lg)] p-3 focus:bg-muted"
            onSelect={() => setSelectedCourse(course)}
          >
            <span
              className={`flex size-6 shrink-0 items-center justify-center rounded-full ${course.color}`}
            >
              <BookOpenIcon className="size-3 text-white" />
            </span>
            <span className="min-w-0 flex-1">
              <span className="block truncate text-sm font-semibold">
                {course.title}
              </span>
              <span className="block truncate text-xs text-muted-foreground">
                {course.description}
              </span>
            </span>
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}

function NavUser() {
  const { isMobile } = useSidebar();

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <SidebarMenuButton
              size="lg"
              className="h-auto rounded-[var(--sample-radius-lg)] bg-card p-3 shadow-[var(--sample-card-shadow)] ring-0 ring-[var(--sample-border-light)] data-[state=open]:bg-sidebar-accent data-[state=open]:text-sidebar-accent-foreground"
            >
              <Avatar className="size-9 rounded-full border-0">
                <AvatarImage src={user.avatar} alt={user.name} />
                <AvatarFallback className="rounded-lg">SR</AvatarFallback>
              </Avatar>
              <div className="grid flex-1 text-left text-sm leading-tight">
                <span className="truncate font-semibold">{user.name}</span>
                <span className="truncate text-xs text-muted-foreground">
                  {user.email}
                </span>
              </div>
              <MoreVerticalIcon className="ml-auto size-4" />
            </SidebarMenuButton>
          </DropdownMenuTrigger>
          <DropdownMenuContent
            className="w-(--radix-dropdown-menu-trigger-width) min-w-56 rounded-[var(--sample-radius-lg)]"
            side={isMobile ? "bottom" : "right"}
            align="end"
            sideOffset={4}
          >
            <DropdownMenuLabel className="p-0 font-normal">
              <div className="flex items-center gap-2 px-2 py-2 text-left text-sm">
                <Avatar className="size-9 rounded-full border-0">
                  <AvatarImage src={user.avatar} alt={user.name} />
                  <AvatarFallback className="rounded-lg">SR</AvatarFallback>
                </Avatar>
                <div className="grid flex-1 text-left text-sm leading-tight">
                  <span className="truncate font-semibold text-black">
                    {user.name}
                  </span>
                  <span className="truncate text-xs text-muted-foreground">
                    {user.email}
                  </span>
                </div>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuGroup>
              <DropdownMenuItem>
                <UserCircleIcon />
                Account
              </DropdownMenuItem>
              <DropdownMenuItem>
                <CreditCardIcon />
                Billing
              </DropdownMenuItem>
              <DropdownMenuItem>
                <BellIcon />
                Notifications
              </DropdownMenuItem>
            </DropdownMenuGroup>
            <DropdownMenuSeparator />
            <DropdownMenuItem>
              <LogOutIcon />
              Log out
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </SidebarMenuItem>
    </SidebarMenu>
  );
}

export function CourseShell({ children }: { children: React.ReactNode }) {
  return (
    <SidebarProvider>
      <Sidebar className="border-sidebar-border" collapsible="offcanvas">
        <SidebarHeader className="gap-5 pt-5 px-2.5">
          <div className="flex justify-center">
            <BrandMark />
          </div>
          <CourseSelector />
        </SidebarHeader>
        <SidebarContent>
          <SidebarGroup className="py-3">
            <SidebarGroupLabel className="px-2 pb-2 text-xs font-extrabold tracking-wide uppercase text-muted-foreground">
              Navigation
            </SidebarGroupLabel>
            <SidebarGroupContent>
              <SidebarMenu className="gap-1.5">
                {courseLinks.map(({ label, href, icon: Icon }) => (
                  <SidebarMenuItem key={href}>
                    <SidebarMenuButton
                      asChild
                      className="h-auto rounded-[var(--sample-radius-sm)] px-3 py-2 text-xs font-medium outline-hidden select-none hover:bg-accent hover:text-accent-foreground focus-visible:bg-accent focus-visible:text-accent-foreground active:bg-accent data-active:bg-accent data-active:text-accent-foreground [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0"
                    >
                      <Link href={href}>
                        <Icon />
                        <span>{label}</span>
                      </Link>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                ))}
              </SidebarMenu>
            </SidebarGroupContent>
          </SidebarGroup>
        </SidebarContent>
        <SidebarFooter className="p-2.5">
          <NavUser />
        </SidebarFooter>
      </Sidebar>
      <SidebarInset>
        <header className="sticky top-0 z-10 flex h-14 items-center justify-between border-b bg-background/95 px-4 backdrop-blur md:px-6 lg:px-8">
          <div className="flex items-center gap-3">
            <SidebarTrigger />
            <span className="text-sm font-semibold">CSC108</span>
          </div>
          <Badge variant="secondary">Instructor view</Badge>
        </header>
        <main className="flex-1 px-4 py-6 md:px-6 lg:px-8">{children}</main>
      </SidebarInset>
    </SidebarProvider>
  );
}
