# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Active
- [ ] (none in progress)

## Up Next
- [ ] **Act on the LabKey integration research recommendations** (BLOCKED -- remainder
      needs a live LabKey server to test/observe, Effort M) — research pass DONE
      (`docs/research/labkey-integration-options-2026-06-19.md`, S143). **Rec #3 (explicit optional
      API-key auth with `.netrc` fallback + clear error) DONE — S144, `setLabKeyDefaults()`.
      Rec #1 (`Rlabkey` version floor) DONE — S146, `Rlabkey (>= 3.2.0)` in `DESCRIPTION` (all four
      EHR-module repos target LabKey 26.6; the live ONPRC/SNPRC server version, doc §8.1, is still
      unobserved). See `CHANGELOG.md`.
      Rec #2 (config-ize the ONPRC defaults) DONE — S147: centralized into the internal
      `defaultSiteParams()` (single source of truth for `getSiteInfo()`'s no-config fallback; no
      behavior change) + documented the center-specific `lkPedColumns` form in the example config
      (flat `dam`/`sire` = SNPRC direct columns; `Id/parents/dam` = ONPRC curated lookup). All three
      quick wins (Rec #1/#2/#3) DONE.**
      Rec #4/#5 (formalize a data-source adapter on the `getPedDirectRelatives` seam + a deterministic
      mocked integration test) DONE (fetch-boundary slice) — S148: internal `getPedigreeSource()`
      (`labkey` | `dataframe`) now backs `getLkDirectRelatives()`'s fetch with the walk byte-identical,
      plus the first deterministic walk test. **Walk-unification DONE — S149:** `getLkDirectRelatives()`
      now delegates its pedigree walk to `getPedDirectRelatives()`, so the LabKey/EHR path returns the
      full connected pedigree component (collaterals included), consistent with the in-memory function —
      a deliberate, owner-accepted behavior change; the deterministic test now asserts the full
      component incl. the previously-excluded collateral sibling. **`file` provider DONE — S150:**
      `getPedigreeSource()` gained a `"file"` source (params `fileName`/`sep`) that reads a pedigree file
      (CSV or Excel) via the exported `getPedigree()`, alongside `"labkey"` and `"dataframe"`;
      offline-deterministic, validates id/sire/dam, errors loudly like the `dataframe` branch.
      **`"file"` provider WIRED to a first-class caller DONE — S151:** new exported
      `getFileDirectRelatives(ids, fileName, sep, unrelatedParents)`, a file-sourced sibling of
      `getLkDirectRelatives()` (reads via the `"file"` provider, then the source-agnostic
      `getPedDirectRelatives()` walk). The clean symmetric family is now `getPedDirectRelatives`
      (in-memory) / `getLkDirectRelatives` (LabKey) / `getFileDirectRelatives` (file).
      **Option C — file pedigree source through the focal-animal app pipeline DONE — S152:** new exported
      `getFocalAnimalPedFromFile(fileName, pedigreeFileName, sep)`, a file-sourced sibling of
      `getFocalAnimalPed()` (reads focal Ids from one file, builds the connected component from a separate
      pedigree file via `getFileDirectRelatives()`; fail-soft to a classed `nprcgenekeeprFileErr` whose
      `message` names WHY the read failed — bad focal-id list file, a missing/not-found/unreadable/
      wrong-column pedigree file, or no focal IDs matched — surfaced as the app's "File Read Error"
      detail (richer error messages added S155). `modInput`
      gained an optional pedigree-file input on the focal-animals path and dispatches to the offline
      function when supplied, else the unchanged LabKey path — so the Shiny focal-animal workflow can now
      run offline with no LabKey/EHR connection. (The focal-id read was factored into a shared internal
      `readFocalAnimalIds()`.) **Still deferred:**
      a non-LabKey other-EHR provider on the same seam; server-side filtering / `executeSql` / consuming
      the centers' `study.Pedigree`/`ehr.kinship` (research doc explicitly defers until pull size is
      measured + per-center query availability/permissions are confirmed; needs a live LabKey server to
      test/observe, and a naive focal-id server filter is incompatible with the client-side
      connected-component walk).
