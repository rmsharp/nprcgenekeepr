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
- [ ] **Trim `CLAUDE.md` without loss of information** (user-requested 2026-06-04, S27) — dedicated
      session. The file is ~84 KB (~21K tokens), loaded in full every session; the 27-row
      "Project-specific Learnings" table is ~89% of it (~75 KB). **Plan:** (1) add a short
      **"Recurring reflexes" glossary** defining the ~10 reflexes the rows repeat verbatim
      (verify-firsthand; discriminating-RED [a pre-existing test passes on the bug];
      `NOT_CRAN`+`load_all` regression read; touched-file-stash net-zero lint;
      `import(shiny)`/`document()` zero-delta; `set.seed` deterministic across the `testServer`
      boundary; recon-then-verify; `* 2.*` dupe scan; REFACTOR-only / no-faked-RED;
      stop-vs-warning-by-baseline; CHANGELOG-vs-BACKLOG placement); (2) rewrite each learning to keep
      its **unique** content (specific finding, file:line citations, the actual bug mechanism, per-item
      verdict) and **reference** the shared reflexes by tag; merge the redundant "When to Apply"
      restatement into the finding. Preserve every specific fact (inline or moved to the glossary).
      Target ~40–48 KB. **⚠ Do NOT touch the synced files** (`SESSION_RUNNER.md`/`SAFEGUARDS.md`/
      `methodology_dashboard.py`) — `CLAUDE.md` is project-owned; this is delicate/high-stakes (it
      governs every session).

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
