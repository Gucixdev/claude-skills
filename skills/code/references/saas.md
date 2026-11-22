# code (saas)

Small SaaS and CRUD products the cheap, boring way. Also load `ui (webdev)` for the front end and `rules`.

The product is the smallest thing a customer pays for; everything else waits for a paying customer to ask.

## Data first

Write the tables before any screen: entities, keys, who creates, reads, changes and deletes each row, what must never
be lost (`code (languages)` (dod)). Every customer-owned row carries `account_id` from the first migration and every query is
scoped by it - retrofitting tenancy is the expensive mistake.

## Stack

- Ruby on Rails for CRUD with users: `rails new APP --database=sqlite3`; scaffolds for the boring screens; Rails 8
  ships an authentication generator (`bin/rails generate authentication`), Solid Queue for jobs on the same SQLite,
  and Kamal for deploys - check the current Rails guides before relying on a detail.
- One Go binary (`net/http`, `html/template`, SQLite) for a small service or an API without accounts.
- SQLite by default (one file, fast, backups by `sqlite3 DB ".backup FILE"`); Postgres only when many writers or a
  host demand it.

## Must have

- Auth from the framework (bcrypt `has_secure_password`, sessions, password reset); never home-made crypto. Magic
  links are fine; 2FA when customers ask.
- Payments through a hosted checkout or payment links (Stripe or similar) so card data never touches his server; B2B
  can start with invoices. Fees per transaction, no monthly cost before revenue (`rules (zero-cost)`).
- Admin: the Rails console or SQL plus a small TUI; no custom admin UI until it saves real time.
- Background work (emails, scans, reports) in a job queue, retries idempotent.
- Migrations: expand, migrate data, verify, contract (`code (ponytail)`, migration); never a destructive migration in the
  same deploy as the code change.

## Deploy and keep it alive

One box (his own behind a tunnel, or a small VPS), Kamal or a systemd unit behind Caddy (automatic TLS). Daily
backups copied off the box, and a restore actually tested. Logs on the box; uptime checked from outside.

## UK GDPR basics

A privacy notice saying what is collected and why; collect the minimum; a processing agreement with every processor
(payments, email); the ICO data protection fee applies to most businesses that process personal data (check the
current rules); access and erasure requests answered - erasure of customer data on request is a real delete, done
with his explicit approval (`rules (trash-not-rm)` covers his files, not a customer's legal right).

## His product ideas

A Cyber Essentials evidence-gathering tool for small firms and a DMARC / MTA-STS DNS scanner came out of his own
market research (2026-08); both fit his IT-services business as lead magnets or paid add-ons.
