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

```handoff
session: S968
date: 2026-10-12
status: pending
active_task: IN PROGRESS -- take and record the owner's three rulings on docs-audit part 2's open code defects (BACKLOG.md:129-133: the "Upload list" choice, R/modBreedingGroups.R:40-43; the two do-nothing checkboxes, R/modGeneticValue.R:63-66; the unused allele_1/allele_2 genotypes, R/fixColumnNames.R:38); owner pick at the Phase 0 picker, option 1 of 4; DECISION NEEDED, Effort S; PRE-RED, a decision-only session (no code until a ruling needs it, then its own gates)
what_was_done: pending
commit: pending
```

```handoff
session: S967
date: 2026-10-12
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the groupAddAssign() help says "...the set of groups with the largest minimum group size (the score is the size of the smallest group)." instead of "largest average size" (R/groupAddAssign.R:11-12 and the regenerated man/groupAddAssign.Rd:153-154; the code ranks a trial by its smallest group, :285): the owner approved the one sentence at the PRE-RED gate; owner pick at the Phase 0 picker, option 1 of 4; READY, Effort S; strict TDD, every gate asked and answered, REFACTOR taken. BACKLOG.md:125-133 updated; the docs-audit item stays open with three rulings left.
what_was_done: Phase 0 (1 commit past the CHANGELOG frontier, covered by the S966 DONE entry; 0 pending receipts; CI 10 of 10 green; dashboard 96/100 High+ 0; context budget OK; ratchet citation matched). Claim 014892b04 (S966 folded into the condensed notes block). PRE-RED: read the code (score = min(lengths(groupMembers))), probed a 10-and-9 candidate on qcBreeders (score 9, mean 9.5) and both paragraph readers, asked the gate with the whole sentence. RED 8f21aedd8: tests/testthat/test_groupAddAssignHelp.R, 7 blocks, 26 expectations, 6 failed, 0 skipped, 0 errors (one test bug, a named string from the roxygen reader, fixed before the commit). GREEN 6d224c590: one roxygen sentence, devtools::document() regenerated one man page; the file 26 of 26; full suite 3,439 blocks 0 failed 0 errors 187 skipped 6 warnings; lint 0; devtools::check() 0/0/0; 3 mutations caught by the blocks that read them (4, 4 and 3 expectations; the score one only after a package reload). REFACTOR 5dfe2fd4f: tests only, the two places are one named list helpPlaces and two blocks are one loop; same 7 blocks and 26 expectations; same mutation results; full suite and lint repeated. Close-out: BACKLOG.md edit, Learning 933, CHANGELOG DONE entry, notes, this receipt.
next_steps: Your three rulings (BACKLOG.md:129-133): "Upload list" (R/modBreedingGroups.R:40-43: remove, build or leave); the two do-nothing checkboxes (R/modGeneticValue.R:63-66: remove or leave); allele_1/allele_2 genotypes unused with no notice (R/fixColumnNames.R:38: leave, accept the spelling or add a notice; my pick: the notice). One decision-only session takes all three; a decision pick is not a go-ahead to edit. Other picker options: the contributor tutorial (BACKLOG.md:139), the Japanese macaque file (:156), the Diagram deceased marker (:403); the snapshot backfill (:194) needs its own scoping session; the 3.0.0 bump (:8) waits for release. 27 commits ahead of origin/master once this lands (S963 to S967, unpushed): the push changes R/, man/ and tests/, so all four workflows run; read them.
key_files: R/groupAddAssign.R:8-12 (the sentence) and :285 (the score); man/groupAddAssign.Rd:150-155; tests/testthat/test_groupAddAssignHelp.R (helpers manParagraph, roxygenParagraph, helpPlaces; 7 blocks); BACKLOG.md:125-133; PROJECT_LEARNINGS.md Learning 933 (last entry); inst/extdata/ui_guidance/gvAndBgDesc.html:151 (the phrase the guide already used).
gotchas: a mutation of R/ code needs pkgload::load_all() after it: a block that reads a file sees the mutation and one that runs a function does not, so a "0 caught" can be the harness (the score mutation, first run); devtools::document() rewrote only the one man page this time but read git diff --stat; PROJECT_LEARNINGS.md has no trailing newline until an append, so check the blank line before a new heading; put R code with \s in a script file, not Rscript -e; the old runGeneKeepR pids 29511, 82416, 92900 still run and are left alone.
runtime_smoke: the generated help page renders the new sentence (tools::Rd2txt of man/groupAddAssign.Rd); the Shiny app was not launched because only help text changed (no UI, no runtime code), and the behavior lock runs groupAddAssign() for real (numGp = 2, seed 10). quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results e8850bbf6f18 · manifest aa983075d6a2
changelog_ref: S967 DONE entry
commit: the close-out commit that carries this receipt; claim 014892b04, RED 8f21aedd8, GREEN 6d224c590, REFACTOR 5dfe2fd4f
```

```handoff
session: S966
date: 2026-10-12
status: complete
self_score: 7
predecessor_score: 8
active_task: DONE -- docs-audit part 2's four likely code defects of slice 4 re-checked against today's code: docs/audits/DOCS_AUDIT_PART2_FOUR_CODE_CANDIDATES_RECHECK_2026-10-12.md (0 critical, 3 moderate, 1 minor); all four are still real in the code and the docs already say so except the groupAddAssign "average" wording; BACKLOG.md item text updated and the item stays open (owner pick at the Phase 0 picker, option 1 of 4; an audit, PRE-RED throughout, no code change and no fix).
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI 10 of 10 green, dashboard 96/100 High+ 0, context budget OK, ratchet citation matched). Claim 87ac25207 (S965 folded into the condensed notes block). Traced the four candidates to slice 4's report (the BACKLOG "8" label was wrong), read the code at each cite, grepped every identifier across R/ inst/ vignettes/ tests/, dated each earlier doc fix with git log -S, and ran two probes from scratch scripts (qcStudbook(), and the real Input module through shiny::testServer, input pedigreeFileTwo). Found: "Upload list" uploads nothing (docs say so); the two calculate checkboxes are never read (docs say so); allele_1/allele_2 in a one-file pedigree load with 0 errors, 0 warnings and no genotypes (docs say so; the app shows only the rename note, read in R/appServer.R:236-296, not seen); the groupAddAssign roxygen still says "largest average size" where the code scores the smallest group; "or younger" was fixed S844. Report, BACKLOG item text, Learning 932 and ledger entry in cdfa78408; this receipt and the notes in the next commit. No R/ or test change. Verified: four wrong line numbers in the first draft of the report were caught by a grep -n pass over every cite and fixed before the commit.
next_steps: Your four rulings (the report's Recommendations): (1) "Upload list": remove, build the upload, or leave; (2) the two do-nothing checkboxes: remove or leave; (3) allele_1/allele_2 genotypes unused with no notice: leave, accept the spelling, or add a notice (my pick); (4) the "average" wording needs only a go-ahead and is one small strict-TDD session (roxygen plus the regenerated man/ page). Each ruling is its own session and none changes a calculated number. Part 2 still has the 6a-6e, 7b and 8 clusters (BACKLOG.md:109). Other picker options, cites re-grepped after my edit: the Japanese macaque file BACKLOG.md:156, the Diagram deceased marker :403, the contributor tutorial :139; the snapshot backfill :194 needs its own scoping session; the 3.0.0 bump :8 waits for release. Local master is unpushed from S963 on; the push changes tests/, so CI will run: read it.
key_files: docs/audits/DOCS_AUDIT_PART2_FOUR_CODE_CANDIDATES_RECHECK_2026-10-12.md; R/modBreedingGroups.R:40-43 (the choice) and :531-536 (the pool); R/modGeneticValue.R:63-66 (the two checkboxes); R/groupAddAssign.R:11 (the "average" line), :37-40 (minAge) and :284 (the score); R/fixColumnNames.R:38 (underscore strip); R/hasGenotype.R:32 (needs first and second); R/modInput.R:130 (pedigreeFileTwo) and :523 (reportChanges = TRUE); R/appServer.R:236-296 (Changed Columns tab); PROJECT_LEARNINGS.md:2641 (Learning 932).
gotchas: qcStudbook(reportErrors = TRUE) returns NULL when there are no errors and no column changes, and the column-change note needs reportChanges = TRUE (the app passes it, R/modInput.R:523); the one-file option's file input is pedigreeFileTwo, not pedigreeFileOne; a slice label in a carried item can be wrong, so grep the candidate's own words across docs/audits before opening the labeled report; .gitignore tracks docs/audits/**; probe scripts live in the scratchpad, never the repo, and the scratchpad path is copied from the environment block, not retyped; the notes file is about 55.6 KB, so the next claim folds S966 into the condensed block and keeps it under about 56,700 B; three old runGeneKeepR pids (29511, 82416, 92900) are left alone.
runtime_smoke: n/a -- docs-only audit, no runtime change. The allele_1/allele_2 behavior was measured through the real Input module (shiny::testServer(modInputServer)), not the full app and not a browser, so what the Changed Columns tab draws is read from the code, not seen. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results fff75d50c33a · manifest aa983075d6a2
changelog_ref: S966 DONE entry
commit: the close-out commit that carries this receipt; claim 87ac25207, report cdfa78408
```

