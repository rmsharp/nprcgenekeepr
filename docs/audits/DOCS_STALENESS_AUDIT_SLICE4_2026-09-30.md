# Docs staleness audit, slice 4: manual components, in-app guidance pages, README (2026-09-30, S824)

Read-only audit. Nothing in the repo was changed except this report and the session records.

## Audit summary

- **Scope:** the 16 `vignettes/manual_components/*.Rmd`, the 8 `inst/extdata/ui_guidance/*.html` in-app help pages, and
  `README.md` (generated from `README.Rmd`, which pulls in five of the manual components as children). Narrowed at claim from
  the BACKLOG slice-4 list: `a2interactive.Rmd`, `man/`, `NEWS.Rmd` and the internal docs move to **slice 5**.
- **Criterion:** does each checkable claim (UI label, default, limit, count, function or argument name, described behavior,
  quoted number, file name, link) still match today's code or output? Read from the implementation, not its docs.
- **Method:** four read-only subagents (manual components in two groups of 8, the guidance pages, the README) read every
  line and ran cheap checks. This session then re-read the code for 26 of the 33 Moderate findings (marked **R**; 4 of those only partly: BA18, BA21, BB13, UG1),
  and re-ran `getRequiredCols()` / `checkRequiredCols()` (BA23). The other 7 are marked **A** (agent-run, not reproduced here).
- **Coverage:** 16 of 16 manual components, 8 of 8 guidance pages, README.md. About 260 claims found current (per-file
  counts were reported by the agents; the great majority of checked claims held).
- **Findings:** 0 critical, **33 moderate, 44 minor** = 77 as reported, **71 distinct** after merging 6 that two agents
  found independently (RM1=BB9=BA24, RM2=BB15, RM3=BB14, UG1=BA23, UG11=UG25). No broken link or anchor was found
  (`#pedigree_format` and `#genotype_format` resolve; the live URLs return 200 except two that block HEAD).

Check column: **R** = re-read by this session against the code; **A** = agent-run or agent-read result, not reproduced.

## Cross-cutting findings (fix once, in the owning file)

README.md is a render of `README.Rmd` plus `_introduction`, `_installation`, `_online_documentation`,
`_running_shiny_application` and `_summary_of_major_functions`. **Fix those children, then re-render README.md.** Several
claims recur in more than one place:

| Root cause | Where it appears | Truth today |
|---|---|---|
| Minimum parent age "defaults to 2 years" | RM1, BB9, BA24 | `minParentAge` is deprecated; `qcStudbook()` and the Input tab take separate `minSireAge` / `minDamAge`, blank = species floor, 2 years only when species unknown (`R/qcStudbook.R:53-63, 204-221`, `R/modInput.R:150-165`) |
| "Development Plans" article | RM2, BB15 | No such article; `_pkgdown.yml` lists 14, several not tutorials |
| "supports 5 functions" | RM3, BB14 | `R/appUI.R` has 14 analysis tabs besides Home, Settings, About, Help (the 5-item text is also `DESCRIPTION`) |
| Required columns are "Ego ID, Sire ID, Dam ID, Sex" | BA23, UG1 | `getRequiredCols()` = id, sire, dam, sex, **birth** (R: executed) |
| Genome-uniqueness threshold = "N other animals" | BA21, UG11, UG25 | `R/calcA.R:43`: `freq <= threshold`, frequency counts the animal itself; app offers 1-5, default 4 |
| Breeding-group default kinship = "second cousin" | BA6, BA13, UG16 | app default is `maxKinship = 0.25` (`R/modBreedingGroups.R:63-64`); 0.015625 is only the `groupAddAssign()` default |
| Candidate source "Upload list" / "enter IDs" | BA1, BA2, UG18 | `custom` and `all` both use every `ped$id` (`R/modBreedingGroups.R:532-537`); there is no upload control for candidates |

## Findings: Moderate

### Manual components, breeding groups and genetic value (group A)

