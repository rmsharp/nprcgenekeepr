# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Active
- [ ] (none in progress)

## Up Next
- [ ] **Complete the monolith → Shiny-module conversion (XARCH-1 / issue #27)** —
      plan: `docs/planning/shiny-module-conversion-plan.md` (9 vertical-slice phases; one phase
      per session, do **not** bundle). **Phases 1–7 + 8a complete** (see `CHANGELOG.md`; Phase 7 =
      focal-animal / LabKey input parity into `modInput`, S29; Phase 8a = the 6 E2E driver helpers +
      `E2E_TIMEOUT` defined browser-free in `tests/testthat/helper-shinytest2.R`, S31).
      **Next: Phase 8b** — boot-smoke tier + CI rewire (the FIRST browser run) — part of enabling the
      shinytest2 E2E harness end-to-end (**GitHub issue #39**).
      **Sub-plan: `docs/planning/phase8-e2e-harness-subplan.md`** (S30) — a **4-session mini-campaign
      8a–8d** (**8a ✅ helpers/constant browser-free, S31** · 8b boot-smoke + CI 🐉 first browser run ·
      8c per-module shallow · 8d interaction/menu → close #39), with assertion-strengthening deferred to
      a separate issue (8e). Owner decisions: scope = harness-enable; CI = scheduled + manual dispatch.
      **Risk MEDIUM-HIGH 🐉** — browser-dependent, never run (8b is the first browser execution). Then
      Phase 9 (declare canonical: alias `runGeneKeepR`, delete the monolith — irreversible, its own commit).
- [ ] **Integration testing for the modularized Shiny app** — **= Phase 8 of the conversion plan**
      (= issue #39; see `docs/planning/phase8-e2e-harness-subplan.md`).
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