```handoff
session: S965
date: 2026-10-12
status: complete
self_score: 7
predecessor_score: 9
active_task: DONE -- methodology/HANDOFFS.md and methodology/CHANGELOG.md are under the context-budget size check: two on-demand rows in methodology/.context-budget.json (warn at 196,608 B, growth refused past 262,144 B; the owner's numbers and yes to CHANGELOG.md), pinned by the new tests/testthat/test_contextBudgetLedgers.R (4 blocks, 26 expectations); BACKLOG.md:8-19 item removed (owner pick at the Phase 0 picker, option 1 of 4; config and tests only; strict TDD, every gate asked and answered, REFACTOR taken).
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI 10 of 10 green, dashboard 96/100 High+ 0, context budget OK, ratchet citation matched). Claim dc5c87394 (S964 folded into the condensed notes block). PRE-RED: read context_budget.py and measured in a scratch copy that the item's own class, read-mandated, adds a 25,000-token check HANDOFFS.md already fails (87,830 B, about 38,691 tokens: red on day one, a 1,000 B receipt refused), while class on-demand is ok, warns past 196,608 B and refuses growth only past 262,144 B; two plain questions (the numbers; CHANGELOG.md yes), both answered on the recommended option. RED 226ad5f55 (22 failed, 4 passed, 0 skipped), RED amendment f0a5f1bcb (the owner approved GREEN to RED: two patterns assumed a trailing comma no correct config prints), GREEN aaaa81515 (config only), REFACTOR 505789449 (tests only). Verified: full suite 3,432 blocks, 0 failed, 0 errors (187 skipped, 6 warnings) after GREEN and after REFACTOR; lint 0; devtools::check() 0/0/0 after GREEN (not re-run after the one-file REFACTOR); 7 mutations of the rows each fail a block, before and after the REFACTOR. BACKLOG.md:8-19 removed (later cites move up 13); one sentence in CLAUDE.md:229-232; Learning 931.
next_steps: Recommended order (not ruled on; cites re-grepped after the removal). Docs-audit part 2 is the item at BACKLOG.md:16 (text :109); the 3.0.0 bump is :8 (READY only at release time). Other picker options: the Japanese macaque example file (:150, DECISION NEEDED, Effort S), the Diagram deceased marker (:397, DECISION NEEDED, Effort M), the contributor tutorial (:133); the snapshot backfill (:188) needs its own scoping session. 19 commits ahead of origin/master once this lands (git rev-list); the owner's push changes tests/, so CI will run: read it. The next close-out must keep SESSION_NOTES.md under about 56,700 B.
key_files: methodology/.context-budget.json:52-65 (the two rows and their notes); tests/testthat/test_contextBudgetLedgers.R (helpers budgetTree, runBudgetTool, expectLedgerStatus; 4 blocks); CLAUDE.md:229-232; methodology/context_budget.py:126 (WHOLE_READ_CLASSES), token_ceiling() at :155; PROJECT_LEARNINGS.md:2637 (Learning 931).
gotchas: a read-mandated class adds a token check clamped at 25,000 tokens (about 56,750 B), so a file the protocol reads in part takes a class outside resident/read-mandated/read-set (here on-demand); context_budget.py --status appends to the gitignored history on every run (my probes took growth_run from 187 to 189), so probe in a scratch copy; CHANGELOG.md has two "## 2026-10" headings (the trimmer's seam): prepend under the first; an on-demand row's JSON ends at warn_bytes, so match with a digit boundary, not a comma, and run every pattern against one real row before committing RED; a test that runs the tool inside a scratch folder needs absolute paths; the first warning is about 20 to 34 sessions out (an estimate: HANDOFFS.md about 92 KB after this close-out, 3,205 to 5,557 B a receipt), so the live warn path has not fired yet; three old runGeneKeepR pids (29511, 82416, 92900) are alive and left alone; keep SESSION_NOTES.md under about 56,700 B and every line under 280 B.
runtime_smoke: context_budget.py read the live config and shows both ledger rows ok (87,830 B and 54,554 B of 262,144 B); its --precommit, which the installed .git/hooks/pre-commit runs, was exercised in scratch git folders (growth at 200,000 B passes, growth at 263,000 B refused with exit 2, a shrink passes) and the GREEN and REFACTOR commits went through the installed hook; the Shiny app is untouched (no R/ change). The live warn path itself has not fired (the files are far below 196,608 B). quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 5c8dd26c8285 · manifest aa983075d6a2
changelog_ref: S965 DONE entry
commit: the close-out commit that carries this receipt; claim dc5c87394, RED 226ad5f55, RED amendment f0a5f1bcb, GREEN aaaa81515, REFACTOR 505789449
```

```handoff
session: S964
date: 2026-10-12
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- no guide picture is taken with a pop-up on screen: the colony script waits before 8 pictures (the six Pedigree Browser ones, age_plot.png, gva_calculating.png) and the Diagram script before 3, each with one line wait_for_popups_before(app, "<file>.png"); 13 pictures retaken (the 11 that carried a pop-up, and by the owner's choice the 2 other Diagram pictures); BACKLOG.md:8-20 item removed (owner pick at the Phase 0 picker, option 1 of 4; capture scripts, tests and pictures only; strict TDD, every gate asked and answered, REFACTOR taken).
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI 10 of 10 green, dashboard 96/100 High+ 0, context budget under every ceiling, ratchet citation matched). Claim f57389c69. Measured first: the 9 listed pictures looked at, a colour scan of all 47 committed pictures (11 carry a pop-up; the Warnings picture keeps its on purpose), one plain scope question (answered: all 11). RED ec50d9e38 (helper waitsRightBeforeShot() plus 3 script-text blocks that fail, 11 expectations, 0 skipped, and 1 block for the 2 older waits). GREEN 30d725342 (8 wait steps in the colony script, 3 in the Diagram script), d9664c715 (5 Diagram pictures: a second question, answered: all 5, because the fresh run showed the Focal Animals sentence S955 replaced, which S956 did not retake for the Diagram script), cdc79292e and c2fdce1a9 (8 colony pictures). REFACTOR 56417b245 (the 11 three-line steps become one recorder function, wait_for_popups_before(), installed by start_capture_run(); 3 new blocks). Verified: full suite 3,428 blocks, 0 failed, 0 errors (187 skipped, 6 warnings); lint 0; devtools::check() 0/0/0 on the first run; 16 mutations each broke only the block aimed at. BACKLOG.md:8-20 removed (later cites move up 13); Learning 930.
next_steps: Recommended order (not ruled on; cites re-grepped after the removal). Budget HANDOFFS.md (BACKLOG.md:8, DECISION NEEDED; its file names predate the move into methodology/: the files are methodology/HANDOFFS.md and methodology/.context-budget.json). Docs-audit part 2 is the item at BACKLOG.md:29 (text :122); the 3.0.0 bump is :21. 13 commits ahead of origin/master once this lands (git rev-list); the owner's push changes tests/ and vignettes/, so CI will run: read it. The next close-out must condense SESSION_NOTES.md (about 56,740 B against the commit hook's limit near 56,750 B).
key_files: tests/testthat/helper-captureHarness.R:98 (wait_for_popups_before), :127 and :141 (list and install); tests/testthat/test_captureHarness.R:307-328 (function blocks), :886 (waitsRightBeforeShot), :901-973 (pin blocks); vignettes/articles/colony-manager-guide-screenshots.R and pedigree-diagram-screenshots.R (grep wait_for_popups_before: 8 and 3 calls); the 13 pictures in vignettes/articles/shiny_app_use/; PROJECT_LEARNINGS.md:2634 (Learning 930).
gotchas: a step label is a result key, so each wait names its picture (a repeated label overwrites the earlier result); a Shiny pop-up is fixed to the viewport's lower right, so in a tall capture it lands over whatever the bottom holds; after a shown-text change run every capture script (S956 ran only the colony one, so the Diagram pictures kept the old Focal Animals sentence); a pop-up pixel count depends on the colour set of the scan, so quote one scan only (GREEN 3's commit message mixes two: 7,925 is from the first scan, 8,832 from compare.py); sips -c does not crop, use Pillow under python3 -I; a CSV-upload picture that differs may only show the random file<hex>.csv name; three old runGeneKeepR pids (29511, 82416, 92900) are alive and left alone; keep SESSION_NOTES.md under about 56,700 B and every line under 280 B.
runtime_smoke: both capture scripts drove the real app (headless Chrome) twice, colony 95 of 95 steps and diagram 21 of 21, no failed step, the second run after the REFACTOR; the 13 new pictures were looked at, an old-over-new sheet was opened for the owner, and a colour scan finds no pop-up in any committed picture except the Warnings one. No R/ change. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 73af0a7ec186 · manifest aa983075d6a2
changelog_ref: S964 DONE entry
commit: the close-out commit that carries this receipt; claim f57389c69, RED ec50d9e38, GREEN 30d725342, d9664c715, cdc79292e, c2fdce1a9, REFACTOR 56417b245
```

```handoff
session: S963
date: 2026-10-11
status: complete
self_score: 7
predecessor_score: 9
active_task: DONE -- the colony manager guide shows the Warnings sub-tab as the app opens it after a check: read_and_check_pedigree_warnings.png (the whole 1300 x 900 window, the two warnings listed, the yellow notice still on screen) after the QC Summary picture, with the owner's sentence, caption and an alt text (BACKLOG.md:8-16 item, removed; owner pick at the Phase 0 picker, option 1 of 4; docs and the capture script only; strict TDD, every gate asked and answered, REFACTOR taken).
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, 4 ad hoc methodology commits since S962 each in CHANGELOG.md and pushed, CI 10 of 10 green, dashboard 96/100 High+ 0, context budget under every ceiling, ratchet citation matched). Claim ebb288e44. Measured first: a probe in the real app (the Warnings sub-tab opens itself, the notice is on screen 1.9 s after the click, 1300 x 900), the picture opened for the owner, one plain question with the sentence, caption and place (answered: use them, after the QC Summary picture). RED 970c10a20 (5 blocks in test_captureHarness.R fail, 0 skipped; commit message amended once, 7 became 20 guarded expectations), GREEN 74491eb77 (one capture step and one shot, the guide sentence, caption and alt text, the picture from the full run, 87 of 87 steps), REFACTOR 1e3821e63 (tests only, shotLineOf(); 11 mutation checks broke the block aimed at, before and after). Verified: full suite 3,420 blocks, 0 failed, 0 errors (187 skipped, 6 warnings), run twice; lint 0; devtools::check() 0/0/0 on the third run (the first two: 0 warnings, 0 notes, 1 error each, the wall-clock benchmark test_markerKinship.R:177 at load 8 and 15 to 20, passing alone 3 of 3). BACKLOG.md:8-16 removed (later cites move up 9); Learning 929.
next_steps: Recommended order (not ruled on; cites re-grepped after the edit). Optional, S: pop-up item (BACKLOG.md:8); budget HANDOFFS.md (BACKLOG.md:21, DECISION NEEDED; its file names predate the move into methodology/: the files are methodology/HANDOFFS.md and methodology/.context-budget.json). Docs-audit part 2 is the item at BACKLOG.md:42 (text :135); the 3.0.0 bump is :34. 5 commits ahead of origin/master once this lands (git rev-list); the owner's push changes tests/ and vignettes/, so CI will run: read it. The next close-out must condense SESSION_NOTES.md (55,759 B against the commit hook's limit near 56,700 B).
key_files: vignettes/articles/colony-manager-guide-screenshots.R:195-211 (the step and the shot); vignettes/articles/colony-manager-guide.qmd:245-249 (sentence, picture, alt text); tests/testthat/test_captureHarness.R:514 (shotLineOf), :717-834 (the five new blocks); vignettes/articles/shiny_app_use/read_and_check_pedigree_warnings.png; PROJECT_LEARNINGS.md:2631 (Learning 929).
gotchas: the capture recorder counts each do_step and each shot once (87 now); the loop block at test_captureHarness.R:396 gains an expectation for every new wait_for_element( line in the script; the notice stays 8 s, so the new step is the guard and stops with a reason; devtools::check() failed the test_markerKinship.R:177 benchmark when the 1-minute load was above about 7 (macOS FSEvents, Spotlight, IDrive), so read uptime first; the old stash@{0} from dev is not ours, never pop it; three old runGeneKeepR pids (29511, 82416, 92900) are alive and left alone; keep SESSION_NOTES.md under about 56,700 B and every line under 280 B.
runtime_smoke: the guide's capture script drove the real app (headless Chrome), 87 of 87 steps, no failed step, with the new step and shot in place; the new picture was looked at and opened for the owner and shows the Warnings sub-tab, both warnings and the notice. No R/ change. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 202c62e2937b · manifest aa983075d6a2
changelog_ref: S963 DONE entry
commit: the close-out commit that carries this receipt; claim ebb288e44, RED 970c10a20, GREEN 74491eb77, REFACTOR 1e3821e63
```