| ID | Location | Claim | Evidence | Fix | Check |
|---|---|---|---|---|---|
| BA1 | `_breeding_group_formation.Rmd:106` | "Upload list: provide a custom list of candidate animal IDs" | `R/modBreedingGroups.R:40-43` only labels the choice; the module's one `fileInput` is the ancestry-rules file; `custom` and `all` both take `ped$id` (`:532-537`) | Say it currently behaves like "All available" (note a possible code defect: a choice that uploads nothing), or drop it | R |
| BA2 | `_breeding_group_formation.Rmd:107` | "All available: all animals in the current population" | `:532-537` takes every pedigree id; `analysisPedigreeData` never filters on `population` | "Every animal in the pedigree on the Pedigree Browser (not limited to the living population)" | R |
| BA3 | `_breeding_group_formation.Rmd:187-192` | Statistics tab shows average kinship per group, sex composition, unassigned animals | `output$groupStats` (`R/modBreedingGroups.R:995-1011`) builds Group, Total, Males, Females only | List those four columns | R |
| BA4 | `_breeding_group_formation.Rmd:182-185` | Groups tab shows "animal IDs and their genetic values; mean kinship within the group" | `:967-991`: heading "Group N (M animals)"; table has id, sex, birth, sire, dam | Describe as count heading plus member table | R |
| BA6 | `_breeding_group_formation.Rmd:224-227` | "By default ... ignores relatedness more distant than second cousins" | App default 0.25 (`:63-64`), which the same file states at `:131-132`; kinship below 0.25 is ignored | State the app default 0.25; keep "second cousin" for the function default | R |
| BA8 | `_breeding_group_formation.Rmd:167-170` | exhaustive mode intractable "for more than a couple dozen candidates" | `maxExhaustiveCandidates = 20L` is a hard `stop()` (`R/groupAddAssign.R:181, 385-390`); time limit 10 s (`:182`); UI hides the checkbox by group count and sex ratio only | State the 20-candidate ceiling and 10 s limit | R |
| BA11 | `_breeding_group_algorithm.Rmd:44-45` | low-value candidates "will be removed ... can be toggled off" | `groupAddAssign` has no low-value step; screening is the optional "Genetic-value floor" (`R/modBreedingGroups.R:555-559`), off by default | Describe the optional floor | A |
| BA12 | `_breeding_group_algorithm.Rmd:71-72` | "we calculate the average group size" | `score <- min(lengths(groupMembers))` (`R/groupAddAssign.R:280`); `gvAndBgDesc.html` says "largest minimum group size"; the `groupAddAssign` roxygen (`:11`) also says "average" | "score = size of the smallest group"; fix the roxygen too | R |
| BA17 | `_genetic_value_analysis.Rmd:36-37` | "Minimum Breeding Age: slider (default 2 years)" | No such control in `R/modGeneticValue.R`; real controls: iterations, Genome Uniqueness Threshold (default 4), Ranking Scheme, categorical sub-controls, 2 checkboxes, kinship-overrides upload | Remove; add the missing controls | R |
| BA18 | `_genetic_value_analysis.Rmd:30-34` | "Calculate Genome Uniqueness / Calculate Mean Kinship" toggles | `calcGenomeUniqueness` and `calcMeanKinship` appear only as UI inputs (`R/modGeneticValue.R:63-66`); the server never reads them (agent grep of all `R/`) | Remove the bullets, or say they have no effect (and consider whether the controls should exist) | R (UI lines) / A (no reader) |
| BA19 | `_genetic_value_analysis.Rmd:64-65` | Summary tab shows "means, standard deviations, and distributions" | `output$gvSummary` (`R/modGeneticValue.R:424-492`) is a Metric/Value table (animals analyzed, mean kinship, GU average, GU SE max, founder statistics); no SD or distribution | List the actual rows | R |
| BA21 | `_genome_uniqueness_algorithm.Rmd:18-19, 41-43, 75-76` | allele unique if "N or fewer **other** members" carry it | `R/calcA.R:43` `f$freq <= threshold`; `alleleFreq(a, ids)` counts distinct carriers including the animal itself; agent executed threshold = 1 on an allele carried only by A and it scored 1 | "carried by N or fewer animals in total, counting the animal itself" | R (code) / A (run) |
| BA23 | `_database_access.Rmd:23-24`; `_input.Rmd:37-38` | "the only columns required are Ego ID, Sire ID, Dam ID, and Sex" | `getRequiredCols()` returns id, sire, dam, sex, birth; `checkRequiredCols(c("id","sire","dam","sex"), TRUE)` returns "birth" | Add Birth Date | R (executed) |
| BA24 | `_input.Rmd:44-46` | minimum parent age "default is 2.0 years" | See cross-cutting table; the same file contradicts itself at `:68-69` | Two optional fields, species defaults | A |
| BA26 | `_database_access.Rmd:21` | QC "occurs automatically upon file upload" | QC runs on the "Read and Check Pedigree" button (`R/modInput.R:167`) | "when you click Read and Check Pedigree" | R |
| BA27 | `_database_access.Rmd:31-36` | QC adds a living-population flag; "Indian-origin, SPF 4"; "two options toggled through this panel" | No such options in the Input UI; no "SPF 4" restriction in `R/` (only ancestry vocabulary); population is set on the Pedigree Browser via `setPopulation` (`R/modPedigree.R:347`) | Rewrite or delete (see BA29) | R |
| BA28 | `_database_access.Rmd:38-39` | population "can be specified directly in the input file" | `setPopulation()` sets `population <- FALSE` first (`R/setPopulation.R:30`), so an input column is overwritten | Say focal animals are entered on the Pedigree Browser | R |

