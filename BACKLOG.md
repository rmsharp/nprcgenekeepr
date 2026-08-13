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
- [ ] **Phase 0 has no step that checks GitHub Actions CI status -- a red
      `R-CMD-check.yaml` run sat unnoticed across 13 sessions (S526-S539)**
      (found S540, 2026-08-12, DECISION NEEDED -- whether/how to add a Phase 0
      step, Effort S) -- issue #152 Slice 2 (S526) introduced 3 CI-only test
      failures (`test_markerKinship.R:169`, `test_markerParentageLikelihood.R:582,628`,
      fixed S540); `gh run list` showed `R-CMD-check.yaml` failing on both pushes
      since (2026-08-11T22:37, 2026-08-12T22:57), then 15 further local commits
      landed without ever pushing again or checking CI status, until the owner
      asked directly. Neither `SAFEGUARDS.md`'s Session Recovery Protocol nor
      `SESSION_RUNNER.md`'s Phase 0 checklist inspects GitHub Actions at all --
      each of the 13 sessions followed its own checklist completely as written;
      the checklist itself has no step that would have caught this (a sibling
      gap to `PROJECT_LEARNINGS.md` Learning 477's `lint.yaml` precedent, which
      fixed that instance's violations but did not add a general check). Not
      fixed this session -- a Phase 0 protocol change is its own scope decision,
      out of a CI bug-fix session's own deliverable. A future session (or the
      owner directly) should decide whether to add a `gh run list --limit 5` (or
      similar) check to `CLAUDE.md`'s "Additional Phase 0 steps," and if so, at
      what cadence (every session vs. only when `git status` shows unpushed
      commits). See `PROJECT_LEARNINGS.md` Learning 547, `CHANGELOG.md`.
