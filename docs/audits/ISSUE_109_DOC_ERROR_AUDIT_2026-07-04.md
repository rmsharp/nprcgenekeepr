# Issue #109 — Documentation-Error Audit (roxygen2 / man pages)

**Issue:** #109 ("roxygen2 errors in functions within R"), second clause — *"Audit the code for similar documentation errors."*
**Date:** 2026-07-04 (Session 273)
**Scope:** all 203 `man/*.Rd` man pages and their `R/*.R` roxygen sources.
**Status:** Assessment complete. This report is the deliverable; **the fixes are a separate, owner-gated follow-on** (each is a pure-doc REFACTOR-class edit that re-stales the `--as-cran` gate). No `R/` was modified in this session.

---

## 1. Audit Summary

- **Criteria.** A documentation *error* is a man page that would **factually mislead a reader about what the code does, or render broken/misleading output** — as opposed to a style/consistency preference (those belong to the #103 harmonization track and are largely bespoke-by-design). Six error classes: `factual-mismatch` (description/details/title contradicts the code), `wrong-return`, `wrong-param`, `broken-example`, `misleading-render`, `broken-xref`.
- **Method.** (a) A deterministic pre-pass over all 203 man pages (§2) establishing the status of the eight S244 rendered-doc defects D1–D8 and the mechanically-checkable classes; (b) a **17-batch parallel semantic audit** (one agent per ~12 man pages) reading each man page *against its source code and, where behaviour was in question, the function body*; (c) an **independent adversarial verification** of every candidate finding (read the actual `.Rd` + source, default-to-refute); (d) **firsthand re-verification by the session author** of all three Critical findings and a cross-class sample of Moderate/Minor findings (and the one refuted candidate). 56 agents, 0 errors; 39 candidates → **38 confirmed, 1 refuted**.
- **Coverage.** 203 / 203 man pages examined (100%).
- **Finding count.** **38 confirmed documentation errors** — 3 Critical, 22 Moderate, 13 Minor. By class: 15 factual-mismatch, 12 wrong-return, 10 wrong-param, 1 misleading-render. **0 broken-example, 0 broken-xref** (both classes cleared: see §2).

**Headline.** This is a **well-documented package with a specific, systematic weakness: prose that describes a *sibling* function or an *earlier version* of the code.** Every confirmed finding passes `R CMD check --as-cran`, `tools::checkRd()`, and `devtools::document()` cleanly — they are all *valid Rd that is factually wrong*, exactly the failure mode issue #109 was opened for (its own reported bug, `\code{}` rendering literally, was valid Rd too). None is a rendering-engine error: **`document()` runs with zero warnings and zero man/ drift**, so the *literal* reading of the issue title ("roxygen2 errors") is already clean — the reported bug was a rendering error, fixed in S272. The remaining surface is semantic accuracy, and it is where all 38 findings live. The dominant root cause is **copy-paste drift between sibling functions** (see §4).

---

## 2. Deterministic pre-pass — mechanically-checkable classes are clean

Before the semantic audit, every class a tool or exact match can decide was checked over all 203 man pages. **All are clean or already-fixed**, so the semantic audit could focus on prose-vs-code accuracy.

**The eight S244-audit rendered-doc defects (D1–D8) are all fixed** by the #103 implementation work (S244→S272), verified firsthand against the current tree:

| # | S244 defect | Status |
|---|---|---|
| D1 | `calcGU` malformed explicit `@description` | **fixed** — real description renders |
| D2 | duplicate `_PACKAGE` sentinel | **fixed** — one sentinel (`nprcgenekeepr-package.R`) |
| D3 | escaped-brace pseudo-Rd lists render literally (7 files) | **fixed** — remaining `\{…\}` in `calcA`/`examplePedigree` is intentional literal-brace set/level notation that renders correctly |
| D4 | `@param` documents a nonexistent arg (`candidates`) | **fixed** — `R CMD check` `code/documentation mismatches … OK` (S272) |
| D5 | `@return` copy-pasted from the wrong function (`findPedigreeNumber`, `getOffspring`) | **fixed** — current text firsthand-confirmed *correct* |
| D6 | title typos (obfucate, portential, …) | **fixed** — 0 grep hits |
| D7 | dead `@importFrom`/`@import` on a commented-out fn | **fixed** — import removed (the `@noRd` block still sits on the commented-out `makeGeneticDiversityDashboard` body; non-rendering; tied to open issue #112) |
| D8 | bare non-`#'` blank lines breaking blocks (4 files) | **fixed** at all four cited sites; 4 *other* files have a cosmetic bare blank at line 6, but roxygen tolerates them (zero `document()` warnings, correct render) |

Other mechanical detectors over all 203 man pages:

- **#109's own class** — literal Rd markup inside `\preformatted{}` (a brace-matched detector): **0 hits** (S272's fix holds).
- **Cross-references** (`broken-xref`): 206 `\alias` topics; **every in-package `\link{}` target resolves (0 unresolved)**; the three external targets (`stats::fivenum`, `ggplot2::ggsave`, `Rlabkey::labkey.setDefaults`) all exist.
- **Doubled `.Rd` sources** (Learning 248): **0**. **Empty `\code{}`/`\link{}`:** **0**.
- **Data-doc columns vs. actual data:** for every dataset doc that lists columns, documented == actual `names()`.
- **`@returns` vs `@return`:** only `set_seed.R` uses the `@returns` alias (renders identically — a consistency nit, out of #109 scope).
- **Un-run examples** (`\dontrun`, not executed by `R CMD check`): 8 files (all LabKey/app-launcher, correctly guarded per `ROXYGEN_EXAMPLES_POLICY.md`); the semantic audit read each and found **no broken-example** — the `\dontrun` code matches the current API.

---

## 3. Confirmed Findings (38)

Each finding was firsthand-verified against the current `.Rd` and source; the three Critical findings and a cross-class sample of the rest were additionally re-verified by the session author. Severity: **high** = exported function whose documented contract, if followed, breaks the caller's code; **moderate** = exported, misleads about return shape / parameter meaning; **minor** = internal (`@noRd`) or cosmetic-but-wrong (name-based access still works).

### Critical (3)

#### 1. `getFocalAnimalPedFromFile` — factual-mismatch · **high**

- **Location:** `man/getFocalAnimalPedFromFile.Rd` (line 42); source `R/getFocalAnimalPedFromFile.R`
- **Doc says:** The underlying file source errors loudly on a bad pedigree file, but this function is the application boundary, so it is fail-soft: it returns \code{NULL} when the pedigree file is missing, does not exist, or lacks the \code{id}, \code{sire}, and \code{dam} columns. (This mirrors how the app's other file inputs behave -- a \code{NULL} surfaces a "File Read Error" ...)
- **Code does:** All three failure paths return nprcgenekeeprFileErr(...) -- a list with class nprcgenekeeprFileErr: an unreadable focal-id file (line 64), an unreadable/missing/wrong-column pedigree file via pedigreeReadReason() (line 79), and the no-focal-IDs-found case (line 87). NULL is never returned. The @return section correctly documents the nprcgenekeeprFileErr object, directly contradicting this @details paragraph.
- **Fix:** Rewrite the @details paragraph to describe the nprcgenekeeprFileErr return (consistent with @return): on failure it returns a classed nprcgenekeeprFileErr object whose message names the reason, not NULL. A reader who follows @details and tests is.null(result) would get FALSE and mishandle the error.

#### 2. `saveDataframesAsFiles` — factual-mismatch · **high**

- **Location:** `man/saveDataframesAsFiles.Rd` (line 16); source `R/saveDataframesAsFiles.R`
- **Doc says:** \item{fileType}{character vector of length one with possible values of \code{"txt"}, \code{"csv"}, or \code{"xlsx"}. Default value is \code{"csv"}.}
- **Code does:** The body guards with stopifnot(any(fileType %in% c("txt", "csv", "excel"))) and dispatches Excel output via `else if (fileType == "excel")`. There is no "xlsx" branch and no normalization, so calling saveDataframesAsFiles(dfList, dir, fileType = "xlsx") — the documented value — fails the stopifnot and aborts. Excel output requires fileType = "excel".
- **Fix:** Change the documented value "xlsx" to "excel" in both the fileType and dfList @param lines (or make the code accept "xlsx").

#### 3. `checkChangedColsLst` — wrong-return · **high**

- **Location:** `man/checkChangedColsLst.Rd` (line 14); source `R/checkChangedColsLst.R`
- **Doc says:** Returns \code{NULL} if all fields are empty else the entire list is returned.
- **Code does:** The body returns the literal TRUE when any changedCols field has length > 0L, otherwise FALSE (R/checkChangedColsLst.R lines 37-52). It never returns NULL and never returns the list. A caller testing is.null() of the result would find the empty case never detected (is.null() is always FALSE), and a caller expecting the list back would instead get TRUE.
- **Fix:** Rewrite @return to: 'Returns TRUE if any changed-columns field is non-empty, otherwise FALSE.'

### Moderate (22)

#### 4. `checkKinshipOverrides` — factual-mismatch · **moderate**

- **Location:** `man/checkKinshipOverrides.Rd` (line 31); source `R/checkKinshipOverrides.R`
- **Doc says:** Supplying \emph{r} -- e.g. 0.5 for half-sibs whose true \emph{f} is 0.125 -- silently corrupts the matrix, so an off-diagonal value above 0.5 (the maximum for a non-inbred pair) draws a warning here.
- **Code does:** By the r = 2f relation stated one clause earlier, a half-sib pair with f = 0.125 has r = 0.25, not 0.5 (0.5 is the relatedness of a full-sib/parent-offspring pair, whose f is 0.25). The warning in code triggers only on kinship > 0.5 (R/checkKinshipOverrides.R line 69), a threshold r = 0.25 would not reach, so the stated half-sib example does not even illustrate the described warning. A reader would conclude half-sib r = 0.5, double the correct value.
- **Fix:** Use an internally consistent example, e.g. '0.25 for half-sibs whose true f is 0.125,' or switch the pair type to match 0.5: 'e.g. 0.5 for full-sibs whose true f is 0.25.'

#### 5. `getPedMaxAge` — factual-mismatch · **moderate**

- **Location:** `man/getPedMaxAge.Rd` (line 5); source `R/getPedMaxAge.R`
- **Doc says:** Get the maximum age of live animals in the pedigree
- **Code does:** getPedMaxAge is just max(ped$age, na.rm = TRUE) (R/getPedMaxAge.R:21). The `age` column is populated by calcAge(birth, exit), which sets exit[is.na(exit)] <- Sys.Date() and computes an age for deceased animals too (age at exit) (R/calcAge.R:24-30; qcStudbook fills it via sb["age"] <- calcAge(sb$birth, sb$exit)). The maximum therefore spans living AND deceased animals.
- **Fix:** Remove 'live' from the title/description (it returns the maximum age of all animals with a non-NA age, deceased included), or restrict the computation to living animals if 'live' is the intended semantics.

#### 6. `kinshipMatricesToKValues` — factual-mismatch · **moderate**

- **Location:** `man/kinshipMatricesToKValues.Rd` (line 28); source `R/kinshipMatricesToKValues.R`
- **Doc says:** the diagonal values are by definition all 1.0 and the upper triangle has the same values as the lower triangle
- **Code does:** kinshipMatricesToKValues() delegates to kinshipMatrixToKValues() for each matrix (R/kinshipMatricesToKValues.R:99,105), and those matrices come from kinship(), whose diagonal is diag(n+1)/2 = 0.5 (self-kinship), not 1.0. The diagonal is retained in the output, so the documented '1.0' contradicts the actual self-pair kinship values.
- **Fix:** Correct '1.0' to 0.5 (or describe the diagonal as self-kinship = (1 + F)/2), consistent with the sibling fix in kinshipMatrixToKValues.

#### 7. `kinshipMatrixToKValues` — factual-mismatch · **moderate**

- **Location:** `man/kinshipMatrixToKValues.Rd` (line 28); source `R/kinshipMatrixToKValues.R`
- **Doc says:** the diagonal values are by definition all 1.0 and the upper triangle has the same values as the lower triangle
- **Code does:** The kinship matrices this function consumes are produced by kinship() (R/kinship.R:78, 102), which sets the diagonal to diag(n+1)/2 = 0.5 for founders and kmat[i,i] = (1 + kmat[mom,dad])/2 (= 0.5 when the parents are unrelated). Self-kinship is 0.5, not 1.0. kinshipMatrixToKValues masks with lower.tri(..., diag = FALSE) so the diagonal is retained (the 210 = 20 + 20*19/2 row count includes the 20 diagonal entries), meaning the self-pair kinship values in the output are ~0.5, not 1.0.
- **Fix:** Correct '1.0' to 0.5 (or describe the diagonal as self-kinship = (1 + F)/2), consistent with the kinship coefficients kinship() produces.

#### 8. `makeCEPH` — factual-mismatch · **moderate**

- **Location:** `man/makeCEPH.Rd` (line 33); source `R/makeCEPH.R`
- **Doc says:** Calculates the first-order relationships in a pedigree, and to convert pairwise kinships to the appropriate relationship category. Relationships categories: For each ID in the pair, find a CEPH-style pedigree and compare them ... Designate the relationship as \code{parent-offspring} ...
- **Code does:** makeCEPH() (R/makeCEPH.R:59-87) only assembles ceph[[i]] <- list(parents, pgp, mgp) per id and returns it; it computes no kinship and assigns no relationship category. The relationship cascade (Parent-Offspring, Full-Siblings, Grandparent-Grandchild, Full-Avuncular, ...) actually lives in convertRelationships() (R/convertRelationships.R:50-90), which calls makeCEPH() as a helper. This is copy-paste drift between the two sibling functions; makeCEPH's own @return correctly says it returns the CEPH list.
- **Fix:** Remove the 'Calculates the first-order relationships...' paragraph and the relationship-category itemize list from makeCEPH's @details; that documentation belongs to convertRelationships().

#### 9. `runModularApp` — factual-mismatch · **moderate**

- **Location:** `man/runModularApp.Rd` (line 36); source `R/runModularApp.R`
- **Doc says:** Use \code{\link{runGeneKeepR}} to run the original monolithic version.
- **Code does:** runGeneKeepR() (R/runGenekeepr.R) is a lifecycle::deprecate_soft alias whose body is `runModularApp(port = port, launch.browser = launch.browser)`, and its own doc states 'The original monolithic Shiny application has been retired.' There is no monolithic version to run; runGeneKeepR launches the identical modular app.
- **Fix:** Replace with a note that runGeneKeepR() is a soft-deprecated alias for runModularApp(), or drop the sentence.

#### 10. `assignAlleles` — wrong-param · **moderate**

- **Location:** `man/assignAlleles.Rd` (line 22); source `R/assignAlleles.R`
- **Doc says:** integer indicating the number of iterations to simulate.
Default is 5000.
- **Code does:** The signature is `assignAlleles <- function(alleles, parentType, parent, id, n)` with NO default for n, and the Rd \usage line `assignAlleles(alleles, parentType, parent, id, n)` confirms no default. Calling without n (relying on the documented default) raises `argument "n" is missing, with no default`. The "Default is 5000" is copy-paste drift from a sibling simulation function that does take n = 5000.
- **Fix:** Remove "Default is 5000." (n is a required argument), or, if a default is intended, add `n = 5000` to the function signature so doc and code agree.

#### 11. `getPotentialSires` — wrong-param · **moderate**

- **Location:** `man/getPotentialSires.Rd` (line 15); source `R/getPotentialSires.R`
- **Doc says:** integer value indicating the minimum age to consider in group formation. Pairwise kinships involving an animal of this age or younger will be ignored. Default is 1 year.
- **Code does:** The body is ped$id[ped$id %in% ids & ped$sex == "M" & getCurrentAge(ped$birth) >= minAge & !is.na(ped$birth)] (R/getPotentialSires.R:22-23). No group formation or kinship is computed, and animals whose age equals minAge are INCLUDED (>= minAge), contradicting 'this age or younger will be ignored'.
- **Fix:** Rewrite @param minAge to state it is the inclusive minimum current age (in years) a male must have to be listed as a potential sire; drop the 'group formation' and 'pairwise kinships ignored' language, which belongs to a kinship/threshold function.

#### 12. `get_elapsed_time_str` — wrong-param · **moderate**

- **Location:** `man/get_elapsed_time_str.Rd` (line 10); source `R/get_elapsed_time_str.R`
- **Doc says:** start_time a POSIXct time object
- **Code does:** The body computes `proc.time()[[3L]] - start_time[[3L]]`, i.e. it indexes the third (elapsed) element of a proc_time object; the @examples set `start_time <- proc.time()`. A real POSIXct object (e.g. Sys.time()) is length 1, so `start_time[[3L]]` raises "subscript out of bounds" (verified). The documented type is wrong; it should be a proc.time()/proc_time object.
- **Fix:** Change the @param to describe a value returned by `proc.time()` (a proc_time object), matching the example, instead of a POSIXct object.

#### 13. `is_valid_date_str` — wrong-param · **moderate**

- **Location:** `man/is_valid_date_str.Rd` (line 16); source `R/is_valid_date_str.R`
- **Doc says:** format character vector of length one having the date format
- **Code does:** The body of is_valid_date_str (R/is_valid_date_str.R:23-35) never references the format argument; both branches call anytime(date_str, useR = TRUE). Passing any format value -- including the @examples' format = "%m-%d-%y" -- has no effect on the result, so a reader copying the example is misled into thinking format controls parsing. Separately, @param optional says 'parameter to as.Date ... if the format guessing does not succeed', but as.Date is never called (validation is via anytime()), and the non-optional path returns FALSE (never signals an error) for an invalid date.
- **Fix:** Either implement format-based parsing or drop the unused format argument and its @param/@examples usage; and remove the 'parameter to as.Date' wording from @param optional since the function uses anytime().

#### 14. `makeExamplePedigreeFile` — wrong-param · **moderate**

- **Location:** `man/makeExamplePedigreeFile.Rd` (line 16); source `R/makeExamplePedigreeFile.R`
- **Doc says:** fileType character vector of length one with possible values of \code{"txt"}, \code{"csv"}, or \code{"xlsx"}. Default value is \code{"csv"}.
- **Code does:** R/makeExamplePedigreeFile.R:25 is stopifnot(any(fileType %in% c("txt", "csv", "excel"))) and the branch tests fileType == "excel" (line 30). "xlsx" is not an accepted value, so fileType = "xlsx" fails the stopifnot and never reaches create_wkbk(); the txt branch uses write.table.
- **Fix:** Change the documented Excel value from "xlsx" to "excel" (or make the code accept "xlsx") so the documented allowed values match the guard.

#### 15. `safeExecute` — wrong-param · **moderate**

- **Location:** `man/safeExecute.Rd` (line 22); source `R/safeExecute.R`
- **Doc says:** \item{silent}{logical. If TRUE, suppresses the error notification. Defaults to FALSE.}
- **Code does:** silent only gates the logModuleEvent(...) logging calls (`if (!silent) logModuleEvent(...)` in both the warning and error handlers). The actual notification — shiny::showNotification(...) — is gated by `notify` and is independent of silent, so silent = TRUE with notify = TRUE still shows the notification. silent suppresses logging, not the notification (the doc reserves 'notification' for the notify param, 'shows a notification to the user').
- **Fix:** Reword the silent @param to say it suppresses error/warning logging, not the notification.

#### 16. `summarizeKinshipValues` — wrong-param · **moderate**

- **Location:** `man/summarizeKinshipValues.Rd` (line 11); source `R/summarizeKinshipValues.R`
- **Doc says:** countedKValues list object from countKinshipValues function that containes the lists \code{kinshipIds}, \code{kinshipValues}, and \code{kinshipCounts}.
- **Code does:** summarizeKinshipValues() validates `if (!all(is.element(names(countedKValues), c("kIds", "kValues", "kCounts")))) stop(...)` and reads countedKValues$kIds, $kValues, $kCounts. countKinshipValues() (R/countKinshipValues.R:97-99, @return line 13-14) returns `list(kIds = kIds, kValues = kValues, kCounts = kCounts)`. No element named kinshipIds/kinshipValues/kinshipCounts exists.
- **Fix:** Change the documented element names in the @param to \code{kIds}, \code{kValues}, and \code{kCounts} to match the object returned by countKinshipValues() and the names this function checks for.

#### 17. `addAnimalsWithNoRelative` — wrong-return · **moderate**

- **Location:** `man/addAnimalsWithNoRelative.Rd` (line 16); source `R/addAnimalsWithNoRelative.R`
- **Doc says:** A dataframe with kinships in long form after adding a row for each animal without a relative.
- **Code does:** kin is produced by getAnimalsWithHighKinship() via `tapply(kin$id2, kin$id1, c)`, whose own @return correctly calls it "A list of named character vectors". Confirmed at runtime: is.data.frame(kin) is FALSE (class is `array`/`list`), not a data.frame. The body does `kin[[cand]] <- NA`, which adds a named LIST ELEMENT, not a row; and the data has already been collapsed OUT of long form by tapply. The example (`length(kin)`, `kin[["0DAV0I"]]`) is pure list-indexing, confirming list semantics. A reader expecting a data.frame (nrow(), id1/id2 columns) would be misled.
- **Fix:** Describe the return as a named list (one element per animal id, value = character vector of high-kinship relatives) with an added NA element for each relative-less candidate. Also fix the matching @param kin "dataframe with kinship values", which mislabels the same list object as a dataframe.

#### 18. `checkErrorLst` — wrong-return · **moderate**

- **Location:** `man/checkErrorLst.Rd` (line 14); source `R/checkErrorLst.R`
- **Doc says:** Returns FALSE if all fields are empty or the list is NULL else the entire list is returned.
- **Code does:** The body returns FALSE when errorLst is NULL or all fields are empty, and returns the literal TRUE otherwise (R/checkErrorLst.R lines 18-33) -- not the errorLst list. A user indexing the 'returned list' (e.g. el$maleDams) on a non-empty result would get TRUE and fail. The FALSE/NULL portion of the sentence is correct.
- **Fix:** Change 'else the entire list is returned' to 'otherwise TRUE' (the function returns a logical scalar).

#### 19. `correctParentSex` — wrong-return · **moderate**

- **Location:** `man/correctParentSex.Rd` (line 30); source `R/correctParentSex.R`
- **Doc says:** A factor with levels: "M", "F", "H", and "U" representing the sex codes for the ids provided
- **Code does:** When reportErrors = TRUE the function returns list(sireAndDam = ..., femaleSires = ..., maleDams = ...); only the reportErrors = FALSE branch returns sex. The @param reportErrors even states 'The errors will be returned in a list of list', so the @return contradicts the package's own documented behavior.
- **Fix:** Document both return shapes: a factor/vector of corrected sex codes when reportErrors = FALSE, and a named list of error vectors (sireAndDam, femaleSires, maleDams) when reportErrors = TRUE.

#### 20. `geneDrop` — wrong-return · **moderate**

- **Location:** `man/geneDrop.Rd` (line 43); source `R/geneDrop.R`
- **Doc says:** A data.frame \code{id, parent, V1 ... Vn} ... The first two columns provide the animal's ID and whether the allele came from the sire or dam. These are followed by \code{n} columns indicating the allele for that iteration.
- **Code does:** The function builds `alleles` as the transposed allele matrix (columns V1..Vn), then runs `alleles$id <- id` and `alleles$parent <- parent` (R/geneDrop.R lines 160-161), so id/parent are appended LAST. Verified empirically: geneDrop(...) returns colnames V1, V2, V3, id, parent -- i.e. the n allele columns come first and id/parent are the final two columns, the reverse of what the doc states.
- **Fix:** Fix the return description to say the first n columns are the per-iteration allele columns (V1...Vn) and the final two columns are `id` and `parent`; or reorder the columns in code to match the documented `id, parent, V1 ... Vn` order.

#### 21. `getPotentialParents` — wrong-return · **moderate**

- **Location:** `man/getPotentialParents.Rd` (line 47); source `R/getPotentialParents.R`
- **Doc says:** a list of list with each internal list being made up of an animal id (\code{id}), a vector of possible sires (\code{sire}) and a vector of possible dams (\code{dam}).
- **Code does:** Each element is built as list(id = pUnknown$id[i][1L], sires = potentialSires, dams = potentialDams$id) at R/getPotentialParents.R:155-159 -- the element names are `sires` and `dams` (plural), not `sire`/`dam`.
- **Fix:** Change the @return names from `sire` to `sires` and `dam` to `dams` to match the list constructed at R/getPotentialParents.R:155-159. The example (potentialParents[[1L]]) prints the actual `sires`/`dams` names, which the reader will see contradict the @return text.

#### 22. `getTokenList` — wrong-return · **moderate**

- **Location:** `man/getTokenList.Rd` (line 13); source `R/getTokenList.R`
- **Doc says:** First right and left space trimmed token from first character vector element.
- **Code does:** The function body ends with `list(param = param, tokenVec = tokenVec)` -- a named list of a parameter-name vector and a list of token vectors. The function's own @examples confirm this by accessing `tokenList$param` and `tokenList$tokenVec`. It never returns a single trimmed token.
- **Fix:** Rewrite @return to describe the returned list, e.g. "A list with two elements: `param`, a character vector of parameter names, and `tokenVec`, a list of the token vectors parsed for each parameter."

#### 23. `modPyramidServer` — wrong-return · **moderate**

- **Location:** `man/modPyramidServer.Rd` (line 15); source `R/modPyramid.R`
- **Doc says:** List with \code{data}, \code{plot}, and \code{livingCount}.
- **Code does:** The function's final return value is list(pedigree = reactive(pedigreeData()), animalCount = reactive(nrow(pedigreeData()))) (R/modPyramid.R lines 153-156). None of the documented names data, plot, or livingCount are present; a caller accessing result$data, result$plot, or result$livingCount receives NULL.
- **Fix:** Update the @return in R/modPyramid.R to describe the components actually returned: pedigree (reactive returning the pedigree data frame) and animalCount (reactive returning the animal row count), then re-run devtools::document().

#### 24. `offspringCounts` — wrong-return · **moderate**

- **Location:** `man/offspringCounts.Rd` (line 22); source `R/offspringCounts.R`
- **Doc says:** A dataframe with at least \code{id} and \code{totalOffspring} required and \code{livingOffspring} optional.
- **Code does:** offspringCounts does `results <- as.data.frame(totalOffspring)` where `totalOffspring <- findOffspring(...)` is a named numeric vector, so `as.data.frame()` yields a one-column data frame named `totalOffspring` with the ids as row.names (and `livingOffspring` cbind-ed on when considerPop=TRUE). Verified by running the documented example: colnames are `totalOffspring` (and `totalOffspring, livingOffspring`), and `"id" %in% colnames(counts)` is FALSE.
- **Fix:** Drop the `id`-column claim; state that the returned data frame contains column `totalOffspring` (and optional `livingOffspring`) and that the animal ids are the data frame's row names, not a column.

#### 25. `removeDuplicates` — wrong-return · **moderate**

- **Location:** `man/removeDuplicates.Rd` (line 18); source `R/removeDuplicates.R`
- **Doc says:** \value{ Pedigree object with all duplicates removed. }  ...  reportErrors: 'The errors will be returned in a list of list where each sublist is a type of error found.'
- **Code does:** When reportErrors = TRUE the function returns `ped$id[duplicated(ped$id[ped$recordStatus == "original"])]` (a character vector of duplicated ids) when duplicates exist, else NULL — neither a 'Pedigree object with all duplicates removed' nor 'a list of list where each sublist is a type of error found'. Only the reportErrors = FALSE branch returns the de-duplicated pedigree.
- **Fix:** Document the reportErrors = TRUE return as a character vector of duplicate ids (or NULL), and correct the 'list of list' claim in the reportErrors @param.

### Minor (13)

#### 26. `calculateSexRatio` — factual-mismatch · **minor**

- **Location:** `man/calculateSexRatio.Rd` (line 13); source `R/calculateSexRatio.R`
- **Doc says:** \item{ped}{dataframe that is the \code{Pedigree}. It contains pedigree information including the IDs listed in \code{candidates}.}
- **Code does:** calculateSexRatio's signature is calculateSexRatio(ids, ped, additionalMales = 0L, additionalFemales = 0L). There is no `candidates` formal argument; the candidate IDs are passed as `ids`. The `\code{candidates}` reference is pulled in verbatim via `@inheritParams getPotentialSires`, whose own ped param (R/getPotentialSires.R line 8) already carries the same stale reference (getPotentialSires is likewise (ids, ped, minAge) with no `candidates`). Because it is wrapped in \code{}, it renders as if it were an argument name, so a reader looking for a `candidates` argument on the page finds none.
- **Fix:** Fix at the source in R/getPotentialSires.R line 8: change `the IDs listed in \code{candidates}` to `the IDs listed in \code{ids}` (or plain prose "the ids you supply"); the corrected description then propagates to calculateSexRatio via @inheritParams. Low priority: inherited wording artifact, not a behavioral error.

#### 27. `convertSexCodes` — factual-mismatch · **minor**

- **Location:** `man/convertSexCodes.Rd` (line 28); source `R/convertSexCodes.R`
- **Doc says:** \item \code{H} -- replacing "HERMAPHRODITE" or "4", if ignore.herm == FALSE
\item \code{U} -- replacing "HERMAPHRODITE" or "4", if ignore.herm == TRUE
- **Code does:** The signature is convertSexCodes(sex, ignoreHerm = TRUE) and the branch is `if (ignoreHerm) ... else ...`. There is no `ignore.herm` argument; the Details use a stale snake_case name that a reader could hunt for in the argument list without finding it.
- **Fix:** Replace the two `ignore.herm` references in @details with `ignoreHerm` (or `\code{ignoreHerm}`) to match the actual argument name shown in Usage/Arguments.

#### 28. `createExampleFiles` — factual-mismatch · **minor**

- **Location:** `man/createExampleFiles.Rd` (line 13); source `R/createExampleFiles.R`
- **Doc says:** Creates a folder named \code{~/tmp/ExamplePedigrees} if it does not already exist. It then proceeds to write each example pedigree into a CSV file named based on the name of the example pedigree.
- **Code does:** pedigreeDir <- tempdir(); ... pedigreeDir <- file.path(pedigreeDir, "ExamplePedigrees"). Files are written to file.path(tempdir(), "ExamplePedigrees") -- the session temp dir (e.g. /var/folders/.../T//RtmpXXXX/ExamplePedigrees), not ~/tmp. The function's own runtime message() reports this real tempdir()-based path, confirming the man page is the stale one.
- **Fix:** Change the description to say the folder is created under the R session temporary directory (as returned by tempdir()), e.g. 'Creates a folder named ExamplePedigrees under tempdir() ...', matching the code and the emitted message.

#### 29. `getPyramidAgeDist` — factual-mismatch · **minor**

- **Location:** `man/getPyramidAgeDist.Rd` (line 20); source `R/getPyramidAgeDist.R`
- **Doc says:** Forms a dataframe with columns \code{id}, \code{birth}, \code{sex}, and \code{age} for those animals with a status of \code{Alive} in the pedigree.
- **Code does:** The function assigns ped$status <- 'ALIVE'/'DECEASED', computes age to exit_date for deceased rows, and returns the full ped with no filtering to living animals (R/getPyramidAgeDist.R:45-71). Its own @return states the added status column 'describes the animal as ALIVE or DECEASED', so deceased animals are included.
- **Fix:** Reword the description: the function returns all animals with an added status column (ALIVE/DECEASED) and computed age (age at exit for deceased), not only living animals.

#### 30. `getVersion` — factual-mismatch · **minor**

- **Location:** `man/getVersion.Rd` (line 10); source `R/getVersion.R`
- **Doc says:** A logical value when TRUE (default) a date in YYYYMMDD format within parentheses is appended.
- **Code does:** The code appends `sessioninfo::package_info("nprcgenekeepr")[["date"]]`, which is an ISO YYYY-MM-DD string (verified value "2026-06-29"), producing output like "1.1.0.9000 (2026-06-29)" -- hyphen-separated, not the undelimited YYYYMMDD the doc promises.
- **Fix:** Correct the documented format to YYYY-MM-DD (or describe it as an ISO date) so the reader is not misled about the appended date's form.

#### 31. `makeSimPed` — factual-mismatch · **minor**

- **Location:** `man/makeSimPed.Rd` (line 23); source `R/makeSimPed.R`
- **Doc says:** For each \code{id} in \code{allSimParents} with one or more unknown parents each unknown parent is replaced with a random sire or dam as needed from the corresponding parent vector (\code{sires} or \code{dams}).
- **Code does:** The loop never tests whether the existing sire/dam is unknown/NA. For every id it executes `ped$sire[ped$id == id] <- sample(sires, 1L)` (and likewise for dam), overwriting an already-known parent; and when the sires or dams vector is empty it sets that parent to NA. So the 'only unknown parents are replaced' conditional is not implemented, and a reader who supplied an id with a known parent (expecting it preserved) would instead have it overwritten or blanked to NA.
- **Fix:** Reword the @description to state that each id's sire and dam are (re)assigned by random draw from the supplied representative vectors, and that an empty vector yields an NA parent, rather than implying only unknown parents are affected.

#### 32. `removePotentialSires` — factual-mismatch · **minor**

- **Location:** `man/removePotentialSires.Rd` (line 17); source `R/removePotentialSires.R`
- **Doc says:** \item{ped}{dataframe that is the \code{Pedigree}. It contains pedigree information including the IDs listed in \code{candidates}.}
- **Code does:** The signature is removePotentialSires(ids, minAge, ped); there is no `candidates` formal argument. The IDs are supplied through `ids` (setdiff(ids, getPotentialSires(ids, ped, minAge))). `candidates` is rendered as \code{} (monospace), so a reader looks for a nonexistent parameter.
- **Fix:** Change \code{candidates} to \code{ids} in the ped @param (the inherited getPotentialSires text has the same error).

#### 33. `getPossibleCols` — misleading-render · **minor**

- **Location:** `man/getPossibleCols.Rd` (line 24); source `R/getPossibleCols.R`
- **Doc says:** \item{birth}{ -- Date or \code{N} (optional) with the individual's birth date}
- **Code does:** Every other optional column in this @return documents its missing value as \code{NA} (e.g. sire, dam, exit, ancestry); birth alone reads \code{N} (R/getPossibleCols.R:22). getRequiredCols' matching birth item correctly reads \code{NA}.
- **Fix:** Change \code{N} to \code{NA} in the birth item of getPossibleCols' @return.

#### 34. `getPotentialSires` — wrong-param · **minor**

- **Location:** `man/getPotentialSires.Rd` (line 12); source `R/getPotentialSires.R`
- **Doc says:** dataframe that is the \code{Pedigree}. It contains pedigree information including the IDs listed in \code{candidates}.
- **Code does:** The signature is getPotentialSires(ids, ped, minAge = 1L) (R/getPotentialSires.R:20). There is no `candidates` argument anywhere; the IDs are supplied through `ids`.
- **Fix:** Change `candidates` to `ids` in the @param ped description of getPotentialSires.

#### 35. `print` — wrong-param · **minor**

- **Location:** `man/print.Rd` (line 15); source `R/print.summary.nprcgenekeeprErr.R`
- **Doc says:** additional arguments for the \code{summary.default} statement
- **Code does:** In print.summary.nprcgenekeeprErr, `...` is forwarded to `print(txt$sp, digits = 2L, row.names = TRUE, ...)`; in print.summary.nprcgenekeeprGV `...` is unused. There is no summary()/summary.default call in either method.
- **Fix:** Describe `...` as further arguments passed to the print() call for the suspicious-parents table (and ignored by the GV method), not as arguments for a summary.default statement.

#### 36. `saveDataframesAsFiles` — wrong-param · **minor**

- **Location:** `man/saveDataframesAsFiles.Rd` (line 11); source `R/saveDataframesAsFiles.R`
- **Doc says:** \item{dfList}{list of dataframes to be stored as files.
\code{"txt"}, \code{"csv"}, or \code{"xlsx"}. Default value is \code{"csv"}.}
- **Code does:** dfList is validated as a list whose elements are all data.frames (inherits(dfList, "list") && all(vapply(..., what = "data.frame"))); the trailing '"txt", "csv", or "xlsx". Default value is "csv".' sentence belongs to the fileType argument and is stray in the dfList description.
- **Fix:** Delete the stray file-type sentence from the dfList @param; it duplicates the fileType description.

#### 37. `filterThreshold` — wrong-return · **minor**

- **Location:** `man/filterThreshold.Rd` (line 19); source `R/filterThreshold.R`
- **Doc says:** The kinship matrix with all kinship relationships below the threshold value removed.
- **Code does:** The body is `kin <- kin[kin$kinship >= threshold, ]; ...; kin` -- it subsets rows of the input long-format data.frame (columns id1, id2, kinship, per its own @param) and returns that data.frame. The function's @description ('long-format table of kinship values') and the sibling filterPairs (@return 'A dataframe representing a filtered long-format kinship table') both correctly call this a table/data.frame, not a matrix.
- **Fix:** Describe the return as the filtered long-format kinship table (data.frame), matching the @param/@description wording and filterPairs, rather than 'the kinship matrix'.

#### 38. `mapIdsToObfuscated` — wrong-return · **minor**

- **Location:** `man/mapIdsToObfuscated.Rd` (line 16); source `R/mapIdsToObfuscated.R`
- **Doc says:** A dataframe or vector with original IDs replaced by their obfuscated counterparts.
- **Code does:** The body is `as.character(vapply(ids, function(id) map[names(map) == as.character(id)], character(1L)))`, which always yields a character vector. There is no code path that returns a data.frame; the input `ids` is a character vector and the result is coerced with as.character().
- **Fix:** Change the @return to describe a character vector of obfuscated IDs (drop the "dataframe or" alternative).

---

## 4. Structural Observations

Fifteen of the 38 are `factual-mismatch`, twelve are `wrong-return`, ten are `wrong-param` — and most cluster into a handful of **systemic patterns**, not 38 independent typos. The recommendation is to fix the *pattern*, not just the instance.

1. **Copy-paste `@param ped` "`candidates`" drift (a donor bug that cascades).** `getPotentialSires`'s `@param ped` says the pedigree "contains … the IDs listed in `\code{candidates}`", but no function in this family has a `candidates` argument — the IDs are the `ids` argument. This one donor line propagates to **`calculateSexRatio`** (via `@inheritParams getPotentialSires`) and is copy-pasted verbatim into **`removePotentialSires`**. *Four findings, one root* (#11 donor-`minAge`, #26, #32, #34). **Fix the donor `getPotentialSires.R` `@param ped` (and `@param minAge`) and re-document — the `@inheritParams` callees fix themselves.**

2. **Logical-scalar checkers documented as "NULL / the entire list."** `checkChangedColsLst` (#3, Critical) and `checkErrorLst` (#18) both return a bare `TRUE`/`FALSE` but their `@return` promises `NULL`-or-the-list. Same template, same wrong contract; a caller writing `is.null(result)` never detects the empty case.

3. **`reportErrors = TRUE` alternate return undocumented.** `correctParentSex` (#19) and `removeDuplicates` (#25) each return a *different type* when `reportErrors = TRUE` (a list / a character vector) than the `@return` (and sometimes the `@param reportErrors`) describes. The dual-return contract of the QC family is under-documented.

4. **`@return` list-element names don't match the code.** `getPotentialParents` (`sire`/`dam` vs `sires`/`dams`, #21), `summarizeKinshipValues` (`kinshipIds…` vs `kIds…`, #16), `modPyramidServer` (`data/plot/livingCount` vs `pedigree/animalCount`, #23), `offspringCounts` (`id` column vs row-names, #24). A caller following the docs gets `NULL` from `$name` access.

5. **Return-*type* mislabelled.** `addAnimalsWithNoRelative` (list documented as long-form data.frame, #17), `getTokenList` (two-element list documented as a single token, #22), `filterThreshold` (data.frame documented as "matrix", #37), `mapIdsToObfuscated` ("dataframe or vector" but always a vector, #38), `geneDrop` (column order reversed, #20).

6. **"Excel" is `"excel"`, documented as `"xlsx"`.** `saveDataframesAsFiles` (#2, Critical) and `makeExamplePedigreeFile` (#14) share the exact wrong allowed-value; the documented `fileType = "xlsx"` trips each function's `stopifnot`.

7. **A "live/alive animals only" filter that the code does not apply.** `getPedMaxAge` (#5) and `getPyramidAgeDist` (#29) both claim living-only results, but neither filters — deceased animals (with age-at-exit) are included, as each function's own `@return` confirms.

8. **`kinship()`'s self-kinship is 0.5, documented as 1.0.** `kinshipMatricesToKValues` (#6) and `kinshipMatrixToKValues` (#7) both state the diagonal "are by definition all 1.0", but this package's `kinship()` uses the coancestry convention (self-kinship `(1+F)/2` = 0.5), and those self-pairs are retained in the output.

9. **Doc describes a sibling helper's job, not this function's.** `makeCEPH` (#8) documents the relationship-category cascade that actually lives in its caller `convertRelationships`. Same shape as the S244 `getSimSires`/`getPotentialSires` and `findGeneration`/`findPedigreeNumber` cases — sibling-function copy-paste.

Two findings also intersect open issues: **`runModularApp` #9** (the "run the monolithic version via `runGeneKeepR`" line is stale) touches **#110** (the `runGeneKeepR` deprecation question), and **D7 / `makeGeneticDiversityDashboard`** touches **#112** (finish the diversity dashboard).

---

## 5. Items Audited & Coverage

| Area | Items | Coverage |
|---|---|---|
| `man/*.Rd` semantic read (doc-vs-code) | 203 / 203 | 100% (17 batches × ~12) |
| Adversarial verification of candidates | 39 / 39 | 100% (38 confirmed, 1 refuted) |
| Session-author firsthand re-verification | 3 Critical + ~7 sampled Moderate/Minor + 1 refuted | headline claims |
| Deterministic classes (D1–D8, xref, doubled-Rd, empty-code, data-doc columns, `document()` warnings) | all 203 | 100% — clean/fixed |

### The one refuted candidate (transparency)

`getRequiredCols` — a finder flagged the `@return` as contradictory because `birth` is listed among the *required* columns yet annotated `(optional)`. **Refuted (verified firsthand):** "(optional)" there qualifies the *value* form ("Date or `NA`"), i.e. the birth-*date value* may be missing — exactly parallel to `sire`/`dam`'s "(`NA` if unknown)". It does **not** annotate the column as omissible; `getRequiredCols()` does return `c("id","sire","dam","sex","birth")`. "A required column whose value may be `NA`" is coherent, not misleading. (That the same verification pass *confirmed* the near-identical `\code{N}`-for-`\code{NA}` typo in `getPossibleCols` #33 while *refuting* this one demonstrates the calibration held.)

---

## 6. Recommendations (for a follow-on, owner-gated session)

Every fix below is a **pure-doc REFACTOR-class edit** (roxygen prose only; no signatures, no `NAMESPACE`). `R/` + `man/` ship in the tarball, so each stage re-stales the `--as-cran` gate (re-gate after; `lintr`; `spell_check_package` hand-adding any new terms). Suggested order (highest value first, structural-cause fixes cascade):

1. **The 3 Critical, first** — `checkChangedColsLst` #3, `getFocalAnimalPedFromFile` #2, `saveDataframesAsFiles` #1: these break a caller who follows the docs (wrong `is.null`/`$name`/`fileType` usage).
2. **Structural-cause fixes that cascade** — fix the `getPotentialSires.R` donor `@param ped`/`@param minAge` (pattern 1 → resolves #11/#26/#32/#34 in one edit + re-`document()`); the two `"xlsx"→"excel"` lines (pattern 6, #1/#14); the two kinship-diagonal `1.0→0.5` lines (pattern 8, #6/#7).
3. **The remaining Moderate wrong-return / wrong-param** — return-shape and element-name corrections (#17–#25, #10, #12–#16), each a localized roxygen edit.
4. **Minor** — the `\code{N}→\code{NA}` render typo (#33), stale paths/format (#28/#30), and the remaining prose mismatches (#27, #31, #35, #36).
5. **Cross-issue** — decide `runModularApp` #9 alongside **#110** (deprecation of `runGeneKeepR`); leave `makeGeneticDiversityDashboard` (D7) to **#112**.

**Process fix to prevent recurrence.** Every finding is *sibling copy-paste* or *code-evolved-past-the-doc*. Two low-cost guards: (a) when documenting a function, read its `@return`/`@param` against the *body*, not a sibling's doc (the S244/S269 "read-before-edit" discipline); (b) a periodic re-run of *this* audit's semantic sweep — the deterministic layer (§2) is already covered by `R CMD check`, but doc-vs-code accuracy is not, and only a read catches it.

---

## 7. Method & Verification Notes

- **The generated `.Rd` is the arbiter, not an `R/` grep** (Learning 251): findings cite the rendered man page a user actually reads, cross-checked to the source and (for behaviour claims) the running function. Several findings were confirmed by *executing* the documented example (`addAnimalsWithNoRelative`, `offspringCounts`, `geneDrop`, `get_elapsed_time_str`).
- **Adversarial verification defaulted to REFUTE**; the 1/39 refute rate reflects well-scoped finders (explicit out-of-scope exclusions for #103-style harmonization nits) plus a same-bar verify pass, not a lax filter — the author's firsthand sample (all 3 Critical + a Moderate/Minor cross-section + the refuted one) held in every case.
- **This audit is the delta, not a re-run.** The S244 audit (`ROXYGEN_HARMONIZATION_AUDIT_2026-06-29.md`) and the #103 work covered *harmonization* (voice, ordering, `@param` de-dup) and are largely implemented; its rendered-doc defects D1–D8 are all fixed (§2). #109's lens is *errors*, and the 38 here are the errors that survive a clean `R CMD check`.
- **No `R/` modified.** Analysis only; the fixes are a separate session.
