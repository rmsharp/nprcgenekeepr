# Performance and memory campaign: the consolidation report (S1066, 2026-10-26)

**Deliverable of S1066:** Phase 11 of `docs/planning/performance-memory-campaign-plan.md` (its section 7):
every harness scenario re-run, before and after for every row of the plan's section 1 with the
estimate-to-actual ratio, the app's memory table, every gate re-measured, and the owner's rulings on
the reference copies and D2. No package code changed this session. The "before" is Phase 0's baseline
(`docs/audits/PERF_BASELINE_2026-10-24.md`, S1052) for the harness and, for the app, the pre-campaign
code run with the same tool in the same hour as today's (section 6).

## In plain words

The campaign did what it set out to do, with exactly the same results for the same random seed. The
Genetic Value analysis of the shipped example takes **0.23 s instead of 3.28 s** (14 times faster), and
on the example's 3,694 animals or a generated 10,000-animal colony 3.0 to 3.6 s instead of 35 to 39 s.
The relationship downloads, which never finished on the example, now take 4 to 7 s. A thousand Breeding
Groups trials take 5.5 s instead of 23 s, the Pedigree Diagram of 708 animals 5.1 s instead of 12.8 s,
and Build Earlier Snapshots 1.0 s instead of 9.4 s for three dates.

The app holds **about 180 MB less** once the example is loaded and about 240 MB less through Breeding
Groups and Genetic Diversity, because it no longer builds and keeps a kinship matrix of every animal.
The Linkage and LD tab, which did not finish within 15 minutes on the pre-campaign code, opens in 14 s.

What is still large is filed: Mate Pair's default run (about 1.4 GB in the app), Marker Genetics'
6.8-million-row relatedness table, harem trials, the diagram's time outside its solver, the founder
statistics' memory peak, and nine fallbacks that keep the old code for unusual inputs (section 11).

## 1. Coverage

| Phase | Session | What changed | Headline number |
|---|---|---|---|
| plan | S1050, S1051 | the plan; D1 to D4 ruled | |
| 0 | S1052 | the harness (`tools/perf/`), the baseline, 7 gates | `reportGV()` 3.28 s |
| 1 | S1053 | genome uniqueness: one rare-allele count (`R/rareAlleleCounts.R`), built once per report | `reportGV()` 3.28 to 0.60 s |
| 2 | S1054 | the gene drop: one matrix inside `geneDrop()` | peak 148.5 to 65.1 MB |
| 3 | S1055 | the relationship table: every pair classified at once (`relationClasses()`) | 300 animals 6.28 to 0.08 s |
| 4 | S1056 | group formation: a candidates x groups table | 1,000 trials 23.0 to 5.6 s |
| D7 | S1057 | Breeding Groups keeps 10 trials | |
| 5 | S1058 | founder statistics by position, built once per report | `calcFEFG()` 1.19 to 0.09 s (synthetic) |
| 6 | S1059 | kinship memory: one n x n fill; long forms built by `rep()` | long form 979.0 to 312.5 MB |
| 7 | S1060 | the diagram's solver: `quadprog::solve.QP.compact()` | 13.17 to 4.70 s |
| 8 | S1062 | the app's memory design; D5 ruled (c) | |
| 9a, 9b | S1063, S1064 | each tab asks `kinshipFor` for its own animals; no shared matrix | upload + QC 685.1 to 520.8 MB |
| 10 | S1065 | the backfill's cost line; D6 ruled no | backfill 9.42 to 1.08 s |
| 11 | S1066 | this report, the NEWS line, the gates, the last rulings | |

Every phase ran under strict TDD where code changed; S1061, between Phases 7 and 8, fixed a CI leg and
is not part of the campaign. No phase is left unfinished.

## 2. How the numbers were measured (this session)

- **Machine:** Apple M2 Max, 96 GB, macOS 27.0; R 4.6.1 with R's reference BLAS, single-threaded, as
  in Phase 0.
- **Harness:** `Rscript tools/perf/run.R <scenario>` at HEAD `c4fb07453` (the `R/` tree of S1065), from
  the project root, each run in its own process: three passes over all 20 scenarios, 11:29 to 11:36
  CDT. Every row below is three runs, the median and then the range.
