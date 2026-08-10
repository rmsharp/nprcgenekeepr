# Count opposite-homozygote (Mendelian-conflict) loci between two genotype rows

Internal helper extracted from
[`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)
(issue \#147 Slice 1, D7) so
[`markerParentageLikelihood`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md)
can reuse the identical "informative conflict" comparison against an
arbitrary candidate parent, rather than forking a second,
independently-written comparison routine. Behavior-preserving:
[`markerParentageExclusion()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)'s
own exported signature, behavior, and test suite are unaffected by this
extraction (see the golden-master regression test in
`test_markerParentageExclusion.R`).

## Usage

``` r
.markerOppositeHomozygoteCount(genoA, genoB)
```

## Arguments

- genoA, genoB:

  two genotype-string vectors, same shape (and same locus order) as a
  single row of a
  [`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md)
  result.

## Value

A list with `exclusionCount` (integer; `NA_integer_` if `nLoci` is 0)
and `nLoci` (integer, the number of jointly non-missing loci compared).
