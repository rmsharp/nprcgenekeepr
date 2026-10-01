# Docs staleness audit, slice 6d: `man/` Shiny application and module pages (2026-10-01, S840)

Read-only audit. Nothing in the repo was changed except this report and the session records.

## Audit summary

- **Scope:** 34 of the 267 `man/*.Rd` pages, the "Shiny application and modules" topic group: the `Server` and `UI` page of
  each of the 15 modules (`modBreedingGroups`, `modCrossCenterIdentity`, `modDeidentifiedExport`, `modGeneticDiversity`,
  `modGeneticValue`, `modGvAndBgDesc`, `modInput`, `modMarkerGenetics`, `modMatePair`, `modORIPReporting`, `modPedigree`,
  `modPotentialParents`, `modPyramid`, `modSnapshotTrends`, `modSummaryStats`) plus `appServer`, `appUI`, `runGeneKeepR`
  and `runModularApp`. `man/` is generated from roxygen in `R/`, so a fix goes in the `R/*.R` roxygen block, then
  `devtools::document()`. Slices 6a-6c took 107 pages (the id list of each slice's "Items audited" table, split on
  commas, gives 107 distinct pages). **126 pages remain** (267 - 107 - 34). The 15 modules make 30 module pages, not the
  28 the earlier handoffs estimated.
- **Criterion:** does each checkable claim (argument list and defaults, return value and fields, described behavior,
  tab and control names, example runnability, `@seealso` targets, counts) match today's code? Read from the
  implementation and by running the calls (`testServer`, `formals()`), not from the roxygen alone.
- **Method:** four read-only subagents (sets A-D, ids RA/RB/RC/RD, 8-10 pages each). This session re-read the code for
  **all 8 moderate findings** and re-ran the two that rest on behavior (RA8 and code candidate CA4). One was
  downgraded (RD6, see below). Minor findings are the agent's own check: **R** = re-read the code, **A** = ran it.
- **Coverage:** 34 of 34 pages. None of the 30 module pages and `appServer`/`appUI` has an `@examples` block; the two
  `runGeneKeepR`/`runModularApp` examples are `\dontrun` launches and were not run. Every `\link` and `@seealso` target
  checked exists. The `ui_guidance/*.html` pages the modules load are outside this slice's scope and unaudited.
- **Findings:** 0 critical, **8 moderate, 34 minor** (42). 26 of 34 pages have no moderate finding. The pattern is
  different from slices 6a-6c: the module pages are mostly accurate about arguments (every `formals()` check held) and
  wrong about **what the returned list contains and when its reactives are ready**, plus several descriptions that
  list features the UI does not have or omit ones it does.

## Findings: Moderate

