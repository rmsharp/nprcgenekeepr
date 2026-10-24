# Performance and Memory Campaign: Plan

**Session:** S1050, 2026-10-24. A planning session: nothing under `R/` or `tests/` changed.
**Status:** DRAFT for owner approval of the plan and of decisions D1 to D4 (section 6).
**Owner's direction (S1050):** "As an architect and engineer examine the code to refactor the
code with the primary goals of smaller memory footprint and faster processing of time intensive
work", then "This is expected to take multiple sessions with planning being very important."
**Workstream:** `methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` (performance improvements to
an existing system), run as a campaign in the shape of `methodology/workstreams/TEMPLATE_CAMPAIGN.md`:
this planning session, one session per phase (section 7), then a consolidation session.
**Code measured:** HEAD `4738c7a37` (the `R/` and `tests/` trees are those of `520bd5dc8`).

---

## 1. Summary

### What is slow, in the order a user meets it

| # | What the user does | Today (measured) | Main cause | After the campaign |
|---|---|---|---|---|
| 1 | Genetic Value analysis on the shipped example (1,000 iterations, threshold 4: the app's defaults; the analysis set is 708 animals, 332 living) | about 3.5 s (3.38 to 3.62 s in four runs) | genome uniqueness: `calcGU()` 1.44 s plus `calcGUSE()` 1.49 s, the same rare-allele count built twice, each with a `tapply()` per iteration | about 0.35 s (estimate) |
| 1b | the same, every one of the example's 3,694 animals in the population | about 41 s (sum of its stages) | the same two calls, 19.7 s and 18.1 s | about 2.2 s (estimate) |
| 1c | the same, a synthetic 10,000-animal colony (analysis set 6,090, 2,981 living) | about 36 s (sum of its stages) | the same two calls, 14.2 s and 14.3 s, then the gene drop, 3.4 s | about 3.9 s (estimate) |
| 2 | Summary Statistics, "Download relationships" or "Download relationship classes", on the example | never finishes in practice: 600 animals take 65 s and the time grows about 10 times per doubling; the example has 3,694 animals (6,824,665 pairs) | the result grows one value at a time (`r <- c(r, relation)`), over a per-pair R loop | preallocating alone: 600 animals 70.4 s to 10.6 s (measured, identical result); the vectorized table: seconds (estimate) |
| 3 | Breeding Groups at the 1,000 trials `groupAddAssign()`'s help recommends (example, 280 candidates, 6 groups) | 23.6 s (harems 26.0 s); the app's default is 10 trials, 0.35 s | `setdiff()` on character vectors for every placement and every group: 78% of the time | 5 to 20 times faster (estimate; not prototyped) |
| 4 | Pedigree Diagram tab at 708 animals (direct style; the app's cap is 750) | 13.9 s | one dense quadratic-program solve: 85% | the solve 11.6 s to 3.0 s with the same solver's compact form (measured, identical positions); the tab about 5 s (estimate) |
| 5 | Build Earlier Snapshots (jmac example, 3 dates, 1,000 iterations) | 10.1 s, 3.4 s a date | each date is a whole `reportGV()`, so it inherits rows 1 to 1c | 4 to 8 times faster (estimate) |
| 6 | The iteration convergence check, `gvaConvergence()` at its default `nMax = 3000`, on the example | 4.86 s | one rare-allele count over 3,000 iterations | about 0.7 s (estimate) |

"Estimate" means derived from the measured times of each stage and of the prototypes in Appendix
B; no estimate is a measurement of the finished code. Phase 0 re-measures every row; each later
phase measures its own row before and after.

### What uses the most memory

- **The app keeps one full kinship matrix of the whole current pedigree for the whole session**
  (`sharedKinshipMatrix`, `R/appServer.R:353-367`), handed to six tabs. For the example's 3,694
  animals it is 104.6 MB. At 8 bytes a cell it is about 800 MB for 10,000 animals and 3.2 GB for
  20,000 (arithmetic, n² x 8 B). On the example 92.7% of its cells are 0, so stored sparsely it
  would be 11.9 MB; on the synthetic closed colony 54.5% are 0 (97.4 MB sparse against 283.7 MB).
- **`kinship()` needs twice the size of its result while it runs:** 568 MB for a 284 MB matrix at
  6,090 animals. It builds an (n+1) x (n+1) matrix (the extra row and column stand for unknown
  parents) and copies it once more to drop them (`R/kinship.R:145-148,231`).
- **Passing peaks far above the result:** `geneDrop()` peaks at 146 MB to return 5.6 MB (example);
  `kinMatrix2LongForm()` at 1,007 MB to return 313 MB (example, all animals); `calcFEFG()` and
  `calcFGSE()` at 446 MB each at 6,090 animals to return a few numbers.

### How

Twelve phases after this one (section 7), one session each, strict TDD (`CLAUDE.md`), each
changing one hotspot. **Every change keeps the exported functions' arguments and results, and
gives exactly the same numbers as today for the same random seed** (decisions D1 and D3). The two
prototypes written this session already do: the faster rare-allele count and the faster gene drop
are `identical()` to today's functions on 3 inputs x 4 settings and on the genotype path, integer
and double codes (Appendix B, section 3.3).

### What the owner decides now

D1 exact results, D2 plain R first, D3 exported functions unchanged, D4 where the speed and
memory budgets live. Each has a recommendation in section 6. Four later decisions (D5 to D8) are
asked in the phase that needs them, never now.

---

## 2. Method and surface

- **Machine:** Apple M2 Max, 96 GB, macOS 27.0; R 4.6.1 (2026-06-24) with R's reference BLAS
  (`libRblas`), single-threaded; load average 3 to 4 from other work during the runs.
- **Time:** elapsed seconds of one call (`proc.time()`).
- **Memory:** `gc(reset = TRUE)` before the call, then `gc()`'s "max used" Mb column after it,
  minus the memory in use before. R 4.6 adds a "limit (Mb)" column, so the column is found by name.
  This is a high-water mark sampled at garbage collections: a lower bound, and noisy. The same
  call peaked at 578 MB in one run and 300 MB in another (`geneDrop()`, 6,090 animals). So every
  before/after comparison in this plan pairs two calls from the same run, and Phase 0 measures
  the spread before any memory gate is declared.
- **Result size:** `object.size()` of the returned value.
- **Inputs:**
  - "example (app trim)": `examplePedigree` through the app's own path:
    `qcStudbook(minSireAge = 2, minDamAge = 2)`, the living animals as the population
    (`setPopulation()`, as `R/modPedigree.R:374` does), `findPedigreeNumber()`, then
    `trimToAnalysisPopulation()` (`R/modGeneticValue.R:313`). 708 rows, 332 probands, 8 generations.
  - "example (all 3694)": the same QC'd pedigree, untrimmed, every animal in the population.
  - "synthetic 10000": a generated colony (Appendix A, `synthColony()`). It has 600 founders,
    births over 45 years, harem breeding (1 male in 6 breeds), parents 3.5 to 20 years older than
    their offspring, and deaths at 1 to 25 years. After QC and the app's trim: 6,090 rows, 2,981
    living, 9 generations. **Synthetic, and labeled so every time it is cited:** no real studbook
    above 3,694 rows is in the repository (`BACKLOG.md:51`, BLOCKED).
  - "jmac": `inst/extdata/examples/deidentified_jmac_ped.csv`, read with
    `na.strings = c("", "NA")` and `qcStudbook(minSireAge = 0, minDamAge = 0)`. That is 2,590
    animals, 4,055 rows after QC adds stand-in parents.
- **What this surface cannot show:** Windows or Linux timings, CRAN's or GitHub's runners (shared
  machines whose speed varies), a real colony above 3,694 animals, or the app's memory as a
  browser session drives it. The last one is Phase 0's job: an app-level measurement through
  `shinytest2`.
- **Scratch only:** the measuring scripts ran from the session's scratch folder and are not
  committed; Appendices A and B hold the code that matters, so Phase 0 can rebuild them.

---

## 3. Measured baselines

### 3.1 The Genetic Value path, stage by stage (1,000 iterations, threshold 4, `byID = TRUE`)

| Stage | example (app trim) | example (all 3694) | synthetic 10000 |
|---|---|---|---|
| `kinship()` of the analysis pedigree | 0.01 s, peak 21 MB, result 3.9 MB | 0.50 s, 234 MB, 104.6 MB | 1.56 s, 568 MB, 283.7 MB |
| `filterKinMatrix()` to the probands | 0.00 s, result 0.9 MB | 0.02 s, 104.6 MB | 0.02 s, 68.2 MB |
| `geneDrop()` | 0.13 s, peak 147 MB, result 5.6 MB | 1.38 s, 338 MB, 28.6 MB | 3.44 s, 578 MB, 47.1 MB |
| `calcGU()` | **1.44 s**, 142 MB | **19.70 s**, 277 MB | **14.24 s**, 262 MB |
| `calcGUSE()` | **1.49 s**, 147 MB | **18.06 s**, 377 MB | **14.34 s**, 327 MB |
| `calcFEFG()` | 0.18 s, 70 MB | 0.67 s, 309 MB | 1.06 s, 446 MB |
| `calcFGSE()` | 0.08 s, 89 MB | 0.68 s, 307 MB | 1.10 s, 446 MB |
| `offspringCounts()` | 0.00 s | 0.01 s | 0.01 s |
| **`reportGV()` whole** | **about 3.5 s** (3.38 to 3.62 s, four runs), peak 161 MB | about 41 s (sum) | about 36 s (sum) |

`qcStudbook()` took 0.06 to 1.21 s and `findPedigreeNumber()` 0.11 to 0.20 s on these inputs:
not targets.

### 3.2 The other time-intensive work

| Work | Input | Time | Peak | Note |
|---|---|---|---|---|
| `convertRelationships()` | first 150 / 300 / 600 example animals (11,325 / 45,150 / 180,300 pairs) | 1.39 s / 6.13 s / 64.95 s | about 270 MB | about 10x per doubling of animals |
| `kinMatrix2LongForm()` | example, all 3,694 (13,645,636 rows) | 1.52 s | 1,007 MB | result 312.7 MB |
| `kinMatrix2LongForm(removeDups = TRUE)` | the same (6,824,665 rows) | 0.77 s | 929 MB | result 182.6 MB |
| `groupAddAssign()`, 6 groups | example, 280 candidates, 704-row trimmed pedigree | 10 trials 0.35 s; 1,000 trials 23.55 s | about 175 MB | harems: 0.50 s and 25.98 s |
| `makePedigreeMatingLayout()` | rhesus fixture, 375 animals | direct 2.48 s; rectilinear 3.33 s | about 155 MB | |
| `makePedigreeMatingLayout()`, direct | example (app trim), 708 animals | 13.90 s | 223 MB | 1 QP: 1,489 variables, 1,480 constraints |
| `backfillColonySnapshots()` | jmac, 3 dates x 1,000 iterations | 10.14 s | 186 MB | the app's cost line says "about 4 seconds" a date (`R/modSnapshotTrends.R:470`) |
| `gvaConvergence(nMax = 3000)` | example (app trim) | 4.86 s | 185 MB | |
| `kinship(sparse = TRUE)` | example (app trim) / (all 3694) | 1.17 s / 44.89 s | 157 / 276 MB | result 1.5 / 11.9 MB; dense 0.01 / 0.53 s, 3.9 / 104.6 MB; same values |

Profiles (`Rprof`):
- **`groupAddAssign()`, 200 trials:** `setdiff` 78.3% of the time,
  `removeSelectedAnimalFromAvailableAnimals` 66.3%, `tryCatch` 26.2% (R 4.6's `setdiff()` calls
  `tryCatch(x[0L])` twice per call, inside `.set_ops_need_as_vector()`), `unique` 20.2%.
- **`makePedigreeMatingLayout()`, 708 animals:** `.solveJointQP` 96.5%,
  `quadprog::solve.QP` 85.2%, `%*%` 9.1%.
- **`calcFEFG()` + `calcFGSE()`, synthetic 10000:** founder contributions 0.74 s for the two calls
  (327 founders), retention `apply()` + `%in%` about 1.0 s.

### 3.3 What the prototypes measured (Appendix B; each pair from the same run)

| Function | Input | Today | Prototype | `identical()` |
|---|---|---|---|---|
| `calcA()`, threshold 4, `byID = TRUE` (the report's setting) | example (app trim) | 1.41 s, 136 MB | 0.08 s, 60 MB | TRUE |
| the same | example (all 3694) | 18.03 s, 237 MB | 0.77 s, 210 MB | TRUE |
| the same | synthetic 10000 | 14.24 s, 219 MB | 0.63 s, 202 MB | TRUE |
| `calcA()`, thresholds 1 and 4, `byID` TRUE and FALSE | all three inputs (12 cases) | 0.62 to 18.12 s | 0.08 to 0.88 s | TRUE in all 12 |
| `geneDrop()` | example (app trim) / (all 3694) / synthetic 10000 | 0.13 / 1.77 / 3.50 s | 0.05 / 0.23 / 0.61 s | TRUE / TRUE / TRUE |
| `geneDrop()` peak | the same | 146 / 269 / 300 MB | 89 / 169 / 199 MB | |
| `geneDrop()` with genotypes | `pedWithGenotype`, 200 iterations, codes stored as double (as shipped) and as integer | | | TRUE / TRUE |
| `convertRelationships()`, result preallocated | first 300 / 600 example animals | 6.44 / 70.43 s | 2.73 / 10.61 s | TRUE / TRUE |
| `quadprog::solve.QP.compact()` for the diagram's QP | example (app trim), 708 animals | 11.60 s | 3.00 s | TRUE (positions) |

---

## 4. Root causes, hotspot by hotspot

**H1. Genome uniqueness (the biggest cost).** For every iteration column, `calcA()`
(`R/calcA.R:38-51`) calls `alleleFreq()`, which runs `tapply(alleles, as.factor(ids), unique)`
(`R/alleleFreq.R:28`): a factor of 2n ids rebuilt, with sorting, 1,000 times. `table()` follows
(`:36`), then `tapply(a, ids, sum)`. `apply()` over the data frame first copies it to a matrix.
The whole count is built twice per report, once by `calcGU()` (`R/calcGU.R:97`) and once by
`calcGUSE()` (`R/calcGUSE.R:58`), through `R/reportGV.R:265,273`; the comment at
`R/reportGV.R:271-272` already names this duplication. `gvaConvergence()` builds it once over
3,000 columns (`R/gvaConvergence.R:209`).
*Fix shape:* per column, `match()` the alleles to their distinct values, `tabulate()` the codes
(minus each animal's homozygous copy when `byID`), and look up rare flags by position. That is
one pass and no factors; built once per report.

**H2. The gene drop.** `geneDrop()` keeps alleles in a named list grown one animal at a time
(`R/geneDrop.R:131`), which `assignAlleles()` copies on every call. It looks each animal's
parents up by row name in a data frame (`:132`), scans the genotype table per animal (`:135`),
builds a data frame with 2n columns and transposes it (`:149`), and grows `id` and `parent` with
`c()` in a loop (`:156`).
*Fix shape:* one K x 2n matrix, parents found by position, the same random draws in the same
order, one conversion at the end.

**H3. The relationship table.** `convertRelationships()` grows its result with
`r <- c(r, relation)` (`R/convertRelationships.R:101`). That is quadratic in the number of pairs,
inside a per-pair R loop (`:52-103`) with list-name lookups into an n-element CEPH list. Its
input comes from `kinMatrix2LongForm()` (`:48`).
*Fix shape:* preallocate (measured, section 3.3), then classify every pair with vector
comparisons in the same rule order.

**H4. Group formation.** Each placement runs `setdiff()` on every group's character vector of
available animals (`R/removeSelectedAnimalFromAvailableAnimals.R:15`) and on the chosen
animal's relatives (`R/fillGroupMembers.R:84`). The same helpers run in
`R/fillGroupMembersWithSexRatio.R:108,117,121,128-129`. One trial therefore makes about groups x
candidates `setdiff()` calls, each over up to all the candidates.
*Fix shape:* availability as a logical candidates x groups matrix and kin as integer indices.
The draws still see the same ordered character vectors, so the same animals are drawn.

**H5. The diagram's solve.** Each separation constraint is a dense n-long column
(`R/makePedigreeDiagramData.R:1458`) holding two nonzero values. `Dmat` is `t(pmat) %*% pmat`
(`:1578`), and `quadprog::solve.QP()` (`:1580`) is dense, so its work grows with the cube of the
node count.
*Fix shape:* `quadprog::solve.QP.compact()` with the constraints' two nonzeros per column, and
`crossprod(pmat)`. The growth stays cubic, so issue #138 stays separate.

**H6. Kinship memory.** `kinship()` allocates (n+1) x (n+1) (`R/kinship.R:145-148`) and copies it
to n x n at the end (`:231`), so its peak is twice its result. `reportGV()` and
`gvaConvergence()` compute the whole analysis pedigree's matrix, then keep only the probands'
(`R/reportGV.R:209-213`, `R/gvaConvergence.R:156`). The app computes and caches the whole current
pedigree's matrix (`R/appServer.R:353-367`) for six consumers:
- Summary Statistics (`:378`; `R/modSummaryStats.R:384`, the kinship CSV at `:840-843`, the
  relationship table at `:427`)
- Breeding Groups (`:426`; `R/modBreedingGroups.R:361`, filtered to candidates at
  `R/groupAddAssign.R:206`)
- Genetic Diversity (`:453`)
- Marker Genetics (`:466`)
- Mate Pair (`:481`; `R/modMatePair.R:392`)

The diagram builds a full matrix only to read each mating pair's consanguinity
(`R/makePedigreeDiagramData.R:1816-1825`; at most 750 animals, about 4.5 MB, so low priority).

**H7. Long forms.** `kinMatrix2LongForm()` builds its m² rows through `as.data.frame()` and
`stack()` (`R/kinMatrix2LongForm.R:33-34`): 1,007 MB peak for a 313 MB result.
`getAnimalsWithHighKinship()` builds the whole long form only to keep the pairs above a threshold
(`R/getAnimalsWithHighKinship.R:47`).

**H8. Founder statistics.** `calcFounderContributions()` updates each descendant's row by name:
`d[ego, ] <- (d[sire, ] + d[dam, ]) / 2L` (`R/calcFounderContributions.R:61`), three name
lookups per animal. It runs twice per report, from `R/calcFEFG.R:70` and `R/calcFGSE.R:63`. The
retention matrix is also built twice, by `apply()` + `%in%` per iteration (`R/calcRetention.R:45`,
`R/calcFGSE.R:77`).

**H9. The snapshot backfill and the convergence check** run whole analyses per date or over
3,000 iterations, so they inherit H1, H2 and H8. The app's cost sentence
(`R/modSnapshotTrends.R:457,470`) will be wrong once those are fixed.

**H10. A second gene drop** runs when any animal has genotype codes (`R/reportGV.R:306-311`, S975:
founder genome equivalents need a drop that ignores the codes, while `gu` keeps its random
numbers). It is needed as designed and gets cheaper with H2. Fusing the two drops would change
the random stream (D1), so it is not proposed.

---

## 5. Design principles and interface contracts

1. **Exact equivalence** (D1). Each phase proves `identical()` against a frozen copy of
   today's function, on a grid of inputs and seeds (section 5.1).
2. **The public interface does not move** (D3). The 20 exported functions in scope keep their
   arguments, defaults, messages, warnings and results. The speed lives in internal helpers they
   call ("deep modules": `ARCHITECTURE_WORKSTREAM.md` §Refactor Heuristics).
3. **One hotspot per session**, with checkpoint commits under the 5-file cap
   (`methodology/SAFEGUARDS.md` §Blast Radius Limits).
4. **Measure before and after on the same harness** (Phase 0), on the same machine, in the
   same run.
5. **Gates, not rows** (`SESSION_RUNNER.md` §3C). Each phase that lowers a number declares or
   tightens a budget (section 5.2).

**New internal helpers** (names are proposals; each phase may rename before RED, never after):

| Helper | Phase | Input | Output (contract) | Errors |
|---|---|---|---|---|
| `rareAlleleCounts(alleles, threshold, byID)` | 1 | `geneDrop()`'s data frame (columns V1..VK, `id`, `parent`) | integer matrix: rows `levels(factor(alleles$id))`, columns V1..VK, each cell the number (0 to 2) of that animal's alleles that are rare in that iteration. Exactly `calcA()`'s result today, dimnames included | none of its own; empty and one-animal input as `calcA()` (S925) |
| `guFromRare(rare, iterations)`, `guSEFromRare(rare, iterations)` | 1 | the matrix above | the `gu` and `guSE` data frames `calcGU()` and `calcGUSE()` return today | |
| (inside `geneDrop()`) a K x 2n matrix | 2 | as `geneDrop()` | `geneDrop()`'s data frame, unchanged | the same messages (`R/geneDrop.R:97-106`, "sire and dam must have had alleles assigned: logic error") |
| `founderContributionMatrix()`, `retentionMatrix()` | 5 | the coerced pedigree; the alleles | the matrices `calcFounderContributions()` and `calcRetention()`/`calcFGSE()` build today | the partial-parentage stop, unchanged |
| `highKinshipPairs(kmat, threshold)` | 6 | a kinship matrix | the pairs `filterThreshold(kinMatrix2LongForm(kmat))` keeps today, same row order | |

### 5.1 The exactness tests (the faithful-verification contract)

- Before a phase changes function `f`, a verbatim copy of today's `f`, and of any helper it
  changes, goes in `tests/testthat/helper-perfReference.R` as `fReference()`. Copying the
  pre-campaign code from git (`git show 520bd5dc8:R/<file>`) keeps the oracle honest.
- The equivalence tests compare the new code with the reference using `identical()`. Inputs:
  `lacy1989Ped`, `qcPed`, `pedWithGenotype` (double codes as shipped and integer copies), the
  example's app-trimmed analysis set, and a one-animal and a zero-animal case where the function
  accepts them. Seeds 1, 7 and 2026. Settings: each function's own arguments (thresholds 1 and
  4, `byID` TRUE and FALSE, `pop` subsets, harem and sex-ratio modes).
- **RED** is twofold. The equivalence tests call the new internal helper by its new name
  (`nprcgenekeepr:::rareAlleleCounts()`), which does not exist yet, so they fail. The opt-in
  budget test (D4) fails on today's code by a wide margin, for example 18 s against a 4 s
  ceiling.
- **Existing tests pin today's behavior and must pass unchanged.** Three of them reach inside the
  functions this campaign changes:
  - `tests/testthat/test_notifyProgress.R:195-209` pins exactly 1 + n `notifyProgress()` calls
    from `geneDrop()`, and `:163-176` one per pair from `convertRelationships()`.
  - `tests/testthat/test_reportGV.R:871` mocks `kinship` by name.
  - `tests/testthat/helper-reorderedSolveQP.R` mocks `quadprog::solve.QP`.

  Each phase greps `mocked_bindings|stub(` for its functions before GREEN.
- **Mutation check** (as S1049 did): a deliberately broken copy of the new helper must make the
  equivalence tests fail; restore the file from saved bytes, never `git checkout`.

### 5.2 Budgets

- **Opt-in budget tests** (D4): `tests/testthat/test_perfBudget_<area>.R`, skipped unless
  `NPRC_RUN_PERF=true` and on CRAN. Each takes the median of 3 runs, has at least 3x headroom
  over the new time, and reads `uptime` first (the two existing wall-clock benchmarks fail under
  desktop load: `tests/testthat/test_markerKinship.R:165-178`,
  `tests/testthat/test_markerParentageLikelihood.R:635-648`).
- **Ratchet gates** in `methodology/.quality-gates.json`: one command per scenario
  (`Rscript tools/perf/run.R <scenario>`, printing `PEAK_MB=` and `SECONDS=`), with
  `extract` regexes. They are declared at today's values in Phase 0 (a ratchet starts where the
  project is) and tightened by each phase. Memory gates come first; a time gate only where Phase
  0 shows a run-to-run spread under about 20%.

---

## 6. Decisions for the owner

**Now, to approve the plan:**

- **D1. Exact results.** *Recommended:* every change must give exactly today's numbers for the
  same inputs and random seed. A change that would alter the random stream (for example one
  random draw for all animals at once) becomes a separate item the owner approves, never part of a
  phase. *Consequence:* a few larger speedups are off the table; the measured gains in section 3.3
  do not need them. *Alternative:* allow results that are statistically equivalent but not
  identical. That gains more speed, but the existing pinned tests would have to change and every
  comparison would need a statistical tolerance.
- **D2. Plain R first.** *Recommended:* no compiled code (C++ through Rcpp) in this campaign;
  revisit at Phase 11 with the measured hotspots that remain. *Consequence:* no new build toolchain
  for anyone installing from source on Windows or macOS, and no compiled-code CRAN checks; the
  ceiling is lower. *Alternative:* allow Rcpp now, for the gene drop and kinship loops especially.
- **D3. Exported functions unchanged.** *Recommended:* the 20 exported functions in scope keep
  their arguments and results; the fast paths are internal helpers. *Consequence:* some memory is
  left on the table (for example `geneDrop()` still returns a data frame with one column per
  iteration), but no script that calls the package breaks. *Alternative:* change some results
  (for example `geneDrop()` returning a matrix), with deprecation notes and a NEWS entry.
- **D4. Where the budgets live.** *Recommended:* speed and memory budgets as opt-in tests
  (`NPRC_RUN_PERF=true`, like the browser tier's `NPRC_RUN_E2E`), plus ratchet gates for memory
  peaks; the exactness tests run in the normal suite. *Consequence:* the normal suite does not
  become flaky under desktop load; budgets are checked when someone runs them or the ratchet.
  *Alternative:* budgets in the normal suite, which is simpler but flaky.

**Later, each in the phase that needs it:**

- **D5 (Phase 8). How the app holds kinship.** The options:
  - (a) as today, one dense full-pedigree matrix;
  - (b) one sparse full matrix, with dense pieces made when a tab asks;
  - (c) each tab computes kinship only for the animals it uses, from their ancestors (the same
    values, because a pair's kinship depends only on its ancestors);
  - (d) a mix.

  Measured inputs: the example is 7.3% nonzero, the synthetic colony 45.5%. A naive dense-to-
  sparse conversion briefly took 1,415 MB at 6,090 animals.
- **D6 (Phase 10). Parallel dates for Build Earlier Snapshots.** Dates are independent. But
  fork-based parallelism does not exist on Windows, and per-worker random streams change the
  results unless each date is seeded on its own. *Recommended:* no, unless Phase 10's
  re-measurement still shows minutes.
- **D7 (after Phase 4). Breeding Groups' default of 10 trials** (`R/modBreedingGroups.R:125`)
  against the help's "should be >= 1000". Raising it changes the groups found (a better search),
  so it is its own decision and its own session.
- **D8 (Phase 3, only if needed). The relationship download's scope:** all pairs (6.8 million
  rows for the example, today's behavior) or related pairs only. Asked only if the vectorized
  table is still too slow or too large.

---

## 7. Phases

The order: Phase 0 comes first because nothing can be claimed without it. Phases 1 and 2 are the
app's main analysis and the largest measured gain. Phase 3 is a download that does not finish at
the example's size. Phase 4 makes the recommended 1,000 trials practical, and Phase 5 completes
the analysis path. Phases 6, 8 and 9 cover memory and Phase 7 the diagram's speed. Phase 10 is
follow-through and Phase 11 consolidation.

Dependencies: Phase 0 comes before all. Phases 1, 2 and 5 come before 10. Phase 6 comes before 9,
and 8 before 9. Phases 3, 4 and 7 are independent and can move if the owner prefers.

Every phase uses the build-equivalent in `CLAUDE.md` "Build / Test / Verify": the clean
regression read (`sum(failed)` and `sum(error)`, unfiltered), `lintr::lint_package()` with the
package loaded, and `devtools::check()`. It also runs `python3 methodology/quality_ratchet.py
--run` and cites its summary line in the receipt. Every phase is **one session: close out when
done.**

**Every phase's DONE includes**, besides its own items below:
1. its equivalence tests pass (section 5.1);
2. its opt-in budget test passes with at least 3x headroom (section 5.2);
3. the full suite gives 0 failed and 0 errors, lint gives 0, and `devtools::check()` is clean;
4. the harness re-measures the phase's rows of section 3, and its gate is tightened.

**Surfaces, and what each cannot enforce.**
- *Exactness* is shown by testthat on this Mac and on CI's R-CMD-check matrix (macOS, Windows,
  Ubuntu). Integer work (Phases 1, 2, 4) is the same on every platform. Double arithmetic in
  the same order (Phases 5, 6) is the same under IEEE rules. A different BLAS routine (Phase
  7's `crossprod()`) can differ by platform, so only CI can show that one.
- *Speed and memory* are shown on this Mac only (D4). CI's shared runners and Windows cannot
  show them.
- *A tab still working* (Phases 3, 4, 7, 9) is shown by the browser tier
  (`NPRC_RUN_E2E=true`, the nightly `shinytest2` job). Unit tests cannot show it.

### Phase 0. The measuring harness, the baselines and the gates (no package behavior change)

- **Goal:** a committed, repeatable harness that reproduces section 3, plus the app's memory
  during a scripted browser session, plus gates declared at today's values.
- **Files:**
  - `tools/perf/harness.R`: `measure()`, `synthColony()`, `appAnalysisPed()`, the stage runner
    (Appendix A).
  - `tools/perf/run.R`: `Rscript tools/perf/run.R <scenario>` prints `SECONDS=`, `PEAK_MB=`.
  - `tests/testthat/test_perfHarness.R`.
  - `.Rbuildignore` (`^tools$`).
  - `methodology/.quality-gates.json`.
  - `docs/audits/PERF_BASELINE_<date>.md`.

  That is six files, so two checkpoint commits.
- **App memory:** `shinytest2` `AppDriver` against the package installed in a scratch library:
  - set up with `R CMD INSTALL --no-docs --library=<scratch> .` and
    `R_LIBS=<scratch>:<renv lib>`;
  - run with `RENV_CONFIG_AUTOLOADER_ENABLED=false NOT_CRAN=true NPRC_RUN_E2E=true`;
  - upload `ExamplePedigree.csv`, then run QC, Genetic Value at 1,000 iterations, Summary
    Statistics and Breeding Groups;
  - read the app process's resident memory (`ps -o rss= -p <pid>`) after each step.
- **RED:** `test_perfHarness.R` checks three things, and fails because there is no harness:
  - `synthColony(500, seed = 1)` is the same twice and passes `qcStudbook()` with no errors;
  - `measure()` returns non-negative numbers;
  - every scenario name runs.
- **GREEN:** the harness. **REFACTOR:** tidy.
- **DONE when:**
  - `run.R reportGV-example` reproduces about 3.5 s within 30% on this machine (3.38 to 3.62 s
    in four runs this session);
  - the baseline doc lists every row of section 3 re-measured (3 runs, median and spread), plus
    the app's memory table;
  - the gates are declared, and `quality_ratchet.py --run` passes.
- **Check:** whether `lintr::lint_package()` reaches `tools/`; if not, lint those files with
  `lintr::lint()`.
- **Surface:** this Mac. CI is not a timing surface (shared runners), and Windows timings are not
  measured.
- **Gain:** none; this phase measures.

### Phase 1. Genome uniqueness: one fast rare-allele count, built once

- **Goal:** `rareAlleleCounts()` replaces the `tapply()`/`table()` count (H1). `calcA()` returns
  it, and `calcGU()`/`calcGUSE()` build their data frames from it. `reportGV()` builds it once
  for both, and `gvaConvergence()` uses it. All results are identical.
- **Files:**
  - `R/rareAlleleCounts.R` (new; Appendix B's `calcAFast()` is the measured prototype)
  - `R/calcA.R`
  - `R/calcGU.R`
  - `R/calcGUSE.R`
  - `R/reportGV.R`
  - `tests/testthat/helper-perfReference.R`
  - `tests/testthat/test_rareAlleleCounts.R`
  - `tests/testthat/test_perfBudget_genomeUniqueness.R`

  `R/gvaConvergence.R` needs no edit, since it calls `calcA()`. `alleleFreq()` is unchanged and
  stays exported.
- **Watch:**
  - Row order is `levels(factor(ids))`, whose collation depends on the locale. Reuse `factor()`
    exactly as `tapply()` does.
  - Keep the one-animal and zero-animal results (S925, the comment at `R/calcA.R:49-50`).
  - Keep `apply(perColumn, 1L, stats::var)` (`R/calcGUSE.R:63`); a vectorized variance would
    differ in the last bits.
  - `calcGU()` and `calcGUSE()` stay callable alone by scripts.
- **Measured (prototype):** `calcA()` 14 to 23 times faster with `byID = TRUE` (the report's
  setting) and 8 to 10 times with `byID = FALSE`; identical in 12 of 12 cases; peak 6% to 56%
  lower (section 3.3).
- **Estimate:** `reportGV()` on the example goes from about 3.5 s to about 0.55 s.
- **DONE when:**
  - the equivalence grid passes;
  - the budget test passes with at least 3x headroom;
  - `gvaConvergence()`'s tests pass unchanged;
  - the full suite gives 0 failed and 0 errors, lint gives 0, and `devtools::check()` is clean;
  - the harness shows the new numbers and the gate is tightened.
- **Surface:** testthat (exactness, every CI platform); this Mac (the budget). The app's Genetic
  Value tab is not re-checked in a browser, because its output is the same `reportGV()` result.

### Phase 2. The gene drop: a matrix inside `geneDrop()`

- **Goal:** H2's fix with an identical data frame out.
- **Files:**
  - `R/geneDrop.R`
  - the reference helper
  - `tests/testthat/test_geneDropEquivalence.R`
  - `tests/testthat/test_perfBudget_geneDrop.R`
- **Must keep:**
  - the id checks and their messages (`R/geneDrop.R:97-106`);
  - the random draws: sire before dam, and a draw only for a known parent;
  - the `notifyProgress()` calls: 1 + n of them, with the pinned arguments;
  - the value type: integer counters, but double when the genotype codes are double, as
    `pedWithGenotype` ships them;
  - the "logic error" stop for a parent with no alleles yet.
- **Left alone:** `assignAlleles()`, `chooseAlleles()` and `getGenoDefinedParentGenotypes()`
  stay, as exported or tested functions. They are no longer called by `geneDrop()`; add them to
  issue #37's list.
- **Measured (prototype):** 2.6 to 7.7 times faster, identical, peak 34% to 39% lower.
- **Later option, outside Phase 2:** hand the matrix straight to Phase 1's count and Phase 5's
  retention inside `reportGV()`. That skips one data frame of 2n x K values (47 MB at 6,090
  animals) and needs its own equivalence tests.
- **DONE when:** the common items, with the progress test unchanged.
- **Surface:** as Phase 1.

### Phase 3. The relationship table

- **Goal:** both relationship downloads finish in seconds on the example (6,824,665 pairs), with
  the same rows and classes.
- **Two steps:** (a) preallocate the result (measured: identical, 6.6 times faster at 600
  animals); (b) map every pair's ids to integer indices of parents and grandparents once, then
  classify all pairs with vector comparisons in the `if`/`else if` chain's order, where the first
  matching rule wins. If (b) does not fit one session, (a) closes this session and (b) is the
  next.
- **Files:** `R/convertRelationships.R` and its tests. Its callers are `R/modSummaryStats.R:427`
  (downloads at `:878`, `:886`) and `R/markerRealizedRelatednessVariance.R:119`.
- **Must keep:** one argument-free progress call per pair when a callback is given
  (`tests/testthat/test_notifyProgress.R:163-176`); the app passes none. Also keep the row order
  and the long form's columns.
- **Estimate:** about 6.7 minutes for the example after (a) alone, at 59 µs a pair; seconds after
  (b). D8 only if (b) still is not enough.
- **DONE when:** the common items, plus both downloads finish on the example in the app.
- **Surface:** testthat for the classes of every pair (`qcPed`, and the example's first 600
  animals against the reference); a browser click on both downloads for the example (the
  browser tier) for the finish time, which no unit test shows.

### Phase 4. Group formation

- **Goal:** 1,000 trials on the example's 280 candidates in a few seconds, with the same groups
  for the same seed.
- **Files:**
  - `R/fillGroupMembers.R`
  - `R/fillGroupMembersWithSexRatio.R`
  - `R/removeSelectedAnimalFromAvailableAnimals.R`
  - `R/removeGroupIfNoAvailableAnimals.R`
  - `R/makeAvailable.R`

  Those are five files: tests go in a second commit.
- **Must keep:** each `sample()` call sees the same ordered vector. `which()` over a mask keeps
  the candidate order. `sample(grpNum, 1L)` samples a list (`makeGroupNum()` returns one), so a
  lone group number never triggers `sample(k)`'s 1:k rule (traced this session: 0 of 20,758
  calls). Keep one progress call per trial (`tests/testthat/test_notifyProgress.R`).
- **DONE when:** `groupAddAssign()`'s whole result is identical for seeds x {plain, harem, sex
  ratio, seeded current groups, ancestry rules, exhaustive mode untouched}, plus the common
  items. Then D7.
- **Surface:** testthat (identical groups, every CI platform); this Mac (the budget); the Breeding
  Groups tab in the browser tier for a run at 1,000 trials.

### Phase 5. Founder statistics

- **Goal:** contributions by integer position, and contributions and retention built once per
  report (H8). `calcFEFG()`, `calcFGSE()`, `calcFE()`, `calcFG()` and `calcRetention()` give
  identical results.
- **Files:**
  - `R/calcFounderContributions.R`
  - `R/calcRetention.R`
  - `R/calcFEFG.R`
  - `R/calcFGSE.R`
  - `R/reportGV.R`
- **Estimate:** at 6,090 animals, 2.2 s goes to under 0.5 s and the peak from 446 MB to under
  150 MB.
- **Watch:** keep the name alignment of issue #86 (`R/calcFEFG.R:72-77`) and the degeneracy
  checks.
- **DONE when:** the common items, with `fg`, `fgSE` and `fe` identical in `reportGV()`'s result.
- **Surface:** as Phase 1.

### Phase 6. Kinship memory

- **Goal:** `kinship()` uses one n x n matrix; long forms and high-kinship pair lists stop
  building m² rows (H6, H7).
- **Steps:**
  - (a) allocate n x n, with an unknown parent contributing a zero row;
  - (b) `kinMatrix2LongForm()` builds its three columns directly with `rep()` and `as.vector()`,
    in the same row order;
  - (c) `getAnimalsWithHighKinship()` starts from
    `which(kmat > threshold, arr.ind = TRUE)`, then applies the same filters.
- **Files:**
  - `R/kinship.R`
  - `R/kinMatrix2LongForm.R`
  - `R/getAnimalsWithHighKinship.R`
  - tests
- **Watch:** `kinship()` is reached by 63 test files and 7 vignettes. Keep:
  - the dimnames;
  - the X branch's NA founders and NA unknown-sex rows;
  - the MZ-twin correction (`mzindex` uses positions up to n, `R/kinship.R:226`);
  - the `sparse = TRUE` path (its speed is outside this phase).
- **Estimate:** the kinship peak goes from 568 MB to about 290 MB at 6,090 animals, and the
  long-form peak from 1,007 MB to about 330 MB.
- **DONE when:** the common items. The memory gate is the measure here: time may not change.
- **Surface:** testthat (identical matrices, every CI platform); this Mac (the peaks).

### Phase 7. The diagram's solver

- **Goal:** H5's fix, with every pinned position unchanged.
- **Files:**
  - `R/makePedigreeDiagramData.R` (`.solveJointQP()` only)
  - `tests/testthat/helper-reorderedSolveQP.R`
  - `tests/testthat/test_solveJointQP.R`
- **Must also:**
  - Move the helper's mock to `quadprog::solve.QP.compact` (permuting `Aind`), and assert the
    mock was called. Otherwise the reordering tests would intercept nothing and pass vacuously.
  - Keep every pinned position passing unchanged: 6,635 lines across 4 test files, as
    `docs/planning/pedigree-diagram-joint-qp-solver-plan.md:58-60` counted them (re-count at the
    phase's start).
  - Test `crossprod(pmat)` against `t(pmat) %*% pmat` for `identical()` on every fixture. The
    two call different BLAS routines, so this must also pass on CI's three platforms; drop
    `crossprod()` if any differ. The compact solve itself was identical here, but it too is shown
    only for this Mac until CI runs it.
- **Measured:** the solve goes from 11.60 s to 3.00 s, identical, at 708 animals.
- **Estimate:** the tab goes from 13.9 s to about 5 s. The growth stays cubic, and issue #138
  (beyond the cap) stays separate.
- **DONE when:** the common items, plus the browser tier's diagram tests pass with no picture
  change.
- **Surface:** testthat on CI's three platforms (the positions); the browser tier (the drawn tab).

### Phase 8. The app's memory: a design session (text only)

- **Inputs:** Phase 0's app memory table, Phase 6's numbers, and the densities in section 3.2.
- **Question:** D5, consumer by consumer (H6 lists them). Only the kinship CSV download and the
  all-pairs relationship table need every pair.
- **Exactness fact behind option (c):** a pair's kinship depends only on its ancestors.
  `reportGV()` already relies on this through `trimToAnalysisPopulation()`. The design must name
  the bit-identity tests, twins included.
- **Output:** a design document, and the owner's D5 ruling.
- **Surface:** none; it is a design session (text only). Its numbers come from Phase 0's app
  memory table and Phase 6's measurements.

### Phase 9. The app's memory: implementation (per Phase 8's design; one or two sessions)

- **DONE when:** Phase 8's design sets the items. The minimum is the app memory table (Phase 0's
  recipe) re-measured before and after, and every tab that uses kinship still passing its
  browser-tier tests.
- **Surface:** the running app (resident memory through `shinytest2`). Unit-level object sizes
  cannot show what a session holds.

### Phase 10. Snapshot backfill and convergence: follow-through

- **Goal:** re-measure Build Earlier Snapshots and `gvaConvergence()` after Phases 1, 2 and 5.
- **The cost line:** `R/modSnapshotTrends.R:457` (`4L * guIter / 1000L`) and `:470` ("about 4
  seconds per 1,000 iterations on a colony of 2,590 animals") need the new number, worded by the
  owner.
- **Then:** D6.
- **DONE when:** the two rows of section 1 (5 and 6) are re-measured and the cost line says the
  measured number in the owner's words.
- **Surface:** this Mac for the number; testthat for the sentence (`describeBackfillCost()`).

### Phase 11. Consolidation

- Re-run every harness scenario.
- Write `docs/audits/PERF_CAMPAIGN_REPORT_<date>.md`, with before and after for every row of
  section 1 and the estimate-to-actual ratio.
- Add one `NEWS.Rmd` release-state line, worded by the owner.
- Tighten every gate.
- Decide whether `helper-perfReference.R` stays as the oracle.
- Revisit D2 with the hotspots that remain.
- Close the BACKLOG item.
- **Surface:** this Mac for the harness; the browser tier for the app memory table and the tabs.

---

## 8. Evidence-based inventory

Every caller, test file and vignette for the functions this campaign changes. Found with
`git grep -n "<name>("` over `R/` (definition lines, roxygen and comment lines removed),
`tests/testthat/` and `vignettes/`. Re-run the grep at each phase's start: line numbers drift.
"Exp" means exported.

| Function (definition) | Exp | Production callers | Test files | Vignettes |
|---|---|---|---|---|
| `calcA` (`R/calcA.R:34`) | yes | `R/calcGU.R:97`, `R/calcGUSE.R:58`, `R/gvaConvergence.R:209` | test_calcA, test_calcGU, test_calcGUSE, test_gvaConvergence, test_reportGV | |
| `calcGU` (`R/calcGU.R:90`) | yes | `R/reportGV.R:265` | test_calcA, test_calcGU, test_calcGUSE, test_calcSnapshotDeltas, test_reportGV, test_reportGVPedigreeOnlyFounderGenome | |
| `calcGUSE` (`R/calcGUSE.R:51`) | yes | `R/reportGV.R:273` | test_calcA, test_calcGUSE, test_newsGeneralFixesGrouped | gvaConvergence.Rmd |
| `alleleFreq` (`R/alleleFreq.R:26`) | yes | `R/calcA.R:40,42` | test_alleleFreq, test_calcGU, test_calcGUSE, test_gvaConvergence, test_reportGV | a2interactive.Rmd |
| `geneDrop` (`R/geneDrop.R:95`) | yes | `R/reportGV.R:253,307`, `R/gvaConvergence.R:204` | helper-fgSEValidation, test_calcFEFG, test_calcFG, test_calcFounderContributions, test_calcSnapshotDeltas, test_geneDrop, test_hasInvalidIdChar, test_notifyProgress, test_reportGV, test_reportGVPedigreeOnlyFounderGenome | articles/fg-se-validation.qmd |
| `assignAlleles` (`R/assignAlleles.R:35`) | yes | `R/geneDrop.R:141,142`, `R/getGenoDefinedParentGenotypes.R:31,37` | test_assignAlleles | |
| `chooseAlleles` (`R/chooseAlleles.R:17`) | yes | `R/assignAlleles.R:49` | | |
| `calcFEFG` (`R/calcFEFG.R:65`) | yes | `R/reportGV.R:317` | helper-fgSEValidation, test_calcFEFG, test_calcFounderContributions, test_calcGeneDiversity, test_calcSnapshotDeltas, test_reportGVPedigreeOnlyFounderGenome | articles/fg-se-validation.qmd |
| `calcFGSE` (`R/calcFGSE.R:60`) | yes | `R/reportGV.R:325` | helper-fgSEFixtures, helper-fgSEValidation, test_calcFGSE, test_calcFounderContributions, test_fgSEValidation, test_reportGVPedigreeOnlyFounderGenome | articles/fg-se-validation.qmd |
| `calcRetention` (`R/calcRetention.R:32`) | yes | `R/calcFEFG.R:71`, `R/calcFG.R:72` | helper-fgSEFixtures, test_calcFEFG, test_calcFG, test_calcFounderContributions, test_calcRetention | articles/fg-se-validation.qmd |
| `calcFounderContributions` (`R/calcFounderContributions.R:26`) | no | `R/calcFE.R:50`, `R/calcFEFG.R:70`, `R/calcFG.R:71`, `R/calcFGSE.R:63` | helper-fgSEFixtures, helper-fgSEValidation, test_calcFEFG, test_calcFGSE, test_calcFounderContributions, test_fgSEValidation | |
| `kinship` (`R/kinship.R:109`) | yes | `R/appServer.R:359`, `R/gvaConvergence.R:156`, `R/makePedigreeDiagramData.R:1817`, `R/modBreedingGroups.R:378`, `R/modSummaryStats.R:413`, `R/reportGV.R:209`, `R/simulateKinship.R:26` | 63 files (`git grep -l "kinship(" -- tests/testthat`) | a2interactive.Rmd and 6 articles |
| `kinMatrix2LongForm` (`R/kinMatrix2LongForm.R:28`) | yes | `R/convertRelationships.R:48`, `R/getAnimalsWithHighKinship.R:47`, `R/reportMatePairs.R:207` | test_filterAge, test_filterPairs, test_filterThreshold, test_kinMatrix2LongForm | |
| `getAnimalsWithHighKinship` (`R/getAnimalsWithHighKinship.R:45`) | yes | `R/groupAddAssign.R:207` | test_addAnimalsWithNoRelative, test_enumerateMaximalIndependentSets, test_fillGroupMembers, test_fillGroupMembersWithSexRatio, test_groupAddAssign, test_haremSireConflicts | |
| `convertRelationships` (`R/convertRelationships.R:37`) | yes | `R/modSummaryStats.R:427`, `R/markerRealizedRelatednessVariance.R:119` | test_convertRelationships, test_filterKinMatrix, test_guideExportTables, test_makeRelationsClasses, test_newsGeneralFixesGrouped, test_notifyProgress, test_relationClassNames | |
| `fillGroupMembers` (`R/fillGroupMembers.R:27`) | no | `R/groupAddAssign.R:297` | test_fillGroupMembers, test_groupAddAssign, test_haremSexRatioStop, test_haremSireConflicts | |
| `removeSelectedAnimalFromAvailableAnimals` (`R/removeSelectedAnimalFromAvailableAnimals.R:12`) | no | `R/fillGroupMembers.R:81`, `R/fillGroupMembersWithSexRatio.R:108,117,121` | | |
| `removeGroupIfNoAvailableAnimals` (`R/removeGroupIfNoAvailableAnimals.R:16`) | no | `R/fillGroupMembers.R:67,85`, `R/fillGroupMembersWithSexRatio.R:128,129` | test_haremSexRatioStop | |
| `makeAvailable` (`R/makeAvailable.R:13`) | no | `R/fillGroupMembers.R:58`, `R/fillGroupMembersWithSexRatio.R:88,89` | | |
| `.solveJointQP` (`R/makePedigreeDiagramData.R:1413`) | no | `R/makePedigreeDiagramData.R:1324` | helper-reorderedSolveQP, test_positionMatingUnitForest, test_solveJointQP | |

Also in scope as callers: `reportGV` (`R/reportGV.R:173`; 7 production calls, 36 test files,
10 vignettes), `gvaConvergence` (`R/gvaConvergence.R:128`; called from `R/modGeneticValue.R`),
`backfillColonySnapshots` (`R/backfillColonySnapshots.R:143`; its per-date loop at `:200`), and
the cost line `describeBackfillCost()` (`R/modSnapshotTrends.R:456`).

Mocks of in-scope code (each phase re-greps `mocked_bindings|stub(`):
- `tests/testthat/test_notifyProgress.R:199` (`notifyProgress` inside `geneDrop`);
- `tests/testthat/test_reportGV.R:871` (`kinship`);
- `tests/testthat/helper-reorderedSolveQP.R` (`quadprog::solve.QP`; called once each in
  `test_positionMatingUnitForest.R` and `test_solveJointQP.R`).

---

## 9. Risks

1. **Random stream drift.** Caught by D1's `identical()` grid with several seeds.
2. **Locale-dependent order of ids** (factor levels). Reuse `factor()`, as `tapply()` does.
3. **Tests that reach inside the code** (section 8's mocks). A refactor that stops calling a
   mocked name leaves its test passing vacuously. Each phase checks that its mocks still
   intercept.
4. **Exported helpers left unused inside the package** (`assignAlleles()`, `chooseAlleles()`,
   `alleleFreq()`). They stay, because they are exported (D3); add them to issue #37.
5. **Flaky budgets.** Opt-in, at least 3x headroom, the median of 3 runs, and `uptime` first.
6. **Noisy memory numbers** (section 2: up to 2x between runs). Compare pairs from the same run,
   and give the gates headroom from Phase 0's measured spread.
7. **The 5-file cap.** Use checkpoint commits.
8. **CRAN check time.** Budget tests skip on CRAN, and no new example runs on a large input: one
   example once took 734 s (`docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md`).
9. **Synthetic colony against real colony.** Structure changes the answers: kinship is 7.3%
   nonzero on the example against 45.5% on the synthetic colony. Any decision that depends on
   structure (D5) is shown with both numbers. A real studbook above 3,694 animals is still
   BLOCKED (`BACKLOG.md:51`).
10. **Scope creep.** Each phase changes its hotspot only. Something noticed on the way becomes a
    `BACKLOG.md` line, never an edit (`methodology/SAFEGUARDS.md` §Scope Creep Red Flags).

---

## 10. Alternatives considered

| Alternative | For | Against | Verdict |
|---|---|---|---|
| `kinship(sparse = TRUE)` as the default | the same values, 11.9 MB against 104.6 MB on the example | 44.89 s against 0.53 s (measured); the synthetic colony gains only 2.9x | rejected for computing; kept as a storage option under D5 |
| Rcpp / C++ for the loops | the largest possible speedup | toolchain, CRAN compiled checks, a second language to maintain | D2: not now; revisit at Phase 11 |
| `data.table` grouping for the rare-allele count (already imported) | familiar | `match()` + `tabulate()` per column already gives 14 to 23x with no new code style | not needed |
| Parallel dates or iterations | wall-clock time | no fork on Windows; random streams change (D1) | D6, only if still slow |
| Change the random draws (for example `rbinom()` for all animals) | faster gene drop | different numbers for the same seed | out under D1 |
| A sparse QP solver (for example `osqp`) | scales past the cap | a new dependency, different floating-point results | belongs to issue #138, not here |
| Fewer iterations, or approximate genome uniqueness | speed | changes the statistics | out of scope (`gvaConvergence()` exists to choose the iteration count) |

---

## 11. Out of scope

- The statistics and their definitions, and kinship values.
- The diagram's layout model and its 750/400 caps (issue #138).
- The UI's layout.
- Marker genetics: already budgeted by its own wall-clock tests (section 5.2).
- The test suite's own run time.
- Any change to the random stream (D1) or to an exported result (D3) without the owner's say.

---

## Appendix A. The measuring harness (condensed from the scratch scripts)

```r
Sys.setenv(NOT_CRAN = "true")
suppressMessages(pkgload::load_all(".", quiet = TRUE))

## peak memory above the starting point, from gc()'s "max used" Mb column
## (R 4.6 adds a "limit (Mb)" column, so the column is found by name)
maxUsedMb <- function(g) sum(g[, which(colnames(g) == "max used") + 1L])
usedMb <- function(g) sum(g[, 2L])
measure <- function(input, label, expr) {
  g0 <- gc(reset = TRUE)
  base <- usedMb(g0)
  t0 <- proc.time()
  val <- expr                      # forced here, inside the timed window
  el <- (proc.time() - t0)[["elapsed"]]
  peak <- maxUsedMb(gc()) - base
  cat(sprintf("%-22s %-34s %9.2f s  peak +%9.1f MB  result %9.1f MB\n", input,
              label, el, peak, as.numeric(utils::object.size(val)) / 2^20))
  invisible(val)
}

## A synthetic colony (labeled synthetic wherever it is cited)
synthColony <- function(n, seed = 1L, years = 45, foundFrac = 0.06) {
  set.seed(seed)
  nF <- max(20L, round(n * foundFrac))
  birth <- c(stats::runif(nF, 0, 4), sort(stats::runif(n - nF, 4, years)))
  sex <- sample(c("M", "F"), n, replace = TRUE)
  id <- sprintf("S%06d", seq_len(n))
  sire <- dam <- rep(NA_character_, n)
  breederM <- sex == "M" & stats::runif(n) < 1 / 6
  for (i in (nF + 1L):n) {
    elig <- which(birth >= birth[i] - 20 & birth <= birth[i] - 3.5)
    m <- elig[breederM[elig]]
    f <- elig[sex[elig] == "F"]
    if (length(m) == 0L || length(f) == 0L) next
    sire[i] <- id[m[sample.int(length(m), 1L)]]
    dam[i] <- id[f[sample.int(length(f), 1L)]]
  }
  exitT <- birth + stats::runif(n, 1, 25)
  exitT[exitT > years] <- NA
  origin <- as.Date("1975-01-01")
  data.frame(id = id, sire = sire, dam = dam, sex = sex,
             birth = origin + round(birth * 365.25),
             exit = origin + round(exitT * 365.25), stringsAsFactors = FALSE)
}

## The app's path up to reportGV()
appAnalysisPed <- function(raw, trim = TRUE) {
  sb <- qcStudbook(raw, minSireAge = 2, minDamAge = 2, reportChanges = FALSE,
                   reportErrors = FALSE)
  ped <- setPopulation(sb, sb$id[isLivingAnimal(sb)])
  ped$pedNum <- findPedigreeNumber(ped$id, ped$sire, ped$dam)
  if (!"gen" %in% names(ped)) ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  if (trim) ped <- trimToAnalysisPopulation(ped)
  ped
}
```

The stage runner calls, in `reportGV()`'s order, `kinship()`, `filterKinMatrix()`,
`geneDrop(n = 1000)`, `calcGU()` and `calcGUSE()` (threshold 4, `byID = TRUE`, `pop` = the
probands), `calcFEFG()`, `calcFGSE()` and `offspringCounts()`, each wrapped in `measure()`, with
`set.seed(20261024)` before the drop.

## Appendix B. The two prototypes (scratch, measured, not package code)

```r
## calcA() with the same result: rows in factor(ids) level order, columns
## V1..VK, each cell the number of the animal's two alleles rare in that column.
calcAFast <- function(alleles, threshold = 1L, byID = FALSE) {
  ids <- alleles$id
  m <- as.matrix(alleles[, !(names(alleles) %in% c("id", "parent")), drop = FALSE])
  lev <- levels(factor(ids))
  g <- match(ids, lev)
  rowsOf <- split(seq_along(g), g)
  twoEach <- all(lengths(rowsOf) == 2L)
  out <- matrix(0L, nrow = length(lev), ncol = ncol(m),
                dimnames = list(lev, colnames(m)))
  if (twoEach) {
    r1 <- vapply(rowsOf, `[`, integer(1L), 1L)
    r2 <- vapply(rowsOf, `[`, integer(1L), 2L)
  }
  for (k in seq_len(ncol(m))) {
    a <- m[, k]
    u <- unique(a)
    code <- match(a, u)
    nU <- length(u)
    if (byID) {
      if (twoEach) {
        cnt <- tabulate(code, nU)
        homo <- code[r1] == code[r2]
        cnt <- cnt - tabulate(code[r1][homo], nU)
      } else {
        cnt <- tabulate(code[!duplicated(cbind(g, code))], nU)
      }
    } else {
      cnt <- tabulate(code, nU)
    }
    rare <- cnt[code] <= threshold
    out[, k] <- if (twoEach) {
      rare[r1] + rare[r2]
    } else {
      as.integer(rowsum(as.integer(rare), g, reorder = TRUE))
    }
  }
  out
}

## geneDrop() with the same result and the same random stream: each animal's
## two allele vectors are columns of a K x 2n matrix, parents found by position.
geneDropFast <- function(ids, sires, dams, gen, genotype = NULL, n = 1000L,
                         updateProgress = NULL) {
  ## (the two id checks of R/geneDrop.R:97-106, unchanged, go here)
  ord <- order(gen)
  id <- as.character(ids)[ord]
  sire <- as.character(sires)[ord]
  dam <- as.character(dams)[ord]
  nA <- length(id)
  if (!is.null(genotype)) {
    genotype <- genotype[!(is.na(genotype$first) & is.na(genotype$second)), ]
  }
  isDouble <- !is.null(genotype) &&
    (is.double(genotype$first) || is.double(genotype$second))
  A <- matrix(if (isDouble) 0.0 else 0L, nrow = n, ncol = 2L * nA)
  done <- logical(nA)
  pos <- stats::setNames(seq_len(nA), id)
  counter <- 1L
  notifyProgress(updateProgress, detail = "Performing Gene-drop Simulation",
                 value = 0L, reset = TRUE)
  draw <- function(parent, slot) {
    if (is.na(parent)) {
      A[, slot] <<- counter
      counter <<- counter + 1L
    } else {
      p <- pos[parent]
      if (is.na(p) || !done[p]) {
        stop("sire and dam must have had alleles assigned: logic error")
      }
      s1 <- sample(c(0L, 1L), n, replace = TRUE)
      A[, slot] <<- (A[, 2L * p - 1L] * s1) + (A[, 2L * p] * (1L - s1))
    }
  }
  for (i in seq_len(nA)) {
    gi <- if (is.null(genotype)) integer(0L) else which(genotype$id == id[i])
    if (length(gi) > 0L) {
      if (is.na(genotype$first[gi])) draw(sire[i], 2L * i - 1L)
      else A[, 2L * i - 1L] <- rep(genotype$first[gi], n)
      if (is.na(genotype$second[gi])) draw(dam[i], 2L * i)
      else A[, 2L * i] <- rep(genotype$second[gi], n)
    } else {
      draw(sire[i], 2L * i - 1L)
      draw(dam[i], 2L * i)
    }
    done[i] <- TRUE
    notifyProgress(updateProgress, n = nA)
  }
  alleles <- as.data.frame(t(A))
  alleles$id <- rep(id, each = 2L)
  alleles$parent <- rep(c("sire", "dam"), nA)
  rownames(alleles) <- seq_len(nrow(alleles))
  alleles
}
```

Known limits of the prototypes, for the phase that adopts them:
- `geneDropFast()` still scans the genotype table once per animal (`which(genotype$id == id[i])`);
  a `match()` up front is the phase's job.
- `calcAFast()` still copies the data frame to a matrix (`as.matrix()`), which is most of its
  remaining peak; the later option under Phase 2 removes that copy.
