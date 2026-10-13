# Docs audit, part 2: the eight marker-genetics code candidates, re-checked against today's code (2026-10-13, S976)

Read-only audit. Nothing in the repo was changed except this report and the session records. No fix was made: every
fix below is a code change and needs your ruling and its own strict-TDD session.

## Audit summary

- **Scope:** the eight "code candidates" of docs-audit slice 6c (S838, `DOCS_STALENESS_AUDIT_SLICE6C_2026-10-01.md:74-91`),
  carried in `BACKLOG.md:16` (text `:115-117`) without a re-check since S870. They hold 11 claims (ids QC7, QA1, QA2, QA4,
  QB1, QB4, QA10, QA11, QA7, QC6, and the `checkGenotypeFile` message, which has no id). **Not covered:** the other
  clusters of that item (slices 6a, 6b, 6d, 6e, 7b and the rest of slice 8); they stay open in `BACKLOG.md`.
- **Criterion:** is the behavior slice 6c described still what the code does; can a colony manager reach it through the
  app (the Marker Genetics tab) or only by calling the function from a script; do the docs say so; does a test pin it?
- **Method:** read each function and every caller in `R/`; grepped the tests; ran probes from scratch scripts outside the
  repo, started from the project root so renv is active (the pure functions, then the real Marker Genetics server through
  `shiny::testServer(modMarkerGeneticsServer)` with the upload recipe of `tests/testthat/test_modMarkerGenetics.R:137-170`).
  The probe numbers below come from those runs; the module fixture is the repo's own hand-verified one.
- **Not done:** no browser-driven run, so what the tab draws is read from `R/modMarkerGenetics.R`, not seen. The guide
  and the in-app guidance were not read for these claims. The effect of finding 7's `"NA/NA"` on `markerFst()`,
  `markerParentageLikelihood()` and `computeGenomicROH()` is read from the code, not run (only Ho, He and kinship were run).
- **Result:** all 11 claims are still true in the code. The docs already say so for 10 of the 11 (roxygen fixed S839,
  S841); the 11th, the `checkGenotypeFile` message, is a code defect with no doc claim. No test pins any of the eight as
  intended behavior. **0 critical, 2 moderate, 6 minor** (one per candidate). Two pairs share one cause: findings 1 and 7,
  and findings 2 and 4 (see Structural observations).

## Findings

### Finding 1 (candidate 1, QC7): `markerExpectedHeterozygosity()` gives 1.0 for a locus nobody was typed at (minor; script-only today; docs already say so)

- **Location:** `R/markerHeterozygosity.R:105-111` (`1.0 - sum(freqs^2.0)` of an empty table); roxygen `:75-82`.
- **Evidence:** a two-animal matrix with `L1` = `A/A`, `A/B` and `L2` = `NA`, `NA` gives `perLocus` L1 0.375, L2 **1.000**
  and `meanHe` **0.6875**; `markerObservedHeterozygosity()` on the same matrix gives `NA` for an animal with no typed locus
  (its own test, `test_markerHeterozygosity.R:71`). No test has an all-missing locus for the expected-heterozygosity function.
- **Reach:** not from the app today. A locus in an uploaded file always has at least one record, and a record with blank
  alleles becomes the text `"NA/NA"` (finding 7), so such a locus gives He **0**, not 1.0 (probe: `perLocus` L2 0.000).
  It is reachable by a script that builds or subsets a matrix itself. **Fixing finding 7 makes this reachable from the
  app**: an all-blank locus would then give 1.0 and lift the mean. Rule the two together.
- **Impact:** a script user's `meanHe` is raised by every untyped locus.
- **Your ruling:** (a) return `NA` for such a locus and average over the typed loci only (one function, one test; no
  result changes for a matrix whose every locus has a typed animal); (b) leave it, since the help page says so.

### Finding 2 (candidate 2, QA1): `computeGenomicROH()` changes every animal's F_ROH with the genotype file's locus list and says nothing (moderate; reachable in the app; docs already say so)

- **Location:** `R/computeGenomicROH.R:114-115` (`fullMeta` keeps only sidecar loci that are matrix columns), `:132-134`
  (the denominator is built from `fullMeta`); roxygen `:24-32`.
