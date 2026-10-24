# Performance baseline: the starting numbers of the performance and memory campaign (S1052, 2026-10-24)

**Deliverable of S1052:** Phase 0 of `docs/planning/performance-memory-campaign-plan.md` (its section
7). Every row of the plan's section 3 re-measured three times with the committed harness, the app's
memory during a scripted browser session, and the ratchet gates declared from these numbers. No
package code changed.

## In plain words

The measuring tool now lives in the repository (`tools/perf/`), so every later phase can measure its
change the same way, on the same inputs, before and after. Its numbers agree with the plan's: the
Genetic Value analysis on the example takes **3.28 s** (the plan measured about 3.5 s), and almost all
of it is still the genome-uniqueness count (1.53 s + 1.41 s).

One finding changes how memory can be compared. **Each peak-memory figure came out exactly the same
in all three runs** (all 20 scenarios), with each measurement in a fresh R process. The plan saw one
call (`geneDrop()` on the synthetic colony) peak at 578 MB in one run and 300 MB in another; both of
those runs had done other work first in the same session, which most likely explains the swing. So
memory is a reliable gate here, as long as each measurement runs in its own process, as `run.R` does.

Seven gates now hold today's numbers, one for each later phase that is meant to lower a number
(section 4).

## 1. How the numbers were measured

- **Machine:** Apple M2 Max, 96 GB, macOS 27.0 (Darwin 27.0.0); R 4.6.1 (2026-06-24) with R's
  reference BLAS, single-threaded. The 1-minute load average before each measurement ranged from 2.7
  to 9.8 (median 3.8): other work was running, as during the plan's own runs.
- **Harness:** `tools/perf/harness.R` and `tools/perf/run.R` at commit `7bd35faec`. Each scenario ran
  as `Rscript tools/perf/run.R <scenario>` from the project root, in its own process, as a ratchet gate
  runs it. Three passes over all 20 scenarios ran from 07:21 to 07:38 CDT, so every row below is three
  runs: the median, then the range.
- **Time:** elapsed seconds of the one call. **Peak:** `gc()`'s "max used" Mb after the call, minus the
  memory in use before it (both columns found by name, so R 4.6's "limit (Mb)" column is skipped).
  **Result:** `object.size()` of the returned value.
- **Inputs** (the plan's section 2; each size re-checked on this run's inputs):
  - "example (app trim)": `examplePedigree` through the app's path (QC with minimum parent age 2, the
    living animals as the population, pedigree numbers, the trim): 708 rows, 332 probands, 8 generations.
  - "example (all 3694)": the same pedigree untrimmed, every animal in the population.
  - "synthetic 10000": `synthColony(10000, seed = 1)`, then the app's path: 6,090 rows, 2,981 living, 9
    generations. **Synthetic**, and labelled so every time it is cited: no real studbook above 3,694
    animals is in the repository (`BACKLOG.md`, the BLOCKED larger-colony thread).
  - "rhesus 375": `rhesusPedigree` through `qcStudbook()`.
  - "jmac 2590": `inst/extdata/examples/deidentified_jmac_ped.csv` with blank cells as NA, QC with no
    minimum parent age: 4,055 rows after QC adds stand-in parents.
- **Settings** (reproduced from S1050's scratch probes, so the rows compare with the plan's): the stages
  at 1,000 iterations, threshold 4, `byID = TRUE`, `set.seed(20261024)` before the gene drop; Breeding
  Groups as the tutorial sets it up (the living animals with a recorded parent, trimmed to their
  ancestors; the 280 candidates born before 2013 and alive; 6 groups; `set.seed(1)`); the diagram on
  the QC'd rhesus pedigree and on the app trim; the backfill on the jmac studbook at 2000-01-01,
  2010-01-01 and 2018-07-01 with 1,000 iterations, threshold 4, `set.seed(3)`; `gvaConvergence()` at
  `nMax = 3000`, threshold 4, `set.seed(5)`.

## 2. The Genetic Value path, stage by stage (1,000 iterations, threshold 4, `byID = TRUE`)

Each cell: seconds, median (range); peak; result. "Plan" is the plan's section 3.1 (S1050).

