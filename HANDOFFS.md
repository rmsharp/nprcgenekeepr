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

This file gains a receipt every session and Phase 0 reads it every session, so it carries the same
size discipline as `CHANGELOG.md`: **two caps, two distinct failure modes, fire if either fires,
stop only when both stop conditions hold.**

| Cap | Protects against | Form | Fire when | Cut until |
|---|---|---|---|---|
| **Lines** — ~2,000, the agent `Read` truncation cap | **silent truncation**: a read past the cap returns no error and no marker | a **rate** | headroom < **15** receipts | headroom > **30** |
| **Bytes** — a per-file budget, default **65,536 B** (64 KB) | **context tax**: every session pays for the whole file, every time | a **level with hysteresis** | `size > budget` | `size ≤ ½ × budget` |

**Run this rather than estimating it:**

```sh
python3 methodology_trim.py --file HANDOFFS.md --check
```

`--check` evaluates both conditions and never writes. `--write` performs the trim, refuses unless it
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
  docs/archive/HANDOFFS-*.md` — or it silently counts a shrunken population.

If a `CHANGELOG.md` sits beside this file, its own **Size, and when to archive** section carries the
reasoning both files share: why the line cap must be a rate, why the byte cap cannot be one, and how
to choose the budget. Everything needed to *act* is here.

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

This file currently holds **2** receipt(s). Computed by `methodology_trim.py` on every
`--check`/`--write` run, never hand-maintained.

**Archived 116 record(s), 2026-08-14 → 2026-09-17** into [`docs/archive/HANDOFFS-through-2026-09-17.md`](docs/archive/HANDOFFS-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 13 record(s), 2026-09-17 → 2026-09-18** into [`docs/archive/HANDOFFS-through-2026-09-18.md`](docs/archive/HANDOFFS-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

```handoff
session: S711
date: 2026-09-18
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Owner-directed push to origin/master (S710 next-step A, owner-picked via AskUserQuestion at Phase 0): 34 commits pushed (955f6f19..afd33514), spanning S708 MHC Slice 4, the S709 export-preview crash fix, and the S710 ledger archive pass. All 4 on-push CI workflows green on afd33514 -- lint 5m43s, test-coverage 9m58s, pkgdown 16m52s, R-CMD-check 33m22s (runs 35386636842/857/853/874), watched to completion in-session and confirmed directly. Process/ops action, no code changes, no TDD phases.
what_was_done: Phase 0 backfill 83618479 (1 commit, 0f7f94fe -- the predicted self-reconcile shape, measured exactly 1); claim afd33514 written BEFORE the push so the pushed head carries the session's own breadcrumb. Push executed, background watcher polled to matrix completion, conclusions re-verified via gh run list before recording. Close-out records committed and pushed immediately after (second push; its CI round is next Phase 0's to verify, per the S706 precedent). Nothing removed from BACKLOG.md (the push was a handoff next-step, not a BACKLOG block); no new learning appended (routine session, no signal -- stated explicitly, not silently). FM 28 reduction check: nothing to trim, all three ledgers remain sparse from S710's cuts.
next_steps: (A) Census class (d) (READY, S): render the 2 duplicate-adjacent sites and judge acceptability. (B) Census class (b) (READY, M): decide the census-predicate tolerance for the 2 noise rows, then assess whether the 6 real 60-180 px union-dot offsets are minSep-forced or QP-reducible (R/makePedigreeDiagramData.R, .solveJointQP()); re-verify the coupled fidelity-article prose. (C) Census curved-chord (READY, M): arc-modelling measurement pass replacing the 1,668-chord upper bound. (D) MHC polish (Housekeeping, S). (E) Owner decisions pending: package-split disposition, pointer-block sweep ratification, REUSE registration. (F) Informational: dashboard copy stale (v2.14.0 vs v2.18.0); R/appServer.R:168 re-throw observer reported-not-changed; untracked leftovers unchanged; LabKey remainder BLOCKED.
key_files: HANDOFFS.md:146 (this receipt), CHANGELOG.md:29 (S711 entries), docs/archive/SESSION_NOTES-through-2026-09-18.md:1 (S709 gotchas, still applicable), BACKLOG.md:109 (census class b), BACKLOG.md:128 (curved-chord), BACKLOG.md:142 (census class d)
gotchas: (1) Fresh baseline still 2,434 blocks (failed=0, error=0, skipped=184, warning=48) -- neither S710 nor S711 touched package files; S709's gotchas apply verbatim, read them in docs/archive/SESSION_NOTES-through-2026-09-18.md. (2) The close-out push triggers one more CI round on the records/self-reconcile head -- expect completed success at Phase 0's gh run list; if red, that is NEW information (docs-only delta), report-don't-fix per the standing convention. (3) Expect ~1 self-reference commit past the CHANGELOG frontier at next Phase 0 (the recurring shape); measure it. (4) origin/master is now in sync -- the long-running "N commits ahead" informational item is gone; don't re-report it from stale handoffs.
runtime_smoke: n/a -- docs-only local changes; the deliverable's own verification IS the CI matrix on real runners (R CMD check, lint, coverage, pkgdown all green on the pushed head afd33514)
changelog_ref: pending
commit: pending
```
Self-score 9/10: + claim-before-push left the pushed head self-describing (a crash mid-watch would still have left origin carrying the session claim); + waited for the full matrix and re-verified the watcher's claim directly before recording it; + clean precedent-following scope, no package files touched, no scope creep. - The close-out push's own CI round is deliberately unwatched (S706 precedent, docs-only delta on a just-verified tree) -- a defensible but real open loop handed to the next Phase 0; - a routine session yields no learning row, correct but worth stating. Predecessor 9/10: next-step A was the exact deliverable -- the ~32 recount measured 32 exactly, the span description and clean-state assurance made the decision presentable with zero re-derivation, and gotcha 5's 1-commit backfill shape measured exactly 1; nothing material missing for this scope; nothing wrong found.

```handoff
session: S710
date: 2026-09-18
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Ledger archive pass (S709 next-step A, owner-picked): all three ledger byte triggers were firing and all three now clear with wide headroom -- SESSION_NOTES.md 87,984 -> 4,771 B (19 records), HANDOFFS.md 78,503 -> 16,481 B (13 receipts), CHANGELOG.md 68,117 -> 9,471 B (40 records), each into its own docs/archive/*-through-2026-09-18.md shard, L1/L2/L3 verified by each shard's verify.sh. Docs-only maintenance; no package files touched.
what_was_done: Phase 0 backfill 7ab986e2 (1 commit, 710fea78 -- the predicted self-reconcile shape, measured exactly 1); claim 852b5292. Cut-boundary discovery: the default cut on every file collided with the existing -through-2026-09-17 shards (S704-S708 all share that date), so legal retained counts were probed with dry-run --cut N -- SESSION_NOTES only >=15 or <=2, HANDOFFS only <=2, CHANGELOG only <=8 (Learning 761). Trims committed one file per commit, largest non-colliding retention satisfying both stop conditions: SESSION_NOTES retain 2 (7fbe17b7), HANDOFFS retain 2 -- the pending S710 stub + S709's complete receipt, never zero (3dbe15f3), CHANGELOG retain 8, trimmed LAST so the two earlier trim-injected P1A entries landed before its cut (447f2beb). No --force needed anywhere: the Learning 549/586/594 SRF refusals never fired (large post-2026-09-17-archive denominators). Receipt-count sentence regenerated to 2 by the tool. Learning 761 appended; records commit follows this receipt.
next_steps: (A) Push decision (owner call): ~32 commits ahead after close-out (recount with git rev-list --count origin/master..HEAD); span includes S708 MHC Slice 4, the S709 crash fix, and this archive pass; no package files touched since the S709-verified clean state. (B) Census class (d) S, class (b) M, curved-chord M -- unchanged. (C) MHC polish (Housekeeping, S). (D) Informational: package-split disposition pending; dashboard copy stale; untracked leftovers unchanged; R/appServer.R:168's deliberate re-throw observer reported-not-changed (S709 next-step E).
key_files: docs/archive/SESSION_NOTES-through-2026-09-18.md:1 (S709's full handoff lives here now), docs/archive/HANDOFFS-through-2026-09-18.md:1 (S696-S708 receipts), docs/archive/CHANGELOG-through-2026-09-18.md:1 (S697-S708 ledger records), PROJECT_LEARNINGS.md:2217 (Learning 761), HANDOFFS.md:135 (regenerated receipt-count sentence)
gotchas: (1) Baseline still 2,434 blocks (failed=0, error=0, skipped=184, warning=48) -- no package files touched; S709's gotchas still apply verbatim, read them in docs/archive/SESSION_NOTES-through-2026-09-18.md. (2) The live ledgers are deliberately sparse now -- older context is one hop away via the front-matter shard pointers; sparseness is not a ghost session. (3) The NEXT archive pass hits the same SHARD_EXISTS collision on the 2026-09-18 boundary -- probe legal cuts with dry-run --cut N first (Learning 761). (4) Every methodology_trim.py --write injects its own entry into CHANGELOG.md -- trim CHANGELOG last in any multi-file pass. (5) Expect ~1 self-reference commit past the CHANGELOG frontier at next Phase 0; measure it.
runtime_smoke: n/a -- docs-only (ledger files and docs/archive shards; zero R/, tests/, man/, vignettes/ changes)
changelog_ref: a6b26716
commit: a6b26716
```
Self-score 9/10: + dry-run probes before every write meant no rollback was ever needed; + CHANGELOG trimmed last so the tool's own injected entries stayed inside the trimmed budget; + every shard verified via its own verify.sh before its commit, and a final --check on all three files confirms no trigger fires. - The deep SESSION_NOTES cut archived S709's handoff record mid-session (before this handoff existed), briefly leaving the live ACTIVE TASK stub-only -- lossless but a crash in that window would have cost the next session an archive hop; - pre-announced an owner --force gate the evidence never required. Predecessor 9/10: next-step A was the exact deliverable with measured sizes and the "measure CHANGELOG first" instruction that proved out; the shard-name collision constraint -- the pass's dominant obstacle -- was unflagged (discoverable only by doing); the predicted SRF refusals never fired (labeled expectation, zero cost).

```handoff
session: S709
date: 2026-09-18
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Export-preview session-crash fix (top BACKLOG Up Next item, found S708): the LD-block, sequence, and MHC export-preview observers in R/modMarkerGenetics.R read every upstream reactive through safeRead() + req(); the sequence observer ports the MHC Dragon 5 missing-id pre-check (sequenceExportMissingIds -- build nothing, say why); the three guidance renderUIs name the could-not-be-processed state; the eager E2E data-ready observe() (a second, unknown, NO-CLICK crash the RED tests exposed) is defused too. Strict TDD, every gate owner-approved via AskUserQuestion.
what_was_done: Phase 0 backfill 148cccaa (1 commit, cc540bf3); claim cf97540e. PRE-RED probes: sequence missing-id crash reachable; LD missing-id crash structurally unreachable (markerLdBlock subsets to founderIds, R/markerLdBlock.R:236 -- owner re-ratified defusal-only); testServer DESTROYS the module session on an observer error so survival is directly assertable (Learning 759, refining 758). Fresh baseline before any test: 2,427/0/0/183/42 (S708 exactly). RED cd63250c: 6 testServer blocks + 1 live E2E in the already-registered ROH E2E file; 5 blocks fail via shiny.destroyed.error, guard passes by design, E2E reproduces the live disconnect on the real tab (isConnected FALSE). GREEN 310c731d (R/modMarkerGenetics.R only): the RED malformed-upload block dying at UPLOAD time exposed the eager data-ready observe({req(comparison())}) as a real no-click crash, fixed with req(safeRead(comparison)); target file 66/66; both live E2E tests green (Phase 3E); lint 0. NEWS 76807b2a + spell-check reword 61c544a3. Full suite once on final source: 2,434 = 2,427 + the 7 new; failed=3 all triaged (2 wall-clock benchmarks = CPU contention from running lint/render beside the suite, both files green on quiet re-run, Learning 760; 1 spelling fixed, re-run green); warnings 42->48 = the i152 fixture's documented markerKinship NA warnings x 3 new instances. devtools::check 0 errors, 1 W + 1 N = the known untracked-local-file artifacts. BACKLOG item removed; Learnings 759/760 appended; records commit follows this receipt.
next_steps: (A) Archive pass (READY, S): HANDOFFS.md (72,242 B) and SESSION_NOTES.md (77,442 B) byte triggers BOTH firing; CHANGELOG.md was 62,816 B before this close-out -- measure; expect SRF small-denominator refusals needing an owner --force (Learnings 549/586/594). (B) Census class (d) S, class (b) M, curved-chord M -- unchanged. (C) Push decision (owner call): ~25 commits ahead after close-out (recount with git rev-list --count origin/master..HEAD); local suite + check clean apart from the untracked-file artifacts. (D) MHC polish (Housekeeping, S). (E) Informational: R/appServer.R:168's observe re-throws cleanedStudbook errors by DELIBERATE design comment -- same crash class as Learning 758, reported not changed, owner's call; package-split disposition pending; dashboard copy stale; untracked leftovers unchanged.
key_files: R/modMarkerGenetics.R:740 (LD observer), R/modMarkerGenetics.R:816 (sequence observer + pre-check), R/modMarkerGenetics.R:807 (sequenceExportMissingIds), R/modMarkerGenetics.R:929 (MHC observer), R/modMarkerGenetics.R:1261 (fixed data-ready observe), R/modMarkerGenetics.R:1036 + :1075 + :1182 (guidance renderUIs), tests/testthat/test_modMarkerGenetics.R:1554 (S709 section), tests/testthat/test-e2e-marker-genetics-genomic-roh-module.R:192 (disconnect E2E), PROJECT_LEARNINGS.md tail (Learnings 759/760), NEWS.Rmd:374 (General Fixes entry)
gotchas: (1) Fresh baseline now 2,434 blocks (failed=0, error=0, skipped=184, warning=48); skipped +1 = new opt-in E2E; warnings +6 = documented fixture warnings, not a regression. (2) Never run heavy jobs beside the full suite -- the 2 wall-clock benchmark files fail under CPU contention; re-run alone before treating as a regression (Learning 760). (3) Observer-crash tests assert session survival directly: click, then read any module state -- shiny.destroyed.error is the honest RED signal; req(x()) does NOT guard against x() erroring (Learning 759). (4) devtools::check keeps 1 W + 1 N from the untracked local files; CI never sees them. (5) Expect ~1 self-reference commit past the CHANGELOG frontier at next Phase 0; measure it. (6) Both ROH E2E tests share makeGenomicRohE2ePedigreeFile(dropIds=); the partial variant writes a different filename so the fixtures cannot clobber each other.
runtime_smoke: live shinytest2 E2E in headless Chrome, both tests: the pre-existing full export flow (8 assertions, upload -> preview -> confirm -> unlock) unchanged, and the new disconnect check -- pedigree missing S050, Generate Preview clicked, Shiny.shinyapp.isConnected() TRUE, guidance names "1 animal ... not in the loaded pedigree"
changelog_ref: 33b0a556
commit: 33b0a556
```
Self-score 9/10: + PRE-RED probes overturned two load-bearing brief assumptions (LD unreachability; destroyed-session observability) before any test existed; + the RED honest-failure discipline surfaced a second real no-click crash the brief didn't know about; + user-boundary runtime verification (live disconnect reproduced pre-fix, survival proved post-fix); - ran lint/render beside the single full-suite launch, causing 2 spurious benchmark failures and a re-triage cycle (Learning 760); - the NEWS spell-check flag surfaced only in the full suite; - the mid-GREEN data-ready-observer fix was decided solo (disclosed in commit + gate, but a mid-session owner flag would have been cleaner). Predecessor 9/10: complete brief with the fix-pattern pointer and the E2E suggestion that became the key test; the "guidance text is the ONLY observable" claim understated the destroyed-session surface, and the eager data-ready observer wasn't flagged; "port to BOTH observers" was evidence-retired for LD.

