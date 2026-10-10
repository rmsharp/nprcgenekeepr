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