```handoff
session: S962
date: 2026-10-11
status: complete
self_score: 7
predecessor_score: 8
active_task: DONE -- a box that holds exactly one animal is headed "(1 animal)" on the Breeding Groups tab and the nobody-is-alive notice for a one-animal source reads "The 1 animal in this source is not alive, so no breeding groups were formed." (BACKLOG.md:30-38 item, removed; owner pick at the Phase 0 picker, option 1 of 4; owner chose to retake the 3 pictures in this session; strict TDD, every gate asked and answered, REFACTOR taken).
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI 10 of 10 green but pushes only up to S939, dashboard 96/100 High+ 0, context budget under every ceiling, ratchet citation matched). Claim 7c95083a1. Measured first: two code places (R/modBreedingGroups.R:682-689 notice, :993-994 headings); all six Breeding Groups pictures looked at: 3 show "(1 animals)" (the item said wording only); a probe found the one-animal fixture (nine animals, seed 7: 3 groups asked leave a one-animal last box, 5 asked give two one-animal groups). One plain question with the sentences (answered: use them, retake the 3 pictures). RED 9f3cea521 (3 blocks fail, 6 expectations), GREEN 0fa5a5761, RED c268af266 (the retaken sex-ratio box holds four animals, the guide said six; 2 pins), GREEN 8c47bdabd (3 pictures, 85 of 85 steps; six to four), REFACTOR 5d9694135 (tests only; guard re-proved), NEWS efa3c7828. Verified: full suite 3,414 blocks, 0 failed, 0 errors (187 skipped, 6 warnings); lint 0; devtools::check() 0/0/0. BACKLOG.md:30-38 removed (later cites move up 9); Learning 928.
next_steps: Recommended order (not ruled on; cites re-grepped after the edit). Optional, S: Warnings picture (BACKLOG.md:8), pop-up item (:17), budget HANDOFFS.md (:30, DECISION NEEDED). Docs-audit part 2 is the item at :51 (text :144); the 3.0.0 bump is :43. 130 commits ahead of origin/master once this lands; the owner's push changes R/, so CI will run: read it.
key_files: R/modBreedingGroups.R:682-689 (notice), :993-994 (headings); tests/testthat/test_guideBreedingGroupsWording.R:137 (groupsText), :268-309 (the two one-animal blocks); tests/testthat/test_modBreedingGroups_livingPool.R:108 (lpWithStatus), :297-330 (notice blocks); vignettes/articles/colony-manager-guide.qmd:624-628 (sex-ratio paragraph and alt text, "four"); PROJECT_LEARNINGS.md Learning 928.
gotchas: the nine-animal fixture's one-animal boxes are at seed 7 only; a retake draws the last box's count, so the test pin follows the picture; a mutation check must change what the tests read (return "", not "keep the tags"); zero needs no change (nobody alive draws no box; a zero-animal source's notice was not probed); three old runGeneKeepR pids (29511, 82416, 92900) are alive and left alone; keep SESSION_NOTES.md under about 56,700 B and every line under 280 B.
runtime_smoke: the guide's capture script drove the real app (headless Chrome), 85 of 85 steps, after GREEN with no R/ change since; breeding_group_1.png and breeding_group_6_infants_with_dam.png of that run show "Unused animals (1 animal)". The one-animal notice was tested with a mocked showNotification, not seen in the real app. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results ed5566ce7b22 · manifest aa983075d6a2
changelog_ref: S962 DONE entry
commit: the close-out commit that carries this receipt; claim 7c95083a1, RED 9f3cea521, GREEN 0fa5a5761, RED c268af266, GREEN 8c47bdabd, REFACTOR 5d9694135, NEWS efa3c7828
```

```handoff
session: S961
date: 2026-10-11
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the Breeding Groups last box (the animals that fit no group) is named "Unused animals" on the Groups heading, the Statistics row and the Group Detail selector (BACKLOG.md:36 item, removed; owner pick at the Phase 0 picker, option 2 of 4; owner scope: the three labels only; strict TDD, every gate asked and answered, REFACTOR taken).
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI 10 of 10 green but pushes only up to S939, dashboard 96/100 High+ 0, context budget under every ceiling, ratchet citation matched). Claim 75910467f. Measured first: 5 places name the box (3 in the item, plus the candidate Groups count and the Group-N.csv file names, both left by the owner's ruling) and 3 of the 7 guide pictures show it (the item said 1). RED f0552138a (2 of 11 blocks fail), GREEN 854561b68 (R/modBreedingGroups.R three labels, guide sentence; 11 of 11), RED 8b2a6b34a (the retaken box holds six animals, the guide said seven; 2 pins), GREEN 04e7f7d21 (3 pictures from the guide's own script, 85 of 85 steps; seven to six), REFACTOR 0a7013150 (one internal breedingGroupLabels(), guard re-proved by breaking it). Verified: full suite 3,410 blocks, 0 failed, 0 errors (187 skipped, 6 warnings); lint 0; devtools::check() 0/0/0. NEWS.Rmd line added and NEWS.md re-knit; BACKLOG.md:36-51 removed (later cites move up 13), the (1 animals) plural carried into BACKLOG.md:30; Learning 927.
next_steps: Recommended order (not ruled on; BACKLOG.md cites re-grepped after the edit). Optional, S: budget HANDOFFS.md and CHANGELOG.md (BACKLOG.md:39, DECISION NEEDED, the two byte numbers), None of the 1 animals plus the (1 animals) plural (BACKLOG.md:30), Warnings picture (BACKLOG.md:8), pop-up item (BACKLOG.md:17). Docs-audit part 2 is the item at BACKLOG.md:60 (text at :153); the 3.0.0 bump is BACKLOG.md:52. 122 commits ahead of origin/master once this lands (git rev-list); the owner's push adds R/breedingGroupLabels.R and changes R/modBreedingGroups.R, so CI will run: read it. Estimates, not measurements: the next HANDOFFS.md trim in about 27 sessions, CHANGELOG.md in about 59.
key_files: R/breedingGroupLabels.R:20; R/modBreedingGroups.R:981-989 (heading), :1017-1025 (Statistics), :1049 (selector); tests/testthat/test_guideBreedingGroupsWording.R:203-228 and :304-330; vignettes/articles/colony-manager-guide.qmd:626-633; the three pictures in vignettes/articles/shiny_app_use/ (breeding_group_1, breeding_group_6_infants_with_dam, breeding_group_sex_ratio_specification); BACKLOG.md:30-37; PROJECT_LEARNINGS.md:2625 (Learning 927).
gotchas: the candidate table's Groups count and the Group-N.csv / GroupKin-N.csv file names are unchanged by the owner's ruling, do not re-offer; the selector's values stay numbers (the capture script sets the box by value); a capture run decides the box's animal count (six this time), so the caption pin follows the picture; the headings read (1 animals) for one animal, older than this change (BACKLOG.md:30); cites to BACKLOG.md:52, :65 and :73 in S960's receipt and Learning 926 are now :39, :52 and :60, frozen as written; in run_in_background a ( cmd ) & wrapper reports its own exit, so read the job's log (hit again); put R code with a backslash in a script file (an Rscript -e with \. failed); zsh reads a ===== echo as an expansion; three runGeneKeepR pids (29511, 82416, 92900) are alive and left alone, the until loop pid 89205 is gone; keep SESSION_NOTES.md under about 56,700 B and every line under 280 B.
runtime_smoke: the guide's capture script drove the real app (headless Chrome) twice, 85 of 85 steps each, the second after the REFACTOR; breeding_group_1.png of that run shows "Unused animals (2 animals)". quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 2905e8fa1143 · manifest aa983075d6a2
changelog_ref: S961 DONE entry
commit: the close-out commit that carries this receipt; claim 75910467f, RED f0552138a, GREEN 854561b68, RED 8b2a6b34a, GREEN 04e7f7d21, REFACTOR 0a7013150
```

