# Handoff Receipts — durable close-out proof

The cumulative, append-only record of **each session's close-out handoff**, distilled into a
machine-checkable block. It is the durable answer to *"was close-out actually performed, and what
did the session hand its successor?"* — the part of close-out that otherwise lives only in the
transient `SESSION_NOTES.md` (overwritten every session) or the spoken report (which leaves no file
at all).

One `handoff` block per **session** (not per commit), newest on top. The canonical-only
`bin/check-handoff` (copy it into your `bin/` if you want the structural check) asserts each block is
present and structurally complete; the next session's Phase 0 reconcile greps this file for a missing
or still-`pending` receipt and backfills it — that reconcile, not the checker, is the dependable
backstop, so the discipline needs no tooling. Together — a write-step at close-out **and** a
reconcile-on-read backstop — this makes a skipped handoff *detectable* rather than silent.

> **A green `bin/check-handoff` is not a good handoff.** The check verifies presence and structure,
> never semantic quality. Faithfulness is still scored 1–10 by the next session (Phase 3A). A
> well-formed but hollow receipt passes the check and is caught only by that human judgement.

## How to write a receipt

**At Phase 1B (claim the session)** — write the stub block below with `status: pending`, filling what
you can, and commit it with your session-claim commit. This committed `pending` block is the crash
breadcrumb: if the session ends before close-out, the next session's Phase 0 reconcile sees it.
**Put the new block directly above the newest receipt** — the first `handoff` block after the
"Size, and when to archive" section — and never inside the example box below (the code box that
opens at the four-backtick line). The trimmer counts everything inside that box as front matter, so
a receipt put there can never be archived (S917 found 104 receipts there and moved them out).

**At Phase 3D (close-out)** — overwrite that block in place to `status: complete` and fill every
field. The block must satisfy all six Minimum Handoff Requirements (`SESSION_RUNNER.md` §3D).

## Format — a fenced `handoff` block

````
```handoff
session: S<N>
date: YYYY-MM-DD
status: <pending | complete>
self_score: <1-10>
predecessor_score: <1-10>
active_task: <current state>
what_was_done: <what you did, including a commit sha — or the literal `pending`>
next_steps: <specific and actionable; never "pick next from backlog">
key_files: <each entry carries a path:line token, e.g. SessionManager.java:245>
gotchas: <traps the next session should watch for>
runtime_smoke: <a run result, or "n/a — docs-only", or "impossible: <reason>">
changelog_ref: <PR #N or a short-sha into CHANGELOG.md>
commit: <short-sha — or `pending` until the next session reconciles it>
```
<free-text prose: the durable proxy for the Phase 3G spoken report, plus the +/- self-score breakdown>

Write clean `key: value` lines — no inline `#` comments (a `#` is a literal value character,
as in `changelog_ref: PR #52`). The keys are the six Phase 3D Minimum Handoff Requirements (the sixth
*is* `self_score`) plus `predecessor_score` (the Phase 3A evaluation) and a little metadata. `status`
is `pending` at the Phase 1B claim and `complete` at
close-out; a third value, `reconciled`, is written *only* by a later session's Phase 0 reconcile
when it reconstructs a receipt a crashed session never completed — you never write it yourself.
````

`self_score` and `predecessor_score` are distinct keys so one can never stand in for the other; omit
`predecessor_score` on Session 1 (there is no predecessor to score). `commit: pending` and
`what_was_done: pending` are legal at write time (the receipt ships in the very commit whose sha it
would name); the next session reconciles them to real shas.

## Size, and when to archive

handoffs-format: 2 — keep this marker, and bring it across with this section; `bin/status` reads it.

This file gains a receipt every session and nothing removes one, so it grows without bound. The
protocol never asks a session to read it whole: Phase 0 reconciles it against `git log` and checks
the newest receipt, and a session reads that receipt at the top — past the harness's default-read
refusal, with an offset and a limit. Archive it when the trimmer's trigger fires. The tool states the
trigger, and this file names no size of its own.

