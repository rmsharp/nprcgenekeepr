# Docs staleness audit, slice 6a: `man/` genetic-value and kinship-calculation pages (2026-10-01, S834)

Read-only audit. Nothing in the repo was changed except this report and the session records.

## Audit summary

- **Scope:** 36 of the 268 `man/` pages, the "genetic value and kinship calculation" topic group (listed under
  Items audited). `man/` is generated from roxygen in `R/`, so a fix goes in the `R/*.R` roxygen block, then
  `devtools::document()`. The other 232 pages are later slices (6b onward); `NEWS.Rmd` is slice 7.
- **Criterion:** does each checkable claim (argument list and defaults, return type and fields, described behavior,
  example runnability, `@seealso` targets, numbers) match today's code? Read from the implementation and by
  running the calls, not from the roxygen alone.
- **Method:** four read-only subagents, nine pages each. This session re-read the source line for the findings marked
  **S** (MB1, MB3-MB6, MC1, MC15, MC18). Every other finding is the agent's own check: **R** = it re-read the code,
  **A** = it ran the call. MA3 and MB14 rest on recall (neither agent could load the `moments` package).
- **Coverage:** 36 of 36 pages. All `@examples` run without error; every `@seealso` target exists.
- **Findings:** 0 critical, **9 moderate, 45 minor** (54). Pages with no finding: calcFE, calcFEFG, calcFG, calcGUSE,
  calcNeSexRatio, calcNeVariance, kinMatrix2LongForm, getGeneticDiversityStats (8).

## Findings: Moderate

| ID | Location | Claim | Evidence | Fix | Check |
|---|---|---|---|---|---|
| MB1 | `R/calculateSexRatio.R:14-19` | `additionalMales`/`additionalFemales`: "Ignored if calculated ratio is 0 or Inf." | Not ignored: 3 males plus `additionalFemales = 2` gives 0.667, not 0; 3 females plus `additionalMales = 1` gives 3, not Inf | Say the additions always count, except the Inf/0/NA short-circuits (no ids and only females added gives Inf; no ids and no additions gives NA) | S, A |
| MB3 | `R/kinship.R`, `chrtype` | An unrecognized-sex individual "gets `NA` kinship with everyone, including their own self-kinship" | True only for a non-founder. A founder of sex "U" gets `NA` only on the diagonal; kinship with other founders stays 0 | Reword for founders vs non-founders, or change the code to match | S, A |
| MB6 | `R/kinshipMatricesToKValues.R` `@return` | "one `kinship` column for each kinship matrix" | Columns are `id_1`, `id_2`, `sim_1` ... `sim_n` (`:108`); the page's own example indexes `paste0("sim_", ...)` | Document the real column names; fix "kinshipMatricies" | S, A |
| MB12 | `R/calcRetention.R:19-20` | "A vector of the mean number of founder alleles retained" | A 1-d named array, one value per founder, a proportion in [0, 1] (lacy1989: A 0.75, B 0.7507), not a count | "mean proportion of simulations in which the founder's allele is retained in descendants" | A |
| MC1 | `R/filterKinMatrix.R:27` | Returns "a numeric matrix ... with named rows and columns" | `kmat[rows, cols]` has no `drop = FALSE`: one matching id returns a bare scalar; output keeps `kmat` order, not `ids` order; absent ids are dropped silently. `reportGV(pop = <one id>)` then errors in `meanKinship` | Add `drop = FALSE` (a code change, owner decision) or document the caveats | S, A |
| MC2 | `R/countKinshipValues.R:6-9` | `kinshipValues` is a "matrix of kinship values" | Needs a data.table/data.frame with `id_1`, `id_2` and one column per simulation (the `kinshipMatricesToKValues()` result); `as.matrix(kv)` errors "incorrect number of dimensions" | "data.table from `kinshipMatricesToKValues()`" | A |
| MC8 | `R/geneDrop.R:61-63`, `R/reportGV.R:28-30`, `R/gvaConvergence.R:70-71` | `updateProgress` "will be called during each iteration" | Called once with `reset = TRUE`, then once per animal (7 animals gave 8 calls), not once per iteration of `n` | "called once at the start and once per animal" | A |
| MC15 | `R/reportGV.R:113-117` (`@examples`) | `qcStudbook(examplePedigree, minParentAge = 2, ...)` | `minParentAge` is deprecated since 2.0.0; the example emits a deprecation warning | `minSireAge = 2, minDamAge = 2` | S, A |
| MC18 | `R/getGVPopulation.R:12-13` | Returns "a logical vector corresponding to the IDs in the vector ... provided in `pop`" | One element per row of `ped`, in `ped` order; ids in `pop` not in `ped` are ignored (ped A,B,C with `pop = c("C","Z")` gives F F T) | "one element per row of `ped`: TRUE if that animal is in `pop`" | S, A |

## Findings: Minor

