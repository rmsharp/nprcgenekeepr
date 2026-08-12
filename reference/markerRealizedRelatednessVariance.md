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
new population-genetics framework. Every other pedigree-relationship
category (grandparent, cousin, avuncular, more distant, unrelated, self)
returns `NA` for the variance, not an error – a pedigree-wide call will
legitimately include many such pairs as a matter of course.

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

- nChr:

  integer; chromosome count (e.g. autosome count for the species). Must
  be a single positive value.

- mapLength:

  numeric; total autosomal genetic map length in Morgans. Must be a
  single positive value.

- ids:

  character vector of IDs or `NULL` to which the analysis should be
  restricted, as in
  [`convertRelationships`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md).

## Value

A dataframe with columns `id1`, `id2`, `kinship`, `relation`, `R`
(pedigree relationship, `2 * kinship`), `varR` (the realized-relatedness
variance estimate), and `sdR` (its square root). `varR`/`sdR` are `NA`
for every `relation` other than `"Parent-Offspring"`, `"Full-Siblings"`,
or `"Half-Siblings"`.

## Details

Relationship pairs are classified from the pedigree structure via the
existing
[`convertRelationships`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md)
(not re-derived). The variance combines `nChr` chromosomes, each
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
#>     id1 id2 kinship               relation      R         varR        sdR
#> 1     A   A 0.50000                   Self 1.0000           NA         NA
#> 2     A   B 0.00000            No Relation 0.0000           NA         NA
#> 3     A   C 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 4     A   D 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 5     A   E 0.00000            No Relation 0.0000           NA         NA
#> 6     A   F 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 7     A   G 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 8     A   H 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 9     A   I 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 10    A   J 0.00000            No Relation 0.0000           NA         NA
#> 11    A   K 0.00000            No Relation 0.0000           NA         NA
#> 12    A   L 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 13    A   M 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 14    A   N 0.00000            No Relation 0.0000           NA         NA
#> 15    A   O 0.00000            No Relation 0.0000           NA         NA
#> 16    A   P 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 17    A   Q 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 19    B   B 0.50000                   Self 1.0000           NA         NA
#> 20    B   C 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 21    B   D 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 22    B   E 0.00000            No Relation 0.0000           NA         NA
#> 23    B   F 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 24    B   G 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 25    B   H 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 26    B   I 0.00000            No Relation 0.0000           NA         NA
#> 27    B   J 0.00000            No Relation 0.0000           NA         NA
#> 28    B   K 0.00000            No Relation 0.0000           NA         NA
#> 29    B   L 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 30    B   M 0.00000            No Relation 0.0000           NA         NA
#> 31    B   N 0.00000            No Relation 0.0000           NA         NA
#> 32    B   O 0.00000            No Relation 0.0000           NA         NA
#> 33    B   P 0.00000            No Relation 0.0000           NA         NA
#> 34    B   Q 0.00000            No Relation 0.0000           NA         NA
#> 37    C   C 0.50000                   Self 1.0000           NA         NA
#> 38    C   D 0.25000          Full-Siblings 0.5000 0.0018350199 0.04283713
#> 39    C   E 0.00000            No Relation 0.0000           NA         NA
#> 40    C   F 0.12500         Full-Avuncular 0.2500           NA         NA
#> 41    C   G 0.12500         Full-Avuncular 0.2500           NA         NA
#> 42    C   H 0.25000          Full-Siblings 0.5000 0.0018350199 0.04283713
#> 43    C   I 0.12500          Half-Siblings 0.2500 0.0009175099 0.03029043
#> 44    C   J 0.00000            No Relation 0.0000           NA         NA
#> 45    C   K 0.00000            No Relation 0.0000           NA         NA
#> 46    C   L 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 47    C   M 0.12500          Half-Siblings 0.2500 0.0009175099 0.03029043
#> 48    C   N 0.00000            No Relation 0.0000           NA         NA
#> 49    C   O 0.00000            No Relation 0.0000           NA         NA
#> 50    C   P 0.06250      Avuncular - Other 0.1250           NA         NA
#> 51    C   Q 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 55    D   D 0.50000                   Self 1.0000           NA         NA
#> 56    D   E 0.00000            No Relation 0.0000           NA         NA
#> 57    D   F 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 58    D   G 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 59    D   H 0.25000          Full-Siblings 0.5000 0.0018350199 0.04283713
#> 60    D   I 0.12500          Half-Siblings 0.2500 0.0009175099 0.03029043
#> 61    D   J 0.00000            No Relation 0.0000           NA         NA
#> 62    D   K 0.00000            No Relation 0.0000           NA         NA
#> 63    D   L 0.12500         Full-Avuncular 0.2500           NA         NA
#> 64    D   M 0.12500          Half-Siblings 0.2500 0.0009175099 0.03029043
#> 65    D   N 0.00000            No Relation 0.0000           NA         NA
#> 66    D   O 0.00000            No Relation 0.0000           NA         NA
#> 67    D   P 0.06250      Avuncular - Other 0.1250           NA         NA
#> 68    D   Q 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 73    E   E 0.50000                   Self 1.0000           NA         NA
#> 74    E   F 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 75    E   G 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 76    E   H 0.00000            No Relation 0.0000           NA         NA
#> 77    E   I 0.00000            No Relation 0.0000           NA         NA
#> 78    E   J 0.00000            No Relation 0.0000           NA         NA
#> 79    E   K 0.00000            No Relation 0.0000           NA         NA
#> 80    E   L 0.00000            No Relation 0.0000           NA         NA
#> 81    E   M 0.00000            No Relation 0.0000           NA         NA
#> 82    E   N 0.00000            No Relation 0.0000           NA         NA
#> 83    E   O 0.00000            No Relation 0.0000           NA         NA
#> 84    E   P 0.00000            No Relation 0.0000           NA         NA
#> 85    E   Q 0.00000            No Relation 0.0000           NA         NA
#> 91    F   F 0.50000                   Self 1.0000           NA         NA
#> 92    F   G 0.25000          Full-Siblings 0.5000 0.0018350199 0.04283713
#> 93    F   H 0.12500         Full-Avuncular 0.2500           NA         NA
#> 94    F   I 0.06250      Avuncular - Other 0.1250           NA         NA
#> 95    F   J 0.00000            No Relation 0.0000           NA         NA
#> 96    F   K 0.00000            No Relation 0.0000           NA         NA
#> 97    F   L 0.06250           Full-Cousins 0.1250           NA         NA
#> 98    F   M 0.06250      Avuncular - Other 0.1250           NA         NA
#> 99    F   N 0.00000            No Relation 0.0000           NA         NA
#> 100   F   O 0.00000            No Relation 0.0000           NA         NA
#> 101   F   P 0.03125         Cousin - Other 0.0625           NA         NA
#> 102   F   Q 0.06250                  Other 0.1250           NA         NA
#> 109   G   G 0.50000                   Self 1.0000           NA         NA
#> 110   G   H 0.12500         Full-Avuncular 0.2500           NA         NA
#> 111   G   I 0.06250      Avuncular - Other 0.1250           NA         NA
#> 112   G   J 0.00000            No Relation 0.0000           NA         NA
#> 113   G   K 0.00000            No Relation 0.0000           NA         NA
#> 114   G   L 0.06250           Full-Cousins 0.1250           NA         NA
#> 115   G   M 0.06250      Avuncular - Other 0.1250           NA         NA
#> 116   G   N 0.00000            No Relation 0.0000           NA         NA
#> 117   G   O 0.00000            No Relation 0.0000           NA         NA
#> 118   G   P 0.03125         Cousin - Other 0.0625           NA         NA
#> 119   G   Q 0.06250                  Other 0.1250           NA         NA
#> 127   H   H 0.50000                   Self 1.0000           NA         NA
#> 128   H   I 0.12500          Half-Siblings 0.2500 0.0009175099 0.03029043
#> 129   H   J 0.00000            No Relation 0.0000           NA         NA
#> 130   H   K 0.00000            No Relation 0.0000           NA         NA
#> 131   H   L 0.12500         Full-Avuncular 0.2500           NA         NA
#> 132   H   M 0.12500          Half-Siblings 0.2500 0.0009175099 0.03029043
#> 133   H   N 0.00000            No Relation 0.0000           NA         NA
#> 134   H   O 0.00000            No Relation 0.0000           NA         NA
#> 135   H   P 0.06250      Avuncular - Other 0.1250           NA         NA
#> 136   H   Q 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 145   I   I 0.50000                   Self 1.0000           NA         NA
#> 146   I   J 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 147   I   K 0.00000            No Relation 0.0000           NA         NA
#> 148   I   L 0.06250      Avuncular - Other 0.1250           NA         NA
#> 149   I   M 0.12500          Half-Siblings 0.2500 0.0009175099 0.03029043
#> 150   I   N 0.00000            No Relation 0.0000           NA         NA
#> 151   I   O 0.00000            No Relation 0.0000           NA         NA
#> 152   I   P 0.06250      Avuncular - Other 0.1250           NA         NA
#> 153   I   Q 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 163   J   J 0.50000                   Self 1.0000           NA         NA
#> 164   J   K 0.00000            No Relation 0.0000           NA         NA
#> 165   J   L 0.00000            No Relation 0.0000           NA         NA
#> 166   J   M 0.00000            No Relation 0.0000           NA         NA
#> 167   J   N 0.00000            No Relation 0.0000           NA         NA
#> 168   J   O 0.00000            No Relation 0.0000           NA         NA
#> 169   J   P 0.00000            No Relation 0.0000           NA         NA
#> 170   J   Q 0.00000            No Relation 0.0000           NA         NA
#> 181   K   K 0.50000                   Self 1.0000           NA         NA
#> 182   K   L 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 183   K   M 0.00000            No Relation 0.0000           NA         NA
#> 184   K   N 0.00000            No Relation 0.0000           NA         NA
#> 185   K   O 0.00000            No Relation 0.0000           NA         NA
#> 186   K   P 0.00000            No Relation 0.0000           NA         NA
#> 187   K   Q 0.00000            No Relation 0.0000           NA         NA
#> 199   L   L 0.50000                   Self 1.0000           NA         NA
#> 200   L   M 0.06250      Avuncular - Other 0.1250           NA         NA
#> 201   L   N 0.00000            No Relation 0.0000           NA         NA
#> 202   L   O 0.00000            No Relation 0.0000           NA         NA
#> 203   L   P 0.03125         Cousin - Other 0.0625           NA         NA
#> 204   L   Q 0.06250                  Other 0.1250           NA         NA
#> 217   M   M 0.50000                   Self 1.0000           NA         NA
#> 218   M   N 0.00000       Parent-Offspring 0.0000 0.0000000000 0.00000000
#> 219   M   O 0.00000            No Relation 0.0000           NA         NA
#> 220   M   P 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 221   M   Q 0.12500 Grandparent-Grandchild 0.2500           NA         NA
#> 235   N   N 0.50000                   Self 1.0000           NA         NA
#> 236   N   O 0.00000            No Relation 0.0000           NA         NA
#> 237   N   P 0.00000 Grandparent-Grandchild 0.0000           NA         NA
#> 238   N   Q 0.00000            No Relation 0.0000           NA         NA
#> 253   O   O 0.50000                   Self 1.0000           NA         NA
#> 254   O   P 0.25000       Parent-Offspring 0.5000 0.0000000000 0.00000000
#> 255   O   Q 0.00000            No Relation 0.0000           NA         NA
#> 271   P   P 0.50000                   Self 1.0000           NA         NA
#> 272   P   Q 0.06250                  Other 0.1250           NA         NA
#> 289   Q   Q 0.50000                   Self 1.0000           NA         NA
```
