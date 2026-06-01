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
per-item reachability notes and traps. Suggested next: test-infra debt (create_test_app),
or the now-trivial NEW-13 follow-ons NEW-22/NEW-30 (the calc* body is in one helper).)*
- [ ] **NEW-22 / NEW-30** — in `R/calcFounderContributions.R`: the hardcoded Mendelian 1/2
      factor (`/ 2L`, also in `kinship.R`) and dead computed vars (the relocated
      `UID.founders` comment block, `founderMatrix <- NULL`). Now trivial — the founder-
      contribution body lives in one helper (NEW-13/NEW-23 done, Session 17).
- [ ] **NEW-12 / XARCH-3** — Shiny progress hook. **XARCH-1** — two coexisting Shiny apps
      (planning session).
- [ ] **Test-infra debt** — the 22 `test-app-*` / `test-e2e-*` files call `create_test_app()`,
      which is defined nowhere in the repo → 154 suite ERRORS when `shinytest2`+`chromote`
      are installed. Either define the helper or gate the tests.
- [ ] **Trivial** — fix the copy/paste-slip assertion in
      `tests/testthat/test_getPotentialParents.R` ("works with records with no potential parent"):
      it recomputes a local `ped` but asserts the old top-level `potentialParents[[1L]]$id`.
