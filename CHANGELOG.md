# Changelog

Development / process history for the **nprcgenekeepr** project, following the
[methodology](https://github.com/rmsharp/methodology) model: `BACKLOG.md` holds open
work, **this file** holds completed history, and `ROADMAP.md` holds the feature
inventory and future plans.

> **Note:** User-facing R-package release notes (the CRAN / pkgdown "Changelog") live in
> `NEWS.md` / `NEWS.Rmd`. This file tracks the development *process* and methodology
> history, not package releases.

Format loosely follows [Keep a Changelog](https://keepachangelog.com/).
When completing work, remove the item from `BACKLOG.md` and add an entry here.

## [Unreleased]

### 2026-05-31 — Enforce "no period in IDs" rule (NEW-45, Session 13)
- Fixed NEW-45: `geneDrop()` silently corrupted allele assignment for any `id`
  containing a period (".") — it rebuilt the id/parent columns by splitting
  flattened data.frame rownames on ".", so a period-bearing id was truncated and
  lost its sire/dam distinction. The documented ID domain forbids "."
  (`inst/extdata/ui_guidance/input_format.html`: id/sire/dam are "Alphanumeric
  characters (no symbols)").
- Enforced the rule rather than re-engineering `geneDrop` to support periods.
  New internal `hasInvalidIdChar()` defines the rule once and is used by:
  `qcStudbook()` (rejects period-bearing `id`/`sire`/`dam` at data input —
  `stop()` in default mode, `errorLst$invalidIdChars` when `reportErrors = TRUE`)
  and `geneDrop()` (defense-in-depth `stop()` for callers that bypass
  `qcStudbook`, e.g. the genetic-value Shiny module). Auto-generated IDs
  (`addUIds` `U####`, `obfuscateId`) are already period-free; locked with tests.
- Documented the feature with rationale (periods break across software
  environments) in roxygen, the live `input_format.html` spec, and `NEWS`.
- Strict TDD (RED→GREEN→REFACTOR). Full suite 0 failed / 0 error / 1961 passed;
  lint 0. Code commit `5e228bd9` (fix) + docs commit.

### 2026-05-31 — Methodology framework update (Session 10)
- Updated the embedded methodology to canonical `rmsharp/methodology` `f32d780`: synced
  `SESSION_RUNNER.md`, `SAFEGUARDS.md`, and `methodology_dashboard.py` byte-identical to
  canonical via `bin/sync`.
- Refreshed `docs/methodology/` framework docs (`ITERATIVE_METHODOLOGY.md`,
  `HOW_TO_USE.md`, `README.md`) and workstreams; added 4 new upstream workstreams
  (`INHERITED_CODEBASE_FAMILIARIZATION_CAMPAIGN`, `RESEARCH_DOCUMENTATION_WORKSTREAM`,
  `RESEARCH_EXHAUSTIVE_VERIFICATION_CAMPAIGN`, `TEMPLATE_CAMPAIGN`).
- Relocated the 10 project Learnings (from `SESSION_RUNNER.md`) and the R-package
  build-equivalent (from `SAFEGUARDS.md`) into `CLAUDE.md`'s "Project-Specific
  Methodology Adaptations" and "Build / Test / Verify" sections, so the synced files
  stay byte-identical to canonical.
- Created `CHANGELOG.md`, `ROADMAP.md`, `RECOMMENDED_SKILLS.md`; split `BACKLOG.md`
  (completed work → here; feature inventory → `ROADMAP.md`).

### 2026-05-30 – 2026-05-31 — PED/GV audit-fix campaign (Sessions 1–9, strict TDD)
- **Audits produced:** `TECH_DEBT_AUDIT_2026-05-30.md` (Session 1, read-only) and
  `PED_GV_AUDIT_2026-05-30.md` (Session 2 — re-audit of the PED & GV clusters;
  61 confirmed / 2 refuted findings).
- **Correctness bugs fixed** (each test-first under strict TDD, with regression tests):
  - NEW-15 — `countKinshipValues` wrong loop index corrupted accumulated kinship counts
    (the audit's only HIGH-severity bug). `b05133ca`
  - NEW-34 — `getPotentialParents` unbound-`j` crash when `pUnknown` is empty. `dc695a3b`
  - NEW-40 — `findGeneration` returned silent NA generations on cyclic pedigrees;
    now warns at the choke point. `ea5d28fa`
  - NEW-37 — `correctParentSex` silently overwrote recorded H/U parent sex to M/F. `6b0ae333`
  - NEW-48 — `calcFEFG`/`calcFE`/`calcFG` crashed on partial parentage; now a clear
    `stop()`. `19350559`
  - NEW-25 — `getProportionLow` crashed on empty input; now a clear `stop()`. `587ba042`
  - NEW-52 — `cumulateSimKinships` standard deviation undefined for n<2: n=1 → NA matrix +
    warning, n<1 → clear `stop()`. (Audit's catastrophic-cancellation mechanism empirically
    disproved as unreachable for dyadic-rational kinship values.) `e3c7e8b3`

## Earlier work (pre-methodology, migrated from BACKLOG.md history)
- Pyramid plot module update.
- Lint cleanup and unused-code removal.
- Changed package name to mprcgenekeepr for side-by-side development.
- Initial Shiny module commit structure.
