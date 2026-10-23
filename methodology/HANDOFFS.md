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

```handoff
session: S1041
date: 2026-10-22
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the issue #36 check (GitHub issue #36, "Add chimpanzee-specific age pyramid plot settings"; owner pick at the Phase 0 picker, item 1 of 4, "Issue #36 check"; read-only, no code): the verdict is already solved, and the owner picked "Close #36 as already solved" (over a guarding test and over keeping it open reworded). Issue #36 is closed (completed, with a comment giving the evidence); open issues went from 10 to 9. BACKLOG.md never held #36, so no block came off.
what_was_done: Claim ee41c077c. Phase 0 re-measured the S1040 handoff's #36 claims (R/agePyramidPlot.R absent, no R file mentions chimpanzees, ticks at R/getPyramidPlot.R:94-98), ledgers at HEAD (frontier 89267ecaa, gap 0, no merges), CI 10 of 10 green. The check found the deletion commit f78162106 (2026-07-06, S285: an unexported, zero-caller duplicate of getPyramidPlot(); its gap, laxlab and raxlab arrived as arguments); the TODO's numbers were the count axis, not age; the live plot sizes age bands from the oldest animal (R/getPyramidPlot.R:62-73) and count ticks and gap from the largest bar (:76, :94-98). Probes: oldest animal 55 gave 28 age bands; 60 animals gave counts 0-10 by 2, 600 gave 0-40 by 8, 1,500 (largest bar 134) gave ticks every 27; no label collisions, also at 800x600 and 72 dpi (the app's default view). The species table names "CHIMPANZEE", no "PT" code exists in R/. One owner question (three options, the comparison table, recommendation first); the issue was closed only on the pick. No code, test, doc or BACKLOG change; the suite was not re-run (S1040: 450 files, 4,279 tests, 0 failed 0 errors).
next_steps: No owner order was given; my order (the six delayed items are not offered): (1) The earlier-snapshots follow-ups (BACKLOG.md:33-50, READY, Effort S per thread): the a2interactive.Rmd pass for backfillColonySnapshots() and previewBackfillSupport() (dedicated pass), the trend chart's missing-value notice (strict TDD) or pinning the 200-character cut of a note; the 'skipped' word in the panel's notice is a DECISION NEEDED; the large-colony cost is BLOCKED on a studbook above 3,694 rows from the owner. (2) The BACKLOG.md compression pass (READY, Effort L, recurring, BACKLOG.md:133; 243 lines). (3) Owner-side: where to post the close_out_report.py write-up (draft only, BACKLOG.md:172; the held-back methodology sync is BLOCKED on it). Informational: 9 open issues (#138, #123, #116, #37, #28, #12, #11, #10, #5).
key_files: R/getPyramidPlot.R:62-73 (age bands from the oldest animal), :76 and :94-98 (count ticks and gap from the largest bar); R/getMaxAx.R (round the largest bar up to a multiple of 5); R/modPyramid.R:29-50 (Bin Size 1-10, plot height slider 400-1500, default 600) and :103-113 (renderPlot with no res); tests/testthat/test_getPyramidPlot.R (2 tests, both only check for a "recordedplot") and test_getMaxAx.R (1 test); data-raw/speciesGestation.R:28 ("CHIMPANZEE"); git f78162106 (the deletion of R/agePyramidPlot.R); methodology/SESSION_NOTES.md (S1041 block), methodology/CHANGELOG.md (S1041 entries), PROJECT_LEARNINGS.md (Learning 1007).
gotchas: git log --all --oneline -S'<a comment line from the issue>' finds the commit that deleted a file an issue cites, and git show <commit>^:<path> reads it. renderPlot() in R/modPyramid.R passes no res or width (72 dpi, container width, height from the slider), so png(800, 600, res = 72) stands in for the app's default view, a function-level render and not an app capture. Nothing pins that the pyramid axes follow the colony (2 tests, "recordedplot" only); the owner declined the guarding test, so do not re-offer it. One cosmetic oddity (a largest bar of 134 gives ticks every 27) was shown inside the third #36 option and not taken: it is not in BACKLOG.md, do not file it unprompted. 154 commits ahead of origin after the close-out; the last push CI run is Oct 20, so CI has not seen S1019-S1041 (no push-only pick, per the owner).
runtime_smoke: Not applicable to a runtime change (no code changed), and no app was launched. What ran: the live getPyramidPlot() at the app's default size (800x600 PNG at 72 dpi) on synthetic colonies, pictures opened for the owner; that is a function-level render, not an app capture.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 6cc4bc336aaa · manifest aa983075d6a2
changelog_ref: ee41c077c
commit: ee41c077c
```

```handoff
session: S1040
date: 2026-10-22
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- Slice 4 of the retrospective colony-snapshot backfill, the words (GitHub issue #170; design docs/planning/retrospective-snapshot-backfill-plan.md section 5, what it decided and found is the new 5.4; owner pick at the Phase 0 picker, item 1 of 4, "Finish #170: Slice 4"): nine places, one sentence each, approved as drafted -- the colony manager guide's Genetic-Health Trends section, NEWS.Rmd and NEWS.md, the backfillColonySnapshots() help Limits paragraph, and three panel wordings (the one-date cost line, the notice, a note under Dates not built). Strict TDD, the scope question, the notice question and every phase gate put to the owner. Issue #170 is closed with a comment citing the ledger; the BACKLOG.md #170 block is off (252 to 243 lines) and its five open threads are one follow-up item at BACKLOG.md:33.
what_was_done: Claim 02e1d1797; RED 98ba3f7b5 (29 new tests: 19 in the new test_earlierSnapshotsDocs.R, 10 in test_modSnapshotTrends.R; 20 failing for the missing text, 9 controls passing, 0 errors; a new helper-guideSections.R); GREEN fc980f93f (guide: four parts, item 4, the limits paragraph, the unknown-fate sentence), d363b54e1 (NEWS.Rmd, NEWS.md re-knit, a 7-line diff), ee6bd5afc (help Limits paragraph and man page), ed83d424e (R/modSnapshotTrends.R: the one-date cost line, the notice shows each note once with no count, output backfillSkippedNote); REFACTOR 38d2a34cf (test code only: the guide-section reader and the build mock each merged from two copies; the reader proved identical on 14 of 14 headings of the guide); docs 31c577781 (BACKLOG, design 5.4, Learning 1006). Owner calls: all nine sentences as drafted; then, after I found "this note came up on 2 dates" false (the "(2 in all)" counted notes, and one date can raise a note twice), "each note once, no count". Full suite 450 files 4,279 tests 14,792 expectations 0 failed 0 errors 197 skipped 8 warnings, identical before and after REFACTOR; lint_package 0; R CMD check 0/0/0 (default build); browser tier 24 of 24; mutation check 7 of 8 breaks killed (the 200-character cut of a note was never pinned); element pictures opened for the owner.
next_steps: No owner order was given; my order (the six delayed items are not offered): (1) Issue #36 check, read-only (READY, Effort S): the issue cites R/agePyramidPlot.R, which does not exist, no R file mentions chimpanzees, R/getPyramidPlot.R:94-98 sets the axis ticks from maxAx; the owner closes issues. (2) The earlier-snapshots follow-ups (BACKLOG.md:33-50, five threads): the a2interactive.Rmd pass for backfillColonySnapshots() and previewBackfillSupport() (READY, Effort S, dedicated pass) or the trend chart's missing-value notice (READY, Effort S, strict TDD); the 'skipped' word in the panel's notice is a DECISION NEEDED. (3) The BACKLOG.md compression pass (READY, Effort L, recurring, BACKLOG.md:133; 243 lines). (4) Owner-side: where to post the close_out_report.py write-up (draft only, BACKLOG.md:172).
key_files: vignettes/articles/colony-manager-guide.qmd:1264-1310 (the Genetic-Health Trends section; item 4 at :1294, the limits paragraph :1300, the unknown-fate sentence :1308); NEWS.Rmd:397-403 and NEWS.md (Longitudinal Monitoring); R/backfillColonySnapshots.R:68-72 (Limits) and man/backfillColonySnapshots.Rd; R/modSnapshotTrends.R:122 (the note's place), :365 (output$backfillSkippedNote), :418 (the notice), :449-456 (describeBackfillCost); tests/testthat/test_earlierSnapshotsDocs.R, helper-guideSections.R (the one guide-section reader), test_modSnapshotTrends.R:349 (mockBuildWithNotes) and :749 on (the Slice 4 wording tests); docs/planning/retrospective-snapshot-backfill-plan.md section 5.4; BACKLOG.md:33-50.
gotchas: Measure what a number counts before it goes into a sentence for the owner ("(2 in all)" counted notes, not dates: Learning 1006). A viewport picture of a tall page shows the top only: give the element an id with app$run_js() and use app$get_screenshot(file, selector = "#id"), after removing the .shiny-notification nodes; a selectize input lists only its selected choice in the DOM. Put the command itself in run_in_background; a trailing & inside a Bash call dies with the call (empty log, no process). testServer() reports a missing output as "referenced an output that hasn't been defined" (a clean RED). NEWS.md writes \#170 with a backslash (strip it in a test). The guide-reading tests skip in a built package. The failed-dates note says 'skipped' in the panel (BACKLOG.md:33). devtools::check() with build_args --no-build-vignettes adds two vignette warnings; the 0/0/0 figure is the default build. 143 commits ahead of origin at Phase 0, 152 after the close-out, not pushed.
runtime_smoke: The app ran in headless Chrome (shinytest2 AppDriver on a scratch install of ed83d424e; REFACTOR changed tests only): before a build the Earlier Snapshots tab read "Skipped dates are listed here after a build." under Dates not built; a start year leaving one date read "1 snapshot (2014-01-01), at 100 iterations each."; a three-date build at 100 iterations showed the notice "Earlier snapshots were built; the calculation gave this note: Founder genome equivalents undefined: ..." and the note under Dates not built was gone; the 24 browser expectations passed. Element pictures A (box), B and C (tab before and after a build) and the page with the notice were opened for the owner (scratchpad shots2 and shots).
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 62d0de7f808a · manifest aa983075d6a2
changelog_ref: 02e1d1797
commit: 38d2a34cf
```

