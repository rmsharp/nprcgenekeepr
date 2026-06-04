# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Active
- [ ] (none in progress)

## Up Next
- [ ] **Complete the monolith → Shiny-module conversion (XARCH-1 / issue #27)** —
      plan: `docs/planning/shiny-module-conversion-plan.md` (9 vertical-slice phases; one phase
      per session, do **not** bundle). **Phases 1–6 complete** (see `CHANGELOG.md`).
      **Next: Phase 7** — Input parity: focal-animal / LabKey pedigree build (`getFocalAnimalPed` /
      `getLkDirectRelatives`; monolith server.r:86-113, none called in the modular path today).
      **Risk HIGH 🐉** — owner consult at phase start (live EHR vs `mockery` stub vs descope the
      radio option); may need its own sub-plan. Then Phase 8 (E2E, = issue #39) and Phase 9
      (delete the monolith — irreversible, its own commit).
- [ ] **Integration testing for the modularized Shiny app** — **= Phase 8 of the conversion plan**
      (author the missing shinytest2 driver helpers + run the E2E tier; this is **GitHub issue #39**).
- [ ] **CRAN submission preparation**

## Audit follow-ups
*(From `PED_GV_AUDIT_2026-05-30.md`; the audit compute/test items are all resolved — see
`CHANGELOG.md`. Per-item reachability notes and traps live in `CLAUDE.md` "Project-specific
Learnings".)*
- [ ] **NEW-12 / XARCH-3** — Shiny progress hook. **Mostly resolved** per the S21 plan §8: `reportGV` /
      `groupAddAssign` are already shiny-free with an injected `updateProgress` hook; the only real leak
      `getMinParentAge` is a dead orphan (removed in conversion Phase 9). Treat as SEPARABLE cleanup.

## Tracker reconciliation (open question for the user)
- The remaining audit follow-ups (XARCH-2..8) are **not** GitHub issues; the live tracker is #1–#39.
  Decide whether to file the remaining XARCH items as issues or keep them here. They currently coexist.