### Manual components, pedigree browser, summary statistics, introduction (group B)

| ID | Location | Claim | Evidence | Fix | Check |
|---|---|---|---|---|---|
| BB1 | `_pedigree_browser.Rmd:82-85` | Edge Style toggle: "Direct" (the default) and "Rectilinear" | `.currentEdgeStyle()` returns "rectilinear" when unset (`R/modPedigree.R:444-450`); the radio is built with `selected = style` | Rectilinear is the default | R |
| BB2 | `_pedigree_browser.Rmd:62-65` | "up to 750 animals ... drops to 400 when Rectilinear is selected" (S789 found this misleading) | Caps 750 / 400 (`R/modPedigree.R:426, 438`); `.currentDiagramCap()` (`:451-457`) gives 400 for the default style; count includes unknown-ID rows when shown | "up to 400 animals with the default Rectilinear style; up to 750 if you switch to Direct" | R |
| BB8 | `_summary_of_major_functions.Rmd:31-33` | ages added only "if a database connection is provided" | `qcStudbook()` adds `age` from birth/exit whenever a birth column exists and no age column does (`R/qcStudbook.R:337`); uses today for living animals | Drop the LabKey condition | R |
| BB9 | `_summary_of_major_functions.Rmd:38-43` | minimum parent age defaults to 2 years | cross-cutting table | same | A |
| BB13 | `_orip_reporting.Rmd:16-22` | tab "will eventually contain" reporting info, may be merged with Summary Statistics | `R/modORIPReporting.R` is a built tab (Export ORIP Report, Export Demographics, site, colony, diversity sections, a "Coming soon" list); it appears only when `center == "ONPRC"` and a config file exists (`R/shouldShowOripTab.R:34-36`) | Describe the current tab and its gating | R (gating) / A (contents) |

### In-app guidance pages (`inst/extdata/ui_guidance/`) and README

