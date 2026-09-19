# Session Notes

**Purpose:** Continuity between sessions. Each session reads this first
and writes to it before closing out.

**Archived 612 record(s), 1998-12-06 → 2026-08-12** into
[`docs/archive/SESSION_NOTES-through-2026-08-12.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-12.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 40 record(s), 2026-08-11 → 2026-08-13** into
[`docs/archive/SESSION_NOTES-through-2026-08-13.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-13.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 76 record(s), 2026-01-26 → 2026-08-15** into
[`docs/archive/SESSION_NOTES-through-2026-08-15.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-15.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 170 record(s), 2026-08-19 → 2026-09-17** into
[`docs/archive/SESSION_NOTES-through-2026-09-17.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-17.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 19 record(s), 2026-08-14 → 2026-09-18** into
[`docs/archive/SESSION_NOTES-through-2026-09-18.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-18.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

------------------------------------------------------------------------

## ACTIVE TASK

### Session 718 Handoff Evaluation (by Session 719)

**Score: 8/10.** **What helped:** gotcha “expect ~1 self-reference
commit past the `CHANGELOG.md` frontier; measure it” held exactly
(`312996b0`, 1 commit); the `BACKLOG.md:133`/`:119` pointers and “~5
commits ahead, recount with `git rev-list`” both measured true at
orientation (5); the untracked-leftovers list matched `git status` line
for line; the 2,437-block baseline (failed=0 error=0 skipped=184
warning=40) re-measured identically this session (4.3 min); S718’s claim
commit (stub + pending receipt + claim entry) was a ready template.
**What was missing:** nothing this deliverable needed — it was
operator-directed from the methodology fork, so next-steps (A)–(E) did
not apply by design. **What was wrong:** one claim. The handoff’s Ledger
line and the close-out `CHANGELOG.md` entry say all three trim-managed
ledgers were “verified trigger-not-firing at close-out”, but on the
committed close-out head (`312996b0`) trimmer 1.1.2 reports
`SESSION_NOTES.md` FIRES (70,138 B against 65,536 B; re-run this session
in an isolated worktree — `HANDOFFS.md` 56,781 B and `CHANGELOG.md`
37,090 B did not fire). Likely the check ran before the handoff text was
appended (an estimate; the order is not recorded). Low impact — the P10
sync replaced the trimmer and its budget, so no trim was ever due — but
a session trusting it would have skipped an owed trim; corrected by this
session’s own ledger entry, since a committed entry is never edited.
**ROI:** high.

### What Session 719 Did

**Deliverable:** BL-57 phase P10 for this project — **DONE**
(operator-directed via the methodology fork’s
`bl57-p10-nprcgenekeepr-launch-prompt.md`; confirmed via
`AskUserQuestion` at Phase 0; docs/process only, no TDD phases, no
push). The framework files are synced to the current methodology
(`v3.7-964-gce14b3f`, local source), this project’s `SESSION_NOTES.md`
extension to `methodology_trim.py` is re-applied, and `CHANGELOG.md` /
`HANDOFFS.md` are at the current ledger rules (`bin/status` reads
`present` for both). **Started/completed:** 2026-09-19 (single session).
**Ledger:** one `CHANGELOG.md` entry per commit (steps 2–7, the BACKLOG
re-scope, this close-out). FM \#28 reduction: none this session —
`SESSION_NOTES.md` (71,192 B) is over the *old* 65,536 B budget but
under the new default; a trim is one dry-run-verified command away
(`--cut 1 --force`: L1–L3 OK, → 4,018 B) and is left as an owner
decision (`BACKLOG.md:119`), not done here (scope).

**What actually happened, in order:** 1. **Phase 0:** reconcile
backfilled 1 commit (`74243f04` for `312996b0`, the predicted shape). CI
10/10 green. Dashboard 96/100. Picker → P10. Claim `d064993a`. 2.
**Measure:** saved the trimmer patch before the sync (49 added, 0
removed); `bin/status` and the `--force` dry run matched the prompt’s
facts (13 written, 2 created). Only differences: source version printed
`v3.7-964-gce14b3f` (one docs-only fork commit past the prompt’s
`c20d6ab`, touching no distributed file), and `bin/_manifest.py` lists
`methodology_trim.py` at `:50`, not `:45`. 3. **`00b8a4ca`** six
`.Rbuildignore` patterns + two `.gitignore` entries (both tool outputs
ignored, matching `dashboard_history.jsonl`). **`b773ddb6`** forced
sync, exactly the 15 listed files; `NO_CONFIG` confirmed. **`63b3286f`**
patch re-applied (`git apply --check` first): `--check` no longer
`NO_CONFIG`; dry run `L1_OK`–`L3_OK`. 4. **`ba1f0135`** `CHANGELOG.md`:
3-line seed paragraph + blank, 0 deletions, all 540 old lines survive in
order. **`47364f51`** `HANDOFFS.md`: `:62`–`:117` replaced by seed
`:89`–`:148` (17 ins / 13 del); §9.8 with `62 117 HANDOFFS.md` printed
*only the block changed*; lines 1–61 and the 208-line tail
byte-identical. (My first attempt’s anchor assert fired before any write
— the real last line has a 2-space indent.) 5. **`2f451d1d`**
`CLAUDE.md`: the `methodology_trim.py` checklist corrected (the fork’s
`main` now distributes it), the per-sync procedure written out, the
bare-`[BL]` and empty-`## 2026-08` legacy forms recorded, budget choice
recorded. Every new claim was run first. **`f88afcb2`** `BACKLOG.md:119`
re-scoped (its “never adopted” premise was made false by the sync). 6.
**Verification:** trimmer dry runs `L1_OK`–`L3_OK` on all three ledgers
(43 / 11 / 20 records); `R CMD build` tarball contains none of the
tooling or ledger files; full suite = baseline exactly (blocks=2437
failed=0 error=0 skipped=184 warning=40, 4.3 min); no CI file references
any touched path.

**Self-assessment (Session 719): 9/10.** **Strengths:** (1) measured
before acting and saved the irreplaceable input (the patch) before the
sync overwrote it; (2) every rewrite was guarded — anchored asserts,
ordered-survival and byte-identity checks, the prompt’s own §9.8 — and
the one guard that fired did so before a write; (3) each claim written
into `CLAUDE.md`/`BACKLOG.md` was run first (plain-sync exit 2,
bare-`[BL]` count 13, each ledger’s size against both budgets); (4)
tight scope — no push, no trim, no `context_budget.py` adoption, S718’s
own inaccuracy reported not silently fixed. **Weaknesses:** (1) the
claim entry lacks the *(in progress)* marker the newly synced rules ask
for — the rules arrived after the claim, and a committed entry is never
edited; (2) `HANDOFFS.md` still differs from the current seed — the seed
has a longer front matter and two later sections (`Three files…`,
`Citing the gate run`) that the P10 steps do not ask for, so they were
left out; by instruction, but a residual divergence; (3) took the tool’s
byte-budget default without an owner ask (sanctioned as “this project’s
call”, flagged as open).

**Next steps (specific):** (A) **Owner: push decision** — ~16 commits
ahead after close-out (recount:
`git rev-list --count origin/master..HEAD`; 5 at orientation, 14 at this
handoff’s write, plus the records and sha commits — the last two are an
estimate). The push is the first CI validation of the new root files and
build patterns (gotcha 2). (B) **Owner decision + evaluation:**
`BACKLOG.md:119` — calibrate/adopt or delete `context_budget.py`, and
settle the trim budget (196,608 B default vs 65,536 B). (C) `Suggests:`
audit (READY, S, `BACKLOG.md:140`). (D) Owner decisions pending:
package-split disposition (`BACKLOG.md:71`), REUSE registration
(`BACKLOG.md:162`). (E) Informational: the dashboard copy is now current
(v2.18.0; the sync fixed the v2.14.0 staleness S718 flagged); untracked
leftovers unchanged; LabKey remainder BLOCKED.

**Key files:** `CLAUDE.md:277` (per-sync procedure) and `:279` (ledger
legacy forms), `methodology_trim.py:301` and `:377` (the local
extension), `CHANGELOG.md:17` (rules pointer + `ledger-format: 2`),
`HANDOFFS.md:62`/`:64` (Size section + `handoffs-format: 2`),
`BACKLOG.md:119` (re-scoped item), `HANDOFFS.md:150` (S719 receipt).

**Gotchas for the next session:** (1) **The next plain `bin/sync`
refuses `methodology_trim.py`** (locally modified, exit 2) — the
four-step procedure is at `CLAUDE.md:277`;
`git show 63b3286f -- methodology_trim.py` is the patch. (2) **The push
is the first CI validation of P10.** `R-CMD-check.yaml` runs
`error-on: "warning"` (Learning 669: a
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
warning once passed locally and tripped CI). I did not run a full
`R CMD check` — only the tarball listing (none of the new files ship)
and the full test suite; no `.R` file was touched, so the lint checklist
did not apply. My *estimate*, not a measurement: green, since zero
package files changed. If red, that is new information — report, don’t
fix inline. (3) The final sha commit carries its own `CHANGELOG.md`
entry, so expect 0 undocumented commits past the frontier at next Phase
0 (unlike S717/S718’s 1); measure it. (4) `context_budget.py` is
installed but uncalibrated — do **not** run `--status` and read red
findings as P10 defects; the seed ceilings are the fork’s own.
`quality_ratchet.py --run` reports `0/0` (no gates declared). (5) Under
the new rules a claim commit’s entry is marked *(in progress)* and
close-out adds its own entry; entries are never edited. (6) The fresh
baseline is still 2,437 blocks (4.3 min). (7) `git worktree list` shows
5 `.claude/worktrees/wf_*` entries this session did not create —
untouched (my own temporary worktree was removed).

### Session 717 Handoff Evaluation (by Session 718)

**Score: 9/10.** **What helped:** next-step A named this session’s exact
deliverable with the `BACKLOG.md:96` pointer; gotcha 3 predicted the
1-commit backfill shape and it measured exactly 1 (`4cfe2dad`); gotcha 2
pre-framed the in-flight docs-only CI round precisely (lint green + 3 in
progress at orientation; all completed green in-session — the S717 open
loop is closed); gotcha 4 (origin in sync; recount before re-reporting
an ahead-count) held (0 ahead at orientation). **What was missing:**
nothing material — the item was DECISION NEEDED, so the population
census was this session’s own work by design; the only unflagged wrinkle
was that the S687 item’s “e.g.” enumeration was non-exhaustive (the
census found 15 blocks, incl. the S568 Compounding-Loop block it didn’t
name) — discoverable only by the census itself, low cost. **What was
wrong:** nothing found; every checked claim held. **ROI:** high —
orientation to owner pick in one pass.

### What Session 718 Did

**Deliverable:** Pointer-block sweep — **DONE, owner-ratified**
(S687-filed BACKLOG Housekeeping item, DECISION NEEDED; owner-picked via
`AskUserQuestion` at Phase 0, then “remove all 15” ratified via a second
`AskUserQuestion` at the gate, over a keep-S457/S458 variant and a hold;
docs-only maintenance, no TDD phases). All 15
`[ ]`-marked-but-fully-RESOLVED pointer blocks removed from `BACKLOG.md`
(429 lines) plus the completed sweep item itself (15 lines): 1,119 → 675
lines. **Started/completed:** 2026-09-19 (single session). Phase 0
backfill `94b39dc7`; claim `f058a8de`; deliverable `b7cc2508`; records
commit follows this handoff, then a self-reconcile sha commit.
**Ledger:** claim + deliverable + close-out entries in `CHANGELOG.md`;
the sweep item removed in the deliverable commit. FM \#28 reduction: the
deliverable IS the reduction (444 lines out of a Phase-0-adjacent
mandated read); all three trim-managed ledgers verified
trigger-not-firing at close-out.

**What actually happened, in order:** 1. **Phase 0:** reconcile
backfilled 1 commit (`4cfe2dad`, the predicted recurring self-reconcile
shape, measured 1). CI at orientation: lint green + 3 in-progress on the
S717 close-out head; all completed green in-session, plus scheduled
shinytest2 green — 5/5, S717’s open loop closed. Dashboard 96/100. Owner
picked the sweep from the 4-option picker. 2. **Census:** full
`BACKLOG.md` read (all 1,119 lines) → population = 15
`[ ]`-marked-but-RESOLVED blocks (the item’s “e.g.” list named 13; the
S545/S549 audit block and the S568 Compounding-Loop block completed it).
The 18 genuinely-open `[ ]` items excluded; the borderline S518
BACKLOG-compression item excluded as recurring-maintenance per its own
S606 correction. 3. **Verification before the gate:** every resolving
session (S457–S568) has dated ledger entries across `CHANGELOG.md` +
shards (3–7 headings each; 0 FM \#27 gaps — vs. the 2 that S529’s sweep
found); depth spot-check on the densest block (S565 Track B) confirmed
the shard entry carries the block’s full verification detail; no open
sub-threads (S568’s untitled-folder finding already stands as its own
item, which stays); zero live cross-references from
`CLAUDE.md`/`SESSION_NOTES.md`/`HANDOFFS.md`. 4. **Gate:** owner
ratified “remove all 15.” 5. **Execution `b7cc2508`:** guarded
line-range script (`scratchpad/s718_sweep.py` — first/last-line anchors
verified per range before writing; the guard genuinely fired once on a
wrong wrap-boundary anchor and refused, then passed after correction);
diff verified deletion-only (429/0); the completed sweep item removed in
the same commit; the `CHANGELOG.md` deliverable entry maps every removed
block to its resolving session(s) and cites
`git show f058a8de:BACKLOG.md` for full-text provenance. 6.
**Close-out:** no new learning appended (routine application of the S686
convention + existing verification discipline, no new signal — stated,
not silent, per the S711/S712 precedent); this evaluation + handoff;
receipt; ledger entries.

**Self-assessment (Session 718): 9/10.** **Strengths:** (1) census-first
— the ratification gate presented a measured population (15 blocks,
per-block ledger verification) rather than the item’s own unverified
enumeration; (2) the anchor-guarded deletion script refused once for the
right reason and never wrote a bad state; (3) tight scope — zero package
files, the borderline S518 item deliberately excluded rather than swept
in. **Weaknesses:** (1) the depth spot-check covered 1 of 15 blocks
(existence was verified for all 15, but full block-vs-ledger content
diffs were judged disproportionate — disclosed at the gate); (2) one
wasted script iteration on the wrap-boundary anchor.

**Next steps (specific):** (A) `Suggests:` audit (READY, S — now the top
READY Housekeeping item, `BACKLOG.md:133`). (B) `context_budget.py`
evaluation (READY, S, `BACKLOG.md:119`). (C) Push decision (owner): ~5
commits ahead after close-out (recount with
`git rev-list --count origin/master..HEAD`); docs-only delta, so the
next push’s CI round is docs-only validation. (D) Owner decisions
pending: package-split disposition (`BACKLOG.md:71`), REUSE registration
(`BACKLOG.md:155`). (E) Informational: dashboard copy stale (v2.14.0 vs
v2.18.0); untracked leftovers unchanged (+ this session’s
`s718_sweep.py`, same class); LabKey remainder BLOCKED; chromote
root-cause optional.

**Key files:** `BACKLOG.md` (post-sweep 675-line file),
`CHANGELOG.md:29` (S718 entries incl. the per-block removal map),
`HANDOFFS.md:146` (S718 receipt), `scratchpad/s718_sweep.py:1` (the
guarded deletion script).

**Gotchas for the next session:** (1) **The fresh full-suite baseline is
still 2,437 blocks** (failed=0, error=0, skipped=184, warning=40) — this
session touched no package files; S716’s gotchas 2–5 (e2e opt-in via
`NPRC_RUN_E2E`, serialization-coupled formatter greps, NEWS `\##` render
check, screenshot recipe) apply verbatim. (2) `BACKLOG.md` at 675 lines
is deliberately sparse — the full text of any removed block is one
command away (`git show f058a8de:BACKLOG.md`); sparseness is not a ghost
session. (3) Expect ~1 self-reference commit past the CHANGELOG frontier
at next Phase 0 (the recurring shape); measure it. (4) The chromote
item’s “CDP-timeout fallback fix below” phrase was stale BEFORE this
sweep (the referenced block is long gone) — a one-word staleness to fix
opportunistically if that item is ever picked up. (5) This session did
not push; the close-out state is local-only until the owner directs a
push.

### Session 716 Handoff Evaluation (by Session 717)

**Score: 9/10.** **What helped:** next-step A was this session’s exact
deliverable, with the recount command (measured 31 at orientation, 33
pushed including the backfill + claim) and the “first remote validation
of S715+S716 package code” framing that made the decision presentable in
one line; gotcha 6 predicted the 1-commit backfill shape and it measured
exactly 1 (`b229a305`). **What was missing:** nothing material — a push
session touches no package internals, so the handoff’s depth was
sufficient by construction. **What was wrong:** nothing found; every
checked claim held (baseline, CI state, ahead-count). **ROI:** high —
orientation to owner pick in one pass.

### What Session 717 Did

**Deliverable:** Owner-directed push to `origin/master` — **DONE** (S716
next-step A, owner-picked via `AskUserQuestion` at Phase 0; process/ops
session, no code changes, no TDD phases; S711 precedent). Pushed 33
commits (`1788e2b8..047d7f74`), spanning S712–S716: the census
assessments, the S715 curved-connector arc-verified roundness fix, the
S716 MHC display rounding + docs, and five sessions of records. **All 4
on-push CI workflows green on `047d7f74`:** lint 4m41s, test-coverage
10m26s, pkgdown 18m40s, R-CMD-check 34m16s (run ids
35425960304/340/312/299). Watched to completion via a 2-min background
poller, then confirmed via `gh run list` directly — this was the FIRST
remote validation of the S715 and S716 package code.
**Started/completed:** 2026-09-19 (single session). Phase 0 backfill
`aa003382`; claim `047d7f74` (deliberately before the push so the pushed
head carries the session claim); records commit follows this handoff,
then a self-reconcile sha commit, both pushed immediately (their own
docs-only CI round is verified at the next session’s unconditional Phase
0 CI check, per the S706/S711 precedent). **Ledger:** claim entry +
push-outcome entry in `CHANGELOG.md` (this close-out). Nothing removed
from `BACKLOG.md` (the push was a handoff next-step, not a BACKLOG
block). FM \#28 reduction check: nothing to trim — all three ledgers
verified under budget at the S716 close-out and gained only this
session’s entries.

**Self-assessment (Session 717): 9/10.** **Strengths:** (1)
claim-before-push kept the pushed head self-describing; (2) waited for
the full 4-workflow matrix and re-verified the watcher’s claim directly
before recording it; (3) tight scope — no package files touched.
**Weaknesses:** (1) the close-out push’s own CI round is deliberately
not watched (docs-only delta on a just-verified tree) — a defensible but
real open loop handed to the next session’s Phase 0; (2) a routine push
session yields no new learning — correct (no signal), stated explicitly
rather than silently.

**Next steps (specific):** (A) Pointer-block sweep ratification
(DECISION NEEDED, M — see the BACKLOG Housekeeping block). (B)
`Suggests:` audit (READY, S). (C) Owner decisions pending: package-split
disposition, REUSE registration. (D) Lower priority: `context_budget.py`
evaluation (READY, S), chromote pinned-Chrome root-cause (optional, M).
(E) Informational: dashboard copy stale (v2.14.0 vs v2.18.0); untracked
leftovers unchanged; LabKey remainder BLOCKED; origin/master now in sync
— don’t re-report the “N commits ahead” item from stale handoffs.

**Key files:** `HANDOFFS.md` (S717 receipt), `CHANGELOG.md` (S717
entries), `BACKLOG.md:96` (pointer-block sweep, now the top DECISION
NEEDED item), `BACKLOG.md:148` (`Suggests:` audit).

**Gotchas for the next session:** (1) **The fresh full-suite baseline is
still 2,437 blocks** (failed=0, error=0, skipped=184, warning=40) —
neither this session nor the push touched package files; S716’s gotchas
2–5 (e2e opt-in, serialization-coupled greps, NEWS `\##` check,
screenshot recipe) still apply verbatim. (2) The close-out push triggers
one more CI round on the records/self-reconcile head — expect
`completed success` at Phase 0’s `gh run list`; if red, that is NEW
information (docs-only delta), report-don’t-fix per the standing
convention. (3) Expect ~1 self-reference commit past the CHANGELOG
frontier at next Phase 0 (the recurring shape); measure it. (4)
origin/master is in sync as of this session — recount before ever
re-reporting an ahead-count.

### Session 715 Handoff Evaluation (by Session 716)

**Score: 9/10.** **What helped:** next-step A was this session’s exact
deliverable, and the BACKLOG block was a complete brief — all three
polish items with exact pointers
([`DT::formatRound()`](https://rdrr.io/pkg/DT/man/formatCurrency.html)
in `output$mhcSummaryTable`, the “never the reactive or export, tests
pin those” constraint that shaped the whole RED design, the two named
NEWS phrases); gotcha 5 predicted the 1-commit backfill shape (measured
exactly 1, `56c705b8`); gotcha 1’s baseline (2,436/0/0/184/40)
reproduced as 2,437 with exactly this session’s +1 test block; gotcha 2
(an `.Rmd` prose edit owes `test_wordlist_coverage.R`) was applied
directly before carrying anything forward. **What was missing:** (1) no
note that every `test-e2e-*` block is OPT-IN via `NPRC_RUN_E2E=true` —
the “full clean regression” baseline includes them only as skips, so the
suite alone could never validate this session’s rendered-surface change;
cost one failed smoke invocation to discover (long-documented elsewhere,
but absent from the handoff chain’s recurring gotchas). (2) The item’s
[`DT::formatRound()`](https://rdrr.io/pkg/DT/man/formatCurrency.html)
suggestion predates DT 0.34.0’s actual seam (columnDefs render fn, not
rowCallback) — found by the PRE-RED probe, low cost. **What was wrong:**
nothing found; every checked claim held. **ROI:** high.

### What Session 716 Did

**Deliverable:** MHC Haplotype Reporting follow-up polish — **DONE,
owner-ratified at every gate** (S708-filed BACKLOG Housekeeping item,
owner-picked via `AskUserQuestion` at Phase 0; strict TDD for the code
part: PRE-RED probe → RED → GREEN, REFACTOR judged unnecessary at the
owner-approved GREEN exit gate; docs parts owner-scoped pre-RED).
**Started/completed:** 2026-09-18 (single session). Phase 0 backfill
`edab0fdd`; claim `d0cf1f09`; RED `27d06c97`; GREEN `dbd68126`; docs
`c4fb69f3`; NEWS entry `37d17a55`; screenshot `476372e6`; records commit
follows this handoff. **Ledger:** claim + close-out entries in
`CHANGELOG.md`; MHC-polish BACKLOG block removed in the records commit
(the FM \#28 reduction; all ledgers otherwise far under budget).

**What actually happened, in order:** 1. **Phase 0:** reconcile
backfilled 1 commit (`56c705b8`, the predicted recurring self-reconcile
shape, measured 1). CI 4/4 green + scheduled shinytest2 green (S712–S715
work unpushed; CI head is S711’s). Dashboard 96/100. Owner picked MHC
polish from the 4-option picker. 2. **PRE-RED probe
(`scratchpad/s716_probe.R`):** DT 0.34.0’s formatRound lands as a
columnDefs render fn gated on `type !== 'display'` (NOT the guessed
rowCallback); testServer’s renderDT output is a class-“json” character;
server-side payload carries no row data (so full-precision pins live on
the reactive/export, not the payload). Two owner scope decisions taken
pre-RED: NEWS sweep = all 8 verified-stale phrases (not just the 2
named); display digits = 4. 3. **RED `27d06c97`:** 3 formatter grepls
(`"targets":5,"render"`, `DTWidget.formatRound(data, 4`, the
display-type gate) + the reactive-identity and pre-upload-not-ready
pins; confirmed failing at HEAD exactly on the 3 formatter assertions.
4. **GREEN `dbd68126`** (3-line edit, `R/modMarkerGenetics.R:1170`):
`DT::formatRound(DT::datatable(tbl), "frequency", digits = 4L)`. Target
file green; full clean regression 2,437 blocks 0 failed / 0 error (+1 =
the new block; warnings 40 unchanged); `lintr::lint_package()` 0. 5.
**Docs `c4fb69f3`:**
[`modMarkerGeneticsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsUI.md)
`@return` rewritten to the real UI (4 uploads, guidance, all 8
sub-tabs); `document()` scope-checked (only
`man/modMarkerGeneticsUI.Rd`, NAMESPACE untouched). NEWS.Rmd: all 8
stale “no Shiny screen yet” phrases removed (the 2 accurate ones stay) +
owner-ratified same-commit repair of 2 pre-existing swallowed section
headings (`## MHC Haplotype Reporting`, `## Genetic Value Analysis`
rendered as literal `\##` text for want of a preceding blank line —
found by diff-checking the render). NEWS.md re-rendered, diff = exactly
the edits. Wordlist + moduleContract + pkgdown guards green. 6. **NEWS
entry `37d17a55`:** plain-language bullet for the user-visible rounding
change (NEWS.Rmd checklist), render diff = only the bullet. 7. **Phase
3E:** live-app smoke (`scratchpad/s716_smoke.R`, `NPRC_RUN_E2E=true`):
every page-1 frequency cell renders exactly 4 decimals
(0.0500/0.0333/0.0167/0.1000/0.0667), zero full-precision runs, no
module console errors; the full MHC e2e file green (20 assertions
incl. the full-precision CSV download pins).
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors + the known pre-existing 1 W / 1 N untracked-file artifacts. 8.
**Screenshot `476372e6`:** the colony-manager guide’s MHC figure showed
the pre-fix display — re-obligated by this session’s own change;
re-captured live at the original framing (`scratchpad/s716_recapture.R`;
toast dismissed, element crop, top 990 px), caption/fig-alt accurate as
written. 9. **Close-out:** Learning 765 appended; this evaluation +
handoff; receipt; ledger entries; BACKLOG block removed.

**Self-assessment (Session 716): 9/10.** **Strengths:** (1) probe-first
— RED asserted DT 0.34.0’s real seam instead of a guessed one; (2) every
scope expansion (8-phrase sweep, heading repair, screenshot re-capture)
was owner-gated or convention-mandated, none silent; (3) verification
faithful per surface: testServer JSON for the formatter declaration,
live chromote for actual displayed cells, e2e for the untouched export
path — the last being something the default suite structurally cannot
check (e2e is opt-in); (4) docs discipline: `document()` scope-checked,
NEWS.md diff-checked both renders, which is exactly how the pre-existing
swallowed headings were caught. **Weaknesses:** (1) the RED formatter
assertions are serialization-coupled (raw-JSON greps) — a DT/htmlwidgets
serializer change could break them without a behavior change (disclosed
as gotcha 3); (2) one wasted smoke invocation before rediscovering the
`NPRC_RUN_E2E` opt-in gate; (3) one wasted screenshot capture before
checking `get_screenshot()`’s no-overwrite behavior.

**Next steps (specific):** (A) Push decision (owner): now ~31 commits
ahead (recount with `git rev-list --count origin/master..HEAD`); the
delta since the last green CI head includes real package code (S715’s
fix + this session’s render change), so the next push’s CI round is
their first remote validation. (B) Pointer-block sweep ratification
(DECISION NEEDED, M). (C) Owner decisions pending: package-split
disposition, REUSE registration. (D) Lower-priority READY items:
`Suggests:` audit (S), `context_budget.py` evaluation (S), chromote
pinned-Chrome root-cause (M, optional). (E) Informational: dashboard
copy stale (v2.14.0 vs v2.18.0); untracked leftovers unchanged (+ this
session’s s716\_\* scratchpad files, same class); LabKey remainder
BLOCKED.

**Key files:** `R/modMarkerGenetics.R:1170` (the rounded render) and
`:165` (the rewritten `@return`),
`tests/testthat/test_modMarkerGenetics.R:1252` (the new display-rounding
test), `NEWS.Rmd:265-304` (sweep) / `:296`+`:338` (restored headings) /
`:327` (the new bullet),
`vignettes/articles/shiny_app_use/marker_genetics_mhc_haplotype.png`
(re-captured), `PROJECT_LEARNINGS.md:2225` (Learning 765),
`scratchpad/s716_probe.R` / `s716_smoke.R` / `s716_recapture.R` /
`s716_smoke_mhc_summary.png` (evidence + reusable recipes).

**Gotchas for the next session:** (1) **The fresh full-suite baseline is
now 2,437 blocks** (failed=0, error=0, skipped=184, warning=40) — +1 is
the new MHC display test. (2) **e2e blocks are opt-in**
(`NPRC_RUN_E2E=true`, helper-shinytest2.R:201): the 0F/0E regression
claim structurally excludes them; a rendered-surface change owes an
explicit e2e run (Learning 765). (3) The new test’s formatter assertions
grep serialized JSON (`"targets":5,"render"` etc.) — if a DT/htmlwidgets
upgrade breaks them with behavior unchanged, re-derive the grep strings
from a fresh probe (the s716_probe.R pattern), don’t loosen the
display-only property pins. (4) After ANY NEWS.Rmd render: read the
NEWS.md diff AND `grep -c '\\##' NEWS.md` must be 0 (two headings sat
swallowed for many sessions; Learning 765). (5)
`AppDriver$get_screenshot()` refuses to overwrite an existing file —
capture aside and `file.copy(overwrite=TRUE)` (s716_recapture.R is the
recipe, incl. dismissing the QC toast that otherwise overlaps the DT
header). (6) Expect ~1 self-reference commit past the CHANGELOG frontier
at next Phase 0 (the recurring shape); measure it.

### Session 714 Handoff Evaluation (by Session 715)

**Score: 8/10.** **What helped:** next-step A was this session’s exact
deliverable, and the BACKLOG block was a complete brief — mechanism,
code pointers (`R/makePedigreeDiagramData.R` curved branch /
`roundnessBump`), the census predicate function names to port, exactly
which `test_resolveEdgeNodeCollisions.R` pins re-derive, and the
S577/S675 constraints — PRE-RED went straight to the right code with
zero discovery; gotcha 4 predicted the 1-commit backfill shape (measured
exactly 1, `0b4d84bb`); gotcha 2 (“cArc is a NEW metric, never compare
against the frozen 1,668”) framed the census-re-run reporting correctly;
the S712→S713→S714 key-file chain made `s712_layouts.rds` the ready-made
pre-fix “before” render with zero recomputation. **What was missing:**
(1) the exemplar warning pins (`test_examplePedigreeFixtures.R`, S693) —
the fix changes those two pinned expectations and triggers that pin’s
own owner-re-render rule; found only by a warning-text grep sweep; (2)
no note that a same-calendar-day census re-run collides with the frozen
CSV filename (resolved via a `_postfix` suffix). **What was wrong:** (1)
S714’s records commit `8c717ee6` corrupted `HANDOFFS.md` — a 5-line
truncated duplicate S713 receipt header (unclosed fence, no unique
content) left between the S714 prose and the real S713 receipt; repaired
at the S715 claim, disclosed in the claim ledger entry; (2) the article
edit introduced `px` into `test_wordlist_coverage.R`’s scan while
carrying the baseline forward unrun — the suite was silently failing for
a session (Learning 764). Both are close-out mechanics, not
handoff-content errors; every content claim checked held (56 residuals,
587/117, the 21/24 bump figures all reproduced). **ROI:** high.

### What Session 715 Did

**Deliverable:** Curved duplicate-connectors fix — **DONE,
owner-ratified at every gate** (S714-filed BACKLOG Housekeeping item,
owner-picked via `AskUserQuestion` at Phase 0; package-code fix, strict
TDD: PRE-RED probe → RED → GREEN, REFACTOR judged unnecessary at the
owner-approved GREEN exit gate). **Started/completed:** 2026-09-18
(single session). Phase 0 backfill `62b57d76`; claim `d5008091` (+
HANDOFFS fragment repair); RED `d39c66eb`; GREEN `704d7c4c`; WORDLIST
fix `fa4ec9ad`; census/NEWS `69152999`; records commit follows this
handoff. **Ledger:** claim + close-out entries in `CHANGELOG.md`;
curved-connector BACKLOG block removed in the records commit (the FM
\#28 reduction; all ledgers otherwise under budget).

**What actually happened, in order:** 1. **Phase 0:** reconcile
backfilled 1 commit (`0b4d84bb`, the predicted recurring self-reconcile
shape, measured 1); repaired S714’s duplicate-S713 receipt fragment in
`HANDOFFS.md` at claim. CI 4/4 green + scheduled shinytest2 green
(S712–S714 work unpushed, so CI head is S711’s). Dashboard 96/100. Owner
picked the curved-connector fix from the 4-option picker. 2. **PRE-RED
probe (`scratchpad/s715_probe.R`):** continuity first (56 residuals,
587/117 reproduced exactly), then the ladder counterfactual: 114 of 170
arcs truly collide at base 0.2; ladder (0.05–0.60 by 0.05; fewest hits,
tie → closest to 0.2, tie → smaller) clears 42 fully, events 587 → 149,
residual 72; no arc made worse. Unoptimized cost measured (+4.4 s →
needs a prefilter). Named representatives cross-checked against the
current bumped set so every RED pin fails honestly. 3. **RED
`d39c66eb`:** census-replica local helpers + 7 failing assertions —
`.curvedCwVia`/`.bezierMinDistTo` units (hand-derived literals), the
never-worse property (the old bump measurably violates it), the S690 pin
pair `__dup_1X40V5_1 → 1X40V5` keeps 0.2 (chord false positive),
`__dup_0L5AWR_1 → 0L5AWR` clears at 0.5 (6 → 0 hits), residual↔︎true-hit
set correspondence, count 56L → 72L; exemplar warning pins flipped
(linebreeding, half_sib → no warning). All confirmed failing for the
right reason. 4. **GREEN `704d7c4c`** (`R/makePedigreeDiagramData.R`
only): internal
`.curvedCwVia()`/`.bezierPointAt()`/`.bezierMinDistTo()`/`.arcDiscHitCount()` +
preference-ordered ladder walk in the curved branch; conservative
Lipschitz-bound sampled prefilter (counts provably unchanged; resolve
0.21 → 0.95 s); warning parenthetical + doc-comment rewritten. Both test
files green; residuals 72 = probe exactly. 5. **Verification:** full
clean regression 2,436 blocks 0 failed/0 error (warnings 48 → 40 = the
cleared collision warnings); the 1 initial failure was S714’s stale `px`
wordlist flag — root-caused as NOT this diff, fixed `fa4ec9ad` (Learning
764); lint 0 package-wide;
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors + the known 1 W/1 N untracked-file artifacts; census re-run
`69152999` (postfix CSV): cArc 587 → 149 / 117 → 72, Track C fully
clean, class (b) = 6 unchanged (article NOT re-obligated). 6. **Owner
gates:** PRE-RED→RED, RED→GREEN, GREEN→close each via `AskUserQuestion`;
exemplar re-renders ratified at the GREEN exit gate
(`scratchpad/s715_render_{linebreeding,half_sib}_after.png` + the
Real-375 site crops). 7. **Close-out:** Learning 764 appended; NEWS.Rmd
plain-language entry + NEWS.md render; this evaluation + handoff;
receipt; ledger entries; BACKLOG block removed.

**Self-assessment (Session 715): 9/10.** **Strengths:** (1) probe-first
counterfactual made RED encode measured expectations that GREEN then
reproduced to the digit — implementation/probe divergence would have
failed a test, not passed unnoticed; (2) the never-worse property test
is a mechanism guarantee, not a pin; (3) performance handled with a
provably-conservative prefilter (counts identical by construction,
verified), not a weakened predicate; (4) the latent S714 suite failure
was root-caused via the spell-check itself before fixing, not assumed to
be this session’s; (5) tight scope — no QP/weight changes, no rerouting,
census script touched only for the CSV filename. **Weaknesses:** (1) the
Real-375 before/after crops do not visually isolate the single fixed arc
(fixture density; ground truth is the census overlap join, disclosed —
the standing S712–S714 pattern); (2) the first site-crop framing wasted
a render iteration (full-arc bbox dominated by empty apex space) before
re-cropping on the obstacle region.

**Next steps (specific):** (A) MHC polish (Housekeeping, S — the top
remaining READY item; full brief in `BACKLOG.md`). (B) Push decision
(owner): now ~21 commits ahead of origin (recount with
`git rev-list --count origin/master..HEAD`); the delta since the last
green CI head includes real package code (this fix), so the next push’s
CI round is the first remote validation of it. (C) Pointer-block sweep
ratification (DECISION NEEDED, M). (D) Owner decisions pending:
package-split disposition, REUSE registration. (E) Informational:
dashboard copy stale (v2.14.0 vs v2.18.0); untracked leftovers unchanged
(+ this session’s s715\_\* scratchpad files, same class); LabKey
remainder BLOCKED.

**Key files:** `R/makePedigreeDiagramData.R:2404` (new arc helpers,
`.curvedCwVia()` onward) and `:2982` (rewritten curved branch),
`tests/testthat/test_resolveEdgeNodeCollisions.R:314` (rewritten curved
section + local census replicas),
`tests/testthat/test_examplePedigreeFixtures.R:183` (flipped exemplar
specs),
`docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-18_postfix_findings.csv`
(new standing census baseline, 157 rows),
`data-raw/pedigreeDrawingErrorCensus.R:79` (postfix CSV name),
`NEWS.Rmd:209` (the new entry), `PROJECT_LEARNINGS.md:2223` (Learning
764), `scratchpad/s715_probe.R` / `s715_render.R` /
`s715_probe_results.rds` / `s715_render_*.png` /
`s715_census_rerun_output.md` / `s715_layouts.rds` (evidence;
`s715_layouts.rds$R` is the current-engine Real-375 rectilinear layout,
reusable until the next engine change).

**Gotchas for the next session:** (1) **The fresh full-suite baseline is
now 2,436 blocks** (failed=0, error=0, skipped=184, warning=40) — +2
blocks are the new helper unit tests; warnings 48 → 40 is the cleared
collision warnings, not a regression. (2) The carried-baseline heuristic
has a hole: a docs-only session that edits `.qmd`/`.Rmd` prose owes at
least `test_wordlist_coverage.R` before carrying a baseline forward
(Learning 764 — S714’s `px` sat failing for a session). (3)
`s712_layouts.rds` is now STALE for edge styling (pre-fix roundness
values); use `s715_layouts.rds` for current-engine renders; recompute
after any future engine change. (4) The census’s standing baseline is
the `_postfix` CSV (149/72); the plain `2026-09-18` CSV is the frozen
pre-fix S714 record — never compare cArc against 587 as same-state. (5)
Expect ~1 self-reference commit past the CHANGELOG frontier at next
Phase 0 (the recurring shape); measure it. (6)
`.resolveEdgeNodeCollisions()` now costs ~0.95 s on the Real-375 fixture
(was 0.21 s) — the arc scoring is the difference; if a future session
sees layout-time complaints, the prefilter margin and the 64-sample
count are the tuning knobs, with the census as the counts-unchanged
referee.

### Session 713 Handoff Evaluation (by Session 714)

**Score: 9/10.** **What helped:** next-step A was this session’s exact
deliverable with the item pointer (`BACKLOG.md:109`) and the
forward-carry spelled out (article “8 of 237” sites + Track B centering
— both discharged exactly as written when the re-run landed and reported
6); gotcha 4 predicted the 1-commit backfill shape and it measured
exactly 1 (`35a33905`); gotcha 2 (“census CSV frozen, do NOT fix it; the
6-row count exists only in a future re-run, which owes the article
update”) framed this session’s obligations precisely; the S712 key-file
chain (`s712_layouts.rds` + `s712_crop.R`) carried through S713’s
handoff was reused directly for the live-widget verification and both
site crops, zero failed render iterations; gotcha 3 (cache valid unless
an engine commit lands — none had) saved a recompute decision. **What
was missing:** the BACKLOG item’s “47 curved-heuristic residuals” figure
was stale (live count 56 + 1, pinned at 56L by
`test_resolveEdgeNodeCollisions.R:394` since S690 — S712’s own handoff
even quoted “1 on Track C, 56 on Real 375”); cost one test-file read to
reconcile. No pointer to the bundled `vis-network.min.js` as the
arc-geometry ground truth — the S577 doc-comment in
`R/makePedigreeDiagramData.R` was the needed breadcrumb, found by grep;
low cost. **What was wrong:** nothing found; every checked claim held
(frozen 1,667+1 reproduced to the row; b=6 at the re-run as predicted).
**ROI:** high — orientation to owner pick in one pass.

### What Session 714 Did

**Deliverable:** Census curved-chord arc-modelling measurement pass —
**DONE, owner-ratified follow-up fix item filed** (S713 next-step A /
BACKLOG curved-chord item, owner-picked via `AskUserQuestion` at Phase
0; measurement/audit session — `data-raw/` census extension + audit
doc + mandated article update; no package code, no TDD phases).
**Started/completed:** 2026-09-18 (single session). Phase 0 backfill
`9a096ed6`; claim `88f563de`; deliverable `318c32da`; records commit
follows this handoff. **Ledger:** claim + close-out entries in
`CHANGELOG.md`; curved-chord BACKLOG block replaced in the records
commit by the ratified fix item (the FM \#28 reduction is the block
swap; all three ledgers are far under budget, nothing else to trim).

**What actually happened, in order:** 1. **Phase 0:** reconcile
backfilled 1 commit (`35a33905`, S713’s self-reconcile — the predicted
recurring shape, measured 1). CI 4/4 green + scheduled shinytest2 green
(origin head unchanged; local now 12 ahead incl. this session).
Dashboard 96/100, no HIGH flags. Owner picked curved-chord from the
4-option picker. 2. **Ground truth:** transcribed the arc geometry from
the bundled `vis-network.min.js` (`_getViaCoordinates()` curvedCW
branch; `_bezierCurve()` = single-via quadraticCurveTo), then verified
the transcription against the LIVE widget via chromote
(`edgeType.getViaNode()` + `options.smooth.*` per edge): max
\|via(model) − via(live)\| = 1.1e-13 px over all 173 curved edges;
per-edge roundness overrides (0.2 / bumped 0.5) confirmed applied
(`scratchpad/s714_verify_via.R`). 3. **Probe
(`scratchpad/s714_probe.R`):** chord predicate reproduced the frozen
census to the row (1,667 Real + 1 Track C) before any new claim; exact
point-to-quadratic min distance (cubic root solve); overlap join: **0 of
1,667 chord pairs are true hits, and all 587 true hits (117 of 170 arcs,
Real 375 only) are outside the chord test’s sight** (485 events on
cross-row connectors nothing ever checked; 102 from bumped arcs crossing
upper rows). Bump audit: 21 arcs hit at 0.2, 24 at the shipped 0.5 — the
blind +0.3 bump is net-negative on Real 375. Sensitivities:
border-trimmed endpoints change nothing; parseInt quantization 587→586;
±1-px jitter 588–596 events with the arc count 117 in all 10 draws.
Incidental discovery: vis-network parseInt -truncates predefined node
coordinates (whole-px; the 1-px “drift” anomaly chased to root cause;
Learning 763). 4. **Census extended**
(`data-raw/pedigreeDrawingErrorCensus.R`): `c-arc-inside` predicate
(exact via + cubic solve) replaces the retired chord heuristic;
scoreboard `cArc`/`cArcEdges`; new CSV
`docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-18_findings.csv` (595
rows); frozen 2026-09-02 artifacts untouched. lint 0; re-run after lint
fixes byte-identical. **Class (b) = 6 at its first post-S713 re-run**
(forward-carry trigger), units = 237. 5. **Coupled prose discharged:**
article mate-line paragraph now cites 6 of 237
(`vignettes/articles/kinship2-fidelity-validation.qmd`); caveats bullet
is count-free, verified accurate as written; Track B centering
re-verified (b=0 both Track B fixtures at re-run; S713 live measurement
stands). 6. **Audit doc:**
`docs/audits/PEDIGREE_DRAWING_CURVED_ARC_CENSUS_2026-09-18.md` (method,
verification evidence, findings, scoreboard vs frozen baseline,
recommendation). Crops of the two deepest sites
(`scratchpad/s714_crop_site{1,2}_*.png`, Learning 732 recipe). 7.
**Owner gate:** recommendation ratified (option 1) — new BACKLOG fix
item filed: arc-verified roundness selection replacing the blind bump
(READY, M, strict TDD); curved-chord measurement block removed in the
same records commit. Corpus sweep for stale counts: test comments’ “47”
are frozen CHANGED-history (live pin is 56L — correct); no other live
site. 8. **Close-out:** Learning 763 appended; this evaluation +
handoff; receipt; ledger entries.

**Self-assessment (Session 714): 9/10.** **Strengths:** (1) continuity
before new claims — the frozen 1,668 reproduced exactly first; (2) the
model was verified against the live renderer, not just a source read —
and the 1-px anomaly it surfaced was chased to a real root cause
(parseInt) instead of waved off; (3) the inversion finding (100%
false-positive AND blind to every true hit) is an exact overlap join,
not an impression; (4) sensitivity analyses (border trim, quantization,
jitter) ran before any count was quoted; (5) the recommendation is
anchored to a measured net-negative effect of the existing heuristic,
and the fix item carries the full brief including which test pins must
be re-derived. **Weaknesses:** (1) the crops show chord clutter at
neighbourhood zoom but do not pixel-isolate a single offending arc
(geometry established programmatically, matching the S712/S713
disclosure pattern); (2) the audit doc briefly claimed the article
update before that edit landed — an in-session ordering slip, corrected
within minutes, but drafting prose ahead of the fact is exactly how
stale claims are born.

**Next steps (specific):** (A) Curved-connector fix item (READY, M,
strict TDD): arc-verified roundness selection — the new BACKLOG block
carries the full brief (mechanism, code pointers
`R/makePedigreeDiagramData.R` curved branch / `roundnessBump`, the
census predicate functions to port, which
`test_resolveEdgeNodeCollisions.R` pins re-derive, constraints
S577/S675). (B) MHC polish (Housekeeping, S). (C) Push decision (owner):
now 12 commits ahead of origin (S712 4 + S713 5 + this session’s 3 by
close-out; recount with `git rev-list --count origin/master..HEAD`) —
package delta since last green CI head is data-raw + docs + one article
page; the pkgdown article render is CI’s to validate. (D) Owner
decisions pending: package-split disposition, pointer-block sweep
ratification, REUSE registration. (E) Informational: dashboard copy
stale (v2.14.0 vs v2.18.0); untracked leftovers unchanged (+ this
session’s s714\_\* scratchpad files, same class); LabKey remainder
BLOCKED.

**Key files:**
`docs/audits/PEDIGREE_DRAWING_CURVED_ARC_CENSUS_2026-09-18.md` (the
audit report), `data-raw/pedigreeDrawingErrorCensus.R:441` (arc
predicate, `curvedCwVia()` onward),
`docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-18_findings.csv`
(595-row re-run),
`vignettes/articles/kinship2-fidelity-validation.qmd:164` (6 of 237
site), `BACKLOG.md:109` (the new fix item), `scratchpad/s714_probe.R` /
`s714_verify_via.R` / `s714_sensitivity.R` / `s714_probe_results.rds` /
`s714_census_rerun_output.md` / `s714_crop_site*.png` (evidence),
`tests/testthat/test_resolveEdgeNodeCollisions.R:394` (the 56L residual
pin the fix item will re-derive).

**Gotchas for the next session:** (1) **The fresh baseline is still
2,434 blocks** (failed=0, error=0, skipped=184, warning=48) — this
session touched no package files (data-raw + docs + article prose only);
S709’s gotchas still apply (read them in
`docs/archive/SESSION_NOTES-through-2026-09-18.md`). (2) The census’s
class-(c) curved measurement is now `cArc`/`cArcEdges` (587/117 on Real
375) — the old `c-curved-chord` subclass no longer exists in the script;
do not compare new `cArc` numbers against the frozen 1,668 as if
same-metric (the audit doc holds the mapping). (3) The 2026-09-02
CSV/doc stay frozen; the 2026-09-18 CSV is the new standing baseline.
(4) Expect ~1 self-reference commit past the CHANGELOG frontier at next
Phase 0 (the recurring shape); measure it. (5) The article now cites “6
of 237” tied to the 2026-09-18 re-run — the NEXT census re-run after the
curved-connector fix will change `cArc` but NOT class (b) (unless the
engine moves nodes); only class-(b) changes re-obligate that sentence.
(6) vis-network parseInt-truncates node coordinates at render (Learning
763d) — any future pixel-exact reasoning about rendered positions must
expect whole-px symbol centers.

### Session 712 Handoff Evaluation (by Session 713)

**Score: 9/10.** **What helped:** next-step A was this session’s exact
deliverable with both populations enumerated (the 2 noise rows with
exact magnitudes, the 6 real rows with ids and offsets) and the exact
code pointers (`R/makePedigreeDiagramData.R`, `.solveJointQP()`);
`s712_layouts.rds` reproduced the frozen census TO THE DIGIT (max
\|diff\| ≈ 2e-15 u on all 8 rows — probe2), so continuity cost one
script instead of a re-derivation; `s712_crop.R` rendered all 4 site
crops with zero failed iterations; gotcha 4 predicted the 1-commit
backfill shape and it measured exactly 1 (`ed79261f`); gotcha 2
(recompute if the engine changed) framed the cache-trust decision
precisely — verified no `R/` commits since, cache reused; gotcha 5
pre-empted misreading the
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
collision warnings during verification runs. **What was missing:** the
committed structural-residual test (`test_positionMatingUnitForest.R`
line 2917) — which already NAMES the exact 6 unions, bounds them at
≤1.55 u, and draws the 1e-3 raw-unit dust line (“8 rows of which 2 dust
= 6 meaningful”) — was this session’s single most decisive context and
went unmentioned; found only via the engine doc-comment’s
cross-reference. **What was wrong:** nothing found; every checked claim
held. **ROI:** high — orientation to owner pick in one pass, probe built
directly on the named targets.

### What Session 713 Did

**Deliverable:** Census class (b) assessment — **DONE, class CLOSED both
ways, owner-ratified** (S712 next-step A / BACKLOG “Census class (b)”
item, owner-picked via `AskUserQuestion` at Phase 0; assessment
session + one ratified data-raw predicate edit; no package files
touched, no TDD phases — `data-raw/` measurement script only).
**Started/completed:** 2026-09-18 (single session). Phase 0 backfill
`47905f6a`; claim `8e769e30`; deliverable `de4e6ce8`; records commit
follows this handoff. **Ledger:** claim + close-out entries in
`CHANGELOG.md`; BACKLOG class-(b) block removed in the records commit
(the FM \#28 reduction), with the census-re-run consequence
forward-carried into the curved-chord item.

**What actually happened, in order:** 1. **Phase 0:** reconcile
backfilled 1 commit (`ed79261f`, S712’s self-reconcile — the predicted
recurring shape, measured 1). CI 4/4 green on origin head `1788e2b8`.
Dashboard 96/100, no HIGH flags. Owner picked class (b) from the
4-option picker. 2. **Probe (`scratchpad/s713_probe.R` +
`s713_probe2.R`):** continuity first (census reproduced to the digit
from the S712 cache AND a fresh run), then trace()-captured
`.solveJointQP()` inputs (5 components; target component 733 variables),
baseline re-solve reproduction check, then the two instruments:
binding-chain analysis (every between-mates gap BINDING at its floor;
chain minimum == observed offset exactly for all 6) and a wUnion sweep 2
→ 2e5 (offsets reducible ONLY via mate-span stretch: `__union_137` 480 →
1,787 px). Verdict: **minSep-forced at the ratified S675 weights**;
weight escalation would degrade the layout and contradict the
no-weight-tuning mandate. 3. **Dust rows:** `__union_75` (≈2.8e-5 px) is
not even pinned (gaps 0.97 u, non-binding — residual is solver epsilon);
`__union_132` (≈1.0e-6 px) is the centred mates-1.0-apart geometry with
float noise over the exact 1e-6 px skip. The committed test’s 1e-3
raw-unit floor already calls both “dust.” 4. **Crops (Learning 732
recipe, `scratchpad/s713_crop_{A_wcpxhd,B_u97,C_u191, D_u228}.png`):**
all 4 neighbourhoods (covering all 6 sites) — each dot sits adjacent to
its distal marry-in mate, i.e. the conventional multiple-marriage chain;
nothing reads as a defect. 5. **Owner gate (2 questions, both
recommended options taken):** (a) 6 real rows accepted as structural
residuals, CLOSED, no fix item; (b) census predicate adopts the 1e-3
raw-unit floor NOW — `data-raw/pedigreeDrawingErrorCensus.R` edited
(`de4e6ce8`), verified old-skip→8 / new-floor→exactly-the-6, lint 0. 6.
**Coupled prose re-verified (no edit owed):** Track B centering
re-measured live (max 1.9e-11 px); “8 of 237” stays accurate as a
frozen-baseline citation; the count changes to 6 only at the next census
re-run — obligation forward-carried into the curved-chord BACKLOG item.
7. **Close-out:** Learning 762 appended (threshold alignment across
measurement artifacts + the trace()-capture/re-solve probe instrument +
the silent NULL-propagation skip corollary, mechanism verified before
recording).

**Self-assessment (Session 713): 9/10.** **Strengths:** (1) continuity
before counterfactuals — baseline re-solve had to reproduce production
devs before any weight sweep was trusted; (2) two independent
instruments agreeing exactly (chain minimums == observed offsets to 9
decimals) makes the verdict measurement, not judgment; (3) the escape
route’s COST was quantified (span stretch 3.7×) rather than asserted;
(4) the tolerance recommendation was anchored to an existing committed
constant (the test’s own floor) instead of inventing a new one; (5)
predicate edit verified against both old and new thresholds on the real
layout. **Weaknesses:** (1) probe v1’s 1a continuity section skipped
silently (NULL propagation, zero output, zero error) — caught by
noticing absent rows, fixed in probe2, mechanism verified and recorded
in Learning 762; (2) the crops show the sites at neighbourhood zoom; no
pixel-ruler measurement in the rendered image (the geometry is
established programmatically, matching the S712 disclosure pattern).

**Next steps (specific):** (A) Census curved-chord (READY, M):
arc-modelling measurement pass replacing the 1,668-chord upper bound —
now carries the forward-carried obligation to update the article’s “8 of
237” sites at the next census re-run (see the BACKLOG block). (B) MHC
polish (Housekeeping, S). (C) Owner decisions pending: package-split
disposition, pointer-block sweep ratification, REUSE registration. (D)
Informational: dashboard copy stale (v2.14.0 vs v2.18.0); untracked
leftovers unchanged (+ this session’s s713\_\* scratchpad files, same
class); LabKey remainder BLOCKED; local ahead of origin by this
session’s commits — push decision is the owner’s, per the standing
convention.

**Key files:** `scratchpad/s713_probe.R` + `s713_probe2.R` (the
two-instrument probe; results `scratchpad/s713_probe_results.rds`),
`scratchpad/s713_crop_*.png` (4 site crops),
`data-raw/pedigreeDrawingErrorCensus.R:346` (the ratified floor, commit
`de4e6ce8`), `tests/testthat/test_positionMatingUnitForest.R:2917` (the
structural-residual test naming the same 6), `CHANGELOG.md` (S713
close-out entry), `BACKLOG.md:109` (curved-chord, now the top census
item, with the forward-carry).

**Gotchas for the next session:** (1) **The fresh baseline is still
2,434 blocks** (failed=0, error=0, skipped=184, warning=48) — this
session touched no package files (data-raw only); S709’s gotchas still
apply (read them in `docs/archive/SESSION_NOTES-through-2026-09-18.md`).
(2) The census CSV remains frozen at 8 class-(b) rows — do NOT “fix” it;
the 6-row count exists only in a future re-run, and that re-run owes the
article-figure update (BACKLOG forward-carry). (3) `s712_layouts.rds`
remains valid (no engine commits since S697); recompute if any session
commits a layout-engine change. (4) Expect ~1 self-reference commit past
the CHANGELOG frontier at next Phase 0 (the recurring shape); measure
it. (5) The trace()-capture probe technique (Learning 762) needs
`capEnv` in globalenv and a translation-invariant comparison
(per-component packing shifts absolute x).

### Session 711 Handoff Evaluation (by Session 712)

**Score: 9/10.** **What helped:** next-step A was this session’s exact
deliverable, with both site ids, the ~120-px values, the S696
crop-precedent pointer, and `BACKLOG.md:142` pointing exactly at the
item; gotcha 3 predicted the 1-commit backfill shape and it measured
exactly 1 (`1788e2b8`); gotcha 2 pre-framed the in-progress R-CMD-check
correctly (it completed green in-session, 33m33s — the S711 open loop is
closed); gotcha 4 (“origin in sync, don’t re-report from stale
handoffs”) held (0/0 at orientation). **What was missing:** nothing
material — the working crop recipe itself (Learning 732 /
`scratchpad/s696_crop.R`) wasn’t named in the handoff, but the BACKLOG
item’s “S696 precedent” phrase found it in one grep. **What was wrong:**
nothing found. **ROI:** high — orientation to owner pick took one pass.

### What Session 712 Did

**Deliverable:** Census class (d) duplicate-adjacent assessment —
**DONE, item CLOSED as acceptable** (S711 next-step A / BACKLOG “Census
class (d)” item, owner-picked via `AskUserQuestion` at Phase 0;
assessment session, no package files touched, no TDD phases; owner
ratified the verdict via a second `AskUserQuestion` with all 6 crops in
front of them). **Started/completed:** 2026-09-18 (single session).
Phase 0 backfill `e099a6f9`; claim `7a3a49f4`; close-out records commit
follows this handoff. **Ledger:** claim entry + close-out entry (the
dated assessment note) in `CHANGELOG.md`; BACKLOG block removed in the
close-out commit per the S686 completed-item convention.

**What actually happened, in order:** 1. **Phase 0:** reconcile
backfilled 1 commit (`1788e2b8`, S711’s self-reconcile — the predicted
recurring shape, measured 1). CI: 3/4 green on the S711 close-out head,
R-CMD-check in progress; completed green in-session (4/4, run
35390065689). Dashboard 96/100, no HIGH flags. Owner picked class (d)
from the 4-option picker. 2. **Probe (`scratchpad/s712_probe.R`):**
recomputed BOTH fixture layouts fresh with the current engine (default
rectilinear) rather than trusting the cached `s696_layout.rds` (engine
file’s last commit, S697 doc-comments, postdates that cache). Census
rows reproduced to the digit: Track C `__dup_Y_2`/`Y` dx=120.0 exactly;
Real 375 `__dup_SLN0TF_2`/`SLN0TF` dx=119.9999999992; both same-row,
ZERO nodes strictly between; dashed duplicate-connector present in the
edge frame at both sites (Track C dup also carries the
consanguineous-marked union edge). 3. **Crops (`scratchpad/s712_crop.R`,
Learning 732 recipe — moveTo + raw-viewport capture):** 6 renders
(100% + 2.2x zoom + context, both sites),
`scratchpad/s712_crop_{trackC,real375}_*.png`. Track C reads cleanly
(70-px rim gap, connector plainly visible; adjacency minimizes connector
length). Real 375 structurally identical but the short connector is hard
to isolate amid unrelated long-range dashed chords — that obscuring is
the class (c) curved-chord density issue, not an adjacency defect; extra
separation would LENGTHEN the connector and add to that clutter. 4.
**Verdict (owner-ratified):** acceptable — adjacent-at-minSep is the
same spacing as any other adjacent same-row pair; overlap subclass count
is 0; adjacency is arguably the optimal duplicate placement. Item
closed; no separation follow-up scoped. Coupled-prose check: the
fidelity article contains zero class-(d)/ “adjacent” references
(grep-verified), so no prose re-verification was owed. 5. **Close-out:**
this evaluation + handoff; receipt completed; ledger entries; BACKLOG
block removed (the FM \#28 reduction for this session). No new learning
appended — routine assessment on existing recipes (Learning 732’s crop
path, Learning 707’s owner-gate discipline), no new signal; stated
explicitly rather than silently, per the S711 precedent.

**Self-assessment (Session 712): 9/10.** **Strengths:** (1) fresh
layouts instead of the stale cache, closing the engine-drift question
before it could taint the evidence; (2) programmatic verification BEFORE
rendering — the census values reproduced to the digit, so the crops
illustrate a measured fact rather than stand in for one; (3) proven
recipe reuse — zero failed render iterations; (4) tight scope — no fixes
attempted, the class-(c) legibility concern routed to its existing item
rather than expanding this one. **Weaknesses:** (1) the Real-375 zoom
could not positively isolate the short dup connector amid the chord
clutter — its presence is established programmatically (edge frame) but
not pixel-confirmed at that site; disclosed to the owner at the gate;
(2) no new learning row (correct — no signal — but stated, not silent).

**Next steps (specific):** (A) Census class (b) (READY, M): decide the
census-predicate tolerance for the 2 noise rows, then assess whether the
6 real 60–180 px union-dot offsets are minSep-forced or QP-reducible
(`R/makePedigreeDiagramData.R`, `.solveJointQP()`); re-verify the
coupled fidelity article prose (“8 of 237”, 0.00-px Track B centering).
`scratchpad/s712_layouts.rds` holds fresh current-engine layouts of both
fixtures — reusable, and `scratchpad/s712_crop.R` renders crops from it
by fixture key. (B) Census curved-chord (READY, M): arc-modelling
measurement pass replacing the 1,668-chord upper bound — this session’s
Real-375 site is a concrete motivating example (a legitimate short
connector visually buried by unrelated chords). (C) MHC polish
(Housekeeping, S). (D) Owner decisions pending: package-split
disposition, pointer-block sweep ratification, REUSE registration. (E)
Informational: dashboard copy stale (v2.14.0 vs v2.18.0);
`R/appServer.R:168` re-throw observer reported-not-changed; untracked
leftovers unchanged (+ this session’s s712\_\* scratchpad files, same
class); LabKey remainder BLOCKED; local is ahead of origin by this
session’s commits (backfill + claim + close-out) — push decision is the
owner’s, per the standing convention.

**Key files:** `scratchpad/s712_probe.R` (the geometry probe),
`scratchpad/s712_crop.R` + `scratchpad/s712_layouts.rds` (reusable crop
path), `scratchpad/s712_crop_*.png` (the 6 crops), `CHANGELOG.md:29`
(S712 entries),
`docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-02_findings.csv:3` +
`:1679` (the 2 closed rows — CSV unchanged, it is a frozen audit
record), `BACKLOG.md:109` (class b, now the top census item),
`BACKLOG.md:128` (curved-chord).

**Gotchas for the next session:** (1) **The fresh baseline is still
2,434 blocks** (failed=0, error=0, skipped=184, warning=48) — this
session touched no package files; S709’s gotchas 1–4 and 6 still apply
verbatim (read them in
`docs/archive/SESSION_NOTES-through-2026-09-18.md`). (2)
`s712_layouts.rds` was computed at S712 — if any session commits a
layout-engine change, recompute before reusing it (the probe script
rebuilds both layouts in ~3 s total; the old ~2-min figure in
`s696_crop.R`’s header predates the QP engine’s current speed). (3) The
census CSV is a frozen audit artifact — a closed class does NOT get
edited out of it; closure lives in `CHANGELOG.md`. (4) Expect ~1
self-reference commit past the CHANGELOG frontier at next Phase 0 (the
recurring shape); measure it. (5) The
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
unresolved-collision warning (1 on Track C, 56 on Real 375) is the
documented class-(c)-adjacent residual disclosure, not a regression
signal.

### Session 710 Handoff Evaluation (by Session 711)

**Score: 9/10.** **What helped:** next-step A was this session’s exact
deliverable — its “~32 commits ahead, recount with
`git rev-list --count origin/master..HEAD`” measured 32 exactly at
session start; its span description (S708 MHC Slice 4, S709 crash fix,
S710 archive pass) and clean-state assurance (“no package files touched
since the S709-verified clean state”) made the push decision presentable
to the owner with zero re-derivation; gotcha 5 predicted the 1-commit
backfill shape and it measured exactly 1 (`0f7f94fe`); gotcha 2
(“sparseness is not a ghost session”) pre-empted exactly the misread the
freshly-trimmed ledgers invite. **What was missing:** nothing material
for this session’s scope — a push session touches no package internals,
so the handoff’s depth was sufficient by construction. **What was
wrong:** nothing found; every checked claim held. **ROI:** high —
orientation to owner-decision took one pass.

### What Session 711 Did

**Deliverable:** Owner-directed push to `origin/master` — **DONE** (S710
next-step A, owner-picked via `AskUserQuestion` at Phase 0; process/ops
action, no code changes, no TDD phases). Pushed 34 commits
(`955f6f19..afd33514`: 32 at session start + Phase 0 backfill
`83618479` + claim `afd33514`), spanning S708 MHC Slice 4, the S709
export-preview crash fix, and the S710 ledger archive pass. **All 4
on-push CI workflows green on `afd33514`:** lint 5m43s, test-coverage
9m58s, pkgdown 16m52s, R-CMD-check 33m22s (run ids
35386636842/857/853/874). Watched to completion in-session, then
confirmed via `gh run list` directly. **Started/completed:** 2026-09-18
(single session). Phase 0 backfill `83618479`; claim `afd33514`; records
commit follows this handoff, then a self-reconcile sha commit, both
pushed immediately (second push — its own CI round is verified at the
next session’s unconditional Phase 0 CI check, per the S706 precedent).
**Ledger:** claim entry + push-outcome entry in `CHANGELOG.md` (this
close-out).

**What actually happened, in order:** 1. **Phase 0:** reconcile
backfilled 1 commit (`0f7f94fe`, S710’s self-reconcile — the predicted
recurring shape, measured 1, commit `83618479`). HANDOFFS fully
reconciled, no pending receipt. CI all green pre-push. Dashboard 96/100,
no HIGH flags. Owner picked the push from the 4-option picker. 2.
**Claim** `afd33514` (stub + pending receipt + claim ledger entry) —
deliberately made before the push so the pushed head itself carries the
session claim. 3. **Push** `955f6f19..afd33514` (34 commits), then a
background watcher polled every 2 min until all 4 workflows completed;
all green; confirmed directly. 4. **Close-out:** this evaluation +
handoff; receipt completed; ledger entries; records + self-reconcile
commits pushed. Nothing removed from `BACKLOG.md` (the push was a
handoff next-step, not a BACKLOG block). FM \#28 reduction check:
nothing to trim — all three ledgers were cut to sparse by S710 and
remain far under budget.

**Self-assessment (Session 711): 9/10.** **Strengths:** (1)
claim-before-push meant the pushed head carries the session’s own
breadcrumb — a crash mid-watch would have left origin self-describing;
(2) waited for the full matrix rather than declaring success at push
time, and re-verified the watcher’s claim directly before recording it;
(3) clean, precedent-following scope — no package files touched, no
scope creep. **Weaknesses:** (1) the close-out push’s own CI round is
deliberately not watched (S706 precedent, docs-only delta on a
just-verified tree) — a defensible but real open loop handed to the next
session’s Phase 0; (2) a routine session yields no new learning, so
`PROJECT_LEARNINGS.md` gains nothing — correct (no signal), but worth
stating explicitly rather than silently.

**Next steps (specific):** (A) Census class (d) (READY, S): render the 2
duplicate-adjacent sites (`__dup_Y_2` vs `Y`, `__dup_SLN0TF_2` vs
`SLN0TF`) and judge acceptability — see the BACKLOG block for the
crop-verification precedent. (B) Census class (b) (READY, M): decide the
census-predicate tolerance for the 2 noise rows, then assess whether the
6 real 60–180 px offsets are minSep-forced or QP-reducible
(`R/makePedigreeDiagramData.R`, `.solveJointQP()`); re-verify the
coupled fidelity article prose. (C) Census curved-chord (READY, M):
measurement pass replacing the 1,668-chord upper bound. (D) MHC polish
(Housekeeping, S). (E) Decisions pending (owner): package-split
disposition; pointer-block sweep ratification; REUSE registration. (F)
Informational: dashboard copy stale (v2.14.0 vs v2.18.0);
`R/appServer.R:168` re-throw observer reported-not-changed; untracked
leftovers unchanged; LabKey remainder BLOCKED.

**Key files:** `HANDOFFS.md:146` (S711 receipt), `CHANGELOG.md:29` (S711
entries), `docs/archive/SESSION_NOTES-through-2026-09-18.md` (S709
gotchas, still applicable),
`BACKLOG.md:109`/`BACKLOG.md:128`/`BACKLOG.md:142` (the three census
items).

**Gotchas for the next session:** (1) **The fresh baseline is still
2,434 blocks** (failed=0, error=0, skipped=184, warning=48) — neither
S710 nor S711 touched package files; S709’s gotchas 1–4 and 6 still
apply verbatim (read them in
`docs/archive/SESSION_NOTES-through-2026-09-18.md`). (2) The close-out
push triggers one more CI round on the records/self-reconcile head —
expect it `completed success` at Phase 0’s `gh run list`; if it is red,
that is NEW information (docs-only delta), report-don’t-fix per the
standing convention. (3) Expect ~1 self-reference commit past the
CHANGELOG frontier at next Phase 0 (the recurring shape); measure it.
(4) origin/master is now in sync — the long-running “N commits ahead”
informational item is gone; don’t re-report it from stale handoffs.

### Session 709 Handoff Evaluation (by Session 710)

**Score: 9/10.** **What helped:** next-step A was this session’s exact
deliverable — it named all three files, and its measured byte sizes
(72,242/77,442 at S709 close-out) tracked straight to this session’s own
pre-claim measurements (78,117/87,140); the “CHANGELOG was 62,816 B
BEFORE this close-out — measure it first” instruction was exactly right
(it measured 65,351 B pre-backfill and crossed the 65,536 B budget with
this session’s own Phase 0 backfill); gotcha 5 predicted the 1-commit
backfill shape and it measured exactly 1 (`710fea78`); gotcha 4’s
devtools::check 1 W + 1 N framing meant the untracked-file noise was
pre-triaged. **What was missing:** the shard-name collision constraint —
the dominant obstacle of the whole pass. Five sessions (S704–S708) share
date 2026-09-17, the cut key of the existing `-through-2026-09-17`
shards, so every intermediate cut was refused (`SHARD_EXISTS`) and only
a few retained counts were writable (Learning 761). Discoverable only by
doing; cost ~6 dry-run probes. **What was wrong:** the predicted
small-denominator `SRF` refusals never fired — no `--force` (and so no
owner gate) was needed; the 2026-09-17 archives left large denominators.
Labeled an expectation, so the cost was zero. **ROI:** high.

### What Session 710 Did

**Deliverable:** Ledger archive pass — **DONE** (S709 next-step A,
owner-picked via `AskUserQuestion` at Phase 0; docs-only maintenance, no
TDD phases). All three ledger byte triggers were firing; all three now
clear with wide hysteresis headroom: `SESSION_NOTES.md` 87,984 → 4,771 B
(19 records → `docs/archive/SESSION_NOTES-through-2026-09-18.md`),
`HANDOFFS.md` 78,503 → 16,481 B (13 receipts →
`docs/archive/HANDOFFS-through-2026-09-18.md`), `CHANGELOG.md` 68,117 →
9,471 B (40 records → `docs/archive/CHANGELOG-through-2026-09-18.md`).
Every shard’s own `verify.sh` run: L1/L2/L3 hold on all three (run them
rather than trusting this sentence). No `--force` was needed anywhere —
the expected SRF refusals never fired (Learning 761).
**Started/completed:** 2026-09-18 (single session). Phase 0 backfill
`7ab986e2`; claim `852b5292`; trims `7fbe17b7` (SESSION_NOTES),
`3dbe15f3` (HANDOFFS), `447f2beb` (CHANGELOG); records commit follows
this handoff. **Ledger:** the three trim entries were injected by
`methodology_trim.py` itself (`P1A_OK`, one per `--write`), plus the
claim entry and this close-out’s entry at the top of `CHANGELOG.md`.

**What actually happened, in order:** 1. **Phase 0:** reconcile
backfilled 1 commit (`710fea78`, S709’s self-reconcile — gotcha 5’s
predicted shape, measured 1). CI all green (4 on-push workflows +
scheduled shinytest2). Dashboard 96/100, no HIGH flags. NEW finding: all
THREE byte triggers firing (CHANGELOG crossed with the backfill itself).
Owner picked the archive pass from the 4-option picker. 2.
**Cut-boundary discovery:** the default computed cut on every file
collided with the existing `-through-2026-09-17` shard (S704–S708 all
dated 2026-09-17). Probed legal retained counts with dry-run `--cut N`:
SESSION_NOTES only ≥15 or ≤2; HANDOFFS only ≤2; CHANGELOG only ≤8
(Learning 761). 3. **Trims, each verified then committed** (largest
non-colliding retained count that satisfies both stop conditions):
SESSION_NOTES retain 2 (`7fbe17b7`), HANDOFFS retain 2 — the S710
pending stub + S709’s complete receipt, never zero (`3dbe15f3`),
CHANGELOG retain 8 — all of 2026-09-18 stays live (`447f2beb`).
CHANGELOG deliberately trimmed LAST so the two earlier trim-injected
entries landed before its own cut. Receipt-count front-matter sentence
regenerated to **2** by the tool (the S561 field). 4. **Close-out:**
Learning 761 appended; this handoff; receipt completed; close-out ledger
entry. Nothing removed from `BACKLOG.md` (the archive pass was a handoff
next-step, not a BACKLOG block).

**Self-assessment (Session 710): 9/10.** **Strengths:** (1) probed cut
semantics with dry runs before any write — no rollback was ever needed;
(2) deliberate ordering (CHANGELOG last) kept the tool’s injected
entries inside the trimmed file’s budget; (3) every shard verified via
its own `verify.sh` before its commit, and the final `--check` on all
three files confirms no trigger fires. **Weaknesses:** (1) the
SESSION_NOTES deep cut archives S709’s “What Session 709 Did” record
mid-session, so until this handoff the live ACTIVE TASK briefly held
only a stub + one evaluation — legal and lossless, but a crash in that
window would have made the next session’s orient one archive-hop longer;
(2) pre-announced an owner `--force` gate that the evidence then never
required — harmless, but a measure-first framing (Learning 761c) would
have been cleaner.

**Next steps (specific):** (A) **Push decision** (owner call): ~32
commits ahead after close-out (recount with
`git rev-list --count origin/master..HEAD`); span includes S708 MHC
Slice 4, the S709 crash fix, and this archive pass; local suite + check
were clean at S709 close-out and this session touched no package files.
(B) Census items unchanged: class (d) (READY, S), class (b) (READY, M),
curved-chord (READY, M). (C) MHC polish (Housekeeping, S). (D)
Informational: package-split disposition pending; dashboard copy stale
(v2.14.0 vs v2.18.0); untracked leftovers unchanged;
`R/appServer.R:168`’s deliberate re-throw observer still
reported-not-changed (S709 next-step E).

**Key files:** `docs/archive/SESSION_NOTES-through-2026-09-18.md`
(S709’s full handoff now lives here),
`docs/archive/HANDOFFS-through-2026-09-18.md` (S696–S708 receipts),
`docs/archive/CHANGELOG-through-2026-09-18.md` (S697–S708 ledger
records), `PROJECT_LEARNINGS.md:2217` (Learning 761), `HANDOFFS.md:135`
(regenerated receipt-count sentence), `methodology_trim.py` (unchanged,
v1.1.2).

**Gotchas for the next session:** (1) **The fresh baseline is still
2,434 blocks** (failed=0, error=0, skipped=184, warning=48) — this
session touched no package files; S709’s gotchas 1–4 and 6 all still
apply verbatim (read them in
`docs/archive/SESSION_NOTES-through-2026-09-18.md`). (2) The live ledger
files are now deliberately sparse — older context is one hop away via
the front-matter shard pointers; don’t mistake sparseness for a ghost
session. (3) The NEXT archive pass will hit the same `SHARD_EXISTS`
collision on the 2026-09-18 boundary — probe legal cuts with dry-run
`--cut N` first (Learning 761). (4) Each `methodology_trim.py --write`
injects its own entry into `CHANGELOG.md` — in any multi-file pass, trim
CHANGELOG last. (5) Expect ~1 self-reference commit past the CHANGELOG
frontier at next Phase 0 (the recurring shape); measure it.

### Session 708 Handoff Evaluation (by Session 709)

**Score: 9/10.** **What helped:** the BACKLOG item was again a complete
brief — crash mechanism, the `mhcExportMissingIds` fix-pattern pointer
(`R/modMarkerGenetics.R:897` at the time), the MHC residual, and the
test strategy were all pre-analyzed, so PRE-RED went straight to the
right code; gotcha 3 (testServer swallows observer errors; assert
guidance text; “ideally a live E2E disconnect check”) shaped the whole
test design — the suggested E2E became the test that reproduced the
crash live; gotcha 1’s baseline (2,427/0/0/183/42) reproduced exactly;
gotcha 5 predicted the 1-commit backfill exactly; gotcha 4’s
devtools::check 1 W + 1 N matched verbatim. **What was missing:** the
“guidance text is the ONLY testServer-observable difference” claim
understated the observable surface — a destroyed module session makes
every later read raise `shiny.destroyed.error`, so session survival is
directly assertable (Learning 759); and the module’s eager data-ready
`observe()` was not flagged as the same crash class (it turned out to
crash on upload alone, no click). Both discoverable only by doing; low
cost. **What was wrong:** “port the pre-check to BOTH observers” — the
LD-block missing-id path is structurally unreachable
([`markerLdBlock()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerLdBlock.md)
subsets to founder ids, `R/markerLdBlock.R:236`); evidence-checked and
owner re-ratified as defusal-only. **ROI:** high.
