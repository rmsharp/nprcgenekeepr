# Check a long-format multi-locus marker genotype file

Validates the structure and legal domain of a long-format marker
genotype table (one row per `id` x `locus`), the input format for the
marker-based (KING-robust) kinship estimator
([`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)).
This is a new, sibling schema to the single-locus
`first_name`/`second_name` genotype format checked by
[`checkGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkGenotypeFile.md)
– that function, and everything downstream of it
([`addGenotype`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md),
[`geneDrop`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)),
is untouched by this one.

## Usage

``` r
checkMarkerGenotypeFile(genotype)
```

## Arguments

- genotype:

  dataframe with long-format marker genotype data: exactly four columns,
  `id`, `locus`, `allele1`, `allele2` (one row per individual x locus).

## Value

The genotype dataframe, checked to ensure the column count, first-column
identity, per-locus allele count, and row uniqueness are all valid. The
returned dataframe has its column names forced to
`c("id", "locus", "allele1", "allele2")`.

## Details

The KING-robust kinship estimator (Manichaikul et al. 2010) is defined
for biallelic markers only – every genotype is classified as
homozygous-reference, heterozygous, or homozygous-alternate, with no
representation for a third allele at a locus. A locus with more than two
distinct alleles observed anywhere in the input is therefore rejected
outright, rather than silently producing an uninterpretable kinship
estimate.

## References

Manichaikul, A., Mychaleckyj, J. C., Rich, S. S., Daly, K., Sale, M., &
Chen, W.-M. (2010). Robust relationship inference in genome-wide
association studies. *Bioinformatics*, 26(22), 2867-2873.
[doi:10.1093/bioinformatics/btq559](https://doi.org/10.1093/bioinformatics/btq559)

## See also

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
checkMarkerGenotypeFile(markerGenotype)
#>   id locus allele1 allele2
#> 1  A    L1       A       A
#> 2  A    L2       A       B
#> 3  B    L1       A       B
#> 4  B    L2       A       B
```
