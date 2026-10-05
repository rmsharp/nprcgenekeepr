# Candidate C (mate-line signposting): do any mate-lines still span generation rows? (S910, 2026-10-05)

> **Status:** measurement DONE; no behaviour, test or `R/` change. `BACKLOG.md`'s "Candidate C" item (found
> S473, kept open by the owner S898, "DECISION NEEDED: product sign-off to pursue") proposed dashed/colored/titled
> styling for a mate-line that spans several generation rows. This audit checks whether that situation still
> occurs. It does not: the owner closed Candidate C and replaced it with a smaller item about the dashed
> duplicate-animal links (see "Owner ruling" at the end).

## Audit summary

- **Scope:** every connector the Pedigree Diagram tab draws, as laid out by `makePedigreeMatingLayout()`
  (`R/modPedigree.R:682`), in both edge styles.
- **Question:** a *mate-line* is the line from a parent (or from a parent's duplicate node) to its mating
  point (the `__union_*` node). It *spans rows* when the parent's row differs from the mating point's row.
  How many do, today?
- **Result: none.** 0 of 474 mate-lines in the 375-animal rhesus pedigree as the app lays it out (after QC);
  0 in each of the 6 small bundled pedigrees (10 to 14 animals, 44 mate-lines in all) and in `rhesusPedigree_fromCenter.csv` (the same 375 animals, so one data point, not two); 0 of 2,032 in 60 random stress pedigrees (synthetic) in which
  672 of 1,016 mating units had parents of different input generations. The rectilinear style's D2 "dogleg"
  waypoint nodes (`__proj_*`), the construct Candidate C would have extended, number **0** on the rhesus
  pedigree.
- **Why:** S573 shipped Candidate A (gen-aware anchor selection), after which the anchor-row mismatch is "closed
  by construction" (`matingUnits$gen == genOf[[anchor]]`, the `docs/planning/issue144-anchor-row-mismatch-fix-plan.md`
  status banner); #143's fix already puts a non-anchor occurrence on its unit's row. The two together leave
  no mate-line off its unit's row. Candidate C's own premise ("a mate-line spanning several generations")
  therefore describes the layout as it was before S573.
- **What still crosses rows:** the dashed curved links that join an animal's repeat appearance (a "duplicate"
  node) back to its main appearance. On the rhesus pedigree, 111 of 170 cross at least one row, 51 cross two
  or more, and 8 cross three or more. They are already dashed and curved (`R/makePedigreeDiagramData.R:1979-2014`)
  and the user manual explains them, but the in-diagram legend has no row for them and the edge table has no
  `title` (hover) column.

| Connector type (direct-style geometry) | Count, rhesus QC'd (375 animals) | Rows crossed |
|---|---|---|
| mate-line, real parent to mating point | 304 | 0 for all |
| mate-line, duplicate node to mating point | 170 | 0 for all |
| mating point to child | 251 | 1 for all (one row down) |
| link between a duplicate and its animal (dashed, curved) | 170 | 59 cross 0 rows; 111 cross 1 or more (51 cross 2 or more, 8 cross 3 or more) |

(The two mate-line rows sum to 474; the link row is 170. The 6 small pedigrees show the same pattern: every
mate-line 0 rows, every child edge 1 row, the few dashed links 0 or 1 row.)

## Findings

### Finding 1: no mate-line spans rows in any pedigree tested (Informational: it retires the item's premise)

`spanAll.R` classifies every edge of the direct-style layout by endpoint kind and measures
`abs(y[from] - y[to]) / 150` (rows are 150 apart). Every `real->union` and `dup->union` edge has gap 0 in all 8
pedigrees run: the rhesus pedigree (375 animals, 237 mating units, 474 mate-lines), the 6 small bundled ones, and
`rhesusPedigree_fromCenter.csv`, which gave the identical table (S907 measured it equal to the rhesus CSV on the 8 shared columns).
`rectCheck.R` confirms the rectilinear layout puts every direct-style node on the same row (`y` equal for all 782),
so the direct-style measurement holds for both styles, and that the rectilinear layout has **0** `__proj_` nodes
(it has 142 `__jog_` nodes, which are collision jogs, not mate-line doglegs).

