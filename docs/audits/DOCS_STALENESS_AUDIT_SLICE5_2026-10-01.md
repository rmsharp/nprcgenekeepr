# Docs staleness audit, slice 5: `vignettes/a2interactive.Rmd` (2026-10-01, S832)

Read-only audit. Nothing in the repo was changed except this report and the session records.

## Audit summary

- **Scope:** `vignettes/a2interactive.Rmd` (1,825 lines, 97 chunks): prose, hand-typed lists, inline R, and what each chunk
  prints. `man/` and `NEWS.Rmd` (the rest of slice 5 in the BACKLOG wording) and the internal docs are **not covered**; they
  are slices 6 onward.
- **Criterion:** does each checkable claim (argument list, default, return fields, described behavior, quoted number, file
  name) still match today's code or output? Read from the implementation and by running the chunks, not from roxygen alone.
- **Method:** four read-only subagents, one per line range (1-660, 661-1160, 1154-1640, 1620-1825); the last also knitted
  the whole vignette into a scratch directory. The session then re-read the cited code for the findings marked **R**.
- **Coverage:** 100% of the file by range, about 226 claims checked. The vignette knits with no chunk error or warning, and
  no function it calls has been removed or renamed. The staleness is in prose that was written for an earlier API and
  inline-R numbers that no longer count what the sentence says.
- **Findings:** 0 critical, **12 moderate, 18 minor** (30).

Check column: **R** = code re-read by this session; **A** = agent ran or counted it, not reproduced here.

## Findings: Moderate

| ID | Location | Claim | Evidence | Fix | Check |
|---|---|---|---|---|---|
| AI1 | `:974-977` | "of the 184 females 156 are included" (harem) | Inline R drops group 1 (`group[-1]`) and counts the 7th element, which is a lone `NA`. Groups hold 29/27/32/33/39/30/1; groups 1-6 hold 190 animals = 184 F + 6 M, so all 184 are placed | Count `1:numGp`: `sum(lengths(haremGrp$group[1:6])) - 6` (184), or say all are placed | A |
| AI2 | `:1016-1019` | "of the 184 females 239 are included" (sex ratio) | 239 is impossible (more than 184). The expression drops group 1 and counts the 7th group, which is the unplaced-candidate pool (103 animals: 27 F, 76 M). Groups 1-6 hold 157 F + 20 M | Use groups `1:numGp`; recompute (157 of 184 females, 20 males) | A |
| AI3 | `:920-930` | "The setting of sexRatio to 0 is ignored in the following call"; "The empty seventh group ... is evidence that all candidates could be placed" | No call follows the sexRatio sentence (the next call is under Harems). Element 7 of `$group` is the **unplaced-candidate pool**, not an empty group: 103 animals in the sexRatio run, one `NA` in the harem run | Delete or rewrite: explain the extra last element; move the `sexRatio = 0` remark next to a call that uses it | A |
| AI4 | `:851-899` | The list of `groupAddAssign` parameters is "the descriptions of the function parameters" | `R/groupAddAssign.R:172-186` has 5 more: `maxCandidates`, `exhaustive`, `maxExhaustiveCandidates`, `exhaustiveTimeLimit`, `ancestryRules`. The list stops at `withKin`; the return items `$score` and `$candidates` are also undescribed | Add the five (the later Ancestry section relies on `ancestryRules`) and the return items, or say the list is abridged | R |
| AI5 | `:680-699` | "The arguments to `reportGV` are all optional except for `ped`", then a 5-argument list | `names(formals(reportGV))` has 15: also `updateProgress` (the chunk at `:702-707` passes it), `breedingTable`, `gestationTable`, `breedingAgeDefault`, `gestationDefault`, `kinshipOverrides`, `twinRelations`, `guCutoff`, `zScoreCutoff`, `axisPriority` | Say the list covers the principal arguments, or add the rest | R |
| AI6 | `:1315` (chunk `listLoops`) | "list the first 10 sets of ids, sires and dams in loops" | `findLoops()` is run on `exampleTree` built from `breederPed` (`qcStudbook` output); the chunk then indexes `examplePedigree`, a different row order (`identical(examplePedigree$id, breederPed$id)` is FALSE). It prints `V49H3Y, 61FUGE, ...`; the animals actually in loops begin `MRC4BF, SZ05LQ, ...` | Select ids with `names(exampleLoops)[unlist(exampleLoops)]` and index `breederPed` | A |
| AI7 | `:1172` | `femaleSires` = "listed as female or hermaphroditic and as a sire" | `R/correctParentSex.R:105`: `!sex %in% c("H","U","M")`; only sex `F` is flagged (the roxygen at `:8-11` says H and U parents are left unchanged). The `maleDams` row is already right | "listed as female and as a sire" | R |
| AI8 | `:453-462`, `:543-546` | `makePedigreeMatingLayout()` returns "a list of three elements" | Four: `nodes`, `edges`, `duplicateToReal`, `isolatedIds` (confirmed by running; the chunk at `:442-451` prints `names(...)` so the output contradicts the prose). "nodes: one row per real animal" also excludes fully isolated animals | "four elements"; add `isolatedIds`; qualify "one row per real animal" | R |
| AI9 | `:550-556` | Under rectilinear, nodes and edges "gain extra `color.background`/`color.border` (nodes) and `color` (edges) columns" | Direct nodes already have `color.background`, direct edges already have `color`. Rectilinear adds only `color.border` to nodes and no edge column | State the one added node column; drop the edge claim | A |
| AI10 | `:623-624` | "Only the validated result is accepted by `makePedigreeMatingLayout`'s `twinRelations`" | `R/makePedigreeDiagramData.R:1621-1626`: "Not validated here; validate with `checkTwinRelations` first." An unvalidated data frame is accepted and yields the same connector rows | "should be validated first; the function does not validate it" | R |
| AI11 | `:317` (footnote 3), `:314-329` | "All animals within the colony have a known birth date"; "only N living animals are in the colony but not in the trimmed pedigree" | After `qcStudbook`, 1,704 animals have no exit date; 1,372 of them have an `NA` birth. The chunk drops every `NA`-birth animal first, so the sentence silently excludes 1,372 living animals and the footnote is contradicted by the data | Correct the footnote; state the exclusion, or drop the filter and recompute | A |
| AI12 | `:142-147` (footnote 1) | Raising `minDamAge` errors "along with the creation of a file `~/lowParentAge.csv`" | `R/qcStudbook.R:323`: `file.path(tempdir(), "lowParentAge.csv")`; the error message prints the path | "`lowParentAge.csv` in the session temp directory (`tempdir()`)" | R |