- **Evidence:** the help-page example (4 loci on chromosome 1, 1.4 Mb) gives F_ROH **0.2857**; the same call with the
  matrix missing `L4` gives **0.4444** (denominator 0.9 Mb), 0 warnings. The real module gives the same two numbers
  through its upload recipe (genotype file with all 4 loci, then without `L4`, sidecar listing all 4): 0.2857, then 0.4444,
  0 warnings. The other direction does warn: a matrix locus the sidecar lacks is dropped with a warning naming it. The tab's
  render has no warning handler (`R/modMarkerGenetics.R`, `output$sequenceRohTable`), so that warning reads as console-only (read, not seen).
  No test covers a sidecar locus absent from the matrix (`test_computeGenomicROH.R:172` covers a *partial* locus).
- **Impact:** a colony manager whose sidecar lists the whole panel and whose genotype file holds a filtered subset gets
  higher F_ROH values (here 56% higher), and two analyses of different subsets are not comparable, with nothing on the page.
- **Your ruling:** (a) warn in the function, naming the sidecar loci the matrix lacks, and keep every number (the
  same warning style the function already uses for the other direction; it reaches the R console only); (a+) the same warning
  plus a one-line notice above the F_ROH table, because the tab shows no warnings today (the shape of the notices S971 and S972
  built on the Input tab); (b) take the denominator from the whole sidecar, so it no longer depends on which loci were typed
  (a methods choice: numbers change, and a sidecar listing untyped regions makes F_ROH smaller); (c) leave it, since the help
  page says so.

### Finding 3 (candidate 3, QA2 and QA4): `hasGenotype()` matches `first` and `second` case-blind, then reads them case-exact (minor; script-only; docs already say so)

- **Location:** `R/hasGenotype.R:36-48`; roxygen `:6-14, :18-19`.
- **Evidence (probe):** `id`, `first`, `second` numeric: TRUE. `First`, `Second` numeric: **FALSE**. All-NA numeric `first`
  and `second`: **TRUE** (the S975 trap, worked around in `R/reportGV.R:304`). Negative and 1e9 values: TRUE. Character
  alleles: FALSE. A column named `valid` (no id column) satisfies the id test: **TRUE** (substring match). One new case: `First`,
  `Second` plus `first_x`, `second_x`: **TRUE**, because `genotype$first` partially matches `first_x`.
  `getGVGenotype()` on the `First`/`Second` frame returns `NULL` with no message. Tests pin only `first`/`second_name`
  and a non-`id` name as FALSE (`test_hasGenotype.R`); none pins `First`.
- **Reach:** not from the app. `fixColumnNames()` lower-cases every header (`Id`, `First`, `Second` become `id`, `first`,
  `second`; probe) before the check. A script that calls `hasGenotype()` or `getGVGenotype()` on an unchecked frame is affected.
- **Your ruling:** (a) leave it (the help says exactly this; Effort none); (b) make the three presence tests case-exact so
  the code reads the way it behaves, which also ends the partial-match case (no result changes; Effort S); (c) accept any
  case, which would also need `getGVGenotype()` and its callers to read the renamed columns (larger, and not checked here).

### Finding 4 (candidate 4, QB1): the sidecar is never compared with the genotype's loci, and no package code passes it to the checker (minor; script-only; docs already say so)

- **Location:** `R/checkSequenceGenotypeFile.R:127-129` (the only use: `checkLocusMetadata(locusMetadata)`); roxygen `:13-15`.
- **Evidence:** `checkSequenceGenotypeFile(g, <sidecar naming only "ZZ">)` with genotype loci `L1`, `L2` returns the genotype
  unchanged, 0 warnings (probe). The module calls the checker without a sidecar, at `R/modMarkerGenetics.R:553` and `:633`
  (no other caller passes one), so in the app the argument is not used at all. The reconciling happens, partly, later:
  `computeGenomicROH()` warns for a matrix locus the sidecar lacks (and, when none of them is in the sidecar, returns `NA` with two
  warnings, no error: probe) and is silent for the converse (finding 2).
