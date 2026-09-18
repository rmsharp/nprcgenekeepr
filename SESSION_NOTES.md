# Session Notes

**Purpose:** Continuity between sessions. Each session reads this first and writes to it before closing out.

**Archived 612 record(s), 1998-12-06 → 2026-08-12** into [`docs/archive/SESSION_NOTES-through-2026-08-12.md`](docs/archive/SESSION_NOTES-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 40 record(s), 2026-08-11 → 2026-08-13** into [`docs/archive/SESSION_NOTES-through-2026-08-13.md`](docs/archive/SESSION_NOTES-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 76 record(s), 2026-01-26 → 2026-08-15** into [`docs/archive/SESSION_NOTES-through-2026-08-15.md`](docs/archive/SESSION_NOTES-through-2026-08-15.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 170 record(s), 2026-08-19 → 2026-09-17** into [`docs/archive/SESSION_NOTES-through-2026-09-17.md`](docs/archive/SESSION_NOTES-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 19 record(s), 2026-08-14 → 2026-09-18** into [`docs/archive/SESSION_NOTES-through-2026-09-18.md`](docs/archive/SESSION_NOTES-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

---

## ACTIVE TASK

### What Session 710 Did
**Deliverable:** Ledger archive pass — trim `SESSION_NOTES.md`, `HANDOFFS.md`, and
`CHANGELOG.md`, whose byte triggers ALL fire (measured this session: 87,140 B /
78,117 B / 65,829 B vs the 65,536 B budget; CHANGELOG crossed with this session's own
Phase 0 backfill). S709 next-step A, owner-picked via `AskUserQuestion`. (IN PROGRESS)
**Started:** 2026-09-18
**Status:** Session claimed. Work beginning. Expect small-denominator SRF refusals
needing an owner `--force` (Learnings 549/586/594); each comes back to the owner via
`AskUserQuestion` before any force. Docs-only maintenance session — no TDD phases.
**Ledger:** `CHANGELOG: pending` — set at claim; this session's actions are recorded in
`CHANGELOG.md` at Phase 3F. Until close-out, this line is the crash breadcrumb for the
next session's reconcile.

### Session 708 Handoff Evaluation (by Session 709)
**Score: 9/10.** **What helped:** the BACKLOG item was again a complete brief — crash
mechanism, the `mhcExportMissingIds` fix-pattern pointer (`R/modMarkerGenetics.R:897`
at the time), the MHC residual, and the test strategy were all pre-analyzed, so PRE-RED
went straight to the right code; gotcha 3 (testServer swallows observer errors; assert
guidance text; "ideally a live E2E disconnect check") shaped the whole test design —
the suggested E2E became the test that reproduced the crash live; gotcha 1's baseline
(2,427/0/0/183/42) reproduced exactly; gotcha 5 predicted the 1-commit backfill
exactly; gotcha 4's devtools::check 1 W + 1 N matched verbatim. **What was missing:**
the "guidance text is the ONLY testServer-observable difference" claim understated the
observable surface — a destroyed module session makes every later read raise
`shiny.destroyed.error`, so session survival is directly assertable (Learning 759); and
the module's eager data-ready `observe()` was not flagged as the same crash class (it
turned out to crash on upload alone, no click). Both discoverable only by doing; low
cost. **What was wrong:** "port the pre-check to BOTH observers" — the LD-block
missing-id path is structurally unreachable (`markerLdBlock()` subsets to founder ids,
`R/markerLdBlock.R:236`); evidence-checked and owner re-ratified as defusal-only.
**ROI:** high.

