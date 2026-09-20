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

```handoff
session: S735
date: 2026-09-20
status: complete
self_score: 9
predecessor_score: 9
active_task: Owner-directed push to origin/master + CI verification DONE — pushed 75d2b049..3b29f498 (3 commits: the 2 unpushed S734 close-out commits — records be4f41ce, sha 12218ad2 — + the S735 claim 3b29f498 riding the push, S726/S729/S731/S733/S734 precedent), all 4 push-triggered workflows completed success ON THE PUSHED SHA 3b29f498 (verified via gh run list --commit, sha match structural): lint 5m14s (35539906766), pkgdown 6m04s (35539906763), test-coverage 9m51s (35539906801), R-CMD-check 21m28s (35539906788) — post-S732-fix ~21–22 min figure confirmed a third consecutive time, single 30-min Monitor arm, no re-arm. No TDD phases; lint N/A.
what_was_done: Claim 3b29f498 (rode the push so CI ran on it; owner directed the push in the same conversation immediately after the S734 report). Abbreviated re-orient (state minutes old): git state, unpushed count (2 = S734's estimate exactly), both ledger frontiers re-measured (0 undocumented); full 8-step orient not repeated — a named deviation, defensible same-conversation, not hidden. Push left origin/master fully current (0 unpushed). CI verification via Monitor polling gh run list --commit 3b29f498 at 60 s emitting every terminal conclusion; all 4 green in 21m28s wall. No BACKLOG item consumed.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~2 expected after close-out: records + sha; both docs-only, estimated at write time; no urgency, CI current through 3b29f498). (B) Priorities unchanged: pedigree-growth measurement (READY, S, BACKLOG.md:117); package-split disposition + REUSE registration (owner decisions); BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M, BACKLOG.md:100). (C) Standing report-only set unchanged from S734, incl. the two context-budget signals (growth run; synced-files differ-from-canonical).
key_files: CHANGELOG.md:41 (S735 entries at top), SESSION_NOTES.md:39 (S735 handoff), BACKLOG.md:117 (next natural pickup)
gotchas: Expect 0 undocumented commits at next Phase 0 — measure it; ~2 unpushed after close-out (estimate). R-CMD-check 21m28s on 3b29f498 — the ~21–22 min figure confirmed three times running; one 30-min Monitor arm suffices. SESSION_RUNNER.md/SAFEGUARDS.md differs-from-canonical flags remain NOT local edits — don't re-sync reflexively; a fork-main sync is its own session with the methodology_trim.py patch procedure (CLAUDE.md checklist). Standing set unchanged: scratchpad/ invisible to git BY OWNER DECISION; quality_ratchet.py --run ~2 min, AFTER committing (Learning 772); methodology_trim.py needs --budget-bytes 65536; renv Rscript banner expected; CLAUDE.md warn band; SESSION_NOTES.md's two ceilings differ (owner decision pending); suite baseline 2437/0/0/184/0 remote-confirmed again by R-CMD-check on 3b29f498.
runtime_smoke: n/a — push + docs only (no runtime behavior changed); the deliverable's verification surface is CI itself, 4/4 green on the pushed sha. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 0c58d203ae28 · manifest aa983075d6a2 (measured 3,483,951 B at 3b29f498)
changelog_ref: 3b29f498
commit: pending-records-commit
```
<free-text: S735 +/- — plus: exact-sha verification with run ids and durations recorded; same-conversation pickup re-measured mechanically (state, frontiers) rather than assumed; full claim/receipt/ledger discipline kept for a 2-commit push; scope held. Minus: Phase 0 abbreviated (dashboard/issues/SAFEGUARDS re-read not repeated minutes after a full orient) — named as a deviation rather than hidden; durations include queue time. Predecessor 9/10: every checked claim held exactly (~2 unpushed, 0 undocumented, CI-wait figure); lightly exercised because the pickup was same-conversation.>