```handoff
session: S1039
date: 2026-10-22
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- Slice 3 of the retrospective colony-snapshot backfill, the app button (GitHub issue #170; design docs/planning/retrospective-snapshot-backfill-plan.md section 5, what it decided and found is the new 5.3; owner pick at the Phase 0 picker, item 1 of 4, "Slice 3: app button"): the Genetic-Health Trends tab has a "Build Earlier Snapshots" box and an "Earlier Snapshots" tab; the button calls backfillColonySnapshots() with the full pedigree and the last analysis's settings. Strict TDD, the PRE-RED, RED-GREEN and GREEN-REFACTOR gates each put to the owner, plus two design calls (export the counts-only preview; fix twin pairs in the function). Issue #170 stays open (Slice 4 remains); BACKLOG.md:33-58 rewritten in place (file 252 lines).
what_was_done: Claim c367d2d9a; RED c40855ff7 and ac656a2e6 (52 new tests in 8 files, 49 failing for the missing feature, 3 guards passing by design; browser tier: 8 earlier expectations pass, the new section fails at the missing tab); GREEN f60a2a79b (previewBackfillSupport()), 2253ed0c9 (twinRelations cut to each date), fe4b4f696 (snapshotSource reportArgs; reconstructedLiving drawn dashed with a caption), 0909df2e5 (the panel and the appServer wiring), a RED-test correction 84f11ed2a (the warnings test was wider than its intent), a caption fix 8757ecc10 (found in the first picture, test first); REFACTOR 47e8d7a63 (four internal helpers replace the duplicated checks, 79 of 79 probe inputs identical; test warnings back to 8); docs 674e19ad7 (BACKLOG, design 5.3, Learning 1005). Owner calls: export previewBackfillSupport(); fix twins in the function. Full suite 449 files 4,250 tests 14,699 expectations 0 failed 0 errors 197 skipped 8 warnings; lint_package 0; R CMD check 0/0/0; browser tier 24 of 24; pictures of the box, the counts table and the trend chart opened for the owner.
next_steps: No owner order was given; my order (the six delayed items are not offered): (1) Slice 4 of #170, documentation and close-out (READY, Effort M, about one session, estimate): NEWS.Rmd entry (release-state, plain words), the colony-manager guide section (vignettes/articles/colony-manager-guide.qmd near :1264) with the B12 limits and the sentence on UNKNOWN-fate ancestors, one proposed sentence per place for the owner to edit and at most one question; the three wording points (a build of one date reads "1 snapshots", the warning notice says "(2 in all)" and shows one distinct text, "Dates not built" is an empty heading before any build); the a2interactive.Rmd pass is a later dedicated one; record the citation checklist as N/A; close #170 with a comment citing the CHANGELOG entry. (2) Issue #36 check, read-only (READY, Effort S): the issue cites R/agePyramidPlot.R, which does not exist, no R file mentions chimpanzees, R/getPyramidPlot.R:94-98 sets the axis ticks from maxAx; the owner closes issues. (3) The BACKLOG.md compression pass (READY, Effort L, recurring, BACKLOG.md:142). (4) Owner-side: where to post the close_out_report.py write-up (draft only, BACKLOG.md:181).
key_files: R/previewBackfillSupport.R:66; R/backfillColonySnapshots.R:141 (the function), :358 assertTwinIdsInPedigree, :386 restrictTwinRelations, :446-518 the four shared helpers; R/modSnapshotTrends.R:194 (server), :319-430 (the panel's reactives, cost line :337, Build :367), :440 describeBackfillCost; R/modGeneticValue.R:355 (reportArgs); R/plotSnapshotTrends.R:131,154 (dashed line, caption); R/appServer.R:531 (fullPedigree); tests/testthat/test_previewBackfillSupport.R, helper-backfillColony.R (shared fixtures), test_modSnapshotTrends.R (recordNotifications(), makeBackfillSource()), test-e2e-snapshot-trends-module.R; docs/planning/retrospective-snapshot-backfill-plan.md section 5.3; BACKLOG.md:33-58.
gotchas: shiny::testServer() does not raise an error that escapes an observer (it prints and carries on), so show "no error escapes" by recording notices: testthat::local_mocked_bindings(showNotification = ..., .package = "nprcgenekeepr", .env = parent.frame()). A test that says "no warning escapes" also catches the trend chart's own ggplot "Removed rows containing missing values" when a metric is NA (10-iteration builds); scope it to the call that warns. Declared MZ pairs must be cut to each date's pedigree (kinship stops on a missing id). fullPedigree defaults to reactive(NULL) (not required) so the 15 older module tests need no change. AppDriver$get_screenshot() refuses an existing file (EEXIST); macOS sed -i needs -i '' (use perl -pi). The browser tier's example colony (makeExamplePedigreeFile, 3,694 rows, default series 1966-2014) differs from the jmac example (53 dates, 1966-2018) and qcPed (57 dates, 1961-2017). No test pins the cost line's seconds, only "estimate". The cost-line coefficient (4 s per 1,000 iterations) is scaled by iterations only; a colony larger than 3,694 rows at 1,000 iterations is unmeasured. 131 commits ahead of origin at Phase 0, 143 after the close-out, not pushed.
runtime_smoke: The app ran in headless Chrome (shinytest2 AppDriver on a scratch install): example pedigree loaded, Genetic Value Analysis at 100 iterations, history fixture uploaded, the Earlier Snapshots tab rendered the 49-row counts table, a build from 2005 made 10 dates in 5.3 s (guIter 100 recorded), a second click added nothing, the trend chart drew the rebuilt line dashed and the recorded line solid with a two-line caption; the 24 browser expectations passed after GREEN and after REFACTOR. Pictures opened for the owner: backfill_1_box.png, backfill_2_support.png, backfill_3_trends.png in the scratchpad.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 2d1608b55ff2 · manifest aa983075d6a2
changelog_ref: c367d2d9a
commit: 47e8d7a63
```