| ID | Location | Claim | Evidence | Fix | Check |
|---|---|---|---|---|---|
| UG1 | `input_format.html:44, 202-206` | "Either Age or Birth must also be provided"; "4 required fields" | `R/columnSchema.R:16` required includes `birth`; agent ran a file with `age` but no `birth`: fails "Required field(s) missing: birth" | `birth` column required (values may be blank when `age` supplied); 5 fields | R (schema) / A (run) |
| UG2 | `input_format.html:83-86, 166-179` | pedigree-file genotypes use `allele_1` / `allele_2`; text says `first` / `second` | `fixColumnNames` strips underscores; `hasGenotype()` needs `first` and `second`; agent ran `allele_1/2`: `hasGenotype(qcStudbook(d))` FALSE, genotypes silently unused | Document `first` / `second` for the one-file option | A |
| UG11 | `gvAndBgDesc.html:42, 45` | threshold "usually 0-3"; "at most x **other** animals" | App offers 1-5, default 4 (`R/modGeneticValue.R:42-44`); semantics per BA21 | State range, default, and meaning | R |
| UG12 | `gvAndBgDesc.html:59-90`; `genetic_value.html:2-6` | ranking described as the tiered rules only | "Ranking Scheme" defaults to "Combined (kinship - uniqueness)" (`R/modGeneticValue.R:45-49`); the tiers apply only to the non-default "Categorical" scheme, with sub-controls (high-uniqueness cutoff 10, low-kinship z cutoff 0.25) | Describe both schemes and the default | R |
| UG13 | `gvAndBgDesc.html:65-66` | "Imported animals without offspring are ranked highest" | `R/orderReport.R:79`: imports = both parents unknown with recorded origin; offspring not considered; "Undetermined" (no origin) not mentioned (same finding as GV1, fixed S823 in the article) | Reword; add Undetermined | A |
| UG14 | `gvAndBgDesc.html:79-80` | animals below the threshold "indicated by highlighting" | no `formatStyle`/`styleEqual`/`rowCallback` anywhere in `R/*.R`; the rankings table is plain | Refer to the `value` column | R (grep) |
| UG16 | `group_formation.html:21-22`; `gvAndBgDesc.html:115-116` | default ignores relatedness more distant than second cousin | see cross-cutting table | App default 0.25 | R |
| UG18 | `group_formation.html:7-8` | "If no candidate IDs are specified above or in the input pedigree, all population members will be used" | no candidate-ID entry; Source choices per BA1; selection is by Top N or value floor | Describe the real controls | R |
| UG20 | `gvAndBgDesc.html:123-125` | "repeated 10,000 times" | "Number of simulations" defaults to **10** (`R/modBreedingGroups.R:113-115`); `groupAddAssign()` default 1000 | Say user-set, default 10, recommend more | R |
| RM1 | `README.md:135-139` | min parent age defaults to 2 | cross-cutting table | fix in `_summary_of_major_functions.Rmd` | A |
| RM2 | `README.md:97-98` | Articles are tutorials "except for Development Plans" | cross-cutting table | fix in `_online_documentation.Rmd` | A |

## Findings: Minor

