# Docs staleness audit, slice 6b: `man/` pedigree QC and curation pages (2026-10-01, S836)

Read-only audit. Nothing in the repo was changed except this report and the session records.

## Audit summary

- **Scope:** 36 of the 268 `man/` pages, the "pedigree QC and curation" topic group (listed under Items audited).
  `man/` is generated from roxygen in `R/`, so a fix goes in the `R/*.R` roxygen block, then `devtools::document()`.
  Slice 6a took 36 genetic-value and kinship pages (S834, fixed S835). 196 pages remain for later slices; `NEWS.Rmd`
  is slice 7.
- **Criterion:** does each checkable claim (argument list and defaults, return type and fields, described behavior,
  example runnability, `@seealso` targets, numbers) match today's code? Read from the implementation and by running
  the calls, not from the roxygen alone.
- **Method:** four read-only subagents, nine pages each (sets A-D, ids PA/PB/PC/PD). This session re-ran or re-read the
  source for **all 20 moderate findings** (marked **S**: PA1-PA6, PB1, PB3, PB4, PB5, PB7, PB11, PC1, PC2, PD1, PD2,
  PD4, PD6, PD8, PD11); all held. Minor findings are the agent's own check: **R** = it re-read the code, **A** = it ran
  the call.
- **Coverage:** 36 of 36 pages. Every `@examples` block that exists runs without error; four emit a `minParentAge`
  deprecation warning (PD3). Every `@seealso` and `\link` target checked exists.
- **Findings:** 0 critical, **20 moderate, 37 minor** (57). Pages with no false claim: removeUnknownAnimals,
  convertRelationships (it omits the list of `relation` categories, an omission rather than a falsehood).

## Findings: Moderate