```handoff
session: S734
date: 2026-09-20
status: complete
self_score: 9
predecessor_score: 9
active_task: Owner-directed push to origin/master + CI verification DONE — pushed 5ed0da83..75d2b049 (4 commits: the 3 unpushed S733 close-out commits — trim 484c46de, records 6fb68007, sha c09d7b5a — + the S734 claim 75d2b049 riding the push, S726/S729/S731/S733 precedent), all 4 push-triggered workflows completed success ON THE PUSHED SHA 75d2b049 (verified via gh run list --commit, sha match structural): lint 5m11s (35536061548), pkgdown 6m03s (35536061442), test-coverage 10m35s (35536061510), R-CMD-check 22m17s (35536061496) — the ~21–22 min post-S732-fix figure confirmed a second time, single 30-min Monitor arm, no re-arm. No TDD phases; lint N/A.
what_was_done: Claim 75d2b049 (rode the push so CI ran on it; owner picked the push via the Phase 0 AskUserQuestion picker). Phase 0 reconcile clean (0 undocumented on both frontiers at c09d7b5a; S733 receipt ratchet citation matched .quality-gates-results.json exactly); 3 unpushed measured = S733's estimate exactly. Context budget surfaced two signals beyond the known CLAUDE.md warn band: growth run 12/10, and SESSION_RUNNER.md/SAFEGUARDS.md "differs from canonical" — verified NOT local edits (both last touched by the S719 forced sync b773ddb6, working tree clean; the checker's comparison target moved, fork-vs-canonical provenance); report-only, nothing changed. CI verification via Monitor polling gh run list --commit 75d2b049 at 60 s emitting every terminal conclusion; all 4 green in 22m17s wall. No BACKLOG item consumed.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~2 expected after close-out: records + sha; both docs-only, estimated at write time; no urgency, CI current through 75d2b049). (B) Priorities: pedigree-growth measurement (READY, S, BACKLOG.md:117); package-split disposition + REUSE registration (owner decisions); BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M, BACKLOG.md:100). (C) Standing report-only set now INCLUDES the two new context-budget signals (growth run; synced-files differ-from-canonical) — surface at Phase 0 until resolved or owner-dispositioned.
key_files: CHANGELOG.md:41 (S734 entries at top), SESSION_NOTES.md:39 (S734 handoff), BACKLOG.md:117 (next natural pickup)
gotchas: Expect 0 undocumented commits at next Phase 0 — measure it; ~2 unpushed after close-out (estimate). R-CMD-check 22m17s on 75d2b049 — the ~21–22 min figure confirmed twice; one 30-min Monitor arm suffices. The SESSION_RUNNER.md/SAFEGUARDS.md differs-from-canonical flags are NOT local edits (verified: last touch b773ddb6, tree clean) — do NOT re-sync reflexively; a fork-main sync carries the methodology_trim.py patch procedure (CLAUDE.md checklist) and is its own session with an owner decision. Standing set unchanged otherwise: scratchpad/ invisible to git BY OWNER DECISION; quality_ratchet.py --run ~2 min, AFTER committing (Learning 772); methodology_trim.py needs --budget-bytes 65536; renv Rscript banner expected; CLAUDE.md warn band; SESSION_NOTES.md's two ceilings differ (owner decision pending); suite baseline 2437/0/0/184/0 remote-confirmed again by R-CMD-check on 75d2b049.
runtime_smoke: n/a — push + docs only (no runtime behavior changed); the deliverable's verification surface is CI itself, 4/4 green on the pushed sha. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 84231b1581ab · manifest aa983075d6a2 (measured 3,483,934 B at 75d2b049)
changelog_ref: 75d2b049
commit: be4f41ce
```
<free-text: S734 +/- — plus: deliverable verified on the exact pushed sha by construction (--commit filter) with run ids and durations recorded; the two new context-budget signals pinned down at Orient (git log ruled out local edits) instead of ignored or "fixed" — report-don't-fix held; monitor filter covered all terminal states, not success-only; scope held through the CI wait. Minus: durations are createdAt→updatedAt and include queue time; whether the differs-from-canonical flags predate this session could not be established — recorded as unverifiable rather than guessed. Predecessor 9/10: the ~3-unpushed estimate, CI-wait figure, reconcile expectation and ratchet citation all held exactly; only gap was the un-itemized context-budget signals.>