| ID | Location | Claim and fix | Check |
|---|---|---|---|
| BA5 | `_breeding_group_formation.Rmd:194-196` | within-group kinship matrix shown only "when Include kinship was checked"; `bgGroupKinView` is built from `res$kmat` regardless of the checkbox (`R/modBreedingGroups.R:1055-1061`). Drop the conditional | A |
| BA7 | `_breeding_group_formation.Rmd:131` | threshold "maximum allowed kinship"; a pair at exactly the threshold conflicts (`R/filterThreshold.R`, `>=`). "at or above this value are kept apart" | A |
| BA9 | `_breeding_group_formation.Rmd:209-213` | `groups` is a "list of data frames"; it is character id vectors; module also returns `score`, `groupKinship`, `ancestryRules`; `nGroups` counts the "Unused" group | A |
| BA10 | `_breeding_group_formation.Rmd:140-142` | ancestry status line counts "candidate animals no rule reaches"; it counts uncovered animals in the pedigree (`R/reportAncestryViolations.R:197-202`) and reads "No ancestry rules loaded." with none | A |
| BA13 | `_breeding_group_algorithm.Rmd:50-51` | "2nd cousin" default; name both defaults (see BA6) | A |
| BA14 | `_breeding_group_algorithm.Rmd:52-54` | female-female filter "can be toggled off"; hard-coded in the app (`R/modBreedingGroups.R:676`), adjustable only via `ignore` in script use | A |
| BA15 | `_breeding_group_algorithm.Rmd:66-67` | picks animal then group; `fillGroupMembers` picks the group first, then an animal | A |
| BA16 | `_breeding_group_algorithm.Rmd:72-74` | "return the currently saved groups"; up to `maxCandidates` (default 5) partitions are kept, each with an "Unused" group | A |
| BA20 | `_genetic_value_analysis.Rmd:77-79` | "approximately 6,000" kinship limit and automatic trimming; no 6,000 figure in `R/`; the module always trims to population ancestors (`R/modGeneticValue.R:309-311`) | A |
| BA22 | `_genome_uniqueness_algorithm.Rmd:79-81` | score reads as a proportion; `R/calcGU.R:99-102` multiplies by 100 (percent) | A |
| BA25 | `_input.Rmd:58` | "each results tab includes a download button"; QC Summary has none (`R/modInput.R:196-202`) | A |
| BA29 | `_database_access.Rmd` (whole file) | dated 2017, referenced by no vignette (agent grep); a stale duplicate of `_input.Rmd`. Delete or confirm it is intentionally orphaned | A |
| BA30 | `_gv_and_bg_desc.Rmd:18` | "GV & BG Description tab"; the tab is "Genetic Value Analysis and Breeding Group Description" (`R/appUI.R:290`) | A |
| BA31 | `_gv_and_bg_desc.Rmd:39` | promises "how sex ratio constraints are applied"; `gvAndBgDesc.html` has no sex-ratio content | A |
| BB3 | `_pedigree_browser.Rmd:47-48` | focal trim keeps "relatives"; it keeps ancestors and descendants only (`R/modPedigree.R:131-132, 360-371`) | A |
| BB4 | `_pedigree_browser.Rmd:141-147` | module "returns" four reactives; it returns eight (adds `analysisPedigree`, `processedPedigree`, `populationCount`, `twinRelations`) | A |
| BB5 | `_summary_statistics.Rmd:28-32` | four export buttons; there are six (`R/modSummaryStats.R:56-110`, adds Export All Relationships, Export Relationship Classes) | R |
| BB6 | `_summary_statistics.Rmd:83-84` | "Tukey five-number summary ... mean"; the code uses `summary()` (six values, `R/modSummaryStats.R:605-613`), and Skewness and Kurtosis columns follow | R |
| BB7 | `_summary_statistics.Rmd:88-93` | module returns only `summaryData`; it returns many more reactives | A |
| BB10 | `_summary_of_major_functions.Rmd:45-53` | focal pedigree only via `labkey.selectRows`; an offline path with a pedigree file exists (`getFocalAnimalPedFromFile()`, `R/modInput.R:97, 140-146`) | A |
| BB11 | `_summary_of_major_functions.Rmd:45` | stray trailing `\` in a heading | A |
| BB12 | `_summary_of_major_functions.Rmd:99-100` | pyramid "two-year increments"; Bin Size defaults to 2 but is adjustable 1-10, and Age Unit offers months (`R/modPyramid.R`) | A |
| BB14 | `_introduction.Rmd:32-42` | "supports 5 functions" (cross-cutting; `_pkgdown.yml:11-28` repeats it) | A |
| BB15 | `_online_documentation.Rmd:24-25` | "Development Plans" (cross-cutting; counted Moderate as RM2) | A |
| BB16 | `_software_development.Rmd:41-42` | logging "occurs in the server.R file"; no `R/server.R` (it is `R/appServer.R` plus `R/modInput.R`); "the the" typo | R (`ls`) |
| BB17 | `_software_development.Rmd:54` | "As of 20241223 95.70 percent of the lines are covered"; nine months old, not re-measured. Refresh or drop the number | A |
| UG3 | `input_format.html:248 vs 275-293` | genotype file "required columns id, first_name, second_name" vs table `allele_1/allele_2`; `checkGenotypeFile` only needs 3 columns, first containing "id", columns 2-3 positional | A |
| UG4 | `input_format.html:117-125` | hermaphrodite listed as a sex code; `convertSexCodes` default `ignoreHerm = TRUE` makes it Unknown | A |
| UG5 | `input_format.html:53-55, 101, 106, 111, 278` | IDs "must be alphanumeric"; only a period is rejected (`R/hasInvalidIdChar.R`), same overstatement fixed in the article and roxygen in S823 | A |
| UG6 | `input_format.html:184-185, 191-192` | "plain text file (.txt or .csv)", "Select Input File"; Excel is the default type; buttons are "Select Pedigree File" etc. and "Read and Check Pedigree" (`R/modInput.R:79-158`) | A |
| UG7 | `input_format.html:14-15` | placeholder ids "UnkownID and UnkID in Pedigree Brower tab"; neither name exists in `R/`; typos; refer to "Display Unknown IDs" and the `placeholder` column | A |
| UG8 | `input_format.html:226-230` | age = (Birth - Exit)/365.25; `R/calcAge.R:29` is (exit - birth)/365.25 rounded to 0.1 | R (code read) |
| UG9 | `input_format.html:166, 250, 261, 266` | markup defects (`#FSFFCC`, stray `</p>.`, missing `)`, `</hr>`) | A |
| UG10 | `input_format.html:34` | mailto subject names "nprcmanager" | A |
| UG15 | `gvAndBgDesc.html:74, 78-79` | "= 10%" and "= 0.25" look like lost inequality signs; code is `gu > cutoff` / `zScores <= zScoreCutoff` (`R/orderReport.R:110-120`) | A |
| UG17 | `group_formation.html:25-26` | "less-than, or equal-to the specified age"; `R/filterAge.R:26` keeps a pair when age `>= minAge` or unknown, so equal age is not ignored; the `groupAddAssign` roxygen (`R/groupAddAssign.R:37-39`) says the same; female-female always ignored, not stated | R (filterAge) / A |
| UG19 | `group_formation.html:11` | "see the README tab"; no README tab exists | A |
| UG21 | `gvAndBgDesc.html:109-111` | "only animals above the threshold are considered"; real options are Top N, value floor, all (`R/modBreedingGroups.R:528-566`) | A |
| UG22 | `pedigree_browser.html:6-11` | column names "Ego ID ... Group and Import"; the table shows raw names (`id`, `sire`, `dam`, `gen`, `population`, `origin`, ...); no Group or Import column | A |
| UG23 | `pyramidPlot.html:2` | "Pedigree Age Plot"; the tab is "Age-Sex Pyramid" | A |
| UG24 | `genetic_value.html:63-65`; `summary_stats.html:37-39` | "Summary Statistics relationship table"; the tab has only export buttons, no on-page table | A |
| UG25 | `population_genetics_terms.html:143-144` | "at most a threshold number of other animals, default 1" (same as UG11; counted once) | A |
| RM3 | `README.md:46-57` | "supports 5 functions" (cross-cutting) | A |
| RM4 | `README.md:4, 8` | render date 2026-08-18; `getVersion()` now gives 2026-09-28. Re-render after fixing the children | A |