### Finding 2: random stress pedigrees do not break it (Informational)

`synthSpan.R` builds 60 random pedigrees (synthetic; 3 to 5 generations of 4 to 8 animals, each child's sire and dam
drawn from any earlier animal of the right sex, so matings cross generations freely), recomputes `gen` with
`findGeneration()`, and lays each out. It is not vacuous: 672 of the 1,016 mating units had a sire and a dam with
different input generations. Result: 2,032 mate-lines, 0 spanning rows, maximum gap 0.

### Finding 3: the dashed duplicate-animal links are what crosses rows (Moderate: it is the real remaining gap, and it is small)

Each duplicate node has one dashed, curved link to the animal's main appearance, built as `dashes = TRUE`,
`smooth.type = "curvedCW"`, roundness 0.2 (`R/makePedigreeDiagramData.R:1999-2008`). On the rhesus pedigree there are
170, one per duplicate node, in both styles. The user manual describes them (`vignettes/manual_components/_pedigree_browser.Rmd:90-91`:
"each occurrence joined back to its main occurrence by a curved, dashed line"). The in-diagram legend
(`R/modPedigree.R:726-779`) shows the sex shapes, "Affected" and the MZ/DZ/? twin rows, and nothing for this link; the
edge table's columns are `from, to, dashes, smooth.enabled, smooth.type, smooth.roundness, color, width`, so there
is no hover text on any edge.

### Finding 4: Candidate C's other half (dashed/colored styling of a mate-line) would clash with the existing dashed link (Minor)

Dashed already means "same animal, shown again" in this diagram (Finding 3). Dashing a mate-line to say "this
spans generations" would give one line style two meanings. This is moot while no mate-line spans rows, and is a
design point for any future signposting.

## Items audited

| Item | Status | Findings |
|---|---|---|
| Mate-line geometry on the app's layout (`makePedigreeMatingLayout()`, both styles) | Audited (measured) | 1, 2 |
| D2 dogleg block (`R/makePedigreeDiagramData.R:2238-2310`) | Observed through its output only (0 waypoints); not audited | 1 |
| Duplicate-animal link construction (`R/makePedigreeDiagramData.R:1979-2014`) | Read and measured | 3 |
| Diagram legend (`R/modPedigree.R:726-779`) and its tests (`tests/testthat/test_modPedigree.R:1270-1424`) | Read | 3 |
| User manual's description of the dashed link (`_pedigree_browser.Rmd:90-91`) | Read | 3 |

## Comparison with prior work

- S473 designed Candidate C against the layout of 2026-08-04, in which 51 of 237 rhesus mating units had an
  anchor off its unit's row (issue #144's own count). S474 (Candidate B, row threading) and then S573
  (Candidate A, which deleted B's `effGenOf` and made the match structural) removed that population.
- S573's live render recorded the redistribution Candidate A causes (duplicate nodes 128 to 102, multi-anchor
  individuals 2 to 22, maximum 5). Each duplicate node is the end of one dashed link (Finding 3). S573 counted 102 duplicate nodes in its render; today's
  QC'd layout has 170. I did not trace the difference (the row-order item, S905, shows the QC step alone moves layout counts).
- The `BACKLOG.md` text said Candidate C remained open "if the owner judges, from that live render, that remaining
  cross-generation mate-lines still benefit from signposting". This audit finds no remaining mate-line to judge.

## Not measured

