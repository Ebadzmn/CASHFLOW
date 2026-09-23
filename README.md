# CashFlow Monorepo

Turborepo-powered monorepo for the CashFlow platform.

## Structure

```
CASHFLOW/
├── apps/
│   ├── backend/        # Node.js/TypeScript Express API  (port 5000)
│   ├── admin/          # Next.js 16 Admin Dashboard      (port 3001)
│   └── mobile/         # Flutter Mobile App (iOS/Android)
├── packages/
│   └── config/         # Shared tsconfig, eslint configs
├── .env                # All environment variables (never commit!)
├── .env.example        # Safe template — commit this
├── turbo.json          # Turborepo pipeline config
└── package.json        # Root workspace manifest
```

## Prerequisites

| Tool | Version |
|------|---------|
| Node.js | ≥ 20 |
| npm | ≥ 10 |
| Flutter | ≥ 3.x |
| Dart SDK | ≥ 3.10.4 |

## Quick Start

```bash
# 1. Clone and enter
git clone <repo-url>
cd CASHFLOW

# 2. Copy env template and fill in your values
cp .env.example .env

# 3. Install JS deps (backend + admin)
npm install

# 4. Install Flutter deps
cd apps/mobile && flutter pub get && cd ../..

# 5. Start EVERYTHING at once 🚀
npm run dev
```

This starts:
- **Backend** → http://localhost:5000
- **Admin Dashboard** → http://localhost:3001
- **Flutter** → connected device/emulator

## Individual Commands

```bash
# Start only the backend
npm run backend

# Start only the admin dashboard
npm run admin

# Start only the Flutter app
npm run mobile

# Build all
npm run build

# Run all tests
npm run test

# Lint all
npm run lint

# Clean all build outputs
npm run clean
```

## Turborepo Filters

Use `--filter` to target specific apps:

```bash
npx turbo dev --filter=cashflow-backend
npx turbo dev --filter=cash-flowiq-app
npx turbo dev --filter=cashflow-mobile
npx turbo build --filter=cashflow-backend...   # backend + its deps
```

## Environment Variables

All env vars live in the root `.env`. Each section is labelled:

- `# ---app start---` → Flutter app vars
- `# ---admin start---` → Next.js admin vars
- `# ---backend start---` → Express API vars

See [`.env.example`](.env.example) for the full list of required variables.

## Apps

### Backend (`apps/backend`)
- **Tech**: Node.js, TypeScript, Express, MongoDB, Socket.io
- **Port**: 5000
- **Start**: `npm run backend`
- **Docs**: [README](apps/backend/README.md)

### Admin Dashboard (`apps/admin`)
- **Tech**: Next.js 16, React 19, Tailwind CSS, shadcn/ui
- **Port**: 3001
- **Start**: `npm run admin`

### Mobile App (`apps/mobile`)
- **Tech**: Flutter, Dart, Firebase, In-App Purchase
- **Platform**: iOS & Android
- **Start**: `npm run mobile` (requires connected device/emulator)