## Items audited

| Item | Status | Findings |
|---|---|---|
| `_breeding_group_algorithm.Rmd` | Fail | BA11-BA16 |
| `_breeding_group_formation.Rmd` | Fail | BA1-BA10 |
| `_database_access.Rmd` | Fail (orphan) | BA23, BA26-BA29 |
| `_genetic_value_analysis.Rmd` | Fail | BA17-BA20 |
| `_genome_uniqueness_algorithm.Rmd` | Fail | BA21, BA22 |
| `_gv_and_bg_desc.Rmd` | Fail (minor) | BA30, BA31 |
| `_input.Rmd` | Fail | BA23, BA24, BA25 |
| `_installation.Rmd` | Pass | none (4 of 4 current) |
| `_introduction.Rmd` | Fail (minor) | BB14 |
| `_online_documentation.Rmd` | Fail (minor) | BB15 |
| `_orip_reporting.Rmd` | Fail | BB13 |
| `_pedigree_browser.Rmd` | Fail | BB1-BB4 |
| `_running_shiny_application.Rmd` | Pass | none |
| `_software_development.Rmd` | Fail (minor) | BB16, BB17 |
| `_summary_of_major_functions.Rmd` | Fail | BB8-BB12 |
| `_summary_statistics.Rmd` | Fail (minor) | BB5-BB7 |
| `input_format.html` | Fail | UG1-UG10 |
| `gvAndBgDesc.html` | Fail | UG11-UG15, UG20, UG21 |
| `group_formation.html` | Fail | UG16-UG19 |
| `genetic_value.html` | Fail (minor) | UG12, UG24 |
| `summary_stats.html` | Fail (minor) | UG24 |
| `pedigree_browser.html` | Fail (minor) | UG22 |
| `pyramidPlot.html` | Fail (minor) | UG23 |
| `population_genetics_terms.html` | Fail (minor) | UG25; about 34 other claims current |
| `README.md` | Fail | RM1-RM4 (source: the 5 child components) |

## Structural observations

