# Roadmap

## Current Milestone
**Shiny application modularization** — converting the monolithic `inst/application/`
(server.R, ui.R) into discrete, testable Shiny modules in `R/`. **Complete (Phase 9).**
The modular architecture (see `NEWS.md` 1.1.0.9000) — `modInput`, `modPedigree`,
`modPyramid`, `modGeneticValue`, `modSummaryStats`, `modBreedingGroups`,
`modORIPReporting`, with `appServer`/`appUI` orchestrating module communication — is now
canonical, and the legacy monolith has been retired: `inst/application/` is deleted and
`runGeneKeepR()` is a deprecated alias for `runModularApp()`. Remaining work is
integration testing and CRAN-submission preparation.

## Planned
*(Scoped but not started. The active task list is in `BACKLOG.md`.)*
- Integration testing for the modularized Shiny app (target >80% coverage).
- CRAN submission preparation.
- **Documentation engine: Hybrid (Quarto + R Markdown)** — adopted 2026-06-17, Option B of
  `docs/planning/quarto-documentation-future-proofing-analysis.md`. The four CRAN vignettes
  stay on `knitr`/`rmarkdown` (zero CRAN risk); new and non-CRAN documentation moves to Quarto
  — pkgdown articles (mixed `.qmd`/`.Rmd` mode), slide decks (`revealjs`), and the
  `inst/extdata/` developer docs. The long-form manual is repositioned onto the Quarto website
  and dropped from the CRAN vignette set (§6.3(b)), coordinated with the CRAN resubmission.
  Implementation is per-slice, in separate sessions — see the analysis doc §7.1.
  **Slice 1 done (S106):** `inst/extdata/meeting_notes.Rmd` → `.qmd` (build-ignored dev doc).
  **Slice 2 done (S107):** pkgdown mixed `.qmd`/`.Rmd` mode stood up (`vignettes/articles/_quarto.yml`)
  + first Quarto article `vignettes/articles/breeding-group-formation.qmd` (build-ignored,
  website-only, zero CRAN risk; verified via `quarto render` + `pkgdown::build_article`).
  **Articles so far (S107–S109):** `breeding-group-formation.qmd`, `genetic-value-analysis.qmd`,
  `studbook-quality-control.qmd` — each a scripted, non-Shiny walkthrough on shipped data; adding
  more is a drop-in `.qmd` (no new config), each verified the same way.
- **Audit follow-ups** (full findings in `PED_GV_AUDIT_2026-05-30.md`; open items in
  `BACKLOG.md`): NEW-53 (in-place ped mutation), NEW-45 (`geneDrop` period-in-id),
  NEW-20 (delete dead `makeGeneticDiversityDashboard.R`), PED-1/NEW-17 (founders-helper
  extraction), NEW-13/23 (calcFE/FG → calcFEFG consolidation), and the `create_test_app`
  test-infrastructure debt.

## What's Built
*(Feature inventory — what the package does today.)*
- **Quality control** of studbooks (text files, Excel workbooks, LabKey EHR pedigrees):
  parent-record verification, sex validation (no male dams / female sires), duplicate and
  date checks, minimum-parent-age verification.
- **Pedigree creation** from animal lists via LabKey EHR integration (`Rlabkey`).
- **Age-sex pyramid plots** for demographic analysis of living animals.
- **Genetic value analysis** reports — mean kinship and genome uniqueness, with a ranking
  scheme favoring low mean kinship / high genome uniqueness.
- **Breeding group formation** that avoids mating close relatives, supports sex-ratio and
  harem configurations, and maximizes genetic diversity.
- **Shiny application** (`runGeneKeepR()`), now organized as Shiny modules.

## Completed Milestones
- **PED/GV correctness campaign (2026-05, Sessions 1–9):** audited the pedigree (PED) and
  genetic-value (GV) function clusters and fixed every confirmed correctness bug test-first
  under strict TDD (NEW-15/34/40/37/48/25/52). Details in `CHANGELOG.md`.
