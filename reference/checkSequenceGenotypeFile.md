# Check a long-format sequence-derived marker genotype file

Validates the structure of a long-format marker genotype table (one row
per `id` x `locus`), the same schema
[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md)
checks – but sized and hardened for sequence-derived panels (issue
\#152): a soft, overridable warning above a sparse/GBS-scale panel-size
ceiling, and an explicit rejection of a literal `"."` allele value
(VCF's missing-genotype placeholder), rather than silently counting it
as a real allele. Optionally cross-validates an accompanying
locus-metadata sidecar by reusing
[`checkLocusMetadata`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md),
rather than reinventing that check.

## Usage

``` r
checkSequenceGenotypeFile(genotype, locusMetadata = NULL, maxLoci = 50000L)
```

## Arguments

- genotype:

  dataframe with long-format marker genotype data: exactly four columns,
  `id`, `locus`, `allele1`, `allele2` (one row per individual x locus).

- locusMetadata:

  optional dataframe with locus metadata (see
  [`checkLocusMetadata`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md)):
  `locus`, `chrom`, `pos`, and optionally `cM`, one row per locus. When
  supplied, is validated via
  [`checkLocusMetadata`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md)
  – its own violations propagate unchanged. Defaults to `NULL` (no
  sidecar to validate).

- maxLoci:

  numeric scope-tier ceiling (default `50000L`, this package's own
  sparse/GBS-scale target ceiling) above which a locus count triggers a
  [`warning()`](https://rdrr.io/r/base/warning.html) rather than a
  [`stop()`](https://rdrr.io/r/base/stop.html).

## Value

The genotype dataframe, checked to ensure the column count, first-column
identity, per-locus allele count, absence of a literal `"."`
placeholder, and row uniqueness are all valid. The returned dataframe
has its column names forced to `c("id", "locus", "allele1", "allele2")`.

## Details

All of
[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md)'s
structural checks are retained – exactly four columns, `id` as the first
column, no duplicate `id` x `locus` rows, and the same biallelic-only
rejection the KING-robust kinship estimator (Manichaikul et al. 2010)
requires. Two rules are new: a literal `"."` allele value is rejected
before the biallelic count is even checked, so a curator sees the
correct, actionable error rather than a misleading "more than two
alleles" report (a genotype-preprocessing pipeline emitting VCF-style
missingness that was never converted to `NA` is a real, anticipated
failure mode – see Danecek et al. 2011 for the VCF missing-genotype
convention this guards against); and a locus count above `maxLoci`
produces a [`warning()`](https://rdrr.io/r/base/warning.html), not a
[`stop()`](https://rdrr.io/r/base/stop.html) – the "right" ceiling for
this package's own vectorized implementations is not yet empirically
known, so a hard stop would risk blocking legitimate data.

## References

Manichaikul, A., Mychaleckyj, J. C., Rich, S. S., Daly, K., Sale, M., &
Chen, W.-M. (2010). Robust relationship inference in genome-wide
association studies. *Bioinformatics*, 26(22), 2867-2873.
[doi:10.1093/bioinformatics/btq559](https://doi.org/10.1093/bioinformatics/btq559)

Danecek, P., et al. (2011). The variant call format and VCFtools.
*Bioinformatics*, 27(15), 2156-2158.
[doi:10.1093/bioinformatics/btr330](https://doi.org/10.1093/bioinformatics/btr330)

## See also

[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md),
[`checkLinkageMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLinkageMarkerGenotypeFile.md),
[`checkLocusMetadata`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md),
[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md)

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
checkSequenceGenotypeFile(markerGenotype)
#>   id locus allele1 allele2
#> 1  A    L1       A       A
#> 2  A    L2       A       B
#> 3  B    L1       A       B
#> 4  B    L2       A       B
```