| ID | Location | Claim | Evidence | Fix | Check |
|---|---|---|---|---|---|
| RA1 | `R/modBreedingGroups.R:257-261` (`modBreedingGroupsServer`) | The paragraph "Up to 5 distinct candidate groupings are formed per run..." follows the `twinRelations` `@param` after a blank line | Roxygen folds it into that `@param`: `man/modBreedingGroupsServer.Rd:50` sits inside `\item{twinRelations}{...}` (re-read) | Move the paragraph above the first `@param` (description or `@details`) | R |
| RA3 | `R/modBreedingGroups.R:263-266` (`@return` `groups`, `nGroups`) | `groups` is a "list of character vectors with animal IDs per group"; `nGroups` is the "number of groups formed" | `validGroups <- filterValidGroups(cand$group)` keeps the trailing "Unused" group when non-empty (`:703-716`), so `groups` and `nGroups` include it. Agent's run: `nGroups = 2` requested, `nGroups()` 3, sizes 106/110/64; the Group Detail selector labels the last element "Unused" | "one character vector per formed group; when candidates remain unplaced a final 'Unused' element is appended (`nGroups` counts it)" | R, A |
| RA4 | `R/modBreedingGroups.R:269-270` (`@return` `unassigned`) | "candidate IDs not placed in groups" | `unassignedIds <- setdiff(candidateIds, unlist(validGroups))` (`:709-710`) and the Unused group is in `validGroups`, so leftovers are never "unassigned". Agent's run: `length(unassigned())` 0 with 64 animals in Unused | "Candidate IDs that appear in no element of `groups`; leftovers are collected in the trailing 'Unused' element, so this is normally empty" | R, A |
| RA8 | `R/modGeneticDiversity.R:63-64` (`@param kinshipMatrix`) | The reactive returns "the full kinship matrix" | `appServer.R:441-446` passes `gvResults$kinshipMatrix`, the GV tab's population-filtered matrix. Re-run here: `getGeneticDiversityStats(groups, qcPed, gv, kmat)` with the full matrix is fine; with a matrix cut to 12 animals it stops "kmat is missing kinship for group member(s): 9K2LZF, ..." | "Square kinship matrix covering every member of every group. In the app this is the genetic-value tab's population-filtered matrix." (see CA2: the wiring itself may be the defect) | A |
| RB1 | `R/modMarkerGenetics.R:455-456` (`@return` `exclusionTable`) | "the `markerParentageExclusion` flagged-pairs data frame" | `markerParentageExclusion()` returns one row per recorded parent pair with a `flagged` column (`R/markerParentageExclusion.R:67-68`). Agent's `testServer` run: 4 rows, all `flagged` FALSE. A reader expects only flagged pairs | "every recorded dam/sire pair with `exclusionCount`, `nLoci` and a `flagged` column (TRUE where the count exceeds the tolerance)" | R, A |
| RC1 | `R/modORIPReporting.R:9-20` (`modORIPReportingUI` description and `@details`) | The tab "includes" Breeding program statistics and Founder representation analysis | The UI has a Site Information table, a Colony Summary (counts) and a Genetic Diversity table; its own "Coming Soon" list names founder contribution, breeding success and PDF reports as not built. The two exports are plain CSVs (re-read; the two lines are `:19-20` and `man/modORIPReportingUI.Rd:27-28`) | "Currently shows site information, a colony summary (animal, sex and founder counts) and mean kinship and mean genome uniqueness, with CSV export. Breeding-program statistics, founder analysis and formatted reports are not implemented." | R |
| RC5 | `R/modPedigree.R:209-225` (`@return` of `modPedigreeServer`) | Lists 7 elements: `pedigree`, `processedPedigree`, `focalAnimals`, `nAnimals`, `populationCount`, `isReady`, `twinRelations` | The returned list has 8: `analysisPedigree` (`:878-879`) is missing. `appServer` uses it, not `pedigree`, as `shared$currentPedigree`; it is the focal-trim result without the Display Unknown IDs filter | Add "`analysisPedigree`: the pedigree the other tabs analyze (focal-animal trim applied, no Display Unknown IDs filter, which affects only the table)" | R, A |
| RD1 | `R/runGeneKeepR.R:27-28`, `R/runModularApp.R:14` (`@return`) | "Returns the error condition of the Shiny application when it terminates" | The body is `shiny::runApp(app, port = port, launch.browser = launch.browser)` (`:36-40`); nothing in `R/` calls `stopApp()` (grep, empty). `runApp` blocks and returns the value given to `stopApp()`, invisibly | "Called for its side effect; blocks until the app is stopped. Returns, invisibly, the value passed to `shiny::stopApp()` (normally NULL)." | R |

## Findings: Minor

