# ── Stage 1: Install dependencies ──────────────────────────────────
FROM node:22-bookworm-slim AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# ── Stage 2: Build ──────────────────────────────────────────────────
FROM deps AS builder
WORKDIR /app
COPY . .
# Inline env vars needed only at build time (public vars baked into JS bundle)
ARG NEXT_PUBLIC_BASE_URL
ARG NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_SOCKET_URL
ARG NEXTAUTH_URL
ENV NEXT_PUBLIC_BASE_URL=$NEXT_PUBLIC_BASE_URL \
    NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL \
    NEXT_PUBLIC_SOCKET_URL=$NEXT_PUBLIC_SOCKET_URL \
    NEXTAUTH_URL=$NEXTAUTH_URL
RUN npm run build

# ── Stage 3: Production runtime (tiny — no node_modules, no source) ─
FROM node:22-bookworm-slim AS runner
ENV NODE_ENV=production
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs && \
    adduser  --system --uid 1001 nextjs

# Copy only what Next.js standalone needs
COPY --from=builder /app/public                           ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static    ./.next/static

USER nextjs
EXPOSE 3001
ENV PORT=3001 \
    HOSTNAME=0.0.0.0

CMD ["node", "server.js"]
