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

**Archived 181 record(s), 2026-07-08 → 2026-08-10** into [`docs/archive/HANDOFFS-through-2026-08-10.md`](docs/archive/HANDOFFS-through-2026-08-10.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 39 record(s), 2026-08-10 → 2026-08-12** into [`docs/archive/HANDOFFS-through-2026-08-12.md`](docs/archive/HANDOFFS-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 17 record(s), 2026-08-12 → 2026-08-13** into [`docs/archive/HANDOFFS-through-2026-08-13.md`](docs/archive/HANDOFFS-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 21 record(s), 2026-08-13 → 2026-08-14** into [`docs/archive/HANDOFFS-through-2026-08-14.md`](docs/archive/HANDOFFS-through-2026-08-14.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

This file currently holds **4** receipt(s). Computed by `methodology_trim.py` on every
`--check`/`--write` run, never hand-maintained.

**Archived 116 record(s), 2026-08-14 → 2026-09-17** into [`docs/archive/HANDOFFS-through-2026-09-17.md`](docs/archive/HANDOFFS-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 13 record(s), 2026-09-17 → 2026-09-18** into [`docs/archive/HANDOFFS-through-2026-09-18.md`](docs/archive/HANDOFFS-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 11 record(s), 2026-09-18 → 2026-09-19** into [`docs/archive/HANDOFFS-through-2026-09-19.md`](docs/archive/HANDOFFS-through-2026-09-19.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-19.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-19.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 9 record(s), 2026-09-19 → 2026-09-19** into [`docs/archive/HANDOFFS-through-2026-09-19-2.md`](docs/archive/HANDOFFS-through-2026-09-19-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 31 record(s), 2026-09-19 → 2026-09-21** into [`docs/archive/HANDOFFS-through-2026-09-21.md`](docs/archive/HANDOFFS-through-2026-09-21.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-21.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-21.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 7 record(s), 2026-09-22 → 2026-09-23** into [`docs/archive/HANDOFFS-through-2026-09-23.md`](docs/archive/HANDOFFS-through-2026-09-23.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-23.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-23.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 11 record(s), 2026-09-23 → 2026-09-24** into [`docs/archive/HANDOFFS-through-2026-09-24.md`](docs/archive/HANDOFFS-through-2026-09-24.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-24.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-24.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 4 record(s), 2026-09-24 → 2026-09-26** into [`docs/archive/HANDOFFS-through-2026-09-26.md`](docs/archive/HANDOFFS-through-2026-09-26.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-26.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-26.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 3 record(s), 2026-09-26 → 2026-09-26** into [`docs/archive/HANDOFFS-through-2026-09-26-2.md`](docs/archive/HANDOFFS-through-2026-09-26-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-26-2.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-26-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 4 record(s), 2026-09-26 → 2026-09-26** into [`docs/archive/HANDOFFS-through-2026-09-26-3.md`](docs/archive/HANDOFFS-through-2026-09-26-3.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-26-3.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-26-3.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 24 record(s), 2026-09-27 → 2026-09-30** into [`docs/archive/HANDOFFS-through-2026-09-30.md`](docs/archive/HANDOFFS-through-2026-09-30.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-30.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-30.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 92 record(s), 2026-09-30 → 2026-10-04** into [`docs/archive/HANDOFFS-through-2026-10-04.md`](docs/archive/HANDOFFS-through-2026-10-04.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-10-04.md.verify.sh`](docs/archive/HANDOFFS-through-2026-10-04.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 43 record(s), 2026-10-05 → 2026-10-08** into [`docs/archive/HANDOFFS-through-2026-10-08.md`](docs/archive/HANDOFFS-through-2026-10-08.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-10-08.md.verify.sh`](docs/archive/HANDOFFS-through-2026-10-08.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 40 record(s), 2026-10-08 → 2026-10-14** into [`methodology/archive/HANDOFFS-through-2026-10-14.md`](archive/HANDOFFS-through-2026-10-14.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-14.md.verify.sh`](archive/HANDOFFS-through-2026-10-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.8.0.

```handoff
session: S993
date: 2026-10-15
status: pending
active_task: IN PROGRESS -- the Genetic Diversity tab no longer stops when a group holds a living animal outside the Genetic Value population (CA2 of docs-audit part 2 slice 6d, `docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md` Finding 1; owner pick at the Phase 0 picker, option 1 of 4; DECISION NEEDED, ruling (a), (b) or (c), recommended (a), asked at PRE-RED; Effort S; strict TDD, PRE-RED first)
what_was_done: pending
commit: pending
```

```handoff
session: S992
date: 2026-10-15
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- Download Plot on the Age-Sex Pyramid tab saves nothing until a pedigree is loaded (docs-audit part 2 slice 6d flag CD5, S991 Finding 2; owner pick at the Phase 0 picker, option 1 of 4, which took the report's recommended ruling; `R/modPyramid.R:141,146`: `req(pedigreeData())` first in the handler, `on.exit(dev.off(), add = TRUE)` after `png()`; strict TDD, the PRE-RED scope question and every gate asked and answered, REFACTOR taken)
what_was_done: Phase 0 clean (gap 0, no pending receipt, no merges, CI 10 of 10 green, dashboard 96/100 High+ 0, ratchet 1/1). Claim 54705dea5. Measured on a stand-in that a failing req() in a download handler answers HTTP 500 and a blank page, then asked the PRE-RED scope question (guard the click, recommended, or hide the button) and the three phase gates. RED 00945baf5: 4 new blocks in tests/testthat/test_modPyramid_coverage.R (nothing loaded saves no picture; a loaded pedigree still saves a PNG; empty-then-loaded in one module; a mocked drawing error leaves no device), 3 fail for the right reasons. GREEN 831383a43: R/modPyramid.R:141,146. REFACTOR f1913449c: the older blocks use pyramidDownloadInputs. NEWS 662381bcd: NEWS.Rmd:445. Checkpoint 9bb21f15b: BACKLOG.md, the audit report, Learning 958. Verified: suite 3,735 blocks / 12,572 expectations, 0 failed, 0 errors, 187 skipped; lint 0; check 0/0/0; mutation 2 of 2; real app 500 with nothing loaded (was 200, 45,680 B), 200 image/png loaded (332 animals). Learning 958; BACKLOG.md and the audit report updated.
next_steps: The owner rules on the rest of docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md (Recommendations 2-6): CA2 first (strict TDD, after a look at the Value column for an animal with no Genetic Value row), then one housekeeping session (the N1 clause, darblue, two comments, ten popovers, CA5 alerts; PRE-RED asks for the owner's sentences), CC1/CB1/CB5/CA3 builds, CC5 is the owner's call. Other open picks: 6e re-check (46 candidates CE-CL), Changed Columns tab (BACKLOG.md:144), nameless header (BACKLOG.md:159), contributor tutorial (BACKLOG.md:172), kinship2 drawing features (BACKLOG.md:398). 204 commits ahead of origin/master; do not offer a push-only session (owner ruled S905).
key_files: R/modPyramid.R:141,146 (the guard and on.exit); tests/testthat/test_modPyramid_coverage.R:29-32 (pyramidDownloadInputs), :96-117 (the pyramidDownload helper), :119-171 (the four new blocks); NEWS.Rmd:445; BACKLOG.md:119-125 (the updated docs-audit text); docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md (Findings 1-3, Rulings with the S992 update); R/getPyramidPlot.R:43-44 (NULL means qcPed); PROJECT_LEARNINGS.md Learning 958.
gotchas: 31 of the app's 45 download handlers have no req()/validate()/need() in their first 30 lines (a crude grep, not examined; most write a reactive that stops by itself); getPyramidPlot(NULL) draws qcPed and other ped = NULL callers were not searched (Learning 957); shiny::testServer() deletes a handler's output file when the block exits, so check the file inside the block; a failing req() read through output$x arrives as class shiny.silent.error and output$x re-runs the handler on every read; the on.exit mutant leaves devices open and R stops at exit with a QuartzBitmap error (the mutant's, not the suite's); Chrome's own display of the failed download was not watched; the CA2 fix still needs a look at the Value column; start every R call with cd to the project root; the studbook stays untracked (never git add -A); never git stash here.
runtime_smoke: the real app (shinytest2, headless Chrome, a scratch app.R that load_all()s this source): Age-Sex Pyramid tab, Download Plot with nothing loaded answered 500 text/html and saved no PNG; after uploading the example pedigree and Read and Check it answered 200 image/png, 54,732 B, PNG signature OK, picture headed "Total on 2026-Oct-14: 332" (Male 123, Female 209). Scratch files are in the session scratchpad, not the repo.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 022fc9e13caa · manifest aa983075d6a2
```

```handoff
session: S991
date: 2026-10-14
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the 21 slice 6d code candidates of docs-audit part 2 re-checked against today's code (docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md; owner pick at the Phase 0 picker, option 1 of 4; an audit, PRE-RED throughout, no code change; rulings proposed, none taken)
what_was_done: Phase 0 clean (gap 0, no pending receipt, no merges, CI 10 of 10 green, dashboard 96/100 High+ 0, ratchet citation matched). Claim 8ffd6f84f; the owed HANDOFFS.md trim ceea6dd3a (197,004 B to 28,966 B, methodology_trim.py v1.8.0, verify script OK); checkpoint 6dbcbbc7e (report and BACKLOG.md). Result: 5 closed (CA1 S970/S973, CA4 S928, CB2 S969, CC4 S882, CD6 S876), 16 still true (0 critical, 2 moderate, 14 minor), 1 new minor (N1, a help clause stale since S928). Moderate CA2: the Genetic Diversity tab stops for a living animal outside the focal set, run through the real modules on qcPed (GV matrix 2x2, pool 3, 1 outside). Moderate CD5: Download Plot with nothing loaded saves a pyramid of the packaged qcPed example, clicked in the real app (45,680 B, Total 46). Two slice claims did not hold (CC2 never FALSE not reproduced; CD3 lost overrides wrong in the app). Learning 957.
next_steps: The owner rules on the report's Recommendations (DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md): CD5 req() guard (Effort S), CA2 shared matrix after a look at the Value column, one housekeeping session (N1 clause, darblue, two comments, ten popovers, CA5 alerts), CC1/CB1/CB5/CA3 builds, CC5 is the owner's call, leave CB3/CB4/CC2/CC3/CD3. Each build is its own strict-TDD session with a PRE-RED gate. Other open picks: 6e re-check (46 candidates CE-CL), Changed Columns tab (BACKLOG.md:144), nameless header (BACKLOG.md:159), contributor tutorial (BACKLOG.md:172), kinship2 drawing features (BACKLOG.md:398). 197 commits ahead of origin/master; do not offer a push-only session (owner ruled S905).
key_files: docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md (Findings 1-3, the minor table); R/appServer.R:441-446 (CA2 wiring, comment :438-440 says full matrix); R/modBreedingGroups.R:548-558 (the living pool); R/modGeneticValue.R:302,552-555; R/modPyramid.R:136-153 (CD5 handler), :46 (darblue); R/getPyramidPlot.R:43-44 (NULL means qcPed); R/modGeneticDiversity.R:80-83 (N1); R/modPedigree.R:521-544 (CC1); R/modSummaryStats.R:393-395,386-391; BACKLOG.md:119-127 (the updated docs-audit text).
gotchas: The CA2 recommendation rests on a probe that did not look at what the Value column counts for an animal with no Genetic Value row; the CC1 fix (a) needs a probe of the layout builder with twin pairs outside the view; the CA3 groups list is read by other tabs; getPyramidPlot(NULL) draws qcPed and other ped = NULL callers were not searched; get_download() needs the tab open and NOT_CRAN=true; start every R call with cd to the project root (a stray cd tests/testthat turned renv off); methodology_trim.py v1.8.0 writes a methodology/ ledger's shard to methodology/archive/; the scratch probes and the downloaded PNG are in the session scratchpad, not the repo; the studbook stays untracked (never git add -A); never git stash here.
runtime_smoke: the real app (shinytest2, headless Chrome, the installed package, whose pyramid module equals the source): Download Plot with nothing loaded returned 200 image/png, 45,680 B, "Total on 2026-Oct-14: 46". CA2, CA3, CB5, CC1, CC2, CC3 run at module or function level; the rest read. No R/ change, so no suite, lint or check run.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 5d4a57326d13 · manifest aa983075d6a2
changelog_ref: S991 DONE entry
commit: the close-out commit that carries this receipt; claim 8ffd6f84f, trim ceea6dd3a, checkpoint 6dbcbbc7e
```

```handoff
session: S990
date: 2026-10-14
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the help for kinship() chrtype and hasBothParents() id says what the code does (BACKLOG.md item removed; docs-audit part 2 flags MB3 and PD12, S986 findings 1 and 8; owner pick at the Phase 0 picker, option 1 of 4; strict TDD, every gate asked and answered, REFACTOR taken)
what_was_done: Phase 0 clean (gap 0, no pending receipt, CI 10 of 10 green). Claim 314243a86. Probed first: both owner-approved sentences against today's code; kinship2's vector kinship() equals ours (0 of 25 cells differ) but its pedigree() route gives 0 on an unknown-sex founder's diagonal; two IDs in reverse order give logical(0). RED 060f12371 (8 of 15 blocks failed); GREEN 797a2a3f2 (the two roxygen blocks, man pages regenerated); REFACTOR 7a5d715df (the test uses helper-pageText.R's readers). Suite 3,731 blocks, 12,562 expectations, 0 failed, 0 errors, 187 skipped; lint 0; check 0/0/0; mutation 7 of 7 at GREEN and REFACTOR. Learning 956.
next_steps: Each needs an owner pick: the Changed Columns tab and summary() decision (BACKLOG.md:141, DECISION NEEDED), the nameless-header decision (BACKLOG.md:156, DECISION NEEDED: leave it, fix each site, or check once at the front of qcStudbook()), the contributor tutorial (BACKLOG.md:169), the two kinship2 drawing features (BACKLOG.md:395), a docs-audit part 2 cluster (6d 21, 6e 46; 6a-6b has nothing left to rule on). 193 commits ahead of origin/master after this close-out; do not offer a push-only session (owner ruled S905).
key_files: R/kinship.R:57-61 (the chrtype sentence); R/hasBothParents.R:6-9 (the id sentence); man/kinship.Rd and man/hasBothParents.Rd (regenerated); tests/testthat/test_kinshipHasBothParentsHelp.R:32 (helpCases), :72 (the wording blocks), :91 (xKinship), :143 (hasBothParentsPed); tests/testthat/helper-pageText.R:92-129 (the shared page readers); BACKLOG.md:112-115 (the docs-audit text updated).
gotchas: test_groupAddAssignHelp.R still has its own copies of collapseSpace and the page readers (not touched, out of scope); a mutant defined as the file at HEAD is a no-op once GREEN is committed (use HEAD~1); sub(fixed = TRUE) changes one site of two (hasBothParents() has ped$id == id twice); kinship2 has two routes for an unknown-sex founder, so the help's "as in kinship2" names the vector kinship() this function ports; a ( cmd ) & inside a background Bash call returns at once, wait on the output file's done marker; the studbook stays untracked (never git add -A); never git stash here.
runtime_smoke: n/a -- help text only, no runtime behavior changed; the two changed help entries rendered with tools::Rd2txt and read as approved, devtools::check(document = FALSE, vignettes = FALSE, args = "--no-manual") gave 0/0/0.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 2e4a798ff81b · manifest aa983075d6a2
changelog_ref: S990 DONE entry
commit: the close-out commit that carries this receipt; claim 314243a86, RED 060f12371, GREEN 797a2a3f2, REFACTOR 7a5d715df
```

```handoff
session: S989
date: 2026-10-14
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- checkRequiredCols() ignores an NA column name at any length, so a list of 5 or more names with an NA and a missing required column returns or names the missing columns instead of stopping "missing value where TRUE/FALSE needed" (BACKLOG.md item removed; docs-audit part 2 flag PB4, S986 finding 3; owner pick at the Phase 0 picker, option 1 of 4; strict TDD, every gate asked and answered, REFACTOR taken)
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, no merges, no untracked files, CI 10 of 10 green, dashboard 96/100 High+ 0, context budget WARN only for SESSION_RUNNER.md and the growth run, ratchet 1/1 and the newest citation matched the results file). Claim eec26f1d6. Probed first: 5 of 5 direct calls with an NA, 5+ names and a missing required name stopped "missing value where TRUE/FALSE needed" with reportErrors TRUE and FALSE; qcStudbook() with an NA header never reaches checkRequiredCols() because fixColumnNames() stops first (R/fixColumnNames.R:43, :46), and with that patched in memory a nameless origin header stops at R/addParents.R:47. PRE-RED scope question: the owner chose checkRequiredCols() only (the recommended option). RED 861f931b6 (4 new blocks; file 6 blocks, 39 expectations, 22 failed, 0 errors, 0 skipped; every NA case gave the same message; one block that ended at its first error was restructured so each case reports alone). GREEN b897b71a6 (ignore_na = TRUE in the first str_detect_fixed_all() call). REFACTOR d8b79d6fc (one found variable in place of two identical calls, R/checkRequiredCols.R:41-42). NEWS 9f49dc063 (NEWS.Rmd:437, NEWS.md re-knit). Verified: file 39 of 39; suite 3,721 blocks, 12,531 expectations, 0 failed, 0 errors, 187 skipped; lint_package 0; devtools::check 0/0/0 (document = FALSE, vignettes = FALSE) at REFACTOR; ratchet 1/1; mutation 4 of 4 caught at GREEN and 6 of 6 at REFACTOR; 15 NEWS-reading files pass. BACKLOG item removed, a nameless-header decision item added (BACKLOG.md:156), Learning 955.
next_steps: Each needs an owner pick: the two help sentences (BACKLOG.md:169, READY, Effort S, help text only with a wording gate), the Changed Columns tab and summary() decision (BACKLOG.md:141, DECISION NEEDED), the nameless-header decision (BACKLOG.md:156, DECISION NEEDED: leave it, fix each site, or check once at the front of qcStudbook()), the two kinship2 drawing features (BACKLOG.md:406), a docs-audit part 2 cluster (6d 21, 6e 46), the contributor tutorial (BACKLOG.md:180). 188 commits ahead of origin/master after this close-out; do not offer a push-only session (owner ruled S905).
key_files: R/checkRequiredCols.R:41-42 (found and the condition), :49-51 (the stop message); tests/testthat/test_checkRequiredCols.R:38 (answer()), :43-114 (the four new blocks); R/fixColumnNames.R:43 and :46 and R/addParents.R:47 (the sites the nameless-header item names); NEWS.Rmd:437; BACKLOG.md:156.
gotchas: the app never reaches checkRequiredCols() with an NA (a CSV blank header is read as X and qcStudbook() stops earlier on an NA name), so NEWS says the Input tab is not affected; an error inside a test_that() block ends it at the first error, so each RED case goes through answer(); a probe that patches the namespace after load_all() still calls the old attached copy from the global environment (use get("fn", ns)); the example CSV's header fields are quoted; devtools::check(document = FALSE, vignettes = FALSE, args = "--no-manual") gave 0/0/0; the studbook stays untracked (never git add -A); never git stash here.
runtime_smoke: the real Input module (shiny::testServer(modInputServer)) on inst/extdata/examples/ExamplePedigree.csv at REFACTOR: as shipped 0 errors, 1 warning, 3,694 records, ready TRUE; with the birth header blanked 1 error ("Missing required columns"), 0 records, not ready. The fix cannot change that path (a CSV blank header is read as X, never NA), so this shows only that the app is unharmed; the fix itself is shown by the test file, since the changed function is not reachable with an NA from the app.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results dfecbde31261 · manifest aa983075d6a2
changelog_ref: S989 DONE entry
commit: the close-out commit that carries this receipt; claim eec26f1d6, RED 861f931b6, GREEN b897b71a6, REFACTOR d8b79d6fc, NEWS 9f49dc063
```

```handoff
session: S988
date: 2026-10-14
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- checkChangedColsLst() counts every kind of rename, so a lowercase geographicorigin header is flagged (BACKLOG.md item removed; docs-audit part 2 flag PB7; owner pick at the Phase 0 picker, option 1 of 4; strict TDD, every gate asked and answered, REFACTOR taken)
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, no merges, no untracked files, CI 10 of 10 green, dashboard 96/100 High+ 0, context budget WARN only for SESSION_RUNNER.md and the growth run, ratchet 1/1). Claim 5dea6ce95. Probed first: an all-lowercase geographicorigin header gave qcStudbook(reportErrors = TRUE) NULL and runQcStudbook() hasChangedCols FALSE with all 13 change fields empty; geographicOrigin (mixed case) was already flagged through caseChange. Found by reading the callers that shouldShowChangedColsTab() repeats the 12-name list and summary() has 10 sentences; a list with only the geographicorigin field gives a blank summary() and an empty tab. One scope question, the owner took the recommended option: the check only. RED 62d37daac: 7 blocks in 3 test files plus a shared helper (pedLowercaseGeographicOrigin() on datePed()); 5 blocks failed with 8 expectations, each for the one cause; 2 guard blocks passed. GREEN 4566b1e99: R/checkChangedColsLst.R:37 is any(lengths(changedCols) > 0L). REFACTOR a1c47808f: one test constant. NEWS 0e3a6256a (NEWS.Rmd:430, NEWS.md re-knit; the defect dates from 2021 and is in v2.0.0). BACKLOG.md: the item removed, a new DECISION NEEDED item for the Changed Columns tab and summary(), the docs-audit count now two READY items; Learning 954.
next_steps: Each needs an owner pick: checkRequiredCols() tolerates an NA column name at any length (BACKLOG.md:156, READY, Effort S, strict TDD), the two help sentences with a wording gate (BACKLOG.md:164, READY, Effort S), the Changed Columns tab and summary() decision (BACKLOG.md:141, DECISION NEEDED: list every rename or leave it), the kinship2 drawing features (BACKLOG.md:401, which pedigree column means deceased), a docs-audit cluster (6d 21, 6e 46; re-check against today's code first), or the contributor tutorial (BACKLOG.md:175). Not an option: pushing (the owner ruled no push-only sessions); 182 commits are ahead of origin/master with this close-out, none seen by CI (estimate of CI risk: low, the full suite, lint and check ran, but check ran at GREEN only).
key_files: R/checkChangedColsLst.R:37 (the one expression); R/shouldShowChangedColsTab.R:36-42 (the 12-name list left alone); R/summary.nprcgenekeeprErr.R:111-165 (10 of 13 sentences); R/processQcStudbookResult.R:198-215 (warning rows only for caseChange and spaceRemoved); tests/testthat/test_checkChangedColsLst.R:33-68 (the four new blocks), test_runQcStudbook.R:237-252, test_modInput_qcStudbook.R:907-923, helper-renamedHeaderPedigree.R:13-19 (lowercaseGeographicOriginRename, pedLowercaseGeographicOrigin()); tests/testthat/test_appServer_dynamicTabs.R:189-209 (the agree-with-checkChangedColsLst block, a 12-field list); NEWS.Rmd:430-435; BACKLOG.md:141-154; PROJECT_LEARNINGS.md Learning 954
gotchas: with an all-lowercase geographicorigin header hasChangedCols is TRUE but the Changed Columns tab stays hidden and the Input tab's Warnings list has no row (NEWS.Rmd says so); only an all-lowercase geographicorigin, recordstatus or fromcenter header reaches those fields alone, since any capital also triggers caseChange; runQcStudbook() returns list(cleaned, qcResult, errorLst), so the flag is res$qcResult$hasChangedCols and res$hasChangedCols is NULL; export a variable before Rscript, a trailing VAR=x is an argument; devtools::check needs vignettes = FALSE to give 0/0/0; 15 test files read NEWS.Rmd and NEWS.md, so do not edit them during a suite run; SESSION_NOTES.md is 55,847 B (the Read tool's 25,000-token cap is about 56,000 B and the commit hook refuses growth past about 56,700 B, so the next claim must condense S988); the studbook stays untracked in inst/extdata/examples/ (never git add -A); never git stash here
runtime_smoke: the real Input module (shiny::testServer(modInputServer)) on inst/extdata/examples/ExamplePedigree.csv at GREEN: as shipped hasChangedCols FALSE, 0 errors, 3,694 records, ready; the same file with a lowercase geographicorigin header TRUE, 0 errors, 3,694 records, ready. Before: this session's probe on a six-animal pedigree (qcStudbook NULL, flag FALSE).
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results e315c8b09228 · manifest aa983075d6a2
changelog_ref: S988 DONE entry
commit: the close-out commit that carries this receipt; claim 5dea6ce95, RED 62d37daac, GREEN 4566b1e99, REFACTOR a1c47808f, NEWS 0e3a6256a
```