| ID | Location | Claim and evidence | Check |
|---|---|---|---|
| MA1 | `R/calcA.R:18-19` | `calcA` returns "the number of unique alleles"; it is the count (0-2) of rare alleles per animal per iteration | A |
| MA2 | `R/calcGU.R`, `parent` | "A factor"; `ped1Alleles$parent` is character | A |
| MA3 | `R/calcKurtosis.R` details | Cites `type = 2` in `moments`/`e1071`; `moments::kurtosis` has no `type` argument (recall) | R |
| MA4 | `R/calcKurtosis.R:41-43` | NA-return list omits `na.rm = FALSE` with an NA in `x` | A |
| MA5 | `R/calcGeneDiversity.R:32-33` | Range "[0, 1)"; formula `1 - 1/(2*fg)` gives -Inf for `fg = 0`, 0 only at `fg = 0.5`; realized range [0.5, 1) | A |
| MA6 | `R/calcFGSE.R` details | "now reports as NA": history wording | R |
| MB2 | `R/calculateSexRatio.R:20` | `\value` omits direction (non-males per male) and the Inf/0/NA values | A |
| MB4 | `R/kinship.R`, `sparse` | `Matrix::Diagnol()` typo (the function is `Diagonal`); start matrix is half-identity, not unit; `sparse = TRUE` returns a `dgCMatrix` | S, A |
| MB5 | `R/kinship.R:14` | "a sum of the kinship's for his or her parents"; code at `:216` averages (`/ 2L`) | S |
| MB7 | `R/kinshipMatricesToKValues.R` | "2 + n" reuses `n` (individual count) | R |
| MB8 | `R/kinshipMatricesToKValues.R` | Empty-list error and the same-ID-order requirement undocumented | R |
| MB9 | `R/kinshipMatrixToKValues.R` | Unnamed matrix: ids are generated (A..Z, A1, B1...), not indices | A |
| MB10 | `R/kinshipMatrixToKValues.R` | "data.frame" is a data.table; garbled sentence "In contrast to the kinship matrix. Each ..." | A |
| MB11 | both kValue pages | Duplicated sentence; single-matrix example defines unused `extractKinship`/`extractKValue` | R |
| MB13 | `R/calcRetention.R:7-11` | "req. fields: ... gen": `gen` not needed; missing `population` silently gives all 0 | A |
| MB14 | `R/calcSkewness.R:8-11` | Same `moments` `type = 2` claim as MA3 (recall) | R |
| MC3 | `R/countKinshipValues.R:10-11` | `accummulatedKValueCounts`: omits that id pairs must match in order; counts are added | R |
| MC4 | `R/countKinshipValues.R:70-81` | Example repeats the simulation and defines unused helpers; no comment says the second is accumulated | R |
| MC5 | `R/summarizeKinshipValues.R:4,12` | "imputed" should be "simulated"; one row per id pair; NA pairs dropped; can return a 0x0 data.frame | A |
| MC6 | `R/summarizeKinshipValues.R:9-11` | Typo "containes"; a subset-named list passes validation | R |
| MC7 | `R/meanKinship.R:8-10` | Divisor is the non-NA count, not N (`colMeans(na.rm = TRUE)`) | A |
| MC9 | `R/geneDrop.R:48-50` | Genotype codes must avoid the minted founder codes (1, 2, 3...); "It will be easy to add" in present tense | R |
| MC10 | `R/geneDrop.R:64-70` | `\value` omits `parent` values (sire/dam) and generation ordering | A |
| MC11 | `R/gvaConvergence.R:54-56` | `guThresh` "passed to calcGU / calcA"; only `calcA` is called | R |
| MC12 | `R/gvaConvergence.R:48-49` | `pop` NULL means "all animals"; an existing `ped$population` is used first | A |
| MC13 | `R/gvaConvergence.R:95-98` | `topOverlap`/`rankAgreement` can be NA; `recommendedIter` can be `NA_integer_` | R |
| MC14 | `R/gvaConvergence.R:113-118` | Example `nMax = 200L` silently trims the grid to 25/50/100 | A |
| MC16 | `R/reportGV.R:21-22,49`, `R/getGVPopulation.R:10-11` | `pop` default NULL: same as MC12 | A |
| MC17 | `R/reportGV.R` examples | `guIter = 50` makes `fg`/`fgSE` degenerate and prints `checkFgDegeneracy` warnings | A |
| MC19 | `R/getGVGenotype.R:16-40` | Example is a copy of the `geneDrop` example; only the last 3 lines use `getGVGenotype` | A |
| MC20 | `R/getGVGenotype.R:9-13` | NULL is also returned when `first`/`second` exist but are not numeric; "the NULL" typo | R |
| MD1 | `R/rankSubjects.R:10-13` | "req. colnames: value": never read; elements are matched by list name | R, A |
| MD2 | `R/rankSubjects.R:11-13` | "gu > 10%", "mk < 0.25": really `guCutoff` and a mean-kinship z-score `<= zScoreCutoff` (same in `reportGV`) | R |
| MD3 | `R/rankSubjects.R:7-8` | Ranks are cumulative across tiers; `noParentage` gets `NA` rank; three value labels, not two | A |
| MD4 | `R/rankSubjects.R:15` | Return note: empty elements come back unchanged | R |
| MD5 | `R/makeGeneticSummaryTable.R:6-8` | Table also has Skewness and Kurtosis columns | A |
| MD6 | `R/alleleFreq.R:69-70` | `alleles` "integer vector" (example is double); returned `allele` column is a factor | A |
| MD7 | `R/alleleFreq.R:65-66` | `ids` must be the same length as `alleles`; never demonstrated | R |
| MD8 | `R/makeSimPed.R:192` | Returns the full input as a data.table, not "id, sire, and dam" | A |
| MD9 | `R/makeSimPed.R:19-20` | `verbose` prints only when a parent cannot be imputed for lack of representatives | R |
| MD10 | `R/createSimKinships.R:21-23` | "list of `n` lists"; each element is a kinship matrix | A |
| MD11 | `R/cumulateSimKinships.R:73-77` | "is generated", "forth"; no `verbose` argument unlike siblings | A |
| MD12 | `R/makeRelationClassesTable.R:11-14` | Columns are `Relationship Class`/`Frequency`; "Self" dropped; zero-count classes omitted | A |
| MD13 | `R/makeRelationClassesTable.R:6` | Description is the fragment "From Relations" | R |
| MD14 | `R/makeFounderStatsTable.R:6-8` | Lists male before female (table has Female first); NULL input returns a placeholder paragraph | A |