1. **The breeding-group and genetic-value pages describe an earlier UI.** BA1-BA4, BA17-BA19, UG12, UG18, UG20, UG21 all
   describe controls and tabs that were reshaped (candidate source, inclusion criterion, ranking scheme, group tabs). These
   pages were written once and not walked against the modules after the rework. A walk of `R/modBreedingGroups.R` and
   `R/modGeneticValue.R` control by control would regenerate them.
2. **Hand-typed defaults went stale (BA6, BB1, BB2, UG11, UG20, RM1).** Same lesson as slice 3: the defaults that held
   were the ones the page took from one place. Four of these defaults are stated in more than one file with different values.
3. **Likely code or UI defects surfaced by the audit** (not documentation fixes, so they need owner decisions, DECISION
   NEEDED): the "Upload list" candidate source uploads nothing (BA1/UG18); the "Calculate Genome Uniqueness" and "Calculate
   Mean Kinship" checkboxes have no effect (BA18); `groupAddAssign`'s roxygen says "average" group size (BA12) and "or
   younger" (UG17) where the code does otherwise; a pedigree file with `allele_1/allele_2` silently drops genotypes (UG2).
4. **`_database_access.Rmd` is an orphan (BA29)** with five wrong claims; deleting it removes them (check
   `a3manual.Rmd`'s child list and README first).
5. **Well-kept reference material:** `population_genetics_terms.html` (about 34 formula and threshold claims, all matched
   the code except the threshold wording), `_pedigree_browser.Rmd` apart from BB1-BB4 (about 30 claims current), and
   `_summary_statistics.Rmd`'s statistics formulas.

## Not verified (union of the agents' lists)

- External facts: LabKey netrc URL (405 to HEAD) and the thoughtco.com URL (403) in the README and
  `_summary_of_major_functions.Rmd:78`; CRAN availability of `install.packages("nprcgenekeepr")`; citation volumes and pages.
- The 95.70% coverage figure (`_software_development.Rmd:54`; a full `covr` run was not done).
- Empirical claims: "default 1,000 iterations gives sampling error below one percentage point" (`gvAndBgDesc.html:50-51`),
  the FG "finite-sample bias" wording, "living breeders usually smaller" (`population_genetics_terms.html:94-95`).
- `README.md:138-139` (parent-age check skipped for missing birth dates), the pyramid explanation text, MathJax rendering
  of the guidance formulas, and `population_genetics_terms.html:262-483` threshold details (ROH, LD, MHC, LOD).
- `unassigned` module reactive wording in `_breeding_group_formation.Rmd` (probably imprecise; includes "Unused").
- 7 of the 33 Moderate findings are agent-run only (A): BA11, BA24, BB9, UG2, UG13, RM1, RM2; re-read each before fixing.
  Most Minor findings are also A.

## Omissions (not defects)

`input_format.html` omits several recognised optional columns (origin, status, species, condition, spf, vasxOvx,
affected, placeholder, recordStatus); `population_genetics_terms.html` has no entry for the mean-kinship z-score, the
Genetic Diversity heat-map metrics, Genetic-Health Trends or Mate Pair statistics; marker-statistic entries sit on the
Summary Statistics tab although they display on Marker Genetics.

## Comparison with prior slices

| Metric | Slice 3 (articles) | Slice 4 (manuals, help pages, README) | Trend |
|---|---|---|---|
| Files | 11 | 25 | n/a |
| Moderate | 7 | 33 | worse: older, hand-written pages |
| Minor | 22 | 44 | worse |
| Broken links or functions | 0 | 0 | stable |
| Dominant cause | hand-typed counts | pages describing an earlier UI, stale defaults | new: UI drift |

## Recommendation

Fix in one docs-only session per cluster, in this order (each is a vertical piece the next can rely on):
(1) `input_format.html` and `_input.Rmd` / `_database_access.Rmd` (required columns, ID rule, genotype columns, min ages,
orphan); (2) the breeding-group pages (`_breeding_group_*.Rmd`, `group_formation.html`, `gvAndBgDesc.html`);
(3) the genetic-value pages (`_genetic_value_analysis.Rmd`, `_genome_uniqueness_algorithm.Rmd`, `genetic_value.html`);
(4) pedigree browser, summary statistics, ORIP, introduction and README re-render. The code and UI defects under
observation 3 are separate owner decisions and should not be folded into the doc fixes.
