import { NextRequest, NextResponse } from "next/server";

function getBackendUrl() {
  const base = (
    process.env.INTERNAL_BACKEND_URL ||
    process.env.NEXT_PUBLIC_SOCKET_URL ||
    "http://10.10.26.198:5000"
  ).replace(/\/+$/, "");
  return base.replace(/\/api\/v1$/, "");
}

async function handleProxy(
  request: NextRequest,
  context: { params: Promise<{ path: string[] }> }
) {
  let targetUrl = "";
  try {
    const { path } = await context.params;
    const pathString = path.join("/");
    const search = request.nextUrl.search;
    const backendUrl = getBackendUrl();
    targetUrl = `${backendUrl}/api/v1/${pathString}${search}`;

    // Build headers to forward, omitting browser origin/host to bypass backend CORS
    const headers = new Headers();
    request.headers.forEach((value, key) => {
      const lower = key.toLowerCase();
      if (
        lower !== "host" &&
        lower !== "origin" &&
        lower !== "referer" &&
        lower !== "content-length"
      ) {
        headers.set(key, value);
      }
    });

    const method = request.method;
    const hasBody = method !== "GET" && method !== "HEAD";

    const fetchOptions: RequestInit = {
      method,
      headers,
      redirect: "manual",
    };

    if (hasBody) {
      const bodyBuffer = await request.arrayBuffer();
      if (bodyBuffer.byteLength > 0) {
        fetchOptions.body = bodyBuffer;
      }
    }

    const backendResponse = await fetch(targetUrl, fetchOptions);

    // Filter headers for the response back to client
    const responseHeaders = new Headers();
    backendResponse.headers.forEach((value, key) => {
      const lower = key.toLowerCase();
      if (
        lower !== "content-encoding" &&
        lower !== "transfer-encoding"
      ) {
        responseHeaders.set(key, value);
      }
    });

    return new NextResponse(backendResponse.body, {
      status: backendResponse.status,
      statusText: backendResponse.statusText,
      headers: responseHeaders,
    });
  } catch (error: unknown) {
    const errMessage = error instanceof Error ? error.message : "Unknown error";
    console.error("[Proxy Error]:", error, "targetUrl:", targetUrl);
    return NextResponse.json(
      {
        success: false,
        message: "Proxy failed to reach backend server",
        error: errMessage,
      },
      { status: 502 }
    );
  }
}

export const GET = handleProxy;
export const POST = handleProxy;
export const PUT = handleProxy;
export const PATCH = handleProxy;
export const DELETE = handleProxy;
export const HEAD = handleProxy;
