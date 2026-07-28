# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Active
- [ ] (none in progress)

## Architecture follow-ups (from TECH_DEBT_AUDIT_2026-05-30.md, re-verified 2026-07-11)
*Resolves the former "Tracker reconciliation" decision item (S365) --
`docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md` re-verified all 8
XARCH-1..8 findings against current source rather than trusting the six-week-old
audit text. XARCH-1/3/7 are fully RESOLVED (no further tracking). XARCH-2 (implicit/
inconsistent module contract) and XARCH-5 (string-column-keyed pipeline, no
validated seam) are STILL OPEN and owner-directed to GitHub issues #122 and #123
respectively -- track them there, not here. XARCH-4 (sex-code literal
centralization) is now also fully RESOLVED -- S367 (2026-07-12): see
`CHANGELOG.md`. XARCH-6 (`qcStudbook()`/`modInput.R` multi-call redundancy) is
now also fully RESOLVED -- S368 (2026-07-12): see `CHANGELOG.md`. XARCH-8's
narrower remaining gap is now also fully RESOLVED -- S369 (2026-07-12): see
`CHANGELOG.md`. The `man/filterPairs.Rd` staleness this recurring collateral
regen left behind (S367 origin, flagged S368/S369) is now also RESOLVED --
S370 (2026-07-12): see `CHANGELOG.md`. No items remain in this section.*
- [ ] (none remaining)

## Up Next
- [ ] (none remaining -- the "verify + likely fix the same low-contrast Mermaid defect in
      colony-manager-guide.qmd" item (flagged S401) is RESOLVED: verified S403 (2026-07-19) --
      NOT affected (the diagram is a plain `flowchart LR` with zero `subgraph` blocks; the actual
      defect is scoped to subgraph/cluster CSS, not a blanket pkgdown-mixed-mode issue -- see
      `PROJECT_LEARNINGS.md` Learning 371, which corrects Learning 369's root-cause claim).
      `format: html: mermaid: theme: default` applied to this file's frontmatter anyway, owner
      directed, as a defensive/future-proofing measure. See `CHANGELOG.md`.)
- [ ] (none remaining -- the "fix broken 'Read deeper' links in the colony-manager-guide
      article" item (issue [#124](https://github.com/rmsharp/nprcgenekeepr/issues/124), filed
      S400) is RESOLVED on the `fix/figure2-contrast-engineering-2.0.0-release` branch --
      fixed S404 (2026-07-20): all 10 `.qmd` hrefs retargeted directly to `.html`
      (`vignettes/articles/colony-manager-guide.qmd:26,50,99-103,374,534`). Pre-work
      verification found Learning 368's "pkgdown's mixed-mode build doesn't perform the
      rewrite" framing was incomplete -- a bare local `quarto render` of the same project
      (no pkgdown involved) produces the identical unrewritten `.qmd` href, because the
      rewrite is a `type: website`/`book` Quarto project feature this directory's
      `_quarto.yml` never enables (see `PROJECT_LEARNINGS.md` Learning 372, which corrects
      Learning 368). All 7 distinct link targets confirmed live at the fixed relative path
      (HTTP 200) before editing; rendered output re-verified to contain zero remaining
      `.qmd` hrefs. **Issue #124 stays open** -- the fix is on the unmerged/unpushed branch
      below, not yet live on the published site. See `CHANGELOG.md`.
      **A second, distinct instance found and fixed S407 (2026-07-21)** -- owner-reported
      live 404 at `.../articles/articles/colony-manager-guide.qmd`, traced to
      `vignettes/ColonyManagerTutorial.Rmd:9` (the retired-tutorial stub, already merged to
      `master` via S398, unlike the branch above): a relative link with a doubled
      `articles/` path segment (this file renders under `/articles/` too, so its own
      `articles/`-prefixed relative link doubled) plus the same `.qmd`-vs-`.html` defect.
      Fixed by pointing the link at the absolute published URL, and by renaming the file to
      `_ColonyManagerTutorial.Rmd` -- pkgdown's `build_articles()` skips any leading-`_`
      vignette by documented convention (verified against the installed pkgdown 2.2.0's own
      `package_vignettes()` source, not assumed), which finally makes true the file's own
      claim that it is not part of the public site (previously false: no `_pkgdown.yml`
      exclusion existed, so pkgdown was building and serving it). Owner also directed a full
      live-site link sweep (all 13 published articles + articles/reference/news index hubs,
      238 resolved internal targets, HTTP-checked) -- no other broken links found; see
      `CHANGELOG.md` and the issue #124 comment thread for the full sweep result.
      **Merged and deployed live -- S408 (2026-07-21):** owner approved merging
      `fix/figure2-contrast-engineering-2.0.0-release` into `master` (`dd8e53fd`) now
      that the CRAN v2.0.0 submission is sufficiently handled. Live verification after
      deploy found a second, unrelated defect blocking the fix from actually taking
      effect: `.github/workflows/pkgdown.yaml`'s `clean: false` deploy step meant
      `gh-pages` had only ever accumulated files, never removed stale ones (981 files,
      including 3 old copies of this same tutorial, one still serving the exact
      `.qmd`-targeting link live). Fixed (`clean: true`, `f5b73edf`), redeployed,
      verified: `gh-pages` dropped to 650 files, zero `ColonyManagerTutorial` matches,
      all stale URLs 404, `colony-manager-guide.html` has zero remaining `.qmd` hrefs.
      **Issue #124 is now fully resolved live**, not just in source. See `CHANGELOG.md`.)
- [ ] (none remaining -- the "Branch-merge strategy for
      `fix/figure2-contrast-engineering-2.0.0-release`" item is RESOLVED: merged into
      `master` and deployed live -- S408 (2026-07-21), see the issue #124 item above and
      `CHANGELOG.md`.)
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
- [ ] (none remaining -- the "CRAN resubmission of v2.0.0" item is RESOLVED:
      **CRAN accepted the 2.0.0 submission and published it 2026-07-26**
      (confirmed live via CRAN's own package page and CRAN's automated
      Windows-binary-build notification email). The full submission saga --
      archived 2025-07-29, resubmitted, rejected S392 on Windows checktime,
      fixed and resubmitted S395-397, CRAN's incoming-pretest confirmed
      clean S399 -- is recorded session-by-session in `CHANGELOG.md`.
      **Phase 6 (Post-acceptance, `docs/planning/cran-2.0.0-submission-plan.md:324`)
      executed -- S410 (2026-07-28):** the `v2.0.0` GitHub Release created
      (the tag and the `DESCRIPTION` dev-version bump to `2.0.0.9000` were
      already done ahead of time in S407); `CRAN-SUBMISSION` deleted (its
      job is resolved); `NEWS.Rmd`'s stale "under review" dev-version note
      fixed. See `CHANGELOG.md`. If a future CRAN cycle requires a
      fix-and-resubmit, it ships as **2.0.1** -- the `v2.0.0` tag never
      moves, since it is the one and only submission that will ever carry
      that version number.

## Housekeeping
- [ ] (none remaining -- the "clean up stale untracked leftover files" item (filed
      S383) is RESOLVED: 18 confirmed-dead untracked files deleted -- S384
      (2026-07-15). See `CHANGELOG.md`.)
- [ ] (none remaining -- the "`README.Rmd` leaves an untracked `README.html`
      byproduct on every render" item (flagged S410, `PROJECT_LEARNINGS.md`
      Learning 376(b)) is RESOLVED: `html_preview: false` added to
      `README.Rmd`'s `output: github_document` frontmatter, mirroring
      `NEWS.Rmd`'s already-working pattern -- S411 (2026-07-28). Verified by
      re-rendering: no `README.html` byproduct produced. See `CHANGELOG.md`.)
- [ ] (none remaining -- the "`CLAUDE.md`'s 'Clean regression read' command
      needs a `pkgload::load_all()` call added" item (flagged S411,
      `PROJECT_LEARNINGS.md` Learning 377) is RESOLVED: `pkgload::load_all(".",
      quiet=TRUE)` prepended to the documented command text (`CLAUDE.md:149`) --
      S412 (2026-07-28). Verified by running the fixed command verbatim: 0
      failed/0 error/0 warning, 3198 passed, 179 skipped, matching the known-good
      baseline. See `CHANGELOG.md`.)