- **Impact:** only a script that passes a sidecar here; a mismatch passes the checker.
- **Your ruling:** this is finding 2's question seen from the checker. (a) report a locus-set mismatch in
  `computeGenomicROH()` (and say whether `markerLdBlock()`, whose slice-6c note QC3 says it drops such loci silently, gets the
  same), where both tables are present and the app reaches; (b) also check in `checkSequenceGenotypeFile()` when a sidecar
  is passed (script-only); (c) leave it.

### Finding 5 (candidate 5): `checkGenotypeFile()`'s collision message repeats itself, carries source indentation and names one column only (minor; script-only)

- **Location:** `R/checkGenotypeFile.R:55-61` (`stri_c(format(collided), sep = ", ")` has no `collapse`; the `stop()` text is a
  string literal split over two source lines).
- **Evidence (probe):** three alleles above 10000 (10001 and 10002 in column 2, 10003 in column 3) give a 182-character message with
  2 line breaks and "Possible collision on allele(s) interpreted as a number > 10000:" **twice** (once per allele);
  10003 is not named, because the loop stops at the first column with a collision. One offending allele gives a 90-character
  message with one line break plus 20 spaces of source indentation. The test (`test_checkGenotypeFile.R:74-79`) is
  `expect_error()` only, so no wording is pinned.
- **Reach:** not from the app. `R/modInput.R:499-503` swallows the error and drops the file without a message; that is
  documented (`R/modInput.R:256-258`) and tested ("degrades gracefully", `test_modInput_qcStudbook.R:698`). Script users see the message.
- **Your ruling:** (a) fix the wording: join the alleles into one list, put the sentence on one line, name the column (no
  effect on which files pass; Effort S); (b) leave it.

### Finding 6 (candidate 6, QB4): `checkLocusMetadata()` counts an empty-string chromosome as present (minor; script-only; docs already say so)

- **Location:** `R/checkLocusMetadata.R:77` (`!is.na(chrom)`); roxygen `:13-15`.
- **Evidence (probe):** `chrom` = `"1"`, `""` gives coverage `full`, `full`. Through the app's reader (`getGenotypes()`, blanks
  read as `NA`) the same file gives `full`, **`partial`**. A script's `read.csv()` on a text chromosome column (`chr1`, blank) keeps the `""`
  and gives `full` (with all-numeric chromosomes `read.csv()` makes the blank `NA`, so it only bites with text labels).
  `computeGenomicROH()` would then treat `""` as a chromosome of its own. No test covers it.
- **Your ruling:** (a) treat an empty or all-space chromosome as missing, as the app's reader already does (one line, one test);
  (b) leave it, since the help page says so.

### Finding 7 (candidate 7, QA10 and QA11): a record with a missing allele becomes the text `"NA/NA"`, which every later number reads as a real genotype (moderate; reachable in the app; docs say the string, not the consequence)

- **Location:** `R/buildMarkerGenotypeMatrix.R:50-55` (`pmin`/`pmax` of an `NA` allele is `NA`, and `paste0(NA, "/", NA)` is
  `"NA/NA"`); roxygen `:15-17, :25-29`.
