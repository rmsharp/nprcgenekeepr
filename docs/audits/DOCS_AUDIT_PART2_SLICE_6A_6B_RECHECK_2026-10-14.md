# Docs audit, part 2: the ten slice 6a-6b flags, re-checked against today's code (2026-10-14, S986)

Read-only audit. Nothing in the repo was changed except this report and the session records. No fix was made: every
fix below is a code or help-text change and needs your ruling and its own session.

## Audit summary

- **Scope:** the ten flags of docs-audit slices 6a (S834, `DOCS_STALENESS_AUDIT_SLICE6A_2026-10-01.md`) and 6b (S836,
  `DOCS_STALENESS_AUDIT_SLICE6B_2026-10-01.md`) that `BACKLOG.md:109-115` carries without a re-check since S870:
  6a MB3, MA3, MB14; 6b PB4, PB7, PB11, PB13, PA4, PD12, PD1. MA3 and MB14 are one claim, so there are **nine findings
  for ten flags**. **Not covered:** slice 6a's MC1 (fixed S923) and its MA5 and MC13 (listed in that report's own
  code-change candidates, not in the backlog's ten), and the clusters 6d, 6e, 7b and slice 8; they stay open in
  `BACKLOG.md`.
- **Criterion:** is the behavior the slice described still what the code does; can a colony manager reach it through
  the app (the Input tab) or only by calling the function from a script; do the help pages say so; does a test pin it?
- **Method:** read each function and every caller in `R/`; grepped the tests; ran probes from scratch scripts outside the
  repo, started from the project root so renv is active. One finding (PB11) was also run through the real Input module
  (`shiny::testServer(modInputServer)`, the upload recipe of `tests/testthat/test_modInput_qcStudbook.R:273-317`) on the
  shipped `ExamplePedigree.csv`. The X-linked kinship was compared with `kinship2` 1.9.6.2 on the same pedigrees.
  `e1071` 1.7.17 and `moments` 0.14.1 were installed into a scratch library (not into renv) to run MA3 and MB14.
- **Not done:** no browser run, so what the Input tab draws is read from the module's stored results, not seen. An
  `.xlsx` with a blank header was not run (`writexl` is not installed here). The help's remark that Excel, SAS and SPSS
  report the same skewness and kurtosis was not checked (none is available here).
- **Result:** all the code behavior the slices described is still what the code does. **0 critical, 1 moderate, 7 minor,
  1 closed** (one per finding). Only **PB11 and PB7 are reachable from an upload**, and only PB11 changes what a
  colony manager sees on the Input tab (the moderate one). The help already tells the truth for PA4, PB13, PD1, MA3 and
  MB14 (fixed S835 and S837); it still says something false for MB3, PB4, PB7 and PB11, and one sentence is half false
  for PD12.

## Findings

### Finding 1 (MB3): `kinship(chrtype = "x")` gives an unknown-sex founder NA only on its own diagonal; the help says "with everyone" (minor; script-only; help still wrong)

- **Location:** help `R/kinship.R:57-59` (and `man/kinship.Rd:61`); code `R/kinship.R:129-135` (founder diagonal NA) and
  `:210-213` (an unknown-sex animal with parents gets an NA row and column).
- **Evidence (probe):** founders F1, M1, U1 (sex F, M, U), C1 = F1 x M1, C2 = M1 x U1 (a son). U1's row is 0 with F1 and
  M1 and NA only with itself; C2 is NA with U1 and 1 with itself. In a second pedigree C1 is of unknown sex: C1's whole
  row and column are NA, itself included, as the sentence says. **Both matrices equal `kinship2::kinship(..., chrtype
  = "x")` cell for cell** (`all.equal` TRUE both times). Tests: `test_kinship.R:170-180` pins an unknown-sex non-founder's NA row
  and column and one unaffected cell; `:205-216` pins one lone unknown-sex animal's NA diagonal; none pins a founder's zeros.
