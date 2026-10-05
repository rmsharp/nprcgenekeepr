# `highlightNearest` degree-6 limit: how often does a rectilinear hover fall short? (S909, 2026-10-05)

> **Status:** measurement DONE; no `R/` or test change. `BACKLOG.md`'s item ("`highlightNearest` degree=6
> mitigation for the rectilinear style is bounded, not a full fix") asked for this measurement as its first
> step. What to do with the item (close it, raise the degree, or keep it) is the owner's call and is recorded
> in `CHANGELOG.md`, not here.

## Audit summary

- **Scope:** the hover highlight on the Pedigree Diagram tab under the default rectilinear edge style
  (`R/modPedigree.R:828-842`: `highlightNearest = list(enabled = TRUE, hover = TRUE, degree = 6L,
  algorithm = "all")`; the direct style keeps `degree = 1L`).
- **Criteria**, both measured per animal X on the layout the app builds (`makePedigreeMatingLayout()`,
  `R/modPedigree.R:682`):
  - **(A)** hovering X lights no visible node except X itself (the backlog item's wording, "light up
    nothing visible"): the nearest other visible node is more than 6 hops away.
  - **(B)** hovering X lights *less than the direct style's degree-1 hover does*: some visible node next to X
    in the direct layout is more than 6 hops from X in the rectilinear layout. This is the standard the
    degree-6 mitigation was written to meet (`R/modPedigree.R:830-839`, S468).
- **Coverage:** the 375-animal rhesus pedigree as the app lays it out after QC (primary), the same pedigree
  in raw CSV row order, and 6 small example pedigrees (10-14 animals); `ExamplePedigree.csv` (3,694
  animals) for family sizes only (it is over the app's 400-animal rectilinear cap, `R/modPedigree.R:457`, so
  the app never lays it out whole); and synthetic families of 2-24 full siblings.
- **Result:** on the one real colony-sized fixture, **(A) never happens (0 of 375)** and **(B) happens for 2
  of 375 animals (0.5%)**, each missing one small union dot. Neither is caused by a wide sibship: the widest
  family in any bundled pedigree is 4 children. Both are caused by `__jog_*` waypoints.
  Degree 6 first falls short for a wide family at **9 full siblings from one pair**.

| Pedigree | Animals | Widest family | (A) lights nothing but X | (B) lights less than direct degree 1 | Hops needed to match direct |
|---|---|---|---|---|---|
| rhesus, QC'd (what the app lays out) | 375 | 3 | 0 of 375 | **2 of 375** | 1, 3, 4, 5, 7 (122, 187, 63, 1, 2 animals) |
| rhesus, raw CSV order (not what the app does) | 375 | 3 | 0 of 375 | 1 of 375 | max 7 |
| 6 small examples (backcross, consanguinity, first cousin, half sib, linebreeding, ancestry) | 10-14 | 1-4 | 0 | 0 | max 4 |
| `ExamplePedigree.csv` | 3,694 | 4 | not laid out (over the cap) | not laid out | n/a |
| synthetic, one pair with n full siblings | n + 2 | n | 0 for every n (2-24) | none up to n = 8; 1 at n = 9 | 3 at n = 2 ... 14 at n = 24 |

`rhesusPedigree_fromCenter.csv` gave the identical result to `obfuscated_rhesus_mhc_ped.csv` (same 375
animals, S907 measured they agree on all 8 shared columns), so it is one data point, not two.

## How a hover works here (read, then confirmed live)

visNetwork 2.1.4 (`htmlwidgets/visNetwork.js:3389-3417`, `algorithm = "all"`): hovering X colours every node
within `degree` hops of X, found by breadth-first search over **all** edges in both directions, hidden edges
and size-0 waypoint nodes included; nodes one hop further only get their labels back. The graph handed to
visNetwork is `layout$nodes` / `layout$edges` (`R/modPedigree.R:705`), so a BFS over those edges is the same
graph.

**Live confirmation (gate d, faithful verification):** the rhesus rectilinear layout was loaded into a
visNetwork widget with the app's `highlightNearest` options, in Chrome (chromote), and visNetwork's own
`hoverNode` handler was fired for six animals (the two short ones, a 4-hop, a 5-hop, a 3-hop and a 1-hop
animal). The set of undimmed nodes matched the BFS prediction exactly for all six (0 nodes differ in either
direction), and the page left 1,360-1,402 of 1,412 nodes dimmed, so the highlight really ran.

## Findings

### Finding 1: 2 of 375 animals lose their family's union dot (Minor)

- **Location:** `R/modPedigree.R:840` (`degree = 6L`).
- **Evidence (side by side, rhesus QC'd, animal `42M0Y8`):** in the direct style a degree-1 hover lights its
  two neighbours, `__union_63` (the dot for its parents' mating, "2 offspring") and `__union_136` (its own
  mating). In the rectilinear style at degree 6 the hover lights 11 visible nodes, including its own
  union `__union_136` and its full sibling `4F3ASD`, but **not `__union_63`** (7 hops; confirmed in the
  browser: `lit = FALSE`). The other short animal is `IRSC6X` (`__union_123`, 7 hops). Both are children of
  families of exactly 2.
- **Impact:** one small dot is not highlighted for 0.5% of animals; the hover still lights 11 and 31 visible
  nodes respectively. Nothing "lights up nothing".
- **Recommendation:** none needed on this evidence (see Recommendations).

### Finding 2: the cause is `__jog_*` waypoints, not sibship width (Moderate: it contradicts the item's stated mechanism)

- **Location:** `.resolveEdgeNodeCollisions()` (`R/makePedigreeDiagramData.R:2639`), which mints `__jog_<n>_a`
  and `__jog_<n>_b` (`:2922-2923`). The rhesus QC'd layout has 142 jog nodes (630 waypoints in all), the
  same counts S905 recorded.
- **Evidence:** the shortest path from `42M0Y8` to `__union_63` is `42M0Y8 -> __jog_27_a -> __jog_27_b ->
  4F3ASD -> __jog_28_a -> __jog_28_b -> __drop___union_63 -> __union_63`: through its sibling's node, with 4
  jog nodes and **no `__bar_` node at all** (`IRSC6X` has the same shape via `H16EC4`). Across all 375
  animals, the farthest direct-style neighbour needs:

  | Hops needed | Animals | `__jog_` nodes on that path |
  |---|---|---|
  | 1 | 122 | 0 |
  | 3 | 187 | 0 (182), 2 (5) |
  | 4 | 63 | 0 (3), 2 (60) |
  | 5 | 1 | 2 |
  | 7 | 2 | 4 |

  Every animal whose path has no jog needs at most 4 hops; each jog pair adds 2. The backlog item expected
  the long chains to come from `__bar_` chains in wide sibships; in this fixture the bars are barely
  involved (largest family 3).
- **Impact:** the two shortfalls depend on where the collision pass put jogs, which depends on layout order
  (raw CSV order gives 1 of 375, not 2). A change in the jog rules could move a different animal across the
  line without anyone touching the hover code.

### Finding 3: wide families do exceed 6 hops, but only from 9 siblings of one pair (Minor, not present in any bundled data)

- **Location:** `R/makePedigreeDiagramData.R:2203-2236` (D1 sibship-bar chain: each child's `__bar_` node and
  the union's `__drop_` node are chained in x order).
- **Evidence (synthetic: one sire, one dam, n full siblings, no jogs):**

  | Children n | 2 | 4 | 6 | 8 | 9 | 10 | 12 | 16 | 20 | 24 |
  |---|---|---|---|---|---|---|---|---|---|---|
  | Hops needed (farthest child) | 3 | 4 | 5 | 6 | 7 | 7 | 8 | 10 | 12 | 14 |
  | Animals short at degree 6 | 0 | 0 | 0 | 0 | 1 | 2 | 4 | 8 | 12 | 16 |

  Hops needed grow by about one per two extra children, so no fixed degree fixes this; a general fix needs
  a traversal that skips invisible waypoints. **Even at n = 24 the farthest child has a visible node
  (its sibling) within 3 hops**, so criterion (A) is never met.
- **Prevalence in the bundled data:** children per sire-dam pair, widest 3 (rhesus, 375 animals) and 4
  (`ExamplePedigree.csv`, 3,694 animals: 1 pair of 4, 2 of 3, 56 of 2, 1,904 of 1). The nearest approach
  to 9 is less than half of it. The app draws at most 400 animals in this style (`R/modPedigree.R:457`).
- **Impact:** none measured. Whether any real colony has a pair with 9 or more full siblings in a
  diagram of at most 400 animals is not answerable from this repository.

### Finding 4: raising the degree trades coverage for noise (Minor; informs the options)

- **Evidence (rhesus QC'd):** degree 7 closes both shortfalls, but visible nodes lit besides X rise from a
  median of 14 (max 45) to a median of 19 (max 69).
- **Location:** a change would also move `tests/testthat/test_modPedigree.R:2063` and `:2072`, which pin the
  literal `"degree":6`.

## Items audited

| Item | Status | Findings |
|---|---|---|
| `highlightNearest` options (`R/modPedigree.R:828-842`) | Audited (read + measured + live) | 1, 4 |
| Rectilinear sibship-bar chain (`R/makePedigreeDiagramData.R:2203-2236`) | Audited (read + synthetic) | 3 |
| Collision-resolution jog pass (`R/makePedigreeDiagramData.R:2639-3097`) | Observed through its output only; its code was not audited | 2 |
| visNetwork 2.1.4 `neighbourhoodHighlight` (`visNetwork.js:3314-3417`) | Audited (read + live) | n/a |
| Pinning test (`test_modPedigree.R:2032-2075`) | Read | 4 |

## Comparison with prior work

- S468 (2026-08-03, Learning 463) measured "hop distances up to 4" live and chose degree 6 as a bounded
  mitigation. That still holds for 372 of 375 animals (1, 3 or 4 hops). The 3 animals that now need 5 or 7
  all run through jogs, and the jog framework (`.resolveEdgeNodeCollisions()`, issue #160, commit
  `c7bdbe4bc`) landed on 2026-08-15, twelve days after S468's measurement, so S468 could not have seen them.
- S905's rectilinear counts reproduce: 1,412 nodes and 142 jog nodes (QC'd), 1,460 nodes (raw order).

## Not measured

- Colonies other than the bundled pedigrees; the app's focal-animal subsets (each is a smaller pedigree
  laid out the same way, so its families are no wider than in the full one); real mouse hit-testing (the live
  check fired the handler directly); browsers other than Chrome; visNetwork versions other than 2.1.4.

## Recommendations

1. **Close the item**, recording these numbers: on every pedigree the app can show from the bundled data,
   the degree-6 hover is at least as good as the direct style's for 99.5% of animals and never lights
   nothing; the stated wide-sibship mechanism needs 9 or more full siblings of one pair, and the widest bundled
   family is 4.
2. **Do not raise the degree** on this evidence: it fixes 2 dots (Finding 1) at the cost of about 5 more
   lit nodes on a typical hover (Finding 4), and it cannot scale to wide families (Finding 3).
3. If the owner knows of a colony with a sire-dam pair of 9 or more offspring, reopen with that evidence;
   the fix would then be a traversal that skips invisible waypoints (its own plan session first).
4. If the owner wants the 2 rhesus dots anyway: degree 7 is a one-line change plus the two assertions in
   Finding 4, strict TDD, its own session.

## Appendix: scripts (run from the repo root; save each in one scratch directory as named)

Run with `SCRATCH=<dir> Rscript <file>`. `hoverWide.R` and `liveHover.R` source `hoverReach.R` from
`$SCRATCH` with `HOVER_SKIP_RUN` set, so they get only its functions. `liveHover.R` needs Chrome and the
`chromote`, `htmlwidgets` and `jsonlite` packages. The edge listings quoted in Finding 2 are
`rect$edges[rect$edges$from %in% ids | rect$edges$to %in% ids, ]` for the path ids.

### Family sizes from the raw files (no layout; used for `ExamplePedigree.csv`)

```r
suppressMessages(pkgload::load_all(".", quiet = TRUE))
for (f in c("obfuscated_rhesus_mhc_ped.csv", "ExamplePedigree.csv")) {
  p <- read.csv(system.file("extdata", "examples", f, package = "nprcgenekeepr"),
                stringsAsFactors = FALSE)
  ok <- !is.na(p$sire) & !is.na(p$dam) & nzchar(p$sire) & nzchar(p$dam)
  t <- table(table(paste(p$sire[ok], p$dam[ok])))   # children per sire-dam pair
  cat(f, ":", paste(names(t), t, sep = "x", collapse = " "), "\n")
}
```

### `hoverReach.R`

```r
## S909: how far does a rectilinear hover (highlightNearest, degree = 6) reach?
##
## Model (read from visNetwork 2.1.4 htmlwidgets/visNetwork.js:3389-3417, algorithm "all"):
## hovering node X colours every node within `degree` hops of X, found by BFS over
## ALL edges in both directions (hidden edges and size-0 waypoint nodes included).
## The graph the app hands to visNetwork is layout$nodes / layout$edges
## (R/modPedigree.R:705), so BFS over those edges is the same graph.
##
## Reference: what the direct style lights up at degree 1 (its neighbours in the
## direct layout's edge list). The rectilinear mitigation was added so that hover
## is "not worse than direct" (R/modPedigree.R:830-839).

Sys.setenv(NOT_CRAN = "true")
suppressMessages(pkgload::load_all(".", quiet = TRUE))
source("tests/testthat/helper-qcdRhesusPed.R")

DEGREE <- 6L

bfs <- function(adj, src) {
  dist <- stats::setNames(rep(NA_integer_, length(adj)), names(adj))
  dist[[src]] <- 0L
  frontier <- src
  d <- 0L
  while (length(frontier) > 0L) {
    d <- d + 1L
    nxt <- unique(unlist(adj[frontier], use.names = FALSE))
    nxt <- nxt[is.na(dist[nxt])]
    dist[nxt] <- d
    frontier <- nxt
  }
  dist
}

adjacency <- function(nodeIds, edges) {
  adj <- split(c(edges$to, edges$from), c(edges$from, edges$to))
  adj <- lapply(adj, unique)
  for (id in setdiff(nodeIds, names(adj))) adj[[id]] <- character(0)
  adj[nodeIds]
}

kindOf <- function(id) {
  ifelse(grepl("^__union_", id), "union",
  ifelse(grepl("^__(bar|drop|proj|jog)_", id), "waypoint",
  ifelse(grepl("^__dup_", id), "dup",
  ifelse(grepl("^__", id), "OTHER", "real"))))
}

measure <- function(ped, label) {
  rect <- suppressMessages(makePedigreeMatingLayout(ped, edgeStyle = "rectilinear"))
  dirc <- suppressMessages(makePedigreeMatingLayout(ped, edgeStyle = "direct"))
  rk <- kindOf(rect$nodes$id)
  dk <- kindOf(dirc$nodes$id)
  stopifnot(!any(rk == "OTHER"), !any(dk == "OTHER"))
  visRect <- rect$nodes$id[rk != "waypoint"]
  visDir <- dirc$nodes$id[dk != "waypoint"]
  sameVisible <- setequal(visRect, visDir)

  adjR <- adjacency(rect$nodes$id, rect$edges)
  adjD <- adjacency(dirc$nodes$id, dirc$edges)

  ## sibship size of each mating unit = child edges leaving the union node
  ce <- dirc$edges[grepl("^__union_", dirc$edges$from), ]
  sib <- table(ce$from)

  targets <- rect$nodes$id[rk == "real"]
  rows <- lapply(targets, function(x) {
    dist <- bfs(adjR, x)
    others <- setdiff(visRect, x)
    n1 <- adjD[[x]]
    dn1 <- unname(dist[n1])
    fromUnion <- n1[grepl("^__union_", n1)]
    ## the family-of-origin union is the one whose child edge points at x
    origin <- ce$from[ce$to == x]
    list(
      id = x,
      nN1 = length(n1),
      needed = if (length(dn1)) max(dn1) else NA_integer_,
      nearestOther = min(dist[others], na.rm = TRUE),
      missing6 = sum(is.na(dn1) | dn1 > DEGREE),
      originSib = if (length(origin)) as.integer(sib[[origin[1L]]]) else NA_integer_,
      lit6 = sum(!is.na(dist[others]) & dist[others] <= DEGREE),
      distOthers = list(unname(dist[others]))
    )
  })
  df <- data.frame(
    id = vapply(rows, `[[`, "", "id"),
    nN1 = vapply(rows, `[[`, 0L, "nN1"),
    needed = vapply(rows, `[[`, 0L, "needed"),
    nearestOther = vapply(rows, `[[`, 0L, "nearestOther"),
    missing6 = vapply(rows, `[[`, 0L, "missing6"),
    originSib = vapply(rows, `[[`, 0L, "originSib"),
    lit6 = vapply(rows, `[[`, 0L, "lit6"),
    stringsAsFactors = FALSE
  )
  dStar <- max(df$needed, na.rm = TRUE)
  litAt <- function(d) vapply(rows, function(r) sum(r$distOthers[[1L]] <= d, na.rm = TRUE), 0L)
  list(
    label = label, n = nrow(ped), nReal = length(targets),
    nUnion = sum(rk == "union"), nWaypoint = sum(rk == "waypoint"),
    sameVisible = sameVisible,
    sibMax = if (length(sib)) max(sib) else 0L,
    sibTable = table(factor(as.integer(sib), levels = seq_len(max(1L, max(sib, 0L))))),
    df = df, dStar = dStar,
    litAt6 = litAt(DEGREE), litAtStar = litAt(dStar)
  )
}

summarise <- function(m) {
  df <- m$df
  cat("\n=====", m$label, "=====\n")
  cat(sprintf("animals %d | real nodes %d | unions %d | waypoints %d | visible ids same in both styles: %s\n",
              m$n, m$nReal, m$nUnion, m$nWaypoint, m$sameVisible))
  cat("sibship sizes (children per mating unit): "); print(m$sibTable[m$sibTable > 0])
  cat(sprintf("largest sibship: %d\n", m$sibMax))
  cat(sprintf("(A) nothing visible lit but X itself (nearest other visible node > %d hops): %d of %d\n",
              DEGREE, sum(df$nearestOther > DEGREE), nrow(df)))
  cat(sprintf("(B) lights up LESS than direct style's degree 1 (some direct neighbour > %d hops): %d of %d\n",
              DEGREE, sum(df$missing6 > 0L), nrow(df)))
  cat("hops needed to match direct degree-1 (distribution):\n"); print(table(df$needed))
  cat(sprintf("smallest degree that closes (B) for this fixture: %d\n", m$dStar))
  cat(sprintf("visible nodes lit besides X at degree 6: median %g, max %d; at degree %d: median %g, max %d\n",
              stats::median(m$litAt6), max(m$litAt6), m$dStar,
              stats::median(m$litAtStar), max(m$litAtStar)))
  bad <- df[df$missing6 > 0L, ]
  if (nrow(bad)) {
    cat("short individuals (id, hops needed, children in own family of origin):\n")
    print(utils::head(bad[order(-bad$needed), c("id", "needed", "originSib", "missing6")], 15L), row.names = FALSE)
  }
  invisible(m)
}

if (nzchar(Sys.getenv("HOVER_SKIP_RUN"))) {
  invisible(NULL)
} else {
fixtures <- list()
qcOne <- function(file) {
  raw <- utils::read.csv(system.file("extdata", "examples", file, package = "nprcgenekeepr"),
                         stringsAsFactors = FALSE)
  suppressWarnings(suppressMessages(
    runQcStudbook(raw, minSireAge = NULL, minDamAge = NULL, reportChanges = TRUE)))$cleaned
}
fixtures[["rhesus, QC'd (what the app lays out)"]] <- qcdRhesusPed()
for (f in c("obfuscated_rhesus_mhc_ped.csv",
            "example_pedigree_backcross.csv", "example_pedigree_consanguinity.csv",
            "example_pedigree_first_cousin.csv", "example_pedigree_half_sib.csv",
            "example_pedigree_linebreeding.csv", "example_ancestry_pedigree.csv",
            "rhesusPedigree_fromCenter.csv")) {
  fixtures[[f]] <- tryCatch(qcOne(f), error = function(e) {
    cat("SKIPPED", f, ":", conditionMessage(e), "\n"); NULL })
}
raw375 <- utils::read.csv(system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                                      package = "nprcgenekeepr"), stringsAsFactors = FALSE)
fixtures[["rhesus, raw CSV row order (not what the app does)"]] <- raw375

results <- list()
for (nm in names(fixtures)) {
  if (is.null(fixtures[[nm]])) next
  cat("\n... measuring", nm, "\n")
  t0 <- Sys.time()
  results[[nm]] <- tryCatch(measure(fixtures[[nm]], nm), error = function(e) {
    cat("FAILED", nm, ":", conditionMessage(e), "\n"); NULL })
  if (!is.null(results[[nm]])) summarise(results[[nm]])
  cat(sprintf("(%.1f s)\n", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
}
saveRDS(results, file.path(Sys.getenv("SCRATCH", "."), "hoverReach_results.rds"))
}
```

### `hoverWide.R`

```r
## S909 probe: how wide must ONE full-sibling family be before degree 6 falls short?
## Synthetic (labelled as such in the report): sire S, dam D, n full siblings.
Sys.setenv(NOT_CRAN = "true", HOVER_SKIP_RUN = "1")
S <- Sys.getenv("SCRATCH", ".")
source(file.path(S, "hoverReach.R"))   # functions only (HOVER_SKIP_RUN)

mk <- function(n) {
  kids <- sprintf("K%02d", seq_len(n))
  data.frame(
    id = c("S", "D", kids),
    sire = c(NA, NA, rep("S", n)), dam = c(NA, NA, rep("D", n)),
    sex = c("M", "F", rep(c("F", "M"), length.out = n)),
    gen = c(0L, 0L, rep(1L, n)), stringsAsFactors = FALSE)
}

out <- lapply(c(2:12, 14, 16, 20, 24), function(n) {
  m <- measure(mk(n), sprintf("synthetic family of %d", n))
  df <- m$df
  data.frame(children = n, sibMax = m$sibMax,
             maxHopsNeeded = max(df$needed),
             individualsShort = sum(df$missing6 > 0L),
             worstNearestVisible = max(df$nearestOther),
             of = nrow(df),
             waypoints = m$nWaypoint)  # bar + drop + jog nodes in the rectilinear layout
})
res <- do.call(rbind, out)
print(res, row.names = FALSE)
cat("\nfirst family width where degree 6 is short for someone:",
    res$children[which(res$individualsShort > 0L)[1L]], "\n")
```

### `hoverPaths.R`

```r
## S909 probe: what do the longest hover paths in the QC'd rhesus layout cross?
Sys.setenv(NOT_CRAN = "true")
suppressMessages(pkgload::load_all(".", quiet = TRUE))
source("tests/testthat/helper-qcdRhesusPed.R")

kindOf <- function(id) {
  ifelse(grepl("^__union_", id), "union",
  ifelse(grepl("^__(bar|drop|proj|jog)_", id),
         sub("^__([a-z]+)_.*", "\\1", id),
  ifelse(grepl("^__dup_", id), "dup", "real")))
}
adjacency <- function(nodeIds, edges) {
  adj <- split(c(edges$to, edges$from), c(edges$from, edges$to))
  adj <- lapply(adj, unique)
  for (id in setdiff(nodeIds, names(adj))) adj[[id]] <- character(0)
  adj[nodeIds]
}
## BFS recording a parent pointer so a shortest path can be read back
bfsTree <- function(adj, src) {
  dist <- stats::setNames(rep(NA_integer_, length(adj)), names(adj))
  par <- stats::setNames(rep(NA_character_, length(adj)), names(adj))
  dist[[src]] <- 0L
  frontier <- src
  d <- 0L
  while (length(frontier) > 0L) {
    d <- d + 1L
    nxtAll <- character(0)
    for (u in frontier) {
      for (v in adj[[u]]) {
        if (is.na(dist[[v]])) { dist[[v]] <- d; par[[v]] <- u; nxtAll <- c(nxtAll, v) }
      }
    }
    frontier <- nxtAll
  }
  list(dist = dist, par = par)
}
pathTo <- function(tree, x, target) {
  p <- target
  while (!identical(p[1L], x)) p <- c(tree$par[[p[1L]]], p)
  p
}

ped <- qcdRhesusPed()
rect <- suppressMessages(makePedigreeMatingLayout(ped, edgeStyle = "rectilinear"))
dirc <- suppressMessages(makePedigreeMatingLayout(ped, edgeStyle = "direct"))
adjR <- adjacency(rect$nodes$id, rect$edges)
adjD <- adjacency(dirc$nodes$id, dirc$edges)
reals <- rect$nodes$id[kindOf(rect$nodes$id) == "real"]

## For each real X: the direct-degree-1 neighbour that is farthest in the rectilinear graph
far <- lapply(reals, function(x) {
  tr <- bfsTree(adjR, x)
  n1 <- adjD[[x]]
  d <- tr$dist[n1]
  t <- n1[which.max(d)]
  p <- pathTo(tr, x, t)
  list(id = x, needed = max(d), target = t, path = p,
       kinds = kindOf(p), nJog = sum(kindOf(p) == "jog"),
       nBar = sum(kindOf(p) == "bar"), nProj = sum(kindOf(p) == "proj"),
       nDrop = sum(kindOf(p) == "drop"))
})
df <- data.frame(
  id = vapply(far, `[[`, "", "id"), needed = vapply(far, `[[`, 0L, "needed"),
  target = vapply(far, `[[`, "", "target"),
  nBar = vapply(far, `[[`, 0L, "nBar"), nDrop = vapply(far, `[[`, 0L, "nDrop"),
  nProj = vapply(far, `[[`, 0L, "nProj"), nJog = vapply(far, `[[`, 0L, "nJog"),
  stringsAsFactors = FALSE)
df$targetKind <- kindOf(df$target)

cat("\n--- the 2 individuals short at degree 6, shortest path to the far neighbour ---\n")
for (f in far[vapply(far, function(z) z$needed > 6L, NA)]) {
  cat(sprintf("\n%s -> %s (%d hops)\n", f$id, f$target, f$needed))
  cat("  ", paste(sprintf("%s[%s]", f$path, f$kinds), collapse = " -> "), "\n")
}

cat("\n--- composition of the longest-neighbour path by needed hops ---\n")
print(stats::aggregate(cbind(nBar, nDrop, nProj, nJog) ~ needed, df, mean), digits = 2)
cat("\nindividuals by needed hops and by what the far neighbour is:\n")
print(table(needed = df$needed, farNeighbour = df$targetKind))
cat("\nneeded vs number of jog waypoints on the path:\n")
print(table(needed = df$needed, jogs = df$nJog))
cat("\ntotal jog waypoint nodes in the layout:", sum(kindOf(rect$nodes$id) == "jog"),
    "| edges touching a jog:", sum(kindOf(rect$edges$from) == "jog" | kindOf(rect$edges$to) == "jog"), "\n")
```

### `liveHover.R`

```r
## S909 faithfulness check: does a REAL hover in Chrome light up exactly the nodes the
## BFS model predicts? Builds the rhesus rectilinear widget with the app's highlightNearest
## options (R/modPedigree.R:828-842), emits visNetwork's own hoverNode handler, reads back
## which nodes the page left undimmed.
Sys.setenv(NOT_CRAN = "true", HOVER_SKIP_RUN = "1")
S <- Sys.getenv("SCRATCH", ".")
source(file.path(S, "hoverReach.R"))   # bfs(), adjacency(), kindOf(), qcdRhesusPed()

ped <- qcdRhesusPed()
rect <- suppressMessages(makePedigreeMatingLayout(ped, edgeStyle = "rectilinear"))
adjR <- adjacency(rect$nodes$id, rect$edges)

w <- visNetwork::visNetwork(rect$nodes, rect$edges) |>
  visNetwork::visPhysics(enabled = FALSE) |>
  visNetwork::visNodes(physics = FALSE) |>
  visNetwork::visEdges(smooth = FALSE) |>
  visNetwork::visOptions(highlightNearest = list(
    enabled = TRUE, hover = TRUE, degree = 6L, algorithm = "all"))
f <- file.path(S, "hover.html")
htmlwidgets::saveWidget(w, f, selfcontained = TRUE)

b <- chromote::ChromoteSession$new()
on.exit(try(b$close(), silent = TRUE), add = TRUE)
b$Page$navigate(paste0("file://", f))
Sys.sleep(4)

js <- function(expr) {
  r <- b$Runtime$evaluate(expr, returnByValue = TRUE)
  if (!is.null(r$exceptionDetails)) stop(r$exceptionDetails$exception$description)
  r$result$value
}
cat("network object found:", js("typeof document.querySelector('[id^=graph]').chart"), "\n")
cat("node count in page:", js("document.querySelector('[id^=graph]').chart.body.data.nodes.length"), "\n")

hoverLit <- function(id) {
  ## reset, hover, read which nodes are not the dimmed grey
  js("(function(){ document.querySelector('[id^=graph]').chart.body.emitter.emit('blurNode', {}); return 1; })()")
  Sys.sleep(0.3)
  js(sprintf("(function(){ document.querySelector('[id^=graph]').chart.body.emitter.emit('hoverNode', {node: %s}); return 1; })()",
             jsonlite::toJSON(id, auto_unbox = TRUE)))
  Sys.sleep(0.5)
  out <- js("JSON.stringify(document.querySelector('[id^=graph]').chart.body.data.nodes.get().map(function(n){
    var c = n.color; var s = (typeof c === 'string') ? c : (c ? (c.background || '') : '');
    return [n.id, s]; }))")
  m <- jsonlite::fromJSON(out)
  data.frame(id = m[, 1], color = m[, 2], stringsAsFactors = FALSE)
}

check <- function(id) {
  cols <- hoverLit(id)
  dimmed <- grepl("rgba\\(200,\\s*200,\\s*200", cols$color)
  litBrowser <- cols$id[!dimmed]
  dist <- bfs(adjR, id)
  litModel <- names(dist)[!is.na(dist) & dist <= 6L]
  vis <- function(x) x[kindOf(x) != "waypoint"]
  vb <- sort(vis(litBrowser)); vm <- sort(vis(litModel))
  cat(sprintf("%-8s browser lights %3d visible nodes, model predicts %3d, only-in-browser %d, only-in-model %d%s\n",
              id, length(vb), length(vm), length(setdiff(vb, vm)), length(setdiff(vm, vb)),
              if (identical(vb, vm)) "  -> IDENTICAL" else "  -> DIFFERENT"))
  invisible(list(browser = vb, model = vm, nDimmed = sum(dimmed), nNodes = nrow(cols)))
}

targets <- c("42M0Y8", "IRSC6X", "4F3ASD")
## one individual that needs exactly 5 hops, and one ordinary 3-hop individual
tmp <- measure(ped, "rhesus")$df
five <- tmp$id[tmp$needed == 5L][1L]
three <- tmp$id[tmp$needed == 3L][1L]
founder <- tmp$id[tmp$needed == 1L][1L]
targets <- c(targets, five, three, founder)
cat("targets:", paste(targets, collapse = ", "), "\n")
res <- lapply(targets, check)
names(res) <- targets
cat("\ndimmed-node sanity (a node count > 0 and < all means highlight really ran): ",
    paste(sprintf("%s=%d/%d", targets, vapply(res, `[[`, 0L, "nDimmed"), vapply(res, `[[`, 0L, "nNodes")),
          collapse = "  "), "\n")
cat("\nfamily-of-origin union lit in the browser?\n")
for (id in c("42M0Y8", "IRSC6X")) {
  u <- if (id == "42M0Y8") "__union_63" else "__union_123"
  cat(sprintf("  hover %s: %s lit = %s\n", id, u, u %in% res[[id]]$browser))
}
```