## Architecture (issue #122 / XARCH-2 -- module contract)
*Resolved -- S372 planning session through S377 execution (Phases 1-5, all DONE); see
`CHANGELOG.md` for the per-phase detail (S373 vocabulary-composition fix, S374 kinship
dedup, S375 vocabulary collapse, S376 dead-surface pruning, S377 contract doc + guard
test). The living contract is `docs/architecture/module-contract.md`; it is enforced by
`tests/testthat/test_moduleContract.R`. `modInput` is the reference implementation.*
- [ ] (none remaining)
- [ ] (none remaining -- the former "4 remaining unguarded `getSiteInfo()` call sites"
      item is now fully resolved: `R/getPedigreeSource.R:83`/`R/getLkDirectAncestors.R:26`
      guarded S382 (see `CHANGELOG.md`); `R/modORIPReporting.R:148`/`:244`,
      `R/appServer.R:124` guarded S380. The remaining 2 sites now stand as their own item
      below, since they need a genuinely different design decision.)
- [ ] (none remaining -- the "`setLabKeyDefaults()`/`getDemographics()` unguarded
      `getSiteInfo()` call sites" design-decision item is RESOLVED: decline, no code
      change -- S383 (2026-07-15). See `CHANGELOG.md`.)
- [ ] (none remaining -- issue #123 (XARCH-5) Phase 1 implementation (S386) and the
      follow-up GitHub issue comment reflecting partial, scoped closure (S387,
      2026-07-15, https://github.com/rmsharp/nprcgenekeepr/issues/123#issuecomment-4986749021)
      are both done; the issue is left OPEN, per the plan's own §10 decision 5, pending
      the escalation triggers it names. See `CHANGELOG.md`.)

## Documents (v1.0.8 -> v2.0.0 write-up)
- [ ] (none remaining -- Document 2 (`docs/planning/document2-colony-manager-guide-plan.md`)
      is fully executed: planning DONE (S345), Phase A DONE (S346), Phase B DONE (S347),
      Phase C DONE (S348), **Phase D DONE (S398, 2026-07-17)** -- full claim-source audit,
      `pkgdown`/`R CMD build` verification, and the `ColonyManagerTutorial.Rmd`
      retire/redirect decision. See `CHANGELOG.md`.)

## Audit follow-ups
*(From `PED_GV_AUDIT_2026-05-30.md`; all audit follow-up items are now resolved — see
`CHANGELOG.md`. Per-item reachability notes and traps live in `CLAUDE.md` "Project-specific
Learnings".)*
- [ ] (none remaining)