```handoff
session: S960
date: 2026-10-10
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- CHANGELOG.md trimmed with methodology_trim.py, 200,518 B to 33,981 B (owner pick at the Phase 0 picker, option 1 of 4; housekeeping, not a BACKLOG.md item; no R/ or test change, so no TDD gates). 135 of 156 records (2026-10-04 to 2026-10-09) are in docs/archive/CHANGELOG-through-2026-10-09.md.
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI 10 of 10 green but pushes only up to S939, dashboard 96/100 with a MEDIUM CHANGELOG.md flag, context budget under every ceiling, ratchet 1/1). Claim d79290f13 (carries its own CHANGELOG.md entry, so the trimmer's P1_UNDOCUMENTED gate was clear). Dry run: trigger fires, SRF 0.7508 vs the last archive f4b181c and 0.1906 vs the largest-drop boundary, no refusal, L1/L2/L3 OK, so --write --budget-bytes 65536 ran with no --force; 135 of 156 records archived, shard 168,387 B, 21 kept plus the tool's own entry. Trim commit 6f6f669fd (ledger, shard, verify script), apart from the close-out; the verify script passes before and after it. Readers checked: no test reads CHANGELOG.md content, the new shard is covered by docs/** and ^docs$, 5 ledger-reading test files pass. Verified: full suite 3,410 blocks, 0 failed, 0 errors (187 skipped, 6 warnings, as S959); dashboard MEDIUM flag gone, High+ 0. BACKLOG.md:63 updated (CHANGELOG.md crossed the line at S959, S960 trimmed it). Learning 926.
next_steps: Recommended order (not ruled on; BACKLOG.md cites re-grepped after the edit, none moved). Optional, S: budget HANDOFFS.md and CHANGELOG.md (BACKLOG.md:52, DECISION NEEDED, the two byte numbers), last-box label (BACKLOG.md:36), None of the 1 animals (BACKLOG.md:30), Warnings picture (BACKLOG.md:8), pop-up item (BACKLOG.md:17). Docs-audit part 2 is inside the item at BACKLOG.md:73 (text at :166); the 3.0.0 bump is BACKLOG.md:65. 114 commits ahead of origin/master once this lands (git rev-list); the owner's push changes R/, so CI will run: read it. Estimates, not measurements: the next HANDOFFS.md trim in about 28 sessions, CHANGELOG.md in about 60.
key_files: docs/archive/CHANGELOG-through-2026-10-09.md and its .verify.sh; CHANGELOG.md:75-81 (the tool's own entry); BACKLOG.md:52-63 (the budget item, now naming CHANGELOG.md's crossing); PROJECT_LEARNINGS.md:2622 (Learning 926); tests/testthat/test_workflowPathsIgnore.R:41 (one old shard listed as a sample).
gotchas: the trimmer neither stages nor commits (git add the ledger, the shard and its verify script, three files); the claim commit needs its own CHANGELOG.md entry before --write (Learning 545); commit a trim apart from the close-out so the verify script passes; each quality_ratchet.py --run prints a new results hash (S959 cited two), so cite only the last run; old CHANGELOG.md:NNNN cites in four frozen docs/planning files were already dead; SESSION_NOTES.md is 56,679 B, under about 56,700, so the next stub must fold the S960 entry the way S960 folded S959; the four old processes (pids 29511, 82416, 92900, 89205) are alive and left alone.
runtime_smoke: n/a -- no R/ change (ledger and notes files only), so the app was not launched; the unfiltered full suite ran from the source tree. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results c7cb9c5626e1 · manifest aa983075d6a2
changelog_ref: S960 DONE entry
commit: the close-out commit that carries this receipt; claim d79290f13, trim 6f6f669fd
```

```handoff
session: S959
date: 2026-10-10
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the three hidden "joint effort between ONPRC and SNPRC" comment lines are deleted from `vignettes/manual_components/_introduction.Rmd` and from the `README.md` knitted from it (owner pick at the Phase 0 picker, option 1 of 4; the owner took the recommended "delete" first try; strict TDD, every gate asked and answered, REFACTOR taken at the owner's choice). BACKLOG.md:52-72 is removed.
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI 10 of 10 green, dashboard 96/100 High+ risk 0, context budget under every ceiling, ratchet 1/1 matching the S958 receipt). Claim ceffd887d. Measured before asking: exactly 2 copies outside the logs (README.md:43, _introduction.Rmd:28), no test reads them, git log -L dates them to the 2018 commit 34a1b9dbd. RED 6f91a288f (1 new block in test_originFundingWording.R; of 17 blocks 16 pass, 1 fails on exactly README.md and the introduction, 0 errors, 0 skipped). GREEN 0081d0f5e (the Rmd and a README re-knit against a scratch-installed HEAD; diff = the 3 lines, their spacers and 2 render-date lines; 17 of 17, test_workflowPathsIgnore.R 11 of 11). REFACTOR 3462444ca (one introductionFile for 3 spellings of the path; guard re-proved by writing the claim back). Verified: full suite 3,410 blocks 0 failed 0 errors (187 skipped, 6 warnings, as S958 plus the 1); lint 0; devtools::check() 0/0/0. No NEWS entry (no reader sees a change). Learning 925.
next_steps: Recommended order (not ruled on; BACKLOG.md cites re-grepped after the removal). Optional, S: budget HANDOFFS.md (BACKLOG.md:52, DECISION NEEDED, the two ceilings), last-box label (BACKLOG.md:36), None of the 1 animals (BACKLOG.md:30), Warnings picture (BACKLOG.md:8), pop-up item (BACKLOG.md:17). Docs-audit part 2 is inside the item at BACKLOG.md:73 (part 2 text at :166); the 3.0.0 bump is BACKLOG.md:65. After the owner pushes (111 commits ahead of origin/master once this close-out lands: 110 by git rev-list --count origin/master..HEAD before it, plus this commit): the push changes R/ and tests, so CI will run; read the runs.
key_files: tests/testthat/test_originFundingWording.R:40 (introductionFile) and :245-260 (the new block); tests/testthat/helper-pageText.R:14 (pageText() does not strip HTML comments); vignettes/manual_components/_introduction.Rmd:24-28 (the acknowledgment, now followed straight by the function list); README.md:38-43 (the knit); PROJECT_LEARNINGS.md:2619 (Learning 925).
gotchas: pageText() keeps HTML comments, so a wording guard counts commented-out copies; a README edit is made in _introduction.Rmd and re-knit with R CMD INSTALL --no-docs --library=<scratch> then .libPaths(c(<scratch>, .libPaths())) before rmarkdown::render("README.Rmd"), which leaves two render-date lines in the diff (the installed build date is a day ahead in UTC); removing a BACKLOG.md block shifts later cites (21 here), so re-grep; a zsh echo whose first argument starts with = fails with "= not found", so quote it; the full suite takes several minutes and the wall-clock benchmark blocks fail under desktop load, so run nothing heavy beside it; the five worktrees and four old processes (runGeneKeepR pids 29511, 82416, 92900 and an until loop, pid 89205) are still alive, left alone; keep SESSION_NOTES.md under about 56,700 B and every line under 280 B.
runtime_smoke: n/a -- no R/ change (two hidden comments removed from docs, one test block added), so the app was not launched; devtools::check() built and checked the package and the full suite ran from the source tree. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 407c0091252c · manifest aa983075d6a2
changelog_ref: S959 DONE entry
commit: the close-out commit that carries this receipt; claim ceffd887d, RED 6f91a288f, GREEN 0081d0f5e, REFACTOR 3462444ca
```

```handoff
session: S958
date: 2026-10-10
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- getAncestors() carries on when a parent has no row of its own in the tree and stops with a message naming an asked-about animal that is not in it (owner pick at the Phase 0 picker, option 1 of 4; the owner chose the recommended rule first try; strict TDD, every gate asked and answered, REFACTOR skipped at the owner's choice). BACKLOG.md:73-87 is removed.
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI 10 of 10 green, dashboard 96/100 High+ risk 0, context budget under every ceiling, ratchet 1/1). Claim c0c156f53. Measured before asking: 7 of 7 inputs stopped with 'argument is of length zero'; after qcStudbook() the same animals gave GONE, B (addParents() adds the row, no error reported); the 5 shipped example pedigrees have 0 parents without a row; the app calls none of getAncestors(), findLoops(), countLoops(). RED e02da5c1b (8 new blocks in test_getAncestors.R 5, test_findLoops.R 2, test_countLoops.R 1, plus helper-absentParentPed.R; 14 existing pass, 1 fails on 2 of 3 expectations, 7 error, 0 skipped). GREEN 2fec4215b (R/getAncestors.R, R/makesLoop.R, man/getAncestors.Rd; 22 of 22). Verified: full suite 3,409 blocks 0 failed 0 errors (187 skipped, 6 warnings); lint 0; devtools::check() 0/0/0; the 5 tests that read NEWS.md pass. Close-out: NEWS.Rmd bullet and NEWS.md re-knit, BACKLOG.md item removed, Learning 924, notes, this receipt, the ledger entry.
next_steps: Recommended order (not ruled on; BACKLOG.md cites re-grepped after the removal). Optional, S: the hidden joint-effort comment (BACKLOG.md:52, DECISION NEEDED), budget HANDOFFS.md (BACKLOG.md:73, DECISION NEEDED), last-box label (BACKLOG.md:36), None of the 1 animals (BACKLOG.md:30), Warnings picture (BACKLOG.md:8), pop-up item (BACKLOG.md:17). Docs-audit part 2 is BACKLOG.md:187; the 3.0.0 bump is BACKLOG.md:86. After the owner pushes (106 commits ahead of origin/master once this close-out lands, counted by git rev-list): the push changes R/ and tests, so CI will run; read the runs.
key_files: R/getAncestors.R:55-63 (the asked-about check) and R/getAncestors.R:81-84 (absent parent returns no ancestors); R/makesLoop.R:29-30 (calls the recursive step directly); tests/testthat/helper-absentParentPed.R:10 (the raw-versus-QC fixture); tests/testthat/test_getAncestors.R:129 (the 5 new blocks); NEWS.Rmd:439 (the bullet); PROJECT_LEARNINGS.md:2616 (Learning 924).
gotchas: qcStudbook() gives an animal with exactly one known parent a placeholder id for the other (K with sire GONE and no dam got dam U0001, measured), so a raw-versus-QC fixture lists both parents or neither; makesLoop() passes a parent id to the recursive step, so the asked-about check must stay in getAncestors() only; removing a BACKLOG.md block shifts later cites (16 here), so re-grep; the full suite takes several minutes and the wall-clock benchmark blocks fail under desktop load, so run nothing heavy beside it; the five worktrees and four old processes (runGeneKeepR pids 29511, 82416, 92900 and an until loop, pid 89205) are still alive, left alone; keep SESSION_NOTES.md under about 56,700 B and every line under 280 B.
runtime_smoke: n/a for the app -- no app path calls getAncestors(), findLoops() or countLoops() (git grep over R/: getAncestors() is called only by countLoops() at R/countLoops.R:50, and findLoops() and countLoops() appear only in examples), so the app was not launched; the 7 probe inputs were run for real against the loaded package before and after GREEN, and devtools::check() ran the getAncestors() example. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 8a8362623462 · manifest aa983075d6a2
changelog_ref: S958 DONE entry
commit: the close-out commit that carries this receipt; claim c0c156f53, RED e02da5c1b, GREEN 2fec4215b
```