- **Load:** the one-minute load average was 4.4 to 5.2 for the whole first pass. Other work (a remote
  desktop app and a test runner, not this session's) raised it to 8 to 22 for the second and third
  passes, from the diagram scenarios on. Those rows read up to about 10% slow: the sparse kinship,
  which no phase changed, took 50.68 s against Phase 0's 45.43 s.
- **A pass takes 2.5 minutes**, against 5.7 at Phase 0, and almost all of it is the unchanged sparse
  kinship of all 3,694 animals (about 50 s).

## 3. Before and after: the rows of the plan's section 1

"Estimate" is the plan's (S1050). "Actual / estimate" below 1 means faster than estimated.

| # | What the user does | Before (Phase 0) | After (S1066) | Faster by | Plan's estimate | Actual / estimate |
|---|---|---|---|---|---|---|
| 1 | Genetic Value analysis, the example as the app trims it (708 rows, 1,000 iterations, threshold 4) | 3.28 s (3.27-3.38) | 0.23 s (0.23-0.24) | 14.3x | about 0.35 s | 0.66 |
| 1b | the same, all 3,694 animals (sum of the stages) | 38.50 s | 3.03 s | 12.7x | about 2.2 s | 1.38 |
| 1c | the same, synthetic 10,000 (6,090 rows after the trim; sum) | 35.03 s | 3.57 s | 9.8x | about 3.9 s | 0.92 |
| 2 | the relationship downloads of the whole example (6,824,665 pairs) | never finishes (600 animals 64.21 s) | 3.40 s to build the table (3 runs); 7.3 s with "Download relationships"' CSV | | seconds | met |
| 3 | Breeding Groups, 1,000 trials, 280 candidates, 6 groups | 23.04 s (23.02-23.30) | 5.54 s (5.49-5.93) | 4.2x | 5 to 20 times faster | just under the range |
| 3h | the same as harems | 27.19 s (26.10-28.04) | 10.69 s (9.78-11.16) | 2.5x | | |
| 4 | Pedigree Diagram, 708 animals, direct | 12.81 s (12.76-12.82) | 5.10 s (4.80-5.22) | 2.5x | about 5 s | 1.02 |
| 5 | Build Earlier Snapshots, jmac, 3 dates x 1,000 | 9.42 s (9.36-9.46) | 0.99 s (0.96-0.99) | 9.5x | 4 to 8 times faster | beyond the range |
| 6 | `gvaConvergence(nMax = 3000)`, the example | 4.73 s (4.67-4.75) | 0.75 s (0.70-0.77) | 6.3x | about 0.7 s | 1.07 |

Row 2 in detail: the first 150, 300 and 600 animals went from 1.35, 6.28 and 64.21 s to 0.06, 0.08 and
0.12 s. On the whole example the old code was never timed to the end; S1055 measured 544.7 s with only
its result preallocated, and the unchanged code grows about 10 times per doubling of animals. Today the
table takes 3.40 s in each of three runs (234.7 MB), "Download relationships" writes it in 4.20 s more
(a 234 MB file), and "Download relationship classes" adds 0.64 s for its 10-row table.

Row 1b is the one clear miss, and part of it is how the row is counted: the stage sum calls `calcGU()`
and `calcGUSE()` one after the other, and each builds its own rare-allele count (0.95 and 0.88 s),
while `reportGV()` builds it once. The plan's prototype measured one count on all 3,694 at 0.77 s
(its section 3.3).

## 4. Memory: the plan's section 1

| What | Before | After | Plan's estimate |
|---|---|---|---|
| The app's kept kinship matrix of the whole pedigree (example) | 104.6 MB, the whole session | none (9b) | (D5) |
| `kinship()` peak, synthetic 10,000 (result 283.7 MB) | 569.9 MB | 455.7 MB | about 290 MB |
| `kinship()` peak, all 3,694 (result 104.6 MB) | 210.1 MB | 153.8 MB | |
| `geneDrop()` peak: app trim / all 3,694 / synthetic | 148.5 / 299.6 / 531.4 MB | 65.1 / 244.2 / 416.7 MB | |
| `kinMatrix2LongForm()` peak, all 3,694 (result 312.7 MB) | 979.0 MB | 312.4 MB | about 330 MB |
| the same with `removeDups = TRUE` (result 182.6 MB) | 915.5 MB | 234.3 MB | |
| `calcFEFG()` / `calcFGSE()` peak, synthetic | 217.9 / 225.6 MB | 221.9 / 253.6 MB | under 150 MB |
| `calcFEFG()` + `calcFGSE()` time, synthetic | 2.11 s | 0.21 s | under 0.5 s |

The memory estimates were the weaker half of the plan: the kinship peak landed at 1.6 times its result
where the plan expected about 1, and the founder statistics' peak rose a little while their time fell
tenfold (now a BACKLOG item, section 11). The long form landed on its estimate.

## 5. Every scenario

The Genetic Value stages. Each cell: seconds, median (range); peak. "Before" is Phase 0.

| Stage | app trim before | app trim after | all 3,694 before | all 3,694 after | synthetic before | synthetic after |
|---|---|---|---|---|---|---|
| `kinship()` | 0.01 s; 20.8 MB | 0.01 s; 20.4 MB | 0.46 s; 210.1 MB | 0.41 s; 153.8 MB | 1.52 s; 569.9 MB | 1.52 s; 455.7 MB |
| `filterKinMatrix()` | 0.00 s; 0.9 MB | 0.00 s; 0.9 MB | 0.02 s; 104.4 MB | 0.14 s; 104.2 MB | 0.02 s; 68.2 MB | 0.01 s; 68.3 MB |
| `geneDrop()` | 0.13 s; 148.5 MB | 0.04 s; 65.1 MB | 1.46 s; 299.6 MB | 0.17 s; 244.2 MB | 3.48 s; 531.4 MB | 0.41 s; 416.7 MB |
| `calcGU()` | 1.53 s; 142.2 MB | 0.10 s; 74.9 MB | 17.54 s; 274.3 MB | 0.95 s; 180.9 MB | 13.91 s; 263.7 MB | 0.68 s; 219.7 MB |
| `calcGUSE()` | 1.41 s; 147.7 MB | 0.11 s; 88.6 MB | 17.75 s; 321.6 MB | 0.88 s; 195.9 MB | 13.98 s; 307.8 MB | 0.73 s; 234.6 MB |
| `calcFEFG()` | 0.08 s; 75.3 MB | 0.02 s; 49.8 MB | 0.65 s; 233.2 MB | 0.27 s; 247.7 MB | 1.04 s; 217.9 MB | 0.09 s; 221.9 MB |
| `calcFGSE()` | 0.08 s; 89.3 MB | 0.05 s; 86.6 MB | 0.64 s; 236.5 MB | 0.20 s; 257.5 MB | 1.07 s; 225.6 MB | 0.12 s; 253.6 MB |
| `offspringCounts()` | 0.00 s; 4.5 MB | 0.00 s; 4.5 MB | 0.01 s; 7.9 MB | 0.01 s; 7.8 MB | 0.02 s; 9.2 MB | 0.01 s; 9.2 MB |
| `reportGV()` whole | 3.28 s; 162.9 MB | 0.23 s; 74.0 MB | | | | |

The 0.14 s of `filterKinMatrix()` on all 3,694 is a garbage collection, not the function (whose code no
phase touched): called on today's `kinship()` result it takes 0.147 s the first time and 0.019 and
0.015 s after; on the pre-campaign code 0.016, 0.023 and 0.014 s. A stage's time can move when an earlier
stage's memory use changes.

The other work. Seconds, median (range); peak.

| Scenario | Before | After |
|---|---|---|
| `convertRelationships-150` / `-300` / `-600` | 1.35 / 6.28 / 64.21 s; 271.7 MB | 0.06 / 0.08 / 0.12 s; 13.0 / 40.8 / 90.9 MB |
| `kinMatrix2LongForm-all` | 1.53 s; 979.0 MB | 0.52 s (0.50-0.54); 312.4 MB |
| `kinMatrix2LongForm-all-removeDups` | 1.11 s; 915.5 MB | 0.55 s (0.54-0.58); 234.3 MB |
| `groupAddAssign-10` | 0.35 s; 139.0 MB | 0.17 s; 91.9 MB |
| `groupAddAssign-1000` | 23.04 s; 139.0 MB | 5.54 s (5.49-5.93); 149.9 MB |
| `groupAddAssign-harem-10` | 0.38 s; 139.0 MB | 0.25 s (0.22-0.27); 128.5 MB |
| `groupAddAssign-harem-1000` | 27.19 s; 139.0 MB | 10.69 s (9.78-11.16); 142.9 MB |
| `diagram-rhesus-direct` | 2.32 s; 155.7 MB | 1.46 s (1.36-1.50); 135.3 MB |
| `diagram-rhesus-rectilinear` | 3.30 s; 155.7 MB | 2.65 s (2.46-2.68); 147.5 MB |
| `diagram-example-direct` | 12.81 s; 253.8 MB | 5.10 s (4.80-5.22); 186.0 MB |
| `backfill-jmac` | 9.42 s; 186.4 MB | 0.99 s (0.96-0.99); 146.1 MB |
| `gvaConvergence-example` | 4.73 s; 185.3 MB | 0.75 s (0.70-0.77); 127.1 MB |
| `kinshipSparse-example` (no phase changed it) | 1.19 s; 143.1 MB | 1.31 s (1.23-1.35); 163.2 MB |
| `kinshipSparse-all` (no phase changed it) | 45.43 s; 153.5 MB | 50.68 s (47.16-50.75); 185.4 MB |

Every peak was the same in all three runs except two diagram and harem rows that differed by 6.3 and 0.1
MB, as at Phase 0. The two sparse-kinship rows are the control: their code is unchanged, so their
10% rise is this session's load.

**Which code ran.** Each phase kept the pre-campaign code for inputs the new code does not take (a factor
where text is expected, for example): nine fallbacks (`rareAlleleCountsGeneral()`, `geneDropGeneral()`,
`convertRelationshipsGeneral()`, `fillGroupMembersGeneral()`, `fillGroupMembersWithSexRatioGeneral()`,
`founderContributionMatrixGeneral()`, `retainedFounderAllelesGeneral()`, `kinshipGeneral()`,
`kinMatrix2LongFormGeneral()`). A probe traced all nine through nine harness scenarios and a sex-ratio
`groupAddAssign()`: none was called. The tracer does count a call (a sparse `kinship()` registered one).
So every number above is the new code's, and the shipped data never needs a fallback.

## 6. The app's memory: the pre-campaign code and today, one tool, one hour

The committed scripted session (`Rscript tools/perf/runAppSession.R <label> <out.csv>`, Phase 9a), run
three times on the pre-campaign code (`520bd5dc8`, a scratch worktree with today's `tools/perf/` copied
in) and three times on HEAD (`c4fb07453`), alternating, 11:38 to 12:02 CDT (load average 7.8 to 13.6).
Medians, then the range; the app's resident memory after each step.

| Step | Pre-campaign | Now | Difference |
|---|---|---|---|
| app started | 416.0 MB (416.0-419.2) | 417.8 MB (416.9-425.8) | +1.8 MB |
| upload + QC | 696.6 MB (695.1-738.7) | 516.0 MB (512.7-521.9) | -180.6 MB |
| open Genetic Diversity (no groups) | 698.8 MB (697.4-741.1) | 518.3 MB (515.9-524.2) | -180.5 MB |
| Genetic Value run (1,000 iterations) | 905.0 MB (902.9-907.3) | 622.3 MB (621.5-632.5) | -282.7 MB |
| open Summary Statistics | 921.6 MB (916.4-925.2) | 677.4 MB (675.7-687.5) | -244.2 MB |
| Breeding Groups: Form Groups (defaults) | 921.9 MB (916.7-925.5) | 683.4 MB (681.8-693.3) | -238.5 MB |
| open Genetic Diversity (groups formed) | 922.3 MB (917.1-925.9) | 684.4 MB (682.2-693.7) | -237.9 MB |
| Mate Pair: Find Eligible Pairs (defaults) | 1,989.2 MB (1,940.1-1,999.3) | 1,397.8 MB (1,374.4-1,712.3) | -591.4 MB |
| open Marker Genetics | 1,989.2 MB | 1,397.8 MB | -591.4 MB |
| open its Linkage and LD Block Metrics tab | did not finish | 2,495.4 MB (2,472.5-2,817.9), 14.2 s | |

- **The LD tab on the pre-campaign code** runs `convertRelationships()` on all 3,694 animals for its
  Realized Relatedness table, which is row 2's "never finishes": run 1 waited the tool's 15 minutes and
  stopped; runs 2 and 3 were capped at 2 minutes (the scratch copy's only change) and stopped the same
  way. Every earlier step finished in under 12 s.
- **The Genetic Value step** took 6.5 s on the old code and 2.8 s today in the app, waits included.
- **What each step left on the page:** each run on today's code showed 10 ranking rows, 3 histograms,
  3 group tables, 1 heat map, 315,023 pairs and 6,824,665 relatedness rows, as at 9a and 9b. The
  pre-campaign runs stopped before the tool prints that list, so their pages are not checked; their
  kinship traces show the upload's 3,694-animal `kinship()` and the analysis's 708, as at 9a's before.
- **The traces today:** the analysis computes kinship for 708 animals, Breeding Groups and Genetic
  Diversity for 166 (the 20 top-ranked animals and their ancestors), Mate Pair for 1,898, and the LD tab
  for all 3,694 plus its `convertRelationships()`.
- **Against the design's estimate** (`docs/planning/app-kinship-memory-design.md` section 11): about
  680 MB through Genetic Diversity; measured 684.4 MB.
- Mate Pair's step (+713 MB today) and the LD tab (+1,098 MB) are what the session holds most, and both
  are filed decisions (`BACKLOG.md`, "Mate Pair's default run uses about 1 GB" and "Marker Genetics'
  Realized Relatedness table holds every pair").

## 7. The gates

The owner's S1052 rule: the slowest of three fresh runs plus 25%, rounded up to 0.1 s; a peak plus 10%,
rounded up to a whole MB. A threshold only tightens.

| Gate | Phase 0 | Before this session | This session's runs | The rule gives | Now |
|---|---|---|---|---|---|
| `perf_reportGV_example_seconds` | 4.3 s | 0.8 s | 0.23, 0.23, 0.24 s | 0.3 s | **0.3 s** |
| `perf_geneDrop_example_peak_mb` | 164 MB | 72 MB | 65.1 MB x 3 | 72 MB | 72 MB |
| `perf_convertRelationships_300_seconds` | 8.0 s | 0.2 s | 0.08 s x 3 | 0.1 s | **0.1 s** |
| `perf_groupAddAssign_1000_seconds` | 29.2 s | 7.1 s | 5.49, 5.54, 5.93 s | 7.5 s | 7.1 s |
| `perf_kinMatrix2LongForm_all_peak_mb` | 1,077 MB | 344 MB | 312.4 MB x 3 | 344 MB | 344 MB |
| `perf_diagram_example_direct_seconds` | 16.1 s | 5.9 s | 4.80, 5.22, 5.10 s | 6.6 s | 5.9 s |
| `perf_backfill_jmac_seconds` | 11.9 s | 1.4 s | 0.96, 0.99, 0.99 s | 1.3 s | **1.3 s** |
| `perf_calcFEFG_synthetic10000_seconds` | (S1058) 0.2 s | 0.2 s | 0.09 s x 3 | 0.2 s | 0.2 s |
| `perf_kinship_synthetic10000_peak_mb` | (S1059) 502 MB | 502 MB | 455.7 MB x 3 | 502 MB | 502 MB |

Three tightened (`958a47e4f`); four already sat at the rule's value; two (Breeding Groups, the diagram)
would loosen under this session's loaded third pass, so they stay. The tarball gate
(`tarball_size_clean_export`, 5,000,000 B) is not a campaign gate and is unchanged. The ratchet's run on
the final tree is cited in the close-out receipt.

## 8. The budget tests and the exactness tests

- **The opt-in budget tests** (`NPRC_RUN_PERF=true`, the median of 3 runs each): all 8 files pass, 11
  tests, 12 expectations, 0 failed, 0 skipped, 102 s in all, started at load average 3.3 (12:47 CDT). Their
  ceilings against this session's harness medians: genome uniqueness 1.0 s, gene drop 2.4 s, the
  relationship table 0.5 s (0.08 s), Breeding Groups 14 s (5.54 s), founder statistics 0.6 s, kinship
  memory 500 and 600 MB, the diagram's solver 9.0 s, and the backfill and `gvaConvergence()` 2 s each
  (0.99 and 0.75 s). The plan asked each for at least 3x headroom over its phase's new time (its section
  5.2).
- **The exactness tests** (D1): the frozen pre-campaign copies in `tests/testthat/helper-perfReference.R`
  (17 functions, 1,110 lines) and the seven files that compare against them (`test_rareAlleleCounts.R`,
  `test_geneDropEquivalence.R`, `test_convertRelationshipsEquivalence.R`,
  `test_groupAddAssignEquivalence.R`, `test_founderStatsEquivalence.R`,
  `test_kinshipMemoryEquivalence.R`, `test_diagramSolverEquivalence.R`): 48 tests, 2,857 expectations,
  0 failed, 1 skipped (the 600-animal relationship check, opt-in), 65.9 s at load average about 8.
  They run in the normal suite on every CI platform.

## 9. Decisions

| | Question | Ruling |
|---|---|---|
| D1 | exact results for the same seed | exactly the same (S1051) |
| D2 | plain R first | plain R, revisited here: **stay plain R** (owner, S1066). Nothing still slow needs compiled code: harem trials and the diagram have plain-R levers left, and the two largest memory users are about what gets built. |
| D3 | exported functions unchanged | unchanged (S1051) |
| D4 | where the budgets live | opt-in budget tests plus ratchet gates (S1051) |
| D5 | how the app holds kinship | (c), each tab its own animals (S1062) |
| D6 | parallel dates for Build Earlier Snapshots | no (S1065) |
| D7 | Breeding Groups' default of 10 trials | keep 10 (S1057) |
| D8 | the relationship download's scope | not needed (S1055) |
| | `helper-perfReference.R` as the oracle | **keep it** (owner, S1066): the seven files go on proving the exact results on every CI platform; a later change meant to alter one of the 17 functions' results updates its copy and test in that change. |
| | the NEWS line | the owner's approved sentence, a "Speed and Memory" section in `NEWS.Rmd` (`7f479fc98`) |

The plan's risk 4 (exported helpers left unused) needs no action on issue #37: `alleleFreq()`,
`assignAlleles()`, `chooseAlleles()` and `getGenoDefinedParentGenotypes()` are all still called inside
the package (`R/rareAlleleCounts.R:125`, `R/geneDrop.R:144,273,278`), so the issue's "now used" marks
still hold.

## 10. Patterns across the campaign

1. **Removing repeated work gave the largest gains.** Genome uniqueness was the same count built twice
   with a factor rebuilt per iteration (Phase 1, 14x on the app's analysis); the relationship table grew
   one value at a time (Phase 3, about 535x at 600 animals); group formation repeated `setdiff()` on
   every group for every placement (Phase 4). The solver change (Phase 7) gained less (2.5x), because
   the solve's cost still grows with the cube of the number of animals (the plan's H5).
2. **The time estimates were good, the memory estimates optimistic.** Times landed at 0.66 to 1.38 of
   their estimates; two of the plan's three memory estimates missed (the kinship peak, the founder
   statistics) and the long form's held.
3. **Exactness held everywhere**, by frozen copies and `identical()`, and nine fallbacks carry the old
   code for unusual inputs that the shipped data never reaches.
4. **Peaks repeat exactly in a fresh process; times spread with the machine's load.** Memory gates were
   the reliable ones, as Phase 0 found; time gates held under +25% at loads up to 22.
5. **Resident memory shows what is built, not what is freed** (9b): removing the kept matrix showed in
   the app only where a step no longer built it (upload, -180.6 MB).
6. **What is left is mostly scope, not speed:** the two largest app costs are tables a user may not need
   in full (Mate Pair's pairs, the LD tab's every pair), and they are decisions about what to build.

## 11. Open items

**Filed this session in `BACKLOG.md`** (owner ruling S1066, all four leftovers):
- Harem trials: 1,000 harem trials take 10.69 s against 5.54 s for plain groups; the extra is the
  harem's age work redone every trial (`getPotentialSires()`, `getCurrentAge()`, `groupsWithoutSire()`,
  `initializeHaremGroups()`; owner, S1056).