- [ ] **CRAN submission preparation** (BLOCKED -- external, Effort S to re-scope) —
      v2.0.0 was already submitted to CRAN (S329, `devtools::submit_cran()`,
      `CRAN-SUBMISSION` sha `8ca8bb24`); CRAN's review outcome is still pending as of
      2026-07-09 (per the v2.0.0 article's own Scope note). This item may be stale --
      whichever session picks it up should first check whether CRAN has responded and
      re-scope or close accordingly, not assume "preparation" is still the right verb.

## Documents (v1.0.8 -> v2.0.0 write-up)
- [ ] **Execute "Document 2" plan (Phase C)** (READY, Effort M) -- planning session DONE
      (S345), Phase A DONE (S346), **Phase B DONE (S347)**:
      `docs/planning/document2-colony-manager-guide-plan.md` §6 Phase B. Checked-in
      capture script `vignettes/articles/colony-manager-guide-screenshots.R` regenerated
      all 34 screenshots (25 in place, 4 new, 5 correctly left untouched as non-app-UI
      spreadsheet illustrations); deleted the 8 confirmed-orphaned pre-rename duplicates.
      Live numeric reproductions confirmed matching Phase A exactly: 3694 QC'd records
      (N1), 54-animal focal trim (N2), 962-animal large-focal-group trim (N3, via the
      shipped `focalAnimals` object), 332 living animals (N4). Next: **Phase C** -- port
      and draft Sections 1-3 (`vignettes/articles/colony-manager-guide.qmd`) using this
      phase's screenshots and Phase A's re-derived numbers. See the plan's §6 Phase C for
      full completion criteria (risk MEDIUM, highest claim-density phase). Phase C must
      account for two new findings below (Excel-upload corruption; non-functional Custom
      sex ratio) when drafting Section 3's Input/Breeding-Groups narrative.
- [ ] **Excel-upload silently corrupts sire/dam pedigree data** (READY, Effort M) --
      discovered during S347's Document-2 Phase B screenshot capture.
      `R/modInput.R`'s `readDataFile()` calls `readxl::read_excel(file$datapath)` with no
      `col_types` argument; `readxl` infers each column's type from an early row sample,
      guesses `logical` because early sire/dam values are blank (unknown/founder rows),
      then silently converts every later alphanumeric sire/dam ID it cannot parse as
      logical to `NA`. Confirmed on an Excel round-trip of the shipped
      `data(examplePedigree)` via `makeExamplePedigreeFile(..., fileType = "excel")`:
      **2026/2026 (100%) of non-blank sire values and 2023/2026 dam values become `NA`**,
      with 4049 `readxl` warnings never surfaced to the app user -- the pedigree silently
      becomes almost entirely founders, with no error pointing at the cause. The CSV path
      is unaffected (byte-identical round-trip, verified). This is the exact code path
      any real user's Excel-format pedigree upload goes through via the Input tab, not
      specific to any test/demo script. Fix: pass an explicit `col_types` (e.g. `"text"`
      for id/sire/dam, or column-specific types matching the documented pedigree schema)
      to `readxl::read_excel()`, or `guess_max = Inf`; add a regression test using a
      pedigree shaped like the shipped example (many blank-parent rows before
      alphanumeric ones). HIGH priority -- this is silent production data corruption on
      the package's primary documented upload path (Excel is the tutorial's default
      format), not a documentation-only issue.
- [ ] **Breeding Groups "Custom" sex ratio has no way to specify the ratio** (READY,
      Effort S) -- discovered during S347's Document-2 Phase B screenshot capture.
      `modBreedingGroupsUI()`'s `sexRatio` radioButtons offers "None"/"Harem
      (1M:NF)"/"Custom" (`R/modBreedingGroups.R`), but no numeric input for the custom
      ratio value exists anywhere in the UI (confirmed via grep of the full file). The
      server's `parseSexRatio(input$sexRatio)` calls `as.numeric(sexRatioInput)` on the
      literal string `"custom"`, which is `NA` and silently falls back to `0.0` --
      behaviorally identical to selecting "None". A colony manager selecting "Custom"
      today gets no ratio control and no indication anything is wrong. Fix: add a
      `conditionalPanel`-gated `numericInput` (e.g. `customSexRatio`, shown when
      `sexRatio == "custom"`) and thread its value into `parseSexRatio()`. Blocks Document
      2 Phase C from faithfully porting `ColonyManagerTutorial.Rmd`'s "sex ratio of 2.5"
      demonstration (plan doc §3A N7) until fixed.
