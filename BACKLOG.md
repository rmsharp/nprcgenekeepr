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
per-item reachability notes and traps. Suggested next: the trivial `test_getPotentialParents.R`
assertion fix, or NEW-12/XARCH-3 / XARCH-1 (Shiny progress hook / two coexisting apps — planning).)*
- [ ] **NEW-12 / XARCH-3** — Shiny progress hook. **XARCH-1** — two coexisting Shiny apps
      (planning session). **XARCH-1 now also gates GitHub issue #39** (validate the E2E suite).
- [x] ~~**Test-infra debt** — the 23 `test-app-*` / `test-e2e-*` files call undefined
      `create_test_app()` → 154 suite ERRORS under `devtools::test()`/CI.~~ **Resolved S19**
      (`a1ee8497`): defined `create_test_app()` with an `NPRC_RUN_E2E` opt-in gate (errors →
      skips). Remaining E2E validation campaign tracked as **GitHub issue #39**.
- [ ] **Trivial** — fix the copy/paste-slip assertion in
      `tests/testthat/test_getPotentialParents.R` ("works with records with no potential parent"):
      it recomputes a local `ped` but asserts the old top-level `potentialParents[[1L]]$id`.
