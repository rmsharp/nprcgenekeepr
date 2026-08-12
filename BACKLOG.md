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
      animal's parent slots are recorded" item (found S498, 2026-08-09,
      design ratified S501) is RESOLVED -- **implemented S502 (2026-08-10):**
      the ratified "shadow pedigree" fix
      (`docs/planning/issue155-parentage-likelihood-candidate-lookup-plan.md`
      §7) -- new internal `.markerFlaggedSlotPedigree()` helper in
      `R/markerParentageLikelihood.R`, wired into both `getPotentialParents()`
      call sites (auto-detect and the explicit `id`/`role`/
      `candidates = NULL` branch). **Zero changes to `getPotentialParents()`
      itself.** Full strict-TDD PRE-RED->RED->GREEN cycle
      (`AskUserQuestion`-gated at every transition; REFACTOR owner-confirmed
      skip -- implementation already minimal, matching the ratified design's
      own code block verbatim). 9 new tests (5 `.markerFlaggedSlotPedigree()`
      unit tests incl. the duplicate-`pedigree$id` guard and both-slots
      -flagged dragon; 2 non-mocked real-`getPotentialParents()` regressions,
      one per call site; 1 mechanism-verification mock; 1 live Shiny-module
      regression) all confirmed genuinely RED first, then GREEN with zero
      regressions to the 147 pre-existing assertions they sit beside. Full
      clean regression: 0 failed/0 error (4236 passed, 201 skipped, 15
      pre-existing-class warnings). `lintr::lint_package()`: 0 lints.
      `devtools::check()`: 0 errors/0 warnings/2 pre-existing notes (vignette
      -engine NOTE and a 13-word spelling-drift NOTE, both confirmed
      unchanged by this diff -- this session's own 2 new WORDLIST gaps from
      its new roxygen text, "positionally"/"unmutated", fixed in the same
      commit). **Live Phase 3E `shinytest2` smoke test** against a real
      running app (real pedigree + genotype file upload through the actual
      Input and Marker Genetics tabs, not just `testServer()`) confirmed the
      previously-empty Candidate Parent Assignment table now renders 2 rows
      for a recorded-but-wrong-parent fixture (the true parent ranked first,
      the wrong recorded parent visible with `LOD = -Inf`/`excluded = TRUE`
      per the ratified D3(a) decision), zero console errors -- closing the
      loop on the exact defect S498 originally found live. **Issue #155
      closed** as part of this session's close-out. See `CHANGELOG.md`,
      `PROJECT_LEARNINGS.md` Learning 501.)
- [ ] (none remaining -- the "`.buildTwinConnectorEdges()` (`R/makePedigreeDiagramData.R`, issue
      #137 Slice 2) never wired the Okabe-Ito green (`#009E73`) color its own implementing
      session's handoff narrative said it picked" item (found S494, 2026-08-09) is RESOLVED --
      **wired S506 (2026-08-10):** owner chose "wire it in" over decline-and-close via
      `AskUserQuestion`. `color = "#009E73"` added to `.buildTwinConnectorEdges()`'s output for
      both `edgeStyle` values, plus a matching legend swatch in `R/modPedigree.R`. A second,
      previously undiscovered dragon found and fixed in the same session:
      `.addRectilinearWaypoints()` unconditionally reset every kept edge's `color` to `NA` under
      `edgeStyle = "rectilinear"` -- the same anti-pattern issue #133 already named/fixed on the
      node side of this same function, now fixed the same way (preserve-if-absent). Full
      strict-TDD PRE-RED->RED->GREEN cycle; 11 new/extended test assertions across 4 files; full
      regression suite 0 failed/0 error (exact +11/-11 delta vs. unmodified `HEAD` via
      `git stash -u`, 0 change to the 15 pre-existing baseline warnings); `lintr` 0 lints;
      `devtools::check()` 0 errors/0 warnings, pre-existing notes only. Live `shinytest2` smoke
      test confirmed the color renders on the real running app under BOTH `edgeStyle` values,
      directly proving the rectilinear dragon-fix live. See `CHANGELOG.md`,
      `PROJECT_LEARNINGS.md` Learning 505.)