```handoff
session: S733
date: 2026-09-20
status: complete
self_score: 9
predecessor_score: 9
active_task: Owner-directed push to origin/master + CI verification DONE — pushed 3b688ae2..5ed0da83 (8 commits: the 7 unpushed S732 commits incl. the CRAN check-time fix ba088d0d touching .R/.Rd, + the S733 claim riding the push — S726/S729/S731 precedent), all 4 push-triggered workflows completed success ON THE PUSHED SHA 5ed0da83 (verified via gh run list --commit, sha match structural): lint 3m56s (35534412900), pkgdown 6m13s (35534413059), test-coverage 10m33s (35534412911), R-CMD-check 21m28s (35534412936) — down from 33m37s on the previous push: the first remote-side confirmation of the S732 fix, −12 min of CI. No TDD phases; lint N/A.
what_was_done: Claim 5ed0da83 (rode the push so CI ran on it). Phase 0 reconcile clean (0 undocumented on both frontiers at ee7cb230; S732 receipt ratchet citation matched .quality-gates-results.json exactly); 7 unpushed measured vs S732's ~6 estimate (delta = S732's own HANDOFFS trim commit). CI verification via Monitor polling gh run list --commit 5ed0da83 at 60 s; no re-arm needed (check now fits one 30-min arm). Pre-handoff SESSION_NOTES trim 484c46de: 14 records archived to docs/archive/SESSION_NOTES-through-2026-09-19-3.md (56,599 → 10,583 B; L1/L2/L3 verified; SRF_RED overridden per the established Learning 549/586/587 resolution; file was 151 B under the 56,750 B token cap and the handoff would not fit). No BACKLOG item consumed (the push was a next-steps owner decision).
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~3 expected after close-out: trim + records + sha; all docs-only, last two estimated at write time; no urgency, CI current through 5ed0da83). (B) Priorities: pedigree-growth measurement (READY, S, BACKLOG.md:117); package-split disposition + REUSE registration (owner decisions); BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M, BACKLOG.md:100). (C) Standing report-only set unchanged from S732.
key_files: CHANGELOG.md:41 (S733 entries at top), SESSION_NOTES.md:39 (S733 handoff), docs/archive/SESSION_NOTES-through-2026-09-19-3.md:1 (new shard), BACKLOG.md:117 (next natural pickup)
gotchas: Expect 0 undocumented commits at next Phase 0 — measure it; ~3 unpushed after close-out (estimate). CI-wait mechanics CHANGED — R-CMD-check now ~21–22 min on the remote after the S732 fix, fits one 30-min Monitor arm; the ~34 min / expect-one-re-arm figure is obsolete (measured on 5ed0da83). methodology_trim.py --cut N keeps the newest N records and archives the rest — dry-run first; SESSION_NOTES.md now 10.6 KB live, several sessions of token-cap headroom. Standing set unchanged: scratchpad/ invisible to git BY OWNER DECISION; quality_ratchet.py --run ~2 min, AFTER committing (Learning 772); methodology_trim.py needs --budget-bytes 65536; renv Rscript banner expected; CLAUDE.md warn band; SESSION_NOTES.md's two ceilings differ (owner decision pending); suite baseline 2437/0/0/184/0 remote-confirmed again by R-CMD-check on 5ed0da83.
runtime_smoke: n/a — push + docs only (no runtime behavior changed); the deliverable's verification surface is CI itself, 4/4 green on the pushed sha. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 7ced9faa4709 · manifest aa983075d6a2 (measured 3,483,941 B at 5ed0da83)
changelog_ref: 5ed0da83
commit: 6fb68007
```
<free-text: S733 +/- — plus: deliverable verified on the exact pushed sha by construction (--commit filter) with run ids and durations recorded; the predicted SESSION_NOTES trim handled proactively on committed state before the hook could refuse, shard verify script run pre-commit; scope held through the CI wait; the R-CMD-check −12 min drop recognized and recorded as the S732 fix's remote confirmation rather than just "still green." Minus: methodology_trim.py --cut semantics (N = kept, not cut) discovered by dry run, not known going in — the accepted trim is more aggressive than first intended (3 records live), though lossless; durations are createdAt→updatedAt and include queue time. Predecessor 9/10: recount command, ratchet citation, trim prediction and CI-filter mechanics all held; only miss was the ~6 unpushed estimate undercounting its own trim commit (measured 7).>

