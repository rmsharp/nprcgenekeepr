# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Up Next

- [ ] **Move the version to 3.0.0 just before release (READY at release time, Effort S)** --
      the owner decided (S855) the next release is **3.0.0**. Until then `DESCRIPTION`, the
      `NEWS.Rmd`/`NEWS.md` heading, `README.md` and `ROADMAP.md` stay at 2.0.0.9000 on purpose.
      At release prep: set `DESCRIPTION` to 3.0.0, retitle the `NEWS.Rmd` dev block to 3.0.0 and
      re-knit `NEWS.md`, reinstall the package and re-render `README` (Learning 376), and update
      the 2.0.0.9000 cites in `ROADMAP.md`. The paper-dependency item below also waits on a
      released 3.0.0.

- [ ] **Create a tutorial for prospective contributors** (owner-requested 2026-09-26; DECISION
      NEEDED, Effort M) -- there is no contributor guide today: measured 2026-09-26, no
      `CONTRIBUTING.md` or `CODE_OF_CONDUCT` at the repo root or in `.github/` (which holds only
      `workflows/`). Candidate contents, from what this project's own docs already say: getting set
      up (clone, `renv::restore()`, `pkgload::load_all()`); where things live (`R/` functions, the
      modular Shiny app `appUI.R` + `appServer.R` + `mod*.R`, `tests/testthat/`, the Quarto
      articles under `vignettes/articles/`, `inst/extdata/`); running tests (the fast single-file
      command, the full suite, `devtools::check()`); the write-tests-first workflow; lint;
      roxygen / `man/` / `_pkgdown.yml` and `NEWS.Rmd` expectations; and how to propose a change.
      **Decisions the pickup needs from the owner first:** (a) form and home -- a
      `CONTRIBUTING.md` plus a pkgdown article, or a Quarto article alone; (b) how much of this
      project's internal discipline (strict RED/GREEN/REFACTOR phase gates, the session protocol)
      is asked of outside contributors versus kept internal; (c) audience -- R developers,
      colony managers who script, or both. The tutorial/article documentation checklist in
      `CLAUDE.md` applies; take the commands from its "Build / Test / Verify" section and re-check
      them rather than copying them from here.

- [ ] **Earlier-snapshots follow-ups after #170 (two threads left, extracted S1040 when the
      #170 block came off; #170 is closed; the tutorial thread was done S1042, the trend chart's
      console notice and the notice's 200-character cut S1049)** -- design and what was built:
      `docs/planning/retrospective-snapshot-backfill-plan.md` sections 5.3-5.4.
      (1) **Build cost on a larger colony** (BLOCKED --
      needs a studbook above 3,694 rows from the owner, Effort S): the cost line's quarter of a second a date per
      1,000 iterations (`describeBackfillCost()`, `R/modSnapshotTrends.R`; S1065) is measured on the 2,590-animal jmac
      studbook (53 dates, 12.6 s) and the 3,694-row example (49 dates, 9.4 s), so a bigger colony is unmeasured.
      (2) **A script word in the panel's notice** (DECISION NEEDED, Effort S): the function's
      failed-dates warning says "listed in 'skipped'" and the panel shows it as is, while its
      table is headed "Dates not built"; reword the message for both readers, or leave it.