- [ ] (none remaining -- the "`devtools::check()` returns a non-portable-filename
      ERROR/WARNING for `inst/extdata/reference/Standardized Human Pedigree
      Nomenclature: Update and Assessment of the Recommendations of the
      Nation.html`" item (found S486, 2026-08-08) is RESOLVED -- S497
      (2026-08-09): owner renamed the file directly (outside a session tool
      call) to `inst/extdata/reference/pedigree_nomenclature.html`, a short,
      portable name. **`devtools::check()` went from 1 error/1 warning/1 note
      to 0/0/0** -- the vignette-engine NOTE this item's own S486 text already
      flagged as "likely-related" was confirmed as exactly that: fixing only
      the filename also cleared the `vignettes/a2interactive.Rmd` "no
      recognized vignette engine" NOTE, even though a direct investigation
      (`tools::pkgVignettes(check = TRUE)` against both the raw source tree
      and a freshly-built tarball) found the vignette's own `VignetteEngine`
      tag valid and correctly recognized throughout -- the NOTE was
      apparently a downstream symptom of the non-portable-filename ERROR
      derailing the check pipeline, not an independent defect. **A second,
      incidental gap found and fixed in the same session:** the rename broke
      a `.gitignore` pattern (`Standardized Human Pedigree Nomenclature*.html`,
      S479) that had deliberately kept this copyrighted, local-only reference
      file out of the public git repo -- `.gitignore` updated to the new
      exact filename (owner's own fix). Separately, `.Rbuildignore` had
      **never** excluded this file (or the two other S479-gitignored
      copyrighted files, `5201430.pdf`/`bioinformatics_24_2_279.pdf`) from
      the built package tarball at all -- `.gitignore` has no effect on
      `R CMD build`, which reads the filesystem directly, so all three files
      had been shipping inside every built/distributed tarball despite being
      deliberately kept out of git. Fixed by adding `.Rbuildignore` entries
      for all three (owner confirmed via `AskUserQuestion`); verified via a
      fresh `pkgbuild::build()` that none of the three ship in the tarball
      and the legitimately-shipped `Master_Genetic_metrics_2_14_15.pdf`
      (S418, a different copyright situation) still does. The one known
      prose reference to the old filename (`docs/audits/
      PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`, per
      `PROJECT_LEARNINGS.md` Learning 480) updated to the new path; historical
      references in `SESSION_NOTES.md`/`CHANGELOG.md`/`PROJECT_LEARNINGS.md`
      correctly left as dated narrative describing repo state as it existed
      when written, not retroactively rewritten. **The separately-tracked
      `spelling.Rout` WORDLIST gap (9 pre-existing words) is unrelated and
      still open** -- see the item below.)
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

- [ ] **Fix the `methodology_trim.py` fence-scanner defect blocking `SESSION_NOTES.md`'s first
      archive** (found S518, 2026-08-11, READY, Effort S) -- `SESSION_NOTES.md` now has a verified
      `LEDGERS` config entry (all 577 record-start headings checked for shape variance, zero found)
      but its archive was NOT run: a 4-backtick-delimited *inline code span* at
      `SESSION_NOTES.md:23229` (`` ```` ```{r}/```{R}```` `` `` -- a legitimate way to show literal
      triple-backtick text) starts a physical line, and the tool's simplified fence-scanner reads
      it as an unclosed *block*-fence opener, putting the remaining 17,040 of 40,269 lines (42%)
      into a false "inside a fence" state and hiding 349 of 513 real session-record headings from
      the partition. Confirmed via direct `fence_scan()` testing, not assumed. Two possible fixes:
      (a) rewrap the one offending paragraph so the 4-backtick sequence no longer opens a physical
      line (smaller, local, but edits frozen historical `SESSION_NOTES.md` content); (b) patch
      `methodology_trim.py`'s fence-scanning regex to distinguish an inline code span from a block
      fence opener (correct upstream fix, but a deeper edit to a canonical-overlay file than the
      config addition this session already made, and arguably belongs reported to the canonical
      methodology repo rather than patched locally). Re-run `python3 methodology_trim.py --file
      SESSION_NOTES.md` after either fix and confirm the record count returns to ~513 (not 164)
      before trusting `--write`. See `CLAUDE.md` Additional close-out checks.
- [ ] **`BACKLOG.md`'s own ledger-size housekeeping -- editorial compression, not a
      `methodology_trim.py` config** (found S518, 2026-08-11, READY, Effort L) -- `BACKLOG.md`
      itself is one of the dashboard's 3-file HIGH-risk ledger-size items (2,181 lines, past the
      2,000-line read cap) but does not fit `methodology_trim.py`'s chronological-record model: it
      has only 10 `##` sections (Active, Architecture follow-ups, Up Next, Housekeeping, Outreach,
      ...), each a large *standing topical category* that accumulates resolved-item narrative
      indefinitely, not dated newest-on-top records -- the tool's always-retain-a-prefix/
      archive-the-suffix cut model would archive whichever section happens to sort last, not the
      oldest/safest content. The file's own header already states the right remedy: "Open,
      actionable work only... for history see `CHANGELOG.md`" -- a future session should review
      each section for fully-RESOLVED items whose long narrative write-up (some run 50+ lines, e.g.
      the LabKey integration item) can be compressed to a short pointer with full detail preserved
      in its existing `CHANGELOG.md` entry, rather than left in place verbatim. This is an
      editorial/judgment task (which items are truly safe to compress without losing something
      load-bearing), not a mechanical trim -- budget it as its own session, not a quick pass.
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