```handoff
session: S732
date: 2026-09-20
status: complete
self_score: 9
predecessor_score: 9
active_task: CRAN check-time fix applied and verified DONE — makePedigreeMatingLayout roxygen example input examplePedigree (3,694 rows, 734 s = 71% of the whole check) → smallPed (17 rows, 0.03 s, zero warnings) at R/makePedigreeDiagramData.R:1659-1663 + regenerated man/makePedigreeMatingLayout.Rd via devtools::document(). §7 clean-export re-measure at the fix commit ba088d0d: Status OK, zero NOTEs, >5 s examples table EMPTY (worst remaining Rd: groupAddAssign 1.98 s); examples 743.0 → 9.8 s; whole check 1,032 → 291.6 s CPU (4.9 min, −72%, matching the audit prediction); wall 518.8 s contention-inflated (load avg 50+; CPU/wall 0.56 vs S730's 0.995) — upper bound only. TDD N/A (doc-only .Rd example change; the re-measure is the ratified verification gate). Lint 0 on the touched file.
what_was_done: Claim e7fe4713; fix ba088d0d; completed BACKLOG item removed in the records commit (S686). Input choice measured across ALL shipped pedigrees with the required id/sire/dam/sex/gen columns: smallPed 0.03 s/clean beat the item's named candidate pedWithGenotype (0.93 s + 5-collision warning), qcPed (0.91 s + same), rhesusPedigree (2.91 s + 72 collisions); smallPed is the fixture idiom in 13 other roxygen examples. Fix committed BEFORE the re-measure (the §7 recipe builds git archive HEAD). First §7 run failed in 4 s (renv banner polluted the R_LIBS capture → "quadprog not available"); re-captured with tail -1, re-check passed.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~6 expected after close-out: 2 pre-existing + claim + fix + records + sha; last two estimated at write time). The fix commit touches .R/.Rd, so a push gets it remote R-CMD-check validation; still no urgency. (B) Priorities: pedigree-growth measurement (READY, S — now the first Up Next item); package-split disposition + REUSE registration (owner decisions); BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M, BACKLOG.md:100). (C) Standing report-only set unchanged from S731.
key_files: R/makePedigreeDiagramData.R:1659 (new example), man/makePedigreeMatingLayout.Rd:110 (regenerated), CHANGELOG.md:41 (S732 entries with verification numbers), docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md:225 (§7 recipe; Finding 4 holds the untaken skip_on_cran lever)
gotchas: §7 recipe trap — capture R_LIBS with Rscript -e 'cat(.libPaths()[1])' 2>/dev/null | tail -1; renv's out-of-sync banner can land on stdout and a polluted R_LIBS kills the check in 4 s ("quadprog not available"). Expect 0 undocumented commits at next Phase 0 — measure it; ~6 unpushed (estimate). Quiet-machine wall figure not measured (machine loaded all session); direction settled (empty >5 s table, worst Rd 1.98 s, CPU 4.9 min). Finding-4 skip_on_cran lever stays untaken unless CRAN's actual farm crowds 10 min. Standing set unchanged: scratchpad/ invisible to git BY OWNER DECISION; ratchet ~2 min AFTER committing (Learning 772); trim needs --budget-bytes 65536; renv banner expected; CLAUDE.md warn band; the two SESSION_NOTES.md ceilings differ (owner decision pending; file at ~56.4 KB is ~350 B under the token cap — next handoff will need a trim); suite baseline 2437/0/0/184/0 not re-run locally (no code-behavior change; CRAN-surface suite ran 0-fail inside the §7 check).
runtime_smoke: n/a — doc-only roxygen example change; the §7 R CMD check executed the new example end-to-end (Status OK, examples stage 9.8 s). quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results f25e0f1593cb · manifest aa983075d6a2 (measured 3,483,950 B at ba088d0d)
changelog_ref: ba088d0d
commit: e6439a20
```