- Colonies other than the bundled pedigrees (no baboon pedigree is bundled); `ExamplePedigree.csv` (3,694
  animals; over the app's 400-animal rectilinear cap, `R/modPedigree.R:457`, and not laid out here).
- Whether any input reaches the D2 dogleg block at all. The #144 plan (§8) records a dangling-parent case that
  crashes there; this audit did not try dangling parents. If no real input reaches the block, it is dead code, which
  is its own question and was not pursued (report, don't fix).
- What a user sees: no screenshot was taken. The measurements are of the layout's coordinates.

## Recommendations

1. **Close Candidate C**: its target (a mate-line spanning rows) occurs in 0 of the mate-lines laid out here
   (474 rhesus + 44 in the 6 small examples + 2,032 synthetic).
2. If anything is wanted for the lines that do cross rows, make it a new, smaller item about the dashed
   duplicate-animal links: a legend row (small; the twin rows already ride the same `visLegend()` call) and/or hover
   text (larger; edges have no `title` column today).

## Owner ruling (S910, 2026-10-05)

Recommendation 2 was taken: **Candidate C is closed and replaced** by a new `BACKLOG.md` item for the dashed
duplicate-animal links (DECISION NEEDED on what the legend and hover text should say). Nothing is built until the
owner approves that item separately.

## Appendix: scripts (run from the repo root; each prints what the report quotes)

Run with `Rscript <file>`; `rectCheck.R`, `spanAll.R` and `synthSpan.R` need `pkgload` and the package source. Save
each under the name shown. `synthSpan.R` is seeded (`set.seed(910)`), so it reproduces exactly on the same R version.

### `spanAll.R`

```r
## S910: which connectors cross rows, across every small bundled pedigree (direct style = the raw geometry)
suppressMessages(pkgload::load_all(".", quiet = TRUE))
source("tests/testthat/helper-qcdRhesusPed.R")
qcOne <- function(f) {
  raw <- read.csv(system.file("extdata", "examples", f, package = "nprcgenekeepr"),
                  stringsAsFactors = FALSE)
  suppressWarnings(suppressMessages(
    runQcStudbook(raw, minSireAge = NULL, minDamAge = NULL, reportChanges = TRUE)))$cleaned
}
fixtures <- list("rhesus QC'd (375)" = qcdRhesusPed())
for (f in c("example_pedigree_backcross.csv", "example_pedigree_consanguinity.csv",
            "example_pedigree_first_cousin.csv", "example_pedigree_half_sib.csv",
            "example_pedigree_linebreeding.csv", "example_ancestry_pedigree.csv",
            "rhesusPedigree_fromCenter.csv"))
  fixtures[[f]] <- tryCatch(qcOne(f), error = function(e) { cat("SKIPPED", f, conditionMessage(e), "\n"); NULL })
ROW <- 150
kind <- function(id) ifelse(grepl("^__union_", id), "union", ifelse(grepl("^__dup", id), "dup", "real"))
out <- list()
for (nm in names(fixtures)) {
  ped <- fixtures[[nm]]; if (is.null(ped)) next
  if (nrow(ped) > 400) { cat("skip (over cap)", nm, nrow(ped), "\n"); next }
  d <- suppressWarnings(suppressMessages(makePedigreeMatingLayout(ped, edgeStyle = "direct")))
  y <- setNames(d$nodes$y, d$nodes$id)
  e <- d$edges
  e$type <- paste0(kind(e$from), "->", kind(e$to))
  e$gap <- abs(y[e$from] - y[e$to]) / ROW
  cat(sprintf("\n== %s: %d animals, %d units\n", nm, nrow(ped), sum(grepl("^__union_", d$nodes$id))))
  print(as.data.frame.matrix(table(e$type, cut(e$gap, c(-1, 0, 1, 2, 3, Inf), labels = c("0 rows", "1", "2", "3", "4+")))))
  out[[nm]] <- e
}
```

### `rectCheck.R`

```r
## S910: does the rectilinear style change which rows the real/duplicate nodes sit on,
## and does it ever create a D2 dogleg waypoint (__proj_) on the app's real pedigree?
suppressMessages(pkgload::load_all(".", quiet = TRUE))
source("tests/testthat/helper-qcdRhesusPed.R")
ped <- qcdRhesusPed()
dirc <- suppressWarnings(suppressMessages(makePedigreeMatingLayout(ped, edgeStyle = "direct")))
rect <- suppressWarnings(suppressMessages(makePedigreeMatingLayout(ped, edgeStyle = "rectilinear")))
ids <- dirc$nodes$id
stopifnot(all(ids %in% rect$nodes$id))
cat("nodes in both styles:", length(ids), "\n")
cat("same y (row) for every direct-style node in the rectilinear layout:",
    all(dirc$nodes$y == rect$nodes$y[match(ids, rect$nodes$id)]), "\n")
cat("rectilinear __proj_ (D2 dogleg) nodes:", sum(grepl("^__proj_", rect$nodes$id)), "\n")
cat("rectilinear __jog_ nodes:", sum(grepl("^__jog_", rect$nodes$id)), "\n")
isLink <- function(e) (grepl("^__dup", e$from) & !grepl("^__", e$to)) | (!grepl("^__", e$from) & grepl("^__dup", e$to))
cat("duplicate-animal links, direct:", sum(isLink(dirc$edges)), " rectilinear:", sum(isLink(rect$edges)), "\n")
y <- setNames(dirc$nodes$y, ids)
l <- dirc$edges[isLink(dirc$edges), ]
g <- abs(y[l$from] - y[l$to]) / 150
cat("links crossing >=1 row:", sum(g >= 1), " >=2 rows:", sum(g >= 2), " >=3 rows:", sum(g >= 3), " of", length(g), "\n")
cat("link columns (no 'title' column on edges):", names(dirc$edges), "\n")
```

### `synthSpan.R`

```r
## S910 (synthetic, labelled as such): can ANY input make a mate-line span rows?
## Random pedigrees where parents are drawn from ANY earlier generation (cross-generation matings,
## backcrosses, hub sires), QC'd by getPedigree-style gen via the package's own path.
suppressMessages(pkgload::load_all(".", quiet = TRUE))
set.seed(910)
mk <- function(nGen, perGen) {
  ids <- character(); sex <- character(); sire <- character(); dam <- character(); gen <- integer()
  for (g in 0:(nGen - 1)) for (k in seq_len(perGen)) {
    id <- sprintf("G%dK%d", g, k); sx <- if (k %% 2) "M" else "F"
    if (g == 0) { s <- NA; d <- NA } else {
      sirePool <- ids[sex == "M"]; damPool <- ids[sex == "F"]
      s <- sample(sirePool, 1); d <- sample(damPool, 1)
    }
    ids <- c(ids, id); sex <- c(sex, sx); sire <- c(sire, s); dam <- c(dam, d); gen <- c(gen, g)
  }
  data.frame(id = ids, sire = sire, dam = dam, sex = sex, gen = gen, stringsAsFactors = FALSE)
}
## recompute 'gen' the way the package does (longest-path) so rows follow the app's rule
res <- list()
for (trial in 1:60) {
  ped <- mk(nGen = sample(3:5, 1), perGen = sample(4:8, 1))
  ped$gen <- NULL
  ped$birth <- as.Date("2000-01-01") + 365L * as.integer(sub("G(\\d+)K.*", "\\1", ped$id)) * 4L
  ped$gen <- tryCatch(findGeneration(ped$id, ped$sire, ped$dam), error = function(e) NULL)
  if (is.null(ped$gen)) next
  d <- tryCatch(suppressWarnings(suppressMessages(makePedigreeMatingLayout(ped, edgeStyle = "direct"))),
                error = function(e) NULL)
  if (is.null(d)) next
  pr <- unique(ped[!is.na(ped$sire) & !is.na(ped$dam), c("sire", "dam")])
  gg <- setNames(ped$gen, ped$id); differ <- sum(gg[pr$sire] != gg[pr$dam])
  y <- setNames(d$nodes$y, d$nodes$id)
  m <- d$edges[grepl("^__union_", d$edges$to), ]
  gap <- abs(y[m$from] - y[m$to]) / 150
  res[[length(res) + 1]] <- data.frame(n = nrow(ped), units = sum(grepl("^__union_", d$nodes$id)),
                                       mate = nrow(m), spanning = sum(gap > 0), maxgap = max(gap, 0), differ = differ)
}
r <- do.call(rbind, res)
cat("synthetic pedigrees laid out:", nrow(r), " animals:", sum(r$n), " units:", sum(r$units),
    " mate-lines:", sum(r$mate), " spanning rows:", sum(r$spanning), " max gap:", max(r$maxgap),
    " units whose parents have different input gen:", sum(r$differ), "\n")
```
