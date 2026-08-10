# Compute per-allele population frequency at one locus from a genotype matrix

Internal helper for
[`markerParentageLikelihood`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md)
(issue \#147 Slice 1, D9). Mirrors
[`markerExpectedHeterozygosity`](https://github.com/rmsharp/nprcgenekeepr/reference/markerExpectedHeterozygosity.md)'s
own inline "parse alleles out of the `lo/hi` genotype string, tabulate"
pattern, factored into a small, independent, non-exported helper rather
than modifying that (or any other) already-shipped statistical
function's internals as a side effect of this feature (see this slice's
own design document, D9, for why a fourth independent reimplementation
was chosen over a shared extraction touching three existing files).

## Usage

``` r
.markerAlleleFrequencyTable(genotypeMatrix, locus)
```

## Arguments

- genotypeMatrix:

  a character matrix as returned by
  [`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md):
  rows are individual `id`s, columns are loci, and each cell is that
  individual's two alleles at that locus, sorted and joined by `"/"` (or
  `NA` if not genotyped at that locus).

- locus:

  a single locus name (one of `colnames(genotypeMatrix)`).

## Value

A named numeric vector, allele -\> frequency, computed from the non-`NA`
cells at `locus` only. A locus monomorphic among genotyped individuals
returns a length-1 vector.
