# Estimate the variance of realized relatedness around pedigree kinship

Pedigree-expected relatedness (this package's existing
[`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
output, doubled) is only an average – the *actual* proportion of genome
shared identical-by-descent (IBD) between two relatives varies around
that expectation because of Mendelian sampling and linkage (finite
chromosome number/map length creates covariance in IBD status among
nearby loci). This function estimates that variance for
Parent-Offspring, Full-Siblings, and Half-Siblings pairs (issue \#153,
D3a) – the closed-form solution of Hill & Weir (2011), extending the
pedigree kinship this package already computes rather than requiring a
new population-genetics framework. It lists only those three kinds of
pairs; every other pair (grandparent, cousin, avuncular, more distant,
unrelated, self) is left out, and
[`convertRelationships`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md)
lists every pair.

## Usage

``` r
markerRealizedRelatednessVariance(kmat, ped, nChr, mapLength, ids = NULL)
```

## Arguments

- kmat:

  square kinship matrix, as produced by
  [`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md).

- ped:

  dataframe with (at least) `id`, `sire`, and `dam` columns, as used by
  [`convertRelationships`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md).
  Ids given as numbers or as a factor, here or in `ids`, are taken as
  their text.

- nChr:

  chromosome count (e.g. autosome count for the species), meant to be a
  whole number. Only a single positive numeric value is enforced, so a
  non-integer such as `20.5` is accepted.

- mapLength:

  numeric; total autosomal genetic map length in Morgans. Must be a
  single positive value.

- ids:

  character vector of IDs or `NULL` to which the analysis should be
  restricted, as in
  [`convertRelationships`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md).

## Value

A dataframe with one row for each `"Parent-Offspring"`,
`"Full-Siblings"` or `"Half-Siblings"` pair and columns `id1`, `id2`,
`kinship`, `relation`, `R` (pedigree relationship, `2 * kinship`),
`varR` (the realized-relatedness variance estimate), and `sdR` (its
square root).

## Details

Pairs are named by the rules of
[`convertRelationships`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md)
and listed in its order, but only an animal with each of its parents and
two animals sharing a parent are looked at, so the table of every pair
is never built. The variance combines `nChr` chromosomes, each
approximated as the average length `mapLength / nChr` – Hill & Weir
(2011) give an exact weighted-sum combination rule (their equation 5)
only for lineal descendants; for Full-Sib/Half-Sib pairs they state in
prose that this equal-length approximation closely matches a real
heterogeneous-length genome, which this package's own PRE-RED research
verified numerically against their published human-genome Table 2
(within ~2%; see the test file header for the full derivation).

## References

Hill WG, Weir BS. 2011. Variation in actual relationship as a
consequence of Mendelian sampling and linkage. Genetics Research
93(1):47-64.

## See also

[`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md),
[`convertRelationships`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md)

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::smallPed
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
## Rhesus macaque autosome count/map length are used only as an example
## scale -- callers should supply values appropriate to their own species.
markerRealizedRelatednessVariance(kmat, ped, nChr = 20L, mapLength = 28)
#>     id1 id2 kinship         relation    R         varR        sdR
#> 3     A   C   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 4     A   D   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 8     A   H   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 9     A   I   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 13    A   M   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 17    A   Q   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 20    B   C   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 21    B   D   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 25    B   H   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 38    C   D   0.250    Full-Siblings 0.50 0.0018350199 0.04283713
#> 42    C   H   0.250    Full-Siblings 0.50 0.0018350199 0.04283713
#> 43    C   I   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
#> 46    C   L   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 47    C   M   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
#> 57    D   F   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 58    D   G   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 59    D   H   0.250    Full-Siblings 0.50 0.0018350199 0.04283713
#> 60    D   I   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
#> 64    D   M   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
#> 74    E   F   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 75    E   G   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 92    F   G   0.250    Full-Siblings 0.50 0.0018350199 0.04283713
#> 128   H   I   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
#> 132   H   M   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
#> 146   I   J   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 149   I   M   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
#> 182   K   L   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 218   M   N   0.000 Parent-Offspring 0.00 0.0000000000 0.00000000
#> 220   M   P   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
#> 254   O   P   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
```