| ID | Location | Claim | Evidence | Fix | Check |
|---|---|---|---|---|---|
| PA1 | `R/qcStudbook.R:99-101` | A record is removed if `id` is UNKNOWN "or both the fields `sire` or `dam` have `NA` or UNKNOWN" | Only `id` = UNKNOWN drops a row; a row with both parents NA/UNKNOWN stays as a founder (A, B, C, D example keeps all four; `qcPed` has hundreds of NA/NA founders) | "If `id` is UNKNOWN the record is removed; UNKNOWN in `sire`/`dam` becomes NA and a row with both parents unknown is kept as a founder" | S, A |
| PA2 | `R/qcStudbook.R:176-177` | "Columns that cannot be used subsequently are removed" | `sb[, c(cols, novelCols)]` (`:355-357`) keeps unrecognized columns after the standard ones; an `extra` column survives, ahead of `placeholder` | "Unrecognised columns are retained after the standard columns; rows are ordered by generation, then ID" | S, A |
| PA3 | `R/qcStudbook.R:189-190` | `@return` "A data.frame ..." | With `reportErrors = TRUE` it returns an `nprcgenekeeprErr` list, or NULL when there are no errors and no column changes (`qcStudbook(pedGood, reportErrors = TRUE)` gives NULL) | Add the `reportErrors = TRUE` return | S, A |
| PA4 | `R/processQcStudbookResult.R:252-258` | `errorLst`: "list object returned by `qcStudbook` with `reportErrors = TRUE`, or NULL" | NULL gives `hasErrors = TRUE` ("No result returned from quality control check"), yet a clean `qcStudbook(reportErrors = TRUE)` returns NULL, so the documented chain reports a false failure | Document the NULL behavior; point to `runQcStudbook()` or say to substitute `getEmptyErrorLst()` | S, A |
| PA5 | `R/runQcStudbook.R:10-11` | `ped` has "id, sire, dam, sex, and optionally birth ..." | `birth` is required: `runQcStudbook(ped[, 1:4])` returns `cleaned` NULL and "Missing required columns / birth" | "required id, sire, dam, sex and birth" | S, A |
| PA6 | `R/runQcStudbook.R:23-25, 27-32` | `reportChanges`: "warnings about renamed columns are included in the qcResult" | `warnings` is filled only for case and space changes (`R/processQcStudbookResult.R:442-455`); `ego_id`, `sire.id`, `dam_id`, `birth_date` gave 0 warning rows with `hasChangedCols` TRUE | "`changedCols`/`hasChangedCols` report all renames; `warnings` lists only case and space changes" | S, A |
| PB1 | `R/checkParentAge.R:23-25` | `reportErrors` "will scan the entire file and make a list of all errors ... a list of list" | Boilerplate. It only changes what happens on uncheckable input: returns NULL instead of `sb` or `stop()` (`:78-97`); integer `birth` with TRUE gives NULL, valid input returns the data frame either way | "If TRUE, return NULL instead of stopping when the input cannot be checked (zero rows, missing id/sire/dam, wrong `birth` class)" | S, A |
| PB3 | `R/checkRequiredCols.R:12-17` | With TRUE "the `errorLst` object is updated with the names of the missing columns and returned" | No `errorLst` argument; TRUE returns the character vector of missing names (`"birth"`), FALSE stops "Required field(s) missing: birth."; NULL when none missing; `reportErrors` has no default | Describe the vector return and the error | S, A |
| PB4 | `R/checkRequiredCols.R:6-10` | With TRUE, `NA` in `cols` is an ordinary non-match "rather than causing an error" | With a required column also missing, `NA` errors "missing value where TRUE/FALSE needed"; line 36 omits `ignore_na = TRUE` (only the `stop()` branch passes it) | Pass `ignore_na = TRUE` (code change) or drop the claim | S, A |
| PB5 | `R/checkRequiredCols.R:23-32` (`@examples`) | Example appears to show "all required present" | `cols` is one comma-joined string, so `length(cols) < 5` and all five names come back as missing; the printed TRUE is an artifact | `strsplit(cols, ",")[[1]]`, expect NULL, add a missing-column case | S, A |
| PB7 | `R/checkChangedColsLst.R:8-9, 36-48` | Returns TRUE "if any changed-columns field is non-empty" | Checks 12 fields; `getEmptyErrorLst()` has 13. `geographicoriginToGeographicOrigin` is ignored, so a list with only that field gives FALSE (code gap; `insertErrorTab` uses the result) | Add the field to the check (code change) or word as "any of the 12 listed fields" | S, A |
| PB11 | `R/getDateErrorsAndConvertDatesInPed.R:6-11, 16-17` | "otherwise the pedigree is not updated" | Mixed: with some invalid rows the whole pedigree converts, invalid dates become NA, `exit` is added, rows go to `errorLst$invalidDateRows`; unconverted only when all rows are invalid. It errors when the first non-NA value of a date column is invalid, or with two date columns and any invalid row (`as.Date()` applied to a data frame, `:42-43`) | Document the partial update; optionally fix `:42-43` per column | S, A |
| PC1 | `R/convertDate.R:22-24` | Bad values "are set to NA" | Never NA: `reportErrors = FALSE` stops "Column 'birth' has invalid dates on row(s) 1 and 2." (`:156-161`) | "An invalid date stops with an error naming the column and rows, unless `reportErrors = TRUE`" | S, A |
| PC2 | `R/convertDate.R:19-21` | `reportErrors` returns "a list of list where each sublist is a type of error" | Returns a sorted character vector of row numbers (repeated per bad column), or NULL (`:168-172`); `convertDate(p, reportErrors = TRUE)` gives `"1" "2"` | Say so, and that it replaces the converted pedigree | S, A |
| PD1 | `R/getPotentialSires.R:9-11`, inherited by `R/removePotentialSires.R:7` | `minAge`: "Default is 1 year." | `removePotentialSires(ids, minAge, ped)` has no default: calling without it errors "argument "minAge" is missing, with no default" | Local `@param minAge` saying it is required, or give it `minAge = 1L` | S, A |
| PD2 | `R/addAnimalsWithNoRelative.R:47` (`@examples`) | `length(kin) # should be 259` | Prints 591 (the 34-id `[["0DAV0I"]]` claim holds) | 591, or drop the hard-coded numbers | S, A |
| PD4 | `R/addUIds.R:20` | `@return` "The updated pedigree with partial parentage removed" | Fills the missing parent with a placeholder: id a (sire NA, dam z) gives sire `U0001`, dam z; the description at `:4-7` contradicts the return text | "each missing sire or dam of a single-parent record replaced by a generated placeholder ID" | S, A |
| PD6 | `R/addParents.R:14-16` | "all remaining columns are filled with NA" | Adds a `recordStatus` column ("original" for existing rows, "added" for new), overwrites any prior one, documented nowhere | Document `recordStatus`; other added-row columns are NA | S, A |
| PD8 | `R/addBackSecondParents.R:4, 13` | `ped`: "a trimmed pedigree"; title "Add back single parents trimmed pedigree" | The description (`:6-7`) says `ped` has the full complement of parents and the code takes second parents from it; the title is garbled | `ped` = the full (untrimmed) pedigree; title "Add back second parents to a trimmed pedigree" | S |
| PD11 | `R/getIdsWithOneParent.R:7` | `@return` "Character vector of all single parents" | Returns the ids of animals with exactly one known parent (`is.na(sire)` xor `is.na(dam)`), not the parents: id o1 (sire NA, dam d1) gives "o1" | "IDs of animals with exactly one known parent" | S, A |