```handoff
session: S957
date: 2026-10-10
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the seven old-style `panel panel-*` boxes (the Home tab's six and one per breeding group) stay plain on purpose; the owner ruled it from a before/after picture, option 1 of 4 at the Phase 0 picker, recommended option, first try; a decision, so no code and no RED. BACKLOG.md:8-20 is removed.
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI green, dashboard 96/100 High+ risk 0, context budget under every ceiling, ratchet 1/1). Claim e7098f23d. Measured before asking: the Home boxes already carry colour on their buttons, 4 guide pictures show the boxes (home_tab_landing, breeding_group_1, breeding_group_6_infants_with_dam, breeding_group_sex_ratio_specification), 0 tests pin a panel class, the group-box cite was R/modBreedingGroups.R:956 and is :984. A scratch mock (before and after from one bslib flatly page, shot with chromote) was opened for the owner; the owner chose plain on purpose for both places. Close-out: BACKLOG.md item removed and the last-box item (BACKLOG.md:36) updated, Learning 923, memory old-style-panel-boxes-stay-plain, notes, this receipt, the ledger entry.
next_steps: Recommended order (not ruled on; BACKLOG.md cites re-grepped after the removal). Owner finding: getAncestors() (BACKLOG.md:73, DECISION NEEDED, S). Optional, S: the hidden joint-effort comment (BACKLOG.md:52), budget HANDOFFS.md (BACKLOG.md:89), last-box label (BACKLOG.md:36), None of the 1 animals (BACKLOG.md:30), Warnings picture (BACKLOG.md:8), pop-up item (BACKLOG.md:17). Docs-audit part 2 is BACKLOG.md:203; the 3.0.0 bump is BACKLOG.md:102. After the owner pushes (101 commits ahead of origin/master once this close-out lands, counted by git rev-list): the push changes R/ and tests, so CI will run; read the runs.
key_files: BACKLOG.md:36-50 (the updated last-box item); R/appUI.R:98-158 and R/modBreedingGroups.R:984-989 (unchanged, plain on purpose); vignettes/articles/shiny_app_use/home_tab_landing.png (unchanged); PROJECT_LEARNINGS.md:2613 (Learning 923); tests/testthat/test_handoffsReceiptPlacement.R:24 (the one test that reads HANDOFFS.md).
gotchas: a git grep for panel panel- in R/ is not a defect, the owner ruled it (memory old-style-panel-boxes-stay-plain); BACKLOG.md removal shifts later cites by the block length plus one (13 here), so re-grep; an image the model Reads does not reach the owner, `open <png>` does; the before and after were a scratch mock outside the repo (the scratchpad goes with the session), not a run of the app; the five worktrees and four old processes (runGeneKeepR pids 29511, 82416, 92900 and an until loop, pid 89205) are still alive, left alone; keep SESSION_NOTES.md under about 56,700 B and every line under 280 B.
runtime_smoke: n/a -- a decision with no R/, test, script or picture change; the app was not launched (the "before" was checked against the committed pictures, the "after" is a mock). quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 06c3fda69cff · manifest aa983075d6a2
changelog_ref: S957 DONE entry
commit: the close-out commit that carries this receipt; claim e7098f23d
```

```handoff
session: S956
date: 2026-10-10
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- the guide pictures that predate the default-population change are retaken (21: 12 that show the ranking, 9 Pedigree Browser pictures that show the Focal Animals sentence S955 replaced) and the four sentences that quote them are corrected; owner pick at the Phase 0 picker, option 1 of 4; scope question answered "all 21"; strict TDD, every gate asked and answered; docs and tests only. BACKLOG.md:65-82 is removed.
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI green, dashboard 96/100 High+ risk 0, context budget under every ceiling, the receipt's ratchet citation matched the results file). Claim a3498ec04 (S955 notes entry folded into the 947-955 block). One colony capture run into a scratch folder (85/85 steps, about 3 min), pixel-compared with the committed pictures: 16 identical, age_plot.png differs only by the date in its title (left alone), 21 differ for a real reason, each viewed beside its old one. RED bc1ad67b7: 4 blocks fail (7 expectations), 0 errors, 0 skipped. GREEN 4aa6f84bf (guide caption, alt text, sex-ratio paragraph and alt text, 3 pictures), 4a3748546 (5 pictures), 9e22437b9 (4 Breeding Groups pictures), 415a4e62f and a86e77beb (the 9 Pedigree Browser pictures). REFACTOR dffe739a0: exampleLiving named once in test_defaultPopulationWording.R; comment commit 33affbd7d. Verified: full suite 3,401 blocks 0 failed 0 errors (187 skipped, 6 warnings); lint 0; devtools::check 0/0/0; ratchet 1/1. Close-out: BACKLOG.md item removed (every later cite moves up 19 lines) and two stale sentences in the docs-audit item corrected, Learning 922, notes, this receipt, the ledger entry.
next_steps: Recommended order (not ruled on; BACKLOG.md cites re-grepped after the removal). Owner findings: old-style boxes (BACKLOG.md:8, DECISION NEEDED: cards or plain, M), getAncestors() (BACKLOG.md:86, DECISION NEEDED, S). Optional, S: the hidden joint-effort comment (BACKLOG.md:65), budget HANDOFFS.md (BACKLOG.md:102), last-box label (BACKLOG.md:49), None of the 1 animals (BACKLOG.md:43), Warnings picture (BACKLOG.md:21), pop-up item (BACKLOG.md:30). Docs-audit part 2 is BACKLOG.md:216; the 3.0.0 bump is BACKLOG.md:115. After the owner pushes (99 commits ahead of origin/master once this close-out lands, counted by git rev-list): the push changes R/ and tests, which are not on the 21-entry paths-ignore list, so CI will run; read the runs.
key_files: vignettes/articles/colony-manager-guide.qmd:445 (caption and alt, 332 entries and 34 pages), :626 and :628 (seven animals in the last box); vignettes/articles/shiny_app_use/ (the 21 retaken PNGs; age_plot.png not); tests/testthat/test_defaultPopulationWording.R:39 (exampleLiving) and its last two blocks; tests/testthat/test_guideBreedingGroupsWording.R:287-311 (the two edited blocks); vignettes/articles/colony-manager-guide-screenshots.R (run unchanged); PROJECT_LEARNINGS.md (Learning 922, the last entry).
gotchas: an unchanged picture is pixel-identical between capture runs here, so diff a fresh run against the committed set (differing pixel count, row range, column range) before listing what to retake, and name each difference's cause; a change that edits shown text stales every picture of that text, not only those with numbers it moves; a random-run picture decides its caption's number (the sex-ratio last box held seven animals, four in S950), so change the test pin first; the Mate Pair table's values moved with the population; the colony script takes about 3 minutes, not 8; the owner's comparison images used a magenta divider strip that exists only in scratch files, no committed picture has one (measured on all 46); BACKLOG.md removal shifts later cites by the block length plus its blank line, so re-grep; the five worktrees and four old processes (runGeneKeepR pids 29511, 82416, 92900 and an until loop, pid 89205) are still alive, left alone; keep SESSION_NOTES.md under about 56,700 B and every line under 280 B.
runtime_smoke: no R/ or capture-script change, so no new runtime behavior; the colony capture run (the real app, headless Chrome through shinytest2, 85/85 steps) is the real-app exercise and it produced the pictures; the guide was not rendered with quarto (only two caption and alt strings and one sentence changed, image paths unchanged). quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 5665ec29a318 · manifest aa983075d6a2
changelog_ref: S956 DONE entry
commit: the close-out commit that carries this receipt; claim a3498ec04, RED bc1ad67b7, GREEN 4aa6f84bf, 4a3748546, 9e22437b9, 415a4e62f and a86e77beb, REFACTOR dffe739a0, comment 33affbd7d
```

```handoff
session: S955
date: 2026-10-10
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- the default-population build (BACKLOG.md:65-82, ruled S954; owner pick at the Phase 0 picker, option 1 of 3; strict TDD, every gate asked and answered): with no focal animals entered the Pedigree Browser flags the living animals as the population, and every sentence that describes it says so. The up to 12 guide pictures that predate it are the new BACKLOG.md:65 item (owner scope).
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI green on all 10 runs, dashboard 96/100 High+ risk 0; the context-budget check read OVER only for 2 notes lines over 280 B, both S954's own). Claim 31837276e (S954 notes entry folded into the 947-954 block). Pre-RED: one question (a pedigree with no living animal: everyone, as the Genetic Value fallback does; measured on qcPed with every animal given an exit date: 280 of 280 flagged and calcFE 77.04, against nobody flagged and NaN), one scope question (behavior and every sentence now, pictures later), one wording question (seven sentences, all as written). RED a14103f25: 20 blocks, 14 fail 0 errors, 6 guards pass. GREEN 2e7cbcf7c (R/modPedigree.R: processedPedigree passes ped$id[isLivingAnimal(ped)] to the unchanged setPopulation(); help text, roxygen, man/modPedigreeServer.Rd, the guide with its export chunk) and 5e2d460e6 (manual, NEWS.Rmd, NEWS.md). Mutation check: a column set straight from isLivingAnimal() fails both nobody-alive guards, living-ignores-focal fails the focal-wins guard. REFACTOR d6b9a54ba: helper-pageText.R; same 16 + 10 blocks pass, same 9 wording blocks fail on the RED tree. Verified: full suite 3,399 blocks 0 failed 0 errors (187 skipped, 6 warnings); lint 0; devtools::check 0/0/0 on both trees. Real app: 332 flagged all ALIVE, 332 ranked, 267 / 60 / 5, median mean kinship 0.0152; the 332 typed as focal 268 / 59 / 5. Close-out: BACKLOG.md:65-82 replaced by the pictures item (18 lines for 18), Learning 921, notes, this receipt, the ledger entry.
next_steps: Recommended order (not ruled on; BACKLOG.md cites re-grepped after this edit). The pictures item at BACKLOG.md:65 (READY, M; the colony capture script takes about 8 minutes, an estimate from S942-S945; retake, compare each with its old picture, fix the numbers in captions). Owner findings: old-style boxes (BACKLOG.md:8, M), getAncestors() (BACKLOG.md:105, S). Optional, S: the hidden joint-effort comment (BACKLOG.md:84), budget HANDOFFS.md (BACKLOG.md:121), last-box label (BACKLOG.md:49), None of the 1 animals (BACKLOG.md:43), Warnings picture (BACKLOG.md:21), pop-up item (BACKLOG.md:30). Docs-audit part 2 is BACKLOG.md:235; the 3.0.0 bump is BACKLOG.md:134. After the owner pushes (83 commits at Phase 0 plus this session's 6): the push changes R/ and tests, which are not on the 21-entry paths-ignore list, so CI will run (unlike S902-S904); read the runs.
key_files: R/modPedigree.R:62-66 (help text), :207-208 (roxygen), :362-372 (the rule); R/isLivingAnimal.R:22; R/setPopulation.R:30 (unchanged, exported); tests/testthat/test_modPedigree_defaultPopulation.R:43 (runBrowser) and :82 (first block); tests/testthat/test_defaultPopulationWording.R:29 (helper pointer) and :35 (first block); tests/testthat/helper-pageText.R:14 (pageText); vignettes/articles/colony-manager-guide.qmd:322, :329-334, :478-488 (export chunk), :1202-1204; vignettes/manual_components/_pedigree_browser.Rmd:173; vignettes/manual_components/_genetic_value_analysis.Rmd:96; NEWS.Rmd:198; BACKLOG.md:65-82 (the pictures item); PROJECT_LEARNINGS.md:2607 (Learning 921).
gotchas: tests/testthat/test_guideExportTables.R:403 compares the guide's export chunk with the pedigree the module hands on, so it stays green at RED and fails only once the module changes: change the chunk in the same commit as the rule; a RED tally must print skipped beside failed (a vector passed as one pageText() path silently skipped 3 blocks); git grep -E has no \s, use [[:space:]] and test the pattern on a known match; the real-app harness is deterministic for one scenario (two default runs gave 267 / 60 / 5) and S954's 271 / 56 / 5 came from another driver, so compare inside one harness; the scratch app.R and driver went with the scratchpad, rebuild from Learnings 904 and 920 plus the capture script's steps (upload, minSireAge and minDamAge 2, dataInput-getData, #geneticValue-runAnalysis; the Genetic Value run takes about 4 s on 332 animals); a snapshot made with no focal animals now carries membership rule focalPopulation (R/modSnapshotTrends.R:176), left alone on purpose; run python3 context_budget.py after the last notes edit; the five worktrees and four old processes (runGeneKeepR pids 29511, 82416, 92900 and an until loop, pid 89205) were not re-checked and left alone.
runtime_smoke: the real app, headless (a scratch app.R that load_all()s the repo with the shared state exported, driven by shinytest2): with no focal animals the Pedigree Browser flags 332 animals, all ALIVE, and Genetic Value ranks those 332 (267 High / 60 Low / 5 Undetermined, run twice with identical results; the 332 typed in as focal gave 268 / 59 / 5); the Focal Animals panel shows the approved sentence and the picture was opened for the owner. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 585390fbcca7 · manifest aa983075d6a2
changelog_ref: S955 DONE entry
commit: the close-out commit that carries this receipt; claim 31837276e, RED a14103f25, GREEN 2e7cbcf7c and 5e2d460e6, REFACTOR d6b9a54ba
```