```handoff
session: S1038
date: 2026-10-22
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- Slice 2 of the retrospective colony-snapshot backfill (GitHub issue #170; design docs/planning/retrospective-snapshot-backfill-plan.md section 5, corrections in the new 5.2; owner pick at the Phase 0 picker, item 1 of 4, "Backfill Slice 2"): backfillColonySnapshots() takes dates or a yearly series (from, to, by, minAnimals) and returns list(history, support, skipped); an animal with no birth date counts from its first dated offspring, an animal with no exit date counts only when isLivingAnimal() says so. Strict TDD, the PRE-RED, RED-GREEN and GREEN-REFACTOR gates each put to the owner, plus the two design calls. Issue #170 stays open (Slices 3 and 4 remain); BACKLOG.md:33-51 rewritten in place (19 lines, file still 244).
what_was_done: Claim 387771996; RED b8d9bfa80 (test_backfillColonySnapshots.R 12 to 29 tests, 17 new and 3 changed, 133 expectations, 53 failed: 11 pass, 9 fail, 9 error, all from the missing feature); GREEN 308cf7b0c (R/backfillColonySnapshots.R, the new internal R/backfillColonyFacts.R, the man page; 185 expectations pass); REFACTOR 1c9e5f28a (parseIsoDate() replaces two identical copies in createColonySnapshot() and the series code). Owner calls: undated parents from their first dated offspring and status UNKNOWN never counted (the rebuilt export date is 339, equal to the app), and the default series starting at the first 1 January with 2 living animals (1966 on the example, 53 points to 2018). Measured in scratch before RED: the effective sizes and fe are identical under the three birth-date rules on 102 dates; the design's 20 possibly alive in 1970 is 24. Full suite 448 files 4198 tests 14,426 expectations 0 failed 0 errors 197 skipped; lint 0; R CMD check 0/0/0 twice; ledger-reading tests 125 files 7,171 expectations 0 failed 0 errors 29 skipped.
next_steps: No owner order was given; my order (the six delayed items are not offered): (1) Slice 3 of #170, the app button (READY, Effort L, about one session, estimate): the PRE-RED asks the owner whether to export a preview function for the support table (design B1's parity promise) or accept an app-only preview; then the panel with fullPedigree = processedPedigree (not analysisPedigree), the captured settings, the dashed line and caption (B3), module-contract and snapshotSource tests, the browser tier, a picture opened for the owner before the long tests; the shipped-file default-series test (8 s) can be added there. (2) Issue #36 check, read-only (READY, Effort S): the issue cites R/agePyramidPlot.R, which does not exist, no R file mentions chimpanzees, R/getPyramidPlot.R:94-98 sets the axis ticks from maxAx; the owner closes issues. (3) The BACKLOG.md compression pass (READY, Effort L, recurring, BACKLOG.md:134). (4) Owner-side: where to post the close_out_report.py write-up (draft only, BACKLOG.md:173). Owed at Slice 4: NEWS.Rmd, the colony-manager guide section (with the sentence on UNKNOWN-fate ancestors), the a2interactive.Rmd pass, closing #170.
key_files: R/backfillColonySnapshots.R:128 (the function; buildBackfillDates() at :296), R/backfillColonyFacts.R:24,67,88 (describeBackfillColony, livingOnDate, supportOnDate), R/parseIsoDate.R:17, R/createColonySnapshot.R (known rules, parseIsoDate call), R/trimToAnalysisPopulation.R, R/validateWholeCount.R, tests/testthat/test_backfillColonySnapshots.R (helpers handBuiltColony(), undatedColony(), runBackfill(), expectStopNaming(), jmacQc()), docs/planning/retrospective-snapshot-backfill-plan.md sections 5.1-5.2, BACKLOG.md:33-51.
gotchas: backfillColonySnapshots() keeps guIter and guThresh after dates = NULL with a nolint on each line; a test pins the signature, so moving them is a RED edit. dates cannot be combined with from, to or by (it tests !missing(by)). nPossiblyAlive also counts UNKNOWN-status animals and dated ones with no exit date; pctSireKnown and pctDamKnown treat a generated stand-in as not recorded. UNKNOWN-fate ancestors with no exit date are still living breeders inside the estimators, as in the app, though not in nAnimals. A panel must catch reportGV's warnings (52 of 53 dates at guIter 10) and read the function's own (N of M dates could not be rebuilt); updateProgress gets n, value and detail once per date. The support preview has no script-callable twin (design 5.2 item 8). No test pins the shipped file's default series (53 dates, 1966-01-01 to 2018-01-01, 8.2 s at guIter 10). The 8 test warnings predate S1037. Wait on a background job with an until kill -0 loop run in the background (the harness blocks sleep N; command). 125 commits ahead of origin at Phase 0, 131 after the close-out, not pushed.
runtime_smoke: The script path ran on the shipped Japanese macaque example: the default series is 53 dates (1966-01-01 to 2018-01-01), all built, 8.2 s at guIter 10, with 52 reportGV warnings; a second call with the result as existingHistory skipped all 53 in 0.1 s and returned the same history; the support figures matched an independent count (1970: 65 living, 21 placed, 24 possibly alive). The function has no app path in Slice 2 (script only), so no browser tier and no picture; the Shiny app was not launched.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 0ef18e584c45 · manifest aa983075d6a2
changelog_ref: 387771996
commit: 1c9e5f28a
```

```handoff
session: S1037
date: 2026-10-22
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- Slice 1 of the retrospective colony-snapshot backfill (GitHub issue #170, filed this session with the owner's word; design docs/planning/retrospective-snapshot-backfill-plan.md section 5; owner pick at the Phase 0 picker, item 1 of 4, "Backfill Slice 1"): the exported backfillColonySnapshots(ped, dates, guIter, guThresh, ...) and the rule reconstructedLiving in createColonySnapshot(), dated animals only. Strict TDD, the PRE-RED, RED-GREEN and GREEN-REFACTOR gates each put to the owner. Issue #170 stays open (Slices 2 to 4 remain); BACKLOG.md:33-51 rewritten in place (19 lines, file still 244).
what_was_done: Claim d4791c562; issue #170 filed from the Appendix C text and recorded b71882631; RED e4b832abd (new test_backfillColonySnapshots.R, 12 tests, plus three tests in test_createColonySnapshot.R; 17 failed 5 errors, all missing function or unknown rule); GREEN 559e260d7 (the rule) and 9f863265d (the function, NAMESPACE, man page, _pkgdown.yml; two commits for the 5-file cap); REFACTOR a20fc3c32 (trimToAnalysisPopulation() for the Genetic Value tab and the function, validateWholeCount() for createColonySnapshot() and the function). Measured in scratch before RED: the hand-built colony gives neSexRatio 8/3 and 4.8, the example at 2018-07-11 equals the app on 25 of 25 fields under one seed, 1990/2000/2010 reproduce the S1036 figures. Found: B4 would count two UNKNOWN-status animals at the export date (341 against 339); the _pkgdown.yml line belongs in Slice 1. Full suite 448 files 14,286 expectations 0 failed 0 errors 197 skipped; lint 0; R CMD check 0/0/0 twice; browser tier 7/7, 7/7, 9/9.
next_steps: No owner order was given; my order (the six delayed items are not offered): (1) Slice 2 of #170 (READY, Effort L, about one session, estimate): from/to/by, minAnimals, the support table (B5), the B6 defaults, existingHistory skips (B7), per-date failures into skipped (B8), updateProgress; the B4 default and the B6 start go to AskUserQuestion; settle B4 against the 341-against-339 finding first. (2) Issue #36 check, read-only (READY, Effort S): the issue cites R/agePyramidPlot.R, which does not exist, no R file mentions chimpanzees, R/getPyramidPlot.R:94-98 sets the axis ticks from maxAx; the owner closes issues. (3) The BACKLOG.md compression pass (READY, Effort L, recurring, BACKLOG.md:134). (4) Owner-side: where to post the close_out_report.py write-up (draft only, BACKLOG.md:173). Owed at Slice 4: NEWS.Rmd (deferred from Slice 1 at the owner's word), the colony-manager guide section, the a2interactive.Rmd pass, closing #170.
key_files: R/backfillColonySnapshots.R:59 (the function; the per-date loop at :95-115), R/createColonySnapshot.R:89 (known rules; the shared population check below it), R/trimToAnalysisPopulation.R:1 and R/validateWholeCount.R:1 (the helpers), R/modGeneticValue.R:302-309 (the tab's fallback and the call), tests/testthat/test_backfillColonySnapshots.R:1 (helpers handBuiltColony(), jmacQc(), appSnapshot(), shortcutNeSexRatio()), tests/testthat/test_createColonySnapshot.R:226-270 (the rule tests), docs/planning/retrospective-snapshot-backfill-plan.md section 5.1 (the corrections), BACKLOG.md:33-51.
gotchas: B4 versus the export date: 2NTIGG and 4R3TIJ are real, status UNKNOWN, no exit, no birth date, one dated offspring each, so the offspring rule counts them (341 against the app's 339); Slice 2 must decide B4 and the exact-match test together. At guIter 10 fg, fgSE and neGD are NA on the jmac file, so use 20. Slice 1 stops the run at the first date that cannot be analyzed and names it; Slice 2 (B8) reports it in skipped instead, so the stop test in test_backfillColonySnapshots.R changes then. The tab's "no animal designated means everyone" fallback must stay out of trimToAnalysisPopulation() (a date nobody was alive on has to stop). Find a background job's worker with ps -axo pid,command | grep 'exec/R .*script' (pgrep -f matches the launching shell). Roxygen text uses American spelling (test_wordlist_coverage.R). The browser tier needs R CMD INSTALL --no-docs --library=scratch, R_LIBS=scratch:renv-lib, RENV_CONFIG_AUTOLOADER_ENABLED=false NOT_CRAN=true NPRC_RUN_E2E=true. The 8 test warnings (test_makePedigreeMatingLayout.R, test_modGeneticValue_snapshotSource.R) predate this session. 117 commits ahead of origin at Phase 0, 124 after the close-out, not pushed.
runtime_smoke: The headless-Chrome tier (shinytest2) ran on a scratch install of the refactored code: genetic-value module 7/7, genetic-value detailed 7/7, snapshot trends 9/9, 0 skipped, because the refactor edited the Genetic Value tab's analysis path. The new function has no app path in Slice 1 (script only), so there is no picture to show; the Shiny app was not launched by hand. The script path ran on the shipped jmac example (339 animals at 2018-07-11, equal to the app's snapshot on every field under one seed).
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 6b6b59567910 · manifest aa983075d6a2
changelog_ref: d4791c562
commit: a20fc3c32
```