- The diagram's time outside the solver: 5.10 s at 708 animals, about 1.7 s of it outside the solve and
  1.0 s of that `t(pmat) %*% pmat`, kept at S1060 because `crossprod()` can give other bits on another
  platform.
- The founder statistics' memory peak on larger inputs: `calcFGSE()` 225.6 to 253.6 MB on the synthetic
  colony and 236.5 to 257.5 MB on all 3,694, `calcFEFG()` 233.2 to 247.7 MB on all 3,694, while their
  time fell about tenfold.
- The nine fallbacks: whether their input types move onto the fast paths, one test per type; none is
  reached on the shipped data, and S1054 found 14 of `geneDropGeneral()`'s 19 test inputs end in an
  error today.

**Already filed:** Mate Pair's default run (`BACKLOG.md`, DECISION NEEDED), Marker Genetics' Realized
Relatedness table (DECISION NEEDED), Summary Statistics keeping its relationship table (DECISION NEEDED),
a colony above 3,694 animals (BLOCKED, the larger-colony thread), and the diagram's cap (issue #138).

**Recorded here only:** the scripted app session has no Summary Statistics download and no genotype
upload, so those every-animal reads are measured by module tests, not in the running app; and the
browser-tier files were not re-run this session (no code changed since S1065; the nightly `shinytest2`
job runs them, its one red test already filed).

## 12. What this surface cannot show

- Timings on another machine, on CI's runners, or on Windows or Linux (D4); the gates hold this Mac's
  numbers, and the busy second and third passes put some of them near 10% high.
- A real colony above 3,694 animals: the 10,000-animal colony is generated.
- The pre-campaign app's LD tab and anything after it: it did not finish.
- The browser's own memory: section 6 is the R process that serves the app.