**Progress (S485, 2026-08-08):** Tier 2 step 1 -- issue #133's design/architecture document -- is
DONE and RATIFIED: see `docs/planning/issue133-affected-status-pedigree-diagram-plan.md`. 8 ratified
decisions (`affected` logical column, kinship2-name parity; single-trait v1 scope; `color.background`
+ tooltip rendering, no new dependency/custom JS; implement in BOTH `makePedigreeDiagramData()` and
`makePedigreeMatingLayout()` -- confirmed via `grep` that the latter, not the former, is what
`R/modPedigree.R:446` actually calls for the live Diagram tab; a new sibling test fixture rather than
an in-place edit to the ~20-test-pinned base fixture; a one-row `visLegend()` extension; vital-status
(`status`) kept explicitly out of scope; exact fill color deferred to the implementing session's own
Pre-RED). Also ruled out reusing this project's existing `condition`/`status` schema columns (both
mean something else, confirmed via direct roxygen read -- see `PROJECT_LEARNINGS.md` Learning 485).
Scoped as 2 future vertical slices with full RED/GREEN/DONE/Verify contracts (Slice 1: data model +
core rendering; Slice 2: legend + documentation) -- next session in this cluster implements Slice 1.
Issue #133 itself intentionally left open (design ratified, not yet implemented); no `gh issue close`
this session.

**Progress (S486, 2026-08-08):** Tier 2 step 2 -- issue #133 Slice 1 (data model + core rendering) --
is DONE, full TDD RED->GREEN cycle (`AskUserQuestion`-gated at every transition, including 2 Pre-RED
author's-call decisions: D8 fill color `#CC79A7` Okabe-Ito reddish-purple, and the `include`
question resolved "not yet"/display-only v1). `affected` is now a recognized optional logical column
(`.nprcColumnSchema$possible`); both `makePedigreeDiagramData()` and `makePedigreeMatingLayout()`
render it (dominant `color.background` + "Affected: Yes/No/Unknown" tooltip line), backward
-compatible (absent column => zero output change, confirmed by dedicated regression tests). New
sibling fixture `inst/extdata/examples/obfuscated_rhesus_mhc_ped_affected.csv` (`data-raw/
obfuscated_rhesus_mhc_ped_affected.R`, seeded RNG, ~20% TRUE/70% FALSE/10% NA, disclosed synthetic).
**Found and fixed one gap the design doc didn't anticipate:** `.addRectilinearWaypoints()` was
unconditionally resetting every node's `color.background`/`color.border` to NA, which would have
silently erased the new affected-status coloring the moment a user selected the rectilinear edge
style (issue #142) -- fixed with a preserve-if-already-set guard, covered by a new regression test in
`test_addRectilinearWaypoints.R`. Verified: full clean regression read 0 failed/0 error (10
pre-existing baseline warnings unchanged, 4632 passed); `lintr::lint_package()` 0 issues on touched
files (2 nested-`ifelse()` warnings resolved by extracting shared `.affectedColor()`/`.affectedLabel()`
helpers rather than suppressed); `devtools::check()` returns 2 ERRORs/1 WARNING/2 NOTEs, **all
pre-existing and unrelated to this session's diff** (confirmed via `git log`: the non-portable
`inst/extdata/reference/...` filename dates to commit `887ee902`/S418; the `a2interactive.Rmd`
vignette-engine NOTE and the `spelling.Rout` mismatch on issue #142-era terms are likewise untouched
by this session) -- zero new errors/warnings/notes introduced. Live `shinytest2`/`chromote` smoke test
(ad hoc, per Phase 3E, not committed as a new e2e test -- outside the approved Slice 1 file-touch
list) confirmed on the real running app: the new sibling fixture visibly shades an `affected=TRUE`
node `#CC79A7` with the tooltip line present, an `affected=FALSE` node in the same pedigree has no
color override, 0 console errors; the base fixture (no `affected` column) shows neither the color nor
the tooltip text anywhere and 0 console errors -- confirmed via the live vis.js Network instance's own
DataSets (`HTMLWidgets.find(...).network.body.data.nodes.get(id)`), matching this file's own
established "known trio" technique, not raw DOM HTML (which does not carry canvas-rendered node data
-- an initial verification pass using `get_html_safe()` alone produced a false negative before this
was caught and corrected). `NEWS.Rmd` entry added this session (judgment call: the design doc's own
Section 5 attributes the NEWS/tutorial checklists to "Slice 2, the session that ships the user-visible
legend/shading," but Slice 1 itself already ships the shading/tooltip rendering per its own Section 4
scope -- read literally, `CLAUDE.md`'s NEWS.Rmd checklist trigger ("ships a new user-facing Shiny
feature") is satisfied now, so the entry was added at Slice 1's close rather than deferred; the
tutorial/article walkthrough update stays correctly deferred to Slice 2 per the design doc, since a
walkthrough is more coherent once the discoverability legend also exists). Issue #120's citation
checklist confirmed NOT applicable (a raw display flag, not a new displayed statistic/estimator,
matching the design doc's own Section 5 read). Issue #133 stays open (Slice 2 -- legend + docs --
still pending); no `gh issue close` this session. Next session in this cluster implements Slice 2: see
`docs/planning/issue133-affected-status-pedigree-diagram-plan.md` Section 4 Slice 2.

