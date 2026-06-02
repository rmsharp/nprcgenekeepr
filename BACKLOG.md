# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Active
- [ ] (none in progress)

## Up Next
- [ ] **Complete the monolith → Shiny-module conversion (XARCH-1 / issue #27)** — **PLANNED (S21):**
      `docs/planning/shiny-module-conversion-plan.md` (9 vertical-slice phases). **Next: implement
      Phase 1 only** (Summary Statistics tab parity). One phase per session; do not bundle.
- [ ] Integration testing for the modularized Shiny app — **= Phase 8 of the conversion plan**
      (author the missing shinytest2 driver helpers + run the E2E tier; this is **GitHub issue #39**).
- [ ] CRAN submission preparation

## Audit follow-ups
*(From `PED_GV_AUDIT_2026-05-30.md`; see `SESSION_NOTES.md` "What You Must Do" for the
per-item reachability notes and traps. Suggested next: NEW-12/XARCH-3 / XARCH-1 (Shiny progress
hook / two coexisting apps — both planning sessions), or a GitHub issue (#34 bug, #30 lintr,
#37 unused exports). The audit compute/test items are all resolved through S20.)*
- [x] ~~**XARCH-1** — two coexisting Shiny apps (planning session). Gates issue #39.~~ **PLANNED S21**
      → `docs/planning/shiny-module-conversion-plan.md` (implementation pending, Phase 1 next). The plan
      verified the audit's "do XARCH-3/4/7 first" sequencing is **moot** and subsumes #39 (Phase 8).
- [ ] **NEW-12 / XARCH-3** — Shiny progress hook. **Mostly resolved** per the S21 plan §8: `reportGV`/
      `groupAddAssign` are already shiny-free with an injected `updateProgress` hook; the only real leak
      `getMinParentAge` is a dead orphan (removed in conversion Phase 9). Treat as SEPARABLE cleanup.
- [x] ~~**Test-infra debt** — the 23 `test-app-*` / `test-e2e-*` files call undefined
      `create_test_app()` → 154 suite ERRORS under `devtools::test()`/CI.~~ **Resolved S19**
      (`a1ee8497`): defined `create_test_app()` with an `NPRC_RUN_E2E` opt-in gate (errors →
      skips). Remaining E2E validation campaign tracked as **GitHub issue #39**.
- [x] ~~**Trivial** — fix the copy/paste-slip assertion in
      `tests/testthat/test_getPotentialParents.R` ("works with records with no potential parent"):
      it recomputes a local `ped` but asserts the old top-level `potentialParents[[1L]]$id`.~~
      **Resolved S20** (`6049445d`): replaced the vacuous tautology with a discriminating
      assertion — pushing BRI2MW's birth to 1950 empties its breeding-age candidate set, so
      getPotentialParents drops it (result 50→49). Mutation-verified (disabling the skip fails
      both new assertions). REFACTOR-only under strict TDD (production already correct →
      green-on-arrival; no faked RED).
