# rules (zero-cost)

## The order

1. Already on his machine or in the project (`code (ponytail)` ladder): use it.
2. Free and local: open-source, offline, self-hosted on his own hardware (podman containers, his own tools).
3. Free and remote with a hard cap: a free tier that cannot bill past zero (a spend limit, a prepaid key - his
   OpenRouter key carries a $10 cap and a 7-day expiry).
4. Paid: only with the price stated per month and per use, what it buys over the free option, and how to leave.

## Costs that count

- Money: subscriptions, per-request APIs, hosting, domains, paid models. Never sign him up for anything.
- A second install: he installs Firefox, Emacs, Nyxt once, locally - no tool that downloads its own private browser or
  runtime when his own one can be driven ("jebać izolację, nie chcę instalować tego dwukrotnie").
- Telemetry and accounts: off by default (`--no-usage-statistics`, `DO_NOT_TRACK=1`, offline modes); his own
  products ship without telemetry (protonsoup: pure local heuristic, no data collection).
- Dependencies: every one is maintenance and churn later (mergekit's pydantic conflicts pushed him to own code).
  Count the transitive tree before adding one.
- Tokens and time: the context window is a budget too (`code (budget)`); a rerun is a cost.
- Hardware: used parts before new (32 GB of used DDR4 for about £50 was the best upgrade for his 1050 Ti box); rent by
  the hour for a one-off heavy job instead of buying.
- Legal: licenses (GPL obligations, MIT, dual licensing for his own C libraries), patents (H.264/HEVC codec work has
  live patents), terms of service of scraped sites.

## Saying it

A suggestion with a cost carries the number: "SERVICE, PRICE/month (checked DATE); free alternative: his own box
behind a tunnel". Prices are looked up, not remembered (`rules (knows-unknowns)`). Zero cost is not zero value: when the
paid option is clearly better for him, say so with the price.