- [ ] **Tutorial leftovers after the S1043 inventory pass: twin-corrected kinship, and a guard for
      omitted exports** (DECISION NEEDED, Effort S; found S1043) -- the pass named the six functions
      and the two parameters it had left (the next pass compares against this pass's commit
      `649389386`, not S541): 170 of the 236 exports are still never named, which is not a gap
      (the tutorial is a walkthrough, not a reference). Three things are open. (1) **`twinRelations`**
      is used in a call only on `makePedigreeMatingLayout()`; the `reportGV()` argument list names it
      and points to `?reportGV`, and the "Passing a Kinship Matrix You Already Have" section says
      `kinship()` takes it, but no output shows a twin-corrected kinship matrix (`kinship()`,
      `reportGV()`, `gvaConvergence()`, `createSimKinships()` and `cumulateSimKinships()` accept it).
      `checkTwinRelations()` wants a same-sex pair for an MZ call and the tutorial's pair is a
      mixed-sex UZ pair, so a demo needs its own pair; whether one belongs is a decision. (2) **No
      guard notices a new exported function the tutorial omits**; one would need an allow-list of the
      never-named set (170 today), so whether it is worth the upkeep is a decision. **Method for the
      next inventory:** formals at the old commit from a scratch `git worktree` through
      `pkgload::load_all()` run in the main checkout (renv), against today's; search each name with a
      boundary that ignores `_` (the tutorial writes `__fn__`, and `\b` treats `_` as a word
      character, so it misses them: S1043's first total of 182 was 176) and confirm every "unnamed"
      claim with `grep -F` on the committed text. Pattern for a section:
      `tests/testthat/test_inventoryTutorialSections.R` (the shared readers `insideChunk()`,
      `sectionProse()` and `chunkOptionText()` are in `helper-pageText.R`).
      (3) **A new parameter since the pass** (S1045, `3ba3fd51b`): `plotSnapshotTrends()` takes
      `ncol`, the number of panel columns. The tutorial's chart has 3 panels, where the default
      grid is right, so whether the tutorial shows `ncol` is a decision.

- [ ] **Act on the LabKey integration research recommendations** (BLOCKED -- remainder
      needs a live LabKey server to test/observe, Effort M) — research pass DONE
      (`docs/research/labkey-integration-options-2026-06-19.md`, S143); Recs #1-#5 all DONE,
      S144-S152 (S155 added richer file-read errors), see `CHANGELOG.md`: `setLabKeyDefaults()`
      (optional API-key auth), `Rlabkey (>= 3.2.0)`, `defaultSiteParams()`, the internal
      `getPedigreeSource()` (`labkey`/`dataframe`/`file`), `getLkDirectRelatives()` delegating its
      walk to `getPedDirectRelatives()` (a deliberate, owner-accepted behavior change: it now
      returns the full connected component), and the exported `getFileDirectRelatives()` and
      `getFocalAnimalPedFromFile()` (the Shiny focal-animal workflow now runs offline). The live
      ONPRC/SNPRC server version (doc §8.1) is still unobserved. **Still deferred:** a
      non-LabKey other-EHR provider on the same seam; server-side filtering / `executeSql` /
      consuming the centers' `study.Pedigree`/`ehr.kinship` (the research doc defers this until
      pull size is measured and per-center query availability/permissions are confirmed; it needs
      a live LabKey server to test/observe, and a naive focal-id server filter is incompatible
      with the client-side connected-component walk).
