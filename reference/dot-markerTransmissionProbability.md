# Probability a parent transmits the reference allele

Internal helper for
[`markerParentageLikelihood`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md)
(issue \#147 Slice 1, D2). For reference allele `refAllele`, the value
is the fraction of the parent's two alleles equal to `refAllele`: a
parent homozygous for `refAllele` transmits it with probability 1; a
heterozygous parent, 0.5; a parent homozygous for any other allele, 0.
At a multiallelic locus all non-reference alleles are lumped together.

## Usage

``` r
.markerTransmissionProbability(genoStr, refAllele)
```

## Arguments

- genoStr:

  a single genotype string (`"lo/hi"` format, as in one cell of a
  [`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md)
  result).

- refAllele:

  the reference allele at this locus.

## Value

A numeric scalar in `{0, 0.5, 1}`.
