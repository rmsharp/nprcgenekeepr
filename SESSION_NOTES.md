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

**Archived 21 record(s), 2026-09-17 → 2026-09-19** into [`docs/archive/SESSION_NOTES-through-2026-09-19.md`](docs/archive/SESSION_NOTES-through-2026-09-19.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-19.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-19.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

---

## ACTIVE TASK

### Session 719 Handoff Evaluation (by Session 720)
**Score: 9/10.** **What helped:** gotcha (3) "expect 0 undocumented commits past the
frontier; measure it" measured exactly 0 — the first clean reconcile after two
1-commit sessions; next-step (B) named this session's deliverable with the
`BACKLOG.md:119` pointer, and that item's "State as of S719" paragraph was accurate
in every checked particular (seed untouched, history gitignored, tools
build-ignored, `--budget-bytes 65536` the only way `SESSION_NOTES.md` fires);
gotcha (4) pre-warned not to read `context_budget.py`'s seed-config reds as P10
defects — directly load-bearing for this exact deliverable; the "trim is one
dry-run-verified command away" claim re-verified live (this session's own dry run:
L1–L3 OK, 79,738 B → 3,500 B — larger than their 71,192 → 4,018 because the file
had since grown, consistent). **What was missing:** nothing material; one
discoverable-only wrinkle — the dashboard's `SESSION_NOTES.md` HIGH-flag text
("the trimmer answers NO_CONFIG") contradicts the local trimmer extension, found
only by running both this session. **What was wrong:** nothing found; every
checked claim held. **ROI:** high.

### What Session 720 Did
**Deliverable:** `context_budget.py` ADOPTED with honest ceilings + ledger-trigger
budget SETTLED at the old 65,536 B cadence + the owed `SESSION_NOTES.md` trim
executed — **DONE, owner-ratified** (`BACKLOG.md:119` item, removed in the adoption
commit; both decisions picked via `AskUserQuestion` — adopt-honest over
freeze-at-current and delete; old-cadence-and-trim over the 196,608 B default and a
one-off trim). Docs/process tooling, no TDD phases, no `.R` files touched.
**Started/completed:** 2026-09-19 (single session). Claim `572562f1`; adoption
`bc6be1d0`; trim `c079c27a`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit (the trimmer wrote its own for the
trim). FM #28 reduction: `SESSION_NOTES.md` 79,738 B → 3,500 B (21 records to
`docs/archive/SESSION_NOTES-through-2026-09-19.md`, L1–L3 verified pre-commit).

**What actually happened, in order:**
1. **Phase 0:** reconcile clean (0 undocumented commits, predicted 0); CI 10/10
   green on `4565c39d`; dashboard 96/100; owner picked this item from the 4-option
   picker. Claim `572562f1`.
2. **Evaluation:** seed-config run exit 2 (`CLAUDE.md` 41,622 B over 28,000;
   structure pattern instrument-failed; fence missing). `--calibrate` REJECTED:
   0.60 B/token with a −6,015-token intercept (n=119, R²=0.73) — implausible,
   confounded; adopted the dashboard's measured densest 2.27 B/token instead.
   Overlap analysis: dashboard observes, trimmer archives chronological ledgers,
   `context_budget.py` uniquely gates `CLAUDE.md` (under the one-read cap, so
   dashboard-invisible; not a ledger, so trimmer-unreachable). Trim measurements:
   SN 79,738 B fires only under 65,536; HANDOFFS 62,667 and CHANGELOG 49,819 fire
   under neither.
3. **Gate:** two `AskUserQuestion`s; owner ratified both recommended options.
4. **Adoption `bc6be1d0`:** config rewritten with derivations in `_` keys
   (ceilings aligned so a `SESSION_NOTES.md` red means exactly "a trim is owed");
   `budget:protected` fence around the Project Overview; per-clone no-growth hook
   installed; Phase 0 check + red-by-design expectations added to `CLAUDE.md`;
   S719's open trigger-budget paragraph resolved; BACKLOG item swapped for the
   successor "CLAUDE.md reduction campaign" (READY, M). Committed `--no-verify` —
   the hook correctly refuses the `CLAUDE.md` growth this very commit makes;
   bypass recorded in the ledger entry.
