# Evidence-based advice on the number of gene-drop iterations a pedigree needs

Part of Genetic Value Analysis

## Usage

``` r
gvaConvergence(
  ped,
  pop = NULL,
  nMax = 3000L,
  guThresh = 1L,
  byID = TRUE,
  grid = NULL,
  k = 20L,
  oMin = 0.9,
  rhoMin = 0.95,
  seed = NULL,
  updateProgress = NULL,
  breedingTable = NULL,
  gestationTable = NULL,
  breedingAgeDefault = NULL,
  gestationDefault = NULL,
  kinshipOverrides = NULL
)
```

## Arguments

- ped:

  The pedigree information in data.frame format (the same input
  [`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  takes).

- pop:

  Character vector with animal IDs to consider as the population of
  interest. The default is NULL (all animals).

- nMax:

  Integer gene-drop budget: the number of iteration columns to simulate.
  Reproducibility is assessed for iteration counts `N` with
  `2 * N <= nMax` (each half-split needs `2 * N` columns). Default 3000.

- guThresh:

  Integer threshold number of animals for defining a rare (unique)
  allele, passed to
  [`calcGU`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md)
  /
  [`calcA`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md).
  Default 1.

- byID:

  Logical passed to
  [`alleleFreq()`](https://github.com/rmsharp/nprcgenekeepr/reference/alleleFreq.md)
  via
  [`calcA`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md);
  if TRUE, homozygous alleles are counted once per individual. Default
  TRUE.

- grid:

  Integer vector of candidate iteration counts to assess. The default
  builds `c(25, 50, 100, 200, 400, 800, 1500)`, keeping only those with
  `2 * N <= nMax`.

- k:

  Integer size of the top-`k` selected set compared for overlap. Default
  20.

- oMin:

  Numeric minimum top-`k` overlap for reproducibility. Default 0.90.

- rhoMin:

  Numeric minimum Kendall rank agreement for reproducibility. Default
  0.95.

- seed:

  Optional integer; when supplied,
  [`set_seed`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
  pins the gene-drop RNG so the convergence curve is reproducible.
  Default NULL.

- updateProgress:

  Function or NULL passed through to
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
  to update a
  [`shiny::Progress`](https://rdrr.io/pkg/shiny/man/Progress.html)
  object. Default NULL.

- breedingTable, gestationTable, breedingAgeDefault, gestationDefault:

  Optional overrides for the unknown-parent mean-kinship correction,
  passed through to `correctUnknownParentMeanKinship()` exactly as
  [`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  passes them (issue \#73 Part 2). NULL uses the bundled defaults.

- kinshipOverrides:

  Optional data.frame of outside-information kinship overrides (`id1`,
  `id2`, `kinship`; the coefficient *f*, not relatedness *r*) applied to
  the kinship matrix before mean kinship and the unknown-parent
  correction, exactly as
  [`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  applies them, so the convergence diagnostic ranks on the same mean
  kinship the report uses (issue \#13). `NULL` (the default) leaves the
  pedigree-derived matrix unchanged. Ids outside the analysis set are
  warn-dropped (the run is not aborted); an override on a one-unknown
  animal supersedes its `+ sexMean / 2` correction. See
  [`applyKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/applyKinshipOverrides.md).

## Value

An object of class `nprcgenekeeprGVConv`: a list with

- `convergence` – a data.frame with one row per assessed iteration
  count: `iterations`, `topOverlap` (top-`k` selected-set overlap, from
  0 to 1), and `rankAgreement` (Kendall rank agreement of the
  commonly-ranked animals, from -1 to 1).

- `recommendedIter` – the smallest assessed iteration count meeting both
  criteria, or `NA` if none did within `grid`.

- `converged` – `TRUE` if any assessed count met both criteria.

- `criteria` – the `k`, `oMin`, and `rhoMin` used.

- `nRankable` – the number of probands carrying a (non-`NA`) rank that
  the order metrics are computed on.

- `nUndetermined` – the count of the excluded issue \#76 Undetermined
  set (2C).

- `nMax` – the gene-drop budget actually simulated.

## Details

Genome uniqueness
([`calcGU`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md))
is the only ranked Genetic Value Analysis output that carries Monte
Carlo (gene-drop) sampling noise, so the number of iterations a colony
actually needs is pedigree-dependent: there is no single universal
"right" count. `gvaConvergence` answers issue \#2's literal ask –
"define reproducible and automate finding the needed number of
iterations" – on the ratified definition that the decision-relevant
quantity is the *selection order* (which animals are chosen, and in what
order), not the precision of the `gu` number itself.

Because the `n` gene-drop iteration columns are independent and
identically distributed replicates, the whole convergence picture is
recoverable from a *single* completed gene drop the user already pays
for: `gvaConvergence` runs one gene drop at `nMax`, computes the
per-iteration rare-allele matrix once
([`calcA`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md)),
and for each candidate iteration count `N` in `grid` splits the columns
into two disjoint halves of `N` columns each. The two halves are
genuinely independent `N`-iteration estimates; each is ranked through
the same ordering pipeline the report uses, and the two orderings are
compared. A run is judged **reproducible at `N`** when both

- the top-`k` selected animals overlap by at least `oMin` (the same
  animals are chosen), and

- the Kendall rank agreement of the commonly-ranked animals is at least
  `rhoMin` (they come out in the same order).

The recommended iteration count is the smallest `N` in `grid` at which
both criteria hold. The issue \#76 de-inflated `gu = 0` "Undetermined"
set (both parents unknown, no recorded origin) is a policy constant with
rank `NA`; it is excluded from the order the criteria are computed on
and reported separately as `nUndetermined`.

Because the half-split compares two `N`-column runs to *each other*
(never to their pooled mean), it is a conservative, self-validating
estimate of reproducibility at `N`. This changes nothing about seeding:
a fixed seed already makes `gu` bit-identical run to run; that is
reproducibility of the *process*, whereas this function reports the
sampling reproducibility of the *estimate*.

## See also

[`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md),
[`calcGU`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
[`calcGUSE`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md)

## Examples

``` r
library(nprcgenekeepr)
## A quick, small illustration (use a larger nMax in practice).
conv <- gvaConvergence(nprcgenekeepr::qcPed, nMax = 200L, seed = 1L)
conv$convergence
#>   iterations topOverlap rankAgreement
#> 1         25          1             1
#> 2         50          1             1
#> 3        100          1             1
conv$recommendedIter
#> [1] 25
```
