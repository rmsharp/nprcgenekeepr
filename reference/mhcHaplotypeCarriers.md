# List the animals carrying each MHC haplotype

Builds the carrier detail table for a wide per-animal MHC haplotype
designation file (the
[`checkMhcHaplotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMhcHaplotypeFile.md)
format): one row per (haplotype x carrying animal), so a colony manager
can go from "which haplotypes are rare"
([`mhcHaplotypeFrequency`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md)'s
summary) to "which animals do I manage." A homozygous animal appears
once per haplotype. The haplotype universe is the summary's – the
distinct *certain* haplotypes – so a label observed only as uncertain
calls has no carrier rows, matching the summary's own
exclude-and-disclose rule.

## Usage

``` r
mhcHaplotypeCarriers(
  genotype,
  rareOnly = TRUE,
  rareFrequencyThreshold = 0.01,
  rareCarrierThreshold = 2L
)
```

## Arguments

- genotype:

  dataframe with wide-format MHC haplotype data as validated by
  [`checkMhcHaplotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMhcHaplotypeFile.md)
  (which this function re-runs defensively): columns `id`, `haplotype1`,
  `haplotype2`, one row per animal.

- rareOnly:

  logical; when `TRUE` (the default) only the haplotypes
  [`mhcHaplotypeFrequency`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md)
  flags rare at the given thresholds are listed, when `FALSE` every
  summary haplotype is.

- rareFrequencyThreshold:

  single non-negative number, passed to
  [`mhcHaplotypeFrequency`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md).
  Default `0.01`.

- rareCarrierThreshold:

  single non-negative number, passed to
  [`mhcHaplotypeFrequency`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md).
  Default `2L`.

## Value

A dataframe with columns `haplotype` (character), `id` (character), and
`uncertain` (logical), one row per (haplotype x carrying animal),
ordered by haplotype then id.

## Details

The `uncertain` column is a per-(haplotype x animal) disclosure: `FALSE`
when the animal has at least one certain call of that haplotype, `TRUE`
when its carriage is only provisional (every call it has of that
haplotype carries the trailing-`?` uncertain marker). Provisional
carriers are listed here – for a rare haplotype, a provisionally typed
carrier is exactly what a manager wants to see – but they are never
counted in
[`mhcHaplotypeFrequency`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md)'s
`nCarriers` or its rare-flag arithmetic. Retaining animals that carry
rare variants is a distinct management objective from maintaining
heterozygosity (Allendorf 1986; Lacy, Ballou & Pollak 2012), which is
what a per-animal carrier list is for.

## References

Allendorf, F. W. (1986). Genetic drift and the loss of alleles versus
heterozygosity. *Zoo Biology*, 5(2), 181-190.
[doi:10.1002/zoo.1430050212](https://doi.org/10.1002/zoo.1430050212)

Lacy, R. C., Ballou, J. D., & Pollak, J. P. (2012). PMx: software
package for demographic and genetic analysis and management of pedigreed
populations. *Methods in Ecology and Evolution*, 3(2), 433-437.
[doi:10.1111/j.2041-210X.2011.00148.x](https://doi.org/10.1111/j.2041-210X.2011.00148.x)

## See also

[`mhcHaplotypeFrequency`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md),
[`checkMhcHaplotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMhcHaplotypeFile.md),
[`rhesusGenotypes`](https://github.com/rmsharp/nprcgenekeepr/reference/rhesusGenotypes.md)

## Examples

``` r
library(nprcgenekeepr)
## Carriers of the rare haplotypes, at the default thresholds
rareCarriers <- mhcHaplotypeCarriers(rhesusGenotypes)
head(rareCarriers)
#>     haplotype     id uncertain
#> 1 A002a_B001a BNHC69     FALSE
#> 2 A002a_B001a K93DCQ     FALSE
#> 3 A002a_B012b 6XRGWW     FALSE
#> 4 A002a_B015a 4A4EC5     FALSE
#> 5 A002a_B024a FHHNGA     FALSE
#> 6 A002a_B069a 7UMJ31     FALSE
## Every haplotype's carriers
allCarriers <- mhcHaplotypeCarriers(rhesusGenotypes, rareOnly = FALSE)
```
