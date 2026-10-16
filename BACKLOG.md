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

- [ ] **Audit the internal and user-facing documentation for stale information and stale
      diagrams** (owner-requested 2026-09-26; DECISION NEEDED (part 2 only; part 1, slice 2, finished S944), Effort S each) -- the owner noticed that two article PDFs showed stale figures.
      **Method** (each slice is its own report, `docs/audits/DOCS_STALENESS_AUDIT_SLICE*`, per
      `AUDIT_WORKSTREAM.md`): check every claim, number, screenshot and diagram against today's
      code or output (regenerate the figure from the current source and compare; count, don't
      recall); list each stale item with its source path; fix it or file it. Related, not
      duplicated: the deferred `a2interactive` pass and the `inst/doc/` slimming item.
      **Slices audited, and their wording findings FIXED** (each has a `CHANGELOG.md` entry that
      carries the counts, and a report): 1 (S820) PDFs and article images -- the untracked PDF is
      gone (`3a8c026bb`, S831), the tracked one was deleted and the one stale kinship2 image
      regenerated (S884), two stale code comments fixed (S882, S883); 2 (S821) screenshots, NOT
      fixed, see below; 3 (S822) article prose, fixed S823; 4 (S824) user manual, in-app guidance
      pages and README, fixed S825-S828 and S830; 5 (S832) `a2interactive.Rmd`, fixed S833;
      6a-6e (S834-S842) all 267 `man/` pages, fixed S835, S837, S839, S841, S844; 7a (S845)
      `NEWS.Rmd`, fixed S846-S847; 7b (S852) living internal docs, 33 of 35 fixed S853; 7c (S860)
      live `docs/planning/` plans, fixed S861, and a header sweep of all 84 plans (31 bannered),
      S862; 8 (S868) `docs/research/` and older `docs/audits/`, a status banner on 26 files, S870.
      **Still open.** (1) *Slice 2* (S821, `DOCS_STALENESS_AUDIT_SLICE2_2026-09-30.md`) was scoped
      S927 into 7-8 sessions: `docs/planning/docs-audit-slice2-screenshot-plan.md` (its owner decisions
      D2 to D5 are all ruled; D1, the order, was followed as the plan recommended; Phase 1, the session-ending crash, was fixed S928 and Phase 2, the capture scripts'
      honest reporting, S930: one shared helper, `tests/testthat/helper-captureHarness.R`, and the
      `NPRC_SHOT_DIR` folder setting; Phase 2's item (e), the full-height `potential_parents_results.png`
      capture, needed no script change (S940: the fixed script's capture is 1300 x 7121, the committed
      height; S927's 900 px was the crashed run); Phases 3a (S941; D2 ruled: delete the orphan), 3b (S942; D3 ruled:
      accept the install date), 3c (S940) 4a (S943; D4 ruled: build the tables) and 4b (S944; D5 ruled: script all nine) are DONE, so slice 2 is finished). Measured S927:
      37 of the 38 script-written `shiny_app_use/` images differ from the app (S821 said 31); the colony
      script's tail failure was that crash (an animal with no birth date in a group), not a script bug,
      and it is fixed; S928 checked it in the headless test driver, S929 by hand in a real Chrome window
      (the owner: `ExamplePedigree.csv` on the Input tab, Form Groups with the defaults, Top ranked; the
      page stayed live and the Genetic Diversity tab drew the heat map; "All available" was checked only
      in S928's headless run, not by hand). Also: 12
      images have no script (2 of the 3 CSV
      pictures are stale from the code alone). S933 retook `read_and_check_pedigree.png` alone
      (the Input tab's new no-birth-date warning made the old picture show Warnings 1; the app now shows 2 and the
      guide text says 2), with the guide's own script into a scratch folder (81/81 steps), copied alone.
      S934 retook `genetic_diversity_heatmap.png` alone (the heat map's names were cut off and tiny; the new
      picture shows them whole at 22 pt, and S931's note), with the guide's own script into a scratch folder,
      copied alone; that run was stopped after the heat map step, so it is not an 81/81 run.
      S935 retook it again (the note under the grid now names the Production and Inbreeding columns), from a
      full 81/81 run, copied alone.
      S936 retook `read_and_check_pedigree.png` (the QC Summary boxes are colored now, and the capture script
      waits for the yellow pop-up to close, which the container crop had cut off mid-sentence), from a full
      82/82 run, copied alone.
      S940 did Phase 3c: 10 pictures retaken (the six Breeding Groups ones, the heat map, Potential Parents
      and both Mate Pair ones) from one full 82/82 run, copied by name. The Group Detail picture's "Group to
      view" box had been blank since 2026-07-10 (the script typed "Group 6"; the box's values are numbers),
      fixed with a test first (`test_captureHarness.R`); the heat map was retaken again (the groups are
      living animals with birth dates now, so S935's note is gone); the Mate Pair caption said all alive
      animals but the picture shows a custom list of six, fixed. Its two findings for the owner (the Group
      Detail kinship caption and the unused animals' "Group 7" heading) were ruled S950: the guide's words
      changed and the app did not; S961 then renamed the box "Unused animals" on the Groups, Statistics and Group Detail tabs.
      S941 did Phase 3a: 14 pictures retaken (9 Pedigree Browser, 5 Diagram) from the colony script's full
      81/81 run and the diagram script's 18/18 run, copied by name; each was 147 px taller than the
      committed one (the longer Display Unknown IDs text) and now shows the `placeholder` column and no
      stale QC pop-up. The owner ruled D2 (delete): `pb_unknown_displayed.png` and its capture step are
      gone (test first, `test_captureHarness.R`). The legend picture shows the dashed "Same animal,
      again" row and the dashed-line paragraph (`pedigree-diagram.qmd:50-56`) names it. Captions fixed:
      "6-animal" is 21 animals, "the top union" is 8LKBV9 x his daughter FJIB3R, the affected picture
      is 12 animals with 4 filled (not three), the names picture is its own 12-animal lineage, and the
      first Pedigree Browser alt text. The two leftovers were the Direct-style item (fixed S949: the article's edge-style
      section now shows a Direct picture, `diagram_direct_edge_style.png`, and says the first picture is the Rectilinear
      default) and the pop-up item (the first item under Up Next).
      S942 did Phase 3b: 12 pictures retaken (Input x4, Home, Age-Sex Pyramid, Summary Statistics x3, Genetic
      Value x3) from the colony script's full 81/81 run, copied by name; sizes matched S927's measurements. D3
      was ruled: accept. The Home picture shows the 2026-10-07 install date and a three-row navigation bar (De-
      Identified Export and Genetic-Health Trends are new tabs). In S942 the Genetic Value results showed imports with
      a recorded origin first, as the prose said (S956 retook both for the living-animals default) (the committed ones, taken 2026-08-10, had no-parent, no-origin animals first; why was not looked into); the
      500-row picture's caption and alt text said rows 1 to 10 of 500, 50 pages (S956: 332 entries, 34 pages), not a High-to-Low transition
      it never showed. Two findings for the owner were the Summary Statistics duplicates item (fixed S945: three
      different pictures) and the Genetic Value row-names item (fixed S946: the table is built with no row names). Phases 4a and 4b then remained.
      S943 did Phase 4a (D4 ruled: build the tables in the guide): the three spreadsheet pictures
      (`ss_kinship_matrix`, `ss_first_order_relationships`, `ss_female_founders`) are deleted and the guide builds
      the three tables itself, in the chunk labelled `summary-export-tables`
      (`vignettes/articles/colony-manager-guide.qmd:468`), from the example file with the export buttons' own
      `write.csv` lines; a kinship corner (the first animal with 3 or more offspring and its first three), and the
      first 8 rows of the first-order and female-founders files. Measured first in the real app (the three export
      buttons, headless): exported functions alone rebuild all three files byte for byte (about 5 s); the old
      first-order picture matched 0 of its 22 rows (cause not looked into), the founders picture lacked
      `fromCenter` and `placeholder`, the kinship picture listed the animals in another order. The gate is
      `tests/testthat/test_guideExportTables.R` (9 blocks): what the guide shows must equal the same cells of
      what the buttons write. S944 did Phase 4b (D5 ruled: script all nine): the nine Marker Genetics pictures are retaken by a new script,
      `vignettes/articles/marker-genetics-screenshots.R` (one fresh app per picture; its five made-up data sets come from
      `tests/testthat/helper-markerPictureFixtures.R`, copies of the hand-checked fixtures in `test_modMarkerGenetics.R`, and the
      other four use files the package ships). Measured first in the real app (headless): every number in all nine old
      pictures still matched; what had changed was the page (8 sub-tabs and 4 upload boxes now; the five oldest pictures
      showed 0 to 5 sub-tabs and 1 or 2 boxes). The gate is `tests/testthat/test_markerPictureScreenshots.R` (16 blocks, 72
      expectations): the script's pictures equal the guide's nine, every picture goes through a pop-up wait, and the data
      run through the real module give the numbers the captions quote. **Slice 2 is finished:** all 46 pictures in
      `shiny_app_use/` (measured S944: each is taken by one of the three capture scripts and cited by the guide or the Diagram
      article) now come from a script, and the guide's abstract says "current as of 2026-10-08". Wording fixed in the
      same pass: the Heterozygosity caption (its animals are X, Y, Z), the Candidate tab's "Current limitation" note
      (issue #155 had fixed it), and the caption's "10 shared loci" (3 of 10 disagree). Its one finding for the owner, the
      Candidate tab's blank table without `fromCenter`, was ruled and built S948 (the tab now says why).
      (2) *Owner decisions about code, found by slices 4 and 6-8* (DECISION NEEDED, Effort S each;
      reword the docs if the code changes; carried as recorded S870 and not re-checked against
      today's code, except where a present-day check is named; the ids are in each slice's
      report): 6a-6b, the ten oldest flags, re-checked S986
      (`docs/audits/DOCS_AUDIT_PART2_SLICE_6A_6B_RECHECK_2026-10-14.md`: 9 findings, 1 moderate, an invalid date in a
      file with two date columns, fixed S987, PB7, `checkChangedColsLst()` counting every rename, fixed S988, and PB4, `checkRequiredCols()` ignoring an `NA` name, fixed S989; MC1 was fixed S923; the owner took the recommended option on all four rulings S986,
      and the last two, the help sentences for MB3 and PD12, were fixed S990; MA3/MB14 are closed by a run and PB13, PA4 and PD1 stay as documented);
      6c 8 candidates, re-checked S976
      (`docs/audits/DOCS_AUDIT_PART2_MARKER_GENETICS_RECHECK_2026-10-13.md`: all 11 claims still real, the
      owner ruled on all of them S976; the first ruling, a blank allele as missing, shipped S977, the second, the F_ROH warning and notice, shipped S978, the third, the two small marker fixes, shipped S979);
      6d 21 candidates, re-checked S991
      (`docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md`: 5 closed by later sessions (CA1, CA4, CB2, CC4, CD6), 16 still
      true, 2 moderate: the Genetic Diversity tab stopped when a group held a living animal outside the Genetic Value population
      (CA2: the owner took the recommended ruling S993 and it is fixed, `R/appServer.R:448` passes `sharedKinshipMatrix`, `NEWS.Rmd:451`),
      and Download Plot on the Age-Sex Pyramid tab saved the packaged example's pyramid when nothing was loaded (CD5: the owner
      took the recommended ruling S992 and it is fixed, `R/modPyramid.R:141,146`, `NEWS.Rmd:445`); 14 minor; one new stale help clause
      (N1, `R/modGeneticDiversity.R:81-84`); **the housekeeping list was done S994** (N1's clause, CD1's `darkblue`, the CD2 and CC1 comments, CD4's ten
      popovers, CA5's two alert sentences; gate `test_docsAuditHousekeepingWording.R`; the pyramid line still shows gray, the theme forces it);
      **CC1 was built S997** (the owner chose "keep the pairs that fit, no message": a twin file is checked against the whole studbook and each place
      gets only the pairs whose two animals it holds, `R/modPedigree.R:530`, `R/twinPairsWithin.R:20`, `NEWS.Rmd:89`; gate
      `test_modPedigree_twinRelationsTrimmed.R`); **CB1 was built S998** (the owner chose "both cases, one sentence": with "separate files" the QC Summary says
      "The genotype file was not used, so no genotypes are used. Reason: ..." for a genotype file the check refuses or the app cannot read, and a file with a short row
      no longer greys out the page and ends the session; `R/readSeparateGenotypeFile.R`, `R/modInput.R:488-504`, `NEWS.Rmd:525`; gate `test_modInputSeparateGenotypeNote.R`);
      **CB5 was built S999** (the owner took option (a): the Marker Genetics module's returned `isReady` answers FALSE, not an error, for a genotype file the module cannot use;
      nothing in `R/` reads `isReady`, so the running app looks the same; `R/modMarkerGenetics.R:595,1347`, help `:479-481`, `NEWS.Rmd` Minor; gates `test_modMarkerGenetics.R`,
      `test_modMarkerGeneticsIsReadyHelp.R`);
      **CA3 was built S1000** (the owner chose to keep the leftover row and call it "Unused animals", with `groups()` left as it is and one new returned item, `groupLabels`:
      the Genetic Diversity heat map's last row, when some animals fit no group, now reads "Unused animals" as the three Breeding Groups pages do; `R/modBreedingGroups.R` `boxLabels`,
      `R/nameBreedingGroups.R`, `R/appServer.R:434-439`, `NEWS.Rmd:279-283`, the guide and the manual say it; gates `test_modBreedingGroups_groupLabels.R`, `test_nameBreedingGroups.R`,
      `test_appServer_server.R`, `test_unusedAnimalsHeatMapWording.R`);
      **the owner's other rulings are not yet taken**, the report proposes one per finding with a recommendation: CC5 is the owner's call,
      and CB3, CB4, CC2, CC3 and CD3 stay as they are), and the R `helpText` at `R/modGeneticValue.R:88` still says
      "Summary Statistics relationship table" (present S890; not re-checked); 6e 46 candidates CE-CL, re-checked S1003
      (`docs/audits/DOCS_AUDIT_PART2_SLICE_6E_RECHECK_2026-10-15.md`: 1 closed by a later session, CF2 in S923; 45 still
      true, 6 moderate (CE2 `fromCenter` text, CE4 and CE5 Cross-Center, CF3 Excel upload fails for kinship overrides and
      snapshot history, CI1 example-config API-key placeholder, CJ3 under-age males in sex-ratio groups) and 39 minor;
      **one new moderate, N1: the Mate Pair table pairs animals of unknown sex, lists them as sire or dam and pairs an
      animal with itself** (`R/reportMatePairs.R:198-211`); **all seven ruled S1004 (fix, option (a) each time); CF3, the Excel upload, fixed S1005, the other
      six queued as five fix items below**, and 13 small wrong statements for one housekeeping session (an item below); CL9 is the open item below),
      and `R/makeGroupNum.R` still says `numGp` "Default is 1" while the examples in
      `R/fillGroupMembersWithSexRatio.R` and `R/groupAddAssign.R` still pass deprecated
      `minParentAge` (all three present S890); 7b/8 CV1 and CV2 (`getGeneticDiversityStats()`
      exports with no `@examples`; the `savePlotToFile` example uses `\dontrun`); the four
      likely code defects of *slice 4* (this item's earlier "8" label was wrong), re-checked against today's code S966
      (`docs/audits/DOCS_AUDIT_PART2_FOUR_CODE_CANDIDATES_RECHECK_2026-10-12.md`): all four are still real and the docs
      already say so, except one wording line, fixed S967 (the `groupAddAssign` roxygen and its `man/` page said
      "largest average size" and now say "largest minimum group size (the score is the size of the smallest group)",
      gate `tests/testthat/test_groupAddAssignHelp.R`; "or younger" was fixed S844). **Three rulings, all taken S968** (the owner took the
      recommended option each time): the two do-nothing Genetic Value checkboxes were removed S969; the "Upload list" choice
      was removed S970 and the candidate list it promised was built S973 ("My own list"); the unused-genotypes notice was redirected S970
      to making the genotype columns work (its item below).
      (3) *Left unsettled by the doc slices:* RO8 (Quarto slices 3-4 status) and the other ids in
      RO3 were reworded "not recorded" / "not re-checked"; AR3's "about 53" is attributed to
      Learning 347, not re-counted; slice 8 left open whether to replace stale `file:line` cites
      in the plans and gap analysis with function names, and D's six parent-to-union edges that
      still differ in row.

- [ ] **Make the Mate Pair table pair only animals of known sex (READY, Effort S; strict TDD)** (ruled S1004: fix,
      option (a); Finding 2, N1, found S1003, `docs/audits/DOCS_AUDIT_PART2_SLICE_6E_RECHECK_2026-10-15.md:72-92`;
      second of six) -- `R/reportMatePairs.R:198-211` drops only male-male and female-female pairs and reads `isSire1
      <- sex1 == "M"`, so an animal of sex `U` is listed as the dam and an animal is paired with itself (a colony of
      M1, M2, F1, F2 and two unsexed living animals: 15 pairs, 7 whose "sire" is not male, 2 self-pairs; `qcPed` with
      two animals set to `U`: 177 of 1,979 pairs hold a `U` animal); `R/modMatePair.R:392-394,431` passes every living
      animal. **Ruled fix:** pair only known-sex M and F and say in one sentence how many animals were left out. The
      `excluded` table's reasons are a closed list (`R/reportMatePairs.R:32-36`), so "add a reason" or "sentence only"
      is the session's PRE-RED question. `NA` sex is a different case (`filterPairs()` already drops every `NA`-sex
      pair, `R/filterPairs.R:58,65`). Fixtures: `matePairPed()` in `tests/testthat/test_modMatePair.R:28`; no test
      uses sex `U` today.

- [ ] **Make `convertFromCenter()` match whole values (READY, Effort S; strict TDD)** (ruled S1004: fix, option (a);
      Finding 3, CE2, `docs/audits/DOCS_AUDIT_PART2_SLICE_6E_RECHECK_2026-10-15.md:94-107`; third of six) --
      `R/convertFromCenter.R:34-39` matches an unanchored y/t and n/f: through `qcStudbook()` on `examplePedigree`,
      "unknown", "N/A" and "maybe" become FALSE, FALSE and TRUE with no error, warning or QC Summary line, while its
      help (`:13`) says an unrecognized value stops naming the rows. **Ruled fix:** accept whole values only (y, yes,
      t, true; n, no, f, false; any case) so anything else stops naming the rows. A file holding "unknown" then stops
      until corrected, so `NEWS.Rmd` says so. `R/qcStudbook.R:314` feeds the `fromCenter` column; `fromCenter` drives
      Candidate Parent Assignment. **Before anchoring the match** check the shipped files for free-text values
      (S1003's gotcha; S1004 scanned the CSVs in `inst/extdata/examples/`: only `rhesusPedigree_fromCenter.csv` has
      the column, 375 of 375 `TRUE`; the `.xlsx`, `.txt` and bundled data objects were not scanned).

- [ ] **Keep males under the minimum breeding age out of groups when a sex ratio is set (READY, Effort S-M; strict
      TDD)** (ruled S1004: fix, option (a) for CJ3, and CJ4 accepted with one help sentence; Finding 4,
      `docs/audits/DOCS_AUDIT_PART2_SLICE_6E_RECHECK_2026-10-15.md:109-127`; fourth of six) --
      `R/fillGroupMembersWithSexRatio.R:83` builds the "female" pool as every candidate that is not a potential sire,
      and a potential sire needs age at least `minAge` (`R/getPotentialSires.R:20-24`), so a younger male is placed as
      a non-male (40 of 40 `groupAddAssign()` runs, 2 groups, `sexRatio = 3`, `minAge = 1`; S1003) while
      `calculateSexRatio()` still counts him as a male. **Ruled fix:** leave a male under `minAge` out of both pools.
      CJ4 stays: a group stops being filled when its male pool is empty (`R/fillGroupMembersWithSexRatio.R:123-124`;
      about 2 females per group against 4 asked in the S1003 test), with one sentence in the `sexRatio` help
      (`R/groupAddAssign.R:56-58`). Reached from Breeding Groups "Sex ratio: Custom" (`R/modBreedingGroups.R:104-117`,
      `:451,544`); check the guide and `NEWS.Rmd` wording (`test_guideBreedingGroupsWording.R`).

- [ ] **Make the Cross-Center check flag an id clash and keep one-sided columns (READY, Effort S-M; strict TDD; one
      session for both)** (ruled S1004: fix, option (a) for CE4 and CE5; Findings 5 and 6,
      `docs/audits/DOCS_AUDIT_PART2_SLICE_6E_RECHECK_2026-10-15.md:129-155`; fifth of six) --
      `R/resolveCrossCenterIds.R:190-205` (`.checkCrossCenterCollision`) compares only ids not in the mapping, so an
      unmapped Center B `T1` against a mapped Center A `T1` shows "Mapping is clean" (0 issues) and the merge holds
      three rows with id `T1`; `:484-509` resolves only columns present on both sides, so a column one center recorded
      is `NA` for a mapped animal, and the whole column vanishes when every animal is mapped. The help promises both
      the check (`:359-363`) and the union of columns (`:382`). **Ruled fix:** also flag a Center B id equal to a
      mapped Center A id that is not the mapped one, and the mirror case (one more row type, shown with the others);
      take the non-`NA` side for every column and keep any column an input has. The module calls the function
      unchanged (`R/modCrossCenterIdentity.R:311`). Fixture to copy: `.ccUploadInputs()` in
      `tests/testthat/test_modCrossCenterIdentity.R:54`.

- [ ] **Make `getConfigApiKey()` ignore commented lines (READY, Effort S; strict TDD)** (ruled S1004: fix, option (a)
      for CI1, with CI3 in the same session; Finding 7,
      `docs/audits/DOCS_AUDIT_PART2_SLICE_6E_RECHECK_2026-10-15.md:157-170`; sixth of six) --
      `R/getConfigApiKey.R:17-24` does not drop `#` lines, so the shipped example config
      (`inst/extdata/examples/example_nprcgenekeepr_config:53`, a commented `apiKey`) returns
      "paste-your-labkey-api-key-here", which `R/setLabKeyDefaults.R:47-51` uses before it looks for a netrc file.
      **Ruled fix:** drop comment lines as `getOptionalConfigToken()` does (`R/getSpeciesOverridesPath.R:23-27`),
      tested on the shipped file. CI3: `getParamDef(<Center key>, "center")` stops "subscript out of bounds"
      (`R/getParamDef.R:19`). Not run against a LabKey server.

- [ ] **Find why the scheduled `shinytest2` run of 2026-10-16 failed in the Marker Genetics Genomic ROH E2E file
      (READY, Effort S)** (found S1004 Phase 0, reported and not fixed; the CI-break convention gives it no issue,
      only this item) -- run 38866018831 (schedule, 07:15 UTC, commit `82ad057f0`, job 116858920550), step "Run
      shinytest2 E2E tier in per-module fresh processes": only
      `tests/testthat/test-e2e-marker-genetics-genomic-roh-module.R` failed (4 of 11 expectations, 62 s; every other
      file in the run passed): `:166` `wait_for_element(...)` FALSE ("Confirm-export modal (and its Confirm Export OK
      button) must render live"), `:171` the click on `#markerGenetics-sequenceConfirmExportOk` finds no element,
      `:247` and `:249` the export guidance still reads the default "Generate a preview, then confirm the export to
      unlock the downloads." instead of "not in the loaded pedigree" and "1 animal". The three scheduled runs before
      it (13 to 15 October) were green, and the push it built (S1002) changed `R/modSummaryStats.R` and nothing in
      Marker Genetics, so a regression from S1002 is unlikely; a wait that is too short on the shared runner is the
      likeliest cause, unconfirmed. **First:** `gh run list --branch master --workflow shinytest2 --limit 5` for the
      nights since (a second red makes it real, a green leaves it a flake to harden), then read the waits around
      `:166` and `:247` and run the file locally (`NPRC_RUN_E2E=true`). Get a CI log with `gh api
      repos/rmsharp/nprcgenekeepr/actions/jobs/<job id>/logs` (`gh run view <id> --log` printed nothing here).

- [ ] **The 13 small wrong statements of the slice 6e re-check (READY, Effort S)** (found S1003; the report's first
      minor group, `docs/audits/DOCS_AUDIT_PART2_SLICE_6E_RECHECK_2026-10-15.md:176`) -- one housekeeping session in
      the S994 shape (help or code fixed, one test file; `tests/testthat/test_docsAuditHousekeepingWording.R` is the
      model). The eight candidates in functions nothing in `R/` calls (the report's "No caller in `R/`") could instead
      be retired under issue #37; that is the owner's call at pickup.

- [ ] **The guide does not name the "groups not in the pedigree" sentence (DECISION NEEDED -- add a sentence where the
      owner wants it, or leave; docs only, Effort S, the owner writes the sentence)** (found S995, widened S996) -- the Genetic
      Diversity page (`R/modGeneticDiversity.R:48-54`) and the Breeding Groups Groups, Statistics and Group Detail pages
      (`R/modBreedingGroups.R:222`) say one sentence when a formed group holds an animal the loaded pedigree lacks (after a
      new file or a trimmed view); `NEWS.Rmd` says it. The guide's Breeding Groups section
      (`vignettes/articles/colony-manager-guide.qmd:623-700`) and its Genetic Diversity paragraph (`:840-866`, which ends
      "Until groups are formed and an analysis has run, the tab shows guidance instead of an empty plot") name neither. Also:
      with that sentence showing, "Export Current Group" stops silently and writes no file (a module-level probe, S996; a
      browser download was not tried), while "Export Current Group Kinship Matrix" still writes the old group's matrix.

- [ ] **The Changed Columns tab and `summary()` skip some rename fields (DECISION NEEDED -- should the
      tab list every rename, Effort S-M; strict TDD)** (found S988, while `checkChangedColsLst()` was made to
      count every rename) -- `getEmptyErrorLst()$changedCols` has 13 fields. `shouldShowChangedColsTab()` checks 12
      (`R/shouldShowChangedColsTab.R:36-42`, none for `geographicoriginToGeographicOrigin`); `summary()` writes a sentence
      for 10 (`R/summary.nprcgenekeeprErr.R:111-165`, none for `recordstatusToRecordStatus`, `fromcenterToFromCenter` or
      `geographicoriginToGeographicOrigin`); `processQcStudbookResult()` makes a warning row only for `caseChange` and
      `spaceRemoved` (`R/processQcStudbookResult.R:198-215`). Measured S988: a list with only the `geographicorigin`
      field filled gives a blank `summary()$txt` and an empty `<ul>` from `insertChangedColsTab()`, so the owner ruled at
      the PRE-RED scope question to leave the tab alone: with an all-lowercase `geographicorigin` header
      `hasChangedCols` is now TRUE but the tab stays hidden (`NEWS.Rmd` says so). The same gap for `recordstatus` and
      `fromcenter` headers was read from the code, not run. **Decision:** open the tab and list every rename (three
      new `summary()` sentences, 13 fields in `shouldShowChangedColsTab()`), or leave it. If it changes,
      `test_appServer_dynamicTabs.R:189-209` ("both functions should agree", a 12-field list) needs a 13-field list
      and the `NEWS.Rmd` sentence changes.

- [ ] **A nameless (`NA`) column header stops `qcStudbook()` before any column check (DECISION NEEDED -- leave it,
      fix each site, or check once at the front, Effort S-M; strict TDD)** (found S989, while `checkRequiredCols()` was
      made to ignore an `NA` name, docs-audit part 2 flag PB4) -- script-only: a CSV blank header is read as `X`, so only
      `names(ped)[k] <- NA` reaches it. Measured S989 on `examplePedigree`: `qcStudbook()` with `reportErrors` TRUE and
      FALSE stops "missing value where TRUE/FALSE needed" in `fixColumnNames()` (`R/fixColumnNames.R:43` and `:46`,
      `if (any(tolower(newCols) == "firstname"))`), before `checkRequiredCols()` is reached. With `na.rm = TRUE` at both
      (previewed in memory, nothing committed) a nameless `birth` header gives `missingColumns` "birth" (and "Required
      field(s) missing: birth." with `reportErrors = FALSE`), but a nameless `origin` header still stops "undefined
      columns selected" at `R/addParents.R:47` (`ped[, names(ped) != "recordStatus"]`), and more sites may follow (not
      searched). The owner ruled S989, at the PRE-RED scope question, to fix `checkRequiredCols()` only (shipped S989).
      **Decision:** (a) leave it (script-only); (b) fix each site, each with a test; (c) check once at the front of
      `qcStudbook()` and stop with one message naming the column's position (the wording is the owner's).

- [ ] **The archive pointers name `docs/archive/`, but the shards sit in `methodology/archive/` (DECISION NEEDED -- leave them, rewrite them, or fix the trim tool, Effort S)** (found S1001, 2026-10-15, while trimming `CHANGELOG.md`) -- measured S1001 by resolving each pointer against its own file's directory: 52 do not resolve -- `methodology/SESSION_NOTES.md` 23 of 23, `methodology/HANDOFFS.md` 17 of 18, and the 12 in `methodology/archive/CHANGELOG-through-2026-10-14.md` (the live `CHANGELOG.md` has one pointer, and it resolves). Every target exists by name in `methodology/archive/`: the sync after S960 moved the shard directory from `docs/archive/` and the older pointers were not rewritten (the S991 and S1001 trims already write `methodology/archive/`). The 12 CHANGELOG pointers were already dead before the S1001 trim (the unmodified `HEAD` copy had the same links), so no proof broke: `verify.sh` and `--reverify` hold. **Decision:** (a) leave it (a reader finds a shard by name in `methodology/archive/`); (b) rewrite the 52 pointers (the 12 sit inside a frozen shard, so that one changes the shard's bytes and its `verify.sh` proof would have to be re-derived, not tried); (c) change `methodology_trim.py` so a pointer is written relative to where the shard really is (a synced file: see the local-customization checklist in `docs/conventions/CLOSEOUT_CHECKLISTS.md`).

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
      Chrome-provisioning steps), verified green on real CI.
      **Unexplained:** why the bootstrap probe `Runtime.evaluate("window.devicePixelRatio", ...)`
      (`private$get_pixel_ratio()`, chromote 0.5.1) never gets a response on the pinned macOS ARM64
      binary, though the same binary works on ubuntu-latest/windows-latest and ambient Chrome works
      on macos-latest (raising `default_timeout` to 60s changed nothing: the session is wedged, not
      slow). The only plausible analog found is Mozilla Bugzilla #1893921 (Firefox's content-process
      spawn hitting a 5s sandbox-denial stall on GitHub's *virtualized* macOS ARM64 hosts); no
      matching Chromium tracker entry exists. Only worth pursuing if pinned-Chrome reproducibility
      on macOS becomes valuable: `xattr -l` on the extracted `.app` on a live failing runner (the
      research found Gatekeeper quarantine NOT evidenced for `browser-actions/setup-chrome`), or a
      new `rstudio/chromote` upstream issue (none matches this macOS+GHA+live-CDP-timeout
      signature).
- [ ] **Shard verify scripts that FAIL on lossless trims: reported upstream as `KJ5HST/methodology#93`;
      waiting on a fix and a way to regenerate old scripts (BLOCKED -- on upstream #93, Effort S once
      it ships)** -- S901 characterized all 10 red scripts (of 54: HANDOFFS 2 of 15, CHANGELOG 1 of 16,
      SESSION_NOTES 7 of 23) and diffed the records: **none is a real loss.** Three causes: (1) 7 scripts
      (v1.5.0): the trim shares a commit with the session's own close-out, so record 0 (a claim stub or a
      `status: pending` receipt) differs, and BL-27 keeps that a loud FAIL; (2) 1 script (v1.1.2): a
      baked-in `INJECTED=0`, fixed upstream since v1.2.0 but frozen scripts never benefit; (3) 2 scripts:
      the L2 "leak" test is a substring test, so a mid-line backtick quote of a front-matter line counts.
      Causes 1 and 3 are still in the current `main` of both `rmsharp/methodology` and `KJ5HST/methodology`
      (byte-identical, v1.5.0). The fork has issues disabled, so the owner chose `KJ5HST/methodology`;
      posted 2026-10-04 (https://github.com/KJ5HST/methodology/issues/93). Evidence and the posted text:
      `docs/audits/SHARD_VERIFY_SCRIPT_FAILURES_2026-10-04.md` (the issue starts at its line 150).
      **New at S917's Phase 0:** a comment on #93 (2026-10-05 16:32 UTC, from the `rmsharp` account, not
      recorded before) re-ran the 54 proofs from a clone at `2563a6ee0` and got the same counts. It says:
      cause 2 is fixed safely by testing whole lines instead of substrings (both shards go green, none
      turns red across 54 here and 103 in its own archive); cause 3 is not independent of cause 1 (the
      v1.1.2 `SESSION_NOTES-through-2026-08-15` shard still fails for cause 1's reason once regenerated);
      all 8 cause-1 shards have a claim stub or a `status: pending` receipt as record 0 and nothing
      else missing; and a `--reverify` would have to lift the record grammar from the frozen script,
      because the canonical `LEDGERS` table has no `SESSION_NOTES.md` entry. It proposes no patch yet.
      S917's own `HANDOFFS.md` trim was committed apart from its close-out and its verify script passes.
      **What is left:** read upstream's answer (`gh api repos/KJ5HST/methodology/issues/93/comments`;
      `gh issue view --comments` fails here); when
      a fix and a regenerate path ship, sync the trimmer (re-apply this project's `SESSION_NOTES.md`
      patch, per the `CLAUDE.md` checklist) and regenerate the 10 scripts; if upstream declines, decide
      whether to patch them here (a second local modification to `methodology_trim.py`, which the owner
      rejected S898). Until then do not quote front-matter command lines verbatim in receipts (Learning 797e).

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
      not anchors):** the docs-audit item (47 lines; S890 already compressed it, so check for
      regrowth first), this item's own history (41 lines), the paper item (24), the `inst/doc/`
      slimming item (21) and the trim verify-script item (20, now longer after S898). The
      verify-script item was one of the 7 parked Effort-S items; the owner kept all 7 open (S898),
      so it may be compressed (Candidate C, another of the 7, was closed S910). The standalone-package
      item is still 34 lines but is nearly all ratified-scope open text; leave it. Regrowth, for
      scale: 378 lines on 2026-09-24, 599 at S853, 552 before S890, 514 after S896.

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
      the NIH grant acknowledgment). Natural dependencies, the owner's call: a released 3.0.0 to
      cite (`DESCRIPTION` reads 2.0.0.9000 today) and the documentation audit above, so the
      papers' figures match the software.
