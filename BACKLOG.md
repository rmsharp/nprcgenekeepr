# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Up Next

- [ ] **PED_GV audit follow-through -- triage DONE (S781, 2026-09-26), F1 shipped (S782), F4
      shipped (S783), F2's duplicate-id half shipped (S797), F3 shipped (S798); every F-slice is
      done, and what remains is owner decisions (DECISION NEEDED, Effort S each; strict TDD for
      every fix)** --
      `docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md` judged 43 ids against today's code (35
      present, 2 fixed, 4 moot, 2 refuted); its table is the plan, so read it first (its F1 is
      done: `removeUnknownAnimals()` now returns a pedigree with no `recordStatus` column
      unchanged; its F4 is done: `getAncestors()` now stops with a message naming the cycle
      instead of recursing until R aborts, and keeps the documented diamond repeats; F2's
      `addUIds()` half is done: a minted id now skips any id already in the `id` column (S806 found it
      still reuses an id used only as a sire or dam; fixed S808); F2's other
      half, real ids mistaken for placeholders, is done (S807-S811, the `placeholder` mark); F3 is done: the
      `getPotentialParents()` dam fallback no longer re-admits a female the gestation window
      ruled out).
      **Open, all owner decisions:** (a) the overhaul roots,
      none urgent -- the error/return contract (PED-5/6, NEW-28/36), the walk helpers (PED-3, NEW-42; all exported, so an API change), the sim
      driver (NEW-50/51) and constants and HTML builders (NEW-18/19/21/26/57); (b) NEW-24 is already open issue #123 (kept open on purpose after Phase 1 shipped S386; its residuals, which the issue's closing comment says are tracked here, are the `nprcgenekeeprGV` print-method wrinkle -- the class is appended last and there is no bare `print.nprcgenekeeprGV`, near `reportGV.R:353` -- and `getGeneticDiversityStats.R:58` keeping its own `requiredPed` vector; plan §10 items 4-5, both low priority). **The 11 settled ids (PED-7, NEW-39, PED-8, PED-9, NEW-27, NEW-33,
      NEW-44, NEW-47, NEW-58, NEW-59, NEW-60) were closed S818**, and **PED-4 and NEW-54 were closed S881** (the `getPotentialParents()` split; NEW-55 shipped S880), and **NEW-61 was closed S871** (owner: known and unknown founders stay counted differently; documented in `calcFEFG()` and `reportGV()` roxygen), and **PED-2 and NEW-29 were closed S879** (sex-code adoption shipped, S874-S879; PED-7 was already counted closed S818), and **NEW-55 was closed S880**, so 28 remain (the report's "Closure record" sections list them). **Trap:** an id grep of the ledger
      both under- and over-counts (`NEWS.md` once used "NEW-47/48/49" as entry labels), so use the
      report's table, not the old 41-id list.

- [ ] **(Optional, owner decision) One internal `isAddedRecord()` helper for the "added" mask
      (raised S785, deferred at the S785, S786 and S787 REFACTORs; DECISION NEEDED, Effort S)** --
      the mask is written inline four times, all meaning "only the exact status `"added"` is
      special; an `NA`, blank or unrecognized status is a real animal": `convertDate()`
      (`R/convertDate.R:115`) and `removeDuplicates()` (`R/removeDuplicates.R:48`) as
      `!is.na(x) & x == "added"`, `removeUnknownAnimals()` (`R/removeUnknownAnimals.R:31`) as its
      complement, and `correctParentSex()` (`R/correctParentSex.R`, `isAdded`, which also answers
      a `NULL` status with "no added rows"). One helper would put that contract in one place; the
      cost is a cross-file refactor (four R files plus a new file and its tests, so staged commits
      under the 5-file cap, and `SAFEGUARDS.md` asks for plan-mode approval of refactoring), and the
      owner may judge four short copies enough. **Trap** to keep in any helper or caller: a
      negative subscript built from an index that can be empty
      (`ped[-getRecordStatusIndex(ped, "added"), ]`) drops EVERY row when nothing is `"added"`.

- [ ] **`getAncestors()` fails cryptically on an id or parent that is absent from the tree, and
      cannot resolve a very deep acyclic chain (found S783, 2026-09-26, DECISION NEEDED, Effort
      S)** -- both left out of the F4 (cycle) slice by the owner's decision at its Pre-RED gate.
      Probes (S783, hand-built trees; not run through `createPedTree()` of a raw pedigree with a
      dangling parent): (1) `getAncestors("K", list(K = list(sire = "GONE", dam = NA)))` and
      `getAncestors("NOPE", tree)` both stop with "argument is of length zero"
      (`ptree[[id]]$sire` is `NULL`, so `is.na()` is `logical(0)` in `R/getAncestors.R:85-88`);
      (2) an acyclic single-parent chain resolves up to 2,218 generations and aborts with
      R's "evaluation nested too deeply" beyond that (997 before the S783 change; `options(expressions)`
      is 5000; the cause of the increase was not investigated). Real pedigrees are a few dozen
      generations deep, so (2) is recorded for completeness, not as a defect to fix. **Decision
      for the owner on (1):** stop with a message naming the absent id (matches F4's wording
      style), or treat an absent parent as a founder (returns fewer ancestors silently; a behavior
      change for the exported `getAncestors()`, `findLoops()` and `countLoops()`). Callers: only
      `R/makesLoop.R:29-30` and `R/countLoops.R:50`, neither reached from the app.