```handoff
session: S731
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: Owner-directed push to origin/master + CI verification DONE — pushed 0572767b..3b688ae2 (9 commits: the 8 unpushed S730 docs-only commits + the S731 claim riding the push), all 4 push-triggered workflows completed success ON THE PUSHED SHA 3b688ae2 (verified via gh run list --commit, sha match structural): lint 4m26s (35490394639), test-coverage 8m41s (35490394613), pkgdown 18m05s (35490394612), R-CMD-check 33m37s (35490394609). Puts the S730 CRAN check-time audit + full S730 record set on the remote. No TDD phases; lint N/A.
what_was_done: Claim 3b688ae2 (rode the push so CI ran on it — S729/S726/S717 precedent). Phase 0 reconcile clean (0 undocumented on both frontiers at bd094712; S730 receipt ratchet citation matched .quality-gates-results.json exactly); 8 unpushed measured = S730 prediction. CI verification via Monitor polling gh run list --commit 3b688ae2 at 60 s, one expected re-arm at the 30-min cap (R-CMD-check ~34 min). No BACKLOG item consumed (the push was a next-steps owner decision), so nothing removed.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~2 expected after close-out: records + sha; both docs-only, estimated at write time; no urgency, CI current through 3b688ae2). (B) Priorities: apply the CRAN check-time fix (READY, S, BACKLOG.md:117 — doc-only roxygen example change at R/makePedigreeDiagramData.R:1659 + devtools::document() + audit §7 re-measure; natural next pickup); pedigree-growth measurement (READY, S, BACKLOG.md:136); package-split disposition + REUSE registration (owner decisions); BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M, BACKLOG.md:100). (C) Standing report-only set unchanged from S730.
key_files: CHANGELOG.md:41 (S731 entries at top), SESSION_NOTES.md:37 (S731 handoff), BACKLOG.md:117 (next natural pickup), docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md:1 (now on the remote)
gotchas: Expect 0 undocumented commits at next Phase 0 — measure it; ~2 unpushed after close-out. The apply-the-fix session's own gotchas live in the S730 receipt and BACKLOG.md:117 (clean-export §7 recipe with NOT_CRAN unset; donttest is NOT an escape at incoming; never edit man/*.Rd by hand). CI-wait mechanics: R-CMD-check ~34 min exceeds the 30-min Monitor cap — arm expecting one re-arm; filter with gh run list --commit <sha>. Standing set unchanged: scratchpad/ invisible to git BY OWNER DECISION; quality_ratchet.py --run ~2 min, AFTER committing (Learning 772); methodology_trim.py needs --budget-bytes 65536; renv Rscript banner expected; CLAUDE.md warn band; SESSION_NOTES.md's two ceilings differ (owner decision pending); suite baseline 2437/0/0/184/0 remote-confirmed again by R-CMD-check on 3b688ae2.
runtime_smoke: n/a — push + docs only (no runtime behavior changed); the deliverable's verification surface is CI itself, 4/4 green on the pushed sha. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 24c0d9475ec1 · manifest aa983075d6a2 (measured 3,483,933 B at 3b688ae2)
changelog_ref: 3b688ae2
commit: f5656164
```
<free-text: S731 +/- — plus: deliverable verified on the exact pushed sha by construction (--commit filter), not run-title matching; prediction discipline held both ways (8 unpushed predicted/measured, 0 undocumented predicted/measured); scope held absolutely through the ~50-min CI wait; every close-out number from a fresh read. Minus: the re-armed monitor re-emitted the 3 already-green workflows (predicted noise); durations are createdAt→updatedAt and include queue time (seconds ±). Predecessor 9/10: the recount command and precedent chain were this session's entire method and every checked claim held; only miss was that the one-re-arm CI-wait mechanic had to be re-derived from S729's durations rather than stated.>

