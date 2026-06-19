# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature
inventory & future plans → `ROADMAP.md`. (Methodology file model — see
`SESSION_RUNNER.md` Phase 0.)*

## Active

(none in progress)

## Up Next

**Research LabKey integration options** — a research/evaluation pass
(RESEARCH_DOCUMENTATION workstream) on how nprcgenekeepr integrates with
LabKey: the current `Rlabkey` API surface and auth model,
alternative/updated integration approaches, schema/query options, and
version/maintenance risk. Output: one research document with a
recommendation. (Added S142 per owner request; could be promoted to a
GitHub issue for the formal tracker.)

**Strengthen the shinytest2 E2E assertions + CI stability** — GitHub
issue **\#40**, the open follow-on to the now-complete Phase 8 E2E
harness: replace boot-level tautologies with behavioral checks, and
harden the full-tier Chrome process-count flake (per-group fresh
processes). Coverage goal \>80%. (The monolith → Shiny-module conversion
campaign — XARCH-1 / issue \#27, all 9 phases — is **COMPLETE**; see
`CHANGELOG.md` and `docs/planning/shiny-module-conversion-plan.md`.)

**CRAN submission preparation**

## Audit follow-ups

*(From `PED_GV_AUDIT_2026-05-30.md`; the audit compute/test items are
all resolved — see `CHANGELOG.md`. Per-item reachability notes and traps
live in `CLAUDE.md` “Project-specific Learnings”.)* - \[ \] **NEW-12 /
XARCH-3** — Shiny progress hook. **Mostly resolved** per the S21 plan
§8: `reportGV` / `groupAddAssign` are already shiny-free with an
injected `updateProgress` hook; the only real leak `getMinParentAge` was
a dead orphan (removed in Phase 9, S35). Treat as SEPARABLE cleanup.

## Tracker reconciliation (open question for the user)

- The remaining audit follow-ups (XARCH-2..8) are **not** GitHub issues;
  the live tracker is \#1–#39. Decide whether to file the remaining
  XARCH items as issues or keep them here. They currently coexist.