```handoff
session: S1036
date: 2026-10-22
status: complete
self_score: 7
predecessor_score: 9
active_task: DONE -- the design document for the retrospective colony-snapshot backfill, docs/planning/retrospective-snapshot-backfill-plan.md (owner pick at the Phase 0 picker, item 3 of 4, "Snapshot backfill design"; a design session, text only, no R code or test change, so no RED/GREEN gates). Owner scope ruling: an exported backfillColonySnapshots() plus a "Build earlier snapshots" button that calls it. BACKLOG.md:33 rewritten in place (19 lines, file still 244). No GitHub issue filed.
what_was_done: Claim 3a3a69df4 (stub, pending receipt, CHANGELOG claim entry, S1035 condensed; test_handoffsReceiptPlacement.R passes). Phase 0 found a clean tree, both ledger frontiers at HEAD (the one commit past the CHANGELOG frontier was S1035's own close-out), no pending receipt, no merges, the ratchet citation matching (0ef16360cae1), CI 10 of 10 success, dashboard 96/100, nothing over a context-budget ceiling. Read the S756 plan (D1-D9, Slice 5), reportGV, createColonySnapshot and the Pedigree and Genetic Value tab code; measured on the jmac studbook (2,592 real animals) and the built-in 3,694-row example: dates are consistent, blanking later exit dates reproduces the app at the export date and setting only the population gives wrong effective sizes (0.0 against 3.9, 0.0 against 62.0, 30.9 against 136.6), the stored breeder-flag caveat is stale, parentage is thin early, about 4 s per date at 1,000 iterations. Withdrew one false defect (stand-in rows counted as animals) before it reached the owner. Deliverable 668d94f5e: the design (twelve decisions B1-B12, a new rule reconstructedLiving, four slices, three appendices) plus the BACKLOG.md rewrite and the DONE entry. Close-out: notes, Learning 1002, this receipt.
next_steps: No owner order was given; my order (the six delayed items are not offered): (1) The owner reads the design and says go; then file the GitHub issue (draft in Appendix C) and start Slice 1, the new rule plus the function for explicit dates (READY once approved, Effort L; the B4, B6 and B11 calls go to AskUserQuestion at the slice). (2) Issue #36 check, read-only (READY, Effort S): the issue cites R/agePyramidPlot.R, which does not exist, no R file mentions chimpanzees, R/getPyramidPlot.R:94-98 sets the axis ticks from maxAx; the owner closes issues. (3) The BACKLOG.md compression pass (READY, Effort L, recurring, BACKLOG.md:134; 244 lines). (4) Owner-side: where to post the close_out_report.py write-up (draft only, BACKLOG.md:173). Estimate, not measured: Slice 1 is about one session.
key_files: docs/planning/retrospective-snapshot-backfill-plan.md:1 (section 2 the measurements, section 3 B1-B12, section 5 the slices, Appendix A the prototype, Appendix B how to repeat, Appendix C the draft issue), BACKLOG.md:33 (the rewritten item), R/getLivingBreeders.R:18 (the only exit reader), R/modPedigree.R:372-374 (the app's population), R/modGeneticValue.R:293-342 (the analysis path), R/createColonySnapshot.R:83 (the known rules), R/appServer.R:527 (the Trends wiring), tests/testthat/test_docsAuditSixRulings.R:76-89 (pins the item's title phrase).
gotchas: Read the jmac file with na.strings = c("", "NA") and qcStudbook(minSireAge = 0, minDamAge = 0). Filter generated stand-ins with isGeneratedUnknownId(id, ped = ped) before any data-quality share. The Genetic Value tab's is.na(exit) fallback is not the app's path (the Pedigree tab sets the population first). The backfill needs processedPedigree, never analysisPedigree (the focal trim). The scratch scripts are not committed; Appendix B repeats the measurements. A background launcher's "completed" notice means the launcher exited, not the job, and a pgrep -f wait loop matches its own command line. BACKLOG.md lines did not move. quality_ratchet.py --run overwrites methodology/.quality-gates-results.json (the hash stayed 0ef16360cae1 because no packaged file changed). 113 commits ahead of origin at Phase 0; the three session commits plus the close-out make 116, not pushed.
runtime_smoke: Not applicable and not skipped silently: no app or package behavior changed (a design document, BACKLOG.md and ledger text only). The mechanical half ran: ratchet 1.5.1 --run, and the ledger-reading tests (see the changelog entry for the counts). The scratch measurements drove the real modGeneticValueServer under testServer() once, to check what the app counts; the Shiny app itself was not launched.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 0ef16360cae1 · manifest aa983075d6a2
changelog_ref: 3a3a69df4
commit: 668d94f5e
```