- [ ] **Document 1's Testing-at-Scale section conflates file-count growth with testing
      quality** (READY, Effort S) -- `vignettes/articles/engineering-the-2.0.0-release.qmd`
      §Section 3 (`#sec-testing`, ~L392-455) leads with "the test suite grew from 132 to
      257 `.R` files... a 95% increase" as its headline metric and never cites an actual
      `covr`/Codecov coverage percentage or a test-*case* count, despite the project
      having a live Codecov badge (`README.md`) and a `test-coverage.yaml` CI workflow
      the section itself references by filename (L524) without quoting its output. The
      word "coverage" appears three times in the section, none of them a quantified
      code-coverage figure -- twice describing E2E *behavioral* coverage ("Coverage at
      the end of 8d was boot-level") and once naming the CI workflow file. File-count
      growth is a real but weak proxy: more files can mean more tests, better coverage,
      or more E2E depth, but doesn't by itself establish any of the three, and the
      section's own prose (rightly) argues the *kind* of test that improved (E2E
      dormant-to-executable-to-behavioral) matters more than the count -- it just never
      backs that argument with the coverage number that would make it load-bearing
      rather than qualitative. (User-flagged, S345.) Fix: pull an actual `covr::package_coverage()`
      percentage (or the Codecov API's recorded value) at both endpoint commits
      (`4548aa1b`, `8ca8bb24`) if reconstructable, or at minimum the current value with
      an honest "not reconstructable at the v1.0.8 endpoint" caveat if not; consider also
      citing total test-*case* count (not just file count) alongside the existing file-count
      table.
- [ ] **`inst/_pkgdown.yml`'s curated Reference-page grouping is dead configuration**
      (READY, Effort S) -- discovered during S345's Document-2 planning research.
      `pkgdown`'s own config resolver (`pkgdown:::pkgdown_config_path`) picks the first
      existing file from `_pkgdown.yml`, `_pkgdown.yaml`, `pkgdown/_pkgdown.yml`,
      `pkgdown/_pkgdown.yaml`, `inst/_pkgdown.yml`, `inst/_pkgdown.yaml` in that order;
      the project's root `_pkgdown.yml` exists (no `reference:` key), so
      `inst/_pkgdown.yml`'s "Data objects"/"Major Features and Functions"/"Primary
      interactive functions"/"All exposed functions" grouping is never read. Confirmed
      live on the deployed site (`https://rmsharp.github.io/nprcgenekeepr/reference/index.html`):
      a flat "All functions" list only, not the grouped structure `README.md:86-94`
      describes. Independently, `inst/_pkgdown.yml`'s own lists have drifted from
      `NAMESPACE` regardless (64 of 182 current exports missing from its "All exposed
      functions" list, incl. every `mod*Server`/`mod*UI` pair) -- so fixing the shadowing
      alone is not sufficient; the lists need re-syncing too, or the `reference:` block
      should be regenerated fresh rather than merely un-shadowed. Fix: either move/merge
      `inst/_pkgdown.yml`'s `reference:` block into the root `_pkgdown.yml` (re-synced
      against current `NAMESPACE`), or delete `inst/_pkgdown.yml` if the grouped
      structure is no longer wanted and update `README.md:86-94` to match whichever is
      chosen. See `docs/planning/document2-colony-manager-guide-plan.md` §1 for full
      verification detail.

## Audit follow-ups
*(From `PED_GV_AUDIT_2026-05-30.md`; the audit compute/test items are all resolved — see
`CHANGELOG.md`. Per-item reachability notes and traps live in `CLAUDE.md` "Project-specific
Learnings".)*
- [ ] **NEW-12 / XARCH-3** (READY, Effort S) — Shiny progress hook. **Mostly resolved** per the S21 plan §8: `reportGV` /
      `groupAddAssign` are already shiny-free with an injected `updateProgress` hook; the only real leak
      `getMinParentAge` was a dead orphan (removed in Phase 9, S35). Treat as SEPARABLE cleanup.

## Tracker reconciliation (open question for the user)
- (DECISION NEEDED, Effort S) The remaining audit follow-ups (XARCH-2..8) are **not** GitHub issues; the live tracker is #1–#39.
  Decide whether to file the remaining XARCH items as issues or keep them here. They currently coexist.
