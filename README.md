# Nexawyn

A modular, intelligent field service platform built by a solo operator for solo operators.

Replaces HouseCallPro, QuickBooks, and disconnected tooling with one connected system that handles CRM, quoting, job management, invoicing, photo documentation, accounting, and reporting. Day-one production user is Skilled Handyman Services CR.

> This project follows the standards in [Rekot24/dev-standards](https://github.com/Rekot24/dev-standards)

---

## Tech stack

| Layer | Tool |
|-------|------|
| Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth |
| Frontend | React + Vite |
| Hosting | Vercel |

## Required environment variables

Create a `.env.local` file in the project root. **Never commit this file.**
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key


Find these in your Supabase project under **Settings → API**.

## Running locally

```bash
npm install
npm run dev
```

Dev server runs at `http://localhost:5173` by default.

## Build phases

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Core schema (15 tables), Supabase project, domain | ✅ Complete |
| 2 | Internal operator dashboard | 🔄 In progress |
| 3 | Customer portal | Planned |
| 4 | Website integration | Planned |
| 5 | Intelligence layer (HD sync, Stripe, parts tracking) | Planned |
| 6 | SaaS product | Future |

See `ROADMAP.md` for full task breakdown and `NEXAWYN.md` for architecture decisions and working notes.