```handoff
session: S1035
date: 2026-10-22
status: complete
self_score: 7
predecessor_score: 9
active_task: DONE -- slim inst/doc/ (owner pick at the Phase 0 picker, item 2 of 4, "Slim inst/doc/"; strict TDD, REFACTOR skipped at the owner's word): a2interactive, gvaConvergence and simulatedKValues moved from html_document (df_print paged) to rmarkdown::html_vignette with df_print kable, a2interactive also fig_width 7 and fig_height 5; the BACKLOG.md block (22 lines, was BACKLOG.md:115-136) is removed.
what_was_done: Claim c64774804 (stub, pending receipt, CHANGELOG claim entry, S1034 condensed). Phase 0 found a clean tree, both ledger frontiers at HEAD, no pending receipt, no merges, the ratchet citation matching (f12acc759237), CI 10 of 10 success, dashboard 96/100, nothing over a context-budget ceiling. The owner picked the item, then the scope "Light template only" (static diagrams and leave-as-is declined) after five measured scratch builds of git archive HEAD. RED 069294279: tests/testthat/test_vignetteLightTemplate.R, 24 expectations, 12 failed, 0 errors. GREEN a737202c4: three output headers; 24 of 24; clean-export tarball 3,971,754 to 3,222,746 B (-749,008 B, -18.9%); the owner saw the old and new plots as image files and said they look fine. Full suite 447 files 14,231 expectations 0 failed 0 errors 197 skipped; lint 0 findings; R CMD check of the rebuilt tarball 0/0/0. REFACTOR skipped (the header reader exists once). Close-out: BACKLOG block removed, DONE entry, audit status line, Learning 1001.
next_steps: No owner order was given; my order (the six delayed items are not offered): (1) Issue #36 check, read-only (READY, Effort S): the issue cites R/agePyramidPlot.R, which does not exist, and no R file mentions chimpanzees; the owner closes issues. (2) The BACKLOG.md compression pass (READY, Effort L, recurring, BACKLOG.md:134; 244 lines). (3) DECISION NEEDED: the retrospective snapshot backfill (BACKLOG.md:33, Effort L, own design session and a new GitHub issue first). (4) Owner-side: where to post the close_out_report.py write-up (draft only, BACKLOG.md:173).
key_files: vignettes/a2interactive.Rmd:4 (the light header, fig_width and fig_height), vignettes/gvaConvergence.Rmd:6, vignettes/simulatedKValues.Rmd:6, tests/testthat/test_vignetteLightTemplate.R:1 (header comment holds the measurements), BACKLOG.md:134 (the compression item), BACKLOG.md:173 (the held-back files item), BACKLOG.md:33 (snapshot backfill), docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md:3 (status line, Finding 3 resolved), R/getPyramidPlot.R:94 (axis ticks).
gotchas: df_print paged is accepted under html_vignette but draws nothing; the light template's default figures are 3 x 3 in (288x288 px), set fig_width and fig_height on any vignette moved to it; html_vignette has no retina doubling, so 7 x 5 in is 672x480 px. pkgdown ignores a vignette's YAML output format, so the website is unchanged. When the owner is asked to compare something inside a long page, extract it as an image file, open that, and say where it sits (81% and 89% down this page; the owner could not find the plots). BACKLOG.md lines after the removed block moved up by 22. zsh: printf -- '---', never echo "===", and stat -f%z is GNU stat here (use wc -c). quality_ratchet.py --run overwrites methodology/.quality-gates-results.json: this session's hash 0ef16360cae1 replaces f12acc759237. 111 commits ahead of origin before the close-out commit, not pushed.
runtime_smoke: The change is to build output, so the build is the smoke test: a clean git archive HEAD tarball was built (3,222,746 B), R CMD check of it (vignettes rebuilt, tests off) gave 0 errors, 0 warnings, 0 notes, and the owner opened the rebuilt a2interactive and gvaConvergence pages and the old and new plots. The Shiny app was not launched: no R/ file changed.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 0ef16360cae1 · manifest aa983075d6a2
changelog_ref: c64774804
commit: a737202c4
```

```handoff
session: S1034
date: 2026-10-22
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the owner's ruling on the ten red archive-proof scripts: A, leave them and remove the item (the BACKLOG.md block, 18 lines, was BACKLOG.md:136-153) (owner pick at the Phase 0 picker, item 2 of 4, "Ten red proof scripts"; S1033's leftover; a decision session, text only, no R code or test change; nothing changed in methodology/, nothing posted upstream).
what_was_done: Claim a03bca0f7 (SESSION_NOTES.md stub, pending receipt, CHANGELOG claim entry, S1033 condensed; test_handoffsReceiptPlacement.R passes). Phase 0 found a clean tree, both ledger frontiers at HEAD, no pending receipt, no merges, the ratchet citation matching (results 1dd9ea741a26), CI all success (10 runs), dashboard 96/100, nothing over a context-budget ceiling. At the Phase 0 picker (4 options) the owner picked the item; a second question (A, B or C) got A, the recommended option. Deliverable 666790db5: the BACKLOG.md block removed (286 to 266 lines, 13 to 12 open items), the compression item's candidate list no longer names it, the DONE entry in CHANGELOG.md carries the S901 and S1033 record. Checked before removal: no test, R file or doc quotes the block; the two tests that read BACKLOG.md plus the ledger tests, 6 files, 49 blocks, 374 expectations, 0 failed, 0 errors. Upstream KJ5HST/methodology#93 and PR #94 both still open (read 2026-10-22).
next_steps: No owner order was given; my order (the six delayed items are not offered): (1) Issue #36 check, read-only (READY, Effort S): the issue cites R/agePyramidPlot.R, which does not exist, no R file mentions chimpanzees and R/getPyramidPlot.R:94-98 sets the axis from the data; try a long-lived example, write the finding down, the owner closes issues. (2) DECISION NEEDED: inst/doc/ slimming (BACKLOG.md:115, Effort M) and the retrospective snapshot backfill (BACKLOG.md:33, Effort L, its own design session first). (3) Owner-side: where to post the close_out_report.py write-up (draft only, BACKLOG.md:195). (4) The BACKLOG.md compression pass (BACKLOG.md:156, READY, Effort L, recurring; the file is 266 lines). Estimate, not measured: HANDOFFS.md was 41,509 B at this claim and warns at 196,608 B.
key_files: BACKLOG.md:137 (the CHANGELOG ledger-convention item, was :155), :156 (the compression item; its candidate list reflowed at :189-193), :195 (the held-back files item, was :215), :115 (inst/doc/), :33 (snapshot backfill); docs/audits/SHARD_VERIFY_REVERIFY_2026-10-22.md:1 (the table of all ten, kept); methodology/CHANGELOG.md (the S1034 DONE entry); R/getPyramidPlot.R:94-98 (the axis from the data); docs/conventions/CLOSEOUT_CHECKLISTS.md:25 (the removal checklist).
gotchas: Every BACKLOG.md line after the removed block moved up by 18, and by 20 past the reflowed list, so older cites (BACKLOG.md:155, :215, :224) are dated records. A sibling item names a removed item by an older nickname: grep its distinctive old words as well as its title (Learning 1000). A pick on a decision item is the item, not the ruling, so expect the A/B/C question. In zsh use printf -- '---
', never echo "===" (a leading = word is an expansion). quality_ratchet.py --run overwrites methodology/.quality-gates-results.json: this session's hash f12acc759237 replaces 1dd9ea741a26. Upstream methodology#93 and PR #94 are untouched.
runtime_smoke: Not applicable and not skipped silently: no app or package behavior changed (BACKLOG.md and ledger text only; methodology/ code untouched). The read-only and ledger tools were run on this project's own files: dashboard 2.23.0 (96/100), context_budget.py, ratchet 1.5.1 --run, and the ledger-reading tests (114 test files that name a ledger, BACKLOG.md, PROJECT_LEARNINGS.md or methodology/: 1,780 blocks, 7,012 expectations, 0 failed, 0 errors, 0 skipped).
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results f12acc759237 · manifest aa983075d6a2
changelog_ref: a03bca0f7
commit: 666790db5
```

