# Roadmap

## Current Milestone
**Shiny application modularization** — converting the monolithic `inst/application/`
(server.R, ui.R) into discrete, testable Shiny modules in `R/`. **Complete (Phase 9).**
The modular architecture — `modInput`, `modPedigree`, `modPyramid`, `modGeneticValue`,
`modSummaryStats`, `modBreedingGroups`, `modORIPReporting` and others (see the `R/mod*.R`
files), with `appServer`/`appUI` orchestrating module communication — is now
canonical, and the legacy monolith has been retired: `inst/application/` is deleted and
`runModularApp()` is a deprecated alias for `runGeneKeepR()`. Version 2.0.0 is tagged
(`v2.0.0`); the package is now at 2.99.0.9000 (releases as 3.0.0). Remaining work is integration testing
(see Planned) and any CRAN follow-up.

## Planned
*(Scoped but not started. The active task list is in `BACKLOG.md`.)*
- Integration testing for the modularized Shiny app (target >80% coverage).
- CRAN follow-up for 2.0.0 (the plan and runbook are in `docs/planning/`; acceptance on CRAN
  is not recorded here).
- **Documentation engine: Hybrid (Quarto + R Markdown)** — adopted 2026-06-17, Option B of
  `docs/planning/quarto-documentation-future-proofing-analysis.md`. The four CRAN vignettes
  stay on `knitr`/`rmarkdown` (zero CRAN risk); new and non-CRAN documentation moves to Quarto
  — pkgdown articles (mixed `.qmd`/`.Rmd` mode), slide decks (`revealjs`), and the
  `dev/extdata-scratch/` developer docs. The long-form manual is repositioned onto the Quarto website
  and dropped from the CRAN vignette set (§6.3(b)), coordinated with the CRAN resubmission.
  Implementation is per-slice, in separate sessions — see the analysis doc §7.1.
  **Slice 1 done (S106):** `inst/extdata/meeting_notes.Rmd` → `.qmd` (build-ignored dev doc; now `dev/extdata-scratch/meeting_notes.qmd`).
  **Slice 2 done (S107):** pkgdown mixed `.qmd`/`.Rmd` mode stood up (`vignettes/articles/_quarto.yml`)
  + first Quarto article `vignettes/articles/breeding-group-formation.qmd` (build-ignored,
  website-only, zero CRAN risk; verified via `quarto render` + `pkgdown::build_article`).
  **Articles:** the first four (S107–S110) were scripted, non-Shiny walkthroughs on shipped data;
  the set has since grown (see `vignettes/articles/` for the current list). Adding more is a
  drop-in `.qmd` (no new config), each verified the same way.
  **Slices 3 and 4** (the manual leaving the CRAN vignette set): status not recorded here; the
  manual is still a CRAN vignette (`a3manual.Rmd`) at 2.99.0.9000 (releases as 3.0.0).
- **Audit follow-ups** (full findings in `PED_GV_AUDIT_2026-05-30.md`; the judged status of each
  id is in `docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md`, and what is still open is in the
  PED_GV item of `BACKLOG.md`). The earlier list here (NEW-53, NEW-20 and the
  `create_test_app` debt) is done; the other ids were not re-checked.

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
- **Genetic diversity dashboard** — a red/yellow/green stoplight heat map with breeding
  groups as rows and diversity metrics as columns (Value, Origin, Production, Inbreeding),
  surfaced as the **"Genetic Diversity"** tab; flags breeding-group problems proactively
  for colony managers.
- **Shiny application** (`runGeneKeepR()`), now organized as Shiny modules.

## Completed Milestones
- **PED/GV correctness campaign (2026-05, Sessions 1–9):** audited the pedigree (PED) and
  genetic-value (GV) function clusters and fixed every confirmed correctness bug test-first
  under strict TDD (NEW-15/34/40/37/48/25/52). Details in `CHANGELOG.md` and, for the ids,
  `docs/archive/CHANGELOG-legacy-pre-S325.md`.