## Findings: Minor

| ID | Location | Claim and evidence | Check |
|---|---|---|---|
| PA7 | `R/qcStudbook.R:30` | `status` "levels ALIVE, DEAD, SHIPPED"; `convertStatusCodes()` gives ALIVE, DECEASED, SHIPPED, UNKNOWN (same stale text in `R/getPossibleCols.R`, outside this slice) | R |
| PA8 | `R/qcStudbook.R:112-113, 119-120` | `ignore.herm` should be `ignoreHerm`; `qcStudbook` always calls `convertSexCodes()` with the default `ignoreHerm = TRUE`, so H becomes U, yet the output factor still has levels F, M, H, U | R, A |
| PA9 | `R/qcStudbook.R:127-129` | `correctParentSex` also silently recodes female sires to M and male dams to F with `reportErrors = FALSE` (reported as `femaleSires`/`maleDams` with TRUE); page mentions neither | R |
| PA10 | `R/qcStudbook.R:67-74, 86-88` | The `stop()` for missing columns holds only for `reportErrors = FALSE` (TRUE returns `$missingColumns`); the error-type list omits `duplicateIds`, `invalidIdChars`, `invalidPlaceholderRows`, `sireAndDam` | R, A |
| PA11 | `R/qcStudbook.R:76-84` | "Column cols" garbled; rename list omits underscore and space removal and `birthdate`, `deathdate`, `recordstatus`, `fromcenter`, `geographicorigin` | R, A |
| PA12 | `R/qcStudbook.R:83, 143, 164, 172, 179` | Typos: "is convert", "coverts", "values is", "I also throws", "coerce" | R |
| PA13 | `R/data.R:271, 317` | `set_seed(10)` should be `set.seed(10)` (qcPedGvReport and pedWithGenotypeReport) | R |
| PA14 | `R/data.R:301, 307-308` | `qcPed$gen` is "integers" but is numeric; "age in year" | A |
| PA15 | `R/data.R:63-73, 284-290`, `R/filterReport.R:18-20`, `R/getEmptyErrorLst.R:7-8` | finalRpt: elements and columns undescribed, `imports`/`noParentage` tiers unmentioned; qcBreeders: `\describe` with no `\item`; filterReport: only `id` is used, not "id, gu, zScores, import, totalOffspring"; getEmptyErrorLst: the 11 fields and class `nprcgenekeeprErr` not listed | R, A |
| PB2 | `R/checkParentAge.R:26-28` | `@return` cites deprecated `minParentAge`; cutoffs are `minSireAge`/`minDamAge` or the species floor (`:139-146`) | R |
| PB2b | `R/checkParentAge.R:8-9` | `sb` needs `id`, `sire`, `dam`, `birth`, `exit` (`species` optional); without `exit` the failure is the uninformative "replacement has 0 rows"; `exit` is returned as character and rows reordered | R, A |
| PB6 | `R/checkRequiredCols.R:35` | Comment lists four required columns (there are five, `birth` too); matching is by substring (`"identity"` matches `id`) | R, A |
| PB8 | `R/checkChangedColsLst.R:6-7` | "each type of column change `qcStudbook`": "made by" missing | R |
| PB9 | `R/getChangedColsTab.R:8` | "HTML formatted error list" is copied from `getErrorTab`; it returns a Shiny `tabPanel` titled "Changed Columns" | R, A |
| PB10 | `R/getErrorTab.R:8` | Returns a `tabPanel` titled "Error List"; type not stated | R, A |
| PB12 | `R/getDateErrorsAndConvertDatesInPed.R:16-17` | `invalidDateRows` is a character vector (`character(0)` when valid); `sb` gains `exit` when converted | R, A |
| PB13 | `R/fixColumnNames.R:4-11` | "standardize" undefined: lower-casing, stripping spaces/periods/underscores, `egoid` to `id`, `sireid`, `damid`, `birthdate`, ... ; `errorLst` should come from `getEmptyErrorLst()`; mapping is unanchored substring (`"category"` becomes `"catidry"`, a code issue) | R, A |
| PB14 | `R/checkTwinRelations.R:10-11, 36-37` | Cites `docs/planning/...`, which is `.Rbuildignore`d, so installed users cannot reach it | R |
| PB15 | `R/checkErrorLst.R:8-9, 30` | Does not say `changedCols` is ignored (see `checkChangedColsLst`); `checkErrorLst(list())` errors (outside the contract) | R, A |
| PC3 | `R/convertDate.R:11-17` | Error row numbers count only records not marked "added" (`:104-105`), not input positions | A |
| PC4 | `R/convertDate.R:22-24, 111-135` | Page says `%Y%m%d`; code accepts `YYYY-MM-DD` and `YYYYMMDD`; years before 1000 are invalid; other column classes stop | R, A |
| PC5 | `R/convertSexCodes.R:24-29` | `sex` "factor with levels M, F, U" and returns "a vector of factors": accepts any character or factor codes, returns one factor with levels F, M, H, U | R, A |
| PC6 | `R/convertStatusCodes.R:8-21` | Unrecognized values become NA (not "UNKNOWN"), no `trimws()`; accepted codes unlisted; the example's "H"/"hermaphrodite" are leftovers giving NA | R, A |
| PC7 | `R/correctParentSex.R:24-25` | `sex` "factor with levels M, F, U" but H is handled; a character input returns character | R, A |
| PC8 | `R/correctParentSex.R:8-40` | With `reportErrors = FALSE`, an id that is both sire and dam stops with an error (TRUE returns `$sireAndDam`); undocumented | A |
| PC9 | `R/correctParentSex.R:72` | Example passes `pedOne$recordStatus` for `pedTwo` (copy-paste slip, harmless) | R |
| PC10 | `R/removeEarlyDates.R:15-16` | "dates after the year": dates in `firstYear` are kept (`year < firstYear`) | A |
| PC11 | `R/removeDuplicates.R:21-22` | "a Pedigree object" is a plain data.frame | A |
| PC12 | `R/removeDuplicates.R:10` | The duplicate-id error applies only with `reportErrors = FALSE`; rows compared on all columns including `recordStatus` | R |
| PC13 | `R/removeAutoGenIds.R:19` | Also sets placeholder sire/dam entries to NA; the "four or more capital letters or digits" match is a prefix (`U1234abc` is removed) | A |
| PD3 | `R/removeUninformativeFounders.R:16`, `R/addBackSecondParents.R:19`, `R/getIdsWithOneParent.R:12`, `R/addAnimalsWithNoRelative.R:28` | `qcStudbook(..., minParentAge = 2, ...)` in four examples emits the 2.0.0 deprecation warning; use `minSireAge = 2, minDamAge = 2` | A |
| PD5 | `R/addParents.R:10` | "after to `addUIds`" | R |
| PD7 | `R/addParents.R:13` | `ped` needs `id`, `sire`, `dam`, `sex` (without `sex`: "numbers of columns of arguments do not match") | A |
| PD9 | `R/addBackSecondParents.R:14`, `R/addIdRecords.R:11` | Return is a data.table once any record is added (`rbindlist`), a plain data.frame when none | A |
| PD10 | `R/addIdRecords.R:8-9` | `fullPed` is described as "a trimmed pedigree" but is the full source of the added records; both pedigrees need identical columns (`rbindlist` error otherwise) | A, R |
| PD12 | `R/hasBothParents.R:6, 8, 19` | Scalar only: a vector `id` warns about recycling; an id absent from `ped` gives `logical(0)`, not FALSE (an `if()` in `addBackSecondParents` would error) | A |
| PD13 | `R/removeUninformativeFounders.R:10` | `id` is also required; removal repeats until none remain (undocumented; matters because removal can create new once-seen founders) | R, A |

