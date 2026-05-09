import { NextRequest, NextResponse } from "next/server";
import { decodeSession, SESSION_COOKIE_NAME } from "@/lib/auth";

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const session = decodeSession(request.cookies.get(SESSION_COOKIE_NAME)?.value);
  const isPublicPath =
    pathname === "/login" ||
    pathname === "/admin/login" ||
    pathname === "/signup" ||
    pathname.startsWith("/onboarding/spotify");

  const isAdminProtected =
    (pathname.startsWith("/admin") && pathname !== "/admin/login") || pathname.startsWith("/curation");

  if (isAdminProtected) {
    if (!session) {
      const url = new URL("/admin/login", request.url);
      url.searchParams.set("next", pathname);
      return NextResponse.redirect(url);
    }

    if (session.role !== "admin") {
      return NextResponse.redirect(new URL("/", request.url));
    }
  }

  if (isPublicPath && session) {
    const next = request.nextUrl.searchParams.get("next");
    const destination = session.role === "admin" ? next ?? "/admin" : "/";
    return NextResponse.redirect(new URL(destination, request.url));
  }

  if (!isPublicPath && !session) {
    const url = new URL("/login", request.url);
    url.searchParams.set("next", pathname);
    return NextResponse.redirect(url);
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico).*)"],
};