## Findings: Minor

| ID | Location | Claim | Evidence / fix | Check |
|---|---|---|---|---|
| AI13 | `:53-55` | "install from GitHub" then `install.packages(nprcgenekeepr)` | Unquoted symbol errors; it is also a CRAN-style install. Quote it and fix the sentence (`eval = FALSE`, so the build is unaffected) | A |
| AI14 | `:67-68` | "The help provided by this (`nprcgenekeepr.R`) needs to be more complete and include links to the tutorials" | No such file (`R/nprcgenekeepr-package.R`); a developer to-do inside a user tutorial. Delete or correct | A |
| AI15 | `:82, 88` | "writes `ExamplePedigree.csv` to a place you select" | `R/makeExamplePedigreeFile.R:19-22`: default is `file.path(tempdir(), "examplePedigree.csv")` (lowercase `e`); the location is chosen only by passing `file =`. The vignette itself reads `inst/extdata/examples/ExamplePedigree.csv` | A |
| AI16 | `:260-281` | "N grandparents in both the trimmed and the complete pedigree" | The `all.equal()` that would support "both" is in an `include = FALSE` chunk and never asserted; assert it or soften | A |
| AI17 | `:1303-1308` | Chunk `countLoops` "counts how many loops" with `length(exampleLoops)` | That is the number of animals checked (3,694); animals in loops is `sum(unlist(exampleLoops))` (145); loops is `sum(unlist(nLoops[nLoops > 0L]))` (258). Label the three outputs | A |
| AI18 | `:1296` | `_Example_Pedigree.csv_` | File is `ExamplePedigree.csv` (as at `:88`, `:92`) | A |
| AI19 | `:1293-1294` | "run the following code and select a pedigree as your input file" | The chunk uses the in-memory `breederPed`; no file is selected | A |
| AI20 | `:1329-1331` | Example genotypes are "the same numbers shown in" the colony-manager-guide tables | The article shows its numbers as screenshots, and its candidate-assignment example (sire `Q`, 10 loci) differs from the vignette's (`O`/`C1`/`C2`, 2 loci); `pedA`/`pedB` have no counterpart. Kinship, heterozygosity, exclusion and Fst examples do match. Narrow the claim | A |
| AI21 | `:1362-1364` | `checkMarkerGenotypeFile` "validates the column shape and rejects any locus with more than two distinct alleles" | It also stops on duplicate id x locus rows; `:1631-1633` lists that check as shared, which implies the biallelic one lacks it | A |
| AI22 | `:1563-1569` | An undeclared collision is reported only once everything above is clean | `R/checkCrossCenterMapping.R:60-72`: the second tier is collision **and** conflicting recorded parents; the first tier returns early | A |
| AI23 | `:1171` | "too young on the date of birth of to have been the parent" | Typo: "...of the offspring to have been the parent" | A |
| AI24 | `:835` vs `:894-895` | "sex ratio between 0.5 and 10" vs the quoted parameter doc "0.5 to 20" | `R/groupAddAssign.R:46-47` says 0.5 to 20; make `:835` agree | R |
| AI25 | `:979-983` | "Controlling Sex Ratios" opens with the harem text ("setting `harem` to `TRUE`") | The chunk sets `sexRatio = 9.0` and no harem. Rewrite | A |
| AI26 | `:1037-1050` | "one male and seven females"; "thousands" of possible pairs | WTE53B is not in `trimmedGeneticValue$kinship`, so six pairs come back and `$excluded` is empty. The full call is 96 M x 184 F = 17,664 possible (17,568 returned): tens of thousands | A |
| AI27 | `:1024-1026` | Eligible pairs are "both above `minAge`" | `R/reportMatePairs.R`: `>= minAge` or `NA`. Say "at or above" | A |
| AI28 | `:786-797` | `geom_boxplot()` call contains a pasted `#| fig.alt` block about Old Faithful eruptions | Inert, but nonsense for this plot; remove lines 790-793 (the real alt text is at `:783-784`) | A |
| AI29 | `:907-913` | Candidates are "at least 2 years old" | The chunk also requires `is.na(exit)` (living) and `birth < 2013-01-01`. Add "and still in the colony" | A |
| AI30 | `:1698-1713` | Parent-offspring pairs have `varR` of exactly 0 around `R = 0.5` | The printed subset has one row, M/N, with `R = 0.00`. Cause is the vignette's `smallPed$gen` (M is generation 1 although its sire A has a sire), not `markerRealizedRelatednessVariance`. Compute `gen` with `findGeneration()` as `:636` does | A |