- [ ] **(Optional, owner decision) Stop the four push workflows from running on pushes that
      change only build-ignored files** (raised 2026-09-24; DECISION NEEDED, Effort S) -- lint,
      pkgdown, R-CMD-check and test-coverage run on every push to `master` with no `paths-ignore`,
      so a push of only `BACKLOG.md`/`CHANGELOG.md`/`HANDOFFS.md`/`SESSION_NOTES.md` still costs a
      ~25-minute R-CMD-check that cannot say anything new. The owner's rule (2026-09-24: "if all
      files edited are in .rbuildignore, there is no reason to ever run CI") is followed today
      only by not waiting for the run. Options: a `paths-ignore` list mirroring `.Rbuildignore`
      in each workflow, or `[skip ci]` in such commits' messages. Caveat for the first: some
      ignored files ARE read by tests (`.github/workflows/*`, `_pkgdown.yml`,
      `.quality-gates.json`, `.Rbuildignore`; e.g. `test_r_cmd_check_workflow_chrome_setup.R` and
      `test_shinytest2_workflow_coverage.R` read the workflow files), so the list must exclude
      those. Not done: it edits CI config, which the owner has not asked for.

- [ ] **Move the version to 3.0.0 just before release (READY at release time, Effort S)** --
      the owner decided (S855) the next release is **3.0.0**. Until then `DESCRIPTION`, the
      `NEWS.Rmd`/`NEWS.md` heading, `README.md` and `ROADMAP.md` stay at 2.0.0.9000 on purpose.
      At release prep: set `DESCRIPTION` to 3.0.0, retitle the `NEWS.Rmd` dev block to 3.0.0 and
      re-knit `NEWS.md`, reinstall the package and re-render `README` (Learning 376), and update
      the 2.0.0.9000 cites in `ROADMAP.md`. The paper-dependency item below also waits on a
      released 3.0.0.

