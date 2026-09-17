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

This file currently holds **6** receipt(s). Computed by `methodology_trim.py` on every
`--check`/`--write` run, never hand-maintained.

**Archived 116 record(s), 2026-08-14 → 2026-09-17** into [`docs/archive/HANDOFFS-through-2026-09-17.md`](docs/archive/HANDOFFS-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

```handoff
session: S702
date: 2026-09-17
status: complete
self_score: 9
predecessor_score: 8
active_task: DONE. CHANGELOG.md archive pass via methodology_trim.py (S701 next-step A; BACKLOG Housekeeping item's remaining half; owner-picked via AskUserQuestion at Phase 0; docs-only maintenance session -- no TDD phases, S700/S701/S594/S539 archive-pass precedent). 328 records (2026-08-14 -> 2026-09-17) archived to docs/archive/CHANGELOG-through-2026-09-17.md; live file 464,522 B -> 33,503 B (-92.8%); both triggers cleared; L1/L2/L3/P1A verified twice (tool assertions + the generated verify.sh re-deriving from git: 347 = 19 retained + 328 archived).
what_was_done: P1_UNDOCUMENTED never fired -- the claim ledger entry shipped IN the Phase 1B claim commit (78dbd8ce), frontier at HEAD (Learnings 752/754 applied, zero wasted gate cycles). SRF_RED fired CONTRARY to the item's carried "likely GREEN" prediction -- the actual most-recent archive boundary is S579's 2026-08-14 pass (66d5aa5), not S547's ~934 KB relocation (6.3072 vs S579, 0.4739 vs the largest-drop boundary -- the small-denominator shape a fourth time); owner-directed --force via AskUserQuestion (S594/S700/S701 precedent); the wrong carried prediction is now Learning 755. Trim committed 6bac092f per the tool's one-ledger-one-shard-one-entry-one-commit instruction; independent verify.sh green; re-check "trigger does not fire" (33,503 B, line metric abstains post-split). Post-trim dashboard flag list re-extracted (Learning 753 method): BOTH CHANGELOG flags GONE; only pre-existing MEDIUM (.Rproj.user jspdf artifact) and LOW (9 branches) remain -- no HIGH flags anywhere. Phase 0 backfill cd2ba39f (S701 close-out self-reference commits); claim 78dbd8ce; deliverable 6bac092f; records 922350bd (CHANGELOG close-out entry, Learning 755, BACKLOG item removed entirely -- both halves done; the H4 rate item stays open). No suite run: docs-only, nothing in the package build/test path changed.
next_steps: (A) Issue #148 MHC haplotype scoping (READY, Effort M -- sequencing audit's last open item; scope decision first per audit Finding #4). (B) Census class (d) duplicate-adjacent assessment (READY, Effort S -- smallest census residual). (C) Census class (b) union dots (READY, Effort M) and the curved-chord measurement pass (READY, Effort M). (D) Push decision (owner call): ~36 commits ahead after close-out (estimate -- count with git rev-list --count origin/master..HEAD); last pushed state CI-green; unpushed span believed docs/prose-only -- verify with git diff origin/master..HEAD --stat before pushing (estimate, not measured). (E) Informational: package-split disposition awaiting owner; dashboard copy stale (v2.14.0 vs v2.18.0); untracked leftovers unchanged; Learning 749 duplicate at PROJECT_LEARNINGS.md:2195.
key_files: docs/archive/CHANGELOG-through-2026-09-17.md (+.verify.sh -- run it rather than trusting claims); CHANGELOG.md:21-23 (new shard pointer) and :25-49 approx (S702 close-out entry above the tool trim entry); PROJECT_LEARNINGS.md:2206 (Learning 755); BACKLOG.md:96 approx (Housekeeping now opens with census class (b)); SESSION_NOTES.md (full S702 handoff + S701 evaluation).
gotchas: All three ledger files now have through-2026-09-17 shards -- pre-trim context lives in docs/archive/; live CHANGELOG.md holds only 19 records (2026-09-17-dated, S700-S702 era). CHANGELOG.md sits at 33,503 B, just ABOVE the 32,768 B half-budget stop; at the H4 ~4-entries-per-session rate the trigger re-fires in ~5 sessions (estimate); HANDOFFS.md re-fires in ~7 (Learning 754) -- recurring cadences. The two S702 close-out self-reference commits will sit past the CHANGELOG frontier -- next Phase 0 backfills them, the recurring shape. failed=0 expectation stays 2,370 blocks, INHERITED from S698 (S699-S702 all docs-only). Any enumeration over CHANGELOG entries must span CHANGELOG.md docs/archive/CHANGELOG-*.md. The empty 2026-08 month header persists (cosmetic); the shard name is a span label, not a day boundary (CUT_STRADDLES_DAY).
runtime_smoke: n/a -- docs-only (archive relocation + ledger/notes/backlog records; no runtime behavior change)
changelog_ref: 2026-09-17 S702 close-out entry (BL-Housekeeping), 922350bd
commit: pending
```
Maintenance session: the last flagged ledger file is cleared by a verified-lossless 328-record archive pass -- no HIGH dashboard flags remain, and the two-file BACKLOG Housekeeping item is fully done and removed. Self-score 9: + zero gate-discovery waste (Learnings 752/753/754 applied at the right moments); + deliverable verified two independent ways plus a post-trim dashboard re-measure; + the wrong carried SRF prediction caught, surfaced accurately at the owner decision point, and converted into Learning 755. - My own Phase 0 report and picker description repeated the "SRF likely GREEN" claim unverified (FM #11-adjacent; a --check at orientation would have caught it pre-picker); - low degree of difficulty (third consecutive precedent-following archive pass). Predecessor (S701) scored 8/10: complete and exact procedure, one wrong load-bearing claim (the S547-boundary SRF prediction, stated as derived but never checked -- Learning 755).

```handoff
session: S701
date: 2026-09-17
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. HANDOFFS.md archive pass via methodology_trim.py (S700 next-step A; BACKLOG Housekeeping item first half; owner-picked via AskUserQuestion at Phase 0; docs-only maintenance session -- no TDD phases, S700/S594/S539 archive-pass precedent). 116 receipts (2026-08-14 -> 2026-09-17) archived to docs/archive/HANDOFFS-through-2026-09-17.md; live file 590,777 B -> 31,315 B (-94.7%); both triggers cleared; stale front-matter count regenerated 21 -> 6; L1/L2/L3/P1A verified twice (tool assertions + the generated verify.sh re-deriving from git: 122 = 6 retained + 116 archived).
what_was_done: P1_UNDOCUMENTED never fired -- the claim ledger entry shipped IN the Phase 1B claim commit (f51210bb), keeping the frontier at HEAD (Learning 752 applied; zero wasted gate cycles vs S700's one, Learning 754). SRF_RED fired as predicted (5.0215 vs the tiny 21-receipt 2026-08-14 boundary, 0.6989 vs the largest-drop boundary -- the S594/S700 small-denominator shape exactly); owner-directed --force via AskUserQuestion. Trim committed 9b551c8b per the tool's one-ledger-one-shard-one-entry-one-commit instruction; independent verify.sh green; re-check reports trigger does not fire (31,315 B, headroom 113). Post-trim dashboard flag list re-extracted (Learning 753 method): HANDOFFS flags GONE; CHANGELOG.md (5,562 lines / 461,077 B) is the only remaining flag, already queued as the BACKLOG item's second half. bin/check-handoff shard-check N/A -- checker not present in this project (canonical-only), stated rather than silently skipped. Phase 0 backfill 21d09bca (S700 close-out self-reference commits); claim f51210bb; deliverable 9b551c8b; records 1a8aeb20 (CHANGELOG close-out entry, Learning 754, BACKLOG item narrowed to CHANGELOG.md half). No suite run: docs-only, nothing in the package build/test path changed.
next_steps: (A) CHANGELOG.md archive pass (READY, Effort S -- the BACKLOG item's remaining half; ship the claim ledger entry IN the claim commit per Learnings 752/754; SRF likely GREEN there -- most recent boundary is S547's ~934 KB legacy relocation -- but if RED it is an owner decision; expect the post-trim level near the 32,768 B stop, not near-zero). (B) Issue #148 MHC haplotype scoping (audit Finding #4: scope decision first). (C) The 3 census-residual items (d-adjacent smallest, Effort S). (D) Push decision (owner call): ~29 commits ahead after close-out; last pushed state CI-green; unpushed span believed docs/prose-only -- verify with git diff origin/master..HEAD --stat before pushing (estimate, not measured). (E) Informational: package-split disposition awaiting owner; dashboard copy stale (v2.14.0 vs v2.18.0); untracked leftovers unchanged; Learning 749 duplicate at PROJECT_LEARNINGS.md:2195.
key_files: docs/archive/HANDOFFS-through-2026-09-17.md (+.verify.sh -- run it rather than trusting claims); HANDOFFS.md:135-141 (new shard pointer + regenerated count 6); CHANGELOG.md:19-50 approx (S701 close-out entry + tool trim entry); PROJECT_LEARNINGS.md:2204 (Learning 754); BACKLOG.md:96-117 approx (narrowed CHANGELOG.md item, re-grep).
gotchas: HANDOFFS.md sits at 31,315 B -- 1,453 B under the half-budget stop; at ~5 KB/receipt the byte trigger (fires > 65,536 B) re-fires in roughly 7 sessions, a recurring cadence, not an anomaly (Learning 754). failed=0 expectation stays 2,370 blocks but is INHERITED from S698 (S699-S701 all docs-only) -- a session touching package files needs a fresh baseline. The two S701 close-out self-reference commits will sit past the CHANGELOG frontier -- the recurring shape; next Phase 0 backfills them exactly as S701 did for S700's. HANDOFFS.md itself now holds only S696-S701; older receipts live in the shards (newest: through-2026-09-17). The CHANGELOG month-header mislabeling (2026-09 entries under 2026-08) persists -- cosmetic, leave unless tasked.
runtime_smoke: n/a -- docs-only (archive relocation + ledger/notes/backlog records; no runtime behavior change)
changelog_ref: 2026-09-17 S701 close-out entry (BL-Housekeeping), 1a8aeb20
commit: 79b6003b
```
Maintenance session: the dashboard's HANDOFFS.md HIGH flag is cleared by a verified-lossless 116-receipt archive pass, leaving CHANGELOG.md as the sole remaining flagged file (its pass already queued with sharpened procedure notes). Self-score 9: + zero gate-discovery waste (Learnings 752/753 applied at the right moments instead of re-derived); + deliverable verified two independent ways plus a post-trim dashboard re-measure; + both refusal-gate paths resolved by their governing rules; - low degree of difficulty (precedent-following maintenance; the score reflects clean execution, not novelty); - the shard-checker step in this file's own guidance is unrunnable here (no bin/check-handoff copy) and was recorded N/A rather than resolved. Predecessor (S700) scored 9/10: procedure notes complete and exact, nothing wrong found; only miss was expectation-shaping on the post-trim level (now Learning 754).

```handoff
session: S700
date: 2026-09-17
status: complete
self_score: 9
predecessor_score: 8
active_task: DONE. SESSION_NOTES.md trim via methodology_trim.py (S699 next-step A; owner-picked via AskUserQuestion at Phase 0; docs-only maintenance session -- no TDD phases, S539/S594 archive-pass precedent). 170 records (2026-08-19 -> 2026-09-17) archived to docs/archive/SESSION_NOTES-through-2026-09-17.md; live file 931,481 B -> 2,560 B (-99.7%); both triggers cleared; L1/L2/L3 verified twice (tool assertions + the generated verify.sh re-deriving from git).
what_was_done: Two tool gates hit and resolved by their own rules: P1_UNDOCUMENTED (the session's own claim commit 86c1bc6a was unledgered -- wrote the claim CHANGELOG entry c75269bb per the gate's "reconcile first, then trim"; Learning 752) and SRF_RED (2.3879 vs the most recent small S594-era archive boundary, 0.1422 vs the largest-drop boundary -- owner-directed --force via AskUserQuestion, S594 precedent exactly). Trim committed 6f722e25 per the tool's one-ledger-one-shard-one-entry-one-commit instruction; independent verify.sh green; re-check reports trigger does not fire. Post-trim dashboard verification found HANDOFFS.md (6,555 lines / 586,022 B; 122 real receipts vs the stale front-matter "21") and CHANGELOG.md (5,515 lines / 457,092 B) ALSO HIGH-flagged past the 2,000-line read cap, both already over at S699's close -- the "1 HIGH flag" orientation framing was an under-count (the dashboard summary counts projects, not flags; Learning 753); queued as one new BACKLOG Housekeeping item (READY, Effort S each, one file per session) with full procedure notes, report-don't-fix. Phase 0 backfill af664d43 (S699 close-out commits); claim 86c1bc6a; claim-ledger c75269bb; deliverable 6f722e25; records c179897a (CHANGELOG close-out entry, Learnings 752-753, BACKLOG item). No suite run: docs-only, nothing in the package build/test path changed.
next_steps: (A) HANDOFFS.md archive pass (READY, Effort S -- new Housekeeping item at section top; claim CHANGELOG entry BEFORE the first --write per Learning 752; expect possible SRF_RED -> owner decision). (B) CHANGELOG.md archive pass (READY, Effort S -- same item, separate session). (C) Issue #148 MHC haplotype scoping (audit Finding #4: scope decision first). (D) The 3 census-residual items (d-adjacent smallest, Effort S). (E) Push decision (owner call): ~24 commits ahead after close-out; last pushed state CI-green; unpushed span believed docs/prose-only -- verify with git diff origin/master..HEAD --stat before pushing (estimate, not measured). (F) Informational: Learning 749 duplicate at PROJECT_LEARNINGS.md:2195; dashboard copy stale (v2.14.0 vs v2.18.0); untracked leftovers unchanged; package-split disposition still awaiting owner.
key_files: docs/archive/SESSION_NOTES-through-2026-09-17.md (+.verify.sh -- run it rather than trusting claims); SESSION_NOTES.md:17-19 (new archive pointer block); CHANGELOG.md:21 (S700 close-out entry, tool trim entry below); PROJECT_LEARNINGS.md:2200-2202 (Learnings 752/753); BACKLOG.md:96-119 approx (new trim item, re-grep).
gotchas: SESSION_NOTES.md now holds ONLY S700's records -- pre-S700 context lives in the archive shards (newest: through-2026-09-17). failed=0 expectation stays 2,370 blocks but is INHERITED from S698 (S699/S700 both docs-only, no suite run) -- do not cite S700 as a fresh baseline. A trim session must ledger its claim commit BEFORE --write (P1_UNDOCUMENTED) and treat SRF_RED as an owner decision. Dashboard "High+ Risk: N" counts PROJECTS -- extract the flag list from dashboard.html; HANDOFFS.md front matter's "21 receipt(s)" is stale (real: 122). The tool inserted a "## 2026-09" month header into CHANGELOG.md; older 2026-09-dated entries still sit under "## 2026-08" -- pre-existing cosmetic mislabeling, leave it unless tasked.
runtime_smoke: n/a -- docs-only (archive relocation + ledger/notes/backlog records; no runtime behavior change)
changelog_ref: 2026-09-17 S700 close-out entry (ad hoc), c179897a
commit: c0b7ec81
```
Maintenance session: the dashboard's SESSION_NOTES.md HIGH flag is cleared by a verified-lossless 170-record archive pass; the two sibling ledger files' own overdue trims are measured and queued with procedure notes. Self-score 9: + deliverable verified two independent ways and re-measured (trigger-clear, dashboard); + both refusal gates resolved by their governing rules (reconcile, owner decision) rather than forced or abandoned; + a multi-session orientation under-count caught, measured, and converted into a self-contained queued item; - Phase 0 repeated the inherited "1 HIGH flag" claim instead of extracting the flag list at orientation; - one extra commit cycle discovering P1_UNDOCUMENTED.

```handoff
session: S699
date: 2026-09-17
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Standing pedigree-drawing directive decision (S698 next-step A; decision/grooming session, docs-only -- no TDD phases). Owner sign-off via AskUserQuestion ("Sign off + itemize residuals"): the S643 standing top-priority note REMOVED from BACKLOG.md; the 3 measured census residuals itemized as ordinary-priority Housekeeping items; agent memory updated to RETIRED.
what_was_done: Grounded the decision by re-tallying the committed S696 census CSV live (not quoting handoffs): full-CSV totals a/c1/c2/e/f=0 everywhere, b=8 (all Real 375, all off-centre), c curved-chord=1,668 (1,667 Real 375 + 1 Track C), d=2 adjacent (1 per fixture). New finding: the 8 class-b rows split into 2 numerical-noise rows (__union_75 -2.3e-07 units, __union_132 8.7e-09 units -- artifacts of the exact >1e-6 px predicate) and 6 real 0.5-1.5-unit (60-180 px) minSep-bound offsets. Posed a 4-option AskUserQuestion; owner picked sign off + itemize. Removed the standing note (BACKLOG.md:6-11), added 3 self-contained Housekeeping items (b-investigation READY M, arc-modelling measurement pass READY M, d-adjacent assessment READY S) each with CSV row ids and coupled article-prose warnings. Rewrote the agent-side standing-priority memory to RETIRED. Phase 0 backfill 6ca5efdd (S698 close-out commits); claim 1ed16e63; deliverable d6e23e40; records 8127201d (CHANGELOG S699 entry; no PROJECT_LEARNINGS entry owed -- the finding is forward-carried in the live item). No suite run: docs-only, nothing in the package build/test path changed.
next_steps: (A) SESSION_NOTES.md trim (READY, Effort S; the dashboard's one HIGH flag; ~11,140 lines). (B) Issue #148 MHC haplotype reporting (genetic-metrics sequencing audit's last open item). (C) The 3 new census-residual items (ordinary priority; d-adjacent is smallest, Effort S). (D) Push decision (owner call): 17 commits ahead after close-out; last pushed state CI-green; unpushed span believed docs/comments/prose-only -- verify with git diff origin/master..HEAD --stat before pushing (estimate, not measured). (E) Informational: Learning 749 duplicate at PROJECT_LEARNINGS.md:2195; dashboard copy stale (v2.14.0 vs v2.18.0); untracked leftovers unchanged; package-split disposition still awaiting owner.
key_files: BACKLOG.md:1-13 (note gone); BACKLOG.md:96-140 approx (3 new Housekeeping items, re-grep); CHANGELOG.md:19 (S699 entry); docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-02_findings.csv (grounding artifact); ~/.claude/projects/-Users-rmsharp-Development-nprcgenekeepr/memory/pedigree-drawing-standing-priority.md (RETIRED).
gotchas: The standing top-priority note is GONE -- older handoffs/forward-carries/learnings referencing it are historical, not live. BACKLOG Housekeeping gained 3 blocks at its top (net +36 lines) -- re-grep line numbers. Census counts going forward: c curved-chord 1,668 total (1,667 Real-375-only), d 2 total (1 Real-375-only) -- older "1,667"/"d=1" are Real-375-scoped. failed=0 expectation stays 2,370 blocks but is INHERITED from S698, not re-measured -- do not cite S699 as a fresh baseline. The class-b item's 2-noise/6-real split couples to both the census predicate and the article's "8 of 237" figure; both couplings are flagged inside the item.
runtime_smoke: n/a -- docs-only (BACKLOG/ledger/notes/memory edits; no runtime behavior change)
changelog_ref: 2026-09-17 S699 entry (ad hoc), 8127201d
commit: 87dfb4dc
```
Owner decision session: the S643 standing pedigree-drawing top-priority directive is retired by explicit owner sign-off; residual fidelity work continues at ordinary priority via 3 new self-contained Housekeeping items. Self-score 9: + decision grounded in a live CSV re-tally (surfaced the class-b noise/real split and the Real-375 scoping of older counts before they entered the items wrong); + items written as archaeology-free specs; + memory loop closed same-session; - the 2-vs-6 class-b split was derived after the owner heard "8" in the decision brief; - no independent re-render to confirm today's engine state matches eeacd06c (relied on S698's day-old live measures).

```handoff
session: S698
date: 2026-09-17
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Pedigree-drawing housekeeping re-measure pass (standing pedigree-fidelity family, owner-picked via AskUserQuestion at Phase 0; DEVELOPMENT_WORKSTREAM, docs/comments-only -- no TDD phases, S692/S694/S695/S697 precedent). All 3 BACKLOG Housekeeping items re-derived live under the QP engine and closed: D2-dogleg comment rewritten with its falsification history, 5-pair proximity residual closed resolved-by-construction with no code change, both stale article mate-line sites rewritten.
what_was_done: Measured before editing (scratchpad/s698_remeasure.R, kept): (A) 0 __proj_ nodes among the real 375 fixture's 1,456 rectilinear nodes -- D2 dogleg structurally unreachable again via S678 Decision 2 (pinned test_comparePedigreeStructure.R:687); finding-1 comment in test_resolveEdgeNodeCollisions.R rewritten with the full history (true 2026-08-15 -> S668 census 56 -> dead S678), dated S698; the sibling test_addRectilinearWaypoints.R 0-projection expectation confirmed general (no edit needed). (B) all 5 S667 pairs re-measured by REAL-id occurrence sweep (indices are allocation-order artifacts, Learning 751): min same-row named-pair distance 480 px vs 25 px limit; independent global class (a) scan 0, agreeing with the committed S696 census CSV (a=0, b=8, c1/c2=0, d=1 adjacent); closed resolved-by-construction. (C) Track B live: all 4 union dots exactly centered (0.00 px from midpoint, mates 120 px apart), matching the committed S675 figure the prose contradicted; kinship2-fidelity-validation.qmd:150 paragraph + :294 caveats bullet rewritten (remaining differences: the union-dot marker itself, issue #161, and the 8-of-237 off-centre residual where minSep floors bind). Verification: spell clean, wordlist gate green directly (before the suite, Learning 750), lint 0 on touched test file (loaded), full unfiltered regression 2,370 blocks failed=0 error=0 skipped=182 (S696/S697 baseline exactly). Phase 0 backfill 3c11df28; claim 3daa4001; deliverable 262c65be; records efd67743 (CHANGELOG entry, Learning 751, 3 BACKLOG blocks removed).
next_steps: (A) The tagged pedigree-fidelity queue is now EMPTY -- the standing top-priority note (BACKLOG:6-11) still stands; next Phase 0 should ask the owner whether the directive is satisfied (sign-off to remove the note) or whether the remaining measured residuals (census b=8 off-centre unions, 1,667 c-curved-chord findings) should become items. (B) SESSION_NOTES.md trim (READY, Effort S; the dashboard's one HIGH flag; ~11,050 lines). (C) Issue #148 MHC haplotype reporting. (D) Push decision (owner call): 11 commits ahead after close-out; local regression clean; last pushed state CI-green. (E) Informational: Learning 749 duplicate at PROJECT_LEARNINGS.md:2195; dashboard copy stale (v2.14.0 vs v2.18.0); untracked leftovers unchanged.
key_files: tests/testthat/test_resolveEdgeNodeCollisions.R:20-40 (rewritten finding 1); vignettes/articles/kinship2-fidelity-validation.qmd:150-172 and :294-306 (rewritten sites); scratchpad/s698_remeasure.R (reusable re-measure harness); CHANGELOG.md:19 (S698 entry); PROJECT_LEARNINGS.md:2198 (Learning 751).
gotchas: failed=0 expectation stays 2,370 blocks. BACKLOG Housekeeping shrank by 3 blocks (net -63 lines) -- re-grep line numbers; the standing top-priority note is UNTOUCHED and needs owner sign-off to remove. The rewritten article paragraph embeds live-measured values (0.00 px centering, 8-of-237 residual) -- re-verify it after any union-positioning change; the census (b) count is 8 per the committed CSV, NOT the 12 some older forward-carries quote. The finding-1 comment deliberately preserves its falsification history -- do not simplify it to a bare present-tense claim. "5 5" suite output lines are pre-existing print noise.
runtime_smoke: n/a -- docs-only (test comments and article prose; no runtime behavior change)
changelog_ref: 2026-09-17 S698 entry (BL-pedRemeasure), efd67743
commit: 49ae8ac1
```

```handoff
session: S697
date: 2026-09-17
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. QP Migration Path Phase 4 cleanup (BACKLOG Up Next item 1, owner-picked via AskUserQuestion at Phase 0; DEVELOPMENT_WORKSTREAM, docs-only -- no TDD phases, S692/S694/S695 precedent). All 7 stale doc-comment sites in R/makePedigreeDiagramData.R now describe the QP engine; the plan doc carries a dated Phase 4 record; the joint-QP-solver migration's 4-phase path is CLOSED.
what_was_done: Inventoried before editing (the plan's own gate grep -- 3 comment hits -- plus a broadened sweep over .kMax*/Tier/Track-7/b1AnchorRelativeX/de-collision vocabulary; every hit read and classified live vs explicitly-historical vs stale). Fixed the 7 stale sites: the S667 component comment's mechanism list and named deleted pass; the qualifies() relocation comment's claim the deleted b1AnchorRelativeX() branch still calls it (the S666 conditional-shift pass is its only caller, verified at the one real call site); the second-sweepMinSepBackstop() rationale's named deleted pass; the S666 chain-rule "Tier 3/collision-avoidance (also unchanged)" framing; the orphaned 39-line present-tense S647 block (removed; identity folded into the Phase 2 replacement comment, deleted symbol de-named); makePedigreeMatingLayout()'s exported roxygen re-attributing the issue-#145 male-left rule from the deleted "Tier 3 formula (S8.1)" to the seeding rules + QP row-order preservation (behavioral claim kept -- pinned by test_positionMatingUnitForest.R:303). devtools::document() regenerated man/makePedigreeMatingLayout.Rd only. First full regression failed=1 (wordlist gate: "QP" first reached a rendered Rd); QP added to inst/WORDLIST (BJL/LOD precedent); final unfiltered run 2,370 blocks failed=0 error=0 skipped=182 (S696 baseline exactly); gate grep returns nothing; lint 0 (loaded). Phase 4 record written into the plan doc. Claim b81bfecc; deliverable 43ed9a24; records 20088807 (CHANGELOG entry, Learning 750, BACKLOG block removed).
next_steps: (A) SESSION_NOTES.md trim (READY, Effort S; the dashboard's one HIGH flag; ~10,930 lines). (B) Pedigree-drawing housekeeping re-measures (standing directive; READY, Effort S-M each): D2-dogleg reachability comment, 5-pair proximity residual re-measure under QP, kinship2-fidelity-validation.qmd:150-163 rewrite. (C) Issue #148 MHC haplotype reporting. (D) Push decision (owner call): 4 commits ahead after close-out; local regression clean; last pushed state CI-green. (E) Informational: Learning 749's body duplicated as a stray bullet at PROJECT_LEARNINGS.md:2195 (S696 paste artifact, reported not fixed); dashboard copy stale (v2.14.0 vs v2.18.0); untracked leftovers unchanged.
key_files: R/makePedigreeDiagramData.R:869,948,1011,1038,1162,1596 (the 7 sites post-edit); man/makePedigreeMatingLayout.Rd (regenerated); inst/WORDLIST:168 (QP); docs/planning/pedigree-diagram-joint-qp-solver-plan.md:448 (Phase 4 record); CHANGELOG.md:19 (S697 entry); PROJECT_LEARNINGS.md:2196 (Learning 750).
gotchas: failed=0 expectation stays 2,370 blocks. BACKLOG.md's FIRST Up Next section is now EMPTY (the QP item was its only block) -- LabKey/package-split live under the SECOND Up Next header; line numbers shifted net -8. A NEW acronym in EXPORTED roxygen fails test_wordlist_coverage.R even when the word is all over internal comments -- run spelling::spell_check_package() before the full suite when touching exported roxygen (Learning 750). The QP plan is CLOSED; the Phase 2 replacement comment deliberately KEEPS past-tense pass vocabulary (gate greps only the 3 symbol names) -- do not strip it as "unfinished cleanup". The "5 5" lines in silent suite output are pre-existing print noise.
runtime_smoke: n/a -- docs-only (comments, one regenerated Rd, one WORDLIST line; no runtime behavior change)
changelog_ref: 2026-09-17 S697 entry (BL-qpPhase4), 20088807
commit: daafea9f
```

```handoff
session: S696
date: 2026-09-17
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Ascender-stub cosmetic fix (found S679, owner visual gate; standing pedigree-fidelity family; owner-picked via AskUserQuestion at Phase 0). .resolveEdgeNodeCollisions() corridors now rejoin a stranded bar point's kid directly instead of climbing back to bar level and leaving 9-27 px of dangling duplicate ink. DEVELOPMENT_WORKSTREAM, full TDD RED -> GREEN (REFACTOR posed, owner-skipped); approach + all gates owner-ratified; owner visual gate ACCEPTED both changed renders.
what_was_done: PRE-RED located the defect in data and crop-verified it -- the dangling ink is the [barY, corridorY] span drawn TWICE (riser + kid-descent top) at invisible bar points with no surviving bar-level or upward edge (84 on the real 375 fixture); drop rejoins never dangle (continuous with the union line). S679's candidate 2 (zero-width bars) refuted: they can never jog. A measured spike (applied, quantified, reverted; scratchpad/s696_spike.patch) proved the direct rejoin: stubs 84 -> 0, zero node movement, census byte-identical, blast radius exactly 2 test blocks + 1 screenshot. RED (d3e15162): 6 new blocks incl. the FROM-side reversed-orientation pin and the real-fixture zero-stubs invariant, verified failing for measured reasons, zero collateral. GREEN (e6fb81a7): the bypass (invisible endpoint + exactly one surviving downward vertical -> corridor connects to the kid, descent dropped, bar point left unreferenced/unmoved) with direction-coherent emission; D-2 walker generalized (collapse only 1-in/1-out jogs, parentless components bridge through shared kids); first_cousin rectilinearEdges 33 -> 31 CHANGED S696. Full clean regression 2,370 blocks failed=0 error=0; lint 0; ground truth pre-gate 42/42 twins triples + 39/39 nets + S691 exemplar validation ALL PASS; twins screenshot recaptured live (pixel diff purely subtractive) + first_cousin exemplar re-rendered (other 4 byte-identical), both owner-accepted (eeae9914); census CSV refreshed (eeacd06c, also folds in S690's never-committed deltas); NEWS plain-language entry (05c3313e), spell check clean. Claim 2e5eee98.
next_steps: (A) QP Migration Path Phase 4 cleanup (now BACKLOG Up Next item 1; READY, Effort S: grep R/ doc-comments for stale deleted-tier/.kMax* references). (B) SESSION_NOTES.md trim (READY; the dashboard's one HIGH flag; ~10,900 lines). (C) Issue #148 MHC haplotype reporting (genetic-metrics sequencing audit's last open item). (D) Push decision (owner call): ~76 commits ahead after this close-out; local full regression clean, last pushed state CI-green. (E) Informational: dashboard copy stale (v2.14.0 vs v2.18.0); untracked leftovers unchanged.
key_files: R/makePedigreeDiagramData.R:2708 (bypass + emission; roxygen :2454); tests/testthat/test_resolveEdgeNodeCollisions.R:973 (S696 section); tests/testthat/test_comparePedigreeStructure.R:301 (walker changes); tests/testthat/test_examplePedigreeFixtures.R:203 (first_cousin re-pin); vignettes/articles/shiny_app_use/diagram_twin_connectors.png + vignettes/articles/pedigree-diagram-img/exemplar-first_cousin-rectilinear.png (owner-accepted renders); scratchpad/s696_spike.patch, scratchpad/s696_twin_diff.png (evidence); PROJECT_LEARNINGS.md (Learning 749).
gotchas: failed=0 expectation is now 2,370 blocks (was 2,364). Screenshot digest baseline moves to any commit >= eeae9914; a layout digest hashes edge from/to, so an orientation-only change alters the digest without changing ink (Learning 749). Waypoint edge DIRECTION is load-bearing (terminal->waypoint = parent-side, waypoint->terminal = child-side) -- new corridor emissions must preserve it or the D-2 walker misclassifies. Orphaned degree-0 size-0 bar points now exist in rectilinear layouts by design. BACKLOG line numbers shifted (ascender block removed); re-grep.
runtime_smoke: Twins screenshot recaptured live through the real app (upload, QC, twin sidecar, focal trim, Diagram render) under the fixed engine; explicit NPRC_RUN_E2E=true run of test-e2e-pedigree-module.R: 16/16 blocks, 55 expectations, 0 failed (exactly the S679 baseline); full clean regression 2,370 blocks failed=0 error=0.
changelog_ref: 2026-09-17 S696 entry (BL-ascenderStub), d9da420a
commit: 77ba72ec
```