```handoff
session: S954
date: 2026-10-10
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- a decision session (owner pick at the Phase 0 picker, option 1 of 4; docs only, no R/ or test change): the owner ruled that with no focal animals entered the Pedigree Browser flags the living animals as the population, not all 3,694 (BACKLOG.md:65). The item is now a READY build (Effort M, strict TDD) with its Pre-RED list.
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI green on all 10 runs, dashboard 96/100 High+ risk 0, nothing over a context-budget ceiling). Claim 413abe6ac (S953 notes entry folded into the 947-953 block). Replayed S938's stored counts in the real app (a scratch app.R with exportTestValues plus a shinytest2 driver, outside the repo): 3,694 animals flagged and the status counts matched; ALIVE 55 / 272 / 5 against the stored 56 / 271 / 5 (random gene drop). Ran the second default (the 332 living entered as focal): 332 ranked, 271 / 56 / 5, 216 living animals Low to High, none the other way, median mean kinship 0.004 to 0.015. A grep of every non-comment use of the population flag found the column's on-screen name, the snapshot membership rule and the places that say living. One question with the side-by-side table; the owner chose "Living animals only (Recommended)". Close-out: BACKLOG.md:65-82 replaced by the READY build item (18 lines for 18, later cites unchanged), Learning 920, notes, this receipt, the ledger entry.
next_steps: Recommended order (not ruled on; BACKLOG.md cites checked after this edit). The build at BACKLOG.md:65 is READY: open with its Pre-RED gate (one question: a pedigree with no living animal; the other facts are in the item), then RED (a fixture with a status or exit column; test_modPedigree_processing.R:46 and :557 stay green on fixtures without one), GREEN in R/modPedigree.R:357-366 through isLivingAnimal() (R/isLivingAnimal.R:22), then the words (Focal Animals help R/modPedigree.R:62-66, the manual, the guide, NEWS.Rmd) and up to 12 guide pictures. Other owner findings: old-style boxes (BACKLOG.md:8, M), getAncestors() (BACKLOG.md:105, S). Optional, S: the hidden joint-effort comment (BACKLOG.md:84), budget HANDOFFS.md (BACKLOG.md:121), last-box label (BACKLOG.md:49), None of the 1 animals (BACKLOG.md:43), Warnings picture (BACKLOG.md:21), pop-up item (BACKLOG.md:30). After the owner pushes (81 commits at Phase 0 plus this session's 2), read the CI run: the last push-triggered run was S939's.
key_files: R/modPedigree.R:357-366 (the flag set from focalIds()); R/isLivingAnimal.R:22; R/setPopulation.R:30 (exported, stays); R/modSnapshotTrends.R:173-177 (snapshot membership rule); R/headerDisplayNames.R:30; BACKLOG.md:65-82 (the build item); tests/testthat/test_modPedigree_processing.R:46 and :557; vignettes/articles/colony-manager-guide.qmd:483 and :394-397; tests/testthat/test_guideExportTables.R:403; PROJECT_LEARNINGS.md:2604 (Learning 920).
gotchas: shared$geneticValues is the report data.frame itself, not a list with $report (a wrong exporter returns NULL and the run still reads clean; export names() first); the scratch app.R and driver lived in the session scratchpad and are gone, rebuild them from Learnings 904 and 920; a living-only Genetic Value run takes about 5 s against 45 s for the whole colony; every gene-drop count moves by an animal or two between runs, so write "to within the random gene drop"; the Breeding Groups floor figures (61, about 270) are S939's and S938's runs, not today's; the five leftover worktrees and four old processes (pids 29511, 82416, 92900, 89205, all still running at Phase 0) were left alone; keep SESSION_NOTES.md under about 56,700 B.
runtime_smoke: n/a -- docs-only decision session; the two real-app runs were the measurement, not a check of a change. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 5bdd2f1adfcf · manifest aa983075d6a2
changelog_ref: S954 DONE entry
commit: the close-out commit that carries this receipt; claim 413abe6ac
```

```handoff
session: S953
date: 2026-10-10
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the origin-and-funding wording S952 left (BACKLOG.md:84; owner pick at the Phase 0 picker, option 1 of 4; strict TDD, code change in R/appUI.R only; every gate asked and answered): the app's About tab, DESCRIPTION's two funder entries (and the generated package help page) and the outreach plan's three spots now limit the NIH grants to version 1.0 and earlier, in the sentences the owner approved with one yes/no question. At the owner's request mid-session, every tracked page was swept for the same limit; none other was found, and the sweep is now a test block. BACKLOG.md:84 removed as done and replaced by one optional item (the hidden "joint effort" comment).
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI green on all 10 runs, dashboard 96/100 High+ risk 0, nothing over a context-budget ceiling). Claim ed48bbaf9 (S952 notes entry folded into the 947-952 block). Measured the three places, put one proposed sentence per place in front of the owner, one question, answered "all three as written". RED 54acc0a30: 8 new blocks in tests/testthat/test_originFundingWording.R, 16 expectations failed, 0 errors (the 8 S952 blocks still passed); the sweep block listed 12 unscoped grant-number hits in 4 files. GREEN c5f9aca8b: R/appUI.R, DESCRIPTION, man/nprcgenekeepr-package.Rd (devtools::document(), only the two funder lines changed), the outreach plan. REFACTOR 9d02737ae: one shared expectWording() in the test file; same 36 expectations pass on HEAD and the same 8 blocks fail on the pre-GREEN tree. Verified: full suite 3,379 blocks 0 failed 0 errors (187 skipped, 6 warnings, unchanged); lint 0; devtools::check(document = FALSE) 0/0/0; real app driven to the About tab. Close-out: BACKLOG.md:84 replaced (20 lines kept, later cites unchanged), Learning 919, notes, this receipt, the ledger entry.
next_steps: Recommended order (not ruled on; BACKLOG.md cites re-grepped after this session's edit). Owner findings, each a short decision session: default population (BACKLOG.md:65, M), old-style boxes (BACKLOG.md:8, M), getAncestors() (BACKLOG.md:105, S). Optional, S: the hidden joint-effort comment in README.md and the manual introduction (BACKLOG.md:84, delete or keep), budget HANDOFFS.md in the context-budget hook (BACKLOG.md:121), the last-box label (BACKLOG.md:49), None of the 1 animals (BACKLOG.md:43), the Warnings picture (BACKLOG.md:21), the pop-up item (BACKLOG.md:30). Docs-audit part 2 is BACKLOG.md:235; the 3.0.0 bump is BACKLOG.md:134. After the owner pushes (76 commits at Phase 0 plus this session's 5), read the CI run: the last push-triggered run was S939's.
key_files: tests/testthat/test_originFundingWording.R:73 (expectWording), :122 (aboutPanelText), :146 (descriptionFunders), :184 (planText), :225 (livePages), :238 (the sweep block); R/appUI.R:323-328 (About tab); DESCRIPTION:14-17 (funders); man/nprcgenekeepr-package.Rd:36-37 (generated); docs/planning/nprc-outreach-announcement-plan.md:47-49, :426-428, :495-498; vignettes/manual_components/_introduction.Rmd:28-30 and README.md:43-47 (the hidden comment); BACKLOG.md:84 (the new optional item); PROJECT_LEARNINGS.md:2601 (Learning 919).
gotchas: the sweep block reads 611 live pages and wants "version 1.0" within 250 characters of every P51 RR13986 / P51 OD011092, with a floor of 9 files, so a new page that names the grants needs the scope sentence; the pages it skips are named in the test header with reasons; DESCRIPTION's funders are now person("<centre>", role = "fnd", comment = "NIH grant P51 ..., work up to and including version 1.0") and the package Rd is generated from them (devtools::document()); use git grep for sweeps, since plain grep -r also walks docs/archive and five leftover git worktrees under .claude/worktrees (git-excluded, registered with git worktree list; left alone, not offered as a session); a shinytest2 AppDriver needs NOT_CRAN=true and a navbarMenu tab is selected with app$set_inputs(mainNavbar = "About"), not by .tab('show') or a click; get_screenshot() will not overwrite a file; README.md is knitted from _introduction.Rmd (Learning 918); a new receipt goes directly above the newest one; keep SESSION_NOTES.md under about 56,700 B; four old processes from earlier sessions (runGeneKeepR pids 29511, 82416, 92900 and an until loop, pid 89205) were not re-checked and left alone.
runtime_smoke: the real app (a scratch app.R that load_all()s the repo, driven by shinytest2) shows the About tab's two new paragraphs exactly as approved and the picture was opened for the owner; the e2e About test that expects NIH on that tab (tests/testthat/test-e2e-settings-about.R:60) is opt-in and was not run, the pane text still contains NIH; quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 61d75bdcec35 · manifest aa983075d6a2
changelog_ref: S953 DONE entry
commit: the close-out commit that carries this receipt; claim ed48bbaf9, RED 54acc0a30, GREEN c5f9aca8b, REFACTOR 9d02737ae
```