| Stage | example (app trim) | example (all 3694) | synthetic 10000 |
|---|---|---|---|
| `kinship()` of the analysis pedigree | 0.01 s (0.01-0.01); 20.8 MB; 3.9 MB | 0.46 s (0.46-0.50); 210.1 MB; 104.6 MB | 1.52 s (1.51-1.52); 569.9 MB; 283.7 MB |
| `filterKinMatrix()` to the probands | 0.00 s; 0.9 MB; 0.9 MB | 0.02 s (0.02-0.02); 104.4 MB; 104.6 MB | 0.02 s (0.01-0.02); 68.2 MB; 68.2 MB |
| `geneDrop()` | 0.13 s (0.13-0.13); 148.5 MB; 5.6 MB | 1.46 s (1.45-1.50); 299.6 MB; 28.6 MB | 3.48 s (3.47-3.50); 531.4 MB; 47.1 MB |
| `calcGU()` | **1.53 s** (1.49-1.57); 142.2 MB | **17.54 s** (17.51-17.86); 274.3 MB | **13.91 s** (13.89-13.91); 263.7 MB |
| `calcGUSE()` | **1.41 s** (1.41-1.42); 147.7 MB | **17.75 s** (17.72-17.87); 321.6 MB | **13.98 s** (13.96-13.98); 307.8 MB |
| `calcFEFG()` | 0.08 s (0.08-0.08); 75.3 MB | 0.65 s (0.64-0.65); 233.2 MB | 1.04 s (1.03-1.05); 217.9 MB |
| `calcFGSE()` | 0.08 s (0.08-0.09); 89.3 MB | 0.64 s (0.64-0.64); 236.5 MB | 1.07 s (1.07-1.10); 225.6 MB |
| `offspringCounts()` | 0.00 s; 4.5 MB | 0.01 s; 7.9 MB | 0.02 s; 9.2 MB |
| **all stages (sum)** | 3.26 s (3.20-3.29) | 38.50 s (38.48-39.05); plan about 41 s | 35.03 s (35.00-35.04); plan about 36 s |
| **`reportGV()` whole** | **3.28 s** (3.27-3.38); 162.9 MB; 1.0 MB; plan about 3.5 s, 161 MB | | |

## 3. The other time-intensive work

| Scenario | Input | Time, median (range) | Peak | Result | Plan (S1050) |
|---|---|---|---|---|---|
| `convertRelationships-150` | first 150 example animals (11,325 rows) | 1.35 s (1.34-1.35) | 271.7 MB | 0.4 MB | 1.39 s |
| `convertRelationships-300` | first 300 (45,150 rows) | 6.28 s (6.27-6.34) | 271.7 MB | 1.6 MB | 6.13 s |
| `convertRelationships-600` | first 600 (180,300 rows) | 64.21 s (64.15-64.69) | 271.7 MB | 6.3 MB | 64.95 s |
| `kinMatrix2LongForm-all` | example, all 3,694 (13,645,636 rows) | 1.53 s (1.52-1.54) | 979.0 MB | 312.7 MB | 1.52 s, 1,007 MB |
| `kinMatrix2LongForm-all-removeDups` | the same (6,824,665 rows) | 1.11 s (1.10-1.12) | 915.5 MB | 182.6 MB | 0.77 s, 929 MB |
| `groupAddAssign-10` | 6 groups, 280 candidates | 0.35 s (0.35-0.37) | 139.0 MB | 0.1 MB | 0.35 s |
| `groupAddAssign-1000` | the same, 1,000 trials | 23.04 s (23.02-23.30) | 139.0 MB | 0.1 MB | 23.55 s |
| `groupAddAssign-harem-10` | 6 harems | 0.38 s (0.38-0.38) | 139.0 MB | 0.1 MB | 0.50 s |
| `groupAddAssign-harem-1000` | 6 harems, 1,000 trials | 27.19 s (26.10-28.04) | 139.0 MB | 0.1 MB | 25.98 s |
| `diagram-rhesus-direct` | rhesus 375 | 2.32 s (2.30-2.33) | 155.7 MB | 0.3 MB | 2.48 s |
| `diagram-rhesus-rectilinear` | rhesus 375 | 3.30 s (3.28-3.35) | 155.7 MB | 0.6 MB | 3.33 s |
| `diagram-example-direct` | example (app trim), 708 | 12.81 s (12.76-12.82) | 253.8 MB | 0.6 MB | 13.90 s, 223 MB |
| `backfill-jmac` | jmac, 3 dates x 1,000 | 9.42 s (9.36-9.46) | 186.4 MB | 0.0 MB | 10.14 s |
| `gvaConvergence-example` | example (app trim), `nMax = 3000` | 4.73 s (4.67-4.75) | 185.3 MB | 0.0 MB | 4.86 s |
| `kinshipSparse-example` | example (app trim) | 1.19 s (1.15-1.21) | 143.1 MB | 1.5 MB | 1.17 s |
| `kinshipSparse-all` | example, all 3,694 | 45.43 s (44.99-45.64) | 153.5 MB | 11.9 MB | 44.89 s |