```handoff
session: S730
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: CRAN check-time measurement audit DONE — docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md. Full CRAN-surface check (clean-export tarball 3,485,111 B at c8397845, NOT_CRAN unset): Status OK, 1,037 s wall / 1,032 s CPU (17.3 min), of which 734 s (71%) is the ONE makePedigreeMatingLayout Rd example on the full 3,694-row examplePedigree (~147x the 5 s per-Rd threshold; the app's own diagram cap is 750, R/modPedigree.R:406). Other 201 examples: 8.9 s combined. Tests fine: 215 s under check, 0 fail; ~14% of local blocks stay home on CRAN. Measured remedy: pedWithGenotype input -> 1.0 s, check -> ~5 min, clearing the verified 10-min incoming Overall-checktime NOTE. Research only; no remedy applied; TDD N/A; lint N/A.
what_was_done: Claim c8397845; deliverable e8a0eca7 (audit + BACKLOG measure-first item removed and replaced in place by the READY/S apply-the-fix item carrying the numbers, S686 convention). Criteria verified at source: CRAN policy rev 6875 fetched; the 5 s CPU-or-elapsed per-Rd rule and _R_CHECK_DONTTEST_EXAMPLES_=as_cran (donttest STILL RUNS at incoming) read from tools/R/check.R itself; the 10-min incoming NOTE evidenced from R-pkg-devel. Measurements: R CMD check --timings under /usr/bin/time -l (CPU/wall 0.995 = single-threaded, 2-core policy pass measured); per-file testthat runs on BOTH sides of the NOT_CRAN switch (CRAN surface 187.6 s / 2,141 blocks / 200 skips; baseline 260.3 s / 2,437 / 184 — standing baseline reproduced exactly, its currency settled as rows/failed/error/skipped); control pedWithGenotype 1.0 s.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~8 expected after close-out: 4 pre-existing + claim + deliverable + records + sha; last two estimated at write time; all docs-only). (B) Priorities: apply the CRAN check-time fix (READY, S, BACKLOG.md:117 — doc-only .Rd example change via R/makePedigreeDiagramData.R:1659-1662 + devtools::document() + the audit §7 re-measure; natural next pickup); pedigree-growth measurement (READY, S, owner-requested S721); package-split disposition + REUSE registration (owner decisions); BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M, BACKLOG.md:100). (C) Standing report-only set unchanged from S729.
key_files: docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md:1 (whole report; §2 stage table, §3 findings, §7 recipe), BACKLOG.md:117 (apply-the-fix item), R/makePedigreeDiagramData.R:1659 (the roxygen example to change), R/modPedigree.R:406 (750-individual cap), CHANGELOG.md:41 (S730 entries at top)
gotchas: The apply-the-fix re-measure must use the audit §7 clean-export recipe with NOT_CRAN unset — expect ~5 min total and an EMPTY >5 s table; never measure from the working tree. pedWithGenotype through the layout emits a benign 5-collision warning — fine for timing; the remedy session may prefer a clean-laying-out examplePedigree subset for the shipped example. \donttest{} is NOT an escape at incoming (verified in check.R) — never re-derive that remedy. Never edit man/*.Rd by hand; devtools::document() regenerates. Standing set unchanged: scratchpad/ invisible to git BY OWNER DECISION; quality_ratchet.py --run ~2 min, AFTER committing (Learning 772); methodology_trim.py needs --budget-bytes 65536; renv Rscript banner expected; CLAUDE.md warn band; SESSION_NOTES.md's two ceilings differ (owner decision pending); suite baseline 2437/0/0/184/0 reproduced exactly this session, currency settled (rows/failed/error/skipped).
runtime_smoke: n/a — research/measurement only (no runtime behavior changed); the deliverable's verification is the measurements themselves, closed three ways (Ex.timings + the check's own >5 s table + a measured small-input control). quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 10bcea6e4007 · manifest aa983075d6a2 (measured 3,485,180 B at e8a0eca7)
changelog_ref: e8a0eca7
commit: fcf6790b
```
<free-text: S730 +/- — plus: every enforcement criterion verified in the enforcing tool's own source or policy page (which overturned the item's implicit donttest remedy before it could be recommended); headline finding closed three ways; the identical-currency double test run settled the long-standing 2437/184 baseline-currency question; scope held — the one-line fix was filed as a READY/S item, not applied. Minus: single-run timings with no variance estimate (conclusion directions robust, magnitudes ±); the ~79 s install/vignette/manual residual not decomposed; one sloppy artifact (full-results CSV write errored on a list column after the needed numbers printed). Predecessor 9/10: the BACKLOG item was the execution plan verbatim and its NOT_CRAN-inversion gotcha was this session's method; nothing checked was wrong; only miss was the remedy steer pointing at simulation examples when the culprit is the layout example — exactly what measure-first exists to catch.>