## Structural observations

- **`reportErrors` documentation is the main source of falsehood** (PA3, PA4, PA10, PB1, PB3, PC2, PB11, PC8, PC12): nine
  findings, five moderate, describe what a `reportErrors = TRUE` call returns. Two pages (`checkParentAge`,
  `convertDate`) carry the same boilerplate sentence, "a list of list where each sublist is a type of error", which
  fits neither. Fix the shared sentence everywhere in one pass.
- **Required-column lists drift** (PA5, PB2b, PB6, PD7, PD13): `birth` is required but listed as optional on
  `runQcStudbook`; `id` and `sex` are missing from several `ped` params.
- **Return-type claims drift again** (PA3, PB9, PB10, PC5, PC11, PD4, PD6, PD9, PD11): the same pattern as slice 6a.
- **`@examples` that run but mislead or are stale** (PB5, PD2, PD3, PC6, PC9): one prints a number that is wrong in the
  comment beside it (591 versus 259), one demonstrates the opposite of what it shows, four emit deprecation warnings.
- **Code-change candidates, not doc fixes (owner decision, strict TDD):** PB4 (`ignore_na = TRUE` at
  `checkRequiredCols.R:36`), PB7 (add `geographicoriginToGeographicOrigin` to `checkChangedColsLst`), PB11
  (`as.Date()` on a data frame at `getDateErrorsAndConvertDatesInPed.R:42-43`), PB13 (unanchored substring renames in
  `fixColumnNames`), PA4 (a clean `qcStudbook(reportErrors = TRUE)` returns NULL, which `processQcStudbookResult`
  reports as a failure), PD12 (`hasBothParents` vector and absent-id behavior), PD1 (give `removePotentialSires` the
  `minAge = 1L` default its inherited text promises).
