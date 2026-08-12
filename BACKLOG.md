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
- [ ] (none remaining -- the "`markerParentageLikelihood()`'s auto-detect
      candidate lookup never finds a candidate when both of a flagged
      animal's parent slots are recorded" item (found S498, design ratified
      S501) is RESOLVED -- **implemented S502 (2026-08-10):** new internal
      `.markerFlaggedSlotPedigree()` helper (`R/markerParentageLikelihood.R`),
      wired into both `getPotentialParents()` call sites; zero changes to
      `getPotentialParents()` itself. Strict TDD; 9 new tests; full regression
      0 failed/0 error. Live `shinytest2` smoke test confirmed the fix on the
      real running app. **Issue #155 closed.** See `CHANGELOG.md`,
      `PROJECT_LEARNINGS.md` Learning 501.)
- [ ] (none remaining -- the "`.buildTwinConnectorEdges()` (`R/makePedigreeDiagramData.R`, issue
      #137 Slice 2) never wired the Okabe-Ito green (`#009E73`) color" item (found S494) is
      RESOLVED -- **wired S506 (2026-08-10):** color added for both `edgeStyle` values plus a
      matching legend swatch (`R/modPedigree.R`). A second dragon found and fixed the same session:
      `.addRectilinearWaypoints()` unconditionally reset edge color to `NA` under
      `edgeStyle = "rectilinear"` (same anti-pattern issue #133 already fixed on the node side).
      Strict TDD; live `shinytest2` smoke test confirmed both `edgeStyle` values. See
      `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 505.)
- [ ] (none remaining -- the "`devtools::check()` returns a non-portable-filename
      ERROR/WARNING for `inst/extdata/reference/Standardized Human Pedigree
      Nomenclature: ...html`" item (found S486) is RESOLVED -- S497
      (2026-08-09): owner renamed the file (outside a session tool call) to
      `inst/extdata/reference/pedigree_nomenclature.html`. `devtools::check()`
      went from 1 error/1 warning/1 note to 0/0/0 -- the vignette-engine NOTE
      was confirmed a downstream symptom of the filename ERROR, not an
      independent defect. Incidental gap found and fixed the same session:
      `.Rbuildignore` had never excluded this file (or 2 other copyrighted
      files) from the built tarball, despite `.gitignore` keeping them out of
      git -- fixed for all three, verified via `pkgbuild::build()`. **The
      separately-tracked `spelling.Rout` WORDLIST gap is unrelated and still
      open** -- see the item below. See `CHANGELOG.md` (backfilled Session
      529), `PROJECT_LEARNINGS.md` Learning 480.)
- [ ] (none remaining -- the "`NEWS.Rmd` has no checklist analogous to the
      citation/tutorial checklists" item (discovered S446) is RESOLVED:
      owner ratified a broad checklist -- any session shipping a new
      exported function OR a user-facing Shiny feature/control must add a
      `NEWS.Rmd` entry in the same session it ships. Recorded in
      `CLAUDE.md`'s "Additional close-out checks" -- S448 (2026-08-01).
      Issue #130 Slices 1-5 backfilled with 5 `NEWS.Rmd` bullets as a
      one-time exception. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md`
      Learning 433.)
- [ ] (none remaining -- the "`vignettes/a2interactive.Rmd` has no checklist
      analogous to the tutorial/article checklist, and issue #130's marker
      -genetics family has ZERO mentions there" item (discovered S447,
      `PROJECT_LEARNINGS.md` Learning 435) is RESOLVED -- S450 (2026-08-02):
      extended `CLAUDE.md`'s documentation-checklist family with a new,
      explicitly DEFERRED (not same-session) rule requiring
      `a2interactive.Rmd` coverage for new exported, script-callable
      functions. Issue #130's 5 already-shipped functions backfilled with a
      new "## Marker Genetics" section (6 subsections), reusing the same
      hand-verified fixtures as the app's own tab screenshots. See
      `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 440.)
- [ ] (none remaining -- the "`devtools::check()`'s spelling NOTE is
      broader than previously tracked" item (discovered S443 as just
      `IACUC`; broadened S448) is RESOLVED -- S452 (2026-08-02): the single
      NOTE actually covered 13 words, not 12; all 13 hand-added to
      `inst/WORDLIST` in `LC_ALL=C` byte-order position. `devtools::check()`
      raw log now reads `Status: 1 WARNING` (the pre-existing, unrelated
      iCloud duplicate-file warning) with no spelling NOTE. See
      `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 441.)
