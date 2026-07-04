# Calculate the standard error of founder genome equivalents

Part of the Genetic Value Analysis

## Usage

``` r
calcFGSE(ped, alleles)
```

## Arguments

- ped:

  the pedigree information in datatable format. Pedigree (req. fields:
  id, sire, dam, gen, population). The pedigree must have no partial
  parentage (every animal has both parents known or both unknown);
  `calcFGSE` stops with an error otherwise.

- alleles:

  dataframe containing an `AlleleTable`: an `id` column, a `parent`
  column, and one column per gene-drop iteration. Produced by
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md);
  the same input
  [`calcFG`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md)
  takes.

## Value

A single numeric value: the Monte Carlo sampling standard error of the
colony founder-genome-equivalent estimate, on the same scale as
[`calcFG`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md).
`NA` (with a warning) when a contributing founder has zero retention.

## Details

Founder genome equivalents
([`calcFG`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md))
is a Monte Carlo estimate: `FG = 1 / sum(p^2 / r)`, where the founder
contributions `p` are deterministic but the mean allelic retention
values `r`
([`calcRetention`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md))
are averages over the gene-drop iterations, so `FG` carries sampling
error that shrinks as the number of iterations grows. Unlike genome
uniqueness (a mean, whose standard error is a column variance), `FG` is
a nonlinear function of `r`, so its standard error is obtained by the
delta method (first-order linearization).

With `S = sum(p_f^2 / r_f)` and `FG = 1 / S`, the gradient is
`dFG/dr_f = FG^2 * p_f^2 / r_f^2`. Writing `R` for the founder-by-
iteration retention matrix (each column an independent gene drop), the
influence series `y_k = sum_f (dFG/dr_f) * R[f, k]` has
`sd(y) / sqrt(K)` equal to the full delta-method standard error,
including the within-iteration covariance among founders. This influence
form is used because it folds in that covariance automatically and never
forms the founder-by-founder covariance matrix.

Founders are matched between `p` and `r` by name (not position), so the
result is correct even when the founders are not in sorted pedigree
order.

A contributing founder (`p > 0`) that is retained in zero of the
iterations (`r == 0`) makes `FG` undefined (the same degeneracy that
[`calcFG`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md)
now reports as `NA`); in that case this function returns `NA` with a
warning advising more iterations. Founders that do not contribute to the
current population (`p == 0`) are dropped, so the standard error refers
to exactly the founder set `FG` is computed from.

## See also

[`calcFG`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
[`calcFEFG`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
[`calcRetention`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md),
[`calcGUSE`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md),
[`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)

Other genetic value analysis:
[`calcA()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md),
[`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
[`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
[`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
[`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
[`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md),
[`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md)

## Examples

``` r
library(nprcgenekeepr)
data("lacy1989Ped")
data("lacy1989PedAlleles")
calcFGSE(lacy1989Ped, lacy1989PedAlleles)
#> [1] 0.006213056
```