- **Reference pages:** `removeUnknownAnimals` matches its code in every checked claim; `checkTwinRelations` has every
  documented rule confirmed by running it (one minor, PB14).

## Items audited

| Page | Findings |
|---|---|
| qcStudbook | PA1-PA3, PA7-PA12 |
| qcPed, qcBreeders, qcPedGvReport, finalRpt | PA13-PA15 |
| runQcStudbook | PA5, PA6 |
| processQcStudbookResult | PA4 |
| filterReport, getEmptyErrorLst | PA15 |
| checkParentAge | PB1, PB2, PB2b |
| checkRequiredCols | PB3-PB6 |
| checkTwinRelations | PB14 |
| checkErrorLst | PB15 |
| checkChangedColsLst | PB7, PB8 |
| getErrorTab, getChangedColsTab | PB10, PB9 |
| getDateErrorsAndConvertDatesInPed | PB11, PB12 |
| fixColumnNames | PB13 |
| convertDate | PC1-PC4 |
| convertSexCodes | PC5 |
| convertStatusCodes | PC6 |
| convertRelationships, removeUnknownAnimals | none |
| correctParentSex | PC7-PC9 |
| removeEarlyDates | PC10 |
| removeDuplicates | PC11, PC12 |
| removeAutoGenIds | PC13 |
| removeUninformativeFounders | PD3, PD13 |
| removePotentialSires | PD1 |
| addUIds | PD4 |
| addParents | PD5-PD7 |
| addBackSecondParents | PD3, PD8, PD9 |
| addIdRecords | PD9, PD10 |
| addAnimalsWithNoRelative | PD2, PD3 |
| getIdsWithOneParent | PD3, PD11 |
| hasBothParents | PD12 |

## Comparison with prior audits

| Metric | Slice 5 (vignette) | Slice 6a (36 man pages) | Slice 6b (36 man pages) |
|---|---|---|---|
| Moderate / minor | 12 / 18 | 9 / 45 | 20 / 37 |
| Findings per unit | 30 in 1 file | 54 in 36 pages (1.5 per page) | 57 in 36 pages (1.6 per page) |
| Clean units | n/a | 8 of 36 | 2 of 36 |

The moderate count more than doubled against 6a: these pages describe error-reporting contracts, which drift more than
the numeric helpers in 6a.

## Recommendations

1. Fix the 57 findings in the `R/*.R` roxygen, then `devtools::document()`, as the next session (the S823, S833 and
   S835 pattern). Do the shared sentences (the `reportErrors` boilerplate, PA7 with `getPossibleCols`, PD3 across four
   examples) across every page at once.
2. Decide the code-change candidates (PB4, PB7, PB11, PB13, PA4, PD12, PD1) before touching their docs; the others in
   this list are doc-only.
3. Slice 6c: the next topic group of `man/` (196 pages remain).