## Not verified

Rendered visNetwork behavior (legend, Export PNG, Select-by-id highlighting); the literature citations (Hill and Weir 2011,
Hedrick 1987, Excoffier and Slatkin 1995, Bhatia 2013, Manichaikul 2010, Nei 1973, others); the hand-typed `summary()`
output compared line by line; whether the Shiny app truly has no loop UI; the "roughly 1.9x" figure at `:419-438`
(derived from a code comment, 3.667/1.973); whether `getPotentialParents` defaults match the prose exactly.

## Structural observations

- The hand-typed **argument lists** (AI4, AI5) are the main drift source: both functions gained arguments after the list was
  written. The same pattern produced the count claims in slice 3. A one-line "see `?fn` for the complete list" would stop
  the recurrence; or derive the list from `formals()` in an inline chunk.
- **Inline R that drops element 1 (`group[-1]`)** (AI1, AI2) was written when `$group` had a different shape. It prints a
  number that reads as a count of placed females but is not; AI2 even prints a value above the number of females.
- Sections written for newer features (Marker Genetics, Ancestry Rules, Aliasing Ids) have no moderate findings
  across about 500 lines (`:1318-1825`), unlike the older Pedigree and Breeding Group sections.

## Items audited

| Range | Status | Findings |
|---|---|---|
| 1-660 (read, focal animals, pyramid, diagram) | Fail | AI8-AI12, AI13-AI16 |
| 661-1160 (GV, breeding groups, mate pairs) | Fail | AI1-AI5, AI24-AI29 |
| 1154-1640 (errors, loops, marker genetics to Fst) | Fail | AI6, AI7, AI17-AI23 |
| 1620-1825 (multiallelic to aliasing) | Pass, one note | AI30 |
| Whole-file knit | Pass | none |

## Recommended next step

One fix session for the 12 moderate findings (strict TDD does not apply to prose; the build equivalent is knitting the
vignette plus `devtools::check()` for the vignette build), then the 18 minor ones in the same pass. Code defects found:
none (AI30 is a data quirk in the vignette's own `smallPed`).