- [ ] **Work with LabKey (Josh Eckels) to update the LabKey integration** (owner-requested
      2026-09-26; BLOCKED -- needs the owner to make contact, and the deferred technical work also
      needs a live LabKey server; Effort M, not a coding task until scoped) -- companion to
      "Act on the LabKey integration research recommendations" above, which records what is DONE
      (Recs #1-#5), what is unobserved (the live ONPRC/SNPRC server version) and what was
      deferred pending per-center confirmation (server-side filtering / `executeSql`, consuming
      the centers' `study.Pedigree` / `ehr.kinship` queries, a non-LabKey EHR provider). Nothing
      in this repository records any contact with LabKey yet. **Suggested first step (the
      owner's):** talk with Josh Eckels about the current LabKey API and `Rlabkey` direction and
      what he would change or add on the LabKey side, using the deferred questions from that item
      as the agenda; then decide which package changes follow and file each as its own item.
      Research base: `docs/research/labkey-integration-options-2026-06-19.md`.

- [ ] **Build a kinship2-similar standalone pedigree package from this repository's code —
      committed, deferred** (disposition S742, 2026-09-20; BLOCKED -- prep steps ALL DONE
      (D-1 S744, D-2 S745, D-3 S746); the remaining blocker is the S738 revisit conditions
      only, scoping doc §6: engine churn calms + an
      accepted CRAN release; Effort L, its own planning session first when unblocked) --
      owner disposition closing the S739 two-step discussion item (step 1: gap analysis
      DONE S741, `docs/research/kinship2-feature-gap-analysis-2026-09-20.md`, 15 EQ /
      8 PARTIAL / 2 ABSENT; step 2: this decision — full record in `CHANGELOG.md` S742).
      **The package WILL be built; only the timing is deferred ("gates stand").
      Purpose (owner-stated): a standalone near-equivalent of kinship2 carrying
      nprcgenekeepr's enhanced features — particularly the pedigree drawing, annotation
      ability, and interactivity; nprcgenekeepr may eventually consume it, but that is NOT
      the primary goal** (i.e. plan a sibling product first, not an extraction nprcgenekeepr
      must immediately depend on). **Ratified scope (S742, so the plan session doesn't
      re-derive):** drawing surface IN — lift the module-bound decorations
      (`R/modPedigree.R`, about `:689-890`: legend, image export, tooltips) into a script-callable
      visNetwork renderer (the unique value per the gap doc's ecosystem observation; the one
      substantive new-work item); parity closers IN — export the shrink helpers + `bitSize`
      (tested internals in `R/shrinkPedigree.R`: `.bitSizeOf`, `.findUnavailable`, `.findAvailAffected`), port `familycheck` + `ibdMatrix`
      (the two full absences), and user-suppliable layout hints (autohint's override half —
      real engine-surface design); OUT — block-sparse `makekinship` (dense whole-colony
      matrices are current practice); API shape (data-frame-as-is vs kinship2-compat layer)
      DELIBERATELY OPEN — decide at plan time with a prototype in hand.
      When unblocked, the pickup is a planning session (package boundary/plan doc in
      `docs/planning/`, evidence-based inventory). **Prep is done** (D-1 S744, D-2 S745, D-3 S746;
      each is in `CHANGELOG.md`): `makePedigreeMatingLayout(kinshipMatrix = )`
      (`R/makePedigreeDiagramData.R`) is the injectable boundary the package needs, and the 13
      `R/positionTreeApportion.R` functions carry `@noRd` roxygen. **One prep claim has drifted
      (found S896):** D-2 took every test outside the layout core's own files off
      `.buildMatingUnitForest()`, but `tests/testthat/test_newsReleaseState.R:234,248` has called it
      directly since S790-S791 (NEWS release-state counts; it is not one of the scoping doc's 9
      core test files), so the planning session must re-run the grep and decide where that test
      lives. (The owner accepted S667's recommendation NOT to split the layout core, recorded S738;
      the prep steps stand whether or not a split ever happens.)
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
      the canonical design's own deferred H4 remedy (recorded as `docs/planning/ledger-trimmer-design.md`
      §10.2, a file that is not in this repo; "the lever is receipt size, and the mechanism would be a norm plus a check, not
      an archiver") is worth adopting for `CHANGELOG.md` specifically. **Measured S897
      (2026-10-04):** `CHANGELOG.md` went from 37,593 B (its 2026-09-27 trim) to 258,724 B in 7
      days, which is what raised the trimmer's `SRF_RED` (7.9455); the owner-approved `--force`
      trim left it at 25,172 B. The owner's choice of lever (shorter claim/close-out entries and
      receipts) is still open.
- [ ] **`BACKLOG.md`'s own ledger-size housekeeping -- editorial compression, not a
      `methodology_trim.py` config** (found S518, 2026-08-11, READY, Effort L; RECURRING --
      last pass S896, 2026-10-04) -- `BACKLOG.md` is one of the dashboard's HIGH-risk
      ledger-size items but does not fit `methodology_trim.py`'s chronological-record model:
      its `##` sections are standing *topical* categories that accumulate resolved-item
      narrative indefinitely, not dated newest-on-top records. The file's own header states the
      remedy ("Open, actionable work only... for history see `CHANGELOG.md`"). Sections
      **regrow** as later sessions append their own progress narrative (S606 found the S531
      "fully RESOLVED" claim was only a snapshot), so this is a recurring maintenance pass,
      never a one-time fix.
      **Pass history** (each pass has its own `CHANGELOG.md` entry; S890 checked the figures
      quoted here against those entries): S529 Housekeeping section (652 -> 389 lines; its
      inventory found 2 items with no ledger entry, a real FM #27 gap, backfilled before
      compressing); S530 "Pedigree diagram vs kinship2" (896 -> 286); S531 "Genetic-metrics PDF
      audit follow-ups" (753 -> 267); S606 re-compressed Genetic-metrics after regrowth (304 ->
      80); S752 (2026-09-21) again (91 -> 62), condensed this history, found "Pedigree diagram vs
      kinship2" NOT regrown (286 -> 156); **2026-09-24** (ad hoc, owner-picked): removed 2
      completed items, fixed 4 stale statements, compressed the LabKey item (44 -> 15) and the
      kinship2 DONE narrative (84 -> 20), deleted the 3 resolved sections (55 lines; file 432 ->
      378; the NEW-53 ledger gap found there was backfilled); **S890** (2026-10-03): condensed the
      docs-audit item (55 -> 48) and this history (50 -> 38); file 552 -> 533 lines (58,228 ->
      46,731 B); **S896** (2026-10-04): compressed the four S890 candidates (PED_GV 20 -> 13 lines,
      standalone-package 37 -> 34, chromote 23 -> 17, kinship2 preamble 20 -> 13); its checks
      corrected a stale `:1661` line reference and a drifted D-2 claim, and recomputed the PED_GV
      count of 9 from the triage table; file 533 -> 514 lines (46,731 -> 43,766 B).
      **Method (every pass, all steps):** before compressing anything to a pointer, (1) verify
      `CHANGELOG.md` + `docs/archive/CHANGELOG-*.md` carry an entry heading for every session
      number cited AND that the load-bearing facts are inside those entries (a heading alone proves
      little); (2) confirm every cited Learning / doc path resolves and every issue state via
      `gh issue view`, not prose; (3) extract any buried open thread as its own item first; (4)
      replace whole line ranges mechanically (Learning 537: a partial `old_string` leaves later
      paragraphs duplicated beside the new bullet); (5) leave open items byte-untouched; (6)
      re-read the compressed result end to end.
      **Candidates for the next pass (measured S896, line counts after this pass; re-grep, sizes
      not anchors):** this item's own history (41 lines) and the paper item (24). The
      standalone-package item is still 34 lines but is nearly all ratified-scope open text;
      leave it. Regrowth, for scale: 378 lines on 2026-09-24, 599 at S853, 552 before S890,
      514 after S896.

- [ ] **Take the methodology files the S1032 sync held back (BLOCKED -- on a fix to `close_out_report.py` in the
      methodology repo, Effort S once it ships)** (found S1032, 2026-10-22) -- the sync copied 7 of 10 files and, at the
      owner's word, held back `SESSION_RUNNER.md` (2 versions behind), `SAFEGUARDS.md` (1 behind) and the new
      `close_out_report.py` (not installed). The newest runner (commit `8f63492b`) makes section 3G run
      `python3 close_out_report.py` and print its output as the last message; v1.2.0 reads the example box in
      `HANDOFFS.md`'s front matter as the newest receipt and refuses (`refused: newest receipt (S<N>) is <pending |
      complete>`), here and on the blank seed. The runner's Oct 12 commit `95005e87` (its subject: a gate run that reads
      unmeasured gates is repaired and repeated, or each gate is named) is held with it. Evidence, a tested 4-line fix and
      the draft upstream report, **not posted anywhere** (where to post it is the owner's call):
      `docs/audits/CLOSE_OUT_REPORT_EXAMPLE_BOX_2026-10-22.md`. **What is left:** when the script reads this ledger, sync
      again (`bin/sync --force`, then the trimmer patch per `docs/conventions/CLOSEOUT_CHECKLISTS.md`) and, before keeping
      the script, print a report from a ledger whose newest receipt is complete; `bin/status` lists these three files
      until then.

- [ ] **Breeding Groups: groupings with equal scores are not listed in the order they were found (DECISION NEEDED,
      Effort S; found S1057)** -- `groupAddAssign()` lists its retained groupings best first and breaks a tie by the slot
      each one holds (`R/groupAddAssign.R:330-334`, `order(-retainedScores, seq_along(retained))`), while the comment
      there says "by discovery order": a later grouping that replaces a worse one takes that one's slot. Measured S1057
      (the example's top 20 ranked living animals, 3 groups, kinship limit 0.25, seed 5, 1,000 trials): all five kept
      groupings score 6, the first was found at trial 7, and the one listed first (the tab selects candidate 1,
      `R/modBreedingGroups.R:865-867`) was found at trial 18 (the five in listed order: trials 18, 7, 8, 23, 26). No
      score is wrong. To decide: correct the comment only, or list ties in the order found (that changes which grouping
      the tab shows first for the same seed, so tests that pin a result would be re-checked).

- [ ] **Two `@inheritParams` lines with nothing to inherit (READY, Effort S; owner-reported S1060)** -- RStudio's Build ->
      Document (roxygen2 8.0.0) prints "In topic 'addParents': @inheritParams failed. All parameters are already
      documented; none remain to be inherited." and the same for 'removeUninformativeFounders': each function takes only
      `ped`, which its own `@param` documents. Delete `R/addParents.R:13` (`@inheritParams reportGV`) and
      `R/removeUninformativeFounders.R:11` (`@inheritParams trimPedigree`); `devtools::document()` should leave `man/`
      unchanged and print neither message (check both). The same run's pandoc line, "Deprecated: --mathjax", is not this
      item: pandoc 3.12.1 deprecates the flag rmarkdown 2.31's `html_vignette` passes, it only shows because the project's
      roxygen options include the vignette roclet (`nprcgenekeepr.Rproj:25`), and `devtools::check()` gives 0 warnings.

- [ ] **Mate Pair's default run uses about 1 GB of app memory (DECISION NEEDED, Effort M; found S1062)** -- on the
      example the default population, "All alive (no recorded exit)" (`R/modMatePair.R:39-45`), is 1,704 animals (332
      by `isLivingAnimal()`), and Find Eligible Pairs raised the app's resident memory from 867.2 to 1,946.3 MB in
      11.3 s: `reportMatePairs()` builds the long form of every pair among them (`R/reportMatePairs.R:207`) before its
      sex, age and exclusion screens. The kinship block itself is 22.4 MB. Measured in the running app
      (`docs/planning/app-kinship-memory-design.md` sections 2.1 and 9, F2). Two levers, not measured apart: build
      only the pairs that pass the screens (the same report; it needs its own exactness tests), or the default
      population's rule (that changes what the tab shows). To decide: either, both, or leave it.

- [ ] **Marker Genetics' Realized Relatedness table holds every pair (DECISION NEEDED, Effort M; found S1062)** --
      opening the "Linkage and LD Block Metrics" tab (`R/modMarkerGenetics.R:227`) runs
      `markerRealizedRelatednessVariance()` on the whole kinship matrix (`:735-751`;
      `R/markerRealizedRelatednessVariance.R:119`), with no genotype file needed: 6,824,665 rows on the example, built
      in 8.31 s with a 707.6 MB peak, a 390.9 MB table kept while the tab shows it; the app's memory rose 716 MB in
      13.5 s (design sections 2.1 and 9, F3). D5's change leaves it as it is, because the table itself needs every
      pair. To decide: related pairs only (as the plan's D8 asks of the relationship download), a chosen set of
      animals, a button that builds it, or leave it.

- [ ] **Summary Statistics keeps the whole relationship table after a download (DECISION NEEDED, Effort S; found
      S1062)** -- `relationshipData()` is a cached `reactive()` (`R/modSummaryStats.R:436-443`) that serves both
      relationship downloads (`:891-907`): 6,824,665 rows and 234.7 MB on the example (built in 3.21 s, peak 693.5 MB),
      kept until the pedigree changes (design section 9, F4). To decide: build it inside each download, so nothing is
      kept and a second download rebuilds it (3.21 s), or keep it, so the two downloads share one build.

- [ ] **The scheduled `shinytest2` run of 2026-10-26 failed in the Diagram tab's deceased-slash test (READY, Effort S;
      found S1064; no GitHub issue, per the CI-break convention)** -- run `40286217416` (07:30 UTC, head `ab3122abc`):
      `tests/testthat/test-e2e-pedigree-module.R:475` "slash past a circle's outline" measured 0.37, expected > 1.1,
      and `:477` "square and circle overhang difference" 0.91, expected < 0.12; the file's other 127 tests passed.
      Not diagnosed. This was the first CI run of the test itself: S1028 added it (`ec2f53511`, 2026-10-21, green in
      the local browser tier), and no push went out between 2026-10-20 (`c5545b016`) and 2026-10-25 20:24
      (`63bc354f7`), so every run before was on older code. Candidates, unmeasured: the runner's Chrome renders the
      outline or the slash differently (pixel width, device pixel ratio), or a later change to the drawing (S1029's
      sections, S1030's `drawPedigreeDiagram()`, S1060's solver). First step: run the test from a scratch install on
      this Mac (`R CMD INSTALL --no-docs --library=<scratch> .`, `R_LIBS=<scratch>:<renv lib>`,
      `RENV_CONFIG_AUTOLOADER_ENABLED=false NOT_CRAN=true NPRC_RUN_E2E=true`), then read the run's Chrome version and
      the measured pixels (`gh run view 40286217416 --log`).
- [ ] **The Build Earlier Snapshots box's "filed under their own rule" reads like a folder (READY, Effort S;
      owner-reported S1065)** -- `R/modSnapshotTrends.R:69-72` says "They are filed under their own rule,
      reconstructedLiving, and never mix with recorded snapshots." The owner asked whether that means a separate
      folder. It does not: the rebuilt rows join the same history table (History, "Download Updated History") with
      `membershipRule` `"reconstructedLiving"` (`R/backfillColonySnapshots.R:220`); the Trends chart draws them as their
      own dashed line (`R/plotSnapshotTrends.R:88`), and Compare Snapshots compares within one rule. Proposed S1065,
      not yet approved (the owner chose to file it for its own session): "They are added to the same history, marked
      reconstructedLiving in its Membership rule column, and drawn as their own dashed line, apart from recorded
      snapshots." No test pins the sentence (`git grep -n "never mix" -- tests/`). Change it test-first in the
      owner's final words, and check the guide's matching step (`vignettes/articles/colony-manager-guide.qmd:1294`).

- [ ] **Breeding Groups: harem trials redo their set-up work every trial (READY, Effort M; owner-raised S1056, filed
      S1066 at the performance campaign's close)** -- 1,000 harem trials on the tutorial's 280 candidates take 10.69 s
      (9.78-11.16) against 5.54 s for 6 plain groups (`Rscript tools/perf/run.R groupAddAssign-harem-1000` and
      `groupAddAssign-1000`, S1066; 27.19 s before the campaign). The extra is the harem's age and sire work
      repeated each trial: `getPotentialSires()` (`R/getPotentialSires.R:20`), `getCurrentAge()`
      (`R/getCurrentAge.R:16`), `groupsWithoutSire()` (`R/groupsWithoutSire.R:33`), `initializeHaremGroups()`
      (`R/initializeHaremGroups.R:20`). The campaign's rules still bind: the same groups for the same seed
      (`identical()` against `groupAddAssignReference()`, `tests/testthat/test_groupAddAssignEquivalence.R`) and
      `groupAddAssign()`'s arguments unchanged; add a gate for the harem scenario (the S1052 rule). Report:
      `docs/audits/PERF_CAMPAIGN_REPORT_2026-10-26.md` section 11.
- [ ] **Pedigree Diagram: about 1.7 s of the 708-animal layout is outside its solver (READY, Effort M; found S1060,
      filed S1066)** -- `diagram-example-direct` takes 5.10 s (4.80-5.22, S1066; 12.81 s before the campaign). About
      1.7 s is outside `.solveSeparationQP()` (`R/makePedigreeDiagramData.R:1606`), 1.0 s of it `Dmat <- t(pmat) %*%
      pmat` (`:1576`), kept at S1060 because `crossprod(pmat)` calls another BLAS routine and could give other bits,
      so other positions, on another platform. First step: profile the other 0.7 s; `crossprod()` only with
      identical positions on CI's three platforms (the pinned positions of the four layout test files, and
      `tests/testthat/test_diagramSolverEquivalence.R`). Gate: `perf_diagram_example_direct_seconds` (5.9 s).
- [ ] **Founder statistics: their memory peak rose a little on larger inputs while their time fell (READY, Effort S;
      found S1058, filed S1066)** -- from Phase 0 to S1066, `calcFGSE()`'s peak went 225.6 to 253.6 MB on the
      generated 10,000-animal colony and 236.5 to 257.5 MB on all 3,694 example animals, and `calcFEFG()`'s 233.2 to
      247.7 MB on all 3,694 (`Rscript tools/perf/run.R gvStages-all` and `gvStages-synthetic10000`), while their time
      fell about tenfold (`calcFGSE()` 1.07 to 0.12 s on the synthetic colony). S1058 saw the rise (225.5 to
      254.1 MB) and recorded no cause. First step: find the step that peaks (`R/calcFounderContributions.R`,
      `R/calcRetention.R`), then decide whether lowering it is worth a change.
- [ ] **The performance campaign's nine fallbacks: move their input types onto the fast paths? (DECISION NEEDED,
      Effort M; owner-raised S1054, filed S1066)** -- each phase kept the pre-campaign code for inputs its new code
      does not take (a factor where text is expected, for example): `rareAlleleCountsGeneral()`, `geneDropGeneral()`,
      `convertRelationshipsGeneral()`, `fillGroupMembersGeneral()`, `fillGroupMembersWithSexRatioGeneral()`,
      `founderContributionMatrixGeneral()`, `retainedFounderAllelesGeneral()`, `kinshipGeneral()` and
      `kinMatrix2LongFormGeneral()`. A probe (S1066) traced all nine through nine harness scenarios and a sex-ratio
      `groupAddAssign()`: none was called on the shipped data (the tracer does count a call: a sparse `kinship()`
      registered one). S1054 found 14 of `geneDropGeneral()`'s 19 test inputs end in an error today. To decide:
      fold some input types in, one test each (the same results, `identical()`), or leave the fallbacks as the old
      code's home for unusual input.

## Pedigree diagram vs kinship2 audit follow-ups (from ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md)
*S435's capability comparison of the issue #129 pedigree diagram against kinship2's drawing
feature set (`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`) produced 8
recommendations, filed S436 as GitHub issues #131-#138. **All are shipped and closed except
#138** (full-colony rendering beyond the 1,500-node cap: `low priority` label, needs its own
scoping session first; tracked on GitHub, not here). The order they shipped in is the sequencing
audit's status line (`docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`). None
reopens issue #129 or the visNetwork-vs-kinship2 technology decision (D2), which stands as
ratified; the
`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd` refresh (S484) has since gone
stale again and carries a status note. Session-by-session record: `CHANGELOG.md`; technical
findings: `PROJECT_LEARNINGS.md` Learnings 410, 411, 485, 488-499. No live item remains here: S921 shipped
the last one (the legend row for the dashed repeat-appearance link; see `CHANGELOG.md`).*

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

- [ ] **Develop paper(s) for peer-reviewed journals** (owner-requested 2026-09-26; DECISION
      NEEDED, Effort L, its own scoping session first; multi-session) -- the owner supplied a
      venue-fit summary (from an AI-assisted conversation) to start from. **Treat its journal
      assessments as unverified leads:** check each journal's current scope, article types and
      fees before committing. Its recommendation, in short: version 3.0 is more than an
      incremental update, so write **two complementary papers** that cite each other -- (1) a
      **software paper** for *The R Journal* or the *Journal of Open Source Software* (package
      architecture, workflows, reproducibility, new features; the canonical citation for the
      package; per the summary, JOSS is very short and citation-like, while *The R Journal* allows
      longer technical descriptions with code examples) and (2) an **applied genetics paper** for
      the *American Journal of Primatology* or the *Journal of Medical Primatology* (how the
      software improves genetic management of captive primate colonies, with realistic examples and
      best practices) -- and optionally (3) a **retrospective paper** on the evolution of
      computerized genetic management in NPRC colonies over past decades (historical and
      methodological, for readers interested in colony-management practice). The summary also
      grouped further candidates into tiers (computational-biology software, conservation
      genetics, statistical computing, and animal-colony-management journals), but **the journal
      names in those tiers were lost when it was pasted** -- only the four above survive -- so the
      pickup must get the original list from the owner. Open decisions: which papers, authorship,
      and what is new in 3.0 relative to the published reference (Vinson & Raboin 2015, *JAALAS*
      54(6):700-707, the package's key reference in `CLAUDE.md`, whose Project Overview also holds
      the NIH grant acknowledgment). Natural dependency, the owner's call: a released 3.0.0 to
      cite (`DESCRIPTION` reads 2.0.0.9000 today); the documentation audit is finished (S1027,
      `CHANGELOG.md`), so the papers' figures match the software.