- [ ] **Audit the internal and user-facing documentation for stale information and stale
      diagrams** (owner-requested 2026-09-26; READY, Effort L -- one audit report per session, so
      expect several slices) -- the owner noticed that `vignettes/articles/pedigree-diagram.pdf`
      and `vignettes/articles/kinship2-fidelity-validation.pdf` show stale figures. Measured
      2026-09-26 (the staleness itself is the owner's observation, not yet re-checked): both PDFs
      were renders dated 2026-08-25 (`.gitignore:21` ignores `vignettes/*.pdf` but not
      `vignettes/articles/*.pdf`). **Corrected S853:** `kinship2-fidelity-validation.pdf` is TRACKED
      (`git ls-files`), and `pedigree-diagram.pdf` was untracked by `3a8c026bb` (S831) and is gone from
      disk. Their their `.qmd` sources were last edited 2026-09-17/18; the
      tracked static image files sit under `vignettes/articles/pedigree-diagram-img/` (5),
      `vignettes/articles/kinship2-fidelity-validation-img/` (8) and
      `vignettes/articles/shiny_app_use/` (50). **First question for the pickup:** is the
      staleness only in the old local PDFs (fix: delete, or re-render and ignore them) or also in
      the committed sources and static images (fix: regenerate them from the current code)? Earlier
      handoffs recorded the PDFs as "sitting locally, uncommitted by design". **Scope** (each a
      slice with its own report under `docs/audits/`, per `AUDIT_WORKSTREAM.md`): (1) user-facing
      -- the README, `vignettes/` and `vignettes/articles/*.qmd` (including every static image),
      the pkgdown site, `NEWS.Rmd`, the in-app guidance pages under `inst/extdata/ui_guidance/`,
      and the `man/` pages; (2) internal -- `docs/` (planning docs, audits, research),
      `ROADMAP.md`, `CLAUDE.md`, this file. **Method:** check every claim, number, screenshot and
      diagram against today's code or output (regenerate the figure from the current source and
      compare; count, don't recall); list each stale item with its source path; fix it or file it.
      **Found S789, for this audit:** the user manual
      (`vignettes/manual_components/_pedigree_browser.Rmd`) worded the Diagram limit as "750 animals
      ... the limit drops to 400 when the Rectilinear edge style is selected", which read
      misleadingly since Rectilinear is the default (the default limit is 400); fixed S828. The roxygen point in
      the male-left item above is the same kind of finding. **Measured S805, for this audit:** the
      5 classic-structure figures under `vignettes/articles/pedigree-diagram-img/` are current (2
      re-rendered and committed S805; the other 3 differ from a fresh
      `pedigree-diagram-exemplar-renders.R` run by anti-aliasing only), so the committed images WERE
      partly stale, not just the local PDFs; the `kinship2-fidelity-validation-img/` (8) and
      `shiny_app_use/` (50) images are not yet checked. Related, not duplicated: the `NEWS.Rmd`
      release-state sweep (above), the deferred `a2interactive` pass, and the `inst/doc/` slimming
      item.
      **Slice 1 DONE S820** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE1_2026-09-30.md`): the staleness is in both
      the local PDFs (rendered 2026-08-25, carry since-retracted claims) and the committed images (1 of 8
      `kinship2-fidelity-validation-img/` is stale: `trackC-nprc-rectilinear.png`; the other 7 are current). **Open
      from slice 1:** the one remaining PDF, the tracked `kinship2-fidelity-validation.pdf` (S853 correction), was **DELETED S884** (owner decision; it was swept in by accident by S825's `9a2a5ddb7`, from which it can be recovered); still open: regenerate `trackC-nprc-rectilinear.png`
      (`data-raw/kinship2FidelityValidation.R`; look at the fresh arc touching the `W` square first); the third, the stale "defaulting to direct"
      comment at `R/modPedigree.R:459-461`, was **FIXED S882** (it now says `"rectilinear"`, the default since S574; the parsed code is unchanged), as the `_pedigree_browser.Rmd` wording was S828.
      **Found S882, same kind, FIXED S883 (comment only; parsed code identical):** the `@noRd` roxygen of `.addRectilinearWaypoints()`
      (`R/makePedigreeDiagramData.R:2110-2113`) called `"direct"` `makePedigreeMatingLayout()`'s own default and said the function
      "has no call site yet"; the default is `"rectilinear"` (`:1675`) and the call site is `:2070`; the block now says so. **Slice 2 DONE S821** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE2_2026-09-30.md`): 31 of 38
      regenerable `shiny_app_use/` images differ from the app (Pedigree Browser family +147 px; Home, Input, Summary
      Statistics, Breeding Groups, GVA); the colony script's tail fails identically every run (diagnose first, then
      regenerate by module); 12 images have no generator; `pb_unknown_displayed.png` is an orphan. **Slice 3 DONE S822** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE3_2026-09-30.md`): the 11 articles' prose has
      7 moderate and 22 minor stale claims, mostly hand-typed counts and one-line rule summaries (colony guide export count
      182 vs 233, "six" feature articles vs 7, Production and Undetermined descriptions; `genetic-value-analysis` tier 1;
      `breeding-group-formation` `minAge`/`threshold`/`ignore`); no broken chunk, link or function name. **Fixed S823:** all 29
      findings, plus the `orderReport`/`qcStudbook`/`hasInvalidIdChar` roxygen. **Slice 4 DONE S824** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE4_2026-09-30.md`): the 16 `manual_components`, 8
      `ui_guidance` pages and README have 33 moderate and 44 minor findings (breeding-group and genetic-value pages describe an
      earlier UI; stale defaults; `birth` is a required column). **Cluster 1 FIXED S825** (all 17 findings in `input_format.html`, `_input.Rmd`; orphan `_database_access.Rmd` deleted). **Cluster 2 FIXED S826** (breeding-group pages: BA1-BA16, BA30-31, UG11-UG21 in `_breeding_group_formation.Rmd`, `_breeding_group_algorithm.Rmd`, `_gv_and_bg_desc.Rmd`, `group_formation.html`, `gvAndBgDesc.html`; the `groupAddAssign` roxygen "average"/"or younger" wording stays with the code-defect decisions). **Cluster 3 FIXED S827** (genetic-value pages: BA17-BA22, UG12 second half, UG24, UG25 in `_genetic_value_analysis.Rmd`, `_genome_uniqueness_algorithm.Rmd`, `genetic_value.html`, `population_genetics_terms.html`, `summary_stats.html`; the R `helpText` at `R/modGeneticValue.R:88` still says "Summary Statistics relationship table"). **Cluster 4 FIXED S828** (BB1-BB17, UG22, UG23, RM1-RM4: `_pedigree_browser.Rmd`, `_summary_statistics.Rmd`, `_orip_reporting.Rmd`, `_summary_of_major_functions.Rmd`, `_software_development.Rmd`, `_introduction.Rmd`, `_online_documentation.Rmd`, `pedigree_browser.html`, `pyramidPlot.html`, README re-rendered; the `test_modPedigree.R` and `test-e2e-pyramid-detailed.R` page-text assertions were updated). **Slice 4 is done.** Its one leftover, BB14 (`DESCRIPTION` and the `_pkgdown.yml` home text said the application "supports five groups of functions" while the app has 14 analysis tabs), was **FIXED S830**: both now say "these main groups of functions" plus a sentence naming the further tabs (this note still listed it as open until S882). **Slice 5 (a2interactive.Rmd) AUDITED S832** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE5_2026-10-01.md`): 12 moderate, 18 minor (AI1-AI30), **all FIXED S833** in `vignettes/a2interactive.Rmd` (knit clean; `devtools::check()` and the spelling test pass). No code defects. **Slice 6a AUDITED S834** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE6A_2026-10-01.md`): 36 genetic-value/kinship `man/` pages, 9 moderate, 45 minor (MA/MB/MC/MD ids); **52 of the 54 FIXED S835** in the `R/*.R` roxygen + `devtools::document()` (lint 0, spelling test and `devtools::check(--no-tests)` pass). Still open, both owner decisions about code (their doc wording waits on the decision): MC1 (`filterKinMatrix` lacks `drop = FALSE`) and MB3 (unknown-sex founder kinship). MA3/MB14 now cite only `e1071` for `type = 2`; neither `moments` nor `e1071` is installed here, so that is from recall, not a run. **Slice 6b AUDITED S836** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE6B_2026-10-01.md`): 36 pedigree QC and curation `man/` pages, 20 moderate, 37 minor (PA/PB/PC/PD ids), all 20 moderates re-run first-hand; **54 of the 57 FIXED S837** in the `R/*.R` roxygen + `devtools::document()` (lint 0, spelling test, examples and `devtools::check(--no-tests)` pass). Still open, owner decisions about code: PB4, PB7, PB11 (their docs untouched); PB13, PA4, PD12, PD1 are code candidates too, and S837 documented today's behavior for them, so reword if the code changes. **Slice 6c AUDITED S838** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE6C_2026-10-01.md`): 35 marker-genetics, genotype and MHC `man/` pages, 4 moderate, 25 minor (QA/QB/QC/QD ids), all 4 moderates re-run first-hand; **all 29 FIXED S839** in the `R/*.R` roxygen + `devtools::document()` (lint 0, spelling test, examples and `devtools::check(--no-tests)` pass), documenting today's behavior. Still open, owner decisions about code (the 8 candidates in the report; reword the docs if the code changes): `markerExpectedHeterozygosity` He = 1.0 for an all-NA locus, `computeGenomicROH` silent locus drop, `hasGenotype` `First`/`Second`, `checkSequenceGenotypeFile` sidecar not reconciled, plus candidates 5-8. **Slice 6d AUDITED S840** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE6D_2026-10-01.md`): 34 Shiny app and module `man/` pages (the Server and UI page of 15 modules, `appServer`, `appUI`, `runGeneKeepR`, `runModularApp`), 8 moderate, 34 minor (RA/RB/RC/RD ids) plus 22 code candidates; the 8 moderates were re-read in the source, RA8 and CA4 re-run. **All 42 FIXED S841** in the `R/*.R` roxygen + `devtools::document()` (lint 0, spelling test, examples and `devtools::check(--no-tests)` pass), documenting today's behavior. Still open, owner decisions about code (the 22 candidates CA1-CA5, CB1-CB5, CC1-CC5, CD1-CD6 in the report; reword the docs if the code changes, esp. RA3/RA4/RA6 (CA1, CA3), RA8 (CA2), RB10 (CB1), RC7 (CC1)). **Slice 6e AUDITED S842** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE6E_2026-10-01.md`): the last 126 `man/` pages, so all 267 are now audited; 26 moderate, 69 minor (RE-RL ids) plus 46 code candidates (CE-CL); 23 of the 26 moderates re-run or re-read first-hand (not RF2, RH2, RJ3). **All 95 slice-6e findings FIXED S844** in the `R/*.R` roxygen + `devtools::document()` (lint 0, spelling test and `devtools::check(--no-tests)` pass), documenting today's behavior; the 46 code candidates (CE-CL) are owner decisions, reword the docs if the code changes; leftovers: `R/makeGroupNum.R` still says `numGp` "Default is 1", and the examples in `R/fillGroupMembersWithSexRatio.R` and `R/groupAddAssign.R` still pass deprecated `minParentAge`. **Slice 7a AUDITED S845** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE7_2026-10-01.md`): `NEWS.Rmd` and `NEWS.md`, 3 moderate (NC1, NC2: "Fixed" bullets for a tab and a file that never shipped in 2.0.0; NE1: `NEWS.md` 37 commits stale), 16 minor; **all FIXED S846** except NA2-NA4, **FIXED S847** (the Diagram section rewritten as a new feature described against kinship2; `NEWS.md` re-rendered; NB5/NB7 were dropped by S845). **Slice 7b AUDITED S852** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE7B_2026-10-01.md`): the living internal docs (`ROADMAP.md`, `CLAUDE.md`, `BACKLOG.md`, `docs/architecture/`, `docs/conventions/`, `docs/setup/`), 10 moderate, 25 minor (RO/CL/BA/BB/AR/CV ids); 9 of the 10 moderates re-checked first-hand; **33 of 35 FIXED S853** (docs only). Left: CV1 and CV2 (code decisions, below); RO8 (Quarto slices 3-4 status) and the other ids in RO3 (not checkable here) were reworded to say "not recorded" / "not re-checked", not settled; AR3's "about 53" is now attributed to Learning 347 and not re-counted. **Slice 7c AUDITED S860** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE7C_2026-10-02.md`; owner scoped it to the live plans only): 9 live `docs/planning/` docs plus a header sweep of all 84; 53 moderate (XA-XI ids), 18 of them re-checked first-hand, the rest on one agent's read. Main cause: the plans were never re-labelled when the work shipped (37 of 38 `issue*` plans have a CLOSED issue; 14+ headers still say DRAFT or not implemented). **Slice 7c FIXED S861** (docs only): status banners on the #112, #122, #123, #144 and #167 plans and the reference qmd, in-place fixes to the CRAN runbook, outreach plan and Quarto analysis, and the three BACKLOG pointers. **Header sweep FIXED S862** (docs only): banners on 31 more plans (the 12 status-less, 10 stale-header `issue*`, 9 non-issue) plus `docs/planning/README.md`; each verified against issue state, commits and artifacts, with unverified points said in the banner. (`getProductionStatus` 0 dams -> green was fixed S863: now NA/gray.) **Slice 8 AUDITED S868** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE8_2026-10-02.md`): `docs/research/` (5) and 41 older `docs/audits/` files, 42 moderate, 62 minor (A-D ids), headline claims re-run first-hand; no code defects. One cause: no dated record carries a "status as of" banner, and their follow-on work (issues #109, #118-#120, #143-#153, #156, #158, #167, #168, the QP solver) all shipped. **Banner pass DONE S870** (docs only): a "Status as of 2026-10-02 (S870)" banner on the 26 files with a moderate finding (4 in `docs/research/`, 22 in `docs/audits/`), each naming what superseded it and checked against the slice 8 report's first-hand evidence; bodies unedited except two numbers (the 09-02 census CSV row count, the tarball "0 gates"). Not bannered: the files with only minor findings. Open from slice 8, not part of the pass: whether to replace the stale `file:line` cites in the plans and gap analysis with function names, and D's six parent-to-union edges that still differ in row. **Next in this item:** nothing further is scoped; slice 8 closes the audit. Two code candidates, owner decisions: `getGeneticDiversityStats()` exports with no `@examples`, and the `savePlotToFile` example uses `\dontrun`. Four likely code defects the audit found
      (candidate "Upload list" uploads nothing; no-op GU/MK checkboxes; `groupAddAssign` roxygen; silent `allele_1/2` genotype
      drop) are owner decisions, DECISION NEEDED, Effort S each, not part of the doc fixes.

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

- [ ] **The shipped `deidentified_jmac_ped.csv` still does not load: 67 "Parent age too young"
      errors (split out S800 from the blank-cells item, which S800 fixed; DECISION NEEDED,
      Effort S)** -- since S800 the app reads its 2,789 blank sire cells as unknown parents,
      so the old "appears as both a sire and a dam" error is gone, but the pedigree check
      still stops on 67 parent-age errors, on the app path and the `getPedigree()` path
      alike (measured S800, `qcStudbook(getPedigree(f), reportErrors = TRUE)$suspiciousParents`,
      67 rows): 65 dams aged 3.43-3.99 years at the birth, under the 4-year female floor
      `getSpeciesMinBreedingAge("JAPANESE MACAQUE", "F")` returns, and 2 sires with
      negative ages (sire `3A34N` of `82I5M`, -37.10 years; sire `NX5RM` of `8PPD8`, -34.77:
      born after their offspring, a data error in the file).
      **Decide:** (1) leave the file as a QC example and say in its documentation that it
      loads only with Minimum Dam Age lowered and still shows the 2 sire errors; (2) correct
      the 2 impossible sire records in the example; (3) review the 4-year Japanese macaque
      dam floor (5 for sires) against the literature -- a species-table change moves every
      Japanese macaque result. The pinned test is
      `tests/testthat/test_modInput_blankCells.R` (last test: exactly 67 errors, all
      "Parent age too young"), which moves with (2) or (3).

- [ ] **Harem-sire conflict enforcement hole — kinship AND ancestry (found S764,
      2026-09-22, DECISION NEEDED — closing it is a behavior change needing its own
      design gate, Effort M)** -- a harem's sampled sire is seeded into the group
      before the fill loop (`initializeHaremGroups()`), and the loop applies
      `kin[[id]]` exclusions only for animals it places itself
      (`R/fillGroupMembers.R:60-77`), so the sire's own conflicts are never
      enforced against his group: a female with 0.25 kinship to the sire can join
      his harem today (M-F pairs are not F-F-exempt, yet go unenforced), and #168
      ancestry blocking inherits the identical hole (owner-ratified S764 as
      "inherit + document": pinned by
      `tests/testthat/test_groupAddAssignAncestry.R`'s harem-limitation test,
      documented in `groupAddAssign()`'s `ancestryRules` roxygen and the NEWS
      caveat). The candidate fix — filtering each group's `available` by its
      pre-seeded members' `kin` entries after `makeGroupMembers()` — changes
      no-rules harem results (a D7-class zero-change violation if done casually)
      and alters `sample()` streams, so it needs its own Pre-RED design gate
      deciding kinship-side scope, RNG posture, and whether `currentGroups` seeds
      in position >1 share the fix. Full mechanics: Learning 778; the S764 harem
      scope gate recorded the "inherit + document" decision.

- [ ] **(Optional, owner decision) Retrospective colony-snapshot backfill for
      longitudinal genetic-health monitoring** (deferred S760, 2026-09-22, from the
      closed issue #167's plan §5 Slice 5, DECISION NEEDED, Effort L, its own scoping
      session first) -- issue #167's v1 (schema + history IO, snapshot generation,
      trend/delta computation, the Genetic-Health Trends tab; Slices 1-4, all shipped
      and closed) is prospective-only: snapshots are recorded from the analysis state
      a user is looking at when they generate one. A future, clearly-caveated feature
      could reconstruct APPROXIMATE historical snapshots from birth/exit dates alone,
      giving an immediate trend from a single studbook rather than waiting for
      prospective series to accumulate. **Never ratified as v1 scope** (plan §3 D5,
      §5 Slice 5) -- the caveat model is the design problem, not an implementation
      detail: as-of-date reconstruction cannot recover historical breeder flags or
      focal-population designations, so `neSexRatio`/`neVariance` and focal-rule
      snapshots would be silently wrong, not merely approximate, unless the design
      session solves that. Requires its own fresh Pre-RED design gate (a new GitHub
      issue, since #167 itself is closed) before any implementation. See
      `docs/planning/issue167-longitudinal-monitoring-plan.md` §5 Slice 5 and D5 (§7
      Dragon 1 is the no-seed-in-`reportGV()` point, not this caveat list)
      for the full caveat inventory.

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
      DELIBERATELY OPEN — decide at plan time with a prototype in hand. When unblocked, the
      pickup is a planning session (package boundary/plan doc in `docs/planning/`,
      evidence-based inventory); step 0's prep is complete — D-1 landed S744:
      `makePedigreeMatingLayout(kinshipMatrix = )` (`R/makePedigreeDiagramData.R:1661`)
      is exactly the injectable boundary the package needs; D-2 landed S745: no test
      file outside the layout core's own reaches `.buildMatingUnitForest()` any more
      (the two `test_modPedigree.R` reaches now derive union/duplicate ids from the
      exported return's `nodes$id` / `duplicateToReal`); D-3 landed S746: all 13
      `R/positionTreeApportion.R` functions carry `@noRd` roxygen (title + `@param` +
      `@return`, house style), so the engine's contract is readable in place
      (`@noRd` generates no `.Rd`, `man/`/`NAMESPACE` verified byte-identical).
      (Prep-step origin context: the owner accepted the S667 recommendation NOT to
      split the layout core into its own package — disposition recorded S738 in
      `CHANGELOG.md`; the prep steps hardened the boundary in place and stand
      whether or not a split ever happens.)
- [ ] **(Optional, owner decision) Slim `inst/doc/` by moving the three `html_document`
      vignettes to `rmarkdown::html_vignette`** (extracted S728, 2026-09-19, from the completed
      tarball build-hygiene item — its still-open step 4; DECISION NEEDED, Effort M, its own
      session) -- `inst/doc/` is 4.38 MB uncompressed = 86% of CRAN's 5 MB documentation
      guideline and 38% of the tarball; `a2interactive`/`gvaConvergence`/`simulatedKValues`
      declare `output: html_document` (`vignettes/a2interactive.Rmd:4-6`,
      `gvaConvergence.Rmd:6-8`, `simulatedKValues.Rmd:6-8`). Est. 0.4-0.9 MB compressed saved
      — an ESTIMATE needing its own before/after clean-export build measurement
      (`docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md` Finding 3 + §7 recipe); `df_print: paged`
      does not exist under `html_vignette` and must become `knitr::kable()`; optionally replace
      `a2interactive`'s two live `visNetwork` widgets with static images — now quantified
      (S737, `docs/audits/PEDIGREE_DRAWING_FEATURE_GROWTH_AUDIT_2026-09-20.md` Obs. 2): the
      widgets' vis-network + html2canvas payload is ~1.23 MB uncompressed ≈ 0.29 MB compressed
      inside `inst/doc/a2interactive.html`, so that one step alone removes most of the drawing
      feature's tarball footprint. Buys
      documentation-guideline headroom, not tarball-limit compliance (already met: clean build
      3.49 MB vs 10 MB); the S728 `tarball_size_clean_export` gate (`.quality-gates.json`,
      <=5 MB) will show any saving mechanically. **Not worth doing on size grounds (measured
      S727):** shrinking example/test data (`inst/extdata/examples/` 0.46 MB compressed,
      `tests/` 0.66 MB), recompressing `data/` (0.14 MB), or the package split. Always build
      release tarballs from a clean export, never the working tree.
- [ ] **(Optional, low priority) Root-cause why the pinned Chrome-for-Testing binary hangs on
      `macos-latest`'s `ChromoteSession$new()` bootstrap** (found S619, 2026-08-20, incidental to
      the chromote CDP-timeout fallback fix (see `CHANGELOG.md`), READY (optional), Effort M -- research only, not
      required) -- the practical problem is FULLY resolved: `macos-latest` reverts to ambient/
      unpinned Chrome (`R-CMD-check.yaml`, `if: matrix.config.os != 'macos-latest'` on the 3
      Chrome-provisioning steps), verified green on real CI. What remains unexplained: raising
      chromote's `default_timeout` to 60s did NOT resolve the pinned binary's hang (same exact
      failure, wall time roughly doubled, confirming the session is genuinely wedged, not merely
      slow) -- direct source inspection confirmed the timeout-governed call is
      `ChromoteSession$new()`'s own internal `Runtime.evaluate("window.devicePixelRatio", ...)`
      bootstrap probe (`private$get_pixel_ratio()`, chromote 0.5.1), but WHY that specific probe
      never gets a response on the pinned macOS ARM64 binary specifically (vs. the SAME pinned
      binary working fine on ubuntu-latest/windows-latest, and vs. ambient Chrome working fine on
      macos-latest) is unconfirmed. A research workflow found a plausible but NOT Chromium-
      confirmed analog (Mozilla Bugzilla #1893921 -- Firefox's own content-process spawn hitting a
      5s AppKit/IOKit sandbox-denial stall specific to GitHub's *virtualized* macOS ARM64 hosts,
      fixed by widening Firefox's own sandbox allowlist) but found no matching Chromium tracker
      entry. Only worth pursuing if pinned-Chrome reproducibility on macOS specifically becomes
      valuable later (e.g. `xattr -l` on the extracted `.app` on a live failing runner to rule
      out/in Gatekeeper quarantine, which the same research found NOT evidenced for
      `browser-actions/setup-chrome`'s actual download/unzip pipeline; or filing a new
      `rstudio/chromote` upstream issue, since no existing issue there matches this exact
      macOS+GHA+live-CDP-timeout signature).
- [ ] **`methodology_trim.py`'s generated shard verify script FAILs its L2 "leak" check when an
      archived record quotes a front-matter line (found S784, 2026-09-26, DECISION NEEDED,
      Effort S)** -- the check embedded in each shard's `.verify.sh` is `ln in "".join(sr)`, a
      SUBSTRING test of every front-matter line over 24 characters against the whole archived
      records text. The archived S779 receipt's `next_steps:` quotes the trimmer's `--check`
      command (with `--budget-bytes 65536`), which contains the front-matter `--check` line, so
      `bash docs/archive/HANDOFFS-through-2026-09-26.md.verify.sh` prints `FAIL: L2 FRONT MATTER
      leaked 1 line(s) into the shard` although the write-time L1/L2/L3 all passed and the
      script's own L1/L3 checks hold (reproduced by a write, a rollback and a second write, and by
      a separate Python probe; the `CHANGELOG.md` shard from the same session is clean, 0 hits).
      It recurs on every later `HANDOFFS.md` trim, because S779 is always in the archived tail.
      Nothing runs these scripts (no CI job, test or tool; only the dashboard recognizes the
      suffix). **Decision for the owner:** (1) fix it upstream in the `rmsharp/methodology`
      fork -- compare against the SET of exact record lines, as that script's BL-28 fix already
      does for its "lost line" check (a local patch would be a second local modification to
      `methodology_trim.py` to re-apply after every sync, per `CLAUDE.md`'s checklist); (2) leave
      it and accept the one known FAIL; (3) reword the front-matter command line in `HANDOFFS.md`
      so it is no longer a substring of what receipts quote (edits a ledger's seed text; its L2
      then checks the reworded line). Until decided, do not quote front-matter command lines
      verbatim in receipts (Learning 797e).
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
      an archiver") is worth adopting for `CHANGELOG.md` specifically.
- [ ] **`BACKLOG.md`'s own ledger-size housekeeping -- editorial compression, not a
      `methodology_trim.py` config** (found S518, 2026-08-11, READY, Effort L; RECURRING --
      last pass 2026-09-24, ad hoc; last numbered-session pass S752, 2026-09-21) -- `BACKLOG.md` is one of the
      dashboard's HIGH-risk ledger-size items but does not fit `methodology_trim.py`'s chronological-record model: its `##` sections
      are standing *topical* categories that accumulate resolved-item narrative indefinitely, not
      dated newest-on-top records. The file's own header states the remedy ("Open, actionable work
      only... for history see `CHANGELOG.md`"). Sections **regrow** as later sessions append their
      own progress narrative (S606 found the S531 "fully RESOLVED" claim was only a snapshot), so
      this is a recurring maintenance pass, never a one-time fix.
      **Pass history** (per-pass detail in `CHANGELOG.md` and `docs/archive/CHANGELOG-through-*.md`): S529 Housekeeping section (263 lines
      removed; its inventory found 2 items with NO ledger entry -- the `inst/extdata/` reorg
      S415-418 and the non-portable-filename fix S497, a real FM #27 gap -- and both were
      backfilled before compressing); S530 "Pedigree diagram vs kinship2" (896->286 lines); S531
      "Genetic-metrics PDF audit follow-ups" (753->267; file total 2,501->1,173 across the three
      passes); S606 re-compressed Genetic-metrics after regrowth (304->80) and fixed 2 stale claims
      found in the same pass; **S752** (2026-09-21) re-compressed Genetic-metrics again (regrown to
      91 lines by the issue #148 chain, all 14 issues now closed -> 62 lines incl. the extracted
      open item), condensed this item's own pass history (91 -> 38 lines), extracted the
      Genetic-metrics section's one buried open thread as its own item, and ran the
      S606-requested regrowth check on "Pedigree diagram vs kinship2": **NOT regrown**
      (286->156 lines; S686's completed-item removals shrank it, and what remains is S530's own
      ratified summary).
      **2026-09-24** (ad hoc, owner-picked from a staleness review; each cited session, Learning
      and issue checked against the ledger, `PROJECT_LEARNINGS.md` and `gh issue view` first):
      removed 2 completed items (the REUSE-badge registration -- the live badge now reads
      "compliant" -- and the empty `untitled folder`), fixed 4 stale statements, merged the
      duplicate `## Up Next` and dropped the empty/resolved headings, and compressed the LabKey
      item (44 -> 15 lines) and the kinship2 section's S435-S500 DONE narrative (84 -> 20 lines;
      the owner ratified this deeper cut at the pick). The LabKey item was compressed in place and
      the QC'd-copy Diagram item rewritten with its measured cause; every other open item is
      byte-identical. **Later the same day**, at the owner's direction ("if the work really was
      done, it should be in `CHANGELOG.md`"), the last three resolved sections -- `## Architecture
      (issue #122 ...)`, `## Audit follow-ups` and the Genetic-metrics section, 58 lines -- were
      deleted after checking each against the ledger (issue #122: 7 tagged entries;
      Genetic-metrics: 14 issues closed, 69 tagged entries; Audit follow-ups: 7 of its 8 items
      recorded, and the eighth, NEW-53, fixed 2026-05-31 in `5f40b7af`, backfilled). The file now
      ends at `## Outreach`.
      **Method (every pass, all steps):** before compressing anything to a pointer, (1) verify
      `CHANGELOG.md` + `docs/archive/CHANGELOG-*.md` carry an entry heading for every session
      number cited AND that the load-bearing facts are inside those entries (a heading alone proves
      little); (2) confirm every cited Learning / doc path resolves and every issue state via
      `gh issue view`, not prose; (3) extract any buried open thread as its own item first; (4)
      replace whole line ranges mechanically (Learning 537: a partial `old_string` leaves later
      paragraphs duplicated beside the new bullet); (5) leave open items byte-untouched; (6)
      re-read the compressed result end to end.
      **Candidates for the next pass (measured 2026-09-24; re-grep, sizes not anchors):** none then --
      no resolved-narrative section or stub remained, and every remaining `##` section held open
      items. Regrowth check (S853): 599 lines now, up from 378 on 2026-09-24 (the file was 480 lines after S752 and 561 before that
      pass); the long narrative items, the docs-audit item and the chromote item, are the likely next cuts. The next pass should compress those two.

- [ ] **Two kinship2 drawing features the Diagram tab still lacks (found S847, 2026-10-01; DECISION
      NEEDED -- which pedigree column marks "deceased", Effort M for each; strict TDD for both)**
      -- checked in the source S847 (`R/makePedigreeDiagramData.R`, `R/modPedigree.R`): (1) **Deceased
      marker:** no diagonal slash is drawn over a deceased animal's symbol, as kinship2 does for a
      deceased `status`. The pedigree already carries `death`, `exit` and `status` columns, so the
      decision is which of them (or a new one) marks an animal deceased, and whether `exit` for a
      transfer must be told apart from death. (2) **More than one affected condition:** `affected`
      is one logical column (`R/makePedigreeDiagramData.R:73-85`, one fill color); kinship2 shades
      up to four conditions per animal as separate sections of the symbol, with a matching legend.
      The decision is the input shape (several logical columns, or a matrix) and the legend text.
      Each is its own session; the Diagram section of `NEWS.Rmd` (lines 33-35) says "A deceased marker and more than one affected
      condition are not drawn" until both ship.

## Pedigree diagram vs kinship2 audit follow-ups (from ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md)
*S435's capability comparison of the issue #129 pedigree diagram against kinship2's drawing
feature set (`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`) produced 8
recommendations; S436 (2026-07-30, owner direction) filed all 8 as GitHub issues #131-#138 in an
owner-set priority order that inverts the audit's own. **All are shipped and closed except #138**
(full-colony rendering beyond the 1,500-node cap: `low priority` label, needs its own scoping
session first; tracked on GitHub, not here). Implementation followed
`docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md` (S480). **Tier 1**
(S481-S484): the dangling-parent crash fixes (issue #154); the issue #145 verification spike --
kinship2 v1.9.6.2 implements neither a hard male-left invariant nor a sex-aware
crossing-minimizing default (`docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`);
and a refresh of `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd` (done S484; its "current" claims have since gone stale again, and it now carries a status note). **Tier 2**
(S485-S500): #133 (affected status, closed S487), #136 (name labels, S490), #137 (twin/zygosity,
S494) and #145 (sire/dam placement, S500, simple-pair scope), each from a ratified plan in
`docs/planning/` and one to three strict-TDD slices with the citation / tutorial / `NEWS.Rmd` /
`a2interactive.Rmd` checklists applied; kinship2's `affected` and `relation` argument conventions
were adopted in #133 and #137. None reopens issue #129 or the visNetwork-vs-kinship2 technology
decision (D2), which stands as ratified. Session-by-session record: `CHANGELOG.md`; technical
findings: `PROJECT_LEARNINGS.md` Learnings 410, 411, 485, 488-499. The open items below are the
section's live work.*

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
      **Also considered and again not adopted for the kinship2-fidelity remediation plan's
      Track 4 (design S572, implemented S573, 2026-08-14)** -- Track 4 ratified and shipped
      Candidate A (gen-aware D2 anchor selection) instead, see
      `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` §3/§8. Live-rendered
      (S573, both `edgeStyle` values, zero console errors) with the redistribution this decision
      predicted (duplicate nodes 128->102, multi-anchor individuals 2->22, max 5). Still not
      precluded -- remains open as a future, separately-scoped enhancement if the owner judges,
      from that live render, that remaining cross-generation mate-lines still benefit from
      signposting for legibility.
- [ ] **The live app's uploaded/QC'd copy of `obfuscated_rhesus_mhc_ped.csv` gets a different
      Diagram layout than the same CSV read directly -- cause found (row order); decision open**
      (found S472, cause measured 2026-09-24, low priority, Effort S) -- the S472 figures (739
      live vs 740 offline nodes; 50 vs 51 projection nodes) no longer reproduce, since the layout
      has changed since (e.g. Track 4, S573), and the original hypothesis -- that `qcStudbook()`
      drops or merges a row -- is REFUTED: it keeps all 375 rows and ids (none lost or added, 0
      duplicates), and `makePedigreeDiagramData()` returns the same 375 nodes / 502 edges for
      both inputs. What differs is row ORDER -- `qcStudbook()` reorders the rows -- and the mating
      layout depends on it: `makePedigreeMatingLayout()` gives 782 nodes for both inputs under
      `edgeStyle = "direct"`, but **1456 (raw order) vs 1412 (QC order)** under `"rectilinear"`,
      and the raw content re-ordered to QC's row order gives exactly 1412 (so order alone
      reproduces QC's count; QC also normalizes some id/sire/dam/sex cells, not characterized).
      Consequence: the app's rectilinear diagram of an uploaded file can carry a different
      number of waypoint nodes than a script user's diagram of the same data, depending only on
      row order. A future session should decide whether that row-order dependence is acceptable,
      and whether the bundled-fixture tests (`test-e2e-pedigree-module.R`, etc.) should assert the
      QC'd count rather than the raw-CSV count as a proxy for what the live app renders.
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
      the NIH grant acknowledgment). Natural dependencies, the owner's call: a released 3.0.0 to
      cite (`DESCRIPTION` reads 2.0.0.9000 today) and the documentation audit above, so the
      papers' figures match the software.
