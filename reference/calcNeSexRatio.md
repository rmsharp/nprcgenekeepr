# Calculate the demographic sex-ratio effective population size

Part of the Genetic Value Analysis

## Usage

``` r
calcNeSexRatio(ped)
```

## Arguments

- ped:

  Pedigree data.frame with `id`, `sire`, `dam`, and `sex`; `exit` is
  used to identify living animals when present.

## Value

The sex-ratio effective size, a single non-negative number; `0` when
either breeding sex is absent among the living breeders.

## Details

The sex-ratio effective size,
`Ne = 4 * nMale * nFemale / (nMale + nFemale)`, is the effective
population size implied by an unequal breeding sex ratio, where `nMale`
and `nFemale` are the numbers of current living breeders that are known
male and known female. It quantifies the diversity lost when many of one
sex are bred to few of the other (as in a harem colony): it equals the
census count when the sexes are balanced and falls toward four times the
rarer sex as the ratio skews.

The breeders are the current living breeders of `ped` (living animals
that appear as a sire or dam, excluding auto-generated unknown parents),
independent of which animals are selected as probands – a different
population than the analysis-set founder statistics
([`calcFE`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
[`calcFG`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
[`calcGeneDiversity`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGeneDiversity.md)).
Only animals with a known sex (`"M"` or `"F"`) are counted; unknown and
hermaphrodite breeders are excluded. When either sex is absent among the
living breeders (`nMale == 0` or `nFemale == 0`, including no living
breeders at all), the result is `0`: a single breeding sex contributes
no diversity from sex balance.

Like all effective-size estimators this idealizes a Wright-Fisher
population (constant size, discrete generations, random union of gametes
within each sex); a managed colony departs from those assumptions, so
read the result as a sex-ratio index rather than a literal head count.

## References

Crow, J. F. and Kimura, M. (1970) *An Introduction to Population
Genetics Theory*. Harper and Row, New York.

## See also

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
[`calcNeVariance()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeVariance.md),
[`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md)

## Examples

``` r
ped <- data.frame(
  id = c("s1", "d1", "d2", "k1", "k2"),
  sire = c(NA, NA, NA, "s1", "s1"),
  dam = c(NA, NA, NA, "d1", "d2"),
  sex = c("M", "F", "F", "M", "F"),
  exit = c(NA, NA, NA, NA, NA),
  stringsAsFactors = FALSE
)
calcNeSexRatio(ped) # 4 * 1 * 2 / (1 + 2) = 2.666667
#> [1] 2.666667
```
