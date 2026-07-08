# Calculate gene diversity from founder genome equivalents

Part of the Genetic Value Analysis

## Usage

``` r
calcGeneDiversity(fg)
```

## Arguments

- fg:

  Founder genome equivalents scalar, as returned by
  [`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md)
  or the `$FG` element of
  [`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md).
  `NA` yields `NA`.

## Value

The gene diversity `GD = 1 - 1 / (2 * fg)`: a single number in `[0, 1)`,
or `NA` when `fg` is `NA`.

## Details

Gene diversity is the expected heterozygosity retained relative to the
founding gene pool, `GD = 1 - 1 / (2 * FG)`, where `FG` is the founder
genome equivalents (see
[`calcFG`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md)).
It summarizes how much of the founders' allelic diversity still
survives: 0 means none is retained, and it approaches (never reaches) 1
as `FG` grows.

`GD` is a diversity proportion, not a count of effective individuals,
and it is computed over the same analysis set as `FG`. `NA` propagates:
when `FG` is `NA` (the zero-retention degeneracy
[`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md)
reports), `GD` is `NA`.

## References

Gene diversity is derived here from the founder genome equivalents
([`calcFG`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md))
of Lacy RC. 1989. Analysis of founder representation in pedigrees:
founder equivalents and founder genome equivalents. Zoo Biol 8:111-123.

## See also

Other genetic value analysis:
[`calcA()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md),
[`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
[`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
[`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
[`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md),
[`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
[`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md),
[`calcNeSexRatio()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md),
[`calcNeVariance()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeVariance.md),
[`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md)

## Examples

``` r
calcGeneDiversity(20) # 0.975
#> [1] 0.975
calcGeneDiversity(52.75) # gene diversity at the qcPed FG
#> [1] 0.9905213
```