```handoff
session: S1033
date: 2026-10-22
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- the ten red archive-proof scripts re-derived with the v1.8.1 trimmer's read-only --reverify and the BACKLOG.md item rewritten (BACKLOG.md:136; 28 to 19 lines; now DECISION NEEDED with a recommendation) (owner pick at the Phase 0 picker, item 1 of 4, "Re-check 10 red proofs"; housekeeping, text only, no R code or test change; nothing changed in methodology/, nothing posted upstream).
what_was_done: Claim d6214eb51. Ran all 60 frozen verify scripts: 50 exit 0, 10 exit 1, the same ten S901 listed (CHANGELOG 1, HANDOFFS 2, SESSION_NOTES 7). --reverify in place refuses 57 of 60 (REVERIFY_SHARD_MISMATCH, exit 3): their proofs name docs/archive/ and the shards moved to methodology/archive/ in 0e2663642; the 3 written since re-derive and exit 0. In a scratch clone with copies at docs/archive/: 49 exit 0 (the 47 earlier passes plus 2 of the ten), 1 exit 4 (HANDOFFS-through-2026-09-26-3, a named stub finalize), 7 exit 1 (SESSION_NOTES: the local spec declares no stub marker; a one-line marker in the clone makes all 7 exit 4, still red by upstream's design). Each of the 8 stub shapes prints "other N records byte-identical, in order, L2 holds"; none is a loss. Nothing runs the scripts. Deliverable 5d713689f: docs/audits/SHARD_VERIFY_REVERIFY_2026-10-22.md (the table, the commands, the limits) and the BACKLOG.md item rewritten as DECISION NEEDED (A leave and remove, recommended; B one-line marker; C tell upstream); the old "do not quote front-matter lines" warning dropped after reading both leak tests (proofs written since v1.5.1 test whole lines). Ratchet 1.5.1 1/1 pass. Ledger-reading tests: 137 test files that read a ledger or methodology/: 2,004 blocks, 7,894 expectations, 0 failed, 0 errors, 28 skipped.
next_steps: No owner order was given; my order (the six delayed items are not offered): (1) Issue #36 check, read-only (READY, Effort S): the issue cites R/agePyramidPlot.R, no R file mentions chimpanzees and R/getPyramidPlot.R:92-97 sets the axis from the data; try a long-lived example, write the finding down, the owner closes issues. (2) The owner's pick on the item this session rewrote (BACKLOG.md:136): A leave them and remove the block, B the one-line marker, C tell upstream; A means removing the block in its own commit. (3) DECISION NEEDED: inst/doc/ slimming (M, BACKLOG.md:115) and the retrospective snapshot backfill (L, BACKLOG.md:33). (4) Owner-side: where to post the close_out_report.py write-up (draft only, BACKLOG.md:215). Watch: HANDOFFS.md passes its 196,608 B warn line in about a week at this rate (the lever is shorter receipts, BACKLOG.md:155, not chosen).
key_files: docs/audits/SHARD_VERIFY_REVERIFY_2026-10-22.md:1 (the table of all ten, the commands, the limits); BACKLOG.md:136 (the rewritten item), :155 (receipt-size lever), :215 (held-back files item); methodology/methodology_trim.py:2034 (reverify), :2027 (stub_pattern_for), :538 (the local SESSION_NOTES.md spec, no stub_marker); methodology/archive/HANDOFFS-through-2026-10-21.md.verify.sh:304 (the whole-line leak test); docs/audits/SHARD_VERIFY_SCRIPT_FAILURES_2026-10-04.md:150 (the upstream report text); PROJECT_LEARNINGS.md Learning 999; methodology/CHANGELOG.md top.
gotchas: --reverify needs a file at the path the proof names: use a scratch git clone with copies in docs/archive/, never edit a frozen script. Exit 4 is a named stub finalize and is still red. macOS git grep -E has no \b (the pattern silently matches nothing). bin/status is not in this repo. Every BACKLOG.md line after 136 moved up by 9 (the S1029 cite BACKLOG.md:224 in SESSION_NOTES is a dated record). The ratchet results file sits in methodology/ and is gitignored. Edit no tracked ledger while the ledger tests run. Never git add -A (the studbook stays untracked).
runtime_smoke: Not applicable and not skipped silently: no app or package behavior changed (docs and BACKLOG.md text only; methodology/ untouched). The read-only tools were run on this project's own files: all 60 verify scripts, --reverify on all 60 (in place and in a scratch clone), dashboard 2.23.0 (96/100), context_budget.py, ratchet 1.5.1 --run, and the ledger-reading tests (137 test files that read a ledger or methodology/: 2,004 blocks, 7,894 expectations, 0 failed, 0 errors, 28 skipped).
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 1dd9ea741a26 · manifest aa983075d6a2
changelog_ref: d6214eb51
commit: 5d713689f
```

```handoff
session: S1032
date: 2026-10-22
status: complete
self_score: 7
predecessor_score: 7
active_task: DONE -- methodology sync: 7 of 10 files updated from the methodology checkout 515b3a7e (dashboard 2.23.0, trimmer 1.8.1 with this project's SESSION_NOTES.md patch re-applied, quality_ratchet 1.5.1, BOOTSTRAP, CLAUDE_TEMPLATE, FRAMEWORK_APPARATUS, HOW_TO_USE); SESSION_RUNNER.md, SAFEGUARDS.md and close_out_report.py held back at the owner's word (owner pick at the Phase 0 picker, item 1 of 4, "Update process files"; infrastructure sync, no R code or test change).
what_was_done: Claim 65cd20de8. bin/status, not the last handoff, set the scope: 9 files behind plus 1 missing. Ran the new close_out_report.py before keeping it (the option text promised to show it): it refuses on this project's HANDOFFS.md and on the blank seed, because it reads the front-matter example box as the newest receipt; one decision put to the owner, "Hold it back (Recommended)". Sync 3bc8a1e8c (bin/sync --force; the 7 files are byte-identical to the checkout; the runner and SAFEGUARDS restored from HEAD, the new script deleted). The trimmer minus the project's patch hashed to canonical 26bc97a2; the patch re-applied in its own commit e90a9b997 (the same 2 hunks as 5a41dbbdd); --check prints the same lines as before for all three ledgers; L1, L2, L3 OK on a borrowed 20-record copy, old and new trimmer alike (the live file's --cut 1 dry run is CUT_OUT_OF_RANGE with both). 137 ledger-reading test files: 2,004 blocks, 7,894 expectations, 0 failed, 0 errors, 28 skipped. Ratchet 1.5.1: 35 s, 1/1 pass. Close-out: S1031 evaluation 7/10, self 7/10, Learning 998, docs/audits/CLOSE_OUT_REPORT_EXAMPLE_BOX_2026-10-22.md (a draft, not posted anywhere), BACKLOG.md:224 (the held-back files), CLOSEOUT_CHECKLISTS.md:29 corrected, S1031 condensed in SESSION_NOTES.md at the claim. Not pushed.
next_steps: No owner order was given; my order (the six delayed items are not offered): (1) text-only update of the BACKLOG item "Shard verify scripts that FAIL on lossless trims" (BACKLOG.md:136; READY, Effort S): this project's trimmer (v1.8.1) already carries the fork's #93 fixes (5270be8f 1.5.1, 45d32d6b 1.6.0, 3616b5fa --reverify) and PR #94 on KJ5HST/methodology is open (last updated Oct 19); re-read #93, #94 and try --reverify on the 10 red scripts first. (2) Issue #36 check, read-only: the file it cites is gone, R/getPyramidPlot.R:97 sets the axis from the data, neither pyramid file mentions chimpanzees; the owner closes issues. (3) DECISION NEEDED: inst/doc/ slimming (M), the retrospective snapshot backfill (L). (4) Owner-side: where to post the close_out_report.py write-up (a draft only). Watch: HANDOFFS.md (about 33 KB) passes its 196,608 B warn line again in about a week at S1031's rate; the lever is shorter receipts (BACKLOG.md:164; the owner has not chosen).
key_files: BACKLOG.md:224 (held-back files item), :136 (shard verify item), :164 (receipt-size lever); docs/audits/CLOSE_OUT_REPORT_EXAMPLE_BOX_2026-10-22.md; docs/conventions/CLOSEOUT_CHECKLISTS.md:29 (the trimmer item, corrected); methodology/methodology_trim.py (the patch is the diff of e90a9b997); methodology/quality_ratchet.py 1.5.1; PROJECT_LEARNINGS.md Learning 998; methodology/CHANGELOG.md top.
gotchas: bin/status is the sync's scope, not the last handoff. A file the owner holds back is restored with git checkout -- <file> (a new one deleted) before the sync commit. The checklist's --cut 1 dry run needs two or more trimmable records: use a borrowed copy in a scratch worktree after a throwaway CHANGELOG.md commit. In zsh path is PATH and $c:name is a modifier. Run background work directly, not in a nested ( ... ) &, or the completion notice fires at once. bin/sync reads the methodology checkout's HEAD, which was 10 commits ahead of origin/main (none touched a distributed file). The ratchet results file is gitignored and --run overwrites it. Edit no tracked ledger while the ledger tests run. Never git add -A (the studbook stays untracked).
runtime_smoke: Not applicable and not skipped silently: no app or package behavior changed (methodology tools and docs only). The tools were run on this project's own files: dashboard 2.23.0 (96/100), the trimmer's three --check runs and the borrowed-ledger dry run, ratchet 1.5.1 --run, bin/status, and the 137 ledger-reading test files.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 084a5d10d455 · manifest aa983075d6a2
changelog_ref: 65cd20de8
```