**How steady the numbers are.** Every row taking a second or more varied by at most 7.1% between its
three runs (the widest: `groupAddAssign-harem-1000`, 26.10 to 28.04 s), and most by under 3%, while
the load average moved between 2.7 and 9.8. Rows under 0.1 s vary more in percent because `run.R`
prints times to the hundredth. Every peak was the same in all three runs (the backfill's differed by
0.1 MB).

**Against the plan's section 3.** Most rows agree within 10%. Where they do not, the plan's figure came
from a call made after other work in the same session:

- `calcGU()` on all 3,694: 17.54 s against 19.70 s.
- `kinMatrix2LongForm(removeDups = TRUE)`: 1.11 s against 0.77 s. S1050 ran it right after the full
  long form.
- `calcFEFG()` on the app trim: 0.08 s against 0.18 s.
- The memory peaks of `geneDrop()` (299.6 against 338 MB, 531.4 against 578 MB), `calcFEFG()` and
  `calcFGSE()` on the larger inputs (218 to 237 MB against 307 to 446 MB), Breeding Groups (139 MB
  against about 175 MB) and the diagram on the app trim (253.8 MB against 223 MB).

The plan's Phase 0 check, "`run.R reportGV-example` reproduces about 3.5 s within 30%", holds: 3.28 s
is 6% under.

**What a measurement costs.** The whole `run.R` process, which loads the package and builds the input
before the measured call, took (median of three) 6 s for `reportGV-example`, 7 s `gvStages-example`,
43 s `gvStages-all`, 40 s `gvStages-synthetic10000`, 4 / 9 / 67 s `convertRelationships-150/300/600`,
5 s and 4 s for the two long forms, 3 / 25 / 2 / 30 s for the four Breeding Groups scenarios,
4 / 6 / 15 s for the three diagrams, 12 s `backfill-jmac`, 7 s `gvaConvergence-example`, and 3 s and
48 s for the two sparse kinships. One pass over all 20 takes about 5.7 minutes.

## 4. The app's memory during a scripted session

The installed package (a scratch-library install of the working tree), driven through `shinytest2` in
Chrome: upload `ExamplePedigree.csv` and run QC, then the Genetic Value analysis at the app's defaults
(1,000 iterations, threshold 4), then the Summary Statistics tab, then Breeding Groups at its defaults
(top ranked, 10 trials). After each step the app process's resident memory was read with
`ps -o rss= -p <pid>`. The script is Appendix A. Each run was checked to have done each step's work:
the rankings table showed its 10 rows, the three Summary Statistics histograms were drawn, and the
Breeding Groups display held 3 tables (908 characters of text).

| Step | Run 1 | Run 2 | Run 3 | Median | Change |
|---|---|---|---|---|---|
| app started | 440.7 MB | 438.5 MB | 444.3 MB | 440.7 MB | |
| upload + QC | 699.1 MB | 697.4 MB | 702.9 MB | 699.1 MB | +258.4 MB |
| Genetic Value (1,000 iterations) | 832.3 MB | 830.2 MB | 834.5 MB | 832.3 MB | +133.2 MB |
| Summary Statistics | 834.6 MB | 834.4 MB | 836.9 MB | 834.6 MB | +2.3 MB |
| Breeding Groups (app defaults) | 837.2 MB | 837.0 MB | 839.6 MB | 837.2 MB | +2.6 MB |

