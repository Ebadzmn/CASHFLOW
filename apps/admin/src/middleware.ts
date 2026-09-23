import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Allow static files, images, fonts, and API routes
  if (
    pathname.startsWith('/_next') ||
    pathname.startsWith('/api') ||
    /\.(png|jpg|jpeg|gif|webp|svg|ico|css|js|woff|woff2|ttf|otf)$/i.test(pathname)
  ) {
    return NextResponse.next();
  }

  // Check if there is a token in the cookies
  const token = request.cookies.get('token')?.value;

  // Auth routes are public
  const isAuthRoute =
    pathname.startsWith('/login') ||
    pathname.startsWith('/reset') ||
    pathname.startsWith('/new-password') ||
    pathname.startsWith('/verify');

  if (!token && !isAuthRoute) {
    // If no token and trying to access a protected route, redirect to login
    return NextResponse.redirect(new URL('/login', request.url));
  }

  if (token && isAuthRoute) {
    // If there is a token and trying to access an auth route, redirect to dashboard
    return NextResponse.redirect(new URL('/overview', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico, sitemap.xml, robots.txt (metadata files)
     * - static files with extensions (.png, .jpg, .svg, etc.)
     */
    '/((?!api|_next/static|_next/image|favicon.ico|sitemap.xml|robots.txt|.*\\.(?:png|jpg|jpeg|gif|webp|svg|ico|css|js|woff|woff2)).*)',
  ],
};
