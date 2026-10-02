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
      none urgent -- sex-code adoption (PED-2/NEW-29; 28 bare-literal comparison lines in 10 files
      remain), the error/return contract (PED-5/6, NEW-28/36), splitting `getPotentialParents`
      (PED-4, NEW-54, and NEW-55 -- labelling whether a dam list came from proven breeders or the
      fallback, which the owner did not take at S798's F3 decision), the walk helpers (PED-3, NEW-42; all exported, so an API change), the sim
      driver (NEW-50/51), constants and HTML builders (NEW-18/19/21/26/57) and the founder
      definition (NEW-61); (b) NEW-24 is already open issue #123. **The 11 settled ids (PED-7, NEW-39, PED-8, PED-9, NEW-27, NEW-33,
      NEW-44, NEW-47, NEW-58, NEW-59, NEW-60) were closed S818**, so 32 remain (the report's "Closure record" lists them). **Trap:** an id grep of the ledger
      both under- and over-counts (`NEWS.md` once used "NEW-47/48/49" as entry labels), so use the
      report's table, not the old 41-id list.

- [ ] **(Optional, owner decision) One internal `isAddedRecord()` helper for the "added" mask
      (raised S785, deferred at the S785, S786 and S787 REFACTORs; DECISION NEEDED, Effort S)** --
      the mask is written inline four times, all meaning "only the exact status `"added"` is
      special; an `NA`, blank or unrecognized status is a real animal": `convertDate()`
      (`R/convertDate.R:103`) and `removeDuplicates()` (`R/removeDuplicates.R:46`) as
      `!is.na(x) & x == "added"`, `removeUnknownAnimals()` (`R/removeUnknownAnimals.R:31`) as its
      complement, and `correctParentSex()` (`R/correctParentSex.R`, `isAdded`, which also answers
      a `NULL` status with "no added rows"). One helper would put that contract in one place; the
      cost is a cross-file refactor (four R files plus a new file and its tests, so staged commits
      under the 5-file cap, and `SAFEGUARDS.md` asks for plan-mode approval of refactoring), and the
      owner may judge four short copies enough. **Trap** to keep in any helper or caller: a
      negative subscript built from an index that can be empty
      (`ped[-getRecordStatusIndex(ped, "added"), ]`) drops EVERY row when nothing is `"added"`.

- [ ] **`convertDate(reportErrors = TRUE)` numbers an invalid date among the non-added records only
      (found S785, 2026-09-26, DECISION NEEDED, Effort S, low priority)** -- probe (S785, a 3-row
      pedigree: `x1` `"added"`, `a` valid, `b` with a bad date on row 3): it reports row `2`, not `3`;
      the pre-change code reports `2` too, so the S785 slice did not cause it. With the added row
      LAST, the order `addParents()` produces, it reports the right row, so the app and
      `qcStudbook()` are unaffected; only a script that puts an added row ahead of an original can
      see it. `R/convertDate.R` numbers `seq_along(originalDates)` after the added records are set
      aside, and `getDateErrorsAndConvertDatesInPed()` copies those numbers into
      `errorLst$invalidDateRows` (`R/getDateErrorsAndConvertDatesInPed.R:36`), the list the user
      reads, and uses them as full-pedigree row numbers in `sb[-invalidAndAdded, ]` (`:37-41`).
      **Decision for the owner:** (1) map the reported numbers back to full-pedigree rows inside
      `convertDate()` (`which(!isAdded)[rows]`; one line plus a test; changes the numbers a script
      sees only in that order); or (2) document the numbering in `@return` and leave it. The test
      must pin BOTH orders (added first and added last).

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

- [ ] **Mate-pair ancestry guardrails -- residue after issue #169 (found S776-S777,
      2026-09-24; DECISION NEEDED -- the owner picks which to pursue, each Effort S)**
      -- #169 shipped and closed S777 (kernel, module, override gate, Ancestry tab,
      committed e2e, article). Three small things it left, none started: (1) **Zero-rule table (DECISION NEEDED)** -- a valid rules
      table with zero rules makes `.buildAncestryOverrideManifest()` stop ("no rules in
      effect"), so Download Audit Manifest errors on BOTH Mate Pair and Breeding Groups;
      decide whether a zero-rule table should read as "inactive" or the manifest should
      say so. (2) **The Excluded tab has no export (DECISION NEEDED)** -- plan section 7
      dragon 8: a curator cannot get the list of blocked pairs as a file (the manifest
      carries per-rule COUNTS only). (3) **Duplicated gate code (READY refactor)** -- the
      override select-choices builder and the confirm-gate modal are duplicated between
      `R/modBreedingGroups.R` and `R/modMatePair.R` (S776's REFACTOR shared only
      `.emptyAncestryOverrides()` and `.overridableAncestryRules()`); the shared shape is a
      choices builder plus a modal constructor taking the warning text and the namespace.
      **Known, accepted:** an unhandled click-time error ends the Shiny session
      (Learning 786).

- [ ] **Decide the release number (DECISION NEEDED, Effort S)** -- S851 adopted the owner's
      draft ideas into the `NEWS.Rmd` dev block (opening summary, the restored marker export fix,
      a plainer pass over all 11 sections) and the owner had the two draft files deleted. Still
      the owner's call: the draft was headed 3.0.0 while `DESCRIPTION` and `NEWS.Rmd` say
      2.0.0.9000.

- [ ] **Male-on-the-left placement is stricter in the code's documentation than in real layouts
      (found S789, 2026-09-27, DECISION NEEDED, Effort S to find the cause, more to fix)** --
      the roxygen of `makePedigreeMatingLayout()` (`R/makePedigreeDiagramData.R`, "Male-left/
      female-right ordering (issue #145) ... is now unconditional") says every simple two-parent
      mating renders the male on the left. Measured S789 over every mixed-sex mating unit (the
      two parents of each `__union_` node read from `layout$edges`, duplicates mapped through
      `layout$duplicateToReal`, x from `layout$nodes`; the 5 example pedigrees, `rhesusPedigree`
      and `smallPed`): 227 of 257 (88.3%) have the male on the left in the Rectilinear style
      (`rhesusPedigree`: 29 of 231 on the right; `smallPed`: 1 of 6; the Direct style: 30 of 237
      and 1 of 6). Most exceptions are pairs where a parent has several mates, which the issue
      #145 plan leaves to the tree structure on purpose
      (`docs/planning/issue145-sire-dam-left-right-placement-plan.md`, D5/D9); but 2 of 34 pairs
      on `rhesusPedigree` where each parent has exactly one mate and neither is a duplicate are
      also on the right, and neither parent has a child of unknown parentage, so the plan's own
      exclusion does not explain them (cause not chased). **Decide:** (1) find the two and fix
      the layout (a placement change, so a re-run of the diagram fidelity checks); or (2) correct
      the roxygen to say the rule covers simple pairs "in most cases" and leave the layout alone.
      The release note already says "in most cases" (S789).

- [ ] **Audit the internal and user-facing documentation for stale information and stale
      diagrams** (owner-requested 2026-09-26; READY, Effort L -- one audit report per session, so
      expect several slices) -- the owner noticed that `vignettes/articles/pedigree-diagram.pdf`
      and `vignettes/articles/kinship2-fidelity-validation.pdf` show stale figures. Measured
      2026-09-26 (the staleness itself is the owner's observation, not yet re-checked): both PDFs
      are UNTRACKED renders dated 2026-08-25 (`.gitignore:21` ignores `vignettes/*.pdf` but not
      `vignettes/articles/*.pdf`), while their `.qmd` sources were last edited 2026-09-17/18; the
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
      (`vignettes/manual_components/_pedigree_browser.Rmd:56`) words the Diagram limit as "750 animals
      ... the limit drops to 400 when the Rectilinear edge style is selected", which reads
      misleadingly since Rectilinear is the default (the default limit is 400); the roxygen point in
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
      from slice 1:** owner decides delete-or-ignore for the two PDFs; regenerate `trackC-nprc-rectilinear.png`
      (`data-raw/kinship2FidelityValidation.R`; look at the fresh arc touching the `W` square first); fix the stale "defaulting to direct"
      comment at `R/modPedigree.R:440-443` (the `_pedigree_browser.Rmd` wording was fixed S828). **Slice 2 DONE S821** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE2_2026-09-30.md`): 31 of 38
      regenerable `shiny_app_use/` images differ from the app (Pedigree Browser family +147 px; Home, Input, Summary
      Statistics, Breeding Groups, GVA); the colony script's tail fails identically every run (diagnose first, then
      regenerate by module); 12 images have no generator; `pb_unknown_displayed.png` is an orphan. **Slice 3 DONE S822** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE3_2026-09-30.md`): the 11 articles' prose has
      7 moderate and 22 minor stale claims, mostly hand-typed counts and one-line rule summaries (colony guide export count
      182 vs 233, "six" feature articles vs 7, Production and Undetermined descriptions; `genetic-value-analysis` tier 1;
      `breeding-group-formation` `minAge`/`threshold`/`ignore`); no broken chunk, link or function name. **Fixed S823:** all 29
      findings, plus the `orderReport`/`qcStudbook`/`hasInvalidIdChar` roxygen. **Slice 4 DONE S824** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE4_2026-09-30.md`): the 16 `manual_components`, 8
      `ui_guidance` pages and README have 33 moderate and 44 minor findings (breeding-group and genetic-value pages describe an
      earlier UI; stale defaults; `birth` is a required column). **Cluster 1 FIXED S825** (all 17 findings in `input_format.html`, `_input.Rmd`; orphan `_database_access.Rmd` deleted). **Cluster 2 FIXED S826** (breeding-group pages: BA1-BA16, BA30-31, UG11-UG21 in `_breeding_group_formation.Rmd`, `_breeding_group_algorithm.Rmd`, `_gv_and_bg_desc.Rmd`, `group_formation.html`, `gvAndBgDesc.html`; the `groupAddAssign` roxygen "average"/"or younger" wording stays with the code-defect decisions). **Cluster 3 FIXED S827** (genetic-value pages: BA17-BA22, UG12 second half, UG24, UG25 in `_genetic_value_analysis.Rmd`, `_genome_uniqueness_algorithm.Rmd`, `genetic_value.html`, `population_genetics_terms.html`, `summary_stats.html`; the R `helpText` at `R/modGeneticValue.R:88` still says "Summary Statistics relationship table"). **Cluster 4 FIXED S828** (BB1-BB17, UG22, UG23, RM1-RM4: `_pedigree_browser.Rmd`, `_summary_statistics.Rmd`, `_orip_reporting.Rmd`, `_summary_of_major_functions.Rmd`, `_software_development.Rmd`, `_introduction.Rmd`, `_online_documentation.Rmd`, `pedigree_browser.html`, `pyramidPlot.html`, README re-rendered; the `test_modPedigree.R` and `test-e2e-pyramid-detailed.R` page-text assertions were updated). **Slice 4 is done.** One leftover, an owner decision: `DESCRIPTION` and the `_pkgdown.yml` home text still say the application "supports five groups of functions" (BB14), while the app has 14 analysis tabs; they match each other and the CRAN description, so the choice is whether to reword both. **Slice 5 (a2interactive.Rmd) AUDITED S832** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE5_2026-10-01.md`): 12 moderate, 18 minor (AI1-AI30), **all FIXED S833** in `vignettes/a2interactive.Rmd` (knit clean; `devtools::check()` and the spelling test pass). No code defects. **Slice 6a AUDITED S834** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE6A_2026-10-01.md`): 36 genetic-value/kinship `man/` pages, 9 moderate, 45 minor (MA/MB/MC/MD ids); **52 of the 54 FIXED S835** in the `R/*.R` roxygen + `devtools::document()` (lint 0, spelling test and `devtools::check(--no-tests)` pass). Still open, both owner decisions about code (their doc wording waits on the decision): MC1 (`filterKinMatrix` lacks `drop = FALSE`) and MB3 (unknown-sex founder kinship). MA3/MB14 now cite only `e1071` for `type = 2`; neither `moments` nor `e1071` is installed here, so that is from recall, not a run. **Slice 6b AUDITED S836** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE6B_2026-10-01.md`): 36 pedigree QC and curation `man/` pages, 20 moderate, 37 minor (PA/PB/PC/PD ids), all 20 moderates re-run first-hand; **54 of the 57 FIXED S837** in the `R/*.R` roxygen + `devtools::document()` (lint 0, spelling test, examples and `devtools::check(--no-tests)` pass). Still open, owner decisions about code: PB4, PB7, PB11 (their docs untouched); PB13, PA4, PD12, PD1 are code candidates too, and S837 documented today's behavior for them, so reword if the code changes. **Slice 6c AUDITED S838** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE6C_2026-10-01.md`): 35 marker-genetics, genotype and MHC `man/` pages, 4 moderate, 25 minor (QA/QB/QC/QD ids), all 4 moderates re-run first-hand; **all 29 FIXED S839** in the `R/*.R` roxygen + `devtools::document()` (lint 0, spelling test, examples and `devtools::check(--no-tests)` pass), documenting today's behavior. Still open, owner decisions about code (the 8 candidates in the report; reword the docs if the code changes): `markerExpectedHeterozygosity` He = 1.0 for an all-NA locus, `computeGenomicROH` silent locus drop, `hasGenotype` `First`/`Second`, `checkSequenceGenotypeFile` sidecar not reconciled, plus candidates 5-8. **Slice 6d AUDITED S840** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE6D_2026-10-01.md`): 34 Shiny app and module `man/` pages (the Server and UI page of 15 modules, `appServer`, `appUI`, `runGeneKeepR`, `runModularApp`), 8 moderate, 34 minor (RA/RB/RC/RD ids) plus 22 code candidates; the 8 moderates were re-read in the source, RA8 and CA4 re-run. **All 42 FIXED S841** in the `R/*.R` roxygen + `devtools::document()` (lint 0, spelling test, examples and `devtools::check(--no-tests)` pass), documenting today's behavior. Still open, owner decisions about code (the 22 candidates CA1-CA5, CB1-CB5, CC1-CC5, CD1-CD6 in the report; reword the docs if the code changes, esp. RA3/RA4/RA6 (CA1, CA3), RA8 (CA2), RB10 (CB1), RC7 (CC1)). **Slice 6e AUDITED S842** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE6E_2026-10-01.md`): the last 126 `man/` pages, so all 267 are now audited; 26 moderate, 69 minor (RE-RL ids) plus 46 code candidates (CE-CL); 23 of the 26 moderates re-run or re-read first-hand (not RF2, RH2, RJ3). **All 95 slice-6e findings FIXED S844** in the `R/*.R` roxygen + `devtools::document()` (lint 0, spelling test and `devtools::check(--no-tests)` pass), documenting today's behavior; the 46 code candidates (CE-CL) are owner decisions, reword the docs if the code changes; leftovers: `R/makeGroupNum.R` still says `numGp` "Default is 1", and the examples in `R/fillGroupMembersWithSexRatio.R` and `R/groupAddAssign.R` still pass deprecated `minParentAge`. **Slice 7a AUDITED S845** (`docs/audits/DOCS_STALENESS_AUDIT_SLICE7_2026-10-01.md`): `NEWS.Rmd` and `NEWS.md`, 3 moderate (NC1, NC2: "Fixed" bullets for a tab and a file that never shipped in 2.0.0; NE1: `NEWS.md` 37 commits stale), 16 minor; **all FIXED S846** except NA2-NA4, **FIXED S847** (the Diagram section rewritten as a new feature described against kinship2; `NEWS.md` re-rendered; NB5/NB7 were dropped by S845). **Next in this item: slice 7b:** the internal docs (`docs/`, `ROADMAP.md`, `CLAUDE.md`, `BACKLOG.md`). Four likely code defects the audit found
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
      `docs/planning/issue167-longitudinal-monitoring-plan.md` §5 Slice 5 / §7 Dragon 1
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
      (`R/modPedigree.R:675-790`: legend/image-export/tooltips) into a script-callable
      visNetwork renderer (the unique value per the gap doc's ecosystem observation; the one
      substantive new-work item); parity closers IN — export the shrink helpers + `bitSize`
      (tested internals, `R/shrinkPedigree.R:227-380`), port `familycheck` + `ibdMatrix`
      (the two full absences), and user-suppliable layout hints (autohint's override half —
      real engine-surface design); OUT — block-sparse `makekinship` (dense whole-colony
      matrices are current practice); API shape (data-frame-as-is vs kinship2-compat layer)
      DELIBERATELY OPEN — decide at plan time with a prototype in hand. When unblocked, the
      pickup is a planning session (package boundary/plan doc in `docs/planning/`,
      evidence-based inventory); step 0's prep is complete — D-1 landed S744:
      `makePedigreeMatingLayout(kinshipMatrix = )` (`R/makePedigreeDiagramData.R:1685`)
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
      declare `output: html_document` (`vignettes/a2interactive.Rmd:4-7`,
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
      the chromote CDP-timeout fallback fix below, READY, Effort M -- research only, not
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
      the canonical design's own deferred H4 remedy (`docs/planning/ledger-trimmer-design.md`
      §10.2, "the lever is receipt size, and the mechanism would be a norm plus a check, not
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
      **Pass history** (per-pass detail in `CHANGELOG.md`): S529 Housekeeping section (263 lines
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
      **Candidates for the next pass (measured 2026-09-24; re-grep, sizes not anchors):** none --
      no resolved-narrative section or stub remains, and every remaining `##` section holds open
      items. Regrowth check: 378 lines now; the file was 480 lines after S752 and 561 before this
      pass. The next pass is a regrowth check, not a known cut.

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
      Each is its own session; the Diagram section of `NEWS.Rmd` says "most of kinship2's
      conventions" until both ship.

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
and a refresh of `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`. **Tier 2**
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