```handoff
session: S1031
date: 2026-10-22
status: complete
self_score: 7
predecessor_score: 8
active_task: DONE -- methodology/HANDOFFS.md trimmed from 207,726 B to 28,615 B, 41 of 44 receipts archived to methodology/archive/HANDOFFS-through-2026-10-21.md (owner pick at the second Phase 0 picker, item 1 of 4, "Trim HANDOFFS.md"; the owner took --force at the SRF_RED question; housekeeping, no code or test change).
what_was_done: Claim 42f534d85. At the first picker the owner delayed six BACKLOG items (tutorial, 3.0.0 move, both LabKey items, kinship2-like package, outreach, papers); saved as memory picker-delayed-items-2026-10-22, no BACKLOG block edited. The plain trim run was refused with SRF_RED (1.0638; both readings name the S991 archive ceea6dd3a, 197,004 B to 28,966 B; 178,760 B regrown in 8 days); a --force dry run showed the exact result; the owner chose "Yes, trim with --force". Trim 52085b223 (methodology_trim.py v1.8.0 --budget-bytes 65536 --force --write; HANDOFFS.md, CHANGELOG.md entry, the shard and its verify script), committed apart from the close-out; the verify script passes from that commit (L1, L2, L3; 44 before = 3 retained + 41 archived). 137 test files that read a ledger or methodology/: 2,004 blocks, 7,894 expectations, 0 failed, 0 errors. Close-out: S1030 evaluation 8/10, self 7/10, Learning 997, SESSION_NOTES.md S1030 condensed. Not pushed.
next_steps: No owner order was given; my order (the six delayed items are not offered): (1) the methodology sync (READY, Effort S-M): SESSION_RUNNER.md 2 commits behind, SAFEGUARDS.md 1, methodology_dashboard.py v2.22.0 against 2.23.0, trimmer v1.8.0 against the fork's v1.8.1; re-apply the SESSION_NOTES.md patch per the CLOSEOUT_CHECKLISTS.md trimmer item. (2) Text-only update of the BACKLOG item "Shard verify scripts that FAIL on lossless trims" (BACKLOG.md:136): re-read KJ5HST/methodology #93 and PR #94 first. (3) Issue #36 check, read-only: R/agePyramidPlot.R is gone, R/getPyramidPlot.R:97 sets the axis from the data, neither pyramid file mentions chimpanzees; the owner closes issues. (4) DECISION NEEDED: retrospective snapshot backfill (L), inst/doc slimming (M). Watch: at about 22 KB a day (an estimate from 8 days) HANDOFFS.md passes its 196,608 B warn line again in about a week; the lever is shorter receipts (BACKLOG.md:164; the owner has not chosen).
key_files: methodology/HANDOFFS.md (28,615 B, 3 receipts live); methodology/archive/HANDOFFS-through-2026-10-21.md and its .verify.sh; methodology/CHANGELOG.md top (the trimmer's entry, then the S1031 entries); PROJECT_LEARNINGS.md Learning 997; BACKLOG.md:136 (shard verify item) and :164 (receipt-size lever); docs/conventions/CLOSEOUT_CHECKLISTS.md:29 (the trimmer item, for the sync).
gotchas: The plain run of methodology_trim.py on HANDOFFS.md is refused (SRF_RED) until the regrowth is smaller than the last trim's drop; --force without --write is a free preview with the exact numbers. Trim only with the claim committed and commit the trim alone (FRONTIER_PENDING_STUB: record 0 is the live stub). The trimmer puts a ## 2026-10 heading and its own entry at the top of CHANGELOG.md, so a DONE entry goes above it. The quality gate builds from git archive HEAD and its results file is gitignored. Edit no tracked ledger while the ledger tests run. Never git add -A (the studbook stays untracked).
runtime_smoke: Not applicable and not skipped silently: no runtime behavior changed (ledger and archive files only; no R, app or docs-site file). The mechanical checks are the shard verify script from the trim commit and the 137 ledger-reading test files.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 972b767212d7 · manifest aa983075d6a2
changelog_ref: 42f534d85
```

```handoff
session: S1030
date: 2026-10-22
status: complete
self_score: 7
predecessor_score: 8
active_task: DONE -- a script draws the Diagram tab's picture with the new exported drawPedigreeDiagram(layout, edgeStyle, onClick), which the app itself calls (owner pick at the Phase 0 picker, item 2 of 4, "Scripts miss slash and sections"; owner ruling at the scope question, the recommended option: "One function draws it all"; strict TDD, every phase behind its own gate).
what_was_done: Claim e1c01d48f. Measured first: the a2interactive chain drew 5 legend rows, no afterDrawing handler and the default canvas against the app's 11 rows, handler and 500 px; five sentences in two pages promised the match; the Diagram article contradicted itself (the sections paragraph against the Script-callable equivalent section). One scope question and the three phase gates, each answered with the recommended option. RED 591948908 (test_drawPedigreeDiagram.R 16 blocks with three parity blocks and a source guard, test_drawPedigreeDiagramDocs.R 5, one browser block; all failed for the right reasons). GREEN 73f1db9fd (one RED expectation corrected: visExport() stores the name with ".png") and 86ca8236e (R/drawPedigreeDiagram.R new, R/modPedigree.R one call, man page, NAMESPACE, _pkgdown.yml; the RED run found layout$conditions partially matching conditionsNotDrawn, now read with [[ ]]). Spelling 15fddfc7c; docs b27a7fb8a (both walkthrough chunks one call, the five claims and the article's sections paragraph name the function, NEWS.Rmd:61). Mutation pin ceecff912 (17 of 17 killed). REFACTOR 91e115310 (halves_js(), is_color(), expect_halves()). E2E qualification db78025b3. Pictures of the old chain and of the function's page opened for the owner. Close-out: the finished BACKLOG block removed, Learning 996. Evidence: unit 16 and 5 blocks, browser tier 22 blocks 108 expectations 0 failed; full suite 446 files 4,162 blocks 14,207 expectations 0 failed 0 errors 197 skipped; lint_package 0; devtools::check() 0/0/0. Not pushed.
next_steps: No owner order was given; my order: (1) BACKLOG.md:16 contributor tutorial (DECISION NEEDED, Effort M; three owner decisions first: CONTRIBUTING.md plus article or article alone, how much strict TDD outsiders are asked to follow, audience). (2) Housekeeping, own sessions: trim methodology/HANDOFFS.md, past its 196,608 B warn line (methodology_trim.py with --file methodology/HANDOFFS.md and --budget-bytes 65536, check first, then write, as its own commit apart from a close-out); the methodology sync (SESSION_RUNNER.md 2 commits behind, SAFEGUARDS.md 1, methodology_dashboard.py v2.22.0 against 2.23.0; re-apply the SESSION_NOTES.md patch per CLAUDE.md). (3) The BACKLOG item "Shard verify scripts that FAIL on lossless trims" is out of date (KJ5HST/methodology issue #93 and its fix PR #94 are open and unmerged); offer the owner a text update.
key_files: R/drawPedigreeDiagram.R:46 (function), :51 and :58 (input checks), :63 (conditions read with [[ ]]), :103 (widget and height), :113 (click), :274 (hover reach); R/modPedigree.R:715 (the one call); tests/testthat/test_drawPedigreeDiagram.R:273 (.appAndScriptedWidgets, the parity helper); tests/testthat/test_drawPedigreeDiagramDocs.R:26 (proseParagraphs); tests/testthat/test-e2e-pedigree-module.R:1168 (halves_js, is_color, expect_halves), :1316 (the scripted-page block); vignettes/a2interactive.Rmd:485 and :549 (the two calls); vignettes/articles/pedigree-diagram.qmd:232 and :319; NEWS.Rmd:61.
gotchas: An E2E-tier file must call exports as nprcgenekeepr::f() (test_e2e_package_qualification.R): the nightly shinytest2 job runs test_dir() without attaching the package, while load_all() and an attached install both pass a bare call. Read a list element whose name starts a longer sibling's with [[ ]] ($ partial matching). visExport() keeps the extension in x$export$name. A page saved with htmlwidgets::saveWidget() holds a 960 px widget, so its legend is cut in a window under 1,000 px (as with the old chain); take pictures at 1,400 px. Inside testServer() the module's reactives are reachable, and a second output$x <- renderVisNetwork(...) serializes like the app's output, so widget text can be compared byte for byte. Never pipe a long Rscript into head: it stalled at 0% CPU; send output to a file and confirm the work process with ps.
runtime_smoke: The running app was driven (shinytest2 AppDriver, scratch install of the final code): all 21 Diagram browser blocks (slash, legend gaps, sections, four conditions, export, search) pass with the Diagram now drawn by drawPedigreeDiagram(); a page saved from the function and opened in headless Chrome paints the slash and the sections (pixels), also run with the package not attached; 22 blocks 108 expectations 0 failed.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 1182f9a08bba · manifest aa983075d6a2
changelog_ref: e1c01d48f
```