```handoff
session: S952
date: 2026-10-09
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the owner's two wording changes (BACKLOG.md:84; owner pick at the Phase 0 picker, option 1 of 4; strict TDD, docs only; all three gates asked and answered, REFACTOR skipped at the owner's choice): "The primary goal of nprcgenekeepr" and "Work on this package up to and including version 1.0 was supported in part by NIH grants ..." in the guide, the engineering article, the manual introduction, README.md and the CLAUDE.md overview. BACKLOG.md:84 stays open, narrowed to what was not asked for.
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, CI green on all 10 runs, dashboard 96/100 High+ risk 0, nothing over a context-budget ceiling). Claim fa4d05053 (S951 notes entry condensed into the 947-951 block). My first question (four forks) was rejected and the owner wrote both sentences. RED 408997473: tests/testthat/test_originFundingWording.R, 8 blocks, 17 expectations failed, each a count mismatch. GREEN a4e259e4b: 5 files (guide goal once and grants twice, engineering article, manual introduction, README.md re-knitted from it against a scratch-installed HEAD, CLAUDE.md overview). Verified: 8 blocks pass; full suite 3,371 blocks 0 failed 0 errors; lint 0; devtools::check 0/0/0; guide renders with quarto (exit 0) with only the new sentences. Close-out: BACKLOG.md:84 narrowed (20 lines kept), Learning 918, notes, this receipt, the ledger entry.
next_steps: Recommended order (not ruled on; BACKLOG.md cites hold). The rest of the origin-and-funding item (BACKLOG.md:84: About tab R/appUI.R:323-324, DESCRIPTION funders, outreach plan): one proposed sentence per place, one question. Then owner findings: default population (BACKLOG.md:65, M), old-style boxes (BACKLOG.md:8, M), getAncestors() (BACKLOG.md:105). Optional, S: budget HANDOFFS.md in the context-budget hook (BACKLOG.md:121), the last-box label (BACKLOG.md:49), None of the 1 animals (BACKLOG.md:43), the Warnings picture (BACKLOG.md:21), the pop-up item (BACKLOG.md:30). Docs-audit part 2 is BACKLOG.md:235; the 3.0.0 bump is BACKLOG.md:134. After the owner pushes (72 commits at Phase 0 plus this session's 4), read the CI run: the last push-triggered run was S939's.
key_files: tests/testthat/test_originFundingWording.R:1 (the 8 blocks); vignettes/articles/colony-manager-guide.qmd:67 (goal), :86 and :1237 (grants); vignettes/manual_components/_introduction.Rmd:16 and :24 (the source README.md is knitted from); README.md:31 and :38; CLAUDE.md:21; vignettes/articles/engineering-the-2.0.0-release.qmd:794; BACKLOG.md:84 (the open remainder); PROJECT_LEARNINGS.md:2598 (Learning 918).
gotchas: README.md is knitted, so edit _introduction.Rmd and re-knit against a scratch-installed HEAD (R CMD INSTALL --no-docs --library=<scratch> ., then .libPaths(c(<scratch>, .libPaths())) before rmarkdown::render("README.Rmd")); the knit also moves two date lines (render date, installed build date in UTC); CLAUDE.md's Project Overview sits in the protected block, keep both markers; a new receipt goes directly above the newest one; keep SESSION_NOTES.md under about 56,700 B; four old processes left alone: runGeneKeepR pids 29511, 82416, 92900 and an until loop on scratchpad/s292, pid 89205.
runtime_smoke: the guide rendered with quarto from a scratch copy of vignettes/articles against a scratch-installed HEAD (exit 0) and its HTML text holds the new grant sentence twice and the new goal sentence once, with none of the old ones; README.md knitted from README.Rmd the same way; quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results e3c29753b4cd · manifest aa983075d6a2
changelog_ref: S952 DONE entry
commit: the close-out commit that carries this receipt; claim fa4d05053, RED 408997473, GREEN a4e259e4b
```

```handoff
session: S951
date: 2026-10-09
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- HANDOFFS.md trimmed, 264,486 B to 30,267 B (owner pick at the Phase 0 picker, option 1 of 4; docs and tooling only, no R/, test or man/ change, so no TDD phase applied). It had crossed the Read tool's 262,144 B whole-file refusal at S950's close-out and was the dashboard's only High+ risk, now 0.
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, S950's ratchet citation matched the results file, CI green on all 10 runs, dashboard 96/100 with High+ risk 1 = HANDOFFS.md over the read limit; context budget: one over-long notes line, gone with the claim's condensing). Claim 4fb0727f9 (S950 notes entry condensed to fit the stub). Dry-ran three cuts, then ran methodology_trim.py --file HANDOFFS.md --budget-bytes 65536 --write with the default cut (no --force: the dry run printed no SRF refusal): 43 receipts (S905-S947) archived to docs/archive/HANDOFFS-through-2026-10-08.md, 4 kept (S948-S951); its verify script passes (47 = 4 + 43, 0 added); trim commit ff66b2703. Close-out: Learning 917, an optional BACKLOG.md item (:121) to budget HANDOFFS.md in the context-budget hook, notes (S939-S941 condensed into one record), this receipt, the ledger entry.
next_steps: Recommended order (not ruled on; cites re-grepped after this session's BACKLOG.md insert). Owner findings, each a short decision session: origin-and-funding wording (BACKLOG.md:84), then larger: default population (BACKLOG.md:65, M), old-style boxes (BACKLOG.md:8, M), getAncestors() (BACKLOG.md:105). Optional, S: budget HANDOFFS.md in the context-budget hook (BACKLOG.md:121; two ceilings to choose), the app's last-box label (BACKLOG.md:49), None of the 1 animals (BACKLOG.md:43), the Warnings picture (BACKLOG.md:21), the pop-up item (BACKLOG.md:30). The docs-audit item (BACKLOG.md:142) holds only part 2 (BACKLOG.md:235); the 3.0.0 bump is BACKLOG.md:134. After the owner pushes (69 commits at Phase 0 plus this session's 3), read the CI run: the last push-triggered run was S939's.
key_files: HANDOFFS.md:199 (this receipt, newest first; the file is 30 KB and opens whole); docs/archive/HANDOFFS-through-2026-10-08.md:1 (the shard, 43 receipts) and docs/archive/HANDOFFS-through-2026-10-08.md.verify.sh:1 (the proof); BACKLOG.md:121 (the optional budget item); .context-budget.json:1 (the files list that item would extend); PROJECT_LEARNINGS.md:2595 (Learning 917).
gotchas: the trimmer neither stages nor commits (git add HANDOFFS.md, CHANGELOG.md, the shard and its verify script, four files); the next HANDOFFS.md trim is due near the trimmer's 196,608 B line, about 36 sessions out (an estimate from 4.6 KB receipts), and nothing but the dashboard watches it until BACKLOG.md:121 is done, so run the dashboard after a close-out that adds a receipt; a new receipt still goes directly above the newest one; parse dashboard.html with python3 -I and re, not ugrep (complexity error); four old processes were left alone: runGeneKeepR pids 29511, 82416, 92900 and an until loop on scratchpad/s292, pid 89205; keep SESSION_NOTES.md under about 56,700 B (56,612 B now).
runtime_smoke: n/a -- docs-only. The shard verify script prints OK for L1, L2 and L3; test_handoffsReceiptPlacement.R (7 blocks) and test_workflowPathsIgnore.R (11 blocks) pass, 0 failed 0 errors; the dashboard now reads High+ risk 0 and 96/100; quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 7240a9f73000 · manifest aa983075d6a2
changelog_ref: S951 DONE entry
commit: the close-out commit that carries this receipt; claim 4fb0727f9, trim ff66b2703
```

```handoff
session: S950
date: 2026-10-09
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the guide's two Breeding Groups statements now match the app (BACKLOG.md:43; owner pick at the Phase 0 picker, option 1 of 4; the owner ruled "fix the guide's words" for both; strict TDD, all three gates asked and answered; the REFACTOR was skipped at the owner's choice).
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, S949's ratchet citation matched the results file, CI green on all 10 runs, dashboard 96/100, nothing over a context-budget ceiling). Claim 5c0163714 (S949 notes entry condensed to fit the stub). Read the code, the three committed pictures, the user manual and the roxygen first: the Group Detail kinship table shows whether or not the box is checked (the manual and the roxygen already said so; the box only decides whether the module returns groupKinship); the second caption's "same 6-group run" was a re-formed run (candidate-table scores 2,1,1,1,1 against 2,2,2,2,1); the first picture shows "Group 7 (4 animals)", four males, for 6 groups asked. RED e6032b2a8 (new test_guideBreedingGroupsWording.R, 11 blocks: 6 red, 5 green by design; a scratch copy of the guide with the new words passes 11 of 11). GREEN 7cb5a69c0 (colony-manager-guide.qmd only: the kinship paragraph, both Group Detail captions and alt texts, the sex-ratio paragraph and alt text, a new paragraph after that picture). Close-out: BACKLOG item removed and an optional item added (the app's "Group N" label, BACKLOG.md:49), the docs-audit item's pointer reworded, Learning 916, notes, ledger.
next_steps: Recommended order (not ruled on; cites re-grepped after this session's edit). Owner findings, each a short decision session: origin-and-funding wording (BACKLOG.md:84), then larger: default population (:65, M), old-style boxes (:8, M), getAncestors() (:105). Optional, S: the app's last-box label (:49), "None of the 1 animals" (:43), the Warnings picture (:21), the pop-up item (:30). The docs-audit item (:129) holds only part 2 (:222). After the owner pushes (68 commits ahead with this close-out commit), read the CI run and open the published guide to confirm the Breeding Groups words and pictures.
key_files: vignettes/articles/colony-manager-guide.qmd:614-660 (the changed words and the new paragraph); tests/testthat/test_guideBreedingGroupsWording.R (the 11 blocks; bgWordingPed() and runBgWording() are the fixture); R/modBreedingGroups.R:984-986 (Groups heading), :1009-1025 (Statistics), :1041-1051 (selector), :1066-1085 (kinship view); vignettes/manual_components/_breeding_group_formation.Rmd:131-137; BACKLOG.md:49; PROJECT_LEARNINGS.md Learning 916.
gotchas: a Breeding Groups test pedigree needs an age column (the Input tab's QC adds one), or every pairwise kinship is ignored and no animal is left over; to read a module's selector choices under testServer() mock updateSelectInput with testthat::local_mocked_bindings(.package = "nprcgenekeepr"); a quarto render of the guide needs the package installed (install a git archive of HEAD into a scratch library from the repo directory, then R_LIBS="<scratch lib>:<renv lib>"; --no-execute still runs inline R; the page has curly quotes); grep a wait sentinel unanchored and run ps before telling the owner why something is slow (my wait loop ran 5 h 41 m on a sentinel that never matched; my ps | grep -v grep check hid it because the loop's own command contains the word grep, and the owner's /exit prompt found it; use pgrep -f or a bracketed pattern instead); the shell's working directory slipped twice after a cd, so use absolute paths; three old runGeneKeepR processes (pids 29511, 82416, 92900) are not from any recent session and were left alone; SESSION_NOTES.md must stay under about 56,700 B.
runtime_smoke: the edited guide rendered with quarto (HEAD installed into a scratch library, exit 0) and the HTML holds every new sentence and none of the old ones ("produced 7 groups", "no kinship shown", "same 6-group run", "was checked before forming" all absent); the app's behavior the words describe is pinned by 5 blocks run in testServer, not a hand check in Chrome. Full suite 3,363 blocks 0 failed 0 errors (187 skipped, 6 warnings) at load 3.8 to 7.0; package lint 0; devtools::check(document = FALSE) 0 errors 0 warnings 0 notes; quality_ratchet: 1/1 pass, 0 fail, 0 unmeasured, results 31eb1a07330f, manifest aa983075d6a2. Six mutants of R/modBreedingGroups.R each turn 1 to 4 blocks red (file restored byte-identical). Published pages not opened (commits unpushed).
changelog_ref: S950 DONE entry
commit: the close-out commit that carries this receipt; claim 5c0163714
```

