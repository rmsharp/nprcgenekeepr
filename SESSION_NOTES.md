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

### What Session 711 Did

**Deliverable:** Owner-directed push of local `master` commits to
`origin/master` (S710 next-step A, owner-picked via `AskUserQuestion` at
Phase 0), then verify the 4 on-push CI workflows go green and record the
outcome. Process/ops action, no code changes, no TDD phases. (IN
PROGRESS) **Started:** 2026-09-18 **Status:** Session claimed. Work
beginning. At claim time: 33 commits ahead (32 at session start + Phase
0 backfill `83618479`); this claim commit makes 34. **Ledger:**
`CHANGELOG: pending` — set at claim; this session’s actions are recorded
in `CHANGELOG.md` at Phase 3F. Until close-out, this line is the crash
breadcrumb for the next session’s reconcile.

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
