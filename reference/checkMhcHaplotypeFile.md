# Check a wide-format MHC haplotype designation file

Validates the structure of a wide per-animal MHC haplotype designation
table: exactly three columns – `id` plus the animal's two named
haplotype designations, one row per animal. This is the explicit input
designation for MHC haplotype reporting (issue \#148): a curator
designates data as MHC by supplying it through this format, and no MHC
semantics are ever inferred from locus or column names (the format has
no locus names). A new, sibling input family: the long-format marker
validators
([`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md),
[`checkLinkageMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLinkageMarkerGenotypeFile.md),
[`checkSequenceGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSequenceGenotypeFile.md))
and the single-locus
[`checkGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkGenotypeFile.md)
path are untouched by this one.

## Usage

``` r
checkMhcHaplotypeFile(genotype)
```

## Arguments

- genotype:

  dataframe with wide-format MHC haplotype data: exactly three columns,
  `id`, `haplotype1`, `haplotype2` (one row per animal; any column
  names, see Details).

## Value

The genotype dataframe, checked to ensure the column count, first-column
identity, and row uniqueness are all valid. The returned dataframe has
its column names forced to `c("id", "haplotype1", "haplotype2")`.

## Details

Column names are not prescribed: the first column must be id-like
(case-insensitive match on `"id"`) and is forced to `id`; the second and
third are forced to `haplotype1` and `haplotype2`, so a colony file
with, e.g., `first_name`/`second_name` headers (the bundled
[`rhesusGenotypes`](https://github.com/rmsharp/nprcgenekeepr/reference/rhesusGenotypes.md)
shape) loads unchanged. `NA`/empty cells pass validation – a missing
call is the statistics layer's concern, not a structural error. A
trailing `?` on a designation (an uncertain, provisional call) is
likewise not validation's business; see the issue \#148 design plan's D3
parse rule. Haplotype designations are otherwise opaque labels: never
parsed, split, or matched against MHC region names.

## See also

[`rhesusGenotypes`](https://github.com/rmsharp/nprcgenekeepr/reference/rhesusGenotypes.md),
[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md)

## Examples

``` r
library(nprcgenekeepr)
checked <- checkMhcHaplotypeFile(rhesusGenotypes)
head(checked)
#>       id haplotype1  haplotype2
#> 1 I67LRJ  A004_B002  A004_B048a
#> 2 K0M2RD A004_B012b  A008_B017a
#> 3 ZPVN1V A008_B015b A002a_B069a
#> 4 0F4FY1 A004_B012b A008_B015b?
#> 5 ZHVYYN  A007_B008  A019_B017a
#> 6 K1HTZ8 A004_B012b  A006_B024a
```