- **Reach:** not from the app: nothing in `R/` outside `kinship.R` passes `chrtype`.
- **Impact:** a script user who reads "NA with everyone" for a founder of unknown sex finds 0 with every other founder.
- **Your ruling:** (a) reword the sentence and keep the code, which equals kinship2's (one help sentence); (b) change
  the code so a founder is NA with everyone (breaks the match with kinship2, the package's reference for this branch); (c) leave.
  Proposed sentence for (a), replacing `R/kinship.R:57-59` from "An individual with" to "self-kinship value.": "A founder of unrecognized \code{sex} gets \code{NA} only
  on its own diagonal cell and 0 with the other founders, as in kinship2; an animal of unrecognized \code{sex} that has
  parents in the pedigree gets \code{NA} kinship with everyone, itself included."

### Finding 2 (MA3 and MB14): the `type = 2` claim of `calcSkewness()` and `calcKurtosis()` is true, now by a run (closed; no ruling)

- **Location:** `R/calcSkewness.R:8-15`, `R/calcKurtosis.R:8-17`; both man pages cite `e1071` only since S835 (`moments` is gone from them).
- **Evidence (run):** `moments::skewness` and `moments::kurtosis` take `x, na.rm` and have no `type`; `e1071`'s take `type`. On
  seven vectors (the two help examples, `rnorm(10)`, `rexp(25)`, `runif(7)`, `rgamma(200, 2)` and one with an `NA`, seed 1)
  `calcSkewness()` equals `e1071::skewness(type = 2)` and `calcKurtosis()` equals `e1071::kurtosis(type = 2)` to six decimals;
  the help examples' 2.232396 and 4.986866 are the same. For n <= 2 and n <= 3 the package returns `NA` and `e1071` stops ("Need
  at least 3 complete observations"); the help already says "Returns `NA`", so no claim differs.
- **Ruling:** none. The slice's "from recall, not a run" caveat is closed.

### Finding 3 (PB4): `checkRequiredCols()` tolerates an `NA` name only when `cols` is shorter than the required set; the help and a test say it always does (minor; script-only)

- **Location:** code `R/checkRequiredCols.R:40-41` (the `if`), `:51-53` (the only use of `ignore_na = TRUE`); help `:6-10`; `R/str_detect_fixed_all.R:21`.
- **Evidence (probe):** required are id, sire, dam, sex, birth. With `birth` missing: 4 names plus `NA` returns `sex, birth`
  (no error); **5 names plus `NA` stops "missing value where TRUE/FALSE needed"**, and so does `reportErrors = FALSE`. It works
  below 5 only because `length(cols) < length(requiredCols)` makes the `if` true before the `NA` is read. The test
  (`test_checkRequiredCols.R:15-29`) uses 4 and 2 names, so it passes. The same error reaches `qcStudbook()` and, through
  `runQcStudbook()`, the Input tab as "Data Processing Error: missing value where TRUE/FALSE needed" (probe, a data frame whose
  sixth name is `NA`).
- **Reach:** not from a CSV upload: `read.csv()` names a blank header `X` (run). An `NA` name needs a data frame edited in a script
  (`names(df)[6] <- NA`); an `.xlsx` with a blank header was not run.
- **Your ruling:** (a) pass `ignore_na = TRUE` in the first test as well and add a test with 5 or more names, so the help
  and the existing test come true (one line); (b) drop the sentence from the help and the test's comment; (c) leave.

### Finding 4 (PB7): `checkChangedColsLst()` checks 12 of the 13 changed-column fields; a lowercase `geographicorigin` header is renamed with no notice (minor; reachable from an upload; visible effect is one flag and one heading)

- **Location:** `R/checkChangedColsLst.R:36-52` (12 fields), `R/getEmptyErrorLst.R:31-45` (13), `R/fixColumnNames.R:76-78` (sets the
  13th), `R/summary.nprcgenekeeprErr.R:111-165` (lists 10), `R/processQcStudbookResult.R:197-213` (writes warning rows for 2).
- **Evidence (probe, `runQcStudbook(reportChanges = TRUE)`, the call `R/modInput.R:520` makes):** a file whose header is lowercase
  `geographicorigin` gives `hasChangedCols` FALSE and no warning, and the cleaned pedigree does have `geographicOrigin`, so the
  rename happened. `GeographicOrigin` (case change), `geographic.origin` (period), `birthdate`, `ego`, `sireid`, `fromcenter` and
  `recordstatus` all give TRUE. `qcStudbook(reportErrors = TRUE, reportChanges = TRUE)` returns `NULL` for such a clean file
  (`R/qcStudbook.R:386`), and `runQcStudbook()` then substitutes the empty list (`R/runQcStudbook.R:153-156`), so no record of the
  rename survives. No test mentions `geographicorigin` (git grep empty). Of the 25 shipped example files only
  `2022-05-02_Deidentified_Pedigree.xlsx` has such a header (`geographic.origin`, caught by the period rule), so no shipped file reaches it.
- **Reach and impact:** `hasChangedCols` is stored (`R/modInput.R:570`) and nothing else reads it; the errors-tab heading "and Changes
  to Pedigree Column Names" appears only when the file also has errors (`R/insertErrorTab.R:16`). The help (`:8-9`, "any changed-columns
  field") is false by one field.
- **Your ruling:** (a) make `checkChangedColsLst()` count any non-empty field of the list it is given (`any(lengths(changedCols) > 0L)`;
  one line, one test; a field added later counts without a second edit); (b) add the 13th name by hand; (c) leave and reword the
  help to "any of the 12 listed fields". Whether `summary()` should list all 13 is a separate question (it lists 10 today).

### Finding 5 (PB11): one invalid date in a file with two date columns stops the Input tab with a cryptic message instead of listing the rows (moderate; reachable from an upload; measured on the shipped example)

- **Location:** `R/getDateErrorsAndConvertDatesInPed.R:43-45` (`sb[, names(sb) %in% getDateColNames()] <- as.Date(sb[, ...],
  origin = ...)`); help `:9-10`; `getDateColNames()` is `birth`, `death`, `departure`, `exit` (`R/getDateColNames.R:10-12`).
- **Evidence, in the real Input module** (`ExamplePedigree.csv`, 3,694 animals, columns `birth` and `exit`, 1,990 non-blank exit dates):

  | File | Errors | What the Errors table says |
  |---|---|---|
  | as shipped | 0 | (warnings 1, "Animals with no birth date") |
  | row 12 (`JHQPAP`) birth set to `2010-16-22` | 1 | "Data Processing Error: do not know how to convert 'sb[, names(sb) %in% getDateColNames()]' to class “Date”" (records 0, not ready) |
  | same, `exit` column removed | 1 | "Invalid date values: 12" |

  An invalid `exit` date gives the same cryptic error (probe). With one date column, an invalid **first** non-blank value gives
  "character string is not in a standard unambiguous format", and an invalid value elsewhere gives "Invalid date values: 3"
  (probe, 4-animal file). `as.Date()` has no method for a data frame of two or more columns, and for one character column it
  reads the whole column's format from its first non-blank value.
- **Why the tests and the article miss it:** `test_getDateErrorsAndConvertDatesInPed.R` uses only `pedInvalidDates`, which has one
  date column; `test_convertDate.R:146-166` shows `convertDate()` itself handles every date column and numbers each bad row.
  `vignettes/articles/studbook-quality-control.qmd:181` promises "Invalid date | stops | `invalidDateRows`", and its example
  (`:134-139`) works for the same reason.
- **Help sentence:** `:9-10` says "otherwise the pedigree is not updated". With some invalid rows the pedigree **is** converted
  (invalid dates become `NA`, `exit` is added; pinned by the tests at `test_getDateErrorsAndConvertDatesInPed.R:26-36`); it is
  left unconverted only when every original record is invalid (pinned at `:82-96`).
- **Impact:** a colony manager with one mistyped date in a file that has two date columns (the commonest shape) gets no list of
  rows and a message with R internals.
- **Your ruling:** (a) convert each date column on its own, so every invalid date is listed by row as the article says, and reword
  the help sentence (files with no invalid date change nothing; test first with two date columns; Effort S to M); (b) reword the help
  only; (c) leave.

### Finding 6 (PB13): `fixColumnNames()` renames by unanchored substring; documented, no shipped file affected (minor; documented)

- **Location:** `R/fixColumnNames.R:52-78`; help `:6-14` (says so, with the `category` example, fixed S837).
- **Evidence (probe):** `category` becomes `catidry`, `birthdate_est` becomes `birthest`. **Two headers that end with the same
  name are not stopped:** `birth` plus `birthdate` become `birth, birth`, `ego` plus `id` become `id, id`; a data frame with `birth`
  and `birthdate` runs through `runQcStudbook()` with no error and the cleaned pedigree holds `birth` and `birth.1` (a data
  frame, not an upload). A `Category` column is kept as `catidry` with `hasChangedCols` TRUE and no warning row (the warnings list
  only case and space changes, as `R/runQcStudbook.R:24-28` says). Across the headers of all 25 shipped example files, the only
  one an unanchored rule touches is `geographic.origin`, renamed on purpose.
- **Your ruling:** (a) leave (documented; anchoring would not stop the same-name case); (b) anchor the renames to whole names;
  (c) a separate item: stop with a message when two columns end with the same name. I would pick (a).

### Finding 7 (PA4): a clean `qcStudbook(reportErrors = TRUE)` returns `NULL`, which `processQcStudbookResult()` reports as a failed check; documented (minor; script-only)

- **Location:** `R/processQcStudbookResult.R:81-90`; help `:9-15` (says so, fixed S837); `R/qcStudbook.R:386`.
- **Evidence (probe):** `qcStudbook(ExamplePedigree.csv, reportErrors = TRUE)` is `NULL`; `processQcStudbookResult(NULL)` gives
  `hasErrors` TRUE, "QC Processing Error: No result returned from quality control check". The app is not affected:
  `runQcStudbook()` replaces the `NULL` with the empty list (`R/runQcStudbook.R:153-156`), and the Input module on the shipped
  file reports 0 errors, 3,694 records, ready. No test pins the failed-check branch (git grep for the message in `tests/`: empty).
- **Your ruling:** (a) leave (the help says so and points to `runQcStudbook()`); (b) treat `NULL` as "nothing found" (reverses the
  documented meaning). I would pick (a).

### Finding 8 (PD12): `hasBothParents()` takes one id; the help says a vector "gives a recycling warning", which is true only sometimes (minor; not reachable; one help sentence half false)

- **Location:** `R/hasBothParents.R:21-23`; help `:6-11` (fixed S837 except that sentence).
- **Evidence (probe, `pedOne`, 8 rows):** `"o2"` gives TRUE. **Two ids give one value, FALSE, and no warning** (the truth is FALSE,
  TRUE); three ids give two recycling warnings. An id not in `ped` gives `logical(0)` (the help says so) and `if (logical(0))`
  stops "argument is of length zero". No test calls the function (git grep empty).
- **Reach:** the only caller, `R/addBackSecondParents.R:43`, passes one id per pass of a loop over `getIdsWithOneParent(uPed)`
  (read, not run), so neither case is reached.
- **Your ruling:** (a) reword one sentence; (b) make it check (one id; FALSE for an id not in `ped`; a test); (c) leave. Proposed
  sentence for (a), replacing `R/hasBothParents.R:6-7`: "a single ID to examine for parents. A vector of IDs is not supported:
  the result is not one value per ID, and a recycling warning appears only when the number of IDs does not divide the number of
  rows of \code{ped}."

### Finding 9 (PD1): `removePotentialSires()` has no default for `minAge`; documented (minor; documented)

- **Location:** `R/removePotentialSires.R:25-27`; help `:8-10` ("there is no default; it is required", fixed S837).
- **Evidence (probe):** calling it without `minAge` stops "argument "minAge" is missing, with no default". Both callers pass it
  (`R/fillGroupMembers.R:43`, `R/addGroupOfUnusedAnimals.R:25`).
- **Your ruling:** (a) leave; (b) give it `minAge = 1L` (no existing call changes; the inherited sentence would then be true). I
  would pick (a).

## Items audited

| Flag | Slice claim | Today | Reachable from the app? | Finding |
|---|---|---|---|---|
| MB3 | unknown-sex founder gets NA only on the diagonal | still true, equals kinship2; help still says "everyone" | no | 1 |
| MA3, MB14 | `type = 2` claim rests on recall | true, run against `e1071` 1.7.17 | n/a | 2 |
| PB4 | `NA` in `cols` errors when a required column is also missing | still true for 5 or more names; help and a test promise otherwise | no (a script) | 3 |
| PB7 | 12 of 13 fields checked | still true; one more place lists 10 | yes, lowercase `geographicorigin` header | 4 |
| PB11 | partial update; `as.Date()` on a data frame errors | still true; moderate, run in the module | **yes, on the shipped example** | 5 |
| PB13 | unanchored substring renames | still true; documented | yes, harmless on shipped files | 6 |
| PA4 | clean `qcStudbook()` is `NULL`, read as failure | still true; documented | no (the app substitutes the empty list) | 7 |
| PD12 | scalar only; absent id gives `logical(0)` | still true; "recycling warning" half false | no | 8 |
| PD1 | no default for `minAge` | still true; documented | no (both callers pass it) | 9 |

Coverage: 10 of 10 flags, 9 of 9 findings examined. Finding 5 was also run through the real module; findings 1, 2, 3, 4, 6, 7 and 8
were run as functions and read in their callers; finding 9 was run and its two callers read.

## Structural observations

- **A fixture too small to reach the branch is behind findings 3 and 5.** The `NA`-name test uses 4 and 2 names, which are shorter
  than the required set and so take the one path that works; the invalid-date tests use `pedInvalidDates`, which has one date
  column. Both pass, and both help pages and the QC article state the general case. A test with 5 names and one with two date
  columns would have failed on the day they were written.
- **Findings 4 and 7 are two sides of one mechanism:** "nothing to report" is a `NULL` (`R/qcStudbook.R:386`), and "nothing" is
  decided by a hand-copied list of field names (12 in the check, 10 in `summary()`, 2 for warning rows, 13 in the list itself).
  Offering "add the missing name" would be the wrong shape; finding 4 (a) derives it from the list.
- **The help pages rewritten S835 and S837 already tell the truth for five of the ten** (MA3, MB14, PA4, PB13, PD1). What is left
  is two stale sentences (MB3, PD12), two promises the code does not keep (PB4, PB7) and one real defect (PB11).
- **Only PB11 and PB7 can be reached from an upload,** and only PB11 changes what is shown beside an error.

## Comparison with slices 6a and 6b

| Slice claim (2026-10-01) | 2026-10-14 |
|---|---|
| MB3: unknown-sex founder NA on the diagonal only | confirmed, and equal to kinship2 cell for cell; the help sentence was never reworded |
| MA3, MB14: `type = 2` of `e1071`, from recall | confirmed by a run; `moments` is no longer cited |
| PB4: `NA` errors; line 36 lacks `ignore_na` | confirmed (now line 40); the test covers only short input |
| PB7: 12 of 13 fields | confirmed; reachable through one header spelling; two more lists lag |
| PB11: `as.Date()` on a data frame; partial update | confirmed; **reaches the shipped example**; the help sentence is still stale |
| PB13: unanchored renames | confirmed; documented; same-name headers are not stopped |
| PA4: clean `qcStudbook()` is `NULL` | confirmed; documented; the app handles it |
| PD12: scalar only, `logical(0)` | confirmed; "recycling warning" is only true when the lengths do not divide |
| PD1: no default | confirmed; documented |

## Recommendations

1. **Finding 5 (a), Effort S to M, strict TDD:** the only finding that changes what a colony manager sees. One date-handling
   cell, a test with two date columns first, and the help sentence.
2. **Finding 4 (a), Effort S:** one line plus a test with a lowercase `geographicorigin` header.
3. **Finding 3 (a), Effort S:** one line plus a test with 5 or more names.
4. **One docs-only session (Effort S):** findings 1 (a) and 8 (a), one sentence each, as proposed above.
5. **Leave:** findings 2 (closed), 6, 7 and 9, as documented.
6. Each build is its own session. Only findings 4 and 5 can change what an upload shows.
