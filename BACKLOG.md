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
- [ ] **CRAN resubmission of v2.0.0** (READY, Effort S) -- CRAN responded 2026-07-09:
      the v2.0.0 submission (S329, `devtools::submit_cran()`, `CRAN-SUBMISSION` sha
      `8ca8bb24`) was archived before publication because `appServer()` unconditionally
      wrote `~/nprcgenekeepr.log` on every boot, violating CRAN Policy. **Fixed in
      S349** (`R/appServer.R`: the file appender is now gated behind the "Debug on"
      checkbox's already-tested `debugMode` reactive, never written unconditionally;
      see `CHANGELOG.md` 2026-07-10 S349 entry for full verification detail incl. a
      live-browser Phase 3E smoke test). Next (owner action): re-run the win-builder /
      R-hub pre-submission checks and resubmit via `devtools::submit_cran()`. No
      version bump is required (the prior 2.0.0 attempt was archived before
      publication) unless the owner prefers one.

## Documents (v1.0.8 -> v2.0.0 write-up)
- [ ] **Execute "Document 2" plan (Phase D)** (READY, Effort M) -- planning session DONE
      (S345), Phase A DONE (S346), Phase B DONE (S347), **Phase C DONE (S348)**:
      `docs/planning/document2-colony-manager-guide-plan.md` §6 Phase C. Drafted
      `vignettes/articles/colony-manager-guide.qmd` (Abstract, Introduction, Sections 1-3,
      Conclusion); Section 3 ported/modernized from `ColonyManagerTutorial.Rmd` using Phase
      B's screenshots and Phase A's re-derived N1/N2/N3/N4 numbers verbatim. Owner-resolved
      pre-drafting decisions: Input-tab narrates CSV with an inline Excel-bug caveat;
      Breeding-Groups subsection covers None/Harem fully, omits the Custom-ratio numeric
      demo (N7). Extended `colony-manager-guide-screenshots.R` with 2 more captures
      (owner-approved) for the Genetic Diversity and Potential Parents tabs, which Phase
      B's tutorial-figure-based inventory had no way to include. `quarto render` of the
      article in isolation succeeds cleanly (zero missing images, zero unresolved
      cross-references). Next: **Phase D** -- assemble (Abstract/Introduction/Conclusion
      full pass), full claim-source audit, decide `ColonyManagerTutorial.Rmd`'s fate (§11
      decision 3), re-verify the pkgdown Reference-page citation live (§8 dragon 5 --
      the underlying dead-config bug this dragon flagged is now **fixed**, S354: root
      `_pkgdown.yml` carries the grouped `reference:` block and is re-synced against
      current `NAMESPACE`; see below and `CHANGELOG.md`. Phase D's live re-verify is
      now confirming a real, working grouped Reference page, not chasing a still-open
      bug), and run the full verification checklist (§9: `pkgdown::build_article()`,
      `R CMD build .` + tarball check, spot-check sibling articles). See the plan's §6
      Phase D for full completion criteria. All three findings Phase C's screenshot
      capture surfaced are now
      **fixed** (Excel-upload corruption S350; non-functional Custom sex ratio S351;
      missing-`fromCenter` example data S353 -- see below and `CHANGELOG.md`), so Phase D can
      update the Potential Parents subsection to show the now-populated result (1,587
      candidates) instead of only the graceful-degradation screenshot, if desired. The
      Custom-ratio numeric demo (N7), omitted from Section 3's Breeding-Groups subsection per
      S348's pre-drafting decision, can also be added in Phase D if desired -- the control
      works end to end as of S351.

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
