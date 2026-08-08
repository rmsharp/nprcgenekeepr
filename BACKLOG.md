# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Active
- [ ] (none remaining -- issue #126 (kinship/genome-uniqueness
      distribution-shape statistics) is DONE -- S429 (2026-07-29): see
      `CHANGELOG.md`. Per the owner-ratified sequencing below, planning +
      implementing #127 and #129 (either order) are next; planning #130
      follows all three.)
- [ ] (none remaining -- Slice 2 of the issue #125 plan (surface multiple
      breeding-group candidates) is DONE -- S425 (2026-07-29): see
      `CHANGELOG.md`. Both slices of the issue #125 plan are now shipped;
      issue #125 itself is closed as part of this session's close-out.)

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
- [ ] (none remaining -- the "`NEWS.Rmd` has no checklist analogous to the
      citation/tutorial checklists" item (discovered S446, 2026-08-01) is
      RESOLVED: owner ratified a broad checklist via `AskUserQuestion` --
      any session shipping a new exported function OR a user-facing Shiny
      feature/control must add a `NEWS.Rmd` entry in the same session it
      ships, mirroring the citation (issue #120) and tutorial/article
      (S436) checklists. Recorded in `CLAUDE.md`'s "Additional close-out
      checks" -- S448 (2026-08-01). Owner also directed backfilling issue
      #130's Slices 1-5 as a one-time exception: 5 new `NEWS.Rmd` bullets
      added to the 2.0.0.9000 section (Marker Genetics tab + Kinship,
      Heterozygosity, Parentage Exclusion, and Cross-Center sub-tabs, plus
      the script-callable `resolveCrossCenterIds()`), re-rendered to
      `NEWS.md` -- diff confirmed exactly the 5 new bullets, no reflow
      churn. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 433.)
- [ ] (none remaining -- the "`vignettes/a2interactive.Rmd` has no checklist
      analogous to the Shiny-app-facing tutorial/article checklist, and
      issue #130's entire marker-genetics function family has ZERO mentions
      there" item (discovered S447, 2026-08-01, `PROJECT_LEARNINGS.md`
      Learning 435) is RESOLVED -- S450 (2026-08-02): owner picked option
      (a) via `AskUserQuestion` -- extended `CLAUDE.md`'s existing
      documentation-checklist family with a new, explicitly DEFERRED
      (not same-session) rule requiring `a2interactive.Rmd` coverage for
      new exported, script-callable functions, added post-review rather
      than in the shipping session (`CLAUDE.md` "Additional close-out
      checks"). Owner also directed backfilling issue #130's 5
      already-shipped marker-genetics functions in this same session (a
      second, separate `AskUserQuestion`), mirroring the `NEWS.Rmd`
      checklist's own one-time backfill precedent (Learning 436). Added a
      new "## Marker Genetics" section to `vignettes/a2interactive.Rmd`
      (6 subsections: preparing a marker genotype file, marker-based
      kinship, heterozygosity diagnostic, parentage verification, cross-
      center identity linking, cross-center Fst) reusing the SAME
      hand-verified fixtures already used by the Shiny app's own
      Marker Genetics tab screenshots in `colony-manager-guide.qmd` (the
      P/C/U kinship/parentage trio, the X/Y/Z heterozygosity trio, and the
      Center A/B Fst fixture from `test_modMarkerGenetics.R`), so the
      tutorial's printed numbers match the article's tables. Every demo
      chunk verified against the real installed package (not hand-derived)
      before and after embedding -- see `PROJECT_LEARNINGS.md` Learning
      440 for a stale-local-install trap hit and fixed along the way
      (`devtools::install()` needed first; the local install lagged 3
      slices behind source). See `CHANGELOG.md`.)
- [ ] (none remaining -- the "`devtools::check()`'s spelling NOTE is
      broader than previously tracked" item (discovered S443 as just
      `IACUC`; broadened S448, 2026-08-01) is RESOLVED -- S452
      (2026-08-02): re-ran `devtools::check()` fresh before touching
      anything and found the single NOTE actually covered 13 words, not
      12 -- the 12 the item named (`Bhatia`, `Chesser`, `Cockerham`,
      `Fst`/`FST`, `Gst`, `Hedrick`, `Maddison`, `Meirmans`,
      `Sankararaman`, `Slatkin`, `monomorphic`) plus the already-tracked
      `IACUC` (`_pedigree_browser.Rmd:55`, flagged since S443, never
      actually fixed by any session in between). All 13 hand-added to
      `inst/WORDLIST` in `LC_ALL=C` byte-order position (not via
      `spelling::update_wordlist()`, per S230 convention). Verified:
      `devtools::check()` raw log now reads `Status: 1 WARNING` with no
      NOTE (the `spelling.Rout`/`spelling.Rout.save` comparison is now
      `OK`, vs. the prior 13-word diff block) -- the remaining WARNING is
      the pre-existing, unrelated iCloud-sync duplicate-file artifact
      (`R/appServer 2.R`/`R/modMarkerGenetics 2.R`); regression suite
      unchanged at 0 failed/0 error (3489 passed, 183 skipped, 10
      pre-existing baseline warnings), exactly matching the known-good
      S450 baseline. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md`
      Learning 441.)
- [ ] (none remaining -- the "Pre-existing `shinyBS is not defined` JS console
      error on every page load" item (discovered S433, 2026-07-30) is
      RESOLVED: fixed S437 (2026-07-30). Root cause confirmed experimentally:
      this package only ever accesses shinyBS via `shinyBS::popify()`/
      `shinyBS::addPopover()` (`R/modSummaryStats.R`), never `library(shinyBS)`
      -- so shinyBS's own `.onAttach()` hook (which registers the `"sbs"`
      `shiny::addResourcePath()` serving `shinyBS.js`/`shinyBS.css`) never
      fires, since `.onAttach()` only runs on attach, not on the namespace
      load that `::` triggers. Fixed by adding `R/zzz.R` with a package
      `.onLoad()` that registers the same resource path itself, guarded by
      `requireNamespace("shinyBS", quietly = TRUE)` (shinyBS is a `Suggests`
      dependency). 2 new unit tests added to
      `tests/testthat/test_modSummaryStats_popovers.R` (resource path
      registered; `.onLoad()` doesn't error when shinyBS is unavailable, via
      `mockery::stub`). Verified live via `shinytest2`/`chromote`: the
      `ReferenceError: shinyBS is not defined` no longer occurs on app load.
      **Live verification surfaced a second, previously-hidden, unrelated
      defect** -- shinyBS 0.65.0's JS is incompatible with this app's bundled
      Bootstrap 4.6.0 popover plugin (`shinyBS.js:207`'s defensive
      `.popover("destroy")` call throws before the actual init call, so
      popovers/tooltips remain completely non-functional, same as before this
      fix, just with a different console error). Not fixed this session, per
      `PROJECT_LEARNINGS.md` Learning 382/407's scope-discipline precedent --
      filed as [issue #140](https://github.com/rmsharp/nprcgenekeepr/issues/140)
      instead. **Issue #140 itself is now RESOLVED -- S438 (2026-07-30):**
      fixed via a JS shim (`inst/www/js/shinyBS-popover-fix.js`, included in
      `R/appUI.R` the same way as `data-ready.js`) that overrides shinyBS's
      mutable `addTooltip` global to guard the `.popover("destroy")`/
      `.tooltip("destroy")` calls that throw under Bootstrap 4.6.0 (Bootstrap
      4 renamed `destroy` -> `dispose`, so the unguarded call fires
      unconditionally, not just when no instance exists). Chosen over 2 other
      researched options (vendor/patch `shinyBS.js`; migrate to
      `bslib::tooltip()`/`popover()`, which turned out to hard-require
      Bootstrap 5 and was out of scope). Verified live via `shinytest2`/
      `chromote`: zero console errors AND a real `bs.popover` instance now
      attaches to both a `popify()`-wrapped button and all 3 `addPopover()`
      targets -- popovers/tooltips are now actually functional, not just
      error-free (matching Learning 414's precedent: verify the underlying
      claim, not just the absence of the originally-reported error). See
      `CHANGELOG.md`.)
- [ ] **`inst/extdata/` reorganization -- Phase 4** (DECISION NEEDED -- 2 open,
      non-blocking decisions, Effort M) -- plan:
      `docs/planning/extdata-reorganization-plan.md` (S414). **Phase 1 DONE -- S415
      (2026-07-28):** relocated the 12 dev-scratch + 12 orphaned zero-reference items
      (24 total -- the plan's own summary table undercounted this as "11 + 9";
      `PROJECT_LEARNINGS.md` Learning 381) into `dev/extdata-scratch/`, removed 3 empty
      untracked dirs (`claude/`, `dev_scripts/`, `uat/`) + the now-empty
      `code_under_development/`, and deleted 11 now-obsolete `.Rbuildignore` lines (the
      10 the plan named plus one it missed, Learning 381) + 10 dead `.gitignore` lines.
      Verified: `devtools::check()` 0 errors/0 warnings (see the new spelling-NOTE item
      below re: the 1 NOTE found, unrelated to this reorg -- Learning 382); `R CMD build`
      tarball no longer contains `create_nprcgenekeepr_hexbadge.R` or any other
      dev-scratch item; regression suite unchanged at 0 failed/0 error/0 warning, 3198
      passed, 179 skipped (S412 baseline). See `CHANGELOG.md`.
      **Phase 2 DONE -- S416 (2026-07-28):** both blocking open decisions resolved first
      -- subfolder name **`examples/`** (owner-picked via `AskUserQuestion`), and
      `vignettes/a2interactive.R`'s generation status (owner-directed: `.Rmd` files are
      the source; `.R`/`.md`/`.html` are generated derivatives -- confirmed also
      gitignored/untracked, `.gitignore:18,20,22`, so the tracked-source fix is the
      `.Rmd` edit alone; the local `.R` copy was regenerated via `knitr::purl()` as a
      courtesy, not committed). `git mv`'d all 10 load-bearing files into
      `inst/extdata/examples/`; updated the central `get_test_data_path()` test helper,
      ~28 individual `system.file()` call sites across 15 test files, 7 path-bearing
      roxygen/comment prose sites (`R/defaultSiteParams.R`, `R/loadSiteConfig.R`,
      `data-raw/rhesusGenotypes.R`, `data-raw/rhesusPedigree.R`, plus 2 test-file
      comments), and the one hardcoded path in `vignettes/a2interactive.Rmd`; regenerated
      `man/loadSiteConfig.Rd` (the only one of the plan's 5 named `.Rd` files that
      actually needed it -- the other 4 are generated from `R/data.R`, whose extdata
      mentions are plain filenames with no path prefix, confirmed unaffected).
      Verified: fresh regression suite exactly matches baseline (0 failed/0 error/0
      warning, 3198 passed, 179 skipped); `R CMD build` tarball confirmed shipping all 10
      files under `examples/` and nothing at the old flat path; `devtools::check()` 0
      errors/0 warnings, 1 NOTE (the same pre-existing, unrelated spelling gap from S415,
      confirmed untouched by this session's diff); grep sweep confirmed the only 3
      remaining un-migrated references are exactly the ones the plan defers to Phase 3
      (`vignettes/manual_components/_summary_of_major_functions.Rmd`'s GitHub blob URL
      source, plus its 2 gitignored rendered byproducts). See `CHANGELOG.md`.
      **Phase 3 DONE -- S417 (2026-07-28):** re-ran the plan's own Dragon 1 grep before
      touching anything (never trust a prior session's or the plan's own phase prose as
      final) and found the plan's Phase 3 "What DONE looks like" text undersold the
      actual scope: `vignettes/articles/offline-focal-animal-workflow.qmd:104,106`
      called `system.file("extdata", "<file>", ...)` directly with no `examples`
      segment -- confirmed in R this returned `""` (broken) since Phase 2 moved the
      files, even though the plan's own §8.1 evidence table had already listed this
      exact call site. Fixed as the source bug it was, not just a re-render target.
      Also fixed the stale GitHub blob URL in
      `vignettes/manual_components/_summary_of_major_functions.Rmd:66`. Re-rendered all
      3 targets (`a3manual.Rmd` with `keep_md = TRUE` to also refresh the gitignored
      `.md` byproduct; `a2interactive.Rmd`; the `.qmd` pkgdown article via `quarto
      render`, which required a throwaway local package install --
      `devtools::install()` -- since the article's `library(nprcgenekeepr)` call needs
      a real install, not just `pkgload::load_all()`). Verified: the fixed
      `system.file()` calls resolve and return real data in the rendered article
      (`dim(colonyPed)` = 2922 x 11, not an error); the plan's prescribed grep sweep
      plus a broadened check of `vignettes/articles/*.html` both return zero stale-path
      hits; `gh api` confirmed the GitHub blob URL target actually exists on
      `origin/master` (Dragon 2's "manual link click" requirement); regression suite
      exact baseline match (0/0/0, 3198 passed, 179 skipped); `devtools::check()` 0
      errors/0 warnings, 1 NOTE (same pre-existing spelling gap below, confirmed
      untouched -- read from the raw check log's `Status:` line per Learning 382, not
      the colored summary, which again showed 0 notes). See `CHANGELOG.md`,
      `PROJECT_LEARNINGS.md` Learning 384.
      **Phase 4 DONE -- S418 (2026-07-28):** both open decisions resolved via
      `AskUserQuestion`: PDF placement -> `inst/extdata/reference/` (end-user-facing
      reference material, plan's own default); orphaned-files archive-vs-delete ->
      keep archived at `dev/extdata-scratch/`, no change from Phase 1. `git mv`'d
      the PDF; ran the plan's final repo-wide sweep grep, which found `README.md`
      stale relative to its already-fixed source (`README.Rmd` `child=`-includes
      `_summary_of_major_functions.Rmd`, fixed by S417, but never re-rendered) --
      re-rendered `README.Rmd` to pick up the fix; see `PROJECT_LEARNINGS.md`
      Learning 385. All other sweep hits triaged as false positives: dated
      historical prose in `NEWS.Rmd`/`NEWS.md` and `docs/planning/`/`docs/research/`
      documents describing repo state as it existed when written, correctly left
      unedited. Verified: `R CMD build` tarball ships the PDF at
      `inst/extdata/reference/` and nothing at the old flat path; regression suite
      exact baseline (0/0/0, 3198 passed, 179 skipped); `devtools::check()` 0
      errors/0 warnings, 1 NOTE (same pre-existing spelling gap below, confirmed
      untouched). **The `inst/extdata/` reorganization plan is now fully executed
      (Phases 1-4 all DONE).** See `CHANGELOG.md`.
- [ ] (none remaining -- the "`ROADMAP.md`'s doc-engine-policy line is now stale"
      item (flagged S418) is RESOLVED: owner resolved the editorial wording call
      via `AskUserQuestion` -- **path-only fix**, keeping the doc-engine-policy
      category and just correcting the location -- `ROADMAP.md:21-22` now reads
      `dev/extdata-scratch/` developer docs instead of `inst/extdata/` developer
      docs, matching where the 3 dev docs (`claude_code.qmd`,
      `software_design_doc.qmd`, `meeting_notes.qmd`) actually live since the
      extdata reorg's Phase 1 (S415) -- S420 (2026-07-29). See `CHANGELOG.md`.)
- [ ] (none remaining -- the "`NEWS.md:8` spelling-check NOTE -- `CRAN's`/`resubmission`
      missing from `inst/WORDLIST`" item (discovered S415, 2026-07-28) is RESOLVED:
      both words hand-added to `inst/WORDLIST` in their case-insensitive-collation
      position (not via `spelling::update_wordlist()`, per S230 convention) -- S421
      (2026-07-29). Verified: `devtools::check()` raw log `Status: OK`, 0 notes.
      See `CHANGELOG.md`.)
- [ ] (none remaining -- the "`test-e2e-data-ready.R`'s 'appUI includes
      data-ready.js' test doesn't actually verify content inclusion" item
      (discovered S438, 2026-07-30) is RESOLVED: fixed S439 (2026-07-30).
      Replaced the hollow `inherits(app_ui, "shiny.tag.list") ||
      inherits(app_ui, "shiny.tag")` assertion with
      `htmltools::renderTags(app_ui)$head` content checks (a distinguishing
      marker `"setDataReady"` plus a full-file-text match), matching the
      pattern from `test_modSummaryStats_popovers.R` (S438). RED proven by
      temporarily disabling `R/appUI.R`'s `includeScript(dataReadyJS)` line
      (`if (FALSE && file.exists(dataReadyJS)) ...`), confirming the new test
      fails for the expected reason (both `grepl()` assertions FALSE), then
      reverting -- `git diff --stat R/appUI.R` confirmed byte-identical to
      HEAD after revert, so no production code changed this session. GREEN:
      regression suite 0 failed/0 error/0 warning (4006 passed, 170 skipped);
      `devtools::check()` 0 errors/0 warnings/0 notes. REFACTOR: owner
      -confirmed skip (single `test_that()` block, already matches the
      established pattern verbatim). Phase 3E: n/a -- test-only change, no
      runtime behavior affected. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md`
      Learning 417.)
- [ ] (none remaining -- the "`CLAUDE.md`'s 'Fast single-file test' command
      silently skips the entire file for any test file that calls
      `skip_on_cran()` at top level" item (discovered S439, `PROJECT_LEARNINGS.md`
      Learning 417) is RESOLVED -- S451 (2026-08-02): `Sys.setenv(NOT_CRAN =
      "true")` prepended to the documented one-liner in `CLAUDE.md`'s "Build /
      Test / Verify" section, with a parenthetical explaining why and citing
      Learning 417. Verified by reproducing the bug first (the OLD command
      against `test-e2e-data-ready.R` reports a bare `S`/"On CRAN") then
      confirming the NEW command runs all 34 expectations for real. See
      `CHANGELOG.md`.)
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
- [ ] **`vignettes/articles/colony-manager-guide.qmd`'s Diagram-tab screenshot
      (`pb_diagram_legend.png`) is now visually stale** (found S461, Effort S)
      -- its surrounding prose still says "one node per animal... directed
      sire/dam edges," and the embedded PNG shows the pre-Option-2 render, but
      the Diagram tab now renders the kinship2-style mating-unit/duplicate-node
      convention (S461). The "1,500 animals" number in this same paragraph was
      already fixed to 750 this session (a text-only change independent of the
      screenshot). Deferred rather than fixed this session (re-capturing a live
      screenshot -- upload the fixture, navigate tabs, screenshot, re-render the
      `.qmd` -- was judged disproportionate to a same-session text fix; the
      `vignettes/manual_components/_pedigree_browser.Rmd` component, which has
      no screenshot, WAS fully updated this session, satisfying the tutorial/
      article checklist's own "and/or" allowance). A future session should
      re-capture `pb_diagram_legend.png` (and update the surrounding prose to
      describe mate-lines/duplicate nodes) against the live app.
- [ ] **iCloud "conflicted copy" duplicate `.R` files corrupt
      `devtools::document()`/`R CMD check` output** (found S461, Effort S,
      not a code defect) -- `R/appServer 2.R` and `R/modMarkerGenetics 2.R`
      (carried forward many sessions as passive noise) are SOURCED by
      `pkgload::load_all()`/`devtools::document()` like any other `.R` file,
      silently merging their own stale roxygen comments into the SAME
      generated `.Rd` page as the current source -- confirmed twice this
      session (`man/appServer.Rd`, `man/modMarkerGeneticsServer.Rd`,
      `man/modMarkerGeneticsUI.Rd`, each reverted via `git checkout --`
      immediately). See `PROJECT_LEARNINGS.md` Learning 454. The owner is
      relocating this repository outside iCloud's purview specifically
      because of this and other iCloud-latency issues (same session,
      out-of-band) -- once moved, this item should self-resolve; a future
      session should confirm the 2 duplicate files no longer reappear and,
      if so, close this item without further action.
      **Recurred again S462 (2026-08-03):** the owner rebuilt the package
      locally (outside this session's own tool calls) while reviewing a
      screenshot, which re-corrupted the same 3 `.Rd` files the same way;
      reverted again via `git checkout --`. As of this session's Orient, the
      planned repository relocation had NOT yet happened (`pwd` still
      resolves to the original iCloud-synced path) -- this item cannot be
      closed until the move actually completes.
- [x] **Accumulated `lintr::lint_package()` warnings, 45 total across 17
      files** (found S462, Effort M) -- **part (a) DONE -- S466
      (2026-08-03):** swept clean, satisfying the owner-directed sequencing
      gate on issue #142 (2026-08-03: "must be completed before the pedigree
      drawing feature is considered complete and pushed"). All 41 warnings
      across the 16 TRACKED files fixed in 4 checkpoint commits (<=4 files
      each), REFACTOR-only per `PROJECT_LEARNINGS.md`'s `[refactor-only]`
      reflex (no RED/GREEN -- style-only, no new behavior). The other 4
      warnings (of the original 45) were on the untracked iCloud-duplicate
      `R/modMarkerGenetics 2.R` -- correctly out of scope (not part of the
      shipped package; belongs to the iCloud-relocation item above, still
      open). **Two lintr-heuristic false positives found and corrected in
      the original count, not just fixed:** (1) the `nonportable_path_linter`
      hits were NOT from the iCloud duplicate files (the S462 note above was
      wrong on the mechanism) -- both were in the real, tracked
      `R/makePedigreeDiagramData.R`, and on inspection were themselves also
      false positives: the flagged string is a plain fallback LABEL
      (`"Other / Unrecorded"`) that merely contains `/`, not a path at all.
      (2) 4 `commented_code_linter` hits (`R/reportGV.R:195`,
      `R/makePedigreeDiagramData.R:42`, `R/modGeneticValue.R:194,328`) were
      live design-rationale comments (issues #125/#127/#132) that embed a
      real R expression in prose, not dead code -- deleting them would have
      destroyed real documentation. All 6 false positives were suppressed
      via documented `# nolint` blocks (not deleted, not "fixed" with a
      semantically-wrong function like `file.path()` on a non-path string).
      One line -- `R/markerKinship.R:17`, the published KING-robust
      estimator's `\deqn{}` LaTeX formula (Manichaikul et al. 2010) -- was
      deliberately left over 80 chars rather than risk corrupting a
      citation-critical formula for a stylistic gain; suppressed via a new
      `.lintr` per-line exclusion (the project's own established mechanism)
      instead. Full regression suite + `devtools::check()` + a live
      `shinytest2` smoke test (4 touched-module tabs: Genetic Value
      Analysis, Marker Genetics, Breeding Groups, Pedigree Browser; 0
      `shiny-output-error` DOM elements, 0 SEVERE console entries) all
      confirmed exact baseline match, 0 new warnings/notes. See
      `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 461. **Part (b) (a
      process fix so lint debt stops re-accumulating -- CI gate and/or a
      Phase 3F close-out check) is NOT done and remains open** -- filed
      below as its own item, since it's analytically separate from the
      sweep and wasn't in this session's scope.
- [x] **Wire a process fix so `lintr` debt stops re-accumulating** (split
      from the item above at its own S462 "(b)" ask; READY, Effort S-M) --
      **DONE -- S477 (2026-08-04):** pre-work investigation found this
      item's own framing was stale, matching the S476 renv.lock precedent
      of a backlog item's speculative framing turning out incomplete on
      direct inspection: `.github/workflows/lint.yaml` already exists and
      already runs `lintr::lint_package()` on every push to `master` (and
      on PRs) with `LINTR_ERROR_ON_LINT: true` -- there was no CI job to
      "add." The real gaps were (1) `master` carries no branch protection,
      so a failing run blocks nothing and is trivially easy to never look
      at, and (2) it WAS currently red -- 2 real violations
      (`commented_code_linter`, `line_length_linter`) introduced in
      `R/makePedigreeDiagramData.R` by S472's issue #143 fix, still unfixed
      through S473-S476 (`gh run list --workflow=lint.yaml` showed
      consecutive `failure` runs with nobody noticing or fixing them --
      confirmed via `gh run view` annotations, not assumed). Surfaced this
      corrected picture via `AskUserQuestion`; owner picked "fix the current
      red + add a close-out check" over the narrower "just fix current red"
      or the broader "also add branch protection" (flagged as likely
      disproportionate given this project commits directly to `master` with
      no PR gate). Fixed both violations (REFACTOR-only, no RED/GREEN --
      style-only, no behavior change, matching the S238/S466 precedent): the
      comment-block false positive suppressed via a documented `# nolint
      start/end: commented_code_linter.` block (established project
      convention, not deleted/reworded -- S466 precedent for live
      design-rationale comments); the over-length line wrapped onto two
      lines matching this file's own existing `<-`-then-indented-RHS house
      style (confirmed via grep across `R/*.R`, not invented). Verified:
      `lintr::lint_package()` (package loaded, matching CI's exact
      invocation) 0 lints package-wide (was 2); full regression suite 0
      failed/0 error (4573 passed, 171 skipped, 10 pre-existing baseline
      warnings, unchanged from S476); `devtools::check()` unchanged from
      baseline. Added a new "Lint close-out checklist" to `CLAUDE.md`'s
      Additional close-out checks requiring sessions to lint touched files
      (package loaded) before closing out, rather than relying on the
      post-push CI run to catch it -- this is the actual recurrence-prevention
      mechanism, since the CI job's own existence did not prevent 4
      sessions from committing on top of a red run. See `CHANGELOG.md`,
      `PROJECT_LEARNINGS.md` Learning 477.
- [x] **Scheduled `shinytest2` E2E CI run failed -- 2 stale-assertion test
      failures in `test-e2e-pedigree-module.R`** (found S462, Effort S,
      root cause fully diagnosed) -- **DONE -- S467 (2026-08-03):**
      `test-e2e-pedigree-module.R:203-208`'s "known trio" assertions rewritten
      to match the live, already-shipped `__union_<n>` mating-unit routing
      instead of the stale pre-Option-2 direct sire/dam edge. PRE-RED live
      verification against the real app (a standalone driver script, not the
      test file itself) confirmed the exact live structure before writing the
      fix: the edge into child `EBG407` comes from `__union_29`, and that
      union node's own incoming edges come from `PH0IXL` and `U5VLXP` (plain
      real ids, not duplicate-occurrence ids, for this specific trio). The
      union node's numeric suffix is a volatile sequential index, so the new
      assertion captures it via `"from":"__union_[0-9]+"` pattern match
      rather than hardcoding `__union_29`, then separately asserts the sire/
      dam edges into the captured union id. REFACTOR-only per
      `PROJECT_LEARNINGS.md`'s `[refactor-only]` reflex (a green-on-arrival
      test correction -- no production code changed). Verified: the file
      itself (29/29 assertions pass), full regression suite (0 failed/0
      error, 10 pre-existing warnings, exact baseline), `devtools::check()`
      (1 WARNING/2 NOTEs, exact pre-existing baseline, 0 new), `lintr` on the
      changed file (0 lints). See `CHANGELOG.md`, `PROJECT_LEARNINGS.md`
      Learning 462.
      [run 30796362515](https://github.com/rmsharp/nprcgenekeepr/actions/runs/30796362515)
      (2026-08-03, triggered by the repo's scheduled/nightly workflow, not a
      push) failed 2 of 251 E2E assertions (249 passed):
      `test-e2e-pedigree-module.R:205` and `:207`
      ("E2E: Pedigree Browser Diagram tab shows a known trio's data"). Root
      cause: this permanent, already-committed test asserts the
      **pre-Option-2** edge convention -- a direct sire/dam -> child edge
      (`expect_match(edgesToChild, '"from":"U5VLXP"'` / `'"from":"PH0IXL"'`)
      -- but Session 461's Option 2 Slice 3 (`makePedigreeMatingLayout()`,
      shipped 2026-08-02, the session immediately before this one) changed
      the Diagram tab to route every parent -> child edge through an
      intermediate mating-unit node instead (confirmed in the failure output:
      the live edge is `{"from":"__union_29","to":"EBG407", ...}`, not
      `{"from":"U5VLXP", ...}`). The sire/dam node-shape assertions in the
      same test (checked just above the failing lines) still pass -- only the
      edge-routing assertion is stale. **Why this wasn't caught before
      shipping:** this specific "shinytest2 E2E tier" only runs on this
      repo's scheduled GitHub Actions workflow (`Run shinytest2 E2E tier in
      per-module fresh processes (opt-in)`), not in the fast local regression
      suite or `devtools::check()`; Session 461's own Phase 3E verification
      was ad hoc (`shinytest2`/`chromote` driven manually against a live
      fixture), not a run of this specific permanently-committed test file,
      so the stale assertion was never exercised until the next scheduled CI
      run. **Fix (not done here, diagnosis only):** update
      `test-e2e-pedigree-module.R:205-207` to assert the new two-hop
      relationship instead -- the child's incoming edge comes from a
      `__union_*` node, and that union node's own incoming edges include the
      sire and dam (or their duplicate-occurrence ids, per
      `makePedigreeMatingLayout()`'s own contract, see
      `R/makePedigreeDiagramData.R`). This is the same gap Session 461's own
      self-assessment flagged as a weakness (no new permanent E2E coverage
      added for the Slice 3 render-chain change) -- this is that gap
      surfacing as a real, scheduled-CI-caught regression, not a
      hypothetical.
- [ ] **`devtools::check()`'s spelling NOTE has drifted again -- 6 new words,
      not caught by any session since S461** (found S465, Effort S,
      incidental -- confirmed pre-existing, not caused by this session's own
      diff via a stash test) -- `man/makePedigreeMatingLayout.Rd:40`
      ("sibship", "waypoint") and `vignettes/a2interactive.Rmd:355,371,429,
      437,440,441` ("duplicateToReal", "js's", "makePedigreeMatingLayout",
      "vis") are flagged in `devtools::check()`'s `spelling.R` test diff
      (comparing fresh `spelling.Rout` against the committed
      `spelling.Rout.save`) but are not yet in `inst/WORDLIST`. Mirrors the
      S443/S448/S452 spelling-gap pattern (Learning 426, `CLAUDE.md`'s own
      "Additional close-out checks" precedent) -- a future session should
      hand-add these 6 words to `inst/WORDLIST` in `LC_ALL=C` byte-order
      position (not via `spelling::update_wordlist()`, per S230 convention)
      and re-verify `devtools::check()` drops to the pre-existing iCloud
      duplicate-file warning + vignette-engine note only.
- [x] **`renv.lock` -- concrete content found for the long-standing
      "unexplained diff" (found S474, Effort S-M, incidental) -- the
      committed `renv.lock` (both HEAD and the pre-existing uncommitted
      135+/19- diff carried since ~S459) has never recorded top-level
      `Packages` entries for `testthat`/`pkgload`/`devtools`/`roxygen2`/
      `shinytest2`/`chromote`/`dplyr`/`mockery`/`quarto`/`shinyBS`, even
      though the full test suite needs all of them. This session hit it
      directly: R was upgraded to 4.6.1 mid-project, which created a fresh,
      empty `renv` project-library hash
      (`nprcgenekeepr-e7e04aee`) -- `renv::restore()` alone left the
      library missing every one of those packages (confirmed present in
      the shared renv CACHE the whole time, just never linked into a
      project library because they were never in the lockfile to restore
      from), causing `pkgload::load_all()` and 18 test files across the
      full suite to error with "there is no package called '...'". Fixed
      in-session via `renv::install(c(...))` (all linked from cache,
      seconds each; confirmed `renv.lock`/`DESCRIPTION` diff unchanged
      before and after, matching Learning 299(b)'s discipline) -- this is
      a session-environment gap, not a lockfile fix, and will recur for
      the next session/machine whose project library gets reset (a new R
      version, a fresh clone, `renv`'s own cache eviction) until the
      lockfile itself is corrected. **Not fixed here** (root-causing why
      these packages were never captured -- likely a `renv::snapshot()`
      run with a dependency-detection type that excludes dev-only/Suggests
      tooling -- and deciding whether to run `renv::snapshot(type = "all")`
      or hand-add them is a decision for a dedicated session, out of scope
      for a TDD implementation session). A future session should
      root-cause and fix the lockfile itself so this stops being a
      recurring, silent per-session trap.
      **RESOLVED -- S476 (2026-08-04):** root cause precisely traced (not
      just "likely," per Learning 476): `renv/settings.json`'s
      `snapshot.type: "explicit"` makes a PLAIN `renv::snapshot()` scan
      only `Imports`/`Depends`/`LinkingTo`, silently excluding every
      `Suggests`-only package. `renv::snapshot(dev = TRUE)` (documented
      renv argument) fixes 8 of the 10 automatically (the 6 already
      declared in `Suggests` -- `testthat`/`dplyr`/`mockery`/`roxygen2`/
      `shinytest2`/`shinyBS` -- plus their transitive deps `pkgload`/
      `chromote` via `shinytest2`); `devtools`/`quarto` needed adding to
      `DESCRIPTION`'s `Suggests` directly (their existing
      `Config/renv/profiles/dev/dependencies` / `Config/Needs/website`
      declarations are inert -- read only by an actively-enabled "dev"
      renv profile / by `pak`, neither ever used in this project),
      matching the existing precedent of `covr`/`pkgdown`/`spelling`
      already living in `Suggests` unreferenced by package code. Also
      installed 6 separately-discovered NOT-INSTALLED `Suggests` packages
      (`covr`/`kableExtra`/`markdown`/`png`/`shinyWidgets`/`spelling`,
      surfaced only because `dev=TRUE`'s dry run refused to snapshot
      packages it couldn't find). Ran the real `renv::snapshot(dev =
      TRUE)` -- 157 packages now recorded (up from 95), all 10 originally-
      flagged packages present. Verified two ways: `renv::status(dev =
      TRUE)` reports "No issues found"; a genuinely fresh
      `renv::restore(library = <empty temp dir>)` installed all 16 target
      packages from the fixed lockfile alone. Full regression suite
      unchanged (0 failed/0 error, 3854 passed, 183 skipped, 10
      pre-existing baseline warnings); `devtools::check()` 0 errors/0
      warnings/2 NOTEs (both pre-existing and unrelated -- the
      already-tracked 6-word spelling-wordlist drift below, plus a
      vignette-engine NOTE on `a2interactive.Rmd`, confirmed via
      `git diff --stat` that vignettes/ was untouched this session).
      Documented `renv::snapshot(dev = TRUE)` as the required standing
      invocation in `CLAUDE.md`'s Build/Test/Verify section so a future
      plain `renv::snapshot()` doesn't silently strip the lockfile again.
      See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 476.

## Pedigree diagram vs kinship2 audit follow-ups (from ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md)
*S435's capability-comparison audit (`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`)
compared the just-shipped issue #129 pedigree-diagram feature against kinship2's pedigree-drawing
feature set (17-point checklist, 8 findings, 8 recommendations). Triaged S436 (2026-07-30) via
explicit owner direction (free-text, not per-item `AskUserQuestion` picks): **all 8 recommendations**
filed as GitHub issues, tracked there, not here -- including Recommendations 4-7, which the audit
itself scored "no action" (data-model-gated, or an already-ratified Dragon-P3 scope tradeoff);
filing tracks the idea for future consideration and does not reverse the audit's own assessment
(each issue body preserves the audit's original disposition text verbatim). Owner set an explicit
priority order that **inverts** the audit's own suggested ordering (which rated Finding #1 highest):
**#131** (diagram image/print export, Finding #3/Rec #2, priority 1) -- **#132** (in-app
shape-to-sex legend, Finding #6/Rec #3, priority 2, also resolves plan Dragon P5) -- **#133**
(affected/phenotype/genotype status encoding, Finding #2/Rec #4, priority 3, data-model gated) --
**#134** (verify inbreeding-loop/consanguinity rendering, Finding #1/Rec #1, priority 4, resolves
plan Dragon P2 / `PROJECT_LEARNINGS.md` Learning 410) -- **#135** (hover tooltips + search/highlight,
Rec #8, priority 5) -- **#136** (name labels instead of ID-only, Finding #8/Rec #7, priority 6,
data-model gated) -- **#137** (twin/zygosity encoding, Finding #5/Rec #5, priority unranked by the
owner, placed 7th as an inference not a stated decision) -- **#138** (full-colony rendering beyond
the 1,500-node cap, Finding #7/Rec #6, priority 8 -- explicitly deprioritized/delayed by the owner,
`low priority` GitHub label applied). Owner also directed (mid-session, 2026-07-30) a broader goal:
overlay kinship2's genetics-domain naming conventions onto the pedigree data model where applicable
when these are implemented, and build test pedigree fixtures with the corresponding added columns --
folded into #133 (kinship2's `affected` argument convention) and #137 (kinship2's `relation`
argument convention), the two data-model-adding items. Owner also directed that any plan
implementing one of #131-#138 must include a documentation phase (`vignettes/articles/
colony-manager-guide.qmd` and/or `vignettes/manual_components/_pedigree_browser.Rmd`), now recorded
as `CLAUDE.md`'s "Tutorial/article documentation checklist" -- checking whether this was already
true for the base feature found it was not: **issue #139** tracks that issue #129's already-shipped
Diagram tab has zero tutorial/article coverage today. See `PROJECT_LEARNINGS.md` Learning 411 and
`CHANGELOG.md` for the full S436 triage record. None imply reopening issue #129 or revisiting the
visNetwork-vs-kinship2 technology decision (D2), which stands as ratified.*
- [ ] (none remaining -- **issue #131** (diagram image/print export, priority 1) is
      RESOLVED: fixed S440 (2026-07-30). Added `visNetwork::visExport(type = "png",
      name = "pedigree_diagram", label = "Export Diagram (PNG)")` to the existing pipe
      chain in `R/modPedigree.R`'s `renderVisNetwork()` block -- zero new package
      dependencies (`visExport()`'s JS libs -- FileSaver/Blob/canvas-toBlob/
      html2canvas/jsPDF -- ship bundled inside `visNetwork` itself as htmlwidget
      deps, confirmed offline/no-CDN hands-on; see `PROJECT_LEARNINGS.md` Learning
      418). PNG chosen over PDF/JPEG via owner `AskUserQuestion` (`visExport()`
      supports exactly one format per widget, confirmed from its R source -- not
      additive). New unit test in `tests/testthat/test_modPedigree.R` asserts the
      widget's JSON payload carries the export config. Documentation phase per
      `CLAUDE.md`'s Tutorial/article documentation checklist: added a "Data Table
      and Diagram" section to `vignettes/manual_components/_pedigree_browser.Rmd`
      describing the Diagram tab and its new export button (scoped to this
      session's feature only -- full Diagram-tab tutorial coverage remains issue
      #139's separate scope). Verified: regression suite 0/0/0 (3290 passed, 182
      skipped); `devtools::check()` 0 errors/0 warnings/0 notes; live
      `shinytest2`/`chromote` runtime smoke test confirmed the button is genuinely
      functional, not just error-free -- clicking it produced a real
      `pedigree_diagram.png` file (17,374 bytes) with a valid PNG magic-number
      signature, captured via the chromote session's own download-behavior
      override (`PROJECT_LEARNINGS.md` Learning 419, since `get_download()`/
      `expect_download()` don't apply to a purely client-side JS download with no
      backing Shiny output). See `CHANGELOG.md`.)
- [ ] (none remaining -- **issue #134** (verify inbreeding-loop/consanguinity
      rendering, priority 4, resolves plan Dragon P2 / `PROJECT_LEARNINGS.md`
      Learning 410) is RESOLVED: verified S453 (2026-08-02), audit-only, no
      production code or tracked test-suite files changed. Data layer: a
      synthetic 6-node half-sib-mating fixture confirmed `makePedigreeDiagramData()`
      builds correct nodes/edges (no duplication, no drops) for a converging-DAG
      loop, and `findGeneration()` correctly places it (not a cycle). Live layer:
      found a real consanguineous-mating case already in the project's own bundled
      E2E fixture (`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv` --
      `GA204Z`, F=0.25, sire `8LKBV9` is also his maternal grandfather) rather than
      inventing a second synthetic one; drove the shipped app end-to-end via
      `shinytest2`/`chromote` (same `AppDriver` helpers `test-e2e-pedigree-module.R`
      already uses) and queried the live `vis.js` `Network` instance's own
      `DataSet`s directly -- confirmed no duplicate node, both loop edges present,
      no dropped edge, zero console errors at any level, and (via the app's own
      focal-animal+trim feature) a visually legible diamond-shaped render.
      Conclusion: vis.js's hierarchical layout handles a real inbreeding loop
      correctly per the plan's own P2 pass criteria. Closed via GitHub comment
      (`https://github.com/rmsharp/nprcgenekeepr/issues/134#issuecomment-5155638782`).
      See `CHANGELOG.md`.)
- [ ] (none remaining -- **issue #135** (hover tooltips + search/highlight,
      priority 5, resolves audit Recommendation #8) is RESOLVED: implemented
      and live-verified S454 (2026-08-02). `makePedigreeDiagramData()`'s
      nodes gain an HTML `title` field (ID/sex-spelled-out/generation/sire/
      dam, HTML-escaped) for vis.js's native hover tooltip; the Diagram
      widget gained `visOptions(nodesIdSelection = TRUE, highlightNearest =
      list(enabled = TRUE, hover = TRUE, ...))` -- a "Select by id" search
      dropdown, highlighting on hover (not click, to avoid overlapping the
      existing click-to-navigate handler, issue #129 Slice 2). TDD RED->GREEN
      (REFACTOR skipped, owner-confirmed -- GREEN already matched the file's
      established style): 10 new unit tests (8 on `makePedigreeDiagramData()`,
      2 on the widget's JSON config, matching the #131/#132 pattern);
      regression suite 0 failed/0 error (3509 passed, unchanged 10 baseline
      warnings); `devtools::check()` 0 errors/1 warning (pre-existing iCloud
      duplicate-file artifact)/0 notes. Live `shinytest2`/`chromote`
      verification against the real app (same known trio as
      `test-e2e-pedigree-module.R`): live node `title` matches exactly; the
      real DOM search dropdown is populated with all 375 IDs; a real
      `change` event genuinely dims an unrelated node while leaving a
      connected one normal (confirmed the highlight logic executes, not
      just that config is present); click-to-navigate unaffected. One
      accepted trade-off documented in code and `PROJECT_LEARNINGS.md`
      Learning 443: `nodesIdSelection` can log one transient, benign
      `[shiny] Duplicate input IDs were found` console warning from the
      second reactive re-render onward (no permanent DOM duplication,
      no functional impact) -- a structural fix was judged disproportionate
      to this "optional, low-priority... UI polish" issue and would risk
      the 3 already-shipped Diagram-tab features; owner-directed
      (`AskUserQuestion`) to accept and document rather than fix.
      `NEWS.Rmd`/`NEWS.md` and `vignettes/manual_components/
      _pedigree_browser.Rmd` updated per the tutorial/article and NEWS.Rmd
      documentation checklists. Closed via GitHub comment
      (`https://github.com/rmsharp/nprcgenekeepr/issues/135#issuecomment-5156062877`).
      See `CHANGELOG.md`.)
- [ ] (none remaining -- **issue #139** (document the pedigree-diagram Diagram
      tab in the manual/tutorial, discovered S436 while triaging the #131-#138
      follow-ups) is RESOLVED: documented S455 (2026-08-02). Closed the depth
      gap left by #131/#132/#135 each scoping their own doc update to one file
      only -- added the shape-to-sex legend description to
      `vignettes/manual_components/_pedigree_browser.Rmd` (previously missing
      there, #132's own feature) and extended `vignettes/articles/
      colony-manager-guide.qmd`'s "Diagram view" paragraph to cover
      click-to-navigate, the 1,500-node cap, the Export Diagram (PNG) button,
      the hover tooltip, and the Select by id search/highlight dropdown
      (previously missing there). Owner picked prose-only depth
      (`AskUserQuestion`) over adding new screenshots. Documentation-only --
      no `R/` or `tests/` files changed, so the TDD RED/GREEN/REFACTOR gates
      did not apply (S448/S451/S452/S453 precedent). Verified: `a3manual.Rmd`
      (parent of `_pedigree_browser.Rmd`) rendered via `rmarkdown::render()`
      with the new text present; `colony-manager-guide.qmd` rendered via
      `quarto render` with zero errors and the new text present;
      `tests/spelling.R` clean (no new flagged words); regression suite
      unchanged at 0 failed/0 error (3509 passed, same 10 pre-existing
      `test_modMarkerGenetics.R` baseline warnings). Closed via GitHub comment
      (`https://github.com/rmsharp/nprcgenekeepr/issues/139#issuecomment-5159297837`).
      See `CHANGELOG.md`.)
- [ ] (feasibility planning DONE -- S457, 2026-08-02, see
      `docs/planning/pedigree-diagram-mating-lines-plan.md` and `CHANGELOG.md`.
      **Pedigree Diagram tab does not visually indicate mating/couple
      relationships** (originally discovered S456 2026-08-02 while reviewing
      the Diagram section added to `vignettes/a2interactive.Rmd`) --
      owner-observed, citing two kinship2 references
      (`https://epilepsygenetics.blog/2014/04/03/straight-lines-the-art-of-drawing-pedigrees-using-kinship2/`,
      `https://rpubs.com/dliupress/pedigreedemo`). S457 answered the
      feasibility question empirically: built and screenshotted 3 `visNetwork`
      POCs via `chromote`, confirming a true kinship2-style mate-line +
      sibship-bar convention **is** achievable inside the ratified visNetwork
      (D2) choice via invisible union/waypoint nodes with hand-computed
      coordinates (`visHierarchicalLayout()` must be abandoned in favor of
      fixed positions -- confirmed from the bundled vis.js source that
      hierarchical layout cannot pin a node's free-axis position, and that no
      orthogonal edge-routing primitive exists at all). Read the D2 ratified
      plan's own text and found it had already explicitly named and accepted
      this exact tradeoff at ratification time. Corrected the prior citation
      of "Finding #8" -- the audit's "Multiple mates/spouses" item is
      checklist table row 8, not prose Finding #8 (a different, unrelated
      node-labels finding); the table row's own "Equivalent-different
      -approach" disposition was about childless/remarriage unions
      specifically, not this broader question. Owner ratified **Option 2 --
      full kinship2-parity layout on visNetwork** (over: reopen D2/switch to
      kinship2 -- not recommended, would regress 4 shipped interactive
      features and lose dynamic per-node metadata exposure kinship2 has no
      analog for; a smaller partial `visNetworkProxy`-repositioned
      mate-line-only step; or decline) via `AskUserQuestion`.)
- [ ] (design DONE -- S458, 2026-08-02, see
      `docs/planning/pedigree-diagram-option2-layout-design-plan.md` and
      `CHANGELOG.md`. **Pedigree Diagram: full kinship2-parity layout (Option
      2 design session)** -- designed and owner-ratified (a) a
      mating-unit/individual-duplication transformation (CraneFoot-derived)
      that resolves crossing-minimization ordering, (b) multi-mate/half-sib
      fan-out representation, and (c) inbreeding-loop safety **via one single
      mechanism** -- a real fixture (`inst/extdata/examples/
      obfuscated_rhesus_mhc_ped.csv`) confirmed this session to exercise both
      (b) and (c) simultaneously through the same individual (`8LKBV9`, issue
      #134's own loop fixture, independently confirmed to also be a 3-mate
      individual). A tree-native positioning algorithm (simplified
      Reingold-Tilford/Walker contour-merge, not kinship2's undocumented
      internals, not a full Buchheim-Jünger-Leipert implementation, not an
      off-the-shelf R package -- `igraph`/`data.tree` are GPL and `ggraph`
      transitively depends on GPL `igraph`, confirmed this session) computes
      final coordinates for the transformed forest. Owner ratified via
      `AskUserQuestion` with one editorial direction: non-human-centric
      terminology throughout (`sire`/`dam`/`mate`/`mating`, not
      `husband`/`wife`/`marriage`/`spouse`).)
- [ ] (none remaining -- **Pedigree Diagram: Option 2 implementation, Slice 1
      (mating-unit transformation)** is RESOLVED: implemented S459
      (2026-08-02). New internal `.buildMatingUnitForest()` in
      `R/makePedigreeDiagramData.R` (D1 mating-unit identification +
      re-parenting + duplicate-node creation, D2 deterministic anchor
      selection, D5 partial-parentage fallback -- all three folded into this
      one function, since D5 governs whether a mating unit is even
      synthesized for a given child). Full TDD cycle (RED->GREEN, REFACTOR
      owner-confirmed skip -- GREEN already matched the file's established
      single-function style), all `AskUserQuestion`-gated. **Pre-RED found
      and corrected a real gap in the ratified design doc's own §7/§9
      figures** (a genuine algorithm-implementation finding, not an
      assumption): actually running D2's anchor rule against the real
      375-individual fixture found it collides twice (`KUENM8`, `IM1B5T`
      each anchor 2 mating units -- the exact "rare case" D3 step 2 already
      names), correcting §7's published 130-duplicate/742-total estimate to
      the verified 128/740 -- owner-directed via `AskUserQuestion` to fix the
      figures in place with an addendum, not leave the ratified doc stale.
      15 new unit tests (input validation + reserved-id-prefix collision;
      D5's 0-parent/1-parent fallbacks; a reconstructed real 8-node
      `GA204Z`/`8LKBV9` loop fixture, extracted directly from
      `inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv` since the
      original 6-node half-sib fixture cited in the design doc's §8 was
      never committed to the test suite -- S453 was audit-only; a
      reconstructed equivalent half-sib-mating convergent-loop fixture; the
      real anchor-collision case verified end-to-end against the full
      bundled fixture). Citation/tutorial/`NEWS.Rmd` checklists: N/A -- an
      internal (`@noRd`), not-yet-wired-in function has no displayed
      statistic and no user-facing surface (Migration Path step 4's own
      "owed once step 3 ships, not before"). Verified: regression suite
      0 failed/0 error (3562 passed = 3509 baseline + 53 new, 183 skipped,
      10 pre-existing warnings, exact baseline match); `devtools::check()`
      0 new warnings/notes (isolated via a clean-tree re-run: the pre-existing
      iCloud-duplicate-file warning and a `vignettes/a2interactive.Rmd`
      vignette-engine NOTE both confirmed to predate this session, unrelated
      to this diff). Phase 3E: n/a -- no runtime behavior changed (the
      function has no call site yet; the render-chain switch is Slice 3).
      See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learnings 449-450.)
- [ ] (none remaining -- **Pedigree Diagram: Option 2 implementation, Slice 2
      (D3 positioning algorithm)** is RESOLVED: implemented S460
      (2026-08-02). New internal `.positionMatingUnitForest(ped, forest)` in
      `R/makePedigreeDiagramData.R`, consuming Slice 1's
      `.buildMatingUnitForest()` output and assigning final `x`/`gen`
      coordinates via a simplified Reingold-Tilford/Walker-style recursive
      contour-merge (D3), founder ordering by input row order (D4), D5's
      one-known-parent fallback attaching directly (no synthesized union).
      **Resolved the deferred Slice 1 question:** `duplicates` does not need
      its own `gen` column -- the positioning function takes `ped` directly
      (already needed for real individuals' own `gen`) and looks up a
      duplicate's `gen` via its `realId`. Pre-RED prototyped the algorithm in
      a throwaway POC against 8 toy fixtures plus the full real
      375-individual fixture (matching S457's own Case-C2-POC precedent, per
      §9's dragon flag) and found 3 non-obvious gaps the ratified design
      didn't fully specify: (1) an individual whose one non-anchor mating
      -unit occurrence is "free" (no duplicate node, per
      `.buildMatingUnitForest()`'s own D2 rule) is not an independent forest
      root -- naively treating them as one creates a phantom disconnected
      node; fixed by folding them into their one unit's children-merge as a
      genuine width-reserving leaf. (2) contour occupancy must be indexed by
      each node's absolute real `gen`, not relative recursive depth --
      because D3 step 6 (ratified) pins y to real `gen`, which diverges from
      recursive depth once a duplicate/free-pass node is re-attached deep
      inside another individual's subtree (impossible in a genuine tree,
      possible here). (3) even gen-indexed contours leave a residual
      ancestor-vs-nested-descendant exact-coincidence edge case (measured at
      12/740 nodes, ~1.6%, on the real fixture); resolved with a small
      deterministic post-placement nudge pass, applied only to
      individual/union nodes (duplicates keep the design's own already
      -accepted "not guaranteed collision-free" trade-off). All 3 findings
      owner-approved via `AskUserQuestion` before RED. Full TDD cycle
      (RED->GREEN, REFACTOR owner-confirmed skip -- GREEN already matched
      the file's established pattern, e.g. `.buildMatingUnitForest()`'s own
      nested-closure precedent). 12 new unit tests (input validation; trio
      union-midpoint geometry; D5-mixed subtree; multi-mate uneven-depth;
      the real `GA204Z`/`8LKBV9` loop fixture; half-sib convergent loop; an
      isolated founder beside an unrelated family; an 8-mate wide fan-out;
      a deeply unbalanced 6-generation chain; the full real 375-individual
      fixture at its exact 740-node count; `gen`-column semantics).
      Citation/tutorial/`NEWS.Rmd` checklists: N/A -- an internal (`@noRd`),
      not-yet-wired-in function has no displayed statistic and no
      user-facing surface (Migration Path step 4's own "owed once step 3
      ships, not before"), matching Slice 1's own precedent. Verified:
      regression suite 0 failed/0 error (3592 passed = 3562 baseline + 30
      new, 183 skipped, 10 pre-existing warnings, exact baseline match);
      `devtools::check()` exact baseline match (1 pre-existing warning, 1
      pre-existing note, 0 new); zero lint warnings in the new code. Phase
      3E: n/a -- no runtime behavior changed (the function has no call site
      yet; the render-chain switch is Slice 3). Incidentally found and fixed
      (not part of this slice's own deliverable, a 1-byte mechanical
      correction in the file already being edited) a literal control
      -character byte that had leaked into `PROJECT_LEARNINGS.md` Learning
      450's own text -- the exact defect that learning describes, recursed
      into its own bug report. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md`
      Learnings 451-453.)
- [ ] (none remaining -- Pedigree Diagram: Option 2 implementation, Slice 3
      (render-chain wiring) is DONE -- S461 (2026-08-02): see `CHANGELOG.md`.
      New exported `makePedigreeMatingLayout()` combines Slices 1/2 into the
      `list(nodes, edges, duplicateToReal)` shape; `R/modPedigree.R`'s render
      chain switched from `makePedigreeDiagramData()` + `visHierarchicalLayout()`
      to the new function + `visPhysics(enabled = FALSE)`/`visNodes(physics =
      FALSE)`/`visEdges(smooth = FALSE)` with fixed x/y. D6 integration:
      click-to-navigate resolves duplicate-node clicks to the real individual
      and ignores union-node clicks; the search dropdown is filtered to real
      ids only (`visOptions(nodesIdSelection = list(values = ...))`); union
      nodes get a small unlabeled dot + offspring-count tooltip, no legend
      entry; mate-line/child edges render as direct (non-waypoint) edges,
      owner-directed, with the fuller rectilinear style filed as deferred
      issue #142. Issue #138's node cap re-derived 1,500 -> 750 individuals
      (owner-directed via `AskUserQuestion`), commented on issue #138.
      **Live Phase 3E verification (mandatory, not skippable for this slice)
      found and this session fixed a genuine crash**: `.buildMatingUnitForest()`
      (Slice 1's own file) threw "missing value where TRUE/FALSE needed" on
      any pedigree where a sire/dam value has no own row -- e.g. this page's
      own pre-existing "Trim pedigree based on focal animals" feature, which
      Slices 1/2 never exercised (both `@noRd`, tested only against
      self-contained fixtures). Root-cause fixed in Slice 1's file (a dangling
      reference is now treated as a founder and can never anchor; its gen
      falls back to its mating unit's own gen), not worked around in Slice 3;
      6 new unit tests; the exact live crash re-verified fixed via
      `shinytest2`/`chromote`. Also found (documented, not fixed, inherited
      from Slice 2): `.buildMatingUnitForest()`'s anchor tie-break is
      row-order-sensitive, and the live app's `qcStudbook()` step reorders
      rows relative to the raw upload -- the real fixture's own "740 total
      nodes" figure (Slices 1/2's unit tests, raw CSV) becomes 739 through the
      live pipeline; both are correct, self-consistent applications of the
      same algorithm to different (valid) row orders. See `CHANGELOG.md`,
      `PROJECT_LEARNINGS.md` Learning 457, design doc §9.)
- [x] **Duplicate-node connector renders straight, not arched, unlike the
      kinship2/standard-pedigree convention** (found S468 2026-08-03) --
      **RESOLVED -- S469 (2026-08-03):** owner observation comparing this
      app's diagram against a reference pedigree image
      (rpubs.com/dliupress/pedigreedemo, Pedigree 1): the referenced
      convention draws the dashed line connecting a duplicated individual's
      extra mating-position occurrence back to their primary occurrence as
      a visibly **arched/curved** line. `makePedigreeMatingLayout()`'s
      `dupEdges` now carry a per-edge vis.js `smooth` override
      (`smooth.enabled = TRUE`, `smooth.type = "curvedCW"`,
      `smooth.roundness = 0.2`, via 3 new dot-named columns), overriding
      `R/modPedigree.R`'s widget-level `visEdges(smooth = FALSE)`; every
      other edge leaves `smooth.enabled` `NA`, inheriting that global
      default unchanged. Pre-RED read the bundled `vis-network.min.js`/
      `visNetwork.js` source directly (not assumed) and confirmed a
      per-edge `smooth.*` dotted-column override is a genuine, already-used
      mechanism (same one backing edges' `color`/nodes' `color.background`)
      -- and found a real second-function integration risk before writing
      any test: `.addRectilinearWaypoints()`'s own fresh waypoint edges
      needed matching NA-filled `smooth.*` columns too, or its
      `newEdges[, names(keptEdges)]` rbind would throw "undefined columns
      selected" once the passed-through direct-style edges carried the new
      columns -- fixed in the same commit; `dupEdges` are never touched by
      that function's D1/D2 waypoint logic, so the arc survives unchanged
      under `edgeStyle = "rectilinear"` too (live-verified). Full TDD cycle
      (RED -- 3 tests, 2 new + the existing "no new columns beyond
      contract" test updated for the now-intentionally-changed edge column
      set; GREEN; REFACTOR owner-confirmed skip -- GREEN already matched
      this file's established `dashes`/`color` column-addition style).
      Verified: regression suite 0 failed/0 error (4524 passed = 4515 + 9
      new assertions, exact baseline 10 pre-existing warnings);
      `devtools::check()` 0 new errors/warnings/notes (1 warning/1 note,
      both the pre-existing unrelated iCloud-duplicate-file and
      vignette-engine baseline); `lintr` 0 on both changed files. Live
      `shinytest2`/`chromote` verification against the real 375-individual
      fixture: all 128 duplicate-connector edges carry the arc override (0
      diagram-related console errors); a small isolated-fixture screenshot
      visually confirms the connector renders curved, distinct from the
      straight mate-line/child edges; the `edgeStyle = "rectilinear"` radio
      toggle re-verified live with 0 errors, arc intact. `_pedigree_browser.Rmd`'s
      "dashed line" wording updated to "curved, dashed line" for accuracy
      (re-rendered, confirmed present in output); no `NEWS.Rmd` entry, per
      the shinyBS-popover-fix precedent (S437/438) -- a bug fix to existing
      behavior, not a new function/control, is outside that checklist's own
      scope. Analytically separate from issue #142's own mate-line/
      sibship-bar edge-routing work (Slice 2, shipped S468) -- not folded
      in, per this project's own scope-discipline precedent (see the
      founder-positioning-defect item immediately below, and
      `PROJECT_LEARNINGS.md` Learning 382). See `CHANGELOG.md`.
- [x] **Founder-positioning defect: a non-anchor parent occurrence (founder or
      already-duplicated multi-mate individual) whose own generation differs
      from their mating unit's generation renders at the wrong row, visually
      implying the wrong pairing** (DONE -- fix implemented S472, Effort M,
      found S463, characterized S470, designed S471) -- confirmed via
      `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`,
      prompted by an owner observation on that document's own Example 1
      rendering ("it appears 2 males have mated"). `.positionMatingUnitForest()`
      assigns EVERY non-anchor parent occurrence's row -- a free-pass real node
      OR a genuine D6 duplicate node -- from that parent's own global `gen`,
      never from the specific mating unit the occurrence belongs to
      (`R/makePedigreeDiagramData.R:585-591`). This is a defect in x/y
      coordinate ASSIGNMENT, not in edge-drawing style -- **independent of and
      would survive** a full issue #142 (rectilinear mate-line/sibship-bar)
      implementation (#142 Slices 1-2 are themselves now shipped/done).
      **S470 audit (`docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md`)
      confirmed this against real bundled fixtures, resolving the "how often in
      practice" question S463 left open:** on the real 375-individual rhesus
      fixture (`obfuscated_rhesus_mhc_ped.csv`), **147 of 237 mating units
      (62%) have at least one mis-positioned parent.** Independently re-derived
      via a blind Workflow agent (same counts, plus a general rule: mismatch
      iff parent's own `gen` != mating-unit `gen`, no exceptions). Real
      Japanese macaque colony data (`deidentified_jmac_ped.csv`, 2,791
      individuals) shows the same pattern on its (small, data-sparse)
      applicable subset. **Filed as [issue #143](https://github.com/rmsharp/nprcgenekeepr/issues/143)
      -- S470 (2026-08-03), owner-confirmed before filing.**
      **Fix designed -- S471 (2026-08-03):**
      `docs/planning/issue143-founder-positioning-fix-plan.md`, owner-ratified
      via `AskUserQuestion`. Adopts the audit's own "point-patch" candidate
      (two synchronized edits assigning every non-anchor occurrence's row from
      its own mating unit's `gen`), with a dangling-free-pass-parent guard the
      plan's own adversarial review found was needed (caught and fixed a real
      crash before ratification, reproduced against the existing `DANGLING_DAM`
      fixture). **Direct empirical verification during planning found the
      S470 audit's own real-fixture numbers under-reported the picture: of the
      147 mismatches, 51 (22% of all 237 units) are ANCHOR-side mismatches the
      audit's detection script could not distinguish from free-pass ones (both
      lack a `__dup_` prefix) -- this fix resolves 96 of 147 (65%), not all of
      it.** Owner reviewed this finding and directed shipping the non-anchor
      fix now, tracking the anchor-side gap as its own urgent follow-up (see
      the new item immediately below, [issue #144](https://github.com/rmsharp/nprcgenekeepr/issues/144)).
      **Implemented -- S472 (2026-08-04):** both synchronized edits shipped
      together in one commit (`R/makePedigreeDiagramData.R:494,585-600ish`),
      following the plan's own RED/GREEN/REFACTOR Verification Plan (§7)
      exactly -- pre-derived regression numbers confirmed to the exact
      integer (0 non-anchor + 51 anchor mismatches remaining;
      `edgeStyle="rectilinear"` real-fixture node count 1375 -> 1279). The
      plan's own §6 dragon-flagged minimum-separation test was investigated
      empirically before writing it and found NOT to discriminate a
      desynchronized fix in this algorithm (unrelated same-row nodes are not
      guaranteed >= minSep apart even under the correct fix); substituted a
      stronger, empirically-verified exact x/gen value test instead (see
      `PROJECT_LEARNINGS.md` Learning 470). Full regression suite 0 failed/0
      error (4560 passed); `devtools::check()` 0 errors/0 warnings (1
      pre-existing, unrelated NOTE); live-verified in the running app via
      `shinytest2` -- FD3BB6 (the audit's own spot-checked example) plus 3
      more previously-mismatched units now render on-row under both
      `edgeStyle` values, zero diagram-related console errors. See
      `CHANGELOG.md`.
- [x] **Pedigree Diagram: anchor-side row mismatches -- 51 of 237 real-fixture
      mating units (22%), distinct from issue #143's non-anchor fix** (found
      S471, incidental to designing #143's fix; filed as
      [issue #144](https://github.com/rmsharp/nprcgenekeepr/issues/144)) --
      **planning DONE -- S473 (2026-08-04):**
      `docs/planning/issue144-anchor-row-mismatch-fix-plan.md`, owner-ratified
      via `AskUserQuestion`. **The standing assumption above -- that fixing
      this "would require restructuring `.positionMatingUnitForest()`'s
      recursive positioning itself... materially larger than issue #143's
      point-patch" -- turned out to be FALSE**, disproven by this session's
      own empirical work (see `PROJECT_LEARNINGS.md` Learning 471): a node's
      own row-reservation is already fully decoupled from its `x`-computation
      and its recursion into children, so the anchor case can be corrected
      with the exact same narrow `dispGenOf`-override pattern #143 itself
      used, ~11 non-comment lines across 3 synchronized edits, entirely
      inside `.positionMatingUnitForest()` -- `.buildMatingUnitForest()`
      (anchor selection) stays untouched. Adopted via a 7-agent
      characterize-then-design workflow (4 parallel characterization agents,
      3 independently-validated candidate designs in isolated worktrees) plus
      a 3-agent adversarial review mirroring S471's own review pattern for
      the sibling #143 plan.
- [ ] (none remaining -- **Implement the ratified issue #144 plan** is
      DONE -- S474 (2026-08-04): all 3 synchronized edits shipped in one
      commit, full RED/GREEN/REFACTOR TDD cycle (`AskUserQuestion`-gated at
      every transition), full regression suite + `devtools::check()` +
      live `shinytest2` verification all clean. See `CHANGELOG.md`.)

**Sequencing note (S480, 2026-08-08):** the items below through the `highlightNearest` degree=6
item, plus GitHub issues #133/#136/#137/#138/#141/#145, were jointly examined for implementation
order in `docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md` (kinship2-capability-
and nomenclature-reference-informed). Recommended order: (1) the two dangling-parent crash bugs
below + the free-pass-filter reachability check, (2) issue #145 (sire/dam left-right placement --
found to be a net-new layout rule request, not a fix to existing behavior, and not textually
supported by this project's own copy of the cited nomenclature standard), (3) refresh the stale
`.qmd` comparison doc below, (4) the owner's existing #133 > #136 > #137 > #138 order (unchanged,
set at S436), (5) #141 and Candidate C stay deferred pending new evidence/owner sign-off. Consult
that audit before picking up any item in this cluster.

**Progress (S481, 2026-08-08):** Tier 1 step (1) is DONE -- the 2 dangling-parent crash bugs +
the free-pass-filter reachability check (issue #154) are fixed/closed, see `CHANGELOG.md`. Step
(2) -- issue #145's verification spike -- is next in this cluster; steps (3)-(5) remain untouched.

**Progress (S482, 2026-08-08):** Tier 1 step (2) is DONE -- see
`docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`. Empirically confirmed
(source read + 5 synthetic-pedigree tests against kinship2 v1.9.6.2 directly, not inferred from
docs alone) that kinship2 implements **neither** a hard male-left invariant **nor** a
sex-aware crossing-minimizing soft default: the single-mate case's apparent "sire-left" result is
an indexing artifact, not a `ped$sex` check, and the moment an individual has multiple mates
("crowding," exactly the scenario #145's own body raises), left/right is decided purely by
pedigree-data discovery order -- confirmed by a direct counter-example (a dam with 2 sire mates,
one sire ends up to her immediate right, the other to her immediate left). kinship2's own
`?align.pedigree` help text frames sire/dam ordering as an overridable hint, not a rule; an
explicit 2-row hint flips the simple-pair default with no special-casing. Also found issue #145's
own inline citations ([2]-[7], already flagged unresolved by the S480 audit) describe
crossing-minimization behavior that does not match kinship2's actual source -- a second,
independent data point (beyond the S480-audited nomenclature reference) that those citations are
unreliable. Step (3) -- refresh the stale `.qmd` comparison doc -- is next in this cluster; steps
(4)-(5) remain untouched. See the research doc's own "Recommendation for a future #145 design
session" section before starting any #145 design work.

**Progress (S484, 2026-08-08):** Tier 1 step (3) is DONE -- see
`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`. Refreshed the doc's stale
founder-positioning "confirmed defect" language in Examples 1-2 (re-ran both example families
against current `master`: `203`/`117` now correctly position adjacent to their own mate's row,
matching kinship2's convention, verified via real layout output not just the "should be fixed"
claim) -- updated to reflect the fix, citing issues #143/#144. Re-verified `vignettes/
a2interactive.Rmd`'s runnable pedigree-diagram example still executes cleanly against current
`master` (33 animals, 48/53 direct-style nodes/edges, 86/91 rectilinear -- re-verification only, no
content rewrite needed). Added a new Example 4 (a dam with 2 sires, "role-reversed crowding")
reproducing S482's own decisive kinship2 counter-example directly in this document, with real
`align.pedigree()` output (`S1, D1, S2` -- dam centered, sires split by discovery order, not sex)
alongside `nprcgenekeepr`'s own duplicate-node handling of the same data; updated the Summary table
and closing "kinds of gap" list to add the sire/dam-ordering question (issue #145) as its own,
now-investigated item, and to close out the founder-positioning item as fixed. Verified via a full
`quarto render` (all 37 chunks executed cleanly, no R errors) -- rendered HTML deleted after
verification, not committed, matching this project's established practice for `docs/planning/*.qmd`
source-only docs. Tier 1 of the sequencing audit (crash bugs + #145 spike + this refresh) is now
fully complete; Tier 2 (#133 > #136 > #137 > #138, owner's existing order) is next in this cluster.
- [ ] **Candidate C's connector/dogleg visual-signposting idea** (found S473,
      designing the issue #144 plan; not adopted for #144 itself, Effort
      unknown, low priority) -- extends the existing D2 mate-line "dogleg"
      (issue #142) to `edgeStyle="direct"` (which currently gets zero
      compensating treatment for any cross-generation connector) and adds
      dashed/colored/titled styling to both edge styles so a
      multi-generation-spanning mate-line reads as intentional rather than a
      positioning bug. Fully validated (including a real ~37%
      `edgeStyle="rectilinear"` performance regression found and fixed during
      design) but requires its own fresh, explicit owner product-level
      sign-off to pursue -- independently valuable as a diagram-readability
      enhancement, decoupled from #144's own resolution (which does not need
      it). See `docs/planning/issue144-anchor-row-mismatch-fix-plan.md` §5/§8.
- [ ] (none remaining -- the 3 dangling-parent crash bugs formerly tracked
      here unnumbered (`.addRectilinearWaypoints()`'s D2 loop "subscript out
      of bounds"; `gen = NA` -> `maxGen` "invalid 'times' argument"; a
      both-parents-dangling mating unit's anchor-selection crash) are now
      filed as **issue #154** (2026-08-08, S481) -- see `CHANGELOG.md` for
      fix status.)
- [x] **`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`'s
      worked examples are stale from issue #143's row-value changes, and will
      become further stale once issue #144 ships too** (found S473 -- DONE
      S484, 2026-08-08, see the S484 progress note above) -- covered both
      #143's and #144's compounding effect on this document in one item
      rather than two, plus S482's kinship2-sire/dam-ordering findings and a
      new multi-mate-crowding worked example (folded in from the same
      sequencing cluster). `vignettes/a2interactive.Rmd`'s runnable example
      re-verified per #143's own plan (confirmed it still executes; not a
      content rewrite). See
      `docs/planning/issue144-anchor-row-mismatch-fix-plan.md` §8.
- [ ] (none remaining -- **the `.positionMatingUnitForest()` free-pass-filter
      reachability question is CLOSED, not fixed** -- S481 (2026-08-08):
      investigated with 2 targeted fixtures (a never-anchoring founder with a
      D5 direct child; a never-anchoring NON-founder with a D5 direct child,
      the specific "if not a root" case this item worried about) and neither
      reproduced a missing/duplicate node. Structurally, a real individual
      excluded from `freePassIds` is either a founder (exclusion just keeps
      them in `rootIds`, since `rootIds <- setdiff(founderIds, freePassIds)`)
      or a non-founder (always visited via their own real parent's normal
      recursion regardless of free-pass status) -- no path found where they
      are lost. See `CHANGELOG.md` and issue #154's own closing note.)
- [ ] **The live app's uploaded/QC'd copy of `obfuscated_rhesus_mhc_ped.csv`
      produces one fewer node than reading the same bundled CSV directly**
      (found S472, incidental to issue #143's live verification, Effort
      unknown, low priority) -- `direct`-style Diagram node count is 739 live
      vs. 740 via `read.csv()` + `.buildMatingUnitForest()`/
      `.positionMatingUnitForest()` directly (a stable, already-tested
      figure, unaffected by this session's fix); the live rectilinear
      -style projection-node count is correspondingly 50 vs. an offline
      -computed 51. Not investigated further this session (out of the
      issue #143 fix's own scope, per `PROJECT_LEARNINGS.md` Learning 382's
      "report, don't fix mid-session" precedent) -- most likely explained by
      the upload/QC pipeline (`modInput.R`'s `qcStudbook()` or similar)
      dropping or merging exactly one row relative to a raw `read.csv()`,
      but this was not confirmed. A future session should identify which
      individual differs and why, and decide whether the app's own bundled
      -fixture test coverage (`test-e2e-pedigree-module.R`, etc.) should
      assert this QC'd count explicitly rather than relying on the
      raw-CSV-read count as a proxy for what the live app actually renders.
- [ ] **`data-raw/rhesusPedigree.R`'s docstring claims
      `rhesusPedigree_fromCenter.csv` is an independent raw/pre-obfuscation
      source for `obfuscated_rhesus_mhc_ped.csv`, but the two shipped fixtures
      are byte-identical on every shared column** (found S470, incidental to
      the founder-positioning audit above, Effort S, low priority) -- confirmed
      via `identical()` on `id`/`sire`/`dam`/`sex`/`gen`/`birth`/`exit`/`age`
      between the two files; `rhesusPedigree_fromCenter.csv` differs only by
      one added `fromCenter` column (all `TRUE`). The documented `obfuscatePed()`
      id/date-obfuscation transform was evidently never applied to produce this
      particular fixture, or produced a no-op. Not fixed this session (reported
      per `PROJECT_LEARNINGS.md` Learning 382's "report, don't fix mid-session"
      precedent -- out of the founder-positioning audit's own scope). A future
      session should reconcile the docstring against the shipped fixture (or
      regenerate `rhesusPedigree_fromCenter.csv` to match the documented
      provenance). See `docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md`
      Finding #4, `PROJECT_LEARNINGS.md` Learning 468.
- [x] **Issue #142 implementation: rectilinear mate-line/sibship-bar waypoint style
      -- Slice 2 (edgeStyle wiring + UI + live re-verification)** (READY, Effort M --
      **gate satisfied S466 (2026-08-03): the owner-directed lint-cleanup
      sequencing gate (part (a) of the "Accumulated `lintr::lint_package()`
      warnings" item above) is now DONE; this item may proceed and be
      pushed once complete**) -- design ratified:
      `docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md`.
      **Slice 1 (the internal waypoint-construction helper) is DONE -- S465
      (2026-08-03):** Pre-RED live-verification (a minimal `visNetwork` widget
      matching `R/modPedigree.R`'s exact render chain, driven via `shinytest2`/
      `chromote`) found the design's own `hidden = TRUE` mechanism does not work --
      vis.js suppresses every edge connected to a hidden node regardless of the
      edge's own setting -- corrected in-place via a design-doc addendum (§11):
      waypoint nodes get `size = 0` + fully transparent color instead, and every
      new waypoint-touching edge gets an explicit, non-inherited color (vis.js
      edges otherwise default to inheriting color from their `from` node's
      border). New internal `.addRectilinearWaypoints(nodes, edges, forest, pos)`
      implements D1 (sibship-bar chain, generalizing to D5 single-parent groups)
      and D2 (per-side mate-line dogleg, correctly handling BOTH the common
      non-anchor-off-row case and the harder anchor-off-row/duplicate-non-anchor
      case -- does not assume the anchor is always on-row). `.buildMatingUnitForest()`'s
      reserved-prefix guard extended to `__drop_`/`__bar_`/`__proj_` (D3). Verified
      against the real 375-individual fixture: node count matches the design's own
      analytical estimate exactly (740 direct-style + 488 D1 + 147 D2 = **1,375**,
      confirming the design doc's §7 math, no drift). No call site yet -- this
      function is not wired to `makePedigreeMatingLayout()` or `R/modPedigree.R`.
      See `CHANGELOG.md`, `PROJECT_LEARNINGS.md`.
      **Slice 2 must, in order:** (a) `makePedigreeMatingLayout()` gains the
      `edgeStyle = c("direct", "rectilinear")` parameter (D4, default `"direct"`,
      byte-identical existing behavior) calling Slice 1's helper; (b) `R/modPedigree.R`
      gains the new style-toggle UI control (net-new layout inside the Diagram
      tab's own `uiOutput` -- no existing "home" for it) + extends the
      click-to-navigate and search-dropdown id-prefix filters to the 3 new reserved
      prefixes (D3); (c) re-run the node-count measurement against the actually-wired
      `edgeStyle = "rectilinear"` code path (Slice 1 already confirms the underlying
      math is right, but re-confirm post-wiring per §9's "hard gate, not
      nice-to-have") and bring the confirmed number to the owner via `AskUserQuestion`
      to ratify the rectilinear-mode-specific individual cap, replacing the
      direct-style-calibrated 750 (design's own math suggests ~380); (d) re-verify
      inbreeding-loop rendering (#134) and `highlightNearest` hover-highlighting
      (#135, a newly-found regression risk -- hidden waypoints becoming a real
      individual's nearest edge-graph neighbor) for the new style specifically, live
      via `shinytest2`/`chromote`, neither inherited from prior verification.
      Explicitly does NOT fix the separate founder-positioning defect above
      (analytically distinct: edge routing vs. coordinate assignment). Citation/
      tutorial/`NEWS.Rmd` checklists: owed once Slice 2 ships the new UI control,
      not before (matching Slice 1/2's own precedent in the Option 2 implementation).
      **Slice 2 DONE -- S468 (2026-08-03):** all four parts (a)-(d) shipped, in 3
      checkpoint commits. **(a)** `makePedigreeMatingLayout()` gained
      `edgeStyle = c("direct", "rectilinear")` (default `"direct"`,
      byte-identical existing behavior); `"rectilinear"` calls Slice 1's
      `.addRectilinearWaypoints()`. **(b)** `R/modPedigree.R` gained a
      `radioButtons()` style toggle (net-new layout inside the Diagram tab's
      own `uiOutput`, alongside the widget, only when a diagram is actually
      shown -- D4); click-to-navigate and the search-dropdown id-prefix
      filters extended to the 3 new reserved prefixes, keeping `__dup_`
      clickable (D3). **(c)** Node count re-confirmed through the actual
      public entry point (1,375 on the real 375-individual fixture, matching
      Slice 1's own already-tested number). The rectilinear-mode individual
      cap was ratified at **400** via `AskUserQuestion` -- re-deriving the
      design doc's own suggested ~380 found it was dimensionally wrong (the
      formula algebraically cancels out the rectilinear/direct node-count
      ratio entirely); the dimensionally-correct re-derivation (preserve the
      same ~1,480-node ceiling the 750 direct cap targets, divided by
      rectilinear's actual measured 3.667 nodes/individual) gives ~404,
      rounded to 400. **(d)** Live `shinytest2`/`chromote` re-verification
      against the real fixture: #134 (the `GA204Z`/`8LKBV9` loop) renders
      correctly under the rectilinear style, 0 diagram-related console
      errors. #135's search dropdown is unaffected (unit-test-covered). **A
      real, live-confirmed regression was found and fixed in #135's
      `highlightNearest` hover-highlighting** -- the exact risk design doc
      Section 3 D3 flagged but did not resolve: degree-1 hover often reaches
      only an invisible `__drop_`/`__bar_`/`__proj_` waypoint under the
      rectilinear style (measured concretely: an individual who is only a
      child, or a parent whose own mate-line got rerouted through a D2
      projection node, lit up NOTHING visible on hover, vs. the direct
      style's own guaranteed visible union-dot minimum). Owner chose a
      bounded mitigation via `AskUserQuestion`: `highlightNearest`'s
      `degree` is now style-aware (1 for direct, unchanged; 6 for
      rectilinear, covering the concretely measured hop distances up to 4).
      Live re-verified after the fix: the same previously-blank hover now
      lights up 2 real individual ids plus 3 union dots. **Not a full fix**
      -- a very wide sibship's D1 bar chain can still exceed 6 hops; see the
      new Housekeeping item below. Legend and PNG export also live-confirmed
      unaffected (separate widget instance renders; export click succeeds;
      0 related console errors). Verified at every checkpoint: full
      regression suite 0 failed/0 error (10 pre-existing baseline warnings,
      unchanged, final count 4515 passed); `devtools::check()` 1
      WARNING/2 NOTEs, exact pre-existing baseline, 0 new, at every
      checkpoint; `lintr` 0 lints on every changed file. See `CHANGELOG.md`,
      `PROJECT_LEARNINGS.md`.
- [ ] **`highlightNearest` degree=6 mitigation for the rectilinear style is
      bounded, not a full fix** (found S468, Effort M, low priority) -- a
      very wide sibship's D1 sibship-bar chain can exceed 6 hops (chain
      length scales with the number of children in one mating unit), so a
      hover on an individual in a very large family could still light up
      nothing visible. A full fix would need either a custom JS
      `highlightNearest` reimplementation that specifically skips through
      invisible waypoint nodes regardless of hop count, or a data-layer
      change that keeps degree-1 semantics correct (e.g. tagging waypoint
      edges so a custom traversal treats them as zero-cost hops). Not
      designed this session -- the degree=6 mitigation was explicitly
      scoped as a quick, bounded fix, owner-directed via `AskUserQuestion`.
      A future session should measure the real fixture's own maximum
      sibship size to gauge how often 6 hops is actually insufficient in
      practice before deciding whether a full fix is warranted.

## Outreach
- [ ] **NPRC outreach & announcement plan** (DECISION NEEDED -- owner review/edit of
      drafts + send timing; Effort N/A, not a coding task) -- plan complete:
      `docs/planning/nprc-outreach-announcement-plan.md` (S413, owner-directed, not
      from this backlog). Covers audiences (the NPRC Genetics and Genomics Working
      Group, plus each of the 7 centers' colony-manager/veterinarian contacts), tailored
      messaging, channels, a sourced 7-center contact roster (director + colony-manager/
      head-veterinarian-equivalent + genetics contact per center, each with a source),
      a generic timeline, 5 named risks, and ready-to-edit draft materials (WG email,
      colony-manager/vet email, one-page feature summary, presentation outline). Two
      items remain genuinely unresolved after dedicated research, not just undone: the
      Working Group's current (2026) chair could not be confirmed (recommended action:
      ask `support@nhprc.org` directly, see the plan's §3/§8); and a colony-manager
      contact could not be named at 3 of 7 centers (Southwest, Tulane, Washington --
      the role is undocumented by name on each center's own site). **Next steps are
      owner-executed, real-world actions** (review/edit the drafts, confirm exact
      recipients, send) per the plan's own §7 -- pick this up in a future session only
      if the owner wants help drafting a specific follow-up, not as a general "send the
      emails" coding task. See `CHANGELOG.md`.

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

## Genetic-metrics PDF audit follow-ups (from GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md)
*S419's capability-comparison audit (`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`)
compared the package against the 2015 NHP Genetics and Genomics Working Group PDF and found 12
missing / 9 partial findings (of 37 total). Triaged S422 (2026-07-29) via owner `AskUserQuestion`
picks -- all 6 findings/clusters owner-directed to file as GitHub issues, tracked there, not here:
**#125** (configurable ranking-priority scheme + surface multiple breeding-group candidates,
Dimensions 1 & 2), **#126** (kinship/genome-uniqueness distribution shape statistics -- skewness,
kurtosis, Dimension 3), **#127** (surface `correctUnknownParentMeanKinship()`'s silently-dropped
`flagged` list, Dimension 4), **#128** (breeding-group exclusion is top-N rank-based, not a
genetic-value floor, Dimension 2), **#129** (pedigree-diagram/tree visualization, currently
table-only, Dimension 7), **#130** (marker-based kinship/heterozygosity/parentage-verification +
cross-center identity resolution, Dimensions 5 & 6). 1 finding (NGS/whole-genome/MHC-specific/
linkage-disequilibrium methods, Dimension 5) declined, no action -- the source PDF itself frames
these as speculative future work even in 2015, matching the audit's own Recommendation #5. The
remaining findings (PMX/MateRx/Pedscope/PedSys tool-comparison notes, the "make pedigree available
to researchers" governance recommendation) are descriptive or already-adequately-served, not gaps
requiring tracking. See `CHANGELOG.md`.*
- [ ] **Sequencing decision (owner-directed, S428, 2026-07-29):** #126 is now
      DONE -- S429 (2026-07-29, see `CHANGELOG.md`). Planning issue #127 was
      DONE -- S430 (2026-07-29). **Implementing issue #127 is now DONE --
      S431 (2026-07-29, closes issue #127):** `reportGV()`'s `$report` carries
      a new boolean `flagged` column (all bundled/live surfaces), see
      `CHANGELOG.md`. **Planning issue #129 is now DONE -- S432 (2026-07-29):**
      `docs/planning/issue129-pedigree-diagram-tree-visualization-plan.md`
      ratified (D1 extend `modPedigree.R`; D2 visNetwork; D3 reuse the
      existing strict-lineal trim; D4 multi-slice). **Implementing issue #129
      Slice 1 is now DONE -- S433 (2026-07-30):** the Pedigree Browser tab
      gained a Diagram view (new `makePedigreeDiagramData()` + `modPedigree.R`
      Table/Diagram tabsetPanel + `visNetwork` dependency), see `CHANGELOG.md`.
      **Implementing issue #129 Slice 2 is now DONE -- S434 (2026-07-30,
      closes issue #129):** clicking a diagram node re-centers the population
      on that animal via the existing `focalIds` reactive path
      (`visNetwork::visEvents(click = ...)` + a new `observeEvent` in
      `modPedigree.R`). Pre-RED found and corrected a real gap in the ratified
      plan's mechanism assumption: visNetwork does not auto-bind node clicks
      to a Shiny input (`input$<id>_click`) the way the plan's design section
      assumed -- confirmed hands-on that `visEvents(click = ...)` must be
      wired explicitly. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning
      408. **Both slices of issue #129 are now shipped; issue #129 itself is
      closed as part of this session's close-out.** **Planning #130 is now
      DONE -- S441 (2026-07-30):**
      `docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md`
      ratified (D1 long/tidy multi-locus genotype format; D2 native
      KING-robust kinship in base R, no new hard dependency; D4 Mendelian
      -exclusion parentage verification; D5 deterministic cross-reference
      -table cross-center identity linking; D6 new dedicated
      `modMarkerGenetics` module; D7 five vertical slices in dependency
      order -- Slice 1 marker kinship first, Slices 2/3/5 depend on it,
      Slice 4 cross-center linking is fully independent). See
      `CHANGELOG.md`. **Implementing Slice 1 (marker-based kinship +
      multi-locus genotype foundation) is now DONE -- S442 (2026-07-30):**
      new `checkMarkerGenotypeFile()`/`buildMarkerGenotypeMatrix()`/
      `markerKinship()` (KING-robust, Manichaikul et al. 2010 Eq. 11,
      sourced and cross-verified from two independent references at
      Pre-RED) plus a new `modMarkerGenetics` module (D6) surfacing a
      pedigree-vs-marker mean-kinship comparison table, wired into
      `appUI.R`/`appServer.R` as a new "Marker Genetics" tab. Full TDD
      cycle (PRE-RED->RED->GREEN->REFACTOR, all `AskUserQuestion`-gated);
      citation checklist (`population_genetics_terms.html` + roxygen
      `@references`) and tutorial checklist (`colony-manager-guide.qmd`
      "Marker Genetics" section + live screenshot) both done in-session.
      Verified: regression suite 0/0/0 (4067 passed, 170 skipped);
      `devtools::check()` 0 errors/0 warnings/0 notes; live
      `shinytest2`/`chromote` smoke test confirmed a real, correctly
      -computed comparison table with no console errors. See
      `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learnings 422-425.
      **Implementing Slice 2 (heterozygosity diagnostic) is now DONE --
      S443 (2026-07-31):** new `markerObservedHeterozygosity()`/
      `markerExpectedHeterozygosity()` (Nei 1973 gene diversity,
      cross-verified and citation-corrected at Pre-RED away from the
      plan's imprecise "VCFtools/PLINK --het" framing) plus a new
      Heterozygosity tab in `modMarkerGenetics` (per-animal `ho` vs.
      population `he`). Full TDD cycle (PRE-RED->RED->GREEN->REFACTOR,
      all `AskUserQuestion`-gated); citation and tutorial checklists both
      done in-session. Verified: regression suite 0/0/0 (4096 passed,
      170 skipped); `devtools::check()` down to the single pre-existing,
      unrelated `IACUC` spelling NOTE below (fixed the marker-genetics
      -family spelling gap S442 left unresolved along the way -- see
      `PROJECT_LEARNINGS.md` Learning 426); live `shinytest2`/`chromote`
      smoke test confirmed real, correctly-computed values with no
      console errors. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md`
      Learnings 426-427.
      **Implementing Slice 3 (Mendelian-exclusion parentage verification)
      is now DONE -- S444 (2026-08-01):** new `markerParentageExclusion()`
      (opposite-homozygote conflict counting over jointly-genotyped loci,
      cross-referenced against the pedigree's recorded dam/sire) plus a
      new Parentage Exclusion tab in `modMarkerGenetics` (flagged-pairs
      table: `id`/`parentId`/`role`/`exclusionCount`/`nLoci`/`flagged`).
      Dragon P4 (genotyping-error tolerance) resolved at Pre-RED via a
      2-source-plus-adversarial-cross-check research `Workflow`:
      `maxExclusions = 2` (flag only at 3+ inconsistent loci), citing
      Cifuentes et al. 2006 and de Groot et al. 2025 (a real captive
      rhesus/cynomolgus colony precedent) over the alternative bison/cattle
      microsatellite convention, owner-approved via `AskUserQuestion`. Full
      TDD cycle (PRE-RED->RED->GREEN->REFACTOR, all `AskUserQuestion`-gated);
      citation and tutorial checklists both done in-session. Verified:
      regression suite 0/0/0 (3425 passed, 182 skipped); `devtools::check()`
      down to the single pre-existing, unrelated `IACUC` spelling NOTE (own
      new citation words fixed in `inst/WORDLIST` same-session, see
      `PROJECT_LEARNINGS.md` Learning 428); live `shinytest2`/`chromote`
      smoke test confirmed real, correctly-computed exclusion counts/flags
      (0/false for a true dam, 3/true for a falsely-recorded sire) with no
      console errors. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learnings
      428-430.
      **Implementing Slice 4 (cross-center identity linking) is now DONE --
      S446 (2026-08-01):** new `resolveCrossCenterIds(pedA, pedB, mapping)`
      (base R, no new dependency) collapsing a curator-confirmed
      cross-center identity link so a transferred animal becomes one node
      with its real parents intact, instead of the artificial founder
      issue #130 names as its literal failure mode. Dragon P6 (Shiny-wiring
      scope) resolved via `AskUserQuestion`: script-callable function only
      this session, no `modInput.R` UI change, matching the plan's own
      cited `getFileDirectRelatives()` precedent. Full TDD cycle
      (PRE-RED->RED->GREEN, REFACTOR owner-confirmed skip, all
      `AskUserQuestion`-gated); RED fixture hand-verified against the
      package's real `kinship()`/`findGeneration()` before any assertion
      was written, proving both the bug (`kinship(S1,O1) == 0` on a naive
      un-merged combination) and the fix (`== 0.125`, the correct
      aunt/nephew coefficient across the two centers) -- see
      `PROJECT_LEARNINGS.md` Learning 432. Citation and tutorial/article
      checklists are N/A this slice (no new displayed statistic, no new
      UI shipped). Verified: targeted test file 18/18 expectations;
      regression suite 0/0/0 (3443 passed, 182 skipped); `devtools::check()`
      0 errors/0 warnings/0 notes; `_pkgdown.yml` reference-coverage entry
      added same-session (the gap class Slice 1 hit and had to fix
      retroactively). See `CHANGELOG.md`.
      **Implementing Slice 5 (cross-center differentiation statistic) is
      now DONE -- S447 (2026-08-01), closing out issue #130's entire
      5-slice sequencing chain:** new `markerFst(genotypeMatrixA,
      genotypeMatrixB)` computing Hudson's Fst (Bhatia et al. 2013 Eq.10,
      citing Hudson, Slatkin & Maddison 1992), ratio-of-sums pooling across
      loci, base R only. Dragon P2 (estimator choice) resolved via a
      5-agent Pre-RED research `Workflow` (3 research angles + adversarial
      verification + synthesis) -- the adversarial pass found the first
      pass's own "Weir & Cockerham (1984)" formula was an incomplete,
      ~40%-off special case, confirmed against 3 independent sources; the
      synthesis recommended switching to Hudson's estimator entirely,
      per Bhatia et al.'s own explicit recommendation for two-named-
      population pairwise comparisons -- see `PROJECT_LEARNINGS.md`
      Learning 434. `modMarkerGenetics` gained a Cross-Center tab (second
      file input). Full TDD cycle (PRE-RED->RED->GREEN, REFACTOR
      owner-confirmed skip, all `AskUserQuestion`-gated); citation and
      tutorial/article checklists both done in-session. Verified: full
      regression suite 0/0 (3476 passed, 182 skipped); `devtools::check()`
      0 errors/0 warnings/0 notes; live `shinytest2`/`chromote` smoke test
      confirmed real, correctly-computed Fst values (byte-exact match to
      the hand-verified fixture) with no console errors. **Issue #130 is
      now fully implemented across all 5 slices; no open item remains in
      this sequencing chain.** See `CHANGELOG.md`.

**Second-generation re-audit and issue-sequencing (S479-S483, 2026-08-05 to 2026-08-08):** a ghost
session (reconciled S479, see `PROJECT_LEARNINGS.md` Learning 479) produced 2 further capability
audits -- `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md` and a revised
`..._2026-08-06.md` -- and filed 8 new GitHub issues against the 08-05 audit's findings: **#146**
(configurable/exhaustive breeding-group candidate retention), **#147** (likelihood-based
candidate-parent assignment after marker parentage exclusion), **#148** (MHC haplotype-specific
frequency/rare-haplotype reporting), **#149** (reviewed cross-center identity-mapping workflow with
provenance export), **#150** (de-identified pedigree export workflow for approved data sharing),
**#151** (individual mate-pair analysis alongside breeding-group optimization), **#152**
(whole-genome/whole-exome sequence input + sequence-based metrics), **#153** (linkage-aware/
haplotype-block metrics for marker data). These sat unsequenced across S479-S482 (each handoff
noting "remain open, GitHub-only, unchanged"). **Sequencing proposed S483 (2026-08-08), owner-
directed:** `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` -- an 8-agent
codebase-grounded assess + synthesize + adversarial-verify workflow recommends: **Tier 1** (design
launch) #147, the batch's sole High-priority item (XL effort, no existing likelihood/LOD parentage
method or pedigree-mutation pattern to build on); **Tier 2** (ready-to-build Medium) #149 > #146 >
#151, ordered by effort/readiness and shared-file coordination (#146/#151 both touch
`modBreedingGroups.R`); **Tier 3** (policy-gated quick win) #150 -- highest codebase readiness in the
batch (the obfuscation primitives are already built/tested) but deliberately excluded from the audit's
own priority table ("Policy/external"), needs an explicit owner sign-off on what "curator-controlled"
means before it is scheduled on technical merits alone; **Deferred** (design-only) #152 > #153 > #148,
matching the 08-06 audit's own "Deferred/scientific... advance only through separately scoped
research/design work" guidance -- #148 flagged as filed broader than the audit recommends (a full
feature request, not the design-only ask #152/#153 were filed as) and needing its own scope-narrowing
conversation first. **Also found:** 2 of the audit's own High-priority rows -- "Longitudinal
genetic-health monitoring" and "Ancestry guardrails in breeding decisions" -- have **no corresponding
filed issue** anywhere in #146-153, despite ranking above every Medium/Deferred item in this batch; a
future triage session should file both (as full-feature requests gated on a Pre-RED design session,
matching #147's own shape, per the audit's Finding #1/Recommendation 2). No issues implemented or
closed this session -- sequencing/proposal only, per the established "audit recommends, a later
session files/implements" precedent.
