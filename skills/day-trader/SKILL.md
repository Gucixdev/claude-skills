---
name: day-trader
description: "Day trading and short-term trading done with discipline - risk per trade and position size first, a written plan with entry, stop and target, expectancy and R-multiples, a trade journal, paper trading and honest backtests before money, the market mechanics that bite (spread, slippage, fees, liquidity, halts). Not advice and no price prediction. Use for day trader, daytrading, intraday, scalping, swing, strategia gieldowa, plan transakcji, backtest, paper trading, dziennik transakcji."
metadata:
  priority: "3"
  tags: "#business #economy #thinking #measurement"
  requires: "skill:economist skill:rules ?cmd:python3 ?py:pandas"
---

# day-trader

Nothing here is financial advice, a signal or a forecast, and I never say what a price will do. The skill is a
process for someone who trades anyway: it keeps losses small, forces a plan before an order, and measures what
actually happens. Market basics and the base rates are in `economist`; claims are labelled with how sure
(`rules (calibration)`).

## Base rates first

Most people who trade short term lose money after costs, and a small share earns most of the profit. Say this once,
at the start, and plan for the likely case: the account is risk capital, the first months are tuition, and the
goal of the first stage is to lose slowly while learning, not to earn. Fees, spread and taxes are part of the
result; leverage multiplies both sides and the speed of ruin.

## The plan (written before the order)

For every trade, one line in the journal before it is placed:

- **Setup:** the named pattern or condition, and why it should have an edge (who is on the other side of the trade?).
- **Entry, stop, target:** prices. The stop is where the idea is wrong, not where the loss feels affordable.
- **Risk:** the amount lost if the stop is hit, a fixed small fraction of the account (commonly 0.5-1%; his choice,
  written in the plan). Position size = risk amount / (entry - stop). Size comes from the stop, never from
  conviction.
- **Reward to risk:** target distance / stop distance, in R. A trade below about 1.5R needs a high win rate to
  pay; say what win rate the plan needs (`expectancy = win% * avg win - loss% * avg loss`, all in R).
- **Daily loss limit** (for example 2-3R) after which the day is over, and a **max trades per day**.

## Market mechanics that cost money

Bid/ask spread and slippage (market orders pay it, limit orders may not fill), commissions and per-share or
per-contract fees, financing on leveraged or overnight positions, thin liquidity and wide spreads at the open and
close, gaps over news, trading halts, and for margin accounts the broker's own rules. In the US there is a
pattern-day-trader rule tied to a minimum account size: look up the current text at the regulator or broker, do not
trust a number from memory (`rules (rtfm)`). Taxes on short-term gains depend on the country; check the local rules
or an accountant.

## Prove it without money

1. **Paper trade** the written plan for a fixed number of trades (not days), same size and rules as live; log every
   trade, including the ones skipped against the plan.
2. **Backtest honestly:** rules fixed before looking; costs and slippage included; no future data in any signal
   (look-ahead); in-sample / out-of-sample split or walk-forward; many variants tried means the best one is
   probably luck, so count how many were tried. A backtest that works is a hypothesis (`economist`).
3. **Metrics, not feelings:** number of trades, win rate, average win and loss in R, expectancy, profit factor, max
   drawdown, longest losing streak. Fewer than about 100 trades says little; show the spread, not one number.
4. **Go live small,** at a size where a full daily loss limit does not matter, and compare live results to the
   paper ones. A gap means costs, slippage or discipline.

## Journal

One TSV row per trade (date, instrument, setup, side, entry, stop, target, size, exit, result in R, fees, followed
the plan yes/no, one line on why). A weekly review reads the file: which setup earns, which hour loses, how many
plan breaks and what they cost. Rules change only after a review of enough trades, never mid-day.

## Behaviour that ruins accounts

Moving a stop away, averaging down on a loser, revenge trades after a loss, size up after a win streak, trading
bored, trading news without a plan, ignoring the daily limit. The fix is mechanical: the daily limit, a pre-trade
checklist, orders with the stop attached, and a rule that the plan is written before the market opens.

## What I do when asked

Help write the plan template, the journal, the position-size and expectancy calculators, a backtest harness with
costs, and the weekly review script. I do not give entries, targets or tips, and I do not place orders.