- [ ] (none remaining -- the "`test-coverage.yaml` CI job failing on `origin/master`" item
      (found S542, 2026-08-12) is RESOLVED -- **diagnosed and fixed S544 (2026-08-13):** root
      cause was `tests/testthat/test_wordlist_coverage.R`'s `find_pkg_src()` helper, not a real
      spelling regression. `covr::package_coverage()` runs tests against an
      `R CMD INSTALL --install-tests` copy; under that layout `inst/*` content is flattened
      into the installed package's own root (standard R install behavior), so there is no
      `inst/` subdirectory. `find_pkg_src()`'s `devtools::test()`-fallback branch only checked
      for a `DESCRIPTION` file (which an installed package also retains), so it accepted that
      directory as source; `spelling::get_wordfile()` then looked for the nonexistent
      `<that-dir>/inst/WORDLIST`, silently found nothing, and every already-whitelisted domain
      word (146 of them) got flagged as unknown. Confirmed byte-for-byte via a direct local
      `R CMD INSTALL --install-tests` + `testthat::test_dir()` repro (identical 146-word list
      to the CI failure) before touching any code -- and re-confirmed after the fix that the
      same repro now skips gracefully instead of failing. Fix: all 3 `find_pkg_src()` branches
      now require both `DESCRIPTION` and an `inst/` subdirectory (a shared `is_pkg_src()`
      helper) before accepting a candidate as source. Strict TDD: 2 new tests pin the
      source-vs-installed detection directly (RED confirmed against the unfixed helper, GREEN
      after the fix); full regression 0 failed/0 error (5,519 passed, up from 5,396); 
      `devtools::check()` 0 errors/0 warnings/1 pre-existing unrelated NOTE; `lintr` clean.
      Pushed and confirmed `test-coverage.yaml` green on the real CI run (`f4b478c0`) -- the
      root-truth verification, since the bug only manifests under actual `covr`. See
      `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 551.
- [ ] (none remaining -- the "`CHANGELOG.md` archive refuses via `SRF_RED`" item (found S542)
      is RESOLVED -- **decided and force-archived S543 (2026-08-12):** re-derived the SRF
      numbers live rather than trusting S542's report (SRF 2.9933 against the most-recent
      11-record archive `50b65d1`, 0.1804 against the largest-drop boundary `0929172a`) and
      found the RED reading's own explanation: `50b65d1` only freed 35,169 B, barely denting a
      file the PRIOR day's 588,779 B archive had already settled near its floor -- the same
      ~105,000 B of absolute regrowth reads as alarming against a tiny recent denominator and
      healthy against a large one. **The decisive fact, not previously computed this
      precisely:** the trimmable (post-S325, tagged) region is capped at 116,176 B total --
      the frozen pre-S325 legacy footer is 935,287 B on its own, ~14x the 65,536 B byte
      budget and ~1.8x the 2,000-line read-cap, so **no trim of the tagged region, forced or
      not, can ever clear either trigger** (confirmed post-trim: still FIRES at 945,242 B).
      Given that, and given the project's indefinite lifespan makes periodic archiving of the
      tagged region ordinary, expected, recurring hygiene regardless of whether it clears the
      trigger, owner chose (via `AskUserQuestion`, after this reframing) to `--force` through
      the refusal rather than hold indefinitely. Archived 67 records, 1,051,843 B -> 945,242 B
      (`docs/archive/CHANGELOG-through-2026-08-12.md`), losslessness verified via the tool's
      own generated `verify.sh` (L1/L2/L3 OK) before committing; retained record confirmed to
      be exactly the 2 newest (this session's own claim entry + the tool's auto-appended trim
      entry), not an over-archive. See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 550.)
- [ ] **Reopen the S325 "freeze legacy, go forward" decision -- the only lever that can
      actually clear `CHANGELOG.md`'s byte/line triggers** (found S543, 2026-08-12, DECISION
      NEEDED -- multi-session migration campaign, not a routine session, Effort L) -- S543's
      `SRF_RED` investigation confirmed numerically that the frozen pre-S325 legacy footer
      (935,287 B, ~3,567 of the file's ~3,721 post-trim lines) is now the file's entire
      read-safety problem: it alone is ~14x the 65,536 B budget and ~1.8x the 2,000-line
      `Read` cap, independent of how aggressively the tagged S325+ portion is trimmed. Per
      `CLAUDE.md`'s existing "CHANGELOG.md ledger-format resolution" note, only re-tagging
      that block (a migration campaign re-tagging ~303 already-closed pre-ledger entries into
      the canonical `[SOURCE]`-tagged format, or an equivalent restructuring) would let a trim
      ever reach the 65,536 B budget. Not scoped this session (a scoping/planning session of
      its own, per `SESSION_RUNNER.md`'s multi-session-campaign guidance -- this is
      significantly larger than the S325 owner-decision-not-to-migrate it would reopen). A
      future session should first decide whether the campaign is worth running at all (the
      file has operated at this size for months without incident beyond the read-truncation
      risk itself) before scoping one.
- [ ] **`CHANGELOG.md`'s own ~4-entries-per-session ledger convention (claim, Phase 0
      reconcile, deliverable, close-out) may be a `CHANGELOG.md`-side analogue of the
      already-diagnosed `HANDOFFS.md` "Receipt Inflation" (H4) rate problem** (found S543,
      2026-08-12, Effort unknown, not investigated) -- incidental to the `SRF_RED`
      investigation: the tagged region regrew ~105,000 B in roughly a day during an active
      multi-session stretch (S536-S542), and a `grep -c '^### 2026-08-12'` on the pre-trim
      file showed a large share of that region was same-day, multiple-entries-per-session
      housekeeping (claim/reconcile/close-out entries) rather than deliverable-content
      entries. Not confirmed as causal, and not investigated further this session (out of
      the `SRF_RED` decision's own scope, per `PROJECT_LEARNINGS.md` Learning 382's "report,
      don't fix mid-session" precedent). A future session could measure the actual
      housekeeping-vs-deliverable entry-byte split and decide whether a norm analogous to
      the canonical design's own deferred H4 remedy (`docs/planning/ledger-trimmer-design.md`
      §10.2, "the lever is receipt size, and the mechanism would be a norm plus a check, not
      an archiver") is worth adopting for `CHANGELOG.md` specifically.
- [ ] (none remaining -- the "`shinytest2`/`chromote` headless browser never
      renders a `showModal()`/`modalDialog()` Bootstrap modal's DOM" item
      (found S535, 2026-08-12) is RESOLVED -- **misdiagnosed, corrected
      S536 (2026-08-12):** there is no shinytest2/chromote harness
      limitation. Live root-causing found S535's own E2E pedigree fixture
      (`makeGenomicRohE2ePedigreeFile()`) omitted `columnSchema.R`'s
      required `birth` column, so `dataInput`'s QC silently rejected it
      (visible only via the Input tab's own `qcErrors` output, never
      checked by that test) and `pedigree()` stayed NULL -- correctly
      (not a bug) blocking `req(pedigree())`/`req(sequenceExportRaw())`
      all the way to `showModal()`. Verified live: with `birth` added, the
      full Generate Preview -> Confirm Export -> modal -> Confirm Export
      OK -> download-unlock sequence works end to end in headless Chrome,
      identical to a real browser. Both S535's own genomic-ROH E2E test
      (issue #152 Slice 5) and a NEW E2E test retrofitted for issue #153's
      previously-untested LD-block export modal now drive the full
      sequence live (strengthened past a substring-in-static-HTML check to
      the export-guidance UI's real empty-vs-alert state). No production
      `R/` code changed -- the fixture was the only defect. See
      `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 542 (corrects
      Learning 541's second finding).
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
- [ ] **Write a dedicated article on the Pedigree Diagram tab covering all of its
      current features** (owner-directed, found S544, 2026-08-13, READY, Effort M) --
      the existing coverage is a paragraph in `colony-manager-guide.qmd`'s "Diagram
      view" section plus the `_pedigree_browser.Rmd` shape-to-sex legend (issue #139,
      resolved S455, 2026-08-02), written before most of the tab's current capability
      shipped. Since then the tab has gained: the Option 2 kinship2-parity
      mating-unit/duplicate-node layout (issues #142-144, S465-473); mate-line/
      sibship-bar rendering; twin/zygosity encoding (issue #137); affected-status
      shading (issue #133); node-label name display (issue #136); sire/dam
      left-right placement (issue #145); rectilinear vs. curved `edgeStyle` edge
      rendering (issue #142 follow-up, S506); the "Select by id" search dropdown +
      hover-highlight (S443); click-to-navigate; PNG export; and the node cap (now
      750, not the paragraph's stale 1,500). A full standalone article -- not just an
      extended paragraph -- would give this feature set the same documentation depth
      as other major tabs get in `vignettes/articles/colony-manager-guide.qmd`, and
      would subsume the stale-screenshot item directly above (a full rewrite
      naturally re-captures `pb_diagram_legend.png` against the current render rather
      than patching the existing paragraph in place). Not scoped or written this
      session (found via a mid-turn user request during an unrelated CI-diagnosis
      session; logged per the owner's explicit ask, not implemented, to keep this
      session's TDD-gated deliverable to its one already-approved scope). A future
      session should inventory the tab's full current feature set against the live
      app (matching the Diagram-tab audit precedent in
      `docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`) before
      drafting, and follow the tutorial/article documentation checklist
      (`CLAUDE.md`, Session 436).
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
- [ ] (none remaining -- "`SESSION_NOTES.md`'s first `methodology_trim.py --write` archive" (the
      step deferred above) is RESOLVED -- S539 (2026-08-12): re-ran the dry-run first (620 records,
      up from S528's 599 -- 21 sessions' worth of drift), confirmed clean, then `--write`. Archived
      **612** of 620 records (1998-12-06 -> 2026-08-12) to
      `docs/archive/SESSION_NOTES-through-2026-08-12.md`; live file 6,370,574 B -> 30,066 B (-99.5%,
      well under the 65,536 B budget), 370 lines (was 42,670 -- 21x past the 2,000-line agent read
      cap before this session). 8 records retained (the last ~3 sessions' handoff-eval/deliverable
      pairs plus this session's own claim stub). Losslessness verified via the tool's own L1/L2/L3
      checks and the generated `docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh`, all
      OK. One gate hit and cleared: the tool's `P1_UNDOCUMENTED` check refused to run while this
      session's own claim commit sat undocumented ahead of `CHANGELOG.md`'s frontier (a trim commit
      would have advanced the frontier and hidden that gap permanently) -- logged the claim to
      `CHANGELOG.md` on its own first (matching the exact gate S528 hit), which cleared it. The tool
      itself also auto-appended its own `[ad hoc]` `CHANGELOG.md` entry for the archive action. See
      `CHANGELOG.md`.)
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
      **"Genetic-metrics PDF audit follow-ups" section DONE -- S531 (2026-08-12):** the 3rd and
      last of the item's 3 oversized sections. Compressed 8 fully-resolved issue chains
      (#126/#127/#129/#130's shared sequencing-decision bullet, plus the individually-tracked
      #147/#149/#146/#151/#150/#153 design->slice narrative chains) to the file's own short-pointer
      convention; also condensed the S479-S483 re-audit/sequencing context note (still relevant --
      it names the still-open items) without losing any issue number, tier assignment, or audit-doc
      pointer. Left the still-open issue #152 chain (design S517, Slice 1 S525, Slice 2 S526, Slice
      3 next) fully untouched, matching the S529/S530 "leave open items untouched" precedent. An
      early compression pass left a real duplication defect -- the #153 chain's design paragraph was
      replaced but its 3 slice-by-slice progress paragraphs (S520/S521-523/S524) were missed and
      briefly duplicated the new compressed bullet -- caught by this session's own end-to-end re-read
      before close-out and fixed by removing the now-redundant paragraphs. Verified `CHANGELOG.md`
      (+ both `docs/archive/CHANGELOG-through-*.md` shards) carries an entry for all 39 session
      numbers cited before compressing to a pointer -- 0 gaps found. All Learning cross-references
      and all 13 cited `docs/planning|audits/*` file paths confirmed to resolve. Net: section
      753->267 lines (486 removed); file total 1,658->1,173 (485 removed, some absorbed by this
      item's own progress-note growth). Zero information loss verified by re-reading the full
      compressed section end-to-end before close-out.
      **The S518 item is now fully RESOLVED -- all 3 oversized sections compressed across 3
      sessions:** Housekeeping (S529, 147->389 lines), "Pedigree diagram vs kinship2" (S530,
      896->286 lines), "Genetic-metrics PDF audit follow-ups" (S531, 753->267 lines). File total:
      2,501 lines (S529 start) -> 1,173 lines (S531 end), a 1,328-line/53% reduction across 3
      sessions, with zero information loss at any step (each session's own end-to-end re-read plus
      CHANGELOG.md/Learning/file-path cross-reference verification). See `CHANGELOG.md`.
- [ ] (none remaining -- the "`inst/WORDLIST` has a large, long-standing gap" item (found S521,
      2026-08-11) is RESOLVED -- S537 (2026-08-12): a fresh `spelling::spell_check_package(".",
      vignettes = TRUE)` found **76** genuinely tracked-source words (not the documented 69 --
      real drift from Sessions 522-536; 4 more, `CJ`/`PWJ`/`QBKW`/`ZX`, traced to a stale
      `.gitignore`'d `vignettes/a2interactive.md` build byproduct, confirmed absent from a clean
      `git archive HEAD` checkout). All 76 verified via source-context `grep` as genuine false
      positives (R identifiers/column names, citation authors, library/proper names, valid
      possessives, standard technical/genetics vocabulary) -- zero actual typos found -- and
      hand-added to `inst/WORDLIST` (per the S230/S421 convention, not `spelling::update_wordlist()`).
      **Correction to this item's own prior text and to S452/S465/S490's stated convention:**
      `inst/WORDLIST` is NOT sorted in `LC_ALL=C` byte order -- that claim is empirically false for
      the file as a whole (e.g. `corrigendum` sits between `ColonyManagerTutorial` and `Cramer's`,
      impossible under true `LC_ALL=C`); the file is loosely hand-maintained alphabetical. New
      words were inserted at their correct local position via a linear scan preserving all existing
      line order, verified as a pure 76-line insertion (`git diff | grep -c "^-[^-]"` == 0) -- a
      naive `LC_ALL=C sort -u` merge was tried first and silently reordered ~21 unrelated existing
      entries before being caught and reverted. A new permanent regression guard,
      `tests/testthat/test_wordlist_coverage.R`, asserts `spelling::spell_check_package()` returns
      0 rows (matching the `test_pkgdown_reference_config.R` guard-test precedent), so this
      NOTE-only drift -- previously found and partially hand-fixed at S443/S448/S452/S465/S490
      without ever stopping the pattern from recurring -- gets a hard `testthat` failure instead of
      an easy-to-miss NOTE going forward. `devtools::check()` confirmed clean: **0 errors / 0
      warnings / 1 NOTE** (only the pre-existing vignettes/figure-leftover NOTE; the spelling NOTE
      is gone). See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 543.
- [ ] (none remaining -- the "`NEWS.Rmd` entries since ~2.0.0 have drifted far more
      verbose than the project's own pre-1.0.8 style" item (found S522, 2026-08-11) is
      RESOLVED -- S538 (2026-08-12): rewrote the `2.0.0.9000 (development version)`
      section's 26 entries from multi-sentence paragraphs (full closed-form formulas,
      citation strings, derivation/approximation rationale) back to the pre-1.0.8
      one/two-line-per-change style, per this item's own scoping instruction (below).
      Every dropped formula/citation was verified present in the relevant function's
      roxygen `@references` and/or `inst/extdata/ui_guidance/population_genetics_terms.html`
      before being dropped (spot-checked via `grep`, including `computeGenomicROH()`'s
      F_ROH formula, which IS covered under HTML `<sub>` markup that a plain-text
      `grep` for `F_ROH` initially missed -- re-checked with broader terms before
      trusting the negative). Every issue number and every exported/new function name
      was cross-diffed old-vs-new (`grep -oE '#[0-9]+'` / backtick-quoted identifiers)
      to confirm nothing substantive was lost; 4 genuinely-dropped function-name
      mentions were restored after the diff caught them (`makeGeneticSummaryTable()`,
      `getPossibleCols()`, `getBoxWhiskerDescription()`/`savePlotToFile()`/
      `getPyramidPlot()`, `createSimKinships()`/`cumulateSimKinships()`) --
      the rest were confirmed-intentional (implementation-rationale mentions, not new
      capabilities). Net: dev-version section 386 -> 134 lines (252 removed);
      `NEWS.Rmd` 1,154 -> 902 lines, `NEWS.md` re-rendered via
      `rmarkdown::render(output_format = rmarkdown::github_document(html_preview = FALSE))`
      (no `NEWS.html` litter). Section heading counts/order confirmed identical between
      `NEWS.Rmd`/`NEWS.md` (28 each). **Correctly left the already-released
      `2.0.0 (20260708)` section completely untouched, per this item's own explicit
      "do not rewrite already-released, frozen version sections" instruction** --
      caught mid-session as a self-correction: an initial pass mistakenly also
      rewrote the frozen `2.0.0` section (misreading the owner-approved "all
      post-2.0.0 entries" scope-question phrasing as license to include it); re-read
      this item's own text before finishing, recognized the conflict, and reverted
      that section verbatim from `git show HEAD:NEWS.Rmd` before re-rendering.
      `test_effectivePopulationSizeDocs.R`'s `NEWS.Rmd` regression guard (asserts
      "effective population size"/"gene diversity" both present) reconfirmed passing
      after the fix. **A first `devtools::check()` run then found a second real bug**
      S537's own fresh `test_wordlist_coverage.R` guard caught: rewriting the prose
      shifted `hunspell`/`spelling`'s context-sensitive tokenization around several
      already-benign possessive constructs (`` `fn()`'s ``/`word's`, identical
      patterns existed pre-session and passed clean under S537), newly flagging
      `centers'` and a stray, context-orphaned `'s` fragment. Verified both as false
      positives (no real typo); fixed by rephrasing the 6 exact constructs producing
      them (dropping/relocating each possessive) rather than adding a bare `'s` to
      `inst/WORDLIST`, which would have blinded the guard to real future typos
      sharing that fragment. Re-rendered and reconfirmed
      `spelling::spell_check_package()` returns 0 rows. Full clean regression 0
      failed/0 error (33 pre-existing, unrelated warnings, unchanged from S537's own
      baseline); final `devtools::check()`: **0 errors / 0 warnings / 1 NOTE** (only
      the pre-existing vignettes/figure-leftover NOTE, matching S537's own baseline
      exactly). See `CHANGELOG.md`.
- [ ] (none remaining -- the "`a2interactive.Rmd` documentation pass is due" item
      (found S522, 2026-08-11) is RESOLVED -- S541 (2026-08-12): all 8 named
      functions/families (`markerParentageLikelihood()`, `checkCrossCenterMapping()`,
      `checkLocusMetadata()`, `checkLinkageMarkerGenotypeFile()`,
      `markerRealizedRelatednessVariance()`, `markerLdBlock()`, `obfuscateLdBlocks()`,
      `reportMatePairs()`, `readTwinRelations()`) now have a demonstration section in
      `vignettes/a2interactive.Rmd` -- 6 new subsections under "Marker Genetics", a new
      top-level "Individual Mate-Pair Analysis" section (reusing the tutorial's own
      `trimmedPed`/`trimmedGeneticValue`/`candidates`), and a new "Twin/Zygosity
      Connectors" subsection under "Pedigree Diagram". Every demo verified against the
      real installed package before writing prose (Learning 440); one documented gap
      (the `reportMatePairs()` D4 age-NA gotcha) could not be live-demoed against the
      tutorial's real data and is described in prose only. Full vignette re-rendered
      end-to-end; spelling clean (`inst/WORDLIST` gained the new identifiers); full
      regression 0 failed/0 error; `devtools::check()` 0/0/1 NOTE (baseline-matching).
      See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 548.)
- [ ] (none remaining -- the `.Rbuildignore` `methodology_trim.py` pattern typo (found S533)
      is RESOLVED -- S534 (2026-08-12): `^methodolog_trim\.py$` corrected to
      `^methodology_trim\.py$`. Full strict TDD RED->GREEN->REFACTOR cycle: new
      `tests/testthat/test_rbuildignore.R` regression guard (asserts some `.Rbuildignore`
      pattern matches the real `methodology_trim.py` filename) confirmed RED before the fix,
      GREEN after. `devtools::check()` (default `cran = TRUE` invocation, per Learning 539)
      re-confirmed "checking top-level files ... OK" -- the NOTE this typo caused is gone;
      2 NOTEs remain (vignettes/figure leftover, unrelated; a spelling.Rout.save snapshot
      mismatch tied to the already-tracked `inst/WORDLIST` gap above, also unrelated). See
      `CHANGELOG.md`.)

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
- [ ] (none remaining -- the S428 (2026-07-29) owner-directed sequencing decision covering issues
      #126/#127/#129/#130 is RESOLVED, all 4 fully shipped: **#126** (kinship/genome-uniqueness
      distribution-shape statistics) DONE S429. **#127** (surface
      `correctUnknownParentMeanKinship()`'s dropped `flagged` list) planned S430, implemented S431
      (closes #127) -- `reportGV()$report` gained a boolean `flagged` column. **#129**
      (pedigree-diagram/tree visualization) planned S432
      (`docs/planning/issue129-pedigree-diagram-tree-visualization-plan.md`); Slice 1 (Diagram tab,
      `makePedigreeDiagramData()` + `visNetwork`) DONE S433; Slice 2 (click-to-recenter via
      `visEvents(click = ...)`, `PROJECT_LEARNINGS.md` Learning 408) DONE S434, closing #129. **#130**
      (marker-based kinship/heterozygosity/parentage-verification + cross-center identity) planned
      S441 (`docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md`) as 5 vertical
      slices, all implemented S442-S447: Slice 1 `markerKinship()` (KING-robust, Manichaikul et al.
      2010) + new `modMarkerGenetics` module (Learnings 422-425); Slice 2
      `markerObservedHeterozygosity()`/`markerExpectedHeterozygosity()` (Nei 1973, Learnings
      426-427); Slice 3 `markerParentageExclusion()` (opposite-homozygote conflict counting,
      Cifuentes et al. 2006 / de Groot et al. 2025, Learnings 428-430); Slice 4
      `resolveCrossCenterIds()` (cross-center identity merge, Learning 432); Slice 5 `markerFst()`
      (Hudson's estimator, Bhatia et al. 2013, Learning 434). Each slice full TDD-cycled with
      citation/tutorial checklists done in-session. Issue #130 fully implemented across all 5 slices,
      no open item remains. See `CHANGELOG.md`.

**Second-generation re-audit and issue-sequencing (S479-S483, 2026-08-05 to 2026-08-08):** a ghost
session (reconciled S479, `PROJECT_LEARNINGS.md` Learning 479) produced 2 further capability audits
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`, `..._2026-08-06.md`) and filed 8
new GitHub issues: **#146** (configurable/exhaustive breeding-group candidate retention), **#147**
(likelihood-based candidate-parent assignment), **#148** (MHC haplotype-specific frequency
reporting), **#149** (cross-center identity-mapping workflow with provenance export), **#150**
(de-identified pedigree export workflow), **#151** (individual mate-pair analysis), **#152**
(whole-genome/whole-exome sequence input + sequence-based metrics), **#153** (linkage-aware/
haplotype-block metrics). Sequencing ratified S483
(`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md`, owner-directed, 8-agent
codebase-grounded workflow): Tier 1 #147; Tier 2 #149 > #146 > #151; Tier 3 (policy-gated) #150;
Deferred (design-only) #152 > #153 > #148, with #148 flagged as needing its own scope-narrowing
conversation first (filed broader than the audit recommends). **Also found, still not filed as of
this compression:** 2 audit-table High-priority rows -- "Longitudinal genetic-health monitoring" and
"Ancestry guardrails in breeding decisions" -- have no corresponding GitHub issue, despite ranking
above every Medium/Deferred item in this batch (Finding #1/Recommendation 2); a future triage session
should file both. **Every Tier 1/2/3 item (#147, #149, #146, #151, #150) plus Deferred-tier #153 are
now fully shipped and closed** -- see the compressed entries below. #152 (Deferred) is in progress
(Slice 3 next). #148 remains unstarted, still needing its scope-narrowing conversation. See
`CHANGELOG.md`.

- [ ] (none remaining -- issue #147 (likelihood-based candidate-parent assignment after marker
      parentage exclusion, Tier 1) is RESOLVED, both slices shipped: design ratified S495
      (`docs/planning/issue147-likelihood-parentage-assignment-plan.md`) -- a 4-agent research
      `Workflow` found CERVUS-style multilocus likelihood-ratio (LOD) scoring (Meagher & Thompson
      1986; Marshall, Slate, Kruuk & Pemberton 1998) is the field's own answer, validated as the
      captive-primate-colony domain's de facto standard by de Groot et al. (2025); ratified
      report-only architecture (no pedigree-mutation write-back) and a 5th read-only "Candidate
      Parent Assignment" tab in `modMarkerGenetics.R` (`PROJECT_LEARNINGS.md` Learning 494). **Slice
      1** (core function) DONE S496: new `markerParentageLikelihood()` + `.markerAlleleFrequencyTable()`,
      extracting a shared `.markerOppositeHomozygoteCount()` helper from `markerParentageExclusion()`
      (Learnings 495-496). **Slice 2** (UI + docs) DONE, issue closed -- S498 (2026-08-09). See
      `CHANGELOG.md`.)

- [ ] (none remaining -- issue #149 (reviewed cross-center identity-mapping workflow with provenance
      export, Tier 2) is RESOLVED, both slices shipped: design ratified S503
      (`docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md`) -- a 2-agent
      adversarial review found and fixed a real data-loss defect (`resolveCrossCenterIds()`'s merge
      step silently dropped every non-`id`/`sire`/`dam` column for merged individuals, about to
      become curator-visible via the new CSV export -- now D10) plus a design-consistency gap (the
      conflict-check helper's row lookup silently depended on an unstated `pedB` id-rewrite order,
      fixed in D2). `PROJECT_LEARNINGS.md` Learning 502. **Slice 1** (validation core) DONE S504: new
      `checkCrossCenterMapping()` + 8 shared internal helpers extracted from `resolveCrossCenterIds()`;
      the D10 data-loss fix shipped as an explicit, `NEWS.Rmd`-documented behavior change (Learning
      503). **Slice 2** (full UI, confirm gate, exports) DONE S505, closing #149: new
      `R/modCrossCenterIdentity.R` module (this app's first `modalDialog()` confirm gate), 5
      downloadable export artifacts, live `shinytest2` smoke test confirmed both named Dragons
      (modal rendering under bslib; `NA`-cell rendering) (Learning 504). See `CHANGELOG.md`.)

- [ ] (none remaining -- issue #146 (configurable/exhaustive breeding-group candidate retention, Tier
      2) is RESOLVED, both slices shipped: design ratified S507
      (`docs/planning/issue146-configurable-exhaustive-breeding-group-retention-plan.md`,
      `PROJECT_LEARNINGS.md` Learning 506) -- an original empirical benchmark found lower-kinship
      (more diverse) candidate pools are the SLOWER case for exhaustive enumeration (n=20 @ 5%
      density: 5.5s; n=25: >60s), and that the real `qcBreeders` fixture already produces 1000
      distinct partitions across 1000 trials at `numGp=2`, together grounding a `numGp==1`-only
      scope. **Slice 1** (mechanical `maxCandidates` parameterization on `groupAddAssign()`, default
      5, `R/groupAddAssign.R:200`) DONE S508. **Slice 2** (exhaustive enumeration mode) DONE S510,
      closing #146: new `.enumerateMaximalIndependentSets()` (hand-rolled Bron-Kerbosch, Bron &
      Kerbosch 1973 / Tomita et al. 2006, no new dependency) + a Breeding Group Formation tab
      **Exhaustive enumeration mode** checkbox toggle; live `shinytest2` smoke test confirmed both
      the completed and hidden (ineligible) cases. See `CHANGELOG.md`.)

- [ ] (none remaining -- issue #151 (individual mate-pair analysis alongside breeding-group
      optimization, Tier 2) is RESOLVED, both slices shipped: design ratified S511
      (`docs/planning/issue151-individual-mate-pair-analysis-plan.md`) -- reused the existing
      pair-eligibility pipeline (`kinMatrix2LongForm()`/`filterPairs()`/`filterAge()`) unmodified,
      captured `modMarkerGeneticsServer()`'s previously-discarded `markerKinshipMatrix` reactive, and
      ratified raw sortable columns with no invented composite score (no such ranking precedent
      exists anywhere in the package). **Slice 1** (core `reportMatePairs()`, script-callable) DONE
      S512. **Slice 2** (new "Mate Pair Analysis" tab, `R/modMatePair.R`, wiring the marker-kinship
      capture) DONE S513, closing #151 -- fixed a real 0-row-crash bug found along the way in
      `reportMatePairs()`; live E2E smoke test (8/8 assertions) confirmed the marker-kinship wiring.
      `PROJECT_LEARNINGS.md` Learnings 513-514. See `CHANGELOG.md`.)

- [ ] (none remaining -- issue #150 (de-identified pedigree export workflow for approved data
      sharing, Tier 3 policy-gated) is RESOLVED, both slices shipped: owner approved formalizing this
      via `AskUserQuestion` before any technical research (sequencing audit Finding #3); design
      ratified S514 (`docs/planning/issue150-deidentified-pedigree-export-plan.md`,
      `PROJECT_LEARNINGS.md` Learning 516) -- found and scoped a real defect: `obfuscatePed()`'s
      independent per-Date-column shift could invert an individual's birth/exit order and produce a
      negative age. **Slice 1** (core function) DONE S515: new `linkedDateShift` parameter (default
      `TRUE`) on `obfuscatePed()` fixes the defect (invariance-tested, not just bounds-checked); new
      `.buildDeidentificationManifest()` helper. **Slice 2** (full UI module, confirm gate, exports)
      DONE S516, closing #150: new `R/modDeidentifiedExport.R` module (3 downloads: de-identified
      pedigree, manifest, re-identification key), reusing Cross-Center Identity's `modalDialog()`
      confirm-gate shape. See `CHANGELOG.md`.)

- [ ] (none remaining -- issue #153 (linkage-aware and haplotype-block metrics for marker data,
      Deferred/scientific tier) is RESOLVED, all 5 slices shipped: design ratified S519
      (`docs/planning/issue153-linkage-haplotype-block-metrics-plan.md`) -- found a real captive
      -macaque STR panel (de Groot et al. 2025) has no cM genetic-map data and is multiallelic, and
      that classical LD/haplotype-block methods assume unrelated sampling, violated by a pedigreed
      colony (Excoffier & Slatkin 1998); haplotype/block-level exports were also found to be MORE
      re-identifying than single-locus data, not less (Lin, Owen & Altman 2004; Erlich & Narayanan
      2014). Ratified building both a pedigree-valid primary metric (Hill & Weir 2011-style
      realized-relatedness variance) and a caveated descriptive secondary metric (pairwise D'/r²,
      same-chromosome only), plus a new multiallelic-tolerant ingestion path and a new tab inside
      `modMarkerGenetics.R`. **Slice 1** (`checkLocusMetadata()` + a new 12-locus multiallelic STR
      fixture) DONE S520. **Slice 2** (`checkLinkageMarkerGenotypeFile()`, multiallelic-tolerant
      ingestion) DONE S521. **Slice 3** (`markerRealizedRelatednessVariance()`) DONE S522. **Slice
      4** (`markerLdBlock()` + `obfuscateLdBlocks()`) DONE S523. (S521-523 each shipped without their
      own `BACKLOG.md` narrative entry -- backfilled at S524 close-out, see `PROJECT_LEARNINGS.md`
      for that gap.) **Slice 5** (a 6th "Linkage and LD Block Metrics" tab in `modMarkerGenetics.R`,
      curator-controlled LD-block export reusing issue #150's confirm-gate pattern) DONE S524,
      closing #153. See `CHANGELOG.md`.)

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

**Progress (S532, 2026-08-12):** Issue #152 Slice 3 -- the new `computeGenomicROH()` F_ROH
metric (D6) -- is now DONE, per `docs/planning/issue152-sequence-input-genetic-metrics-plan.md`
§5 Slice 3. Full strict TDD PRE-RED->RED->GREEN->REFACTOR cycle, gated by an `AskUserQuestion`
at every transition per `CLAUDE.md`'s Development Process Contract. Three genuine judgment
calls the design left open were ratified via a dedicated Pre-RED `AskUserQuestion` round
(all recommended options chosen): both a heterozygous AND a missing genotype end a
run-of-homozygosity; F_ROH's denominator (`genomeLength`) is a single value shared across
every individual -- summed per-chromosome full-coverage-locus span from `locusMetadata`,
Ceballos et al. (2018)'s L_autosome convention, not recomputed per individual (avoids
conflating an individual's own missingness with inbreeding); defaults `minSnp = 50L`,
`minBp = 1e6` (1 Mb matches PLINK's own `--homozyg-kb` default; 50 SNPs is scaled down from
PLINK's literal 100 for this package's sparser GBS-scale target tier, D1). New
`R/computeGenomicROH.R` reuses `checkLocusMetadata()`'s existing 3-tier coverage
classification to exclude any locus lacking full chrom+pos coverage from both the ordered
walk and the denominator (warned, not treated as a run-breaking gap) -- ~150 lines,
loop-based per individual/per chromosome (this slice is new code, not one of D5's two named
rewrite targets, so no vectorization requirement applied). 9 new `test_that` blocks in
`tests/testthat/test_computeGenomicROH.R` (40 expectations): a hand-derived 3-individual/
2-chromosome core fixture (exact-fraction expected values, matching `markerFst.R`'s own
convention) plus 8 focused edge cases (heterozygous break, missing break, locus-exclusion
+warning, dual-threshold both directions, a normal zero-segment case with no spurious warning,
absent/NULL `locusMetadata` -> `stop()`, a zero-`genomeLength` -> warning+`NA` case, and
confirmation of the `minSnp`/`minBp` defaults). RED confirmed (9/9 blocks failing, function not
found) before implementation; GREEN passed all 9 blocks (40/40 expectations) on the first
implementation attempt. REFACTOR: fixed 4 `implicit_integer_linter` findings (bare `0`/`1e6`
literals), 0 behavior change, re-confirmed 40/40 still passing. A real mid-close-out finding:
`devtools::check()` first reported only 2 NOTEs (not the expected 3, since the known
~69-77-word spelling-WORDLIST gap did not fire) -- direct `spelling::spell_check_package()`
verification (not assumed) found this session's own new content introduced 6 genuinely new
flagged words (`bp`, `Ceballos`, `gapless`, `Joshi`, `PLINK's`, `ROH`), hand-added to
`inst/WORDLIST` in `LC_ALL=C` byte-order position. Also found and fixed a `PROJECT_LEARNINGS.md`
Learning 530 violation this slice's own first draft made: the `@references Purcell et al.
2007` (PLINK) citation was copied verbatim from `checkLocusMetadata.R`'s existing 11-author
form rather than trimmed to "Purcell, S., et al. (2007)" per Learning 530's own >6-author
rule -- fixed, removing `computeGenomicROH.Rd` as a second independent source of 5
already-known WORDLIST-gap surnames (`Bakker`/`Ferreira`/`Maller`/`Neale`/`Sklar`, still
present via `checkLocusMetadata.R`'s own unchanged citation, out of this slice's scope to
fix). Citation checklist (issue #120): new "Genomic Runs of Homozygosity (F_ROH)" entry added
to `inst/extdata/ui_guidance/population_genetics_terms.html`, matching the file's established
per-metric style. `NEWS.Rmd`/`NEWS.md`: terse entry added (matching the Slice 1/2 entries'
own brevity, honoring this session's own flagged NEWS-verbosity-drift backlog item rather than
adding to it). `_pkgdown.yml`: new `computeGenomicROH` entry added at its correct alphabetical
position in the "All exposed functions" group. `devtools::document()` run, `NAMESPACE`/
`man/computeGenomicROH.Rd` regenerated. Full clean regression 5,457 passed/0 failed/0 error (0
non-baseline offenders); `devtools::check()` 0 errors/0 warnings/2 NOTEs, both confirmed
pre-existing (top-level files; vignettes/figure leftover -- the spelling NOTE is gone, not
hidden: independently re-verified via direct `spelling::spell_check_package()`, not the
abbreviated `❯`-bullet table `BACKLOG.md`'s own S521/S526 findings warn against trusting
alone); `lintr::lint_package()` 0 lints on touched files. Runtime smoke test: n/a --
script-callable only, no Shiny wiring touched this slice, matching the Slice 1/2 precedent.
**Issue #152 stays open -- Slice 4 (the new de-identification primitive,
`R/obfuscateGenotypeMatrix.R`, D7) is the next planned slice**, a separate future session per
the plan's own session-boundary requirement. See `CHANGELOG.md`.

**Progress (S533, 2026-08-12):** Issue #152 Slice 4 -- the new `obfuscateGenotypeMatrix()`
de-identification primitive (D7) -- is now DONE, per
`docs/planning/issue152-sequence-input-genetic-metrics-plan.md` §5 Slice 4. Full strict TDD
PRE-RED->RED->GREEN->REFACTOR cycle, gated by an `AskUserQuestion` at every transition per
`CLAUDE.md`'s Development Process Contract. D7 was already ratified at the design session
(folded into D8's own vote, §11), and the interface catalog (§4) fully specified the
function's shape, so this slice needed no fresh Pre-RED judgment-call round, unlike Slice 3's
3 open decisions. New `R/obfuscateGenotypeMatrix.R` mirrors `obfuscateTwinRelations()`'s/
`obfuscateLdBlocks()`'s established de-identification pattern exactly: reads
`rownames(genotypeMatrix)` as the ids, `stop()`s loudly (never silently drops) if any id is
absent from `map`, otherwise remaps rownames to their alias via `unname(map[ids])` --
genotype cell values, column names (loci), and row/column order are all untouched by
construction. 3 new `test_that` blocks in `tests/testthat/test_obfuscateGenotypeMatrix.R`:
remap-and-values-unchanged, stop-on-missing-id, and a round-trip through the real map
`obfuscatePed(ped, map = TRUE)` returns -- mirroring the established test shape for this
function family. RED confirmed (3/3 blocks failing, function not found) before
implementation; GREEN passed all 3 blocks on the first implementation attempt. REFACTOR: a
first lint pass mistakenly used `lintr::linters_with_defaults()` instead of the project's own
`.lintr` config, surfacing 4 false-positive-looking findings (camelCase naming, indentation)
this project's own config explicitly permits/disables -- caught before treating any of them
as real; re-run with the correct `lintr::lint_package()` (no override) found 0 lints, so no
refactor changes were needed. `PROJECT_LEARNINGS.md` Learning 539 records the near-miss.
`devtools::document()` regenerated `NAMESPACE`/`man/obfuscateGenotypeMatrix.Rd` plus the
`@family obfuscation` cross-reference in 6 sibling `.Rd` files (collateral, expected).
`NEWS.Rmd` gained a terse entry (rendered to `NEWS.md` via `rmarkdown::render()`, matching
this file pair's established regeneration convention); `_pkgdown.yml`'s "All exposed
functions" group gained the new export at its correct alphabetical position, confirmed via
`test_pkgdown_reference_config.R`. Citation checklist (issue #120) and tutorial/article
checklist (Session 436): N/A this slice, per the design doc's own §9 checklist mapping (Slice
4 is not a displayed statistic and ships no UI). Full clean regression 0 failed/0 error;
`devtools::check()` 0 errors/0 warnings/2 NOTEs, both confirmed pre-existing (vignettes/figure
leftover; top-level files -- `methodology_trim.py`, root-caused this session to the
`.Rbuildignore` typo above, not a mystery). A first `devtools::check(cran = FALSE)` call
misleadingly returned only 1 NOTE -- caught before accepting it, per Learning 538's own "a
lower NOTE count is not automatically good news" rule; `cran = FALSE` is a non-default
argument that suppresses the CRAN-incoming-style top-level-files check, and re-running with
the plain default (`cran` omitted, `= TRUE`) reproduced the documented 2-NOTE baseline
exactly. `PROJECT_LEARNINGS.md` Learning 539. Runtime smoke test: n/a -- script-callable
only, no Shiny wiring touched this slice, matching the Slice 1/2/3 precedent.
**Issue #152 stays open -- Slice 5 (the full module tab, wiring, curator-controlled export,
and documentation, D8/D9) is the next and final planned slice**, a separate future session per
the plan's own session-boundary requirement. See `CHANGELOG.md`.

**Progress (S535, 2026-08-12):** Issue #152 Slice 5 -- the full module tab, wiring,
curator-controlled export, and documentation (D8/D9) -- is now DONE, closing issue #152 (all 5
slices shipped). Per `docs/planning/issue152-sequence-input-genetic-metrics-plan.md` §5 Slice 5.
A dedicated Pre-RED `AskUserQuestion` round resolved 3 genuine judgment calls the interface
catalog left open (all recommended options chosen): genome-scale kinship/heterozygosity/Fst
reruns reuse the EXISTING `genotypeFile`/`genotypeFileB` inputs (validator swapped to the
confirmed-superset `checkSequenceGenotypeFile()`), not a dedicated duplicate tab; F_ROH's
`locusMetadata` sidecar reuses the EXISTING `locusMetadataFile` input already wired to issue
#153's own tab (D3's shared-vocabulary intent); the curator export covers exactly 3 artifacts
(de-identified genotype matrix, de-identified F_ROH table, manifest), not all 4-5 possible
tables. New `R/obfuscateGenomicROH.R` (`obfuscateGenomicROH()`, a new de-identification
primitive for computeGenomicROH()'s id-column table shape -- none of the existing `obfuscate*`
siblings fit). New "Genomic ROH (F_ROH)" tab in `R/modMarkerGenetics.R`: `sequenceRohTable`
reactive, curator confirm-gate export (Generate Preview -> Confirm -> Confirm-OK -> 3
downloads), `.buildSequenceExportManifest()` helper. 13 new tests (RED->GREEN->REFACTOR each
gated by `AskUserQuestion`); full clean regression 0 failed/0 error (2,127 blocks).
**A real bug found and fixed via this slice's own Phase 3E live verification** (not caught by
testServer alone): `sequenceRohTable` passed `locusMetadata()`'s ALREADY-checked output
(`checkLocusMetadata()` appends a `coverage` column) into `computeGenomicROH()`, which
internally re-runs `checkLocusMetadata()` expecting the raw 3/4-column shape -- silently
mislabeled `coverage` as `cM` on a 3-column fixture (no error, wrong data) and threw loudly on
a real 4-column (with `cM`) fixture, reproduced live against the actual committed Slice 1
fixture. Fixed by stripping the `coverage` column before the second check; a new regression
test (4-column, with-`cM` fixture) added. **A second finding, NOT a defect**: a live probe
found `shinytest2`/`chromote`'s headless browser never renders a `showModal()` modal's DOM for
EITHER this tab's export gate OR the already-shipped issue #153 LD-block export's identical
pattern -- a pre-existing harness limitation predating this slice, filed to this file's own
Housekeeping section (found S535) rather than attempted mid-session. The live E2E test
(`tests/testthat/test-e2e-marker-genetics-genomic-roh-module.R`) verifies everything through
Generate Preview against the real Slice 1 fixture at full 50x1,000-locus scale (zero console
errors); the Confirm-modal step is documented and gracefully skipped, with the server-side
confirm sequence proven correct by `testServer()`. `devtools::check()` 0 errors/0 warnings/2
NOTEs (both confirmed pre-existing: vignette/figure leftover; the separately-tracked
`inst/WORDLIST` gap) -- verified via the RAW `Status: N NOTEs` line, not the abbreviated
`❯`-bullet table alone, per Learning 538's own discipline; 1 genuinely new flagged word
(`computeGenomicROH`, this session's own new file) hand-added to `inst/WORDLIST`, matching the
Slice 1 precedent of adding only what the session's own new content is responsible for.
Citation checklist (issue #120): N/A, already satisfied at Slice 3. Tutorial/article checklist
(Session 436): DONE -- a new "Genomic ROH (F_ROH)" section added to
`vignettes/articles/colony-manager-guide.qmd` with a real screenshot from the live app.
`_pkgdown.yml` reference-coverage guard: DONE (`obfuscateGenomicROH` added). `a2interactive.Rmd`
checklist: deferred per its own standing rule, not this slice. `PROJECT_LEARNINGS.md` Learning
541. **Issue #152 closed** -- all 5 slices (ingestion+fixture, performance rewrite, F_ROH
metric, de-identification primitive, full module+export+docs) shipped across Sessions 525-535.
See `CHANGELOG.md`.