**Run this rather than estimating it:**

```sh
python3 methodology_trim.py --file HANDOFFS.md --check
```

`--check` evaluates the trigger and never writes. `--write` performs the trim, refuses unless it
can prove the split lossless, and **neither commits nor stages** — it leaves this file modified and
the new shard *untracked*, and leaves the commit to you (`git add HANDOFFS.md docs/archive/`).

An archive is a **shard**: a new frozen file, same format, same newest-on-top order.

- **Path: `docs/archive/HANDOFFS-through-<CUT-KEY>.md`.** Both halves are load-bearing — the
  directory keeps the shard from shadowing this file, and the `HANDOFFS-` prefix is what the
  trigger's own glob looks for. A shard named otherwise is silently invisible to it.
- **This file keeps one short pointer** naming each shard, the span it covers and how many receipts
  it holds — with the command that recomputes those counts, never a hand-maintained number.
- **The shard back-links here and states only facts about itself.** It must not restate a
  forward-looking rule: a shard is frozen, so a rule copied into one cannot be corrected when the
  live rule moves.
- **After a split, anything that enumerates receipts must span both** — `HANDOFFS.md
  $(git ls-files 'docs/archive/HANDOFFS-*.md')` — or it silently counts a shrunken
  population. Enumerate the shards with `git ls-files`, never as a bare glob: zsh aborts a
  command whose glob matches nothing, so before the first split the bare form counts nothing
  at all — the same reason the ledger's audit is written that way.