- **Evidence, in the real module** (the repo's hand-verified fixture, X/Y/Z across 4 loci, `test_modMarkerGenetics.R:137`):

  | Marker Genetics, Heterozygosity table | Ho of X | Ho of Y | Ho of Z | mean He |
  |---|---|---|---|---|
  | the file as the test has it (Y has no `L4` record) | 0.75 | 0.3333 | 0.25 | 0.3993 |
  | the same file plus a `Y,L4` record with blank alleles | 0.75 | **0.25** | 0.25 | **0.4583** |

  The first row equals the test's hand-verified values; the file's blank cells are read as `NA` by `getGenotypes()`
  (`na.strings = c("", "NA")`) and accepted by the checker (a test says so: `test_checkSequenceGenotypeFile.R:164-168`, "a genuine NA allele
  as valid missingness"), then the matrix builder makes them the string `"NA/NA"`, which `markerObservedHeterozygosity()` scores
  homozygous and `markerExpectedHeterozygosity()` counts as an allele named `NA`. Scratch data (4 animals x 6 loci, random alleles, seed 11),
  Y's `L3` blank versus the record deleted: Y's Ho 0.5 vs 0.6; mean He 0.4844 vs 0.4583; `markerKinship()` of Y with X 0.0833 vs
  0.1667, with Z 0.1667 vs 0.25, with W 0.0 vs -0.125; no warning either way. From the code: `computeGenomicROH()` counts `"NA/NA"`
  homozygous (`R/computeGenomicROH.R:157`, `!anyNA(a)` on the split strings), so a blank can extend a run, and
  `markerParentageLikelihood()` splits the same string (`.markerTwoSourceGenotypeProbability`); I did not read `markerFst()`
  and ran none of the three.
  Duplicate id x locus rows overwrite each other, last wins: confirmed (probe), but the app's checker stops on them first
  (`checkSequenceGenotypeFile` error, "duplicate id x locus row(s)"), so only a script that skips the checker is affected, and the
  roxygen says to run it first.
- **Impact:** a typing failure left blank in a marker file is counted as a real homozygote, silently, in the Heterozygosity and
  Kinship Comparison tabs (measured), and by the code's own reading in the F_ROH and candidate-parent numbers (not run).
- **Your ruling:** (a) a record with a missing allele gives `NA` in the matrix, the same as a record that is not there (small;
  files with no blank alleles are unchanged; files with blanks change, in the direction of the "deleted" rows above); (b) reject
  such rows in the checker with a message naming them (a visible stop for files that load today); (c) leave it. Duplicates: leave.
  Rule this one together with finding 1.

### Finding 8 (candidate 8, QA7 and QC6): two documented, internal edge cases (minor; not reachable from the package's own callers)

- **`chooseAlleles()`** (`R/chooseAlleles.R:17-22`): `chooseAlleles(1:4, 1:2)` returns four values with the shorter vector
  recycled (probe). The roxygen says so (`:9-10`). Its one caller, `R/assignAlleles.R:49`, passes the parent's two allele
  vectors, both built from `rep(counter, n)` or an earlier `chooseAlleles()` result, so they have equal length. No test calls
  it directly.
- **`.markerAlleleFrequencyTable()`** (`R/markerAlleleFrequency.R:26-32`): an all-missing locus returns `numeric(0)` (probe); the
  roxygen says so (`:23-24`). Its one caller, `markerParentageLikelihood()`, builds a table per locus but reads a locus only
  where both animals have a genotype (`R/markerParentageLikelihood.R:250-255`), so the empty vector is never read.
- **Your ruling:** (a) leave both (recommended; the pages say so and no package path reaches them); (b) add a length check to
  `chooseAlleles()`.

## Items audited

| Candidate | Slice 6c claim | Today | Reachable from the app? | Finding |
|---|---|---|---|---|
| 1 | He = 1.0 for an all-NA locus (QC7) | still true; help says so | no (becomes 0 via finding 7) | 1 |
| 2 | silent drop of sidecar loci absent from the matrix (QA1) | still true; help says so | yes, 0 warnings (module run) | 2 |
| 3 | `First`/`Second`, substring id (QA2, QA4) | still true; help says so; a partial-match case is new | no (headers are lower-cased first) | 3 |
| 4 | sidecar not reconciled (QB1) | still true; help says so | the app passes no sidecar | 4 |
| 5 | message has no `collapse` | still true; no doc claim | no (the app drops the file silently, documented) | 5 |
| 6 | empty-string chrom counts as present (QB4) | still true; help says so | no (the app's reader makes blanks `NA`) | 6 |
| 7 | `"NA/NA"` and overwrites (QA10, QA11) | still true; help says the string, not the numbers | `"NA/NA"` yes (module run); overwrite no (checker stops) | 7 |
| 8 | recycling, `numeric(0)` (QA7, QC6) | still true; help says so | no | 8 |

Coverage: 8 of 8 candidates, 11 of 11 claims examined. Candidates 2 and 7 were also run through the real module's server;
the other six were run as functions and read in their callers.

## Structural observations

- **Findings 1 and 7 are one cause: the matrix builder makes a missing allele into text.** Everything downstream already
  treats `NA` as missing (`markerObservedHeterozygosity()` returns `NA`, `computeGenomicROH()` ends a run on `NA`), so the
  fix lives at the source, and then finding 1 becomes reachable from the app. Offering "a check in each function" would
  be the wrong shape; one decision about the builder, one about the all-missing locus.
- **Findings 2 and 4 are one cause: the sidecar and the genotype file are compared nowhere both are present.** The
  checker has the sidecar argument but the app never passes it; `computeGenomicROH()` has both and handles one direction. The
  place to report a mismatch is `computeGenomicROH()` (and `markerLdBlock()`), not the checker.
- **The package's own roxygen, rewritten S839 to S841, already tells the truth for 10 of 11 claims.** What the pages
  cannot do is warn a user mid-upload; every moderate finding is a silent number change, not a wrong sentence.
- **The app's reader (`getGenotypes()`, blanks as `NA`) and the app's `fixColumnNames()` close findings 3 and 6 for app
  users;** both stay open only for scripts.
- **Found while checking, not one of the eight:** a separate-files genotype file that fails `checkGenotypeFile()` is
  dropped with no message in the app (`R/modInput.R:499-503`; documented at `:256-258`, tested at
  `test_modInput_qcStudbook.R:698`). Whether the app should say so is a separate question, like the one-file notice S972 built.
  Not examined further here.

## Comparison with slice 6c

| Slice 6c claim (2026-10-01) | 2026-10-13 |
|---|---|
| He = 1.0 for an all-NA locus, inflating `meanHe` (agent's run, not re-run) | confirmed (probe: 1.000, `meanHe` 0.6875); not reachable from the app |
| `fRoh` changes with the matrix's locus set | confirmed, in the function and in the module; no warning |
| `hasGenotype` accepts `First`/`Second` in name checks, then FALSE; substring id | confirmed; plus a partial-match TRUE case |
| sidecar not reconciled | confirmed; the app does not even pass a sidecar |
| `stri_c(..., sep = ", ")` has no `collapse` | confirmed, and worse: repeated sentence, one column named |
| empty-string `chrom` counts as present | confirmed for scripts; the app's reader turns blanks into `NA` |
| missing allele gives `"NA/NA"`; duplicates overwrite | confirmed, and its numeric effect measured in the module |
| `chooseAlleles` recycles; `numeric(0)` for an all-NA locus | confirmed; not reachable from package callers |

## Recommendations

1. **Findings 7 and 1 together (one ruling, Effort S):** rule 7 (a), (b) or (c), and 1 (a) or (b). I would pick (a) for
   both: it changes numbers only for files with a blank allele or an untyped locus, and it is the only finding that moves a
   number a colony manager sees in the tabs today.
2. **Findings 2 and 4 together (one ruling, Effort S to M):** rule (a), (a+), (b) or (c) from finding 2. I would pick (a+),
   a warning plus a notice on the tab that keeps every number, since a console warning does not reach a colony manager;
   (b) is a methods choice for you.
3. **Finding 6 (a), then finding 5 (a):** each a one-function wording or one-line change with a test, no effect on app users
   today. Effort S each.
4. **Findings 3 and 8:** leave, unless you want finding 3 (b)'s tidy of the case tests.
5. Each ruling is its own session. Only findings 1, 2 and 7 can change a calculated number.

## Rulings taken (S976, the same day; the owner took the recommended option each time)

- **Findings 7 and 1:** treat a blank allele as missing (the matrix gives `NA`), and `markerExpectedHeterozygosity()` gives `NA` for
  a locus nobody is typed at. Built in a later session; the two ship together.
- **Findings 2 and 4:** warn, naming the sidecar loci the genotype file lacks, and show a one-line notice above the F_ROH table.
  Every number stays. Built in a later session.
- **Findings 6 and 5 only:** fix the empty-chromosome check and the collision message; leave findings 3 and 8.
- The three build items are in `BACKLOG.md` ("Up Next", just after the docs-audit item). No code was changed in S976.