## Structural observations

- **Return-shape claims drift most** (MB6, MB10, MB12, MC1, MC18, MD8, MD10, MD12): eight findings, four of them
  moderate (MB6, MB12, MC1, MC18), say a return is something it is not (a `kinship` column, a data.frame, a matrix,
  a list of lists, a count instead of a proportion).
- **Copy-pasted roxygen** carries one error to several pages (MC8 in three, MC12/MC16 in three, MD2 in two,
  MA3/MB14 in two). Fix the shared sentence everywhere in one pass.
- **`@examples` that run but mislead** (MC15, MC17, MC4, MB11, MC19): none errors; two emit warnings.
- **Code-change candidates, not doc fixes (owner decision, strict TDD):** MC1 (`drop = FALSE` in `filterKinMatrix`),
  MB3 (founder of unknown sex: is `NA` self-kinship with 0 elsewhere intended?), MA5/MC13 (unvalidated inputs).
- **Reference pages:** `calcNeSexRatio`, `calcNeVariance`, `kinMatrix2LongForm` and `getGeneticDiversityStats` match
  their code in every checked claim.

## Items audited

| Page | Findings |
|---|---|
| calcA | MA1 |
| calcFE, calcFEFG, calcFG, calcGUSE | none |
| calcFGSE | MA6 |
| calcGU | MA2 |
| calcGeneDiversity | MA5 |
| calcKurtosis | MA3, MA4 |
| calcRetention | MB12, MB13 |
| calcNeSexRatio, calcNeVariance, kinMatrix2LongForm | none |
| calculateSexRatio | MB1, MB2 |
| calcSkewness | MB14 |
| kinship | MB3, MB4, MB5 |
| kinshipMatrixToKValues | MB9, MB10, MB11 |
| kinshipMatricesToKValues | MB6, MB7, MB8, MB11 |
| filterKinMatrix | MC1 |
| countKinshipValues | MC2, MC3, MC4 |
| summarizeKinshipValues | MC5, MC6 |
| meanKinship | MC7 |
| geneDrop | MC8, MC9, MC10 |
| gvaConvergence | MC11-MC14 |
| reportGV | MC8, MC15-MC17 |
| getGVGenotype | MC19, MC20 |
| getGVPopulation | MC16, MC18 |
| rankSubjects | MD1-MD4 |
| makeGeneticSummaryTable | MD5 |
| alleleFreq | MD6, MD7 |
| makeSimPed | MD8, MD9 |
| createSimKinships | MD9, MD10 |
| cumulateSimKinships | MD11 |
| makeRelationClassesTable | MD12, MD13 |
| makeFounderStatsTable | MD14 |
| getGeneticDiversityStats | none |

## Comparison with prior audits

| Metric | Slice 5 (vignette) | Slice 6a (36 man pages) |
|---|---|---|
| Moderate / minor | 12 / 18 | 9 / 45 |
| Findings per unit | 30 in 1 file | 54 in 36 pages (1.5 per page) |
| Clean units | n/a | 8 of 36 |

## Recommendations

1. Fix the 54 findings in the `R/*.R` roxygen, then `devtools::document()`, as the next session (the S823 and S833 pattern).
   Do the shared sentences (MC8, MC12/MC16, MD2, MA3/MB14) across every page at once.
2. Decide MC1 and MB3 as code questions before touching their docs.
3. Slice 6b: the next topic group of `man/` (the remaining 232 pages).
