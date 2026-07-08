# Calculate the variance effective population size

Part of the Genetic Value Analysis

## Usage

``` r
calcNeVariance(ped)
```

## Arguments

- ped:

  Pedigree data.frame with `id`, `sire`, and `dam`; `exit` is used to
  identify living animals when present.

## Value

The variance effective size, a single number; `NA` when there are fewer
than two living breeders.

## Details

The variance effective size measures the diversity lost to unequal
family sizes – typically the dominant reducer of effective size in a
harem colony, where a few breeders produce most of the offspring. It is
the mean-adjusted Crow & Kimura (1970) form

\$\$N_e = \frac{N \bar{k} - 1}{\bar{k} - 1 + V_k / \bar{k}}\$\$

where `N` is the number of current living breeders, \\\bar{k}\\ the mean
number of lifetime offspring among them, and \\V_k\\ the variance of
those offspring counts. This general form makes no constant-size
assumption and reduces to the classic `(4N - 2) / (Vk + 2)` at exact
replacement (\\\bar{k} = 2\\); it is preferred over that bare form,
which assumes \\\bar{k} \approx 2\\ and misstates the effective size
when the mean family size departs from replacement.

The breeders are the current living breeders of `ped` (living animals
that appear as a sire or dam, excluding auto-generated unknown parents),
independent of which animals are selected as probands – a different
population than the analysis-set founder statistics
([`calcFE`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
[`calcFG`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
[`calcGeneDiversity`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGeneDiversity.md)).
Unlike the sex-ratio effective size
([`calcNeSexRatio`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md)),
breeders of every sex are counted. When fewer than two living breeders
are present the variance is undefined and the result is `NA`.

Like all effective-size estimators this idealizes a Wright-Fisher
population (constant size, discrete generations, random union of
gametes); a managed colony departs from those assumptions, so read the
result as a family-size-variance index rather than a literal head count.

## References

Crow, J. F. and Kimura, M. (1970) *An Introduction to Population
Genetics Theory*. Harper and Row, New York.

## See also

[`calcNeSexRatio`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md),
[`calcGeneDiversity`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGeneDiversity.md)

Other genetic value analysis:
[`calcA()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md),
[`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
[`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
[`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
[`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md),
[`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
[`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md),
[`calcGeneDiversity()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGeneDiversity.md),
[`calcNeSexRatio()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md),
[`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md)

## Examples

``` r
ped <- data.frame(
  id = c("s1", "d1", "k1", "k2", "k3"),
  sire = c(NA, NA, "s1", "s1", "s1"),
  dam = c(NA, NA, "d1", "d1", "d1"),
  sex = c("M", "F", "M", "F", "F"),
  exit = c(NA, NA, NA, NA, NA),
  stringsAsFactors = FALSE
)
calcNeVariance(ped) # 2 breeders, equal families: (2*3-1)/(3-1) = 2.5
#> [1] 2.5
```