Resident memory is what the operating system holds for the process. It seldom falls when R frees
memory, so a later step can reuse what an earlier step freed, and a small change does not mean the
step used little. Which step builds the app's shared full-pedigree kinship matrix (104.6 MB for the
example, `R/appServer.R:353`) is not visible in this table. That question belongs to Phase 8, the app
memory design.

## 5. The gates (owner-approved, S1052)

The owner chose one gate for each later phase that is meant to lower a number, on its smallest input
that shows the number, with +25% room on time (over the slowest of the three runs, rounded up to 0.1 s)
and +10% on memory (over the peak, rounded up to a whole MB). They are in
`methodology/.quality-gates.json`, and each phase tightens its own.

| Gate | Phase | Scenario and number | Today | Fails above | Run time |
|---|---|---|---|---|---|
| `perf_reportGV_example_seconds` | 1, genome uniqueness | `reportGV-example`, seconds | 3.28 s (3.27-3.38) | 4.3 s | 6 s |
| `perf_geneDrop_example_peak_mb` | 2, the gene drop | `gvStages-example`, the `geneDrop` row's peak | 148.5 MB | 164 MB | 7 s |
| `perf_convertRelationships_300_seconds` | 3, the relationship table | `convertRelationships-300`, seconds | 6.28 s (6.27-6.34) | 8.0 s | 9 s |
| `perf_groupAddAssign_1000_seconds` | 4, group formation | `groupAddAssign-1000`, seconds | 23.04 s (23.02-23.30) | 29.2 s | 25 s |
| `perf_kinMatrix2LongForm_all_peak_mb` | 6, kinship memory | `kinMatrix2LongForm-all`, peak | 979.0 MB | 1,077 MB | 5 s |
| `perf_diagram_example_direct_seconds` | 7, the diagram's solver | `diagram-example-direct`, seconds | 12.81 s (12.76-12.82) | 16.1 s | 15 s |
| `perf_backfill_jmac_seconds` | 10, follow-through | `backfill-jmac`, seconds | 9.42 s (9.36-9.46) | 11.9 s | 12 s |

Together they add about 79 s to every close-out's ratchet run. The first ratchet run with them passed
all 8 gates (`quality_ratchet: 8/8 pass · 0 fail · 0 unmeasured · results 58d5e14ea1fc · manifest
ce133ee1db5d`; 119 s with the tarball gate). It was a fourth measurement: the two peaks were again
148.5 MB and 979 MB exactly, and the five times read 3.39, 6.44, 23.83, 13.18 and 9.71 s, about 3%
above the medians above. Phase 5 (founder statistics) declares
its gate in Phase 5: its calls take 0.08 s on the app trim, too short to gate, and the larger inputs
take about 40 s to run until Phase 1 shortens them. Phases 8 and 9 (the app's memory) have no gate:
the app run needs Chrome and an installed copy, which a gate does not have.

## 6. What this surface cannot show

- Timings on another machine, on CRAN's or GitHub's runners, or on Windows or Linux: the gates hold
  this Mac's numbers, and another machine needs its own baseline (the plan's D4).
- A real colony above 3,694 animals (only the synthetic one).
- Memory compared across different ways of running: the peaks repeat exactly for one scenario in one
  fresh process; a call made after other work in the same session can peak differently (the plan's
  578 MB against 300 MB).
- The browser's own memory; the table in section 4 is the R process that serves the app.

## 7. For the phases that follow

- Measure before and after with `Rscript tools/perf/run.R <scenario>` from the project root, in the
  same session. A `--quick` run uses a 150-animal synthetic stand-in, says "quick" on every line, and
  is never a baseline.
- Tighten your phase's gate in `methodology/.quality-gates.json` to the new value with the same room
  (+25% time, +10% memory), and run `python3 methodology/quality_ratchet.py --run`.
- `lintr::lint_package()` does not read `tools/` (lintr 3.4.0 reads `R`, `tests`, `inst`, `vignettes`,
  `data-raw`, `demo` and `exec`), so lint the harness with
  `lintr::lint("tools/perf/harness.R")` and `lintr::lint("tools/perf/run.R")`.