```handoff
session: S729
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: Owner-directed push to origin/master + CI verification DONE — pushed 9006b567..0572767b (13 commits: 12 unpushed S726-S728 docs/config + the S729 claim riding the push), all 4 push-triggered workflows completed success ON THE PUSHED SHA 0572767b: lint 4m49s (35485603669), test-coverage 9m39s (35485603670), pkgdown 18m32s (35485603680), R-CMD-check 33m54s (35485603672). First remote validation of the S728 build-hygiene work incl. the first .quality-gates.json manifest. No TDD phases; lint N/A.
what_was_done: Claim 0572767b (rode the push so CI ran on it — S717/S726 precedent). Mid-session owner request filed, not acted on (1-and-done, S726 precedent): CRAN check-time item at BACKLOG.md:117 (c9c946f7, READY, Effort M) — measure-first on the CRAN-visible surface (R CMD check --timings per-Rd example times, incoming NOTE > 5 s; suite run WITHOUT NOT_CRAN=true so skip_on_cran exclusions match CRAN's), remedies (donttest, smaller example inputs, skip_on_cran on CI-duplicated tests, shared fixtures) deferred until measured. CI verification via background poller from the first attempt (35 polls, ~35 min), jq-filtered on headSha == 0572767b exactly.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~3 expected after close-out: filing c9c946f7 + records + sha; last two estimated at write time; all docs-only, no urgency). (B) Priorities: CRAN check-time measurement (READY, M, owner-requested S729, BACKLOG.md:117, measure first); pedigree-growth measurement (READY, S, owner-requested S721); package-split disposition + REUSE registration (owner decisions pending); BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M, BACKLOG.md:100). (C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub; iCloud Housekeeping item closable pending confirmation; owner's stale 19.7 MB ../nprcgenekeepr_2.0.0.9000.tar.gz + ../nprcgenekeepr.Rcheck/ outside the repo.
key_files: BACKLOG.md:117 (new CRAN check-time item), CHANGELOG.md:1 (S729 entries at top), HANDOFFS.md:154 (this receipt), .quality-gates.json:17 (gate manifest now on the remote via the push)
gotchas: CI is current through 0572767b — only ~3 close-out docs commits unpushed; expect 0 undocumented commits at next Phase 0, measure it. The CRAN check-time item's test measurement must run WITHOUT NOT_CRAN=true — the exact opposite of the Build/Test/Verify regression-read setting; never blend the two numbers. Standing set unchanged from S728: scratchpad/ invisible to git BY OWNER DECISION (ls -d scratchpad if in doubt); quality_ratchet.py --run takes ~2 min and measures git archive HEAD so run it AFTER committing (Learning 772); methodology_trim.py needs --budget-bytes 65536; renv Rscript banner expected; CLAUDE.md warn band; SESSION_NOTES.md's two ceilings differ (owner decision pending); suite baseline 2437/0/0/184/0 — remote-confirmed again by R-CMD-check on 0572767b.
runtime_smoke: n/a — push + docs only (no runtime behavior changed); the deliverable's verification surface is CI itself, 4/4 green on the pushed sha. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results a39b6c231e42 · manifest aa983075d6a2 (measured 3,485,202 B at c9c946f7)
changelog_ref: 0572767b
commit: 2b6ccc45
```
<free-text: S729 +/- — plus: the claim rode the push so CI ran on the exact claim sha; verification pinned to headSha with run ids and durations recorded, not eyeballed; the mid-session owner request was filed with a measure-first mandate and its own ledger entry and NOT started; the CI wait used a background poller from the first attempt (S726's sleep-chain fumble not repeated). Minus: Phase 0 was an abbreviated re-verification (status, unpushed count, frontier check) rather than the full 8-step read — the session began minutes after S728's close-out with the full orientation in-context and the owner's task already given; recorded honestly rather than claimed as a full Orient. The poller's 55-poll cap was a guess that fit (35 needed) — a longer queue would have timed it out. Predecessor 9/10: the push decision was named with the exact recount command (measured 12, predicted ~12), the ratchet-after-commit gotcha was applied without a fumble, and no checked claim failed.>


