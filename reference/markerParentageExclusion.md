# Flag Mendelian-inconsistent recorded parents from marker genotypes

For each animal in `pedigree` with a recorded dam and/or sire that is
also genotyped, compares the animal's marker genotype to that recorded
parent's, locus by locus, and counts loci at which no shared allele is
possible under simple Mendelian inheritance ("opposite homozygotes" –
the animal and the candidate parent are each homozygous for a
*different* allele). Aggregates to a per-pair exclusion count and a
`flagged` decision, directly targeting the issue's named ~5%
dam-misidentification problem: a recorded parent whose genotype evidence
contradicts the pedigree.

## Usage

``` r
markerParentageExclusion(genotypeMatrix, pedigree, maxExclusions = 2L)
```

## Arguments

- genotypeMatrix:

  a character matrix as returned by
  [`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md):
  rows are individual `id`s, columns are loci, and each cell is that
  individual's two alleles at that locus, sorted and joined by `"/"` (or
  `NA` if not genotyped at that locus).

- pedigree:

  a data frame with (at least) columns `id`, `sire`, and `dam` – the
  standard pedigree shape used throughout this package. `sire`/`dam` may
  be `NA` for an unrecorded parent.

- maxExclusions:

  integer; the maximum number of Mendelian- inconsistent loci tolerated
  before a recorded parent is flagged as excluded. Default `2L` (flag
  only at 3 or more).

## Value

A data frame, one row per (offspring, recorded-parent) pair for which
both individuals are genotyped, with columns `id` (the offspring),
`parentId`, `role` (`"dam"` or `"sire"`), `exclusionCount`, `nLoci` (the
number of jointly-genotyped loci the count is based on), and `flagged`
(the canonical boolean vocabulary, matching
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)'s
`flagged` column). A pair with an unrecorded or ungenotyped parent has
no row at all. A data frame with zero rows (but the full column shape)
is returned when no pair is checkable.

## Details

A locus contributes to the exclusion count only when both the animal and
the candidate parent are genotyped there *and* both are homozygous for
different alleles – the same "informative conflict" definition verified
against the ICAR/ISAG cattle-SNP parentage-verification standard at this
function's Pre-RED (a heterozygous genotype at either individual is
never, by itself, Mendelian-inconsistent with a biallelic parent
genotype). Loci where either individual is not genotyped are excluded
from both the numerator and the denominator.

`maxExclusions` is the maximum number of Mendelian-inconsistent loci
*tolerated* before a recorded parent is flagged as excluded (i.e.
flagging requires `exclusionCount > maxExclusions`) – a single
mismatching locus is not, by itself, evidence the recorded parent is
wrong, since ordinary genotyping error or mutation can produce an
isolated conflict even for a true parent-offspring pair. The default of
`2` (flag only at 3 or more inconsistent loci) is grounded in Cifuentes
et al. (2006) and the real captive-macaque-colony parentage precedent of
de Groot et al. (2025), both cited below – it is a raw locus count
calibrated to small/moderate marker panels and typical genotyping error
rates reported in that literature; it does not scale with the number of
loci actually typed or with this package's (currently unmeasured)
per-locus genotyping-error rate, so panels much larger or noisier than
that should retune `maxExclusions` rather than rely on the shipped
default.

When an animal and its recorded parent share zero jointly-genotyped
loci, the exclusion count is undefined; that pair's `exclusionCount` and
`flagged` are `NA` and a warning names the pair (mirroring
[`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)'s
precedent for the same kind of no-shared-evidence case). A recorded
parent that is `NA` (unknown) or that has no row in `genotypeMatrix`
(never genotyped) is silently skipped – no row is emitted for that pair,
since there is no genotype evidence to check.

## References

Cifuentes, L. O., Martinez, E. H., Acuna, M. P., & Jonquera, H. G.
(2006). Probability of exclusion in paternity testing: time to reassess.
*Journal of Forensic Sciences*, 51(2), 349-350.
[doi:10.1111/j.1556-4029.2006.00046.x](https://doi.org/10.1111/j.1556-4029.2006.00046.x)

de Groot, N. G., de Vos-Rouweler, A. J. M., Heijmans, C. M. C., et al.
(2025). Genetic Conservation and Population Management of Non-Human
Primates: Parentage Determination Using Seven Microsatellite-Based
Multiplexes. *Ecology and Evolution*, 15(4), e71216.
[doi:10.1002/ece3.71216](https://doi.org/10.1002/ece3.71216)

## See also

[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md),
[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md),
[`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)

## Examples

``` r
library(nprcgenekeepr)
markerGenotype <- data.frame(
  id = c("A", "A", "B", "B"),
  locus = c("L1", "L2", "L1", "L2"),
  allele1 = c("A", "A", "A", "A"),
  allele2 = c("A", "B", "B", "B"),
  stringsAsFactors = FALSE
)
genotypeMatrix <- buildMarkerGenotypeMatrix(markerGenotype)
pedigree <- data.frame(id = "B", sire = NA_character_, dam = "A",
                        stringsAsFactors = FALSE)
markerParentageExclusion(genotypeMatrix, pedigree)
#>   id parentId role exclusionCount nLoci flagged
#> 1  B        A  dam              0     2   FALSE
```