| ID | Location | Claim and evidence | Check |
|---|---|---|---|
| RA2 | `R/modBreedingGroups.R:257` | "Up to 5 distinct candidate groupings": the count is the UI input "Candidates to retain" (`maxCandidates`, default 5, 1-50); fewer return when the run finds fewer distinct (`maxCandidates=7, nIterations=3` gave 3) | A |
| RA5 | `R/modBreedingGroups.R:271-272` | `groupKinship` "(if withKin=TRUE)": there is no `withKin` argument; the control is the checkbox "Include kinship in display of groups" (default FALSE); NULL otherwise | A |
| RA6 | `R/modBreedingGroups.R:213-227` | The options list says animal source is "top-ranked or all available"; the UI has three: "Top ranked", "Upload list", "All available" (see CA1). Undocumented: inclusion criterion, number of top animals and groups, minimum breeding age, simulations, exhaustive mode (only 1 group, sex ratio "none"), seed groups, and the Statistics / Group Detail / Ancestry tabs | R |
| RA7 | `R/modBreedingGroups.R:232-234` | `geneticValues` is "used to source the topRanked ... list"; it is also required (`req(geneticValues())`) for the genetic-value-floor criterion with any source, drops "Low Value" ids and ids absent from the report | R |
| RA9 | `R/modGeneticDiversity.R:56-58` | `groups` "one per breeding group (the groups returned by modBreedingGroupsServer)": those include the trailing "Unused" element (RA3), scored as another heat-map row (see CA3) | A, R |
| RA10 | `R/modGeneticDiversity.R:68-70` | `stats`/`heatmap` "NULL when data are not ready": errors raised inside `getGeneticDiversityStats` (missing kinship ids, NA birth dates, CA4) are not caught, so the reactive errors instead | A |
| RA11 | `R/modDeidentifiedExport.R:60-61` | "...and this file's `.buildDeidentificationManifest`": that helper is `@noRd`, and "this file" means nothing on a man page; the Rd renders `\code{` then a newline | R |
| RA13 | `R/modDeidentifiedExport.R:163-181`, `R/modCrossCenterIdentity.R:211-220` | `@return` lists reactives without saying that `exportedPedigree()`, `map()`, `manifest()`, `mergedPedigree()` and `issues()` halt via `req()` before Preview / Validate (and `mergedPedigree` while issues remain); a `try-error` in `testServer` | A |
| RB2 | `R/modMarkerGenetics.R:301-307` | The genotype file is validated by `checkMarkerGenotypeFile`; the shared and Center B uploads use `checkSequenceGenotypeFile` (the marker checks plus "." rejection and a `maxLoci` warning) | R |
| RB3 | `R/modMarkerGenetics.R:340-345` | "(found empirically this session, correcting the original PRE-RED plan)": session-history wording on an installed page; keep the reason (every `tabPanel` binds its outputs) and drop the parenthetical | R |
| RB4 | `R/modMarkerGenetics.R` `@return` `sequenceExport*` | "each NULL before then": also NULL when any genotype id is absent from the pedigree or when the ROH table or pedigree is NULL; only the MHC elements document the missing-id case | R |
| RB5 | `R/modMarkerGenetics.R` `@return` `comparisonTable` | `indivMeanKin` is NA for every row when the kinship matrix is NULL or errors, and for any genotyped id absent from it; not stated | R |
| RB6 | `R/modGeneticValue.R:173-181` | `@return` lists 8 elements; `testServer` returned 9: `kinshipOverrides` is undocumented and `appServer.R:361-427` reads it | R, A |
| RB7 | `R/modGeneticValue.R:165` | "Unlike `kinshipOverrideFile` below": no such name is documented on the page (it is a UI input id) | R |
| RB8 | `R/modInput.R:214-215` | `qcSummary` "(error/warning counts)": the list is `list(errors, warnings, records)` | R |
| RB9 | `R/modInput.R:216-221` | `minSireAge`/`minDamAge` re-parse the live text boxes; they are not the values the last "Read and Check Pedigree" used and can drift after an edit | R |
| RB10 | `R/modInput.R:212` | `genotypeData` "Genotype data if provided": only `id`/`first`/`second` from the cleaned studbook; a separately uploaded file that fails `checkGenotypeFile` is silently set to NULL (see CB1) | R |
| RB11 | `R/modInput.R:40-43` | `modInputUI` description omits the fourth File Content mode ("Focal animals only; pedigree built from database"), the two optional minimum age fields, the "Debug on" box and the QC Summary / Errors / Warnings / Cleaned Data tabs | R |
| RC2 | `R/modORIPReporting.R:130` | `@return` "A list with reactive components": exactly one, `colonySummary`, returning `list(nTotal, nMales, nFemales, nFounders)` (ran) | A |
| RC3 | `R/modORIPReporting.R:127-129` | `geneticValues` must be the flat report data frame (`indivMeanKin`, `gu`), not `list(report=)`; `siteConfig` needs `center`, `nodename`, `user`, `sysname`, `release` and falls back to `getSiteInfo(expectConfigFile = FALSE)` | R |
| RC4 | `R/modORIPReporting.R` (both pages) | The tab is mounted only when `shouldShowOripTab()` is TRUE (ONPRC site config); `appUI` says so, the module pages do not | R |
| RC6 | `R/modPedigree.R:218` | `isReady` "Logical indicating if pedigree data is ready": with no studbook, `isReady()` and `nAnimals()` raise a silent `req()` error instead of FALSE / 0 (ran; see CC2) | A |
| RC7 | `R/modPedigree.R:219-224` | `twinRelations` is validated against the focal-trimmed, unknown-hidden table pedigree; one id outside it makes `checkTwinRelations` stop and the whole sidecar becomes NULL, while the code comment says such pairs are "ignored" (see CC1) | R |
| RC8 | `R/modPedigree.R:8-9, 194-195` | Descriptions omit the Diagram tab (node caps 400 rectilinear / 750 direct, edge style, names, twin connectors, PNG export, click-to-focal), the twin sidecar upload, the Display Unknown IDs filter and focal-animal file upload | R |
| RC9 | `R/modPotentialParents.R:196-201, 229` | `pedigree` has default NULL and the module "degrades gracefully"; with `pedigree = NULL`, `observeEvent(pedigree(), ...)` fails ("could not find function 'pedigree'") (ran; see CC3). Graceful handling applies to a reactive returning NULL / zero rows | A |
| RC10 | `R/modMatePair.R:179-184, 203-219` | `allAlive` takes every id when `ped` has no `exit` column; `pairs()` and `excluded()` halt via `req()` before the first run (ran), not NULL | A |
| RD2 | `R/runGeneKeepR.R:9-19` | The app "includes" 8 items; `appUI()` has 16 top-level tabs plus a More menu (ran `appUI()`), including Mate Pair, Genetic Diversity, Marker Genetics, Cross-Center Identity, De-Identified Export, Potential Parents, GV & BG Description, Genetic-Health Trends and (ONPRC only) ORIP Reporting | A, R |
| RD3 | `R/runGeneKeepR.R:5-6` | Does not say the call blocks the R session until the app stops | R |
| RD4 | `R/runModularApp.R:5-8` | "soft-deprecated alias": a direct call emits the lifecycle message "was deprecated in nprcgenekeepr 2.0.0 ... use `runGeneKeepR()`" (seen with `runGeneKeepR` mocked); soft deprecation is silent for indirect callers; all arguments pass through | A |
| RD5 | `R/modSummaryStats.R:253-255` | `geneticValues` "Must be a data frame with columns id, indivMeanKin, gu. Optional zScore": `id` is never read; the module prefers `zScores` (what `reportGV()` emits) and accepts `zScore` as a legacy name | A |
| RD6 | `R/modSummaryStats.R:258-281` | **Downgraded from moderate in this session.** `kinshipMatrix` "If NULL the module calculates kinship"; overrides and twins apply "when the module recomputes (the usual path)". `appServer.R:378` passes `sharedKinshipMatrix`, which already applies twins and overrides (`:353-367`), so the supplied matrix is the usual path and is used unchanged; a supplied reactive that errors or returns NULL silently falls back to the recompute (`:370-375`). The doc's outcome is right for the app, its "usual path" is wrong; the comment at `:377-378` ("appServer passes kinshipMatrix=NULL") is stale (see CD2) | R |
| RD7 | `R/modSummaryStats.R:283-296` | `@return` lists 6 reactives; `names(session$returned)` has 14 (adds `mkShape`, `guShape`, `mkHistogram`, `zscoreHistogram`, `guHistogram`, `meanKinshipBoxPlot`, `zscoreBoxPlot`, `guBoxPlot`) | A |
| RD8 | `R/modSummaryStats.R:240-249` | The description omits the founder table, the Effective Population Size block, skewness and kurtosis, the six-number summary, PNG export of the six plots, and the first-order and relationship-class CSVs | R |
| RD9 | `R/modSnapshotTrends.R:114` | `isReady` "is a non-empty history loaded": the code is `reactive(!is.null(history()))`, so it says nothing about non-empty; whether a zero-row history can reach it was not tested | A |