The reasoning this file shares with `CHANGELOG.md` — how a ledger is read, why the tool is the only
statement of its trigger, and what a split must conserve — is in the *Reading and archiving*
subsection of [§The Action Ledger](docs/methodology/FRAMEWORK_APPARATUS.md#the-action-ledger).
That subsection makes archiving optional for `CHANGELOG.md`; this file keeps its own rule, above —
archive it when the trimmer's trigger fires. Everything needed to *act* is here.

What is specific to *this* file, and gets receipts wrong if assumed:

- **A record is a `handoff` block *plus the prose beneath it*, not the fence alone.** The self-score
  and predecessor-score paragraphs sit outside the fence and belong to the receipt above them. A
  fence-only cut severs every receipt from its own scoring.
- **Archive oldest-first by position, never by sorting on `session:`.** Two independent `S<N>`
  sequences can share one ledger — a fork and its upstream each running their own counter — and
  their numbers collide. The record's identity is **session + date**.
- **A trim leaves the newest-receipt check alone and moves what the older-receipt checks see.**
  Phase 0 reconcile is frontier-based and a structural checker applies the full schema to the newest
  receipt only, so neither is disturbed. Its other passes are not so confined — an answer-slot rule
  reads every receipt below the newest, and a locator-form rule reads every receipt in the file. So
  after a trim, **run the checker against each shard as well**, and recompute any "all N older
  receipts" count from the files rather than carrying it forward.
- **Never trim to zero receipts.** An empty receipt ledger is indistinguishable from a broken one.
- **A shard freezes, with one exception this file needs:** a `commit:` answer slot may still be
  reconciled inside an archived receipt, because that field was always going to be filled by a later
  session. Nothing else in a shard is rewritten.

**Archived 181 record(s), 2026-07-08 → 2026-08-10** into [`methodology/archive/HANDOFFS-through-2026-08-10.md`](archive/HANDOFFS-through-2026-08-10.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-08-10.md.verify.sh`](archive/HANDOFFS-through-2026-08-10.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 39 record(s), 2026-08-10 → 2026-08-12** into [`methodology/archive/HANDOFFS-through-2026-08-12.md`](archive/HANDOFFS-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-08-12.md.verify.sh`](archive/HANDOFFS-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 17 record(s), 2026-08-12 → 2026-08-13** into [`methodology/archive/HANDOFFS-through-2026-08-13.md`](archive/HANDOFFS-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-08-13.md.verify.sh`](archive/HANDOFFS-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 21 record(s), 2026-08-13 → 2026-08-14** into [`methodology/archive/HANDOFFS-through-2026-08-14.md`](archive/HANDOFFS-through-2026-08-14.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-08-14.md.verify.sh`](archive/HANDOFFS-through-2026-08-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

This file currently holds **3** receipt(s). Computed by `methodology_trim.py` on every
`--check`/`--write` run, never hand-maintained.

**Archived 116 record(s), 2026-08-14 → 2026-09-17** into [`methodology/archive/HANDOFFS-through-2026-09-17.md`](archive/HANDOFFS-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-17.md.verify.sh`](archive/HANDOFFS-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 13 record(s), 2026-09-17 → 2026-09-18** into [`methodology/archive/HANDOFFS-through-2026-09-18.md`](archive/HANDOFFS-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-18.md.verify.sh`](archive/HANDOFFS-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 11 record(s), 2026-09-18 → 2026-09-19** into [`methodology/archive/HANDOFFS-through-2026-09-19.md`](archive/HANDOFFS-through-2026-09-19.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-19.md.verify.sh`](archive/HANDOFFS-through-2026-09-19.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 9 record(s), 2026-09-19 → 2026-09-19** into [`methodology/archive/HANDOFFS-through-2026-09-19-2.md`](archive/HANDOFFS-through-2026-09-19-2.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh`](archive/HANDOFFS-through-2026-09-19-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 31 record(s), 2026-09-19 → 2026-09-21** into [`methodology/archive/HANDOFFS-through-2026-09-21.md`](archive/HANDOFFS-through-2026-09-21.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-21.md.verify.sh`](archive/HANDOFFS-through-2026-09-21.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 7 record(s), 2026-09-22 → 2026-09-23** into [`methodology/archive/HANDOFFS-through-2026-09-23.md`](archive/HANDOFFS-through-2026-09-23.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-23.md.verify.sh`](archive/HANDOFFS-through-2026-09-23.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 11 record(s), 2026-09-23 → 2026-09-24** into [`methodology/archive/HANDOFFS-through-2026-09-24.md`](archive/HANDOFFS-through-2026-09-24.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-24.md.verify.sh`](archive/HANDOFFS-through-2026-09-24.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 4 record(s), 2026-09-24 → 2026-09-26** into [`methodology/archive/HANDOFFS-through-2026-09-26.md`](archive/HANDOFFS-through-2026-09-26.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-26.md.verify.sh`](archive/HANDOFFS-through-2026-09-26.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 3 record(s), 2026-09-26 → 2026-09-26** into [`methodology/archive/HANDOFFS-through-2026-09-26-2.md`](archive/HANDOFFS-through-2026-09-26-2.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-26-2.md.verify.sh`](archive/HANDOFFS-through-2026-09-26-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 4 record(s), 2026-09-26 → 2026-09-26** into [`methodology/archive/HANDOFFS-through-2026-09-26-3.md`](archive/HANDOFFS-through-2026-09-26-3.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-26-3.md.verify.sh`](archive/HANDOFFS-through-2026-09-26-3.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 24 record(s), 2026-09-27 → 2026-09-30** into [`methodology/archive/HANDOFFS-through-2026-09-30.md`](archive/HANDOFFS-through-2026-09-30.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-30.md.verify.sh`](archive/HANDOFFS-through-2026-09-30.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 92 record(s), 2026-09-30 → 2026-10-04** into [`methodology/archive/HANDOFFS-through-2026-10-04.md`](archive/HANDOFFS-through-2026-10-04.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-04.md.verify.sh`](archive/HANDOFFS-through-2026-10-04.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 43 record(s), 2026-10-05 → 2026-10-08** into [`methodology/archive/HANDOFFS-through-2026-10-08.md`](archive/HANDOFFS-through-2026-10-08.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-08.md.verify.sh`](archive/HANDOFFS-through-2026-10-08.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 40 record(s), 2026-10-08 → 2026-10-14** into [`methodology/archive/HANDOFFS-through-2026-10-14.md`](archive/HANDOFFS-through-2026-10-14.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-14.md.verify.sh`](archive/HANDOFFS-through-2026-10-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.8.0.

**Archived 41 record(s), 2026-10-14 → 2026-10-21** into [`methodology/archive/HANDOFFS-through-2026-10-21.md`](archive/HANDOFFS-through-2026-10-21.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-21.md.verify.sh`](archive/HANDOFFS-through-2026-10-21.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.8.0.

**Archived 34 record(s), 2026-10-22 → 2026-10-25** into [`methodology/archive/HANDOFFS-through-2026-10-25.md`](archive/HANDOFFS-through-2026-10-25.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-25.md.verify.sh`](archive/HANDOFFS-through-2026-10-25.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.8.1.

```handoff
session: S1066
date: 2026-10-26
status: pending
active_task: IN PROGRESS -- Phase 11 of the performance and memory campaign, consolidation (owner pick at the Phase 0 picker, item 1 of 4, "Campaign Phase 11 (Recommended)"; BACKLOG.md:8; plan docs/planning/performance-memory-campaign-plan.md:701): re-run every harness scenario, write docs/audits/PERF_CAMPAIGN_REPORT_<date>.md, the owner's NEWS.Rmd line, tighten every gate, decide helper-perfReference.R and D2, close the BACKLOG item.
what_was_done: pending
changelog_ref: pending
commit: pending
```
Session claimed; work beginning.

```handoff
session: S1065
date: 2026-10-26
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- Phase 10 of the performance and memory campaign, snapshot backfill and convergence: follow-through (owner pick at the Phase 0 picker, item 1 of 4, "Campaign Phase 10 (Recommended)"; strict TDD). Rows 5 and 6 re-measured; the Build Earlier Snapshots cost line counts a quarter of a second a date per 1,000 iterations in the owner's words; D6 ruled no; the backfill gate 11.9 to 1.4 s; an opt-in budget test. Phase 10 is complete; BACKLOG.md:8 is now Phase 11 (READY).
what_was_done: Claim 3601ebc4a. Measured (3 fresh runs each, load 6.7-8.7): backfill-jmac 9.42 to 1.08 s, 186.4 to 146.1 MB; gvaConvergence-example 4.73 to 0.84 s, 185.3 to 127.1 MB; the app's default series at 1,000 iterations jmac 53 dates 12.6 s, example 49 dates 9.4 s (the old line said about 4 and 3 min); one date about 0.2 s per 1,000 iterations plus under 0.1 s fixed. RED feb8c0055 (4 tests in test_modSnapshotTrends.R: the owner's sentence word for word, 2 min at 10,000 iterations, the 59/60 s boundary, the panel). GREEN e6fb78338 (describeBackfillCost(): 4L to 0.25, "about a quarter of a second per 1,000 iterations"). REFACTOR bb85e6001 (januaries() test helper, identical() to three copies). Budget test c7e94674b (test_perfBudget_snapshotBackfill.R, both calls under 2 s; owner ruling "Add one"). Gate 5312eb280 (perf_backfill_jmac_seconds 1.4 s). Docs 3333fbc35 (plan D6 ruling and Phase 10 Done bullet :680; BACKLOG.md:8 for Phase 11, the larger-colony figure, new :276 help-text item). Learning 1031.
next_steps: The owner's campaign: (1) Phase 11, consolidation (BACKLOG.md:8; plan docs/planning/performance-memory-campaign-plan.md:701): re-run every harness scenario (Rscript tools/perf/run.R <scenario>; 20 scenarios, about 6 min a pass, scenario names from Rscript tools/perf/run.R with no argument), write docs/audits/PERF_CAMPAIGN_REPORT_<date>.md with before (section 1, docs/audits/PERF_BASELINE_2026-10-24.md) and after for every row and the estimate-to-actual ratio, the owner-worded NEWS.Rmd line, tighten every gate (methodology/.quality-gates.json; the S1052 rule), decide on tests/testthat/helper-perfReference.R as the oracle, revisit D2 (plain R), and the block's "Also for Phase 11" list; then the block comes off. (2) The tie-order decision (BACKLOG.md:221). Outside the campaign: :231 (READY, S), :264 (the shinytest2 CI break, READY, S), :276 (the help-text sentence, READY, S); :240, :249, :258 (DECISION NEEDED).
key_files: R/modSnapshotTrends.R:457 (describeBackfillCost), :458 (the 0.25 constant), :471 (the sentence), :69-72 (the help text filed as BACKLOG.md:276); tests/testthat/test_modSnapshotTrends.R:287 (januaries), :802-863 (the S1065 cost-line tests); tests/testthat/test_perfBudget_snapshotBackfill.R; tools/perf/harness.R:329 (backfillScenario), :346 (gvaConvergenceScenario); methodology/.quality-gates.json (perf_backfill_jmac_seconds); docs/planning/performance-memory-campaign-plan.md:360 (D6), :680 (Phase 10 done), :701 (Phase 11); docs/audits/PERF_BASELINE_2026-10-24.md:87-88 (rows 5 and 6 before).
gotchas: A fresh-process time (tools/perf/run.R, what a gate reads) and a warm in-process time after one untimed run (what a budget test reads) differ by about 0.4 s of first-call cost on the backfill (1.08 against 0.61 s): quote which, and set a budget from a measurement taken the test's way. The plan's section 7 common DONE items (budget test, gate) bind every phase even when the phase's own bullet does not name them: read them at the phase's start. The gate's 3-date case is not the user's case: the app builds about 50 yearly dates. Shell: ( ... ) & inside a background launcher returns at once; zsh does not split an unquoted $spec. test_backfillColonySnapshots.R:374 builds yearly dates a fourth way (a local seq(), left alone: outside the approved REFACTOR).
runtime_smoke: The running app from a scratch install of e6fb78338: the example uploaded, Genetic Value at the default 1,000 iterations, Earlier Snapshots: the box read "49 snapshots, 1966-01-01 to 2014-01-01, at 1000 iterations each. Each date runs the gene drop again, about a quarter of a second per 1,000 iterations on a colony of 2,590 animals, so expect under a minute here (an estimate; larger colonies take longer)."; the element picture opened for the owner; Build took 11.4 s from click to idle.
quality_ratchet: 10/10 pass · 0 fail · 0 unmeasured · results 65a65d9abc28 · manifest f715ad02d4b2
changelog_ref: 3601ebc4a
commit: 3333fbc35
```

```handoff
session: S1064
date: 2026-10-26
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- Phase 9b of the performance and memory campaign, the app's memory (owner pick at the Phase 0 picker, item 1 of 4, "Campaign Phase 9b"; strict TDD). Summary Statistics' kinship CSV and relationship downloads and Marker Genetics' comparison and Realized Relatedness tables ask appServer()'s kinshipFor for every animal when the user asks; appServer() keeps no shared matrix (sharedKinshipMatrix removed). Phase 9 is complete; BACKLOG.md:8 is now Phase 10 (READY).
what_was_done: Claim b02b35804. RED 6530cae3a (test_kinshipForConsumers.R 11 new tests on qcPed, test_appServer_server.R 3, the CD2 guard in test_docsAuditHousekeepingWording.R pinning the owner's sentence). RED return d8b99c981 (one test passes no pedigree: testServer() draws every output on a flush). GREEN 26f18f238 (Summary Statistics: getKinshipMatrix a plain function, matrix then kinshipFor() then the cached fallback), b16836c03 (Marker Genetics: kinshipMatrix = NULL default, kinshipFor; Realized Relatedness checks pedigree and inputs before asking), c8d8e1695 (appServer). REFACTOR 3a3f6d2bc (kinshipFromSources() for four tabs, 216-case proof), c71dabe9d (Breeding Groups help), 5b74f1742 (kinshipArgs() test builder), 336f957b7 (test_modErrorHandling.R's "tryCatch" word check became a behavior test, owner ruling). Docs: design section 13, plan Phase 9, BACKLOG.md:8, Learning 1030.
next_steps: The owner's campaign: (1) Phase 10 (BACKLOG.md:8; plan docs/planning/performance-memory-campaign-plan.md:666): re-measure Build Earlier Snapshots and gvaConvergence() (rows 5 and 6 of the plan's section 1) after Phases 1, 2 and 5; the cost line R/modSnapshotTrends.R:457 and :470 gets the measured number in the owner's words (describeBackfillCost(), a testthat sentence); then D6 (parallel dates; recommended no unless still minutes). (2) Phase 11 (consolidation, the owner-worded NEWS line). (3) The tie-order decision (BACKLOG.md:221). Outside the campaign: :231 (READY, S); :240, :249, :258 (DECISION NEEDED; :249 Realized Relatedness and :258 Summary Statistics' relationship table are now the app's largest kept tables).
key_files: R/kinshipFromSources.R:20 (kinshipFromSources); R/appServer.R:347 (currentKinshipOverrides), :366 (kinshipFor), :382 and :488 (Summary Statistics and Marker Genetics get it); R/modSummaryStats.R:396 (getKinshipMatrix), :408 (fallbackKinshipMatrix), :436 (relationshipData, kept: F4); R/modMarkerGenetics.R:539 (signature), :593 (comparison's read), :735 (realizedRelatedness); R/modBreedingGroups.R:371, R/modGeneticDiversity.R:131 (the helper's other callers); tests/testthat/test_kinshipForConsumers.R:37 (recordingProvider), :56 (kinshipArgs), :67 (todaysMatrix), :406 (summaryRun), :528 (markerRun); tests/testthat/test_modErrorHandling.R:191; docs/planning/app-kinship-memory-design.md section 13.
gotchas: testServer() draws every output when an input changes (a browser draws only the visible tab), so a call count includes every output reading the counted source: remove the others' precondition (no pedigree) or count inside the reactive. test_modErrorHandling.R greps deparse() of modSummaryStatsServer and modBreedingGroupsServer for words ("tryCatch", "showNotification", "req("): grep for deparse(<fn>) before moving code out of a function. Each click now computes again, so warnings repeat per click: compare value, error and warnings one click a session. testthat::test_file(desc =) cannot match a paste()-built name. HANDOFFS.md is near its 196,608 B warn line: a methodology_trim.py --budget-bytes 65536 trim is owed when the context-budget check warns.
runtime_smoke: The running app through the committed tool, 3 runs before (b02b35804) and 3 after (c8d8e1695): every step's output on the page, the LD tab's kinship() now from realizedRelatedness > kinshipFor; the table within the runs' spread (LD tab 2,563.8 to 2,512.2 MB). The browser tier of design 7.2 from scratch installs of c8d8e1695 and 336f957b7: 11 files, 38 tests, 0 failed each.
quality_ratchet: 10/10 pass · 0 fail · 0 unmeasured · results 6aa294989f75 · manifest 7335ff8d4ddc
changelog_ref: b02b35804
commit: 336f957b7
```

```handoff
session: S1063
date: 2026-10-25
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- Phase 9a of the performance and memory campaign, the app's memory (owner pick at the Phase 0 picker, item 1 of 4, "Campaign Phase 9a"; strict TDD). Breeding Groups, Genetic Diversity and Mate Pair ask appServer()'s kinshipFor(ids) for their own animals through the internal kinshipForAnimals(); upload + QC 685.1 to 520.8 MB (design section 12). BACKLOG.md:8 now reads Phase 9b (READY): Summary Statistics' and Marker Genetics' every-animal reads, then sharedKinshipMatrix removed, then the table re-measured.
what_was_done: Claim 0716ead7a. RED b61752e08 (test_perfAppSession.R, test_kinshipForAnimals.R 18, test_kinshipForConsumers.R 12, test_appServer_server.R wiring changed by design). GREEN 70bd838b6 (tools/perf/appSession.R, runAppSession.R, appSession/app.R) then three "before" runs, 816717628 (R/kinshipForAnimals.R), 3981961ee (Breeding Groups), b5eb89972 (Genetic Diversity, Mate Pair; amended for two lints before any push), 5ba8941ec (appServer provider). RED return 44fdc736f and GREEN c6c9a5829: the owner replaced S993's Genetic Diversity help sentence, made false by the change. Three "after" runs. REFACTOR 4c68f73b2 (shared test helpers; the recorder now records a request for every animal, closing the one mutation gap), ed1e9caae (currentKinshipOverrides()), ab3122abc (mzTwinGroups() for kinship() and the helper; kinshipGeneral() word for word). Owner rulings: overrides "Include them, then cut" (design rule 3 replaced); the help sentence; push now (37997db3f..ab3122abc, 16 commits). Docs 67a7cfb04 (design section 12, plan :653, BACKLOG.md:8 for 9b).
next_steps: The owner's campaign: (1) Phase 9b (BACKLOG.md:8; design sections 6.1, 7.1 item 6, 8 and 12; strict TDD): Summary Statistics' kinship CSV and relationship downloads (R/modSummaryStats.R:384-436, :840-894) and Marker Genetics' Kinship Comparison (R/modMarkerGenetics.R:576-580, keep only the means) and Realized Relatedness (:716-729) through kinshipFor, each asking for every animal inside its handler; their item-6 tests (download bytes, the two tables); then sharedKinshipMatrix (R/appServer.R:353) removed, test_appServer_server.R:322 reads twins through the provider; then the table re-measured with Rscript tools/perf/runAppSession.R. (2) Phase 10. (3) The tie-order decision (BACKLOG.md:221). Outside the campaign: BACKLOG.md:231 (@inheritParams, READY, Effort S); :240, :249, :258 (DECISION NEEDED).
key_files: R/kinshipForAnimals.R:40-60 (kinshipForAnimals) and :77-100 (twinRelationsForSet); R/mzTwinGroups.R:17-28; R/appServer.R:353-387 (sharedKinshipMatrix, currentKinshipOverrides, kinshipFor at :382); R/modBreedingGroups.R:367 (getKinshipMatrix) and :680-690 (the kinship step below the seed boxes); R/modGeneticDiversity.R:121-141 (diversityStats); R/modMatePair.R:398-426 (analyze handler); tools/perf/appSession.R:39-78 (steps); tests/testthat/test_kinshipForConsumers.R:30-39 (recordingProvider); tests/testthat/helper-perfCampaign.R:69-81; docs/planning/app-kinship-memory-design.md section 12.
gotchas: The app session loads the working tree in each run (load_all), so take before-runs before touching R/ and edit nothing while one runs; it works from the project root (no outside-the-project recipe needed), about a minute a run, output to a file, wait for DONE. A test recorder must use c(asked, list(ids)): asked[[n + 1]] <<- NULL records nothing. A lint step in an && chain does not stop the commit; read the count. test_geneticDiversityKinshipHelp.R pins owner-approved help text; grep tests for a parameter's help before rewording it. Mate Pair's own step grew 392 MB less after 9a, not investigated (F2). HANDOFFS.md is 190,493 B, 6,115 B under its 196,608 B warn line: a trim is owed when it warns.
runtime_smoke: The running app through the committed tool, 3 runs before (70bd838b6) and 3 after (c6c9a5829): upload + QC 685.1 to 520.8 MB, no kinship() at upload, every step's output on the page; the browser tier of design 7.2 from scratch installs of c6c9a5829 and ab3122abc, 11 files, 38 tests, 0 failed.
quality_ratchet: 10/10 pass · 0 fail · 0 unmeasured · results 89d758aa16dd · manifest 7335ff8d4ddc
changelog_ref: 0716ead7a
commit: ab3122abc
```
The owner picked Phase 9a and answered the approach question (overrides), the three phase gates, the help-wording question and the push question with the recommended option each time. The only exported change: three Shiny module servers gain an optional last argument, kinshipFor, and two get a NULL default for kinshipMatrix; values, messages and results are unchanged.

