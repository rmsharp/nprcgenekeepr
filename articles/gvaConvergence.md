# Gene-Drop Iteration Convergence

## How many gene-drop iterations does a pedigree need?

The Genetic Value Analysis ranks animals by mean kinship and **genome
uniqueness**. Mean kinship is deterministic, but genome uniqueness
(`gu`) is *estimated* by a gene-drop simulation: alleles are dropped
down the pedigree a chosen number of times, and `gu` is the average
result. Like any estimate from a finite number of draws, it carries
sampling noise, so the precision of `gu` – and, more importantly, the
**selection order** it produces – depends on how many iterations you
run.

There is no single iteration count that is right for every colony. A
pedigree with many animals whose true genome uniqueness sits near a
ranking boundary needs more iterations before the chosen set of animals
stops changing run to run; a pedigree whose ranked animals are well
separated settles almost immediately.
[`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
answers the question *for the pedigree in hand*: it reports how
reproducible the selection order is at a range of iteration counts, and
the smallest count at which it has settled.

### What it measures

Because the gene-drop iteration columns are independent replicates, the
whole convergence picture is recoverable from a **single** gene drop.
[`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
runs one gene drop at a budget `nMax`, then for each candidate iteration
count `N` it splits the columns into two disjoint halves of `N` columns
each – two genuinely independent `N`-iteration runs – ranks each half
through the same ordering pipeline the report uses, and compares the two
orderings on two criteria:

- **top-`k` overlap** – do the two runs choose the same top animals?
  (default `k = 20`, threshold `oMin = 0.90`)
- **Kendall rank agreement** – do the chosen animals come out in the
  same order? (threshold `rhoMin = 0.95`)

The run is **reproducible at `N`** when both hold, and the recommended
iteration count is the smallest `N` meeting both. The “Undetermined”
animals (both parents unknown, no recorded origin) are a policy constant
with rank `NA`; they are excluded from the order and reported separately
as `nUndetermined`.

This is distinct from seed reproducibility. A fixed seed already makes
`gu` bit-identical run to run – that is reproducibility of the
*process*.
[`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
reports the sampling reproducibility of the *estimate*: would a fresh,
independent run lead to the same animals being chosen, in the same
order?

## A pedigree where the iteration count matters

No bundled pedigree exercises the diagnostic well – after the `gu = 0`
de-inflation the shipped pedigrees have no `gu` signal left to rank on,
so their selection order is settled at the smallest iteration count. To
show a pedigree where the count *does* matter, we build a small half-sib
web in which the founders (the sources of the private alleles) are
excluded from the analyzed population, so their alleles survive among
the offspring only through descendants. Overlapping sire/dam mating
windows give the offspring distinct true genome-uniqueness values that
straddle the ranking boundary, so at low iteration counts the gene-drop
estimate randomly crosses the boundary and the selection order churns.

``` r

## A deterministic dense-mid-range pedigree: 14 founder sires, each mated to a
## wrapping window of 5 of 15 founder dams (one offspring per pair). Windows
## overlap, so dam fan sizes vary and the 70 offspring get distinct genome
## uniqueness straddling the 10% ranking cutoff. Founders are excluded from the
## analyzed population (`pop`); the offspring are the probands.
makeConvergenceFixture <- function() {
  w <- rep(5L, 14L)          # sire window widths
  b <- 15L                   # number of founder dams
  a <- length(w)
  sids <- sprintf("S%03d", seq_len(a))
  dids <- sprintf("D%03d", seq_len(b))
  id <- c(sids, dids)
  sire <- rep(NA_character_, a + b)
  dam <- rep(NA_character_, a + b)
  sex <- c(rep("M", a), rep("F", b))
  off <- character(0L)
  ocount <- 0L
  start <- 1L
  for (i in seq_len(a)) {
    for (j in seq_len(w[i])) {
      dj <- ((start + j - 2L) %% b) + 1L
      ocount <- ocount + 1L
      o <- sprintf("O%04d", ocount)
      id <- c(id, o)
      sire <- c(sire, sids[i])
      dam <- c(dam, dids[dj])
      sex <- c(sex, if (ocount %% 2L == 0L) "F" else "M")
      off <- c(off, o)
    }
    start <- start + max(1L, w[i] - 1L)
  }
  ped <- data.frame(id = id, sire = sire, dam = dam, sex = sex,
                    stringsAsFactors = FALSE)
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  list(ped = ped, pop = off)
}

fx <- makeConvergenceFixture()
nrow(fx$ped)      # total animals (founders + offspring)
#> [1] 99
length(fx$pop)    # offspring (the analyzed population)
#> [1] 70
```

We assess iteration counts from 25 up to 1500 (a fixed `seed` makes the
curve reproducible):

``` r

conv <- gvaConvergence(
  fx$ped, pop = fx$pop, nMax = 3000L,
  grid = c(25L, 50L, 100L, 200L, 400L, 800L, 1500L), seed = 11L
)

kable(
  conv$convergence,
  digits = c(0L, 3L, 3L),
  col.names = c("Iterations (N)", "Top-20 overlap", "Kendall agreement"),
  caption = "Selection-order reproducibility vs. iteration count (half-sib web)."
) |>
  kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)
```

| Iterations (N) | Top-20 overlap | Kendall agreement |
|---------------:|---------------:|------------------:|
|             25 |           0.75 |             0.701 |
|             50 |           0.80 |             0.781 |
|            100 |           0.85 |             0.853 |
|            200 |           1.00 |             0.916 |
|            400 |           1.00 |             0.945 |
|            800 |           1.00 |             0.953 |
|           1500 |           1.00 |             0.971 |

Selection-order reproducibility vs. iteration count (half-sib web).
{.table .table .table-striped .table-hover
style="width: auto !important; margin-left: auto; margin-right: auto;"}

``` r


conv$recommendedIter   # smallest N meeting both criteria
#> [1] 800
conv$converged
#> [1] TRUE
conv$nRankable
#> [1] 70
conv$nUndetermined
#> [1] 0
```

At the smallest counts the two independent half-runs disagree on both
which animals are chosen and their order; both measures climb as `N`
grows, and the selection order has settled by the higher counts and
stays settled there. `recommendedIter` (printed below the table) reports
the smallest count meeting both criteria. For this pedigree the default
of 1000 iterations is in the right range, and
[`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
is how you would confirm that rather than guess it.

## A pedigree that converges immediately

Contrast the bundled `qcPed`. After the `gu = 0` de-inflation none of
its ranked animals carry a non-zero genome uniqueness, so the selection
order is driven by deterministic mean kinship and does not move with the
iteration count.

``` r

convQc <- gvaConvergence(
  nprcgenekeepr::qcPed, nMax = 400L,
  grid = c(25L, 50L, 100L, 200L), seed = 11L
)

kable(
  convQc$convergence,
  digits = c(0L, 3L, 3L),
  col.names = c("Iterations (N)", "Top-20 overlap", "Kendall agreement"),
  caption = "Selection-order reproducibility vs. iteration count (qcPed)."
) |>
  kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)
```

| Iterations (N) | Top-20 overlap | Kendall agreement |
|---------------:|---------------:|------------------:|
|             25 |              1 |                 1 |
|             50 |              1 |                 1 |
|            100 |              1 |                 1 |
|            200 |              1 |                 1 |

Selection-order reproducibility vs. iteration count (qcPed). {.table
.table .table-striped .table-hover
style="width: auto !important; margin-left: auto; margin-right: auto;"}

``` r


convQc$recommendedIter   # converges at the grid floor
#> [1] 25
convQc$nRankable
#> [1] 156
convQc$nUndetermined     # the excluded Undetermined set
#> [1] 124
```

Overlap and agreement are at their maximum from the smallest count, so
the recommended count is the floor of the grid: this pedigree needs
almost no iterations for the *order* to be reproducible. The
`nUndetermined` count reports how many animals were set aside without a
rank.

## Choosing an iteration count

Run
[`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
on your own pedigree and read `recommendedIter`. If `converged` is
`FALSE`, no count in the grid settled the order – raise `nMax` and
extend the `grid` (each candidate `N` needs `2 * N <= nMax`), or accept
that this pedigree is intrinsically near a ranking boundary and
interpret the ranking with care. The thresholds `k`, `oMin`, and
`rhoMin` are arguments, so you can make the definition of “reproducible”
stricter or looser for your purpose.

Keep two ideas separate. The per-animal sampling standard error (`guSE`,
reported beside `gu` in
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md))
tells you how *precise the genome uniqueness number* is; it shrinks like
one over the square root of the iteration count. The *selection order* –
what
[`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
measures – is what actually decides which animals are chosen for
breeding. A small `guSE` does not by itself mean the order has settled,
which is exactly why the convergence check exists.

See also
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
(the analysis whose iterations this advises on),
[`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md)
(the per-animal standard error), and the *Colony Manager Tutorial*
vignette.