## Code candidates (owner decisions; the docs would state today's behavior until decided)

| ID | Location | Observation | Check |
|---|---|---|---|
| CA1 | `R/modBreedingGroups.R:42` | "Upload list" (`animalSource == "custom"`) has no upload control and behaves exactly like "All available" | R |
| CA2 | `R/appServer.R:441-446` | The diversity module gets the GV tab's population-filtered matrix, but groups can hold animals outside it (e.g. "All available" with dead animals); `getGeneticDiversityStats` then stops, uncaught in `diversityStats()`. Re-run: partial matrix gives "kmat is missing kinship for group member(s)". `sharedKinshipMatrix` (full pedigree) is what other modules get | A |
| CA3 | `R/modBreedingGroups.R:1089-1091`, `R/appServer.R:429-431` | `bgResults$groups()` includes the trailing "Unused" bucket; the group count, the heat map and `shared$breedingGroups` treat it as a real group, while the Ancestry report strips it | A |
| CA4 | `R/getKinshipWithMaleStatus.R:~49-61` | A group member with a missing birth date gives `group$age >= minMaleAge` NA, `males` holds NA ids and `kmat[f, males]` fails. Re-run: `qcPed` has 47 NA birth dates; groups made of NA-birth animals give "subscript out of bounds", groups without them work. So `modGeneticDiversityServer` errors for any pedigree with an unknown birth date among group members | A |
| CA5 | `R/modDeidentifiedExport.R:286-291`, `R/modCrossCenterIdentity.R:373-378` | The alerts say confirming "unlocks" the Export tab or downloads, but the download handlers never check `confirmed()` (the docs say so); in the cross-center module the merged download still halts via `req(isClean())` | R |
| CB1 | `R/modInput.R:~336-346` | In separate-file mode `tryCatch(checkGenotypeFile(genotype), warning = NULL, error = NULL)` drops a bad genotype file with no message; QC then says "passed" with no genotypes | R |
| CB2 | `R/modGeneticValue.R:63-66` | The `calcGenomeUniqueness` and `calcMeanKinship` checkboxes are read nowhere in the server (dead controls) | R |
| CB3 | `R/modGeneticValue.R:338-340` | With the "categorical" ranking scheme the function returns before `setDataReady`, so the E2E ready flag is never set | R |
| CB4 | `R/modInput.R:~380-390` | The `is.null(rawData)` read-error path does not send `setDataReady`; the other error paths do | R |
| CB5 | `R/modMarkerGenetics.R` `isReady` | `reactive(!is.null(comparison()))` is not wrapped in `safeRead`; a malformed shared genotype upload makes `isReady()` throw instead of returning FALSE | R |
| CC1 | `R/modPedigree.R:501-518` | The twin sidecar is validated against the focal-trimmed, unknown-hidden pedigree but exported app-wide; a trim or hidden unknown ids can reject the whole sidecar and every other tab silently loses the twin correction (an error toast only) while the comment says such pairs are "ignored" | R |
| CC2 | `R/modPedigree.R:887-896` | `isReady` can never return FALSE (`pedigreeData()` halts first), unlike the Mate Pair `isReady` | A |
| CC3 | `R/modPotentialParents.R:229, 251` | The default `pedigree = NULL` is unusable: `pedigree()` is called in `observeEvent` with no guard, though `tryCatch(pedigree(), ...)` is used elsewhere in the file | A |
| CC4 | `R/modPedigree.R:444-450` | `.currentEdgeStyle()` returns "rectilinear" when the toggle is NULL, but the comment above says it defaults to "direct" | R |
| CC5 | `R/modORIPReporting.R:276-285` | "Export Demographics" writes the whole pedigree CSV unchanged (probably a placeholder) | R |
| CD1 | `R/modPyramid.R:46` | Help text style `color: darblue` (typo for `darkblue`); browsers ignore it | R |
| CD2 | `R/modSummaryStats.R:377-378` | Stale comment "appServer passes kinshipMatrix=NULL" (RD6) | R |
| CD3 | `R/modSummaryStats.R:357-364` | `tryCatch(kinshipMatrix(), error = function(e) NULL)` swallows every error from the supplied reactive and silently recomputes without the shared overrides | R |
| CD4 | `R/modSummaryStats.R` UI popovers | Export popovers say "to the user selected directory" but they are browser `downloadButton`s | R |
| CD5 | `R/modPyramid.R` `downloadPlot` | `png()`/`dev.off()` has no `on.exit(dev.off())` and no `req(pedigreeData())` guard | R |
| CD6 | `R/modPyramid.R` `pyramidStats` | Counts `sex == "M"`/`"F"` literally, where `modSummaryStats` uses `sexCodes[["male"]]` | R |