- [ ] (none remaining -- the "Pre-existing `shinyBS is not defined` JS console
      error on every page load" item (discovered S433) is RESOLVED: fixed
      S437 (2026-07-30). Root cause: this package only ever accesses shinyBS
      via `::`, never `library(shinyBS)`, so shinyBS's own `.onAttach()`
      resource-path hook never fires. Fixed via `R/zzz.R`'s own `.onLoad()`
      registering the same resource path, guarded by `requireNamespace()`.
      Verified live via `shinytest2`: the console error no longer occurs.
      **Live verification surfaced a second, unrelated defect** -- shinyBS's
      JS is incompatible with this app's Bootstrap 4.6.0 popover plugin,
      leaving popovers/tooltips non-functional -- filed as
      [issue #140](https://github.com/rmsharp/nprcgenekeepr/issues/140).
      **Issue #140 RESOLVED -- S438 (2026-07-30):** fixed via a JS shim
      (`inst/www/js/shinyBS-popover-fix.js`) guarding the throwing
      `.popover("destroy")`/`.tooltip("destroy")` calls. Verified live: zero
      console errors AND popovers/tooltips actually functional. See
      `CHANGELOG.md`.)
- [ ] (none remaining -- the "`inst/extdata/` reorganization" item (plan:
      `docs/planning/extdata-reorganization-plan.md`, S414) is RESOLVED -- all
      4 phases DONE (S415-S418, 2026-07-28): **Phase 1** relocated 24 dev
      -scratch/orphaned items to `dev/extdata-scratch/`, cleaned dead
      `.Rbuildignore`/`.gitignore` lines. **Phase 2** moved 10 load-bearing
      files to `inst/extdata/examples/` (owner-picked name), updating ~28
      `system.file()` call sites across 15 test files. **Phase 3** fixed 2
      un-migrated `system.file()` calls the plan's own scope text undersold
      (`PROJECT_LEARNINGS.md` Learning 384) + a stale GitHub blob URL. **Phase
      4** moved the reference PDF to `inst/extdata/reference/`, re-rendered a
      stale `README.Rmd` (Learning 385). Every phase verified against exact
      regression baseline (0 failed/0 error) and `R CMD build` tarball
      contents. See `CHANGELOG.md` (backfilled Session 529).)
- [ ] (none remaining -- the "`ROADMAP.md`'s doc-engine-policy line is now stale"
      item (flagged S418) is RESOLVED: `ROADMAP.md:21-22` corrected to
      `dev/extdata-scratch/`, matching where the extdata reorg's Phase 1 moved
      the dev docs -- S420 (2026-07-29). See `CHANGELOG.md`.)
- [ ] (none remaining -- the "`NEWS.md:8` spelling-check NOTE -- `CRAN's`/
      `resubmission` missing from `inst/WORDLIST`" item (discovered S415) is
      RESOLVED: both words hand-added -- S421 (2026-07-29). `devtools::check()`
      `Status: OK`, 0 notes. See `CHANGELOG.md`.)
- [ ] (none remaining -- the "`test-e2e-data-ready.R`'s 'appUI includes
      data-ready.js' test doesn't actually verify content inclusion" item
      (discovered S438) is RESOLVED: fixed S439 (2026-07-30). Replaced the
      hollow class-inherits assertion with `htmltools::renderTags(app_ui)$head`
      content checks. RED proven by temporarily disabling the include, GREEN
      restored with 0 failed/0 error. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md`
      Learning 417.)
- [ ] (none remaining -- the "`CLAUDE.md`'s 'Fast single-file test' command
      silently skips the entire file for any test file that calls
      `skip_on_cran()` at top level" item (discovered S439, `PROJECT_LEARNINGS.md`
      Learning 417) is RESOLVED -- S451 (2026-08-02): `Sys.setenv(NOT_CRAN =
      "true")` prepended to the documented one-liner. See `CHANGELOG.md`.)
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
- [x] (none remaining -- the "Accumulated `lintr::lint_package()` warnings, 45
      total across 17 files" item (found S462) is RESOLVED -- **part (a)
      DONE -- S466 (2026-08-03):** all 41 warnings across the 16 tracked
      files fixed (REFACTOR-only, style-only). 4 of the original 45 were on
      an untracked iCloud-duplicate file, correctly out of scope. 6 lintr
      false positives found and suppressed via documented `# nolint`
      blocks/`.lintr` exclusions rather than deleted or semantically
      mis-"fixed" (a load-bearing `\deqn{}` citation formula among them).
      Full regression + `devtools::check()` + live `shinytest2` smoke test
      across 4 touched module tabs all confirmed exact baseline match. See
      `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 461. **Part (b) was
      split out as its own item, below.**)
- [x] (none remaining -- the "Wire a process fix so `lintr` debt stops
      re-accumulating" item (split from the item above, S462) is RESOLVED --
      **DONE -- S477 (2026-08-04):** found `.github/workflows/lint.yaml`
      already existed and ran on every push -- the real gaps were no branch
      protection (a failing run blocks nothing) and 2 real, unnoticed
      violations red for 4 sessions (`R/makePedigreeDiagramData.R`, from
      S472's issue #143 fix). Fixed both (REFACTOR-only); added a "Lint
      close-out checklist" to `CLAUDE.md` requiring sessions to lint touched
      files before closing out, rather than relying on CI alone. Verified: 0
      lints package-wide (was 2); full regression 0 failed/0 error, unchanged
      baseline. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 477.)
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
      **Count grown to 9 words as of S490 (2026-08-09), still not fixed** --
      incidental to issue #136 Slice 2's own `devtools::check()` verification
      pass. The original 6 (`sibship`/`waypoint`/`duplicateToReal`/`js's`/
      `makePedigreeMatingLayout`/`vis`) are joined by 3 more: `discoverable`
      (`NEWS.md:140`), a bare `js` (`a2interactive.Rmd:533`, distinct token
      from `js's`), and `unshaded` (`_pedigree_browser.Rmd:55`) -- all 3
      confirmed via `git blame`/`git log -S` to trace to commit `100741ae`
      (S487, 2026-08-08, issue #133 Slice 2's own NEWS/tutorial/article
      commit), not this session's diff. A future session fixing this item
      should hand-add all 9 words, not just the original 6.
- [ ] **The "10 pre-existing baseline warnings" carried in every full-regression
      report since S448 have never been root-caused, and were introduced by a
      test-fixture gap, not a real production-code issue** (found S487,
      incidental to issue #133 Slice 2's own regression read; Effort S, low
      priority) -- the owner asked directly ("we had zero at last release")
      after seeing `warning: 10` in this session's clean regression read, which
      no prior session had actually traced. Root cause: both
      `tests/testthat/test_modMarkerGenetics.R` "cross-center" tests (added by
      commit `a319e0c5`, S447, 2026-08-01, implementing issue #130 Slice 5)
      upload a hand-derived 2-locus toy fixture (Center A n=4, Center B n=6)
      chosen for exact-fraction Fst arithmetic, not for kinship completeness.
      `modMarkerGeneticsServer`'s reactive graph incidentally also computes
      marker-based kinship (the Slice 1 feature) on any uploaded Center-A file,
      and in this fixture `'CA1'`/`'CA2'` share no heterozygous locus --
      `markerKinship()` correctly warns and returns `NA` for that pair (working
      as designed, not a bug), 5x per test x 2 tests = 10. **Confirmed CRAN
      v2.0.0 (released 2026-07-26) predates S447 (2026-08-01) and genuinely
      shipped with a clean, 0-warning suite** -- the owner's recollection was
      correct. S447's own close-out reported "0 failed/0 error" but never
      actually stated a warning count; S448 (the very next session)
      independently found S447's self-reported `devtools::check()` "0/0/0"
      also didn't hold up under re-verification (a missed spelling gap) --
      the same kind of unverified self-report, in the same session, is the
      most likely origin of this gap too, though this was never directly
      confirmed against S447's own raw test output (not preserved). Every
      session from S448 through S486 (~40 sessions) carried "10 pre-existing
      ... warnings" forward as an accepted baseline without investigating what
      it was. Not fixed this session (`PROJECT_LEARNINGS.md` Learning 382's
      "report, don't fix mid-session" precedent -- out of scope for a Slice 2
      legend/documentation TDD session; owner directed file-and-continue via
      `AskUserQuestion`). A future session should either (a) wrap the
      `session$setInputs(genotypeFile = ...)` calls in these 2 tests with
      `suppressWarnings()` (matching the established `PROJECT_LEARNINGS.md`
      Learning 273(d) precedent: "a degenerate out-of-contract input ... often
      misbehaves further downstream -- suppress the incidental warning, not
      the branch"), or (b) adjust the 2-locus fixture so `CA1`/`CA2` share a
      heterozygous locus -- but only after re-verifying the exact-fraction Fst
      values (`58/1001`, `139/308`, `614/2233`) still hold, since the fixture
      was hand-derived specifically to produce those numbers.
      **Count grown from 10 to 15, found incidentally S504 (2026-08-10), still
      not fixed** -- a full clean regression read during issue #149 Slice 1
      showed `warning: 15`, confirmed via a `git stash` comparison to be
      pre-existing (identical on unmodified `HEAD`), unrelated to that
      session's own diff. The 3rd 5-warning source is
      `test_modMarkerGenetics.R`'s "candidate-parent-assignment table is
      non-empty for a real (non-mocked) recorded-but-wrong-parent fixture
      (issue #155)" block, added S502 (2026-08-10) -- a live, non-mocked
      genotype-file upload that incidentally triggers the same
      `markerKinship()` NA-warning path as the 2 original cross-center tests.
      A future session fixing this item should address all 3 test blocks, not
      just the original 2.

- [ ] (none remaining -- the "fix the `methodology_trim.py` fence-scanner defect blocking
      `SESSION_NOTES.md`'s first archive" item (found S518) is RESOLVED -- S527 (2026-08-12):
      rewrapped the one offending paragraph (`SESSION_NOTES.md`, then-line `:23229`, shifted to
      `:24390` by the time this session ran) so the 4-backtick inline code span no longer opens a
      physical line -- a 2-line, zero-content-change edit (moved the word "backtick" to the start of
      the next line; same words, same order, only the wrap point moved). Verified: before the fix,
      `python3 methodology_trim.py --file SESSION_NOTES.md` reported `173 record(s) partitioned`;
      after, `522` -- confirmed via direct `fence_scan()` cross-check against the tool's own
      `record_start` regex that this is the FULL count the regex is capable of matching (0 missing).
      **A second, independent, pre-existing defect was found while verifying this fix (not fixed
      this session, filed below as its own item):** the regex itself has a trailing `\b` that
      structurally can never match the "Handoff Evaluation (by Session N)" heading branch (always
      ends in `)`, a non-word char, immediately followed by end-of-line -- `\b` requires a word/
      non-word transition, which never occurs there). This means the 522 figure above, though it IS
      the fence-scanner's full current capability, still excludes all 74 "Handoff Evaluation"
      headings in the file (596 real headings total, confirmed via direct regex testing, 0 of the 74
      ever matched). See `CHANGELOG.md`.)
- [ ] (none remaining -- the "`methodology_trim.py`'s `SESSION_NOTES.md` `LEDGERS` `record_start`
      regex never matches 'Handoff Evaluation' headings" item (found S527) is RESOLVED -- S528
      (2026-08-12): moved the trailing `\b` so it guards only the `What Session \d+ Did` branch
      (the one that actually needed it) instead of sitting after the whole alternation --
      `record_start = re.compile(r"^### (?:Session \d+ Handoff Evaluation \(by Session \d+\)|What
      Session \d+ Did\b)")`. The `Handoff Evaluation (by Session N)` branch needed no `\b` at all
      (it already ends unambiguously in a literal `)`); dropping the anchor entirely (the other
      candidate fix) was considered and rejected because it would also silently accept a
      hypothetical `"### What Session N Didn't ..."` heading as a false record start -- moving `\b`
      inside the `Did` branch keeps that guard while fixing the real bug. Verified via a direct
      `fence_scan()`/`record_start` cross-check (the CLI's own dry-run was blocked this session by
      an unrelated `P1_UNDOCUMENTED` gate on the in-progress claim commit): RED = 523 of 598 true
      headings matched (0 of 75 "Handoff Evaluation" headings); GREEN = 598 of 598, exact. Also
      confirmed the fix still rejects the hypothetical `"Didn't"` false-match case (no such heading
      exists in the file today). **After this fix's own close-out commit advanced the
      `CHANGELOG.md` frontier, the `P1_UNDOCUMENTED` gate cleared and the CLI's own dry-run was
      re-run directly, confirming end-to-end (not just via the direct cross-check): `[L3_OK] 599
      record(s) partitioned; every one byte-identical across the move` -- an exact match against the
      true total.** `PROJECT_LEARNINGS.md` Learning 534. See `CHANGELOG.md`. The actual first
      `--write` archive of `SESSION_NOTES.md` is still deferred, owner-picked this session, matching
      the S527 precedent of keeping the archive itself a separate, later action -- a future session
      should re-run the dry-run once more (counts drift as sessions append) and, if still clean, run
      `--write`.)
- [ ] **`BACKLOG.md`'s own ledger-size housekeeping -- editorial compression, not a
      `methodology_trim.py` config** (found S518, 2026-08-11, READY, Effort L) -- `BACKLOG.md`
      itself is one of the dashboard's 3-file HIGH-risk ledger-size items but does not fit
      `methodology_trim.py`'s chronological-record model: it has 10 `##` sections, each a large
      *standing topical category* that accumulates resolved-item narrative indefinitely, not dated
      newest-on-top records. The file's own header already states the right remedy: "Open,
      actionable work only... for history see `CHANGELOG.md`."
      **Housekeeping section DONE -- S529 (2026-08-12):** an inventory pass (background agent, full
      read of all 2,501 then-current lines) found 62 top-level items file-wide, 48 fully resolved,
      ~1,500 compressible lines total, concentrated in 3 oversized sections (Housekeeping,
      "Pedigree diagram vs kinship2," "Genetic-metrics PDF audit"). Scoped to Housekeeping only for
      this session (owner-picked via `AskUserQuestion`, over top-15-file-wide / single-biggest-item
      / prep-only alternatives) -- self-contained, bounded by clean section headers. All 17 of its
      19 fully-resolved items compressed to the file's own established short-pointer convention; the
      8 genuinely-open items (incl. this one) left untouched. **2 items had NO existing
      `CHANGELOG.md` entry at all** (a real ledger gap, FM #27 -- not just verbose narrative): the
      `inst/extdata/` reorg (Sessions 415-418) and the non-portable-filename fix (Session 497).
      Backfilled proper `CHANGELOG.md` entries for both before compressing, rather than compress to
      a dangling pointer that would have destroyed the only detailed record. Net: Housekeeping
      147→389 lines (263 removed); file total 2,501→2,238 (263 removed). Zero information loss
      verified by re-reading the full compressed section end-to-end before close-out.
      **"Pedigree diagram vs kinship2 audit follow-ups" section DONE -- S530 (2026-08-12):** the
      2nd of the item's 2 remaining sections. Compressed all 12 fully-resolved bulleted items (issues
      #131/#134/#135/#139, Option 2 layout feasibility/design/3 implementation slices, the
      duplicate-node-arc fix, issues #143/#144) to the file's own short-pointer convention, and
      condensed the ~375-line unbulleted S480-S500 Progress-narrative chain (Tier 1 crash-bug fixes +
      #145 spike + doc refresh; Tier 2 issues #133/#136/#137/#145, all closed) into one ~50-line
      consolidated summary retaining every session number, design-doc path, and Learning
      cross-reference. Verified `CHANGELOG.md` (+ its `docs/archive/CHANGELOG-through-*.md` shards)
      actually carries an entry for all 31 session numbers cited before compressing to a pointer --
      0 gaps found this time (unlike the Housekeeping section's 2). All Learning cross-references and
      all 11 cited `docs/planning|audits|research/*` file paths confirmed to resolve. The 4 genuinely
      -open items (Candidate C's connector idea; the 3 dangling-parent-crash-bugs and free-pass-filter
      pointers, both already short; the node-count-off-by-one gap; the docstring-mismatch gap; the
      `highlightNearest` degree=6 bound) left untouched. Net: section 896->286 lines (610 removed);
      file total 2,254->1,658 (596 removed, after this session's own S518-item progress notes added
      lines back elsewhere in the file). Zero information loss verified by re-reading the full
      compressed section end-to-end before close-out.
      **Still open -- 1 section remains, its own future session per this item's original
      "budget it as its own session" guidance:** "Genetic-metrics PDF audit follow-ups" (~753 lines,
      a single living tracker for issues #146/#147/#149/#150/#151/#153 plus the still-open issue
      #152 -- higher-risk than either section already done: a naive "compress everything with a
      CHANGELOG pointer" pass would wrongly compress active-thread content, since most individual
      Progress blocks carry a pointer even while the overall thread remains open). A future session
      picking it up should re-run a fresh inventory pass first (line numbers/counts will have
      drifted) rather than trust this note's own figures verbatim.
- [ ] **`inst/WORDLIST` has a large, long-standing gap -- `devtools::check()`'s spelling-check step
      fires a NOTE on every run** (found S521, 2026-08-11, READY, Effort M) -- confirmed via direct
      verification, not assumed: temporarily removing this session's own new files from the tree and
      re-running `spelling::spell_check_package(".", vignettes = TRUE)` still flagged **69 words**
      not in `inst/WORDLIST`, spanning many past sessions' files (`NEWS.md`, `a2interactive.Rmd`,
      `_pedigree_browser.Rmd`, `_breeding_group_formation.Rmd`, `makePedigreeMatingLayout.Rd`,
      `checkLocusMetadata.Rd`, and more) -- proper nouns/citation authors (Bakker, Ferreira, Maller,
      Neale, Okabe, Sklar), genetics vocabulary (chrom, cM, pos, dizygotic, monozygotic, sibship,
      zygosity-adjacent terms), and methodology/UI prose (handoff, walkthrough, onboarding, CLI,
      shas, subplan, browsable, discoverable, unshaded, waypoint, js, vis, and others). This session
      hand-added only the 2 words its own new `checkLinkageMarkerGenotypeFile.Rd` is responsible for
      (`validator`, `multiallelic`) -- fixing the other 69 is a distinct, larger editorial task (verify
      each is a genuine false positive vs. an actual typo, per the S230/S421 hand-add convention, not
      `spelling::update_wordlist()`) out of scope for a single implementation slice. `devtools::check()`
      currently reports **0 errors / 0 warnings / 3 NOTEs** (this spelling NOTE plus the 2
      already-known pre-existing NOTEs: top-level files, vignette-engine) -- but S520's own close-out
      reported only "1 pre-existing note." Confirmed via `git log` that S520 never touched any of the
      69 flagged-word files, so the gap is not new since S520 -- the likelier explanation, worth
      recording as its own finding: `devtools::check()`'s abbreviated results table only lists a `❯`
      bullet for some NOTE-producing steps, and the "checking tests ... NOTE" step (spelling.R's
      diff-based check) does NOT get one -- only the raw `Status: N NOTEs` line (above the table)
      counts it. A session that trusts only the `❯`-bullet table, as this session nearly did, silently
      undercounts. See `CHANGELOG.md` 2026-08-11.
- [ ] **`NEWS.Rmd` entries since ~2.0.0 have drifted far more verbose than the
      project's own pre-1.0.8 style** (found S522, 2026-08-11, owner-directed,
      READY, Effort M) -- entries through and including the `1.0.8 (20250723)`
      section are short, plain bullets (e.g. "Added returned value
      descriptions for all functions within R directory where formerly
      missing."), one line per change, no formulas, no citations, no
      implementation rationale. Recent entries (issue #130's marker-genetics
      family, issue #153 Slices 1-3, etc.) have grown into multi-sentence
      paragraphs carrying full closed-form formulas, citation strings, and
      derivation/approximation rationale that belongs in roxygen `@references`
      and `inst/extdata/ui_guidance/population_genetics_terms.html` instead --
      both of which are already the user-viewable surfaces the citation
      checklist (issue #120) requires for exactly this content. A future
      session should rewrite the development-version entries back toward the
      pre-1.0.8 level of detail (what changed, in a sentence, matching
      existing bullet style) and move any calculation/derivation detail that
      isn't already in `@references`/`population_genetics_terms.html` there
      instead of trimming it outright. Scope this to entries from
      `2.0.0.9000 (development version)` forward -- do not rewrite already
      -released, frozen version sections (matching the general
      don't-edit-frozen-history precedent used for `CHANGELOG.md`'s Legacy
      history marker).
- [ ] **`a2interactive.Rmd` documentation pass is due -- several exported,
      script-callable functions shipped since the last pass (S478, 2026-08-04)
      have zero coverage** (found S522, 2026-08-11, owner-directed, READY,
      Effort M) -- per `CLAUDE.md`'s own deferred, non-same-session
      `a2interactive.Rmd` checklist rule. Confirmed gaps (grep of
      `vignettes/a2interactive.Rmd`'s section headers against `NEWS.Rmd`'s
      `2.0.0.9000` entries): the "Marker Genetics" section demonstrates only
      `markerKinship()`, the heterozygosity pair, Mendelian-exclusion
      parentage verification, `resolveCrossCenterIds()`, and `markerFst()`
      (issue #130-era) -- it has **no** section for `markerParentageLikelihood()`
      (LOD-based candidate-parent ranking, issue #147),
      `checkCrossCenterMapping()` (issue #149), `checkLocusMetadata()` (issue
      #153 Slice 1), `checkLinkageMarkerGenotypeFile()` (issue #153 Slice 2),
      `markerRealizedRelatednessVariance()` (issue #153 Slice 3, S522), or
      `markerLdBlock()`/`obfuscateLdBlocks()` (issue #153 Slice 4, S523).
      Outside marker genetics, `reportMatePairs()` (issue #151 Slice 1) and
      `readTwinRelations()` (S494, itself shipped with no `NEWS.Rmd` entry
      either per `PROJECT_LEARNINGS.md` Learning 495) also have no matching
      section. A future documentation-pass session should re-verify this list
      against the actual file (do not trust it as final -- compiled via grep,
      not an exhaustive read) and add a demonstration section per function,
      matching the existing "Marker Genetics" section's established style
      (reused, hand-verified fixtures; each demo chunk checked against the
      real installed package, not hand-derived, per `PROJECT_LEARNINGS.md`
      Learning 440's stale-local-install trap).

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
      RESOLVED: fixed S440 (2026-07-30) -- `visNetwork::visExport(type = "png", ...)`
      added to `R/modPedigree.R`'s render chain, zero new package dependencies; live
      `shinytest2`/`chromote` confirmed the button genuinely functional (real PNG
      produced). See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 418/419.)
- [ ] (none remaining -- **issue #134** (verify inbreeding-loop/consanguinity
      rendering, priority 4, resolves plan Dragon P2 / `PROJECT_LEARNINGS.md`
      Learning 410) is RESOLVED: verified S453 (2026-08-02), audit-only. Confirmed
      against a real consanguineous case in the bundled E2E fixture (`GA204Z`,
      F=0.25) via live `shinytest2`/`chromote`: no duplicate/dropped node, 0
      console errors, legible diamond-shaped render. vis.js's hierarchical layout
      handles a real inbreeding loop correctly. See `CHANGELOG.md`.)
- [ ] (none remaining -- **issue #135** (hover tooltips + search/highlight,
      priority 5, resolves audit Recommendation #8) is RESOLVED: implemented and
      live-verified S454 (2026-08-02). Nodes gained an HTML hover-tooltip `title`
      field; the Diagram widget gained a "Select by id" search dropdown +
      hover-highlight (not click, to avoid the existing click-to-navigate
      handler). 10 new unit tests; live `shinytest2`/`chromote` confirmed the
      dropdown, tooltip, and highlight-on-change all genuinely functional. One
      accepted trade-off: a transient, benign `[shiny] Duplicate input IDs`
      console warning, owner-directed to accept rather than fix (`PROJECT_LEARNINGS.md`
      Learning 443). See `CHANGELOG.md`.)
- [ ] (none remaining -- **issue #139** (document the pedigree-diagram Diagram
      tab in the manual/tutorial, discovered S436 while triaging the #131-#138
      follow-ups) is RESOLVED: documented S455 (2026-08-02). Closed the doc-depth
      gap left by #131/#132/#135 each scoping their own doc update to one file --
      extended `_pedigree_browser.Rmd` (shape-to-sex legend) and
      `colony-manager-guide.qmd`'s "Diagram view" paragraph (click-to-navigate,
      node cap, PNG export, tooltip, search/highlight). Documentation-only, both
      rendered clean. See `CHANGELOG.md`.)
- [ ] (feasibility planning DONE -- S457, 2026-08-02, see
      `docs/planning/pedigree-diagram-mating-lines-plan.md`. **Pedigree Diagram
      tab does not visually indicate mating/couple relationships** (owner-observed
      S456, citing kinship2-convention references) -- confirmed empirically (3
      `visNetwork` POCs via `chromote`) that a true kinship2-style mate-line +
      sibship-bar convention is achievable inside the ratified visNetwork (D2)
      choice via invisible union/waypoint nodes with hand-computed coordinates.
      Owner ratified **Option 2 -- full kinship2-parity layout on visNetwork**
      via `AskUserQuestion`, over reopening D2/switching to kinship2 or a
      smaller partial-repositioning step. See `CHANGELOG.md`.)
- [ ] (design DONE -- S458, 2026-08-02, see
      `docs/planning/pedigree-diagram-option2-layout-design-plan.md`.
      **Pedigree Diagram: full kinship2-parity layout (Option 2 design
      session)** -- designed and owner-ratified a mating-unit/individual
      -duplication transformation (CraneFoot-derived) resolving
      crossing-minimization ordering, multi-mate/half-sib fan-out, and
      inbreeding-loop safety via one mechanism; a simplified
      Reingold-Tilford/Walker contour-merge algorithm (not an off-the-shelf
      package -- `igraph`/`ggraph` are GPL) computes final coordinates. Owner
      ratified via `AskUserQuestion` with one editorial direction:
      non-human-centric terminology (`sire`/`dam`/`mate`/`mating`). See
      `CHANGELOG.md`.)
- [ ] (none remaining -- **Pedigree Diagram: Option 2 implementation, Slice 1
      (mating-unit transformation)** is RESOLVED: implemented S459
      (2026-08-02). New internal `.buildMatingUnitForest()` in
      `R/makePedigreeDiagramData.R` (D1 mating-unit ID + re-parenting +
      duplicate-node creation, D2 deterministic anchor selection, D5
      partial-parentage fallback). Pre-RED found and corrected a real gap in
      the ratified design doc's own §7/§9 figures (a genuine anchor collision
      on the real fixture, corrected 130/742 -> the verified 128/740). 15 new
      unit tests; full clean regression 0 failed/0 error; `devtools::check()`
      0 new warnings/notes. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md`
      Learnings 449-450.)
- [ ] (none remaining -- **Pedigree Diagram: Option 2 implementation, Slice 2
      (D3 positioning algorithm)** is RESOLVED: implemented S460
      (2026-08-02). New internal `.positionMatingUnitForest(ped, forest)`
      assigns final `x`/`gen` coordinates via a simplified Reingold-Tilford/
      Walker-style recursive contour-merge (D3). Pre-RED prototyping found 3
      non-obvious gaps the ratified design didn't fully specify (free-pass
      node handling, gen-indexed vs. recursive-depth contour occupancy, a
      residual ~1.6% exact-coincidence edge case) -- all 3 owner-approved via
      `AskUserQuestion` before RED. 12 new unit tests; full clean regression
      0 failed/0 error; `devtools::check()` exact baseline match. See
      `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learnings 451-453.)
- [ ] (none remaining -- Pedigree Diagram: Option 2 implementation, Slice 3
      (render-chain wiring) is DONE -- S461 (2026-08-02). New exported
      `makePedigreeMatingLayout()` combines Slices 1/2; `R/modPedigree.R`'s
      render chain switched to it with fixed x/y (physics/smooth disabled).
      D6 integration: click-to-navigate resolves duplicate nodes to the real
      individual; search filtered to real ids; union nodes get a small dot +
      tooltip; mate-line edges render direct, with the fuller rectilinear
      style filed as deferred issue #142. Issue #138's node cap re-derived
      1,500 -> 750. **Live Phase 3E verification found and fixed a genuine
      crash** (`.buildMatingUnitForest()` threw on any pedigree with a
      dangling sire/dam reference, e.g. the "Trim pedigree based on focal
      animals" feature) -- root-caused in Slice 1's file, 6 new unit tests,
      re-verified live. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning
      457, design doc §9.)
- [x] **Duplicate-node connector renders straight, not arched, unlike the
      kinship2/standard-pedigree convention** (found S468 2026-08-03) --
      **RESOLVED -- S469 (2026-08-03):** owner observation vs. a reference
      pedigree image. `dupEdges` now carry a per-edge vis.js `smooth`
      override (curved, matching the referenced convention), surviving
      `edgeStyle = "rectilinear"` unchanged. Full TDD cycle; live
      `shinytest2`/`chromote` confirmed all 128 duplicate-connector edges
      arc correctly under both edge styles, 0 console errors. Analytically
      separate from issue #142's own edge-routing work, not folded in
      (`PROJECT_LEARNINGS.md` Learning 382). See `CHANGELOG.md`.
- [x] **Founder-positioning defect: a non-anchor parent occurrence renders at
      the wrong row, visually implying the wrong pairing** (found S463,
      characterized S470, designed S471, fixed S472) -- owner-observed on
      `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`'s
      Example 1 ("it appears 2 males have mated"). `.positionMatingUnitForest()`
      assigned a non-anchor occurrence's row from the parent's own global
      `gen` rather than its specific mating unit's `gen`
      (`R/makePedigreeDiagramData.R:585-591`) -- independent of issue #142's
      edge-routing work. **S470 audit** confirmed 147 of 237 real-fixture
      mating units (62%) mis-positioned; filed as
      [issue #143](https://github.com/rmsharp/nprcgenekeepr/issues/143).
      **S471 design/S472 fix:** a synchronized point-patch (`.positionMatingUnitForest()`
      only) resolves 96 of 147 (65%) -- non-anchor mismatches; planning found
      the remaining 51 (22%) are ANCHOR-side mismatches the fix's own detection
      couldn't distinguish, tracked separately as issue #144 below. Full
      regression 0 failed/0 error; `devtools::check()` 0 new errors/warnings;
      live `shinytest2` re-verified previously-mismatched units now render
      on-row. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 470.
- [x] **Pedigree Diagram: anchor-side row mismatches -- 51 of 237 real-fixture
      mating units (22%), distinct from issue #143's non-anchor fix** (found
      S471, filed as [issue #144](https://github.com/rmsharp/nprcgenekeepr/issues/144))
      -- **planning DONE -- S473; implemented -- S474 (2026-08-04):** the
      standing assumption that this needed restructuring
      `.positionMatingUnitForest()`'s recursion turned out FALSE (`PROJECT_LEARNINGS.md`
      Learning 471) -- corrected with the same narrow `dispGenOf`-override
      pattern #143 used (~11 lines, 3 synchronized edits). Full RED/GREEN/REFACTOR
      TDD cycle, full regression + `devtools::check()` + live `shinytest2`
      verification all clean; 0 non-anchor + 0 anchor mismatches remaining.
      See `CHANGELOG.md`.

**Sequencing note (S480, 2026-08-08):** the items below through the `highlightNearest` degree=6
item, plus GitHub issues #133/#136/#137/#138/#141/#145, were jointly examined for implementation
order in `docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md` (kinship2-capability-
and nomenclature-reference-informed). Recommended order: (1) the two dangling-parent crash bugs
below + the free-pass-filter reachability check, (2) issue #145's verification spike, (3) refresh
the stale `.qmd` comparison doc below, (4) the owner's existing #133 > #136 > #137 > #138 order, (5)
#141 and Candidate C stay deferred pending new evidence/owner sign-off.

**Tier 1 -- DONE (S481, S482, S484):** the 2 dangling-parent crash bugs + the free-pass-filter
reachability check were filed and fixed as issue #154 (S481). Issue #145's verification spike (S482,
`docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`) empirically confirmed
(kinship2 v1.9.6.2 source read + 5 synthetic-pedigree tests, not inferred from docs) that kinship2
implements **neither** a hard male-left invariant **nor** a sex-aware crossing-minimizing default --
once an individual has multiple mates, left/right is decided purely by pedigree-data discovery order;
the issue's own cited sources were found unreliable on this point. `docs/planning/pedigree-diagram-
kinship2-reference-comparison.qmd` was refreshed (S484) to reflect issues #143/#144's fixes and to
add a new Example 4 reproducing S482's own kinship2 counter-example directly (`quarto render` clean,
37 chunks).

**Tier 2 -- DONE (S485-S494, S499-S500): issues #133, #136, #137, and #145 are all now fully
implemented and closed.** Each followed design-document ratification (`AskUserQuestion`-gated
judgment calls) then 1-3 implementation slices, each slice a full strict-TDD PRE-RED->RED->GREEN
(->REFACTOR) cycle with clean regression + `devtools::check()` + live `shinytest2`/`chromote`
verification, plus the citation/tutorial/`NEWS.Rmd`/`a2interactive.Rmd` documentation checklists
applied per-slice:
- **Issue #133** (affected/phenotype status): design S485 (`docs/planning/issue133-affected-status-
  pedigree-diagram-plan.md` -- new `affected` logical column, `color.background` + tooltip, no new
  dependency). Slice 1 (data model + rendering) S486 -- found and fixed a gap where the rectilinear
  edge style would have silently erased the new coloring. Slice 2 (legend + docs) S487. **Closed
  S487.**
- **Issue #136** (name labels): design S488 (`docs/planning/issue136-name-labels-pedigree-diagram-
  plan.md` -- corrected 3 premises in the issue itself; found and closed a disclosure defect,
  `obfuscatePed()` would have left `name` unscrubbed). Slice 1 (data model + de-identification) S489.
  Slice 2 (label rendering + off-by-default toggle + docs) S490 -- found and fixed a real
  toggle-discarded-on-rerender defect via live verification (`PROJECT_LEARNINGS.md` Learning 490).
  **Closed S490.**
- **Issue #137** (twin/zygosity encoding): design S491 (`docs/planning/issue137-twin-zygosity-
  pedigree-diagram-plan.md` -- new sidecar `twinRelations` table, zero schema.R changes; a
  workflow-truncation tooling defect found and worked around, `PROJECT_LEARNINGS.md` Learning 491).
  Slice 1 (data model + de-identification, `checkTwinRelations()`/`obfuscateTwinRelations()`) S492.
  Slice 2 (core rendering, MZ/DZ/UZ connector styles) S493. Slice 3 (UI wiring, legend, docs) S494 --
  found and filed (not fixed) a Slice 2 color-wiring gap as its own Housekeeping item. **Closed
  S494.**
- **Issue #145** (sire/dam left-right placement, deferred from Tier 1's spike): design S499
  (`docs/planning/issue145-sire-dam-left-right-placement-plan.md` -- a 3-agent adversarial review
  refuted the first proposed mechanism, `orderBySex = TRUE` parameter ratified instead). Slice 1
  (core positioning) S500. **Closed S500** for the ratified simple-pair scope.

**Issue #138** (full-colony rendering beyond the 1,500-node cap) is the one item in the owner's Tier 2
order this cluster did not reach -- still open, tracked as its own GitHub issue (`low priority`
label), needing its own scoping session first, matching #133/#136/#137/#145's own precedent. See
`CHANGELOG.md` for the full session-by-session record and `PROJECT_LEARNINGS.md` Learnings 485,
488-499 for the individual technical findings.
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
- [ ] (none remaining -- **the `.positionMatingUnitForest()` free-pass-filter
      reachability question is CLOSED, not fixed** -- S481 (2026-08-08):
      investigated with 2 targeted fixtures, neither reproduced a missing/
      duplicate node; structurally, no real individual is ever lost regardless
      of free-pass status. See `CHANGELOG.md` and issue #154's own closing note.)
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

**Progress (S495, 2026-08-09):** Tier 1's own Pre-RED design/scoping session for issue #147
(likelihood-based candidate-parent assignment after marker parentage exclusion) is DONE and RATIFIED:
see `docs/planning/issue147-likelihood-parentage-assignment-plan.md`. A 4-agent research `Workflow`
(3 independent literature angles -- CERVUS/LOD-score methods, COLONY/sibship-reconstruction methods,
captive-primate-colony-specific precedent -- plus an adversarial synthesis pass) run alongside a
separate codebase-inventory `Explore` agent, both spot-checked against source before use (`PROJECT_
LEARNINGS.md` Learning 494). Central finding: CERVUS-style multilocus likelihood-ratio (LOD) scoring
(Meagher & Thompson 1986; Marshall, Slate, Kruuk & Pemberton 1998) is the field's own answer to this
exact problem shape, independently validated as the captive-primate-colony domain's de facto standard
by de Groot et al. (2025) -- already cited in this package's `markerParentageExclusion()`; full-pedigree
reconstruction (COLONY/FRANz) was found to solve a different, harder problem and was ruled out. The
adversarial synthesis pass, explicitly stress-tested against this package's own realistic 2-10-locus
panel sizes, found this range sits inside the literature's own documented underpowered zone and that a
full/half sibling of the true parent can plausibly outrank it at small panel sizes -- both load-bearing
findings drove the plan's no-percentage-confidence (raw LOD+delta+coverage only) and minimum-loci-gate
design decisions. Ten design decisions (D1-D10); four genuine judgment calls (LOD-formula scope,
minimum-loci-gate mechanism, report-only-vs-write-back architecture, UI integration shape) all ratified
via a single `AskUserQuestion` round -- owner selected this document's own recommended option in all
four cases: no-error-model formula now (error-tolerant extension deferred, pending an unretrievable
2010 corrigendum); a fixed, literature-informed `minLoci` default; **report-only** (this package has
zero existing pedigree-mutation precedent, confirmed by a full grep sweep -- any future write-back is
its own separately-gated issue); and a 5th read-only "Candidate Parent Assignment" tab in
`modMarkerGenetics.R`, matching the existing 4-tab pattern. Implementation plan is 2 vertical slices
(core statistical function; UI + documentation), each its own future session. No code changed this
session -- design/planning only, matching the #133/#136/#137 precedent. See `CHANGELOG.md`.

**Progress (S496, 2026-08-09):** Slice 1 (core statistical function) is now DONE: new exported
`markerParentageLikelihood()` (`R/markerParentageLikelihood.R`), ranking candidate replacement
parents via the ratified CERVUS-style LOD score; `.markerAlleleFrequencyTable()` (D9); the D7
extraction of `markerParentageExclusion()`'s opposite-homozygote comparison into a shared
`.markerOppositeHomozygoteCount()` helper, byte-identical-behavior proven via a golden-master
regression test. Full strict TDD PRE-RED->RED->GREEN->REFACTOR cycle, `AskUserQuestion`-gated at
every transition; Pre-RED independently re-derived and hand-verified the LOD formula from first
principles before any RED test was written. Verified: all new/changed tests pass; full clean
regression read 0 failed/0 error (4841 passed, 175 skipped, 10 pre-existing baseline warnings
unchanged); `devtools::check()` 2 ERRORs/1 WARNING/1 NOTE, exact pre-existing baseline match, 0 new;
`lintr::lint_package()` 0 lints. **Slice 2 (UI + documentation) is the natural next pickup for this
issue** -- a separate future session, per the plan's own session-boundary requirement. See
`CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learnings 495-496.
(Issue #147's Slice 2 was completed and the issue closed -- S498, 2026-08-09; see `CHANGELOG.md`.)

**Progress (S503, 2026-08-10):** Tier 2 step 1 -- issue #149's own design/architecture document
(reviewed cross-center identity-mapping workflow with provenance export, a Shiny wrapper around the
existing `resolveCrossCenterIds()`) -- is DONE and RATIFIED: see
`docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md`. Ten design decisions
(D1-D10); a same-session, 2-agent adversarial review (correctness-vs-source; completeness/house-style
against the #147/#137 precedent) found and fixed one significant, previously-unaddressed technical
defect (`resolveCrossCenterIds()`'s merge step silently drops every non-`id`/`sire`/`dam` column for
merged individuals, about to become curator-visible for the first time via the new CSV export -- now
D10) and one design-consistency gap (the extracted conflict-check helper's row lookup silently
depends on a `pedB` id-rewrite step the first draft never made explicit -- now fixed in D2, with a
new Dragon). Four genuine judgment calls (D2 validation-extraction mechanism, D3 scope boundary, D8
export-artifact set, D10 whether to fix the newly-found data-loss now) ratified via a single
`AskUserQuestion` round -- owner selected this document's own recommended option in all four cases,
no changes requested. **Issue #149 stays open** -- design/planning only, matching the
#133/#136/#137/#145/#147 precedent; a 2-slice implementation (Slice 1: validation core + the D10 data
-loss fix, R-function level only; Slice 2: full UI, confirm gate, exports, documentation) is the
natural next pickup, each its own future session. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md`
Learning 502.

**Progress (S504, 2026-08-10):** Slice 1 (validation core, R-function level only, no UI) is now DONE:
new exported `checkCrossCenterMapping(pedA, pedB, mapping)` (`R/checkCrossCenterMapping.R`), the D2
two-tier collect-all validator sharing `resolveCrossCenterIds()`'s four checks via 8 new shared
internal helpers extracted from it (`.requireCrossCenterPedColumns`/`.requireCrossCenterMappingColumns`/
`.checkCrossCenterUniqueness`/`.checkCrossCenterExistenceA`/`.checkCrossCenterExistenceB`/
`.checkCrossCenterCollision`/`.checkCrossCenterConflict`/`.rewriteCrossCenterIds`/
`.pickCrossCenterParent`). `resolveCrossCenterIds()` itself calls these in its original exact order,
keeping its own historical `stop()` message text byte-for-byte (proven via a new golden-master test);
all 7 pre-existing test blocks pass unmodified. The D10 data-loss fix also shipped in this slice:
a merged pair's other shared, agreeing columns (e.g. `sex`) now survive the merge under the same
prefer-non-`NA`/error-on-conflict rule already used for `sire`/`dam`, instead of being silently
dropped -- an explicit, `NEWS.Rmd`-documented additive behavior change (a merge that previously
succeeded silently on a disagreeing non-`sire`/`dam` column now raises a conflict error). Full strict
TDD PRE-RED->RED->GREEN cycle (`AskUserQuestion`-gated at every transition; REFACTOR owner-confirmed
skip -- implementation already matches the ratified design's own decomposition). Dragon #2 (the `pedB`
id-rewrite must run before the conflict check's row lookup, or it silently reports zero conflicts) has
its own dedicated regression test injecting a real conflict and confirming it is actually reported.
10 new test blocks (9 in new `tests/testthat/test_checkCrossCenterMapping.R`, 3 appended to
`tests/testthat/test_resolveCrossCenterIds.R`), 0 regressions. Verified: full clean regression suite 0
failed/0 error (4951 passed, 175 skipped); `lintr::lint_package()` 0 lints on touched files;
`devtools::check()` 0 errors/0 warnings/1 pre-existing note (vignette-engine, unchanged);
`_pkgdown.yml` reference-coverage entry added for `checkCrossCenterMapping` (this actually caught the
gap live -- `test_pkgdown_reference_config.R` failed until fixed); `NEWS.Rmd` entry added and
re-rendered clean. `runtime_smoke: n/a` -- confirmed via `grep` that neither function has any call
site in the live Shiny app yet (Slice 2 wires them in); script-callable only, matching the
`resolveCrossCenterIds()` Slice 4 precedent. **Incidental finding, not fixed (out of this slice's
scope):** the "10 pre-existing baseline warnings" Housekeeping item below has silently drifted to 15
(a 3rd `test_modMarkerGenetics.R` cross-center-shaped test block now also triggers the same
`markerKinship()` NA-warning pattern) -- confirmed pre-existing via a `git stash` comparison against
unmodified `HEAD`, unrelated to this session's diff; that item's own count corrected below. See
`CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 503.

**Progress (S505, 2026-08-10):** Slice 2 (full UI, confirm gate, exports, documentation) is now
DONE, closing issue #149: new `R/modCrossCenterIdentity.R`
(`modCrossCenterIdentityUI`/`modCrossCenterIdentityServer`) -- 3 file uploads, a
`checkCrossCenterMapping()`-backed Validation tab showing every issue at once, a Preview tab
computing `resolveCrossCenterIds()`'s proposed merge with a per-pair lineage-change table (2 new
internal helpers, `.buildCrossCenterLineagePreview()`/`.buildCrossCenterMergeProvenance()`), a
`shiny::modalDialog()` confirmation gate (this app's first-ever use of the function), and 5
downloadable export artifacts. Wired additively into `appUI.R`/`appServer.R` (self-contained, no
`shared$...` dependency, per D3). Full strict TDD PRE-RED->RED->GREEN cycle
(`AskUserQuestion`-gated at every transition; REFACTOR owner-confirmed skip -- implementation
already matches the ratified design's own decomposition). 17 new test blocks, 0 regressions;
full clean regression suite 0 failed/0 error (5026 passed, 175 skipped, 15 pre-existing warnings
unchanged); `lintr::lint_package()` 0 lints; `devtools::check()` 0 errors/0 warnings/pre-existing
notes only (a new spelling-drift word from this session's own roxygen was caught and fixed by
rewording, not left for `inst/WORDLIST`). **Live `shinytest2` smoke test** against the real running
app directly confirmed both of the plan's named highest-risk Dragons: #6 (`modalDialog()` renders
correctly under this app's previously-untested bslib theme) and #7 (the Preview table's `NA` cells
render as blank text, read via `app$get_js()` cell traversal, not assumed) -- zero `SEVERE` console
entries throughout the full upload -> validate -> preview -> confirm -> export sequence.
Documentation: `NEWS.Rmd`/`NEWS.md`, `_pkgdown.yml` reference-coverage, and a new "Cross-Center
Identity" subsection in `colony-manager-guide.qmd` (text-only, re-rendered clean via `quarto
render`) all done same-session; `a2interactive.Rmd` coverage explicitly deferred per its own
standing rule. **Both slices of issue #149 are now shipped; issue #149 itself is closed as part of
this session's close-out.** See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 504.

**Progress (S507, 2026-08-10):** Tier 2 step 2 -- issue #146's design/architecture document -- is
DONE and RATIFIED: see
`docs/planning/issue146-configurable-exhaustive-breeding-group-retention-plan.md`. Splits the
issue into 2 slices matching the sequencing audit's own recommendation: **Slice 1** (parameterize
`groupAddAssign()`'s hardcoded top-5 candidate-retention cap into a `maxCandidates` argument --
mechanical, Effort S) and **Slice 2** (a new bounded exhaustive-enumeration mode -- genuinely new
combinatorial-search algorithm work, Effort M-L). Owner ratified 4 judgment-call decisions in a
single `AskUserQuestion` round, selecting this document's own recommended option in all 4 cases:
exhaustive mode scoped to `numGp==1`/no harem/no custom sex ratio only, `stop()` (not silent
fallback) outside that scope or over the feasibility ceiling; a hand-rolled Bron-Kerbosch-style
maximal-independent-set enumerator (no new `igraph` dependency), citing Bron & Kerbosch (1973) /
Tomita, Tanaka & Takahashi (2006); feasibility-guard defaults `maxExhaustiveCandidates = 20L` /
`exhaustiveTimeLimit = 10` seconds; and the UI toggle ships in Slice 2 itself, not deferred to a
Slice 3. The design decisions are grounded in an original empirical benchmark run this session (not
derived from any prior document): a throwaway, un-pivoted Bron-Kerbosch enumerator timed against
synthetic conflict graphs found a counter-intuitive result -- **lower-kinship (more diverse)
candidate pools are the slower case for exhaustive enumeration, not the faster one** -- n=20 at 5%
density took 5.5s; n=25 at 5% density exceeded 60s, both in an unoptimized baseline implementation.
Also confirmed the real `qcBreeders` test fixture (29 candidates, `numGp=2`) already produces 1000
distinct partitions across 1000 random trials -- direct in-repo evidence that exhaustive
enumeration is intractable beyond `numGp=1` at realistic scale, forcing the single-group scope
decision. No code changed this session -- design/planning only, matching the #133/#136/#137/#147/
#149 precedent. **Next session in this cluster implements Slice 1** (the mechanical
`maxCandidates` parameterization); Slice 2 (exhaustive enumeration + UI) is its own separate
session per §5's session-boundary requirement. Issue #146 intentionally left open. See
`CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 506.

**Progress (S508, 2026-08-10):** Slice 1 (mechanical `maxCandidates` parameterization) is now DONE:
`groupAddAssign()`'s previously-hardcoded `5L` candidate-retention cap (`R/groupAddAssign.R:200`,
the only literal site) is now a `maxCandidates = 5L` argument; `R/modBreedingGroups.R` gained a
matching **Candidates to retain** numeric input (default 5, 1-50 per D6) threaded through
`runFormation()`'s existing defensive-default pattern. Full strict TDD PRE-RED->RED->GREEN cycle
(`AskUserQuestion`-gated at every transition; REFACTOR owner-confirmed skip -- implementation
already minimal/mechanical). 5 new tests: 2 direct `groupAddAssign()` tests (real `qcBreeders`
fixture, lowered to 3 and raised to 8, proving the old hardcode is gone in both directions), 1
UI-control-presence test, and 2 `testServer` tests against the real (unmocked) `modBreedingGroupsServer`
reactive code -- only the terminal `groupAddAssign()` call itself mocked -- proving `input$maxCandidates`
reaches the real argument at both the unset-default and an explicit value. (The first attempt at the
default-case test passed vacuously before any server change, since the mock's own default happened to
also be 5L; caught and fixed with a sentinel default before treating RED as satisfied.) Verified: full
clean regression suite 0 failed/0 error (5050 passed, 175 skipped, 15 pre-existing baseline warnings
unchanged); `lintr::lint_package()` 0 lints; `devtools::check()` 0 errors/0 warnings/1 pre-existing
note (vignette-engine, unchanged). **Live `shinytest2` smoke test:** the new control renders with the
correct default (5) on a fresh app load with 0 console errors; a live run with `maxCandidates=1`
consistently and correctly caps the rendered candidate dropdown to exactly 1 option (3/3 runs).
**Incidental, out-of-scope finding, not investigated further:** attempts to also prove the "raise
above 5" half of the live differential live (via `maxCandidates=8`) were inconclusive -- the bundled
`obfuscated_rhesus_mhc_ped.csv` fixture converges to a single dominant maximal-set partition in the
live app across every combination tried (`numGp=1`/`numGp=2`, loose/strict kinship threshold,
`iter=100`), even though a direct (non-live) `groupAddAssign()` call using the same nominal parameters
against the same fixture (read via `qcStudbook()`/`kinship()` outside the app) reliably produces 8
distinct partitions. Not root-caused this session (matches the already-tracked, separately-filed "live
app's QC'd copy produces one fewer node than a direct CSV read" gap above -- plausibly the same
live-vs-direct pedigree-construction discrepancy, not confirmed). The parameter's correctness itself is
not in doubt -- proven independently by the 2 direct-function tests and the 2 real-server-code
`testServer` integration tests above, neither of which depends on this fixture's live diversity.
`NEWS.Rmd`/`NEWS.md` updated. Citation/tutorial-article/`_pkgdown.yml` checklists N/A per the ratified
plan's own §6/§9 (no new statistic, no new interaction pattern, `groupAddAssign` already listed).
`a2interactive.Rmd` coverage deferred per its own standing rule (new parameter on an already-documented
function). **Issue #146 stays open** -- Slice 2 (exhaustive enumeration + UI) is the natural next
pickup, its own future session per §5's session-boundary requirement. See `CHANGELOG.md`.

**Progress (S510, 2026-08-10):** Slice 2 (exhaustive enumeration mode + UI toggle) is now DONE:
`groupAddAssign()` gained `exhaustive`/`maxExhaustiveCandidates`/`exhaustiveTimeLimit` arguments; a
new `.enumerateMaximalIndependentSets()` helper implements the ratified hand-rolled Bron-Kerbosch
design (D4), scoped to `numGp=1`/no harem/no custom `sexRatio` (D2) with a two-layer feasibility
guard (D5) and named-reason `stop()`s (D9); `groupMembersReturn()` gained the D7 `exhaustive`/
`examined`/`retentionRule` fields, byte-identical-by-default for ordinary sampling calls. The
Breeding Group Formation tab gained the D8-ratified **Exhaustive enumeration mode** checkbox
(visible only when D2-eligible) and a status callout. Full strict TDD PRE-RED->RED->GREEN cycle. 11
new/extended test blocks across 4 files; full clean regression suite 0 failed/0 error (5081 passed,
175 skipped, 15 pre-existing baseline warnings unchanged); `lintr::lint_package()` 0 lints;
`devtools::check()` 0 errors/0 warnings/2 pre-existing notes (unrelated to this session). Live
`shinytest2`/`chromote` smoke test against the real running app confirmed the completed and hidden
(D2-ineligible) cases with real, correctly-computed status text; the truncated case was not
reproduced live (deadline not user-UI-configurable; already unit-tested), an explicit judgment call
the ratified plan itself grants. `NEWS.Rmd`/`NEWS.md` updated;
`vignettes/manual_components/_breeding_group_formation.Rmd` gained new coverage (text-only,
satisfying the tutorial/article checklist's "and/or" allowance). **Issue #146 is now fully
implemented across both slices; closed as part of this session's close-out.** See `CHANGELOG.md`.

**Progress (S511, 2026-08-10):** Tier 2 step 3 -- issue #151's design/architecture document
(individual mate-pair analysis alongside breeding-group optimization) is DONE and RATIFIED: see
`docs/planning/issue151-individual-mate-pair-analysis-plan.md`. **All of Tier 1/Tier 2's
ready-to-build items (#147/#149/#146/#151) now have ratified designs** -- #151's is the only one
not yet implemented. Direct reads of every function in the relevant call graph (not summarized
from memory) found the reusable pair-eligibility pipeline (`kinMatrix2LongForm()`/`filterPairs()`/
`filterAge()`/`filterThreshold()`) already lives entirely outside `R/modBreedingGroups.R` --
correcting the sequencing audit's own "shared-file risk" flag for this item -- and that
`modMarkerGeneticsServer()` already computes and returns a `markerKinshipMatrix` reactive that
`R/appServer.R` currently discards, so "marker kinship where available" is a one-line capture, not
new computation. An original empirical benchmark against the bundled `examplePedigree` (not
derived from any prior document) found an unscoped candidate-pair reshape produces 1,744,722 rows
in 54.0s, and that `filterAge()`'s NA-passes-the-filter semantics (81% of "alive" fixture
individuals have no recorded age) means the age control alone cannot bound table size -- directly
grounding the design's population-scope requirement. Also confirmed no continuous composite-score
ranking precedent exists anywhere in the package (`reportGV()`'s own `orderReport()` is a
rule-based tier classification, never a weighted formula), grounding the "raw sortable columns,
not an invented score" recommendation. Owner ratified 3 judgment-call decisions (ranking,
population-scope control, exclusion transparency) in a single `AskUserQuestion` round, selecting
this document's own recommended option in all 3 cases: raw sortable/filterable columns (no
composite score); a required population-scope radio control (mirroring Breeding Groups' own
`animalSource` convention) applied before the pair-reshape, plus server-side `DT` paging; and a
separate "Excluded" table with a `reason` column plus a user exclude-list textarea (mirroring
Breeding Groups' own "seed groups" convention). No code changed this session -- design/planning
only, matching the #133/#136/#137/#145/#147/#149/#146 precedent. **Next session in this cluster
implements Slice 1** (the core `reportMatePairs()` function, script-callable only); Slice 2 (UI +
`appServer.R` marker-kinship wiring + documentation) is its own separate session per §5's
session-boundary requirement. Issue #151 intentionally left open. See `CHANGELOG.md`.

**Progress (S512, 2026-08-10):** Issue #151 Slice 1 -- the core `reportMatePairs()` function
(new, exported, script-callable only, no UI) -- is DONE, per
`docs/planning/issue151-individual-mate-pair-analysis-plan.md` §5 Slice 1. Full strict TDD
PRE-RED->RED->GREEN->REFACTOR cycle, each transition `AskUserQuestion`-gated. Composes the
existing, unmodified pair-eligibility pipeline (`kinMatrix2LongForm()`/`filterPairs()`/
`filterAge()`/`filterKinMatrix()`) into opposite-sex, minimum-age-eligible mate pairs, each row
carrying pedigree kinship plus `NA`-safe marker-kinship and per-parent genetic-value context; a
closed-vocabulary `excluded` frame reports why a pair was dropped ("under minimum age" or
"user-excluded"). 8 new `test_that` blocks / 37 expectations in `tests/testthat/test_reportMatePairs.R`,
including a regression test directly reproducing the ratified plan's own Dragon #1 (`filterAge()`'s
NA-passes semantics means `minAge` alone cannot bound table size; the `populationIds` D4 control
is what actually does). Full clean regression suite 0 failed/0 error (5118 passed, 15 pre-existing
baseline warnings confirmed unchanged via `git stash -u` before/after); `lintr::lint_package()` 0
lints; `devtools::check()` 0 errors/0 warnings/1 pre-existing note (unrelated). Fixed 2 real gaps
found during verification: the `_pkgdown.yml` reference-coverage guard, and a `devtools::check()`
Rd cross-reference warning (a `\link{}` to `filterAge()`, a `@noRd` internal function with no `.Rd`
page). `NEWS.Rmd`/`NEWS.md` updated (new exported function checklist). **Issue #151 stays
open -- Slice 2** (`R/modMatePair.R` UI, the D6 `appServer.R` marker-kinship capture, `appUI.R`
tab mount, tutorial/article documentation, live `shinytest2` smoke test, `gh issue close 151`) **is
the next and final planned slice**, a separate future session per the plan's own session-boundary
requirement. See `CHANGELOG.md`.

**Progress (S513, 2026-08-10) -- Issue #151 fully shipped, closed:** Slice 2 -- the new
"Mate Pair Analysis" tab (`R/modMatePair.R`), the D6 `appServer.R` marker-kinship capture
(`modMarkerGeneticsServer()`'s previously-discarded `markerKinshipMatrix` return now reaches the
new module), `appUI.R` tab mount, and documentation -- is DONE, per
`docs/planning/issue151-individual-mate-pair-analysis-plan.md` §5 Slice 2, closing out the plan in
full. Full strict TDD PRE-RED->RED->GREEN->REFACTOR cycle, each transition `AskUserQuestion`-gated.
Along the way, found and fixed a genuine pre-existing bug in Slice 1's own `R/reportMatePairs.R`
(bare scalar column assignment crashed when the age filter alone reduced the candidate table to
exactly 0 rows -- fixed with its own regression test, surfaced to the owner first since it was
outside the approved GREEN scope) and 2 guard-test regressions only a full regression read
surfaces (`_pkgdown.yml` reference coverage; `shinytest2.yaml` E2E group-regex coverage). Full
clean regression 0 failed/0 error (5172 passed, 15 pre-existing warnings unchanged);
`devtools::check()` 0 errors/0 warnings/1 pre-existing note; `lintr` 0 lints on touched files. A
**live E2E smoke test** (new, opt-in `tests/testthat/test-e2e-mate-pair-analysis-module.R`) ran
against the real app: 8/8 assertions passed, including live proof of the D6 wiring (a real,
non-`NA` marker-kinship value reaching the new tab) and confirmation Marker Genetics itself still
renders correctly post-change. `NEWS.Rmd`/`NEWS.md`, a new "Mate Pair Analysis" section in
`vignettes/articles/colony-manager-guide.qmd` with 2 new live-captured screenshots, and
`_pkgdown.yml` reference coverage all done same-session. **Issue #151 closed.** See `CHANGELOG.md`,
`PROJECT_LEARNINGS.md` Learnings 513-514.

**This cluster (issue #151, all slices) is now fully complete.** No further items remain in this
narrative.

**Progress (S514, 2026-08-10):** Tier 3 (policy-gated quick win) -- issue #150's own owner policy
decision and design/architecture document (de-identified pedigree export workflow for approved data
sharing) -- is DONE and RATIFIED: see
`docs/planning/issue150-deidentified-pedigree-export-plan.md`. Put the sequencing audit's own
Finding #3 policy question to the owner via `AskUserQuestion` before any technical research (its own
recommendation, verbatim); owner answered yes, formalize it. Found and empirically verified (seeded
`Rscript` against the bundled `pedGood` fixture, 25% hit rate) a real, previously-unflagged defect:
`obfuscatePed()` shifts each Date column independently, which can invert an individual's birth/exit
order and produce a negative recomputed age. Ten design decisions (D1-D10); four genuine judgment
calls (fix the date defect now via a new `linkedDateShift` parameter defaulting `TRUE`; explicit
institutional-responsibility warning text; disclose rather than scrub non-id/date fields; tab
placement after Cross-Center Identity) ratified via a single `AskUserQuestion` round -- owner
selected the recommended option in all four. Implementation plan is 2 vertical slices (core function
work; full UI module + documentation), each its own future session. No code changed this session --
design/planning only, matching the #133/#136/#137/#145/#146/#147/#149/#151 precedent. Issue #150
stays intentionally open. See `CHANGELOG.md`. *(Note: this progress note was written retroactively by
S515, reconstructed from `CHANGELOG.md`/`HANDOFFS.md` -- S514's own close-out did not append one here,
unlike every other design-session precedent in this cluster, S495/S503/S511. Flagged, not silently
skipped; see `PROJECT_LEARNINGS.md` Learning 516.)*

**Progress (S515, 2026-08-10):** Slice 1 (core function work, R-function level only, no UI) is now
DONE: `obfuscatePed()` gained a `linkedDateShift` parameter (default `TRUE`, D3) that draws exactly
one random offset per individual and applies it to every Date column for that row, closing the S514
negative-age defect while preserving each individual's exact inter-date gaps (proven by an invariance
assertion, not just a bounds check); `linkedDateShift = FALSE` reproduces the old independent-per-
column behavior for any caller that needs it. New internal `.buildDeidentificationManifest()` helper
(`R/modDeidentifiedExport.R`, D4) mirrors `.buildCrossCenterMergeProvenance()`'s shape. Full strict
TDD PRE-RED->RED->GREEN->REFACTOR cycle (REFACTOR: owner-confirmed no candidate identified), each
transition `AskUserQuestion`-gated. Along the way, found and fixed a genuine order-dependence defect
in this session's own RED tests: a bare `set.seed()` call is silently order-dependent in this test
suite because this package's own `set_seed()` helper (used throughout for cross-R-version RNG
parity) permanently changes `RNGkind(sample.kind = "Rounding")` for the rest of the testthat
session -- switched to `set_seed()`, matching every other test file's convention, and re-derived a
seed that reproduces the defect deterministically under that RNGkind regardless of run order
(verified via a perturb-then-rerun check, not assumed). Full clean regression 0 failed/0 error (5186
passed, 15 pre-existing warnings unchanged); `devtools::check()` 0 errors/0 warnings/1 pre-existing
note (confirmed unrelated via a `git stash -u` baseline check); `lintr::lint_package()` 0 lints on
touched files. `NEWS.Rmd`/`NEWS.md` entry done. **Slice 2 (full UI module, confirm gate, exports,
documentation) is the natural next pickup for this issue** -- a separate future session, per the
plan's own session-boundary requirement. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 516.

**Progress (S516, 2026-08-10) -- Issue #150 fully shipped, closed:** Slice 2 (full UI module, confirm
gate, exports, documentation) is now DONE, closing out the plan in full. New **De-Identified Export**
Shiny module (`R/modDeidentifiedExport.R`): `modDeidentifiedExportUI`/`modDeidentifiedExportServer`
(D1: reads `shared$currentPedigree`, no fresh upload) -- Configure & Preview tab (config controls,
live preview, static D6 warning text) plus an Export tab gated by a `modalDialog()` confirm (mirrors
`modCrossCenterIdentityServer`'s own shape) with 3 downloads (de-identified pedigree, D4 manifest, D5
"DO NOT SHARE" re-identification key). Two forced correctness requirements found at Pre-RED (same
category as the plan's own D1/D2/D4/D5/D7/D9, not owner judgment calls): the manifest snapshots the
exact params used at Generate-Preview time rather than re-reading live input state (prevents a
curator's post-preview slider tweak from producing a manifest that describes different params than
what was actually exported); regenerating the preview resets `confirmed` to `FALSE` (mirrors #149's
own D5 stale-confirmation-reset pattern). Downloads are not hard-gated on `confirmed`, matching Cross-
Center Identity's own precedent exactly (this issue's own ratified framing: a confirmation dialog and
warning text, not real access control). Wired into `appUI.R`/`appServer.R` (D10 tab placement after
Cross-Center Identity). Full strict TDD PRE-RED->RED->GREEN->REFACTOR cycle, each transition
`AskUserQuestion`-gated; REFACTOR: no candidate identified. 16 new test blocks, 0 regressions. Full
clean regression 0 failed/0 error (5233 passed, was 5186, 15 pre-existing warnings unchanged);
`devtools::check()` 0 errors/0 warnings/1 pre-existing NOTE (confirmed byte-identical to unmodified
`HEAD` via `git stash -u` before/after -- including the raw-log spelling-diff NOTE, a pre-existing
environment quirk); `lintr::lint_package()` 0 lints on touched files (fixed 3 style lints);
`_pkgdown.yml` reference-coverage gap caught live by its own guard test, fixed. **Live smoke test**
(ad hoc script, no permanent E2E file added, matching the #149 precedent) drove the real running app
end to end -- Input -> De-Identified Export -> Generate Preview -> Confirm Export modal -> Export tab
-- 0 console errors; a first unscoped `a[data-value='Export']` click selector warned of multiple
matches (Cross-Center Identity also has an "Export" tab) and was fixed to a module-scoped selector
before trusting the result. `NEWS.Rmd`/`NEWS.md` and a new "De-Identified Export" `colony-manager-
guide.qmd` subsection (text-only, matching Cross-Center Identity's own no-screenshot convention) done
same-session, re-rendered clean. `a2interactive.Rmd` deferred per its own standing rule. **Both slices
of issue #150 are now shipped; issue #150 closed** as part of this session's close-out. See
`CHANGELOG.md`.

**This cluster (issue #150, all slices) is now fully complete.** No further items remain in this
narrative.

**Progress (S519, 2026-08-11):** the Deferred/scientific tier's second item -- issue #153's own
design/architecture document (linkage-aware and haplotype-block metrics for marker data) -- is DONE
and RATIFIED: see `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md`. Two parallel
background research agents (codebase inventory: confirmed no marker function treats loci as
ordered/positioned, and confirmed `checkMarkerGenotypeFile()` hard-rejects multiallelic loci;
domain research: locus-order metadata realism, rhesus genetic-map resources, classical LD/
haplotype-block methods, CRAN package survey, recombination-aware kinship literature,
coverage-reporting precedent, privacy implications) plus direct re-verification of the two most
load-bearing findings (`R/checkMarkerGenotypeFile.R:68-78`'s biallelic-only rejection; #152's D3/D4
decisions verbatim). Central findings: a directly-sourced real captive-macaque-colony STR panel (de
Groot et al. 2025, 23 microsatellite markers) has essentially no cM genetic-map data and is
multiallelic -- both facts collide with this package's current assumptions (loci currently
unordered/unpositioned everywhere; ingestion hard-rejects >2-allele loci); every classical LD/
haplotype-block method assumes an unrelated/randomly-mating sample, which a pedigreed colony
violates (Excoffier & Slatkin 1998), while the one genuinely pedigree-native method (Lander-Green
multipoint IBD / MERLIN) isn't CRAN-available; haplotype/block-level exports are MORE
re-identifying than single-locus data, not less (Lin, Owen & Altman 2004; Erlich & Narayanan 2014).
Nine design decisions (D1-D9); four genuine judgment calls (D3 metric choice, D4 multiallelic
ingestion, D5 module boundary, D8 CRAN-vs-hand-roll) ratified via a single `AskUserQuestion` round
-- owner selected this document's own recommended option in all four: build both a pedigree-valid
primary metric (Hill & Weir 2011-style realized-relatedness variance) and a caveated descriptive
secondary metric (pairwise D'/r², same-chromosome pairs only); add a new multiallelic-tolerant
sibling ingestion validator rather than reuse the existing biallelic-only path; a new tab inside the
existing `modMarkerGenetics.R`, not a dedicated new module; hand-roll the D'/r² computation in base
R rather than add a CRAN dependency. Scoped as 5 future vertical slices (locus-metadata ingestion +
STR fixture; multiallelic-tolerant ingestion path; the realized-relatedness-variance metric,
requiring its own literature deep-dive first; the descriptive LD statistic + de-identification
primitive; full module tab + documentation), each its own future session. No code changed this
session -- design/planning only, matching the #133/#136/#137/#145/#146/#147/#149/#150/#151/#152
precedent. Issue #153 intentionally left open. **Next in the ratified Deferred-tier order: #148
(MHC haplotype-specific frequency reporting) still needs its own scope-narrowing conversation first,
per the sequencing audit's Finding #4, before a design document analogous to this one and #152's can
be written for it.** See `CHANGELOG.md`.

**Progress (S517, 2026-08-11):** the Deferred/scientific tier's first item -- issue #152's own
design/architecture document (whole-genome/whole-exome sequence input + sequence-based genetic
metrics) -- is DONE and RATIFIED: see
`docs/planning/issue152-sequence-input-genetic-metrics-plan.md`. Two parallel background research
agents (a codebase-inventory `Explore` agent; a domain-research `general-purpose` agent) plus direct
verification of the single most load-bearing prior decision (issue #130 plan's D2, the ratified
Bioconductor-Imports decline) grounded the design. Central findings: `markerKinship()`'s O(n²·L)
nested-pair loop and `markerParentageLikelihood()`'s O(F·C·L·n) redundant per-candidate
allele-frequency rescan are the real scale bottlenecks (independent of the biallelic-only question);
a directly-applicable captive-pedigreed-macaque-colony precedent (Bimber et al. 2016, ~22,455-marker
GBS panel + pedigree-aware imputation) grounds a realistic scope-tier ceiling; raw VCF ingestion is
infeasible on pure file-size grounds (144 GB-900 TiB class); summary statistics computed from
genotype data are not an automatic privacy safe-harbor (Homer et al. 2008), so any sequence-derived
export (raw or derived) must route through the same curator-controlled gate issue #150 already
shipped. Ten design decisions (D1-D10); four genuine judgment calls (D1 scope tier, D3
`locusMetadata` sidecar timing, D6 initial metric set, D8 module boundary) ratified via a single
`AskUserQuestion` round -- owner selected this document's own recommended option in all four:
sparse/GBS-scale tier (~50,000-locus ceiling, declining to reopen the Bioconductor decline); build
the `locusMetadata` (`locus, chrom, pos[, cM]`) sidecar now, as shared vocabulary for sibling issue
#153; genome-wide F_ROH (new, Ceballos et al. 2018) plus genome-scale reruns of the existing
kinship/heterozygosity/Fst functions, explicitly ceding effective-population-size-from-LD to #153; a
new tab inside the existing `modMarkerGenetics.R`, not a dedicated new module. Scoped as 5 future
vertical slices (ingestion+fixture; a required `markerKinship()`/`markerParentageLikelihood()`
performance rewrite; the new F_ROH metric; a new de-identification primitive; the full module tab +
documentation), each its own future session. No code changed this session -- design/planning only,
matching the #133/#136/#137/#145/#146/#147/#149/#150/#151 precedent. Issue #152 intentionally left
open. **Next in the ratified Deferred-tier order: #153 (linkage-aware/haplotype-block metrics), which
can now reuse this session's own `locusMetadata` vocabulary; #148 (MHC) still needs its own
scope-narrowing conversation first, per the sequencing audit's Finding #4.** See `CHANGELOG.md`.

**Progress (S520, 2026-08-11):** Issue #153 Slice 1 -- locus-metadata ingestion + coverage validator
+ a new multiallelic STR fixture -- is now DONE, per
`docs/planning/issue153-linkage-haplotype-block-metrics-plan.md` sec 5 Slice 1. Full strict TDD
PRE-RED->RED->GREEN->REFACTOR cycle, each transition `AskUserQuestion`-gated (REFACTOR:
owner-confirmed no candidate identified, matching the S515 precedent). New `checkLocusMetadata()`
(D7, this session authored the canonical validator since #152's own Slice 1 has not shipped yet --
sec 7 Dragon 1's own predicted ordering risk) validates a `locus, chrom, pos[, cM]` sidecar table
and classifies each locus into D2's literal three-tier coverage definition ("full" = chrom AND pos
present, cM optional; "partial" = exactly one of chrom/pos; "none" = neither), via a lookup-table
implementation (not nested `ifelse()`, `nested_ifelse_linter` clean). New
`data-raw/generate_str_fixtures.R` (mirrors `generate_twin_fixtures.R`'s fail-loudly-at-generation-
time discipline, `set_seed(153L)`) generates a 12-locus/8-chromosome/10-individual multiallelic STR
panel shaped on de Groot et al. 2025's real panel (not its literal data -- fully fabricated, sec 7
Dragon 2), 8 full/2 partial/2 none coverage loci, 2 genuinely multiallelic (3+ allele) loci --
committed as `inst/extdata/examples/example_locus_metadata.csv` /
`example_str_marker_genotypes.csv`, the package's first bundled long-format multiallelic marker
fixture at any scale (sec 2.8's confirmed gap). 10 new `test_that` blocks / 16 expectations in
`tests/testthat/test_checkLocusMetadata.R`, including a fixture-scale proof that the existing,
UNMODIFIED `buildMarkerGenotypeMatrix()` pivots multiallelic genotypes without error (D4's structural
claim, empirically confirmed -- the biallelic restriction lives entirely in
`checkMarkerGenotypeFile()`, deliberately not called on this fixture, matching Slice 2's own future
scope). Full clean regression suite 0 failed/0 error (5249 passed, 15 pre-existing warnings
unchanged); `devtools::check()` 0 errors/0 warnings/1 pre-existing note (unrelated, matching
baseline); `lintr::lint_package()` 0 lints on touched files (fixed 1 real `nested_ifelse_linter` +
several `implicit_integer_linter`/`line_length_linter` findings in `data-raw/
generate_str_fixtures.R`, matching this project's own house style). Fixed the `_pkgdown.yml`
reference-coverage guard (new exported function added to the "All exposed functions" catch-all
group). `NEWS.Rmd`/`NEWS.md` updated (new exported function checklist). Citation checklist (issue
#120) and tutorial/article checklist (Session 436) do NOT yet apply -- no UI/displayed statistic
this slice, matching the #146/#149/#150/#151 Slice-1-only precedent (verified via `git log` on
`population_genetics_terms.html`, last touched only by UI-shipping slices). **Issue #153 stays open
-- Slice 2 (the multiallelic-tolerant `checkLinkageMarkerGenotypeFile()` ingestion path, D4) is the
next planned slice**, a separate future session per the plan's own session-boundary requirement. See
`CHANGELOG.md`.

**Progress (S521, 2026-08-11):** Slice 2 (`checkLinkageMarkerGenotypeFile()`, D4) DONE. **Progress
(S522, 2026-08-11):** Slice 3 (`markerRealizedRelatednessVariance()`, the pedigree-valid
realized-relatedness-variance metric, D3a) DONE. **Progress (S523, 2026-08-11/12):** Slice 4
(`markerLdBlock()` + `obfuscateLdBlocks()`, the descriptive LD/block statistic and its
de-identification primitive, D3b/D8/D9) DONE. (Backfilled here at S524 close-out -- neither S521 nor
S522 nor S523 added their own narrative entry to this file, the gap `PROJECT_LEARNINGS.md` records as
this session's own finding; see `CHANGELOG.md` for each slice's own full, contemporaneous
close-out record.)

**Progress (S524, 2026-08-12):** Slice 5 -- full module tab, wiring, documentation -- is now DONE,
per `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md` sec 5 Slice 5. A sixth
"Linkage and LD Block Metrics" tab in `modMarkerGenetics.R` (D5, D6) wires in the locus-metadata
coverage report (`checkLocusMetadata()`, Slice 1), the primary realized-relatedness-variance table
(`markerRealizedRelatednessVariance()`, Slice 3), and the secondary LD-block table behind a
persistent, non-dismissable caveat banner (`markerLdBlock()`, Slice 4) -- plus curator-controlled
export wiring for the LD-block table reusing issue #150's confirm-gate pattern
(`obfuscateLdBlocks()`, D9). A dedicated `linkageGenotypeFile` upload, independent of the other five
tabs' shared `genotypeFile`, replaced the original PRE-RED plan to reuse that shared upload --
found empirically this session that Shiny renders every `tabPanel`'s output bindings regardless of
which tab is visible, so a multiallelic file fed through the shared input broke the other five tabs'
own DT outputs simultaneously (see `PROJECT_LEARNINGS.md`). Full strict TDD PRE-RED->RED->GREEN
cycle (REFACTOR: no candidate identified), 18 new `test_that` blocks / test_moduleContract.R updated
for 5 new returned reactives. Full clean regression 0 failed/0 error; `devtools::check()` 0
errors/0 warnings/2 pre-existing NOTEs; `lintr::lint_package()` 0 lints. Live runtime smoke test via
Chrome browser automation against the Slice 1 STR fixture confirmed the tab end to end (coverage
report, LD-block values matching the hand-verified reference exactly, the founders-only
restriction guard, the export confirm-gate's guidance states) -- see `CHANGELOG.md`. Tutorial/
article checklist (Session 436) applied for the first time in this issue family: new
`colony-manager-guide.qmd` "Linkage and LD Block Metrics" subsection with 2 new screenshots.
**This cluster (issue #153, all 5 slices) is now fully complete; issue #153 closed** as part of
this session's close-out. No further items remain in this narrative.

**Progress (S525, 2026-08-11):** Issue #152 Slice 1 -- sequence ingestion + fixture -- is now
DONE, per `docs/planning/issue152-sequence-input-genetic-metrics-plan.md` §5 Slice 1. Full strict
TDD PRE-RED->RED->GREEN cycle (REFACTOR: a real candidate was identified -- a 3rd copy of
`checkMarkerGenotypeFile()`'s structural-check logic -- but declined via `AskUserQuestion` as
out of this slice's pre-declared file scope, matching the S521-S524 precedent of deferring
cross-file refactors; noted for a future session). New `checkSequenceGenotypeFile()` (D2/D4):
same structural rules as `checkMarkerGenotypeFile()`, plus two new rules this design adds -- a
literal `"."` (VCF missing-genotype placeholder) allele value is rejected before the biallelic
count check runs (so the error is specific, not misleadingly "more than two alleles"), and a
locus count above a `maxLoci` parameter (default `50000L`, D1's scope-tier ceiling) triggers a
`warning()`, not a `stop()`. A genuine PRE-RED discovery: the plan's own §5 Slice 1 deliverable
"a new locusMetadata validation helper" (D3) was **already shipped** -- issue #153 Slice 1
(S520) built `checkLocusMetadata()` against this exact schema, crediting #152's own design
decision as its origin -- so this slice reuses it directly rather than reimplementing it.
Also, per PRE-RED `AskUserQuestion` (4 decisions, all recommended options chosen): returns the
checked dataframe (not `TRUE` invisibly, the plan's literal but since-superseded wording) to
match the actual 3-for-3 sibling-validator convention; `maxLoci` is a parameter, not a hardcoded
constant; the literal-`"."` case is a hard `stop()`, not a silent `NA` coercion. New
`data-raw/generate_sequence_fixtures.R` (seeded `set_seed(152L)`) generates a 50-individual x
1,000-locus synthetic biallelic SNP panel across 20 chromosomes with ~2% missingness, plus a
100%-"full"-coverage `locusMetadata` sidecar (deliberately not the sparse mix #153's own STR
fixture models -- this fixture's stated purpose is scale/performance exercise, Slice 2, and
reuse by the future F_ROH metric, Slice 3, which needs position data for every locus) --
committed as `inst/extdata/examples/example_sequence_genotypes.csv` /
`example_sequence_locus_metadata.csv`. 18 new `test_that` blocks, 0 regressions. Full clean
regression 5,408 passed/0 failed/0 error (17 pre-existing warnings, all traced to 4 unrelated,
already-known pre-existing test blocks); `devtools::check()` 0 errors/0 warnings/3 NOTEs, all 3
independently confirmed pre-existing (top-level files; vignettes/figure leftover; the known
~69-70-word spelling-WORDLIST gap -- direct diff confirmed zero flagged words trace to this
session's own new files); `lintr::lint_package()` 0 lints on touched files (1 line-length + 1
`stopifnot_all_linter` finding fixed). `_pkgdown.yml` reference-coverage guard fixed (new export
added to the "All exposed functions" catch-all group). `inst/WORDLIST` gained 5 new entries
(`GBS`, `VCF`, `VCF's`, `VCFtools`, `Danecek`) for this session's own new citation/vocabulary --
the Danecek et al. 2011 VCF citation was trimmed to first-author-plus-"et al." (matching this
codebase's own `MacCluer JW, et al.` precedent) rather than listing all ~12 co-authors, avoiding
4 additional WORDLIST entries for names with no other use in this package. `NEWS.Rmd`/`NEWS.md`
terse entry added (deliberately matching the pre-1.0.8 style this file's own flagged
verbosity-drift item, above, asks future entries to return to). Citation checklist (issue #120)
and tutorial/article checklist (Session 436) do NOT yet apply -- no UI/displayed statistic this
slice, matching the #146/#149/#150/#151/#153-Slice-1 precedent. Runtime smoke test: n/a --
script-callable only, no Shiny wiring this slice (matches the `resolveCrossCenterIds()` Slice 4
precedent). **Issue #152 stays open -- Slice 2 (the `markerKinship()`/
`markerParentageLikelihood()` performance rewrite, D5) is the next planned slice**, a separate
future session per the plan's own session-boundary requirement. See `CHANGELOG.md`.

**Progress (S526, 2026-08-11):** Issue #152 Slice 2 -- the `markerKinship()`/
`markerParentageLikelihood()` performance rewrite (D5) -- is now DONE, per
`docs/planning/issue152-sequence-input-genetic-metrics-plan.md` §5 Slice 2. Full strict TDD
PRE-RED->RED->GREEN cycle (REFACTOR: a real candidate was identified -- the
alphabetically-first-observed-allele-as-reference idiom now exists independently in 3 places
(`markerFst.R`, `markerParentageLikelihood.R`, the new `markerKinship.R`) -- declined via
`AskUserQuestion` as touching `markerFst.R`, outside this slice's pre-declared file scope,
matching the S521-S525 precedent). This slice is fundamentally a refactor (unchanged public
signatures/output), so PRE-RED's own `AskUserQuestion` round first resolved how RED applies:
golden-master regression tests (dput()-captured current output, `expect_identical()`) pass
immediately as a characterization safety net; two new precedent-setting `system.time()`
benchmark tests (no new dependency) are the slice's actual RED, gated at thresholds tighter
than this session's own measured current runtime on the committed Slice 1 fixture
(`markerKinship()` ~0.12-0.13s warm / 0.08s threshold; `markerParentageLikelihood()`
~0.84-0.88s warm / 0.5s threshold, explicit id/role/candidates call, no new fixture). A real
PRE-RED finding: a plain `dput()` does not always round-trip a double exactly (found
`-0.3` printing for an actual `-0.30000000000000004`) -- both golden-master literals use
`dput(x, control = c(..., "digits17"))` instead. `markerKinship()` rewritten as vectorized
matrix algebra (integer-count matrix products via `Hz`/`Gz`/`Z0`/`Z2` indicator matrices),
achieving ~0.07-0.09s (a ~2x speedup) while preserving the original's per-pair
undefined-kinship warning and ordering exactly. `markerParentageLikelihood()` rewritten to
precompute every locus's allele-frequency table once per call (was: once per
(offspring, candidate, locus) triple), achieving ~0.35-0.39s (a ~2.4x speedup) for the
10-candidate benchmark scenario. Both new benchmark tests include an untimed warm-up call
before timing -- PRE-RED found the naive (no-warm-up) version flakes between ~0.12s and
~0.26s depending on JIT warm-up state/test execution order -- plus the MEDIAN of 3 timed reps
rather than a single call, added after a single-call design still flaked once (system-noise
variance, not JIT) in a full `test_dir()` run despite passing 5/5 isolated `test_file()`
reruns (`markerKinship()`'s threshold loosened 0.08s -> 0.10s accordingly; both fixes are
`PROJECT_LEARNINGS.md` Learning 532's final form). 4 new `test_that` blocks (2
golden-master, 2 benchmark) across the 2 existing test files; 0 regressions. Full clean
regression 5,417 passed/0 failed/0 error (17 pre-existing warnings, unchanged), re-confirmed
clean across 2 further solo full-suite reruns after the median-of-3 fix;
`devtools::check()` 0 errors/0 warnings/3 NOTEs, all 3 confirmed pre-existing (top-level
files; vignettes/figure leftover; the known ~77-word spelling-WORDLIST gap, up from ~69-70 --
zero flagged words trace to this session's own touched files; note the 3rd NOTE does not
appear as its own `❯` bullet in `devtools::check()`'s printed summary, only in the raw
`Status:` line -- this session independently reproduced the exact undercounting risk
`BACKLOG.md`'s own S521 finding above already documents); `lintr::lint_package()` found and
fixed 9 `implicit_integer_linter` findings in the new `markerKinship.R` matrix-algebra code
(`0`/`2`/`4` -> `0L`/`2L`/`4L`), 0 lints remaining. `_pkgdown.yml` unaffected (no new export --
both functions already listed). `NEWS.Rmd`/`NEWS.md` terse entry added. Citation checklist
(issue #120) and tutorial/article checklist (Session 436) N/A -- no new/displayed statistic,
no UI change this slice. Runtime smoke test: n/a -- script-callable only, no Shiny wiring
touched this slice. **Issue #152 stays open -- Slice 3 (the new F_ROH metric,
`R/computeGenomicROH.R`, D6) is the next planned slice**, a separate future session per the
plan's own session-boundary requirement. See `CHANGELOG.md`.