5. **Trim `c079c27a`:** dry run then `--write` under `--budget-bytes 65536`;
   verify.sh OK before commit; the hook ran live on this commit and passed it
   (the shrink path, observed end-to-end).

**Self-assessment (Session 720): 9/10.** **Strengths:** (1) measured before
deciding, and rejected the tool's own calibration when it was confidently wrong
rather than adopting a bad number; (2) both decisions went to the owner with
recommendations and measured trade-offs, none pre-empted; (3) single-remedy design
— the two tools' `SESSION_NOTES.md` triggers are the same number, so no standing
two-trigger disagreement; (4) honest-red posture with the remedy filed as a
BACKLOG item and growth mechanically refused meanwhile. **Weaknesses:** (1) one
`BACKLOG.md` edit clipped the first line of the adjacent `Suggests:` item —
caught and restored before commit, but a real anchor-selection error; (2) first
config write guessed `max: 0` disables a bound (it is literal) — caught by
running the tool, cost one iteration; (3) `CLAUDE.md` grew 1,726 B in the very
session that adopted its ceiling (fence + Phase-0 step + decision record) —
documented as red-by-design, but the irony stands.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~6 expected after close-out: 1
pre-existing + claim + adoption + trim + records + sha — the last two are an
estimate at write time). All changes are docs/config; CI clones never see the
per-clone hook. (B) `Suggests:` audit (READY, S — the item now sits near
`BACKLOG.md:133`; recount after any BACKLOG edit). (C) Owner decisions pending:
package-split disposition (`BACKLOG.md:71`), REUSE registration (`BACKLOG.md`
Housekeeping). (D) `CLAUDE.md` reduction campaign (new item, READY, M) — clears
the by-design red and re-greens the Phase 0 budget check. (E) Informational: the
dashboard's `SESSION_NOTES.md` HIGH flag should clear on its next Phase 0 run
(post-trim 3,500 B); LabKey remainder still BLOCKED.

**Key files:** `.context-budget.json` (calibrated config — every value carries its
derivation in the neighbouring `_` key), `CLAUDE.md` "Context-budget check" under
Additional Phase 0 steps, `CLAUDE.md` trigger-budget decision inside the
`methodology_trim.py` checklist block, `BACKLOG.md:119` (reduction-campaign item),
`docs/archive/SESSION_NOTES-through-2026-09-19.md` + `.verify.sh`,
`.git/hooks/pre-commit` (per-clone, untracked).

**Gotchas for the next session:** (1) **Phase 0's `python3 context_budget.py` run
exits 2 with `CLAUDE.md` + resident red BY DESIGN** until the reduction campaign
lands — only *new* reds are findings; a `SESSION_NOTES.md` red means a
`--budget-bytes 65536` trim is owed, nothing else. (2) **The pre-commit hook
refuses any commit that grows `CLAUDE.md`** — shrink it, or `--no-verify` with the
rationale recorded in the ledger entry; a fresh clone must re-run
`python3 context_budget.py install-hook`. (3) **Every `methodology_trim.py` run
needs `--budget-bytes 65536`** (the tool keeps no per-project setting; decision
recorded in `CLAUDE.md`). (4) `HANDOFFS.md` was 62,667 B before this session's
receipt — under the 65,536 budget it is within ~3 KB of firing; this close-out
measures it after appending (result in the close-out ledger entry) and trims it
if it fires. (5) The dashboard HIGH-flag text "the trimmer answers NO_CONFIG"
for `SESSION_NOTES.md` overstates (stock-class hardcoding vs the local
extension); do not act on the text, act on the size. (6) Full-suite baseline
re-measured this session — see the close-out ledger entry for the number
(2,437 blocks expected).

