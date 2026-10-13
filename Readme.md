# SkyPort Admin Panel

Responsive React + Vite frontend starter for the `feature/admin` branch.

## Run
```bash
npm install
npm run dev
```

## Build
```bash
npm run build
```

## Included
- SkyPort responsive admin shell and sidebar
- Dashboard cards and revenue chart
- Flight search/filter and demo CRUD (in-memory only)
- Navigation for airports, aircraft, routes, bookings, passengers, tickets, payments, analytics, settings
- SkyPort CSS tokens
- Centralized API client boundary

## Important
This is a frontend starter, not a complete production backend. Flight changes reset on refresh in demo mode. Other management pages are integration placeholders. Sample metrics are illustrative. Connect existing Spring Boot APIs and authentication before production. Do not duplicate teammate-owned authentication, booking, search, or ticket-generation logic.
