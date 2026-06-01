# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Active
- [ ] (none in progress)

## Up Next
- [ ] Complete remaining monolithic UI/server → Shiny module conversion
- [ ] Integration testing for the modularized Shiny app (target >80% coverage)
- [ ] CRAN submission preparation

## Audit follow-ups
*(From `PED_GV_AUDIT_2026-05-30.md`; see `SESSION_NOTES.md` "What You Must Do" for the
per-item reachability notes and traps. Suggested next: NEW-46 or NEW-20.)*
- [ ] **NEW-46** — `geneDrop.R:82-104` parent lookup by rowname; duplicate ids → wrong
      values (the sibling of the now-fixed NEW-45 in consensus issue #7).
- [ ] **NEW-20** — delete dead `makeGeneticDiversityDashboard.R` (+ its fully-commented test).
- [ ] **PED-1 / NEW-17** — extract `getFounders(ped)` / `isFounder(ped)`.
      ⚠ Do NOT naively unify the adjacent `descendants` lines — `calcRetention.R:27` filters
      by `ped$population`; the `calc*` copies do not.
- [ ] **NEW-13 / NEW-23** — calcFE/calcFG delegate to calcFEFG; when doing so, collapse the
      triplicated partial-parentage guard (Session 7) into the single calcFEFG.
- [ ] **NEW-12 / XARCH-3** — Shiny progress hook. **XARCH-1** — two coexisting Shiny apps
      (planning session).
- [ ] **Test-infra debt** — the 22 `test-app-*` / `test-e2e-*` files call `create_test_app()`,
      which is defined nowhere in the repo → 154 suite ERRORS when `shinytest2`+`chromote`
      are installed. Either define the helper or gate the tests.
- [ ] **Trivial** — fix the copy/paste-slip assertion in
      `tests/testthat/test_getPotentialParents.R` ("works with records with no potential parent"):
      it recomputes a local `ped` but asserts the old top-level `potentialParents[[1L]]$id`.
