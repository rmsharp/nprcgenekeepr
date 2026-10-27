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
session: S1072
date: 2026-10-27
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- harem trials build their set-up once per groupAddAssign() call (BACKLOG item "Breeding Groups: harem trials redo their set-up work every trial", filed S1066), under strict TDD (owner pick at the Phase 0 picker, item 1 of 4, "Faster harem trials"; the PRE-RED->RED, RED->GREEN and GREEN->REFACTOR gates each answered "Yes"). Block off BACKLOG.
what_was_done: Claim 06fee3112. Profiled 200 harem trials: 70% in getPotentialSires(), about 9 calls a trial, 60% in lubridate::today()'s time-zone check; only the sire draw differs between trials. Scratch prototype: 9.03 to 4.17 s, 30 of 30 outcomes identical. RED fa8ac7484: frozen copies of groupAddAssign(), makeGroupMembers() and initializeHaremGroups() from 520bd5dc8; 8 harem grid cases; test_haremSetUp.R (call count 458 against 26, the helpers' start on 25 inputs x 3 seeds, fills handed the set-up or not); opt-in 13 s budget; 85 of 94 expectations failed. GREEN df5644fd8: R/makeHaremSetUp.R (makeHaremSetUp(), drawHaremGroups()), fillGroupMembers(haremSetUp = NULL), groupAddAssign() builds the set-up once after 1L:iter. Gate aa87799a9: perf_groupAddAssign_harem_1000_seconds 5.9 s (new 4.67/4.57/4.58 s, today's code 9.78/9.71/9.67 s). REFACTOR 27516dec1: initializeHaremGroups() is one call to the helpers; defaultRelatives() test helper for two copies, identical on 6 inputs. NEWS 6568bf3e5. Verified: full suite 478 files 4,468 tests 0 failed 0 errors and check 0/0/0 on GREEN and REFACTOR; lint 0; mutants 7 of 7; the app 10.9 to 5.7 s.
next_steps: The owner picks at the next Phase 0. READY: diagram time outside the solver (BACKLOG.md:237, M), founder statistics' memory peak (:244, S), GPU and CPU pixel passes (:261, S); the DECISION NEEDED items are unchanged. New finding to put to the owner (not filed): the reportGV-example gate measures 0.31 to 0.41 s from the repo folder against 0.22 s from a scratch worktree of the same commit, so it failed this session's ratchet run (0.31 against 0.3) with no code cause; not investigated past ruling out src/ and ignored R/ files. At Phase 0 read the scheduled shinytest2 run on S1067's fix (none yet at S1072's Phase 0, 04:14 UTC 2026-10-27). Not pushed (30 ahead).
key_files: R/makeHaremSetUp.R:31 (makeHaremSetUp: the two stops, the sires, the pool without them), :76 (drawHaremGroups: the one sample() a trial); R/groupAddAssign.R:300-309 (1L:iter first, the set-up once, handed to each trial); R/fillGroupMembers.R:37,45-46 (the optional set-up); R/initializeHaremGroups.R:24 (one call to the helpers); tests/testthat/test_haremSetUp.R:26-41 (call count), :50-126 (start comparison), :140-149 (fills); tests/testthat/helper-perfReference.R:592,639,672 (frozen copies); tests/testthat/helper-perfCampaign.R:121 (defaultRelatives); methodology/.quality-gates.json:63 (the gate); NEWS.Rmd:424-425.
gotchas: A shinytest2 app driven from the repo folder ran the repo source although R_LIBS put a scratch install first (find.package() inside the app said so): for a before/after app timing drive from outside the repo with a scratch app.R that calls library(lib.loc =) and logs find.package(). The reportGV-example gate is folder-sensitive (0.31 s in the repo, 0.22 s in a worktree). zsh does not split an unquoted $F list: use ${=F}. A test_file() loop needs absolute paths. groupAddAssignReference() is now the pre-campaign text, so it stays as it is when groupAddAssign() changes again. A 3x-headroom budget passes today's code when the gain is under 3x (say so in the file; RED needs a deterministic test).
runtime_smoke: The GREEN tree and the pre-session code installed into scratch libraries (R CMD INSTALL --no-docs); a scratch app.R (library(lib.loc =), find.package() logged, groupAddAssign() traced) driven by shinytest2 from the scratch folder: ExamplePedigree.csv, Breeding Groups, All available (332), Harem, 3 groups, 1,000 trials: before 10.9 s from the click (groupAddAssign 10.25 s), after 5.7 s (5.00 s); each harem shows one male (ages 12.3, 13.4 and 13.5), the groups hold 70, 72 and 70 animals, no console errors.
quality_ratchet: 10/11 pass · 1 fail · 0 unmeasured · results 30b7bc1b5d01 · manifest a22028f2dbff (the fail is perf_reportGV_example_seconds, 0.31 against 0.3, a folder effect, not this session's code)
changelog_ref: 06fee3112
commit: 6568bf3e5
```
Self 8/10. + Profiled and prototyped before RED, so the gate texts carried measured numbers and every gate was taken as recommended; 7 of 7 mutants caught, full verification on both trees; the app before/after proved by find.package() inside the app. - The first app comparison (5.8 s both) rested on an unchecked package path, and a zsh list split and a relative path in a test_file() loop cost about 5 calls. Predecessor S1071 8/10: its Next and the block named the four functions, the equivalence test and the gate rule, all accurate; its "a real-app run reads the installed package" was wrong for a driver started from the repo folder.

```handoff
session: S1071
date: 2026-10-26
status: complete
self_score: 7
predecessor_score: 9
active_task: DONE -- the shipped example snapshot history (inst/extdata/examples/example_snapshot_history.csv) holds values the package makes (BACKLOG item "The example snapshot history's neGD values are not gene diversity", found S1070), under strict TDD (owner pick at the Phase 0 picker, item 1 of 4, "Fix example neGD"; owner rulings "All three" and "Leave them"; the three gates answered "Yes" and one GREEN->RED stop "Back to RED").
what_was_done: Claim 4f8d12e5e. Measured all 27 columns of the 4 rows against the definitions and against createColonySnapshot() rows of qcPed and the example colony's 332 living animals: neGD 42.5-43.8/30.4 where 1 - 1/(2*fg) gives 0.919-0.944; meanGu/medianGu/meanGuSE written as shares (about 0.21/0.21/0.004) where calcGU() writes percentages (example colony 22.8/14.4/0.28); kurtosis 2.8-3.2 where calcKurtosis() gives excess kurtosis (example colony -0.28/0.88); the rest consistent. RED f4dd96b15 (tests/testthat/test_exampleSnapshotHistoryValues.R; test_calcSnapshotDeltas.R rows 1-2), RED addition b68f4e293 (test_plotSnapshotTrends.R meanGu band, missed at RED by a truncated grep, found by the first GREEN run), GREEN 160d0915d (24 cells: neGD 0.9419/0.9432/0.9444/0.9194, genome uniqueness x100, kurtosis -3), REFACTOR ba2baebce (validatedSnapshotHistory() in tests/testthat/helper-snapshotHistory.R for four identical copies). BACKLOG block off; CHANGELOG DONE entry; Learning 1037.
next_steps: The owner picks at the next Phase 0. READY items: harem trials redo set-up work (BACKLOG.md:237, M), diagram time outside the solver (:247, M), founder statistics' memory peak (:254, S), GPU and CPU pixel passes (:271, S); the DECISION NEEDED items are unchanged. At Phase 0, read the first scheduled shinytest2 run on S1067's fix (due about 07:15 UTC 2026-10-27; run 40286217416 was the last red one). Not pushed (23 ahead of origin after this commit).
key_files: inst/extdata/examples/example_snapshot_history.csv (the corrected 24 cells, columns 13 and 22-25, 27); tests/testthat/test_exampleSnapshotHistoryValues.R:24-41 (the neGD-against-fg test and the pinned corrections); tests/testthat/helper-snapshotHistory.R:9 (the shared reader); tests/testthat/test_calcSnapshotDeltas.R:103-127 (rows 1-2 hand-copied); tests/testthat/test_plotSnapshotTrends.R:245-263 (the meanGu band); R/calcGeneDiversity.R, R/calcGU.R:114-115 (percent), R/calcKurtosis.R (excess) for the definitions.
gotchas: Never cut an inventory grep with a per-file head: the RED inventory's | head -15 hid test_plotSnapshotTrends.R's hand-copied meanGu band, the gate text said "the one test that copies" when there were two, and a GREEN->RED reversal was needed. validatedSnapshotHistory() now lives in helper-snapshotHistory.R and loads for every test file; a test file that defines the same name locally shadows it. The example file's values are hand-made: only neGD is tied to a definition (fg); the genome uniqueness and kurtosis numbers are pinned values. The three test files' own made-up rows (test_appendColonySnapshot.R, test_calcSnapshotDeltas.R, test_plotSnapshotTrends.R builders) still use neGD 44.2, meanGu 0.229 and kurtosis 2.8/3.0 by owner ruling. A real-app run needs the scratch install on R_LIBS (the app and system.file read the installed package).
runtime_smoke: The tree installed into a scratch library (R CMD INSTALL --no-docs), the full app started with shinytest2, the corrected file uploaded on the Genetic-Health Trends tab, the Trends sub-tab's 18-panel chart (903 x 600 px) draws neGD on 0.92-0.945, meanGu about 20-22 with its band, meanGuSE 0.28-0.41 and kurtosis -0.2 to 0.2, each panel in its intended direction; picture opened for the owner.
quality_ratchet: 10/10 pass · 0 fail · 0 unmeasured · results 48f546074f8c · manifest 38cf32b77360
changelog_ref: 4f8d12e5e
commit: ba2baebce
```
Self 7/10. + Measured every column against definitions and two real colonies before the scope question, which found the genome-uniqueness and kurtosis scale errors the filed item did not name; the owner took the recommended option each time; the real-app picture and full verification on both trees. - A truncated inventory grep missed a second test that copies the file's values, so two gate texts carried a false "the one test" and a GREEN->RED reversal cost a round trip. Predecessor S1070 9/10: its Next and block named this item, its definition, the pinned test line and the reader count, all accurate.

```handoff
session: S1070
date: 2026-10-26
status: complete
self_score: 7
predecessor_score: 9
active_task: DONE -- guidance on what a colony manager can learn from the Genetic-Health trend (BACKLOG item "Genetic-Health Trends: no document says what a colony manager can learn from the trend", owner-requested S1069), one file shown under the trend chart and in the guide, under strict TDD (owner pick at the Phase 0 picker, item 1 of 4, "Trends guidance"; the three gates answered "Yes"; owner rulings "App box + guide, one text", three questions covered, the drafted text approved as written).
what_was_done: Claim 5a8cfecae. Research: panels titled by column name; band +/-1 SE on fg and meanGu only; provenance change = another point shape plus caption; neGD = 1 - 1/(2*fg), a 0-1 share; mean GU falls on loss and on spread; founder counts = known founders in the pedigree trimmed to the population and its ancestors; lacy1989Ped probe: an import moves fe/fg only once it has offspring (2.909 to 3.390). RED 52b512616 (tests/testthat/test_snapshotTrendsGuidance.R, 4 tests, 87 of 142 failing). GREEN 1b91df4ad (inst/extdata/ui_guidance/snapshot_trends.html; R/modSnapshotTrends.R Trends sub-tab box; colony-manager-guide.qmd "#### Reading the trend" + chunk trend-guidance). REFACTOR 62b4e8e5a (helpBoxStyle for three exact copies, byte-identical UI). NEWS d1982110e. Filed: example_snapshot_history.csv neGD on the wrong scale (BACKLOG, READY S). Owner question answered: the memory and speed report is docs/audits/PERF_CAMPAIGN_REPORT_2026-10-26.md (opened).
next_steps: Owner-given order (S1069) is finished: S1069's item and the trends guidance are both done. Next, the owner's pick from the picker; the newest READY item is the example history's neGD (BACKLOG.md:237, Effort S: correct the four rows so neGD = 1 - 1/(2*fg), check the other columns the same way, re-check test_calcSnapshotDeltas.R:116 which pins 42.5 and the eight other test files that read the file). Other READY: harem trials (:249, M), diagram time outside the solver (:259, M), founder statistics' memory peak (:266, S), GPU and CPU pixel passes (:283, S). At Phase 0, read the first scheduled shinytest2 run on S1067's fix (07:00 UTC 2026-10-27). Not pushed (17 ahead of origin after this commit).
key_files: inst/extdata/ui_guidance/snapshot_trends.html (the one text); R/modSnapshotTrends.R:95-109 (the Trends sub-tab and its box); R/helpBoxStyle.R (the shared style); vignettes/articles/colony-manager-guide.qmd:1312-1320 (the guide's subsection and chunk); tests/testthat/test_snapshotTrendsGuidance.R (the guard, incl. every trendDefaultMetrics panel named); inst/extdata/examples/example_snapshot_history.csv (the wrong neGD values); BACKLOG.md:237 (the new item).
gotchas: The guide's chunk reads the INSTALLED package (system.file, mustWork = TRUE), so a local quarto render needs a scratch R CMD INSTALL and R_LIBS=<scratch>/lib:<renv path>; render a copy in the scratch folder (the qmd plus shiny_app_use/) to keep vignettes/ clean. A panel added to trendDefaultMetrics fails test_snapshotTrendsGuidance.R until the page explains it (skewness/kurtosis names ride on their shared line). AppDriver element pictures crop inside a box's padding (read getComputedStyle before calling a background missing); a chromote element picture stops at the session height. shinytest2 still needs NOT_CRAN=true and RENV_CONFIG_AUTOLOADER_ENABLED=false. Answer an owner question that arrives mid-turn first and on its own line.
runtime_smoke: The tree installed into a scratch library (R CMD INSTALL --no-docs), the full app started with shinytest2, the shipped example history uploaded, the Genetic-Health Trends tab's Trends sub-tab shows the "Reading the trend" box under the 18-panel chart with all 13 bullets (computed background rgb(237, 237, 237), padding 10px, radius 25px); the guide copy rendered with quarto 1.7.33 shows the subsection inside the trends section, raw HTML formatted, no code; both pictures opened for the owner.
quality_ratchet: 10/10 pass · 0 fail · 0 unmeasured · results 252b26ac1cc5 · manifest 38cf32b77360
changelog_ref: 5a8cfecae
commit: d1982110e
```

```handoff
session: S1069
date: 2026-10-26
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the Build Earlier Snapshots box's "filed under their own rule" sentence (R/modSnapshotTrends.R:69-72; BACKLOG item "The Build Earlier Snapshots box's 'filed under their own rule' reads like a folder", owner-reported S1065), reworded in the owner-approved words under strict TDD (owner pick at the Phase 0 picker, item 1 of 4, "Snapshot help sentence"; the three gates answered "Yes"). The BACKLOG block is removed; the owner's follow-up (no document says what a manager learns from the trend) is filed at BACKLOG.md:237, next in line by the owner's word.
what_was_done: Claim 16e4c48d5. Research: each fact in S1065's stored draft checked against code: rebuilt rows join the existing history (R/backfillColonySnapshots.R:259, appendColonySnapshot()), so they show in the History table and Download Updated History; the Trends chart draws them dashed with a caption (R/plotSnapshotTrends.R:140,158); the History tab renders the history as is, so its header is the raw name membershipRule (DT::datatable() of a real rebuilt history, 28 header cells), while "Membership rule:" is only the Compare Snapshots selector's label, so the draft's "Membership rule column" became "membershipRule column". Owner chose "Box only" (guide step 4 already says the rebuilt points are drawn dashed apart from recorded ones; the two help pages and a2interactive.Rmd:924 keep "filed under"). RED 7849e86c1: a test_that in tests/testthat/test_modSnapshotTrends.R pins the exact sentence and no "filed under" (2 expectations failed). GREEN 0e4e84ae5: the helpText's second sentence replaced. REFACTOR 2231ea4b0: the panel test's comment no longer says "where they are filed". The owner then asked whether any document says why someone would build earlier snapshots and what can be learned; read the guide, NEWS, help page, vignette, the #170 and #167 plans and the ui_guidance pages: the why is one clause each, the rest caveats, nothing on what the trend teaches; filed at the owner's word. Verified: full suite on the GREEN tree 475 files 4,457 tests 0 failed 0 errors (212 skipped); lint_package 0; devtools::check() 0/0/0; the module file on the final tree 57 tests 156 expectations 0 failed. Learning 1035.
next_steps: Owner-given order (S1069): (1) finish this item if anything is left (nothing known: block off, all checks green); (2) the new trends-guidance item, BACKLOG.md:237 (DECISION NEEDED, M: decide where it goes, a guide subsection after step 4, an app help page for the tab, or both, and which questions it covers; the owner writes or approves the sentences; check each statement about a measure against its function's documentation); (3) the rest. At Phase 0, read the first scheduled shinytest2 run on S1067's fix (07:00 UTC 2026-10-27; gh run list --branch master --limit 10); this session's commits are not pushed. READY: :254 harem trials (M); :264 the diagram's time outside the solver (M); :271 the founder statistics' peak (S); :288 CPU and GPU passes for the local browser tests (S). DECISION NEEDED: :203 equal-score order, :213 Mate Pair memory, :222 Realized Relatedness table, :231 the kept relationship table, :278 the nine fallbacks.
key_files: R/modSnapshotTrends.R:66-78 (the Build Earlier Snapshots box); tests/testthat/test_modSnapshotTrends.R:372-396 (the panel test and the new sentence test); vignettes/articles/colony-manager-guide.qmd:1264-1310 (the Genetic-Health Trends section; :1270 its only sentence on what the trend shows); docs/planning/retrospective-snapshot-backfill-plan.md section 1.1; BACKLOG.md:237 (the new item); PROJECT_LEARNINGS.md Learning 1035.
gotchas: shinytest2's AppDriver stops with "Reason: On CRAN" without NOT_CRAN=true; with a scratch install also set R_LIBS=<scratch>/lib:<the renv path .libPaths() prints> and RENV_CONFIG_AUTOLOADER_ENABLED=false. The History table shows raw column names (membershipRule), so name columns as the table shows them. An element picture of a sidebar box: set an id on its .well with app$get_js(), then app$get_screenshot(file, selector = "#<id>"). Tests read BACKLOG.md and the ledgers, so do not edit them while a full suite runs.
runtime_smoke: The tree installed into a scratch library (R CMD INSTALL --no-docs), the full app started with shinytest2 and moved to the Genetic-Health Trends tab: the Build Earlier Snapshots box's text reads the new sentence and its element picture shows it whole, nothing clipped (opened for the owner).
quality_ratchet: 10/10 pass · 0 fail · 0 unmeasured · results 4f34ad9653e8 · manifest 38cf32b77360
changelog_ref: 16e4c48d5
commit: 2231ea4b0
```

```handoff
session: S1068
date: 2026-10-26
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the two @inheritParams lines with nothing to inherit (R/addParents.R's reportGV, R/removeUninformativeFounders.R's trimPedigree; BACKLOG item "Two @inheritParams lines with nothing to inherit", owner-reported S1060), deleted under strict TDD (owner pick at the Phase 0 picker, item 1 of 4, "Empty @inheritParams lines"; the three gates answered "Yes"), with a package-wide guard test. The BACKLOG block is removed.
what_was_done: Claim 1ad2b06f0. Research: a roxygen run (roxygen2 8.0.0) on a scratch worktree printed "@inheritParams failed" for exactly addParents and removeUninformativeFounders and changed no file; roxygen2:::inherit_params warns when a page's own @param names (comma lists split, \dots as ...) cover all its formals, per page (@rdname joins blocks, @noRd makes none); roxygen2 is dev-only and no package dependency reaches it, so a roxygen-calling test would skip on CI. Owner chose "check all help pages" over a two-function test or a roxygen run. RED 2afa4dabb: tests/testthat/test_roxygenInheritParams.R, a plain-R reader (parse(keep.source = TRUE), the #' lines above each function), 11 synthetic cases each run through roxygen2::roc_proc_text(rd_roclet()) first (pass), and a scan of R/ (36 pages with @inheritParams; fails naming the two). GREEN 26b11046a: the two lines deleted; devtools::document() prints nothing and man/ is unchanged. REFACTOR e67f30e5b (owner's pick over my "skip"): the reader moved word for word to tests/testthat/helper-roxygenBlocks.R. Verified on the final tree: the new file 13 expectations 0 failed; full suite 475 files 4,456 tests 0 failed 0 errors (212 skipped); lint_package 0; devtools::check() 0/0/0 (also on the GREEN tree). Learning 1034.
next_steps: Read the first scheduled shinytest2 run on S1067's fix (07:00 UTC 2026-10-27; gh run list --branch master --limit 10); this session's commits are not pushed. Then pick from BACKLOG.md. READY: :237 the Build Earlier Snapshots help sentence (S, the owner's words, test-first); :248 harem trials' per-trial set-up (M); :258 the diagram's 1.7 s outside the solver (M); :265 the founder statistics' peak (S); :282 a CPU-drawing pass for the local browser tests (S). DECISION NEEDED: :203 equal-score order, :213 Mate Pair memory, :222 Realized Relatedness table, :231 the kept relationship table, :272 the nine fallbacks.
key_files: R/addParents.R:4-32 and R/removeUninformativeFounders.R:4-31 (the two roxygen blocks); tests/testthat/test_roxygenInheritParams.R (the 11 cases, the R/ scan); tests/testthat/helper-roxygenBlocks.R (inheritParamsPages(), emptyInheritParams()); PROJECT_LEARNINGS.md Learning 1034.
gotchas: roxygen2 is not installed where CI runs the tests (Config/Needs/dev only), so a test that calls it only skips there; check a doc-reader case against roxygen with roxygen2::roc_proc_text(roxygen2::rd_roclet(), text). A helper-*.R loads for every test file, so grep its names first. Tests that read R/ skip under R CMD check. The reader reads only blocks above a function assignment (all 64 @inheritParams blocks today).
runtime_smoke: No runtime behavior changed: two roxygen comment lines removed and devtools::document() left man/ byte-identical (git status showed only the two R files), so the installed help and the app are unchanged; nothing to launch.
quality_ratchet: 10/10 pass · 0 fail · 0 unmeasured · results f31c02d7c3b4 · manifest 38cf32b77360
changelog_ref: 1ad2b06f0
commit: e67f30e5b
```

```handoff
session: S1067
date: 2026-10-26
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- the nightly shinytest2 failure of the Diagram tab's deceased-slash test (run 40286217416, tests/testthat/test-e2e-pedigree-module.R:475,477; owner pick at the Phase 0 picker, item 1 of 4, "Nightly slash test (Recommended)"; strict TDD, the three gates answered "Yes"). Test code only: the pixel reader reads a partly see-through pixel as it shows on white, the outline cutoff is half covered, the overhangs are re-read at 25 sub-pixel view shifts. The BACKLOG item is removed; the owner's follow-up (local tests with CPU and GPU drawing) is filed at BACKLOG.md:291.
what_was_done: Claim bb8c3a8ba. Diagnosis (no code): CI's job log gives Chrome for Testing 156.0.8078.47 on Linux and circle 0.37, gap 0.91; a scratch install here (R CMD INSTALL --no-docs --library=<scratch>, HeadlessChrome 155) passes at 1.265/1.279. A probe printing the raw distances showed the outline pixel on E's diagonal is (52,130,234) at alpha 133, which diagram_pixel_js() counted as white. Chrome started with --disable-accelerated-2d-canvas gave 31/83.5 = 0.371 and gap 0.908 at the first frame (the sibship bar found in place of E's outline): CI's numbers exactly; this Mac paints the first frames on the GPU. Over 100 positions 0.1 px apart with CPU drawing: the old reader 28/100 within 1.10-1.40 and gap < 0.12; blending 100/100 but the circle up to 1.391; blending plus cutoff 194 100/100 (square 1.261-1.333, circle 1.245-1.340, gap <= 0.054); a single-pixel ray still misses. RED 25414fa0b: the 25-position sweep inside the slash test (GPU: 3 of 19 failed; CPU: 5 failed, :475 0.37 and :477 0.91 as on CI). GREEN d57172c28: lum() and rgb() blend onto white; cutoff 250 to 194 (half way from white to #2B7CE9's grey 133). REFACTOR 71ef50967: one overhang_js for both readers. Owner ruling at a follow-up question: local runs test with both CPU and GPU; the app needs nothing (vis-network calls getContext("2d") with no options); filed BACKLOG.md:291. Verified: slash block 19 expectations 0 failed and the whole file 22 blocks 111 expectations 0 failed, each with GPU and CPU drawing; full suite 474 files 4,454 tests 0 failed 0 errors (212 skipped); lint_package 0; devtools::check() 0/0/0. Learning 1033.
next_steps: The nightly shinytest2 stays red until a push carries d57172c28 (the scheduled run uses the remote default branch); after the push the owner asks for, read the next scheduled run with gh run list --branch master --limit 10. Then pick from BACKLOG.md. READY: :213 two empty @inheritParams lines (S); :246 the Build Earlier Snapshots help sentence (S, the owner's words, test-first); :257 harem trials' per-trial set-up (M); :267 the diagram's 1.7 s outside the solver (M); :274 the founder statistics' peak (S); :291 a CPU-drawing pass for the local browser tests (S, owner ruling S1067; first step: choose how the second pass runs). DECISION NEEDED: :203 equal-score order, :222 Mate Pair memory, :231 Realized Relatedness table, :240 the kept relationship table, :281 the nine fallbacks.
key_files: tests/testthat/test-e2e-pedigree-module.R (diagram_pixel_js() :313-339; the slash test's overhang description, overhang_js, get_overhang() and 25-position sweep :446-534); tests/testthat/helper-shinytest2.R:200,235 (create_test_app(), create_app_driver()); R/deceasedSlash.R (the slash handler, unchanged); BACKLOG.md:291 (the follow-up); PROJECT_LEARNINGS.md Learning 1033.
gotchas: Pixel tests read a GPU frame first on this Mac and a CPU frame on CI: run them with chromote::set_chrome_args(c(chromote::default_chrome_args(), "--disable-accelerated-2d-canvas")) before the app starts, too. After many getImageData() calls this Mac's frames read like CPU frames, so one local run can pass on its first frame and fail later. vis-network's network.redraw() paints synchronously; moveTo() alone only asks for a frame. testthat::test_file(path, desc = "<description with its newline and indentation>") runs one block. R_LIBS needs <scratch>:<the renv library .libPaths() prints>, plus RENV_CONFIG_AUTOLOADER_ENABLED=false NOT_CRAN=true NPRC_RUN_E2E=true. The tool output of a file read can carry a wc line on top: take line numbers from grep -n.
runtime_smoke: No runtime behavior changed (no R/ edit). The changed test drove the real app from a scratch install: the slash block and the whole E2E pedigree file passed with Chrome's GPU drawing and with --disable-accelerated-2d-canvas; the CI proof is the next nightly after a push.
quality_ratchet: 10/10 pass · 0 fail · 0 unmeasured · results 08bd46cbf3d1 · manifest 38cf32b77360
changelog_ref: bb8c3a8ba
commit: 71ef50967
```

```handoff
session: S1066
date: 2026-10-26
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- Phase 11 of the performance and memory campaign, consolidation (owner pick at the Phase 0 picker, item 1 of 4, "Campaign Phase 11 (Recommended)"; no code changed, so no TDD cycle). The campaign is complete: report docs/audits/PERF_CAMPAIGN_REPORT_2026-10-26.md, the owner's NEWS line, three gates tightened, helper-perfReference.R kept, D2 plain R, four leftovers filed, the BACKLOG block removed.
what_was_done: Claim c4fb07453. Measured: 20 scenarios x 3 fresh runs at c4fb07453 (load 4.4-5.2 in pass 1, 8-22 after, from other work): reportGV-example 3.28 to 0.23 s (0.66 of its 0.35 s estimate), all 3,694 38.50 to 3.03 s (1.38), synthetic 35.03 to 3.57 s (0.92), convertRelationships-600 64.21 to 0.12 s and the whole example 3.40 s (build) + 4.20 s (write.csv), groupAddAssign-1000 23.04 to 5.54 s (harem 27.19 to 10.69), diagram 12.81 to 5.10 s (1.02), backfill 9.42 to 0.99 s, gvaConvergence 4.73 to 0.75 s (1.07); the app session (tools/perf/runAppSession.R) 3 runs on 520bd5dc8 (scratch worktree, tool copied in) and 3 on HEAD, alternating: upload + QC 696.6 to 516.0 MB, through Genetic Diversity 922.3 to 684.4 MB, Mate Pair 1,989.2 to 1,397.8 MB, the LD tab did not finish (15 min, then a 2-min cap) and takes 14.2 s now. Probes: none of the nine *General() fallbacks runs on the shipped data (positive control: a sparse kinship() counts one); filterKinMatrix()'s 0.14 s on all 3,694 is a first-call garbage collection; issue #37 needs nothing (the four helpers are still called). Owner rulings: keep helper-perfReference.R (17 copies, 7 files, 48 tests, 66 s); D2 stays plain R; the NEWS line as drafted, a Speed and Memory section (7f479fc98); all four leftovers filed. Gates (958a47e4f): perf_reportGV_example_seconds 0.8 to 0.3, perf_convertRelationships_300_seconds 0.2 to 0.1, perf_backfill_jmac_seconds 1.4 to 1.3; six re-measured, unchanged. Report, plan complete, D2 revisit, BACKLOG items :269 :279 :286 :293 (e223bf1db). Close-out: the campaign block off BACKLOG.md, CHANGELOG.md DONE entry, Learning 1032. Verified: full suite 474 files 4,454 tests 0 failed 0 errors; lint 0; devtools::check() 0/0/0; budget tests (NPRC_RUN_PERF=true) 8 files 11 tests 0 failed; NEWS readers 19 files 172 tests 0 failed; ratchet 10/10.
next_steps: The campaign is over and no owner-ordered work remains; pick from BACKLOG.md. READY: :246 the nightly shinytest2 deceased-slash failure (CI break, S; run test-e2e-pedigree-module.R:475,477 from a scratch install, then read run 40286217416's Chrome version and pixels); :213 two empty @inheritParams lines (S); :258 the Build Earlier Snapshots help sentence (S, the owner's words, test-first); :269 harem trials' per-trial set-up (M, identical() groups, add a harem gate); :279 the diagram's 1.7 s outside the solver (M, profile first; crossprod() only with identical positions on CI's three platforms); :286 the founder statistics' peak (S, find the step). DECISION NEEDED: :203 the tie order; :222 Mate Pair's 1 GB; :231 Marker Genetics' every-pair table; :240 Summary Statistics' kept table; :293 the nine fallbacks.
key_files: docs/audits/PERF_CAMPAIGN_REPORT_2026-10-26.md (sections 3 the rows, 6 the app table, 7 the gates, 11 open items); docs/planning/performance-memory-campaign-plan.md (status, D2 at section 6, Phase 11's done note); docs/audits/PERF_BASELINE_2026-10-24.md (the before); methodology/.quality-gates.json (9 perf gates + tarball); tools/perf/run.R, tools/perf/harness.R, tools/perf/runAppSession.R, tools/perf/appSession.R; tests/testthat/helper-perfReference.R (the kept oracle); NEWS.Rmd:416-424 (the Speed and Memory section); BACKLOG.md:269-302 (the four new items).
gotchas: The harness at load 8 to 22 reads up to 10% slow; the unchanged sparse-kinship rows are the control (50.68 against 45.43 s). A threshold only tightens, so a loaded run cannot raise a gate; two gates stayed because their rule value was looser. To run old code with today's tool: git worktree add --detach <scratch>/pre <sha>, copy tools/perf in, run from the main checkout (renv's shinytest2), check the clicked input ids exist with git grep -c on both commits, and remove the worktree with --force; cap the waits in the copy when old code may never finish. zsh does not split an unquoted $files; testthat::test_file() changes the working directory; a monitor's pgrep -f '<script>' matches its own shell.
runtime_smoke: No runtime behavior changed (no R/ edit). The scripted app session ran today's source tree (c4fb07453) three times through all ten steps (upload and QC, Genetic Diversity, Genetic Value at 1,000 iterations, Summary Statistics, Breeding Groups, Genetic Diversity with groups, Mate Pair, Marker Genetics and its Linkage and LD tab), each run leaving 10 ranking rows, 3 histograms, 3 group tables, 1 heat map, 315,023 pairs and 6,824,665 relatedness rows. The browser-tier test files were not re-run (no code changed since S1065).
quality_ratchet: 10/10 pass · 0 fail · 0 unmeasured · results 78157e1e2a9d · manifest 38cf32b77360
changelog_ref: c4fb07453
commit: e223bf1db
```

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