```handoff
session: S1029
date: 2026-10-22
status: complete
self_score: 7
predecessor_score: 8
active_task: DONE -- the Diagram tab draws more than one affected condition per animal (owner pick at the Phase 0 picker, item 2 of 4, "More than one condition"; strict TDD, every phase behind its own gate): every pedigree column starting "affected" is a condition, in file order, the first four drawn; the symbol is split into equal sections, one per condition, in colors #CC79A7 #E69F00 #56B4E9 #009E73; the legend has a row per condition; the canvas grows 45 px per row past 11; a note names columns past four. Also ad hoc at the owner's request: the optional Chrome-for-Testing BACKLOG item removed (7934dcc24).
what_was_done: Claim f8e3651f2. Measured first: QC lower-cases a header and drops spaces, periods and underscores (affected_2 -> affected2); kinship2 draws up to four equal sections; no bundled file has two conditions; a standalone legend of 11 rows at 500 px reads 0.703 and each row adds 66 world units. One scope question (input shape and legend text, the recommended option taken) and the three phase gates were asked. RED 6a6e9646a (layout 13 new blocks, module 7, browser 2; failed on the pre-GREEN install for the right reasons). GREEN 079907fc4 (R/affectedConditions.R new, R/makePedigreeDiagramData.R, R/modPedigree.R, man page); real-app pictures of 2, 3 and 4 conditions and all five shapes opened for the owner before the long runs. Docs 9953771d9 (NEWS, Diagram article section, guide, manual). Mutation pins 9f7bbaf59: 24 mutants, 17 of the first 20 killed, three pinned, the painter's four killed with two pixel probes (outside the outline, on the section line). REFACTOR ca963f006 (.affectedSectionsOf(), .diagramUiHtml()). Close-out: SR3 pin changed RED first then the finished BACKLOG block removed, one found item added, Learning 995. Evidence: layout 84 blocks, module 90, browser 5 blocks 0 failed; full suite 444 files 4,140 blocks 14,103 expectations 0 failed 0 errors 196 skipped; lint_package 0; devtools::check() 0/0/0. Mid-session, the owner asked to remove the Chrome-for-Testing item (checked first: nothing reads its text; 109 BACKLOG-naming files 1,559 blocks 0 failed; 7934dcc24) and asked whether KJ5HST/methodology#93 had merged (it had not: see next_steps). Not pushed.
next_steps: No owner order was given; my order: (1) BACKLOG.md:16 contributor tutorial (DECISION NEEDED, Effort M; three owner decisions first: CONTRIBUTING.md plus article or article alone, how much strict TDD outsiders are asked to follow, audience). (2) The BACKLOG item "Scripted Diagram rendering lacks the deceased slash and the condition sections" (new, DECISION NEEDED, Effort M): an exported helper returning the handler, or say so at a2interactive.Rmd:472's "exactly". (3) Housekeeping, own sessions: methodology/HANDOFFS.md is over its WARN line (about 199,000 B against 196,608 B): run python3 methodology/methodology_trim.py --file methodology/HANDOFFS.md --budget-bytes 65536 --check, then --write, as its own commit apart from a close-out; a methodology sync is owed (SESSION_RUNNER.md 2 commits behind, SAFEGUARDS.md 1, methodology_dashboard.py v2.22.0 against 2.23.0, methodology_trim.py v1.8.0 against the fork's v1.8.1; re-apply the SESSION_NOTES.md patch per CLAUDE.md). (4) The BACKLOG item "Shard verify scripts that FAIL on lossless trims" is out of date and the owner has not asked for a change: KJ5HST/methodology issue #93 is open, its fix PR #94 is open and unmerged (changes requested 2026-10-19, the owner's reply and force-push 1670c5d the same evening; not on KJ5HST main, last commit 2026-10-03, nor on the fork's main); our synced trimmer v1.8.0 already has a read-only --reverify; run over all 59 shards it passes 2 (the 2026-10-14 ones) and refuses 57 with REVERIFY_SHARD_MISMATCH because the frozen scripts name docs/archive/ while the shards sit in methodology/archive/. Offer the owner a text update. (5) Optional: a picture of the sections for the Diagram article (a derived fixture and a script step; tests/testthat/test_captureHarness.R pins the script).
key_files: R/affectedConditions.R:13 (colors), :25 (finder), :38 (labels), :65 (.affectedSectionsOf), :91 (painter), :175 (.diagramAfterDrawing), :199 (.diagramHeight); R/makePedigreeDiagramData.R:1723-1731 (conditions), :1852 (conditionOf), :2154 (affectedSections); R/modPedigree.R:668 (height), :676 (note), :727 (legend rows), :767 (handler); tests/testthat/test_makePedigreeMatingLayout.R:2079 (S1029 section) and :2373 (mutation gaps); tests/testthat/test_modPedigree.R:2866; tests/testthat/test-e2e-pedigree-module.R:360 (open_diagram_with), :500 (read_legend_rows), :1136 (S1029 blocks), :1221 (pixel probes); vignettes/articles/pedigree-diagram.qmd ("More than one affected condition"); BACKLOG.md (new found item, above the kinship2 audit section).
gotchas: QC rewrites headers before any name rule sees them (affected_2 and affected2 are one column); QC turns sex H, X and O into U, so the real app never draws a star or a diamond (a script does); a pixel test of a painted shape needs a probe outside the outline and on each boundary; a harness that cannot find its anchor must print ANCHOR PROBLEM and stop (my J3 and J4 first ran as the baseline); one NEWS check allows one Diagram entry to say shaded or filled; a BACKLOG removal shifts later cites (the Chrome item moved the kinship2 block from 241 to 224); the browser tier needs R CMD INSTALL --no-docs --library=<scratch> ., R_LIBS=<scratch>:<renv lib>, RENV_CONFIG_AUTOLOADER_ENABLED=false, NOT_CRAN=true, NPRC_RUN_E2E=true, and a block can be extracted into a scratch folder with the helper-*.R files symlinked; the sections are painted by the app's own script, so visNetwork() alone draws neither them nor the S1028 slash.
runtime_smoke: The running app was driven (shinytest2 AppDriver on a scratch install of the final code): two conditions fill the left and right halves of a circle and a square in the right colors (pixels), an unaffected or unknown animal stays open with its section line, nothing paints outside the outline, four conditions give 10 legend labels on a 635 px canvas with every gap 6 or more and scale 0.65 or more; pictures of 2, 3 and 4 conditions were read and opened for the owner; 5 browser blocks 0 failed.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results fa5fa2978bbb · manifest aa983075d6a2
changelog_ref: f8e3651f2
```