- `tests/testthat/test_perfHarness.R` checks the harness itself (20 tests, about 16 s); it skips
  outside the source tree.

## Appendix A. The scripted app session (scratch, S1052)

Kept here rather than committed as code (owner's choice, S1052): Phase 8 decides whether it joins
`tools/perf/` with its own test. The script below is the one that ran, with its progress printing
left out. Install the working tree into a scratch library from the project root, then run the script
from a folder outside the project, so renv does not start:

```sh
R_LIBS=<scratch lib>:<renv lib> RENV_CONFIG_AUTOLOADER_ENABLED=false \
  R CMD INSTALL --no-docs --library=<scratch lib> .
R_LIBS=<scratch lib>:<renv lib> RENV_CONFIG_AUTOLOADER_ENABLED=false NOT_CRAN=true \
  NPRC_RUN_E2E=true Rscript app_memory.R run1 app_memory_run1.csv
```

```r
args <- commandArgs(trailingOnly = TRUE)
runLabel <- args[[1L]]
outFile <- args[[2L]]
library(shinytest2)
appDir <- system.file("shinytest", package = "nprcgenekeepr")
stopifnot(nzchar(appDir))
app <- AppDriver$new(appDir, name = "perf_app_memory", height = 900,
                     width = 1400, load_timeout = 120000, timeout = 600000,
                     screenshot_args = FALSE)
on.exit(app$stop(), add = TRUE)
## The app's R process: the one listening on the app's port.
port <- sub(".*:([0-9]+).*", "\\1", app$get_url())
pid <- system2("lsof", c("-nP", paste0("-iTCP:", port), "-sTCP:LISTEN", "-t"),
               stdout = TRUE)[[1L]]
rssMb <- function() {
  as.numeric(system2("ps", c("-o", "rss=", "-p", pid), stdout = TRUE)) / 1024
}
rows <- list()
step <- function(name, seconds) {
  rows[[length(rows) + 1L]] <<- data.frame(run = runLabel, step = name,
                                           seconds = seconds, rssMb = rssMb())
}
timed <- function(expr) {
  t0 <- proc.time()[["elapsed"]]
  force(expr)
  proc.time()[["elapsed"]] - t0
}
step("app started", 0)
csv <- system.file("extdata", "examples", "ExamplePedigree.csv",
                   package = "nprcgenekeepr")
step("upload + QC (ExamplePedigree.csv)", timed({
  app$upload_file(`dataInput-pedigreeFileOne` = csv)
  app$click("dataInput-getData")
  app$wait_for_idle(duration = 1000, timeout = 600000)
}))
step("Genetic Value (1,000 iterations)", timed({
  app$set_inputs(mainNavbar = "Genetic Value Analysis")
  app$set_inputs(`geneticValue-nIterations` = 1000)
  app$click("geneticValue-runAnalysis")
  app$wait_for_idle(duration = 2000, timeout = 600000)
}))
step("Summary Statistics", timed({
  app$set_inputs(mainNavbar = "Summary Statistics")
  app$wait_for_idle(duration = 2000, timeout = 600000)
}))
step("Breeding Groups (app defaults)", timed({
  app$set_inputs(mainNavbar = "Breeding Groups")
  app$click("breedingGroups-formGroups")
  app$wait_for_idle(duration = 2000, timeout = 600000)
}))
## What each step left on screen, so a step that silently did nothing shows.
shown <- c(
  rankingsRows = app$get_js(paste0("document.querySelectorAll(",
    "'#geneticValue-rankingsTable tbody tr').length")),
  summaryPlots = app$get_js(paste0("document.querySelectorAll(",
    "'#summaryStats-mkHist img, #summaryStats-zscoreHist img, ",
    "#summaryStats-guHist img').length")),
  groupsTextChars = app$get_js(paste0("(document.querySelector(",
    "'#breedingGroups-groupsDisplay') || {innerText: ''}).innerText.length")),
  groupsTables = app$get_js(paste0("document.querySelectorAll(",
    "'#breedingGroups-groupsDisplay table').length"))
)
print(shown)
utils::write.csv(do.call(rbind, rows), outFile, row.names = FALSE)
```

The step times it records include a quiet wait of 1 to 2 s after each step, so they are not
processing times; section 4 gives memory only.
