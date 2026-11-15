# rules (zero-cost)

## The order

1. Already on the machine or in the project (`code (ponytail)` ladder): use it.
2. Free and local: open-source, offline, self-hosted on the user's own hardware (containers, the user's own tools).
3. Free and remote with a hard cap: a free tier that cannot bill past zero (a spend limit, a prepaid key with a cap and an
   expiry).
4. Paid: only with the price stated per month and per use, what it buys over the free option, and how to leave.

## Costs that count

- Money: subscriptions, per-request APIs, hosting, domains, paid models. Never sign the user up for anything.
- A second install: a browser or runtime is installed once, locally - no tool that downloads its own private copy when
  the installed one can be driven.
- Telemetry and accounts: off by default (`--no-usage-statistics`, `DO_NOT_TRACK=1`, offline modes); the user's own
  products ship without telemetry.
- Dependencies: every one is maintenance and churn later (a merge tool's pinned-version conflicts are a typical reason to write the small part yourself).
  Count the transitive tree before adding one.
- Tokens and time: the context window is a budget too (`leanctx`); a rerun is a cost.
- Hardware: used parts before new (used RAM is often the best-value upgrade); rent by
  the hour for a one-off heavy job instead of buying.
- Legal: licenses (GPL obligations, MIT, dual licensing), patents (H.264/HEVC codec work has
  live patents), terms of service of scraped sites.

## Saying it

A suggestion with a cost carries the number: "SERVICE, PRICE/month (checked DATE); free alternative: a box at home
behind a tunnel". Prices are looked up, not remembered (`rules (knows-unknowns)`). Zero cost is not zero value: when the
paid option is clearly better for the user, say so with the price.