## Items audited

| Page | Findings |
|---|---|
| modBreedingGroupsServer | RA1, RA2, RA3, RA4, RA5, RA6, RA7 |
| modBreedingGroupsUI | none |
| modCrossCenterIdentityServer | RA13 |
| modCrossCenterIdentityUI | none |
| modDeidentifiedExportServer | RA13 |
| modDeidentifiedExportUI | RA11 |
| modGeneticDiversityServer | RA8, RA9, RA10 |
| modGeneticDiversityUI | none |
| modGeneticValueServer | RB6, RB7 |
| modGeneticValueUI | none |
| modGvAndBgDescServer | none |
| modGvAndBgDescUI | none |
| modInputServer | RB8, RB9, RB10 |
| modInputUI | RB11 |
| modMarkerGeneticsServer | RB1, RB2, RB3, RB4, RB5 |
| modMarkerGeneticsUI | none |
| modMatePairServer | RC10 |
| modMatePairUI | none |
| modORIPReportingServer | RC2, RC3, RC4 |
| modORIPReportingUI | RC1, RC4 |
| modPedigreeServer | RC5, RC6, RC7, RC8 |
| modPedigreeUI | RC8 |
| modPotentialParentsServer | RC9 |
| modPotentialParentsUI | none |
| modPyramidServer | none |
| modPyramidUI | none |
| modSnapshotTrendsServer | RD9 |
| modSnapshotTrendsUI | none |
| modSummaryStatsServer | RD5, RD6, RD7, RD8 |
| modSummaryStatsUI | none |
| appServer | none |
| appUI | none |
| runGeneKeepR | RD1, RD2, RD3 |
| runModularApp | RD1, RD4 |