```handoff
session: S949
date: 2026-10-09
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the Diagram article's edge-style section shows a Direct picture instead of a second copy of the Rectilinear one (BACKLOG.md:30; owner pick at the Phase 0 picker, option 1 of 4; the owner ruled "show Direct instead"; strict TDD, all three gates asked and answered yes).
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, S948's ratchet citation matched the results file, CI green on all 10 runs, dashboard 96/100, nothing over a context-budget ceiling). Claim 5e306e1d2 (S948 notes entry condensed to fit the stub). Measured first: diagram_rectilinear_edge_style.png and pb_diagram_legend.png are byte-identical (cmp; md5 cda44efa55b4f402db79cf55f518ad6a), because the app opens on Rectilinear and the script's step changed nothing. RED 330c8f686 (9 new blocks in test_captureHarness.R, 8 red, 1 green by design; 42 older blocks pass). GREEN d692e2cc1 (the script's step types direct and shoots diagram_direct_edge_style.png; pedigree-diagram.qmd captions it and points to the first picture as the Rectilinear default; the duplicate file is removed; the diagram script ran 18/18 into a scratch folder and only the Direct picture was copied; one test bug found and fixed in GREEN, said in the commit). REFACTOR 441245b40 (test helper typedValues() shared by viewGrpValues() and edgeStyleValues(); identical output on three scripts). Close-out: BACKLOG.md item removed and the docs-audit item's leftovers sentence updated, Learning 915, notes, ledger.
next_steps: Recommended order (not ruled on; lines re-grepped after this session's removal). Owner findings, each a short decision session: the Breeding Groups statements (BACKLOG.md:43; the READY (optional) None of the 1 animals wording, :62, can ride along). Larger: default population (:68, M), old-style boxes (:8, M), origin-and-funding wording (:87), getAncestors() (:108). The docs-audit item (:132) holds only part 2 (:224). After the owner pushes (63 commits ahead of origin before this close-out commit, 64 with it), read the CI run and open the published Diagram article to confirm the Direct picture loads.
key_files: vignettes/articles/pedigree-diagram-screenshots.R:148-155 (the Direct step and shot); vignettes/articles/pedigree-diagram.qmd:58-78 (the section); vignettes/articles/shiny_app_use/diagram_direct_edge_style.png; tests/testthat/test_captureHarness.R:425-433 (typedValues), :591-710 (the 9 blocks); PROJECT_LEARNINGS.md Learning 915.
gotchas: a guarded assertion in a RED test is unrun until GREEN (run its body once against made-up passing text before the RED commit); blockContaining() finds only column-0 do_step( and shot( calls and the diagram script indents its shots; this run's first picture (pb_diagram_legend.png) differs from the committed one by 15,533 of 2,007,870 pixels (legend panel about 38 px left), so view any retake of it beside the old one first; the edges of the Direct picture were not traced against the data; put R code with a backslash-s in a script file, never inline Rscript -e; three old runGeneKeepR processes (pids 29511, 82416, 92900) are not from any recent session and were left alone; SESSION_NOTES.md must stay under about 56,700 B (56,567 B now).
runtime_smoke: real app, headless: the diagram capture script ran 18/18 steps into a scratch folder (log has no did-not-update warning); the new picture shows the Direct radio on, sloped connectors, the same 21 animals and layout; the first picture shows Rectilinear on, as the article now says; both opened for the owner. Full suite 3,352 blocks 0 failed 0 errors (187 skipped) at load about 4; package lint 0; devtools::check(document = FALSE) Status OK, 0 errors 0 warnings 0 notes; quality_ratchet: 1/1 pass, 0 fail, 0 unmeasured, results 06a8a0a755ce, manifest aa983075d6a2. Not a hand check in Chrome; published pages not opened (commits unpushed).
changelog_ref: S949 DONE entry
commit: the close-out commit that carries this receipt; claim 5e306e1d2
```

```handoff
session: S948
date: 2026-10-08
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the Candidate Parent Assignment tab says why its table is blank when the pedigree has no fromCenter column (BACKLOG.md:57; owner pick at the Phase 0 picker, option 1 of 4; the owner ruled add the one-line reason, as one sentence shared with the Potential Parents tab; strict TDD, all three gates asked and answered yes).
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, S947's ratchet citation matched the results file, CI green on all 10 runs, dashboard 96/100, both sequencing audits fully executed). Claim 60def83ed (S947 notes entry condensed to fit the stub). Read the code first: the Candidate table is blank for four causes (no genotype file, nothing flagged, no fromCenter column, no eligible candidate); the owner chose the missing-column notice only. RED b660db5d9 (17 new blocks: test_fromCenterNotice.R 4, test_modMarkerGenetics.R 10, test_modPotentialParents.R 3; 15 red, 2 green by design; two test bugs of mine fixed before the commit: a pane-name regex that missed newlines and sentence text broken across lines by htmltools). GREEN c58cd2ac7 (R/fromCenterNotice.R; output$candidateNotice and its slot in R/modMarkerGenetics.R; R/modPotentialParents.R:304 calls the helper). REFACTOR 0e4ebcba4 (roxygen sentence, man/modMarkerGeneticsServer.Rd). Docs 1f8a9eced (guide note, NEWS line). Real app, headless: notice shown with the column missing (with and without a genotype file), absent with it; the guide's Candidate picture is pixel-identical to the app's output (0 of 740,410), none retaken. Four mutants of the new render each turn the matching blocks red (4, 6, 1, 1). Guide note (colony-manager-guide.qmd:914), NEWS line (NEWS.Rmd:138, NEWS.md re-knit), BACKLOG item removed (54,981 to 53,854 B; the docs-audit item's pointer to it reworded), Learning 914. Verified: three touched files 125 blocks 0 failed; lint 0; spelling 0; NEWS, wordlist, guide and marker-picture guards pass; quality_ratchet: 1/1 pass, 0 fail, 0 unmeasured, results 2e43edea9612, manifest aa983075d6a2. NOT CLEAN: the full suite (3,343 blocks, 0 errors, 187 skipped, 6 warnings) and devtools::check() (0 warnings, 0 notes) each show 2 failed blocks, the wall-clock benchmarks test_markerKinship.R:177 and test_markerParentageLikelihood.R:647 (0.34 s against 0.1 s; 1.9 s against 0.5 s) at a desktop load of about 10; the same two fail at the pre-change commit 597cc727e (git archive export) and alone; I could not get a quiet-machine read here.
next_steps: Recommended order (not ruled on; lines re-grepped after this session's removal). Owner findings, each a short decision session: the Diagram article's missing Direct picture (BACKLOG.md:30), the Breeding Groups statements (:57). Larger: default population (:82, M), old-style boxes (:8, M), origin-and-funding wording (:101), getAncestors() (:122). The docs-audit item (:146) holds only part 2 (:237). After the owner pushes (58 commits ahead of origin before this close-out commit, 59 with it), read the CI run: the two benchmark blocks should pass on a quiet runner; if they do not, that is a finding about the benchmarks, not this change. Also open the published guide and confirm the Genetic Value, Summary Statistics and Marker pictures load.
key_files: R/fromCenterNotice.R:13 (the one sentence); R/modMarkerGenetics.R:225 (the notice slot), :1019-1028 (the render), :396-398 (roxygen); R/modPotentialParents.R:304 (takes the sentence from the helper); tests/testthat/test_fromCenterNotice.R (4 blocks); tests/testthat/test_modMarkerGenetics.R:1732 (the 10 new blocks, from the RED (S948 comment); tests/testthat/test_modPotentialParents.R:164-251 (3 blocks); vignettes/articles/colony-manager-guide.qmd:914; NEWS.Rmd:138; PROJECT_LEARNINGS.md Learning 914.
gotchas: a mutation script run with Rscript must restore the file in tryCatch(finally =), not on.exit() (it never runs at the top level; the last mutant stayed in R/modMarkerGenetics.R until the file-change notice); htmltools breaks a multi-argument div() across lines, so tests of shown text collapse whitespace; to run an old commit's tests, git archive it to scratch and setwd() into it from the MAIN repo's R session (the export has no renv library); the benchmark blocks fail whenever the desktop is loaded (uptime about 10 here), so compare with the previous commit before reading a failure; the Candidate table's other two blanks (nothing flagged, no eligible candidate) stay unexplained by the owner's choice, do not re-offer them as a new item; three stale runGeneKeepR R processes (pids 29511, 92900, 82416) are not from this session and were left alone; SESSION_NOTES.md must stay under about 56,700 B.
runtime_smoke: real app, headless (a scratch shinytest2 script outside the repo, built from the guide's marker capture script, 11 of 11 steps): the notice shows above the blank table with the column removed, before and after a genotype upload; with the column there is no notice and the row C / sire / Q shows; pictures opened for the owner. Not a hand check in Chrome; published pages not opened (commits unpushed).
changelog_ref: S948 DONE entry
commit: the close-out commit that carries this receipt; claim 60def83ed
```