**Progress (S487, 2026-08-08):** Tier 2 step 2 -- issue #133 Slice 2 (legend + documentation) -- is
DONE, full TDD RED->GREEN cycle (`AskUserQuestion`-gated at every transition). Added one "Affected"
row to the Diagram tab's existing shape-to-sex `visLegend()` (D6, reusing Slice 1's `#CC79A7`
color) -- confirmed hands-on that the design doc's own Dragon #3/#4 concerns were both real: (1)
`shape="box"` (a Pre-RED author's call, not dictated by the design doc) rendered as a label-sized
filled pill inconsistent with the other 5 fixed-size-icon rows -- switched to `"hexagon"`; (2) the
6th row's own label clipped against the legend's fixed 400px canvas height at the existing
`stepY=65L` -- retuned to `stepY=54L`, live-reverified clipping-free. `visExport()` PNG capture of
a `color.background`-only node (Dragon #3, deferred by S486) confirmed working via a real exported
PNG (900+ matching pixels). Documentation checklists done in-session: `NEWS.Rmd`'s existing #133
bullet updated (no second entry) to describe the legend rather than promise it "in a later
release"; `_pedigree_browser.Rmd` and `colony-manager-guide.qmd` (owner's #133 comment requires
both) updated and re-rendered clean. **Incidental fix:** re-rendering `NEWS.Rmd` found S486's own
bullet had never actually been re-rendered/committed to `NEWS.md` (last touched S468) -- fixed as a
byproduct of this session's own render, not a separate action. Citation checklist (#120)
re-confirmed N/A. Verified: full clean regression read 0 failed/0 error (4640 passed, 10
pre-existing warnings -- now root-caused, see the new Housekeeping item above); `lintr` 0 on
touched files; `devtools::check()` exact pre-existing baseline (2 ERRORs/1 WARNING/2 NOTEs, all
individually attributed, 0 new); live `shinytest2`/`chromote` smoke test confirmed all 6 legend
rows + the main diagram's affected-node coloring + the PNG export, 0 console errors. **Both slices
of issue #133 are now shipped; issue #133 itself is closed as part of this session's close-out.**
Tier 2's remaining order (#136 > #137 > #138, each needing its own scoping session) is next in this
cluster.

**Progress (S488, 2026-08-08):** Tier 2 step 3 -- issue #136's design/architecture document -- is
DONE and RATIFIED: see `docs/planning/issue136-name-labels-pedigree-diagram-plan.md` (READY for
implementation, Slice 1 Effort S-M, Slice 2 Effort M). Owner ratified in two `AskUserQuestion`
rounds: the framing (names exist at **some centers, inconsistently**; an optional `name` column +
off-by-default toggle, over tooltip-only / decline / configurable label-source) and the 4
judgment-call decisions (D3 augment `id`+name not name-only; D6 pin `useLabels = FALSE`; D10
truncate displayed + full name in tooltip; D8 `obfuscatePed()` drops `name` to `NA`). D1/D4/D5/D7/
D11/D12 are forced by structural traps, not voted. **The design corrects three premises in the issue
itself:** `label` is already independent of `id` and `label != id` already ships (dup nodes `:906`,
union nodes `:929`), so #136 is "choose the string" not "build the mechanism"; the schema's
`first_name`/`second_name` are ALLELE names (the Learning 485 trap re-encountered); and the real
constraint is **geometry, not the data model** -- 25.6% of adjacent label-bearing node pairs sit 48
layout units apart with ~50-unit nodes, every id is exactly 6 chars, and nothing in the
fixed-coordinate layout measures text. **Also found a disclosure defect** no prior session had reason
to look for: `obfuscatePed()` scrubs only `id`/`sire`/`dam` + Date columns, so a `name` column would
survive de-identification intact -- now a mandatory same-slice requirement (D8). Scoped as 2 slices;
**next session in this cluster implements Slice 1** (data model + de-identification; no visible app
change). Issue #136 intentionally left open. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 488.

**Progress (S489, 2026-08-08):** Tier 2 step 3, Slice 1 -- issue #136's data model + de-identification
-- is DONE, full TDD RED->GREEN cycle (`AskUserQuestion`-gated at every transition). `name` is now a
recognized, optional, character pedigree column: `.nprcColumnSchema$possible` gained `name` (appended
after `affected`); `qcStudbook()` keeps it first-class (character-typed, ordered ahead of any genuine
novel column) and coerces a factor-supplied `name` to character (mirroring the existing `species`
precedent); `obfuscatePed()` now scrubs `name` to `NA` (D8), closing the disclosure defect S488 found.
New sibling fixture `inst/extdata/examples/obfuscated_rhesus_mhc_ped_name.csv` (`data-raw/
obfuscated_rhesus_mhc_ped_name.R`, seeded RNG, ~70% named/~15% empty/~15% `NA` per D4's "inconsistent"
case, 1 deliberately long name pre-staged for Slice 2's geometry mitigation). **Pre-RED found 2 of the
plan's suggested RED tests (trap 3 `removeDuplicates()`, trap 4 `fixColumnNames()`) already pass with
zero code change** -- both are schema-agnostic existing behavior correctly extending to the new column
-- disclosed to the owner and included as labelled documentation/coverage rather than presented as
RED-driving (see `PROJECT_LEARNINGS.md` Learning 489). No visible app change (Slice 1 scope); issue
#136 stays open. Verified: full clean regression read 0 failed/0 error (10 pre-existing baseline
warnings unchanged, 4650 passed); `lintr` 0 issues on all 8 touched files (using the project's own
`.lintr` config, not the default linter set); `devtools::check()` 1 ERROR/1 WARNING/1 NOTE, all
pre-existing (non-portable `inst/extdata/reference/...` filename from S418; `a2interactive.Rmd`
vignette-engine NOTE), 0 new; end-to-end pipeline check against the new fixture confirmed `name`
survives `qcStudbook()` and is correctly scrubbed by `obfuscatePed()`. Citation (#120), `NEWS.Rmd`, and
tutorial/article checklists are N/A per the plan's own Section 5 (owed at Slice 2, which ships the
user-visible rendering). REFACTOR: owner-confirmed skip (each change mirrors an existing precedent
exactly -- `species`'s coercion block, `affected`'s roxygen bullet, D8's scrub). **Next session in this
cluster implements Slice 2** (label rendering + toggle + documentation): see `docs/planning/
issue136-name-labels-pedigree-diagram-plan.md` §4 Slice 2. Phase 3E: n/a, no runtime behavior change
this slice. See `CHANGELOG.md`.

**Progress (S490, 2026-08-09):** Tier 2 step 3, Slice 2 -- issue #136's label rendering + toggle +
documentation -- is DONE, full TDD PRE-RED->RED->GREEN cycle (`AskUserQuestion`-gated at every
transition). Pre-RED resolved both open dragons hands-on via a live `chromote` render: Dragon 1
(multi-line `"\n"` rendering) confirmed working, no fallback needed; D10's truncation budget
empirically calibrated at 15 characters + `"..."` against the real fixture's tightest measured
spacing. Two new shared helpers (`.nameLabel()`, `.nameTooltipLine()`) wired into both
`makePedigreeDiagramData()` and `makePedigreeMatingLayout()` (D7, including duplicate-node label
parity); `R/modPedigree.R` gained an off-by-default "Show Names on Diagram" toggle (D3/D4/D6), the
`diagramLayout` reactive strips `name` when the toggle is off, `useLabels = FALSE` pinned on the
search dropdown (D6). **A real defect was found via live Phase 3E verification** (not caught by any
unit test): `pedigreeDiagramUI`'s `renderUI()` rebuilds the toggle checkbox from scratch on ANY
re-render (e.g. switching `edgeStyle`), and a hardcoded `value = FALSE` silently discarded an
already-on toggle -- fixed with a self-referential `value = .currentShowNames()`, matching the
pre-existing `edgeStyle` radio buttons' own pattern. Proven that a `shiny::testServer()` test cannot
pin this class of regression at all (it never simulates the real client round-trip that is the actual
failure mechanism); permanent coverage is instead 2 new live `shinytest2`/`chromote` tests in
`test-e2e-pedigree-module.R`. See `PROJECT_LEARNINGS.md` Learning 490. Documentation checklists done
in-session: `NEWS.Rmd`/`NEWS.md`, `_pedigree_browser.Rmd` **and** `colony-manager-guide.qmd` (owner's
#136 comment requires both, both re-rendered clean), `input_format.html` (new `name` row). Verified:
full clean regression read 0 failed/0 error (10 pre-existing baseline warnings unchanged, 4677
passed, 173 skipped); `lintr` 0 issues on all 6 touched files (2 `commented_code_linter` false
positives reworded away, not suppressed); `devtools::check()` 1 ERROR/1 WARNING/1 NOTE, all
pre-existing and individually attributed, 0 new (the fresh spelling diff's extra 3 words confirmed via
`git blame` to predate this session -- see the updated Housekeeping item above); full live
`test-e2e-pedigree-module.R` run clean. REFACTOR: owner-confirmed skip. **Both slices of issue #136
are now shipped; issue #136 itself is closed as part of this session's close-out.** Tier 2's remaining
order (#137 > #138, each needing its own scoping session) is next in this cluster. See `CHANGELOG.md`.

**Progress (S491, 2026-08-09):** Tier 2 step 4 -- issue #137's design/architecture document -- is
DONE and RATIFIED: see `docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md`. A 4-agent
research + draft + 3-lens adversarial-verify workflow, cross-checked against this session's own
substantial independent first-hand verification (kinship2 v1.9.6.2's `relation` mechanism deparsed
and empirically tested directly, not just read from Rd text; the codebase's rendering/obfuscation/
schema code read directly). Central finding: twin-ness is **pairwise** (unlike #133's `affected` or
#136's `name`, both single-individual attributes), so `.nprcColumnSchema`'s single-per-individual-row
model structurally cannot hold it -- resolved via a new sidecar `twinRelations` table
`(id1, id2, code)`, mirroring kinship2's own `relation` convention and this project's existing
`applyKinshipOverrides()` precedent, needing **zero** change to `columnSchema.R`/`getPossibleCols()`/
`qcStudbook()`/`checkRequiredCols()`/`fixColumnNames()`/`removeDuplicates()`. Confirmed kinship2's
`relation` codes are 1=MZ/2=DZ/3=UZ **twin** plus a 4th, non-twin `4=Spouse` code the issue's own text
omitted; confirmed via direct source read that kinship2 renders DZ with position-clustering only, no
distinct mark, unlike MZ (extra crossbar) and UZ ("?" glyph) -- informing this design's own simpler
direct-edge-with-label rendering choice (no attempt to reproduce kinship2's wedge geometry, ruled out
of scope by the same Deletion-Test refactor heuristic #133 D4 cited). Also found and resolved, in the
same slice as the data model (not deferred): `obfuscatePed()` cannot reach a second sidecar object,
so a new `obfuscateTwinRelations()` companion consuming `obfuscatePed(..., map = TRUE)`'s existing
`map` output is a required Slice 1 deliverable, closing the same class of PII gap #136 D8 closed for
`name`. 4 genuine judgment calls (data-model shape D1, rendering mechanism D6, duplicate-node
connector-targeting D7, UI-wiring slice boundary D11) ratified via a single `AskUserQuestion` round;
owner selected this document's own recommended option in all four cases, no changes requested. A
tooling discovery made and recorded in-session (`PROJECT_LEARNINGS.md` Learning 491): the workflow's
own huge (~56K-character) drafted document was silently truncated to its last ~18.6K characters
before reaching both the persisted journal and the downstream adversarial-verify agents, causing 2 of
3 verify lenses' "blocking" findings to be false positives (content the truncated copy never showed
them, not a real gap) -- caught only by recovering the drafting agent's raw transcript directly and
cross-checking against this session's own independent verification. 3 genuinely new verify findings
did survive reconciliation and are incorporated into the ratified document (a missing `CHANGELOG.md`
ledger-format close-out item; a "twin zygosity," never bare "zygosity," prose-disambiguation
requirement against the Marker Genetics module's existing "Heterozygosity" tab; and two rendering
mechanics notes -- a `dashes` list-column technique and `visLegend()`'s single-call `addEdges`
parameter). No `R/`/`tests/`/`man/` content changed this session (design-only). Issue #137 stays
open, ready for Slice 1 implementation in a future session. See `CHANGELOG.md`.

**Progress (S492, 2026-08-09):** issue #137 Slice 1 (data model + de-identification) is DONE --
`R/checkTwinRelations.R` (validates a twin/zygosity sidecar `(id1, id2, code)` against kinship2's
own five relation rules) and `R/obfuscateTwinRelations.R` (de-identification companion consuming
`obfuscatePed(..., map = TRUE)`'s alias vector), both `@export`. Full strict-TDD PRE-RED->RED->GREEN
cycle; a real RED-phase rigor gap found and fixed live (bare `expect_error()` trivially satisfied by
"could not find function," not the intended domain rule -- `PROJECT_LEARNINGS.md` Learning 492).
Fixture pair added (`obfuscated_rhesus_mhc_ped_twins.csv` + `..._twin_relations.csv`), built from
REAL full-sibling structure already present in the base pedigree (not fabricated), including a twin
who is independently a multi-mate parent (design doc sec 6 Dragon 3's exact scenario). Verified:
full clean regression read 0 failed/0 error, 4694 passed; `lintr` 0 issues; `devtools::check()` 1
ERROR/1 WARNING/1 NOTE, all pre-existing/individually attributed, 0 new (2 new spelling-check words
this session's own diff introduced -- "zygosity", an ordinal-digit "th" tokenization artifact --
were found and fixed in-session, not left as a new gap). REFACTOR: owner-confirmed skip. **Issue
#137 stays open** -- Slice 2 (core rendering: connector edges in both diagram functions, rectilinear
trap fix) is next in this cluster, followed by Slice 3 (UI wiring, legend, documentation). See
`CHANGELOG.md`.

**Progress (S493, 2026-08-09):** issue #137 Slice 2 (core rendering) is DONE -- both
`makePedigreeDiagramData()` and `makePedigreeMatingLayout()` gain an optional `twinRelations`
parameter (D1/D6/D7) rendering a distinctly-styled connector edge per twin pair via a new shared
`.buildTwinConnectorEdges()` helper: MZ solid+"MZ", DZ short-dash `c(4L,4L)`+"DZ", UZ long-dash
`c(14L,8L)`+"?" (D10 colors/dash patterns decided this session -- `#009E73` Okabe-Ito bluish-green,
confirmed via grep against every hex color already in `R/` to avoid collision). `dashes` is an
`I(list(...))` list-column, re-confirmed hands-on (a second, independent verification of the design
doc's own Dragon #4) via a live `rbind()`/`jsonlite` test that a plain logical value and a
numeric-vector dash pattern coerce and serialize correctly in the same column.
`.addRectilinearWaypoints()`'s `newEdges` construction now unconditionally stamps a `label` column
(D9) -- verified as genuinely load-bearing, not just plausible, by temporarily reverting the fix,
re-observing the exact predicted "undefined columns selected" crash, then restoring it. Full
strict-TDD PRE-RED->RED->GREEN->REFACTOR cycle (`AskUserQuestion`-gated at every transition; REFACTOR
fixed one small doc-drift item, a stale non-`L`-suffixed dash value in `.buildTwinConnectorEdges()`'s
own roxygen prose after a lint fix changed the code to integer literals). Phase 3E: a live
`shinytest2`/`chromote` smoke test against a hand-built, zoomed focus-subset of the Slice 1 fixture
(the 3 twin pairs + immediate family, including the D7 multi-mate-duplicate scenario) VISUALLY
confirmed all 3 connector styles distinctly, under both `edgeStyle` settings, 0 console errors --
closing the design doc's own Dragon #5 gap ("never visually rendered, not even once"); confirmed the
MZ connector targets HV7LZ3's REAL node specifically, not either of her 2 `__dup_` occurrences (D7);
confirmed the twin connectors stay direct/unrouted under `edgeStyle = "rectilinear"` while mate-lines
route through right-angle waypoints around them (D9), exactly as designed. Verified: both targeted
test files green (76+128 expectations); full clean regression read 0 failed/0 error, 4733 passed,
173 skipped, 10 pre-existing baseline warnings (unchanged); `devtools::check()` 2 ERRORs/1 WARNING/2
NOTEs, all independently traced to already-tracked `BACKLOG.md` pre-existing items (non-portable
filename S418; vignette-engine NOTE + the exact same 9-word spelling gap tracked since S465/S490), 0
new; `lintr::lint_package()` 0 lints on touched files. **Issue #137 stays open** -- Slice 3 (UI
wiring, legend, documentation) is next in this cluster. See `CHANGELOG.md`.

**Progress (S494, 2026-08-09):** issue #137 Slice 3 (UI wiring, legend, documentation) is DONE,
closing the 3-slice chain. Pre-RED found the plan's own "Touches" list overstated scope: neither
`R/appServer.R` nor `R/modInput.R` needed a change (unlike `kinshipOverrides`, `twinRelations` is
consumed only inside `modPedigree`'s own render chain, no cross-module threading needed) --
confirmed by direct reads before writing any code, not assumed. New `fileInput(ns("twinRelationsFile"),
...)` lives in `modPedigreeUI()`'s STATIC UI (never the dynamically re-rendered `pedigreeDiagramUI`
block) -- a `fileInput` has no `value=` a fresh render could read back self-referentially the way
`checkboxInput`/`radioButtons` do, so keeping it outside any re-executing block is the only way to
avoid silently discarding an upload (Learning 490's file-input corollary, found this session, not
merely inherited). New `twinRelationsData()` reactive (mirrors `modGeneticValue.R`'s
`kinshipOverrideData` precedent exactly, minus its dead warning-handling branch --
`checkTwinRelations()` only ever `stop()`s, never `warn()`s) validates the upload against
`pedigreeData()`, non-fatal on error. New off-by-default **Show Twin Connectors** toggle follows the
established self-referential-value pattern (Learning 490) alongside the existing `edgeStyle`/
`pedigreeShowNames` controls; `diagramLayout()` gates whether the validated data reaches
`makePedigreeMatingLayout()` on the toggle, mirroring the existing `showNames`-gates-the-`name`-column
precedent. Legend gained MZ/DZ/UZ rows via the SAME `visLegend()` call's `addEdges` parameter
(confirmed via source read that it passes straight through with no validation, so a second call was
never needed) -- describing exactly what Slice 2 actually renders (label + dash pattern only). New
exported `R/readTwinRelations.R` mirrors `readKinshipOverrides()` verbatim. **Found and filed, not
fixed:** Slice 2's own `.buildTwinConnectorEdges()` never actually wired the `#009E73` color its own
S493 handoff narrative said was picked -- confirmed via direct grep (zero `009E73` hits in
`R/makePedigreeDiagramData.R`) -- filed as its own Housekeeping item above rather than fixed here
(outside Slice 3's own pre-declared file scope). Full strict-TDD PRE-RED->RED->GREEN cycle
(`AskUserQuestion`-gated at every transition, including a dedicated pre-RED scope decision on the
color gap; REFACTOR owner-confirmed skip -- the GREEN diff was already minimal and precedent-mirroring).
Phase 3E: the full, real `test-e2e-pedigree-module.R` suite (13 tests, including 2 new ones for this
slice) run live against a freshly `devtools::install()`ed package (the Learning 440 stale-install trap
avoided proactively, not rediscovered) -- all 13 passed, including the new MZ/DZ/UZ connector-render
test and the toggle-survives-`edgeStyle`-switch regression test (Learning 490's own pattern, applied
to a second toggle), 0 console errors. Verified: full clean regression read 0 failed/0 error, 4758
passed, 175 skipped, 10 pre-existing baseline warnings (unchanged); `devtools::check()` 2 ERRORs/1
WARNING/2 NOTEs, an EXACT match to S493's own baseline, 0 new; `lintr::lint_package()` 0 lints (6
false positives on new comments/a label string, suppressed via the established `# nolint` convention,
not deleted or reworded). `NEWS.Rmd` and `vignettes/manual_components/_pedigree_browser.Rmd` both
updated this session. Citation checklist (#120): N/A, confirmed explicitly -- a twin/zygosity
connector is a relationship marker/rendering convention, not a new displayed statistic or estimator,
matching the precedent already set for #133's `affected` flag and #136's `name` label.
`a2interactive.Rmd` coverage remains DEFERRED per its own standing rule (a future documentation pass,
not this slice). **Issue #137 is now fully implemented across all 3 slices; closed as part of this
session's close-out.** See `CHANGELOG.md`.

**Progress (S499, 2026-08-09):** Issue #145's own design/architecture document -- deferred since
S482's verification spike per that spike's own "Recommendation for a future #145 design session" --
is DONE and RATIFIED: see `docs/planning/issue145-sire-dam-left-right-placement-plan.md`. Direct
source verification found two things the spike's own cross-project recommendation got wrong once
re-derived against `nprcgenekeepr`'s OWN algorithm (which does not call kinship2 at all, confirmed
this session): (a) today's simple-pair default is NOT "coincidentally male-left" the way kinship2's
is -- the project's own canonical GA204Z/8LKBV9 fixture places the DAM left of the SIRE today, the
opposite of the spike's assumption; (b) the multi-mate "crowding" case has no existing
"anchor-centered, mates flank" mechanism to extend, contrary to the spike's claim that one already
exists for unrelated reasons. A 3-agent adversarial review of the resulting draft (before
ratification) found a real, constructed counter-example breaking the draft's first proposed
mechanism (a subtree reflection) and refuted an overstated "gen and x are orthogonal" claim about
issues #143/#144 using their own shipped test diffs -- both incorporated into a revised, more
conservative mechanism (swap only the two real parents' own `x` values) before ratification, not
patched around superficially. Three genuine judgment calls (direction, toggle shape, whether to file
a follow-up issue for the harder multi-mate case) ratified via a single `AskUserQuestion` round,
owner selected this document's own recommended option in all three: male-left/female-right; a new
`orderBySex = TRUE` parameter on `makePedigreeMatingLayout()` with no UI wiring yet (Slice 2 not
created); no follow-up issue filed for the multi-mate case. **Issue #145 stays open** -- this is
design/planning only, matching the #133/#136/#137/#147 precedent; Slice 1 (core positioning
behavior) is the natural next pickup, with its own Pre-RED required to empirically verify D2's
mechanism live before RED (not yet proven beyond a paper argument -- see the plan's own §6 Dragon 1).
See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 498.

**Progress (S500, 2026-08-10):** Issue #145 Slice 1 (core positioning behavior) is DONE, implementing
the ratified design's D1-D8: `.positionMatingUnitForest()` gained a new `orderBySex = TRUE`
parameter (an additive post-hoc value-swap for every D1-qualifying simple pair);
`makePedigreeMatingLayout()` threads a matching parameter through, default on. Full strict-TDD
PRE-RED->RED->GREEN cycle (`AskUserQuestion`-gated at every transition, REFACTOR owner-confirmed
skip). Pre-RED empirically verified D2's swap mechanism live (not just on paper) against the real
GA204Z/8LKBV9 fixture and a reconstructed version of the adversarial review's own wide-fanout
counter-example, re-derived to actually force the swap to fire. GREEN's own live run surfaced a
second, independently D1-qualifying pair nested inside the wide-fanout test fixture (`C2`/`GCMate`),
correctly swapped by the (intentionally per-unit-scoped) implementation -- the test's own assertion
was widened to match, not the implementation narrowed (`PROJECT_LEARNINGS.md` Learning 499). Verified:
all 8 new/modified tests pass; full clean regression read 0 failed/0 error (4881 passed, up from
4858, same 10 pre-existing baseline warnings); `lintr::lint_package()` 0 lints on touched files;
`devtools::check()` 0 errors/0 warnings/1 note (pre-existing `a2interactive.Rmd` baseline, unchanged
-- the first check run caught a real codoc-mismatch WARNING from a forgotten `devtools::document()`,
fixed, which also atomically corrected a second, already-stale `.Rd` file from S498's own
unregenerated roxygen source); live `shinytest2` smoke test (visNetwork bound, 0 diagram-related
console errors) with a screenshot of a real 2-child qualifying family in the bundled fixture visually
confirming male-left/female-right rendering -- satisfies the plan's own §6 dragon 3. `NEWS.Rmd`/
`NEWS.md` updated; citation/`_pkgdown.yml`/tutorial-article checklists all N/A this slice (D7);
`a2interactive.Rmd` deferred per its own standing rule. **Issue #145 is now fully implemented for
the ratified simple-pair scope; closed as part of this session's close-out.** See `CHANGELOG.md`,
`PROJECT_LEARNINGS.md` Learning 499.
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