## Not counted

- **Not a doc finding:** the `modDeidentifiedExportServer` text "not hard-gated on `confirmed`" is accurate (agent's RA12); the
  mismatch is the UI alert wording, filed as CA5. An agent's confirmed-correct claim (`snapshotSource` fields, RD10) is
  not a finding. Internal decision ids in the Mate Pair prose ("D1", "issue #151 Slice 1") were judged style.
- **Confirmed by running (agents, `testServer` and `formals()`):** every function's formals and defaults match its page;
  `modMatePairServer`, `modPotentialParentsServer`, `modPyramidServer` and `modGvAndBgDescServer` return what they
  document; the de-identified preview, manifest columns, stale-confirmation reset and alias map; the cross-center
  validate, merge and confirm flow; the 4 heterozygosity and candidate-assignment table shapes.
- **Not verified:** a live Shiny launch and real browser uploads (`testServer` simulates a `datapath`); the ancestry
  override flow and the ORIP gating (read only); the Linkage, ROH and MHC tab runtime paths (read only); the guidance
  HTML pages under `inst/extdata/ui_guidance/` (existence only); a zero-row history through `checkSnapshotHistory`
  (RD9). This session re-ran RA8 and CA4 and re-read the other 7 moderates' code; it did not re-run the 34 minors.
- **Reclassified:** the agent's moderate RD6 was downgraded to minor (above); RC10 and RA12 were kept or excluded as
  stated (RA12 is not a finding).
