# Calculates the sampling standard error of genome uniqueness for each ID

Part of Genetic Value Analysis

## Usage

``` r
calcGUSE(alleles, threshold = 1L, byID = FALSE, pop = NULL)
```

## Arguments

- alleles:

  dataframe containing an `AlleleTable` (the same input
  [`calcGU`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md)
  takes): an `id` column, a `parent` column, and one integer column per
  gene-drop iteration. Produced by
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md).

- threshold:

  an integer indicating the maximum number of copies of an allele that
  can be present in the population for it to be considered rare. Default
  is 1.

- byID:

  logical variable of length 1 that is passed through to eventually be
  used by
  [`alleleFreq()`](https://github.com/rmsharp/nprcgenekeepr/reference/alleleFreq.md),
  which calculates the count of each allele in the provided vector. If
  `byID` is TRUE and ids are provided, the function will only count the
  unique alleles for an individual (homozygous alleles will be counted
  as 1).

- pop:

  character vector with animal IDs to consider as the population of
  interest, otherwise all animals will be considered. The default is
  NULL.

## Value

Dataframe `rows: id, col: guSE` A single-column table of
genome-uniqueness standard errors as percentages. Rownames are set to
'id' values that are part of the population.

## Details

Genome uniqueness
([`calcGU`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md))
is a Monte Carlo estimate: it is the average, over the gene-drop
iterations, of the proportion of an animal's two allele copies that are
population-rare. Because it is an average over independent simulated
iterations, it carries sampling error that shrinks as the number of
iterations grows.

For animal `i` let `m_ik = rare[i, k] / 2` be the per-iteration value in
iteration `k` (so the mean of `m_ik` over the `K` iterations equals
`gu_i / 100`). This function returns the exact Monte Carlo standard
error of that mean, on the same percentage scale as
[`calcGU`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md):

\$\$guSE_i = 100 \times \sqrt{\frac{var(m\_{i\cdot})}{K}}\$\$

The standard error is computed from the same per-iteration rare-allele
matrix
([`calcA`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md))
that
[`calcGU`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md)
averages, so it is correct for any `threshold` / `byID` without a
closed-form approximation. An animal whose rare-allele count does not
vary across iterations has a standard error of 0.

## See also

[`calcGU`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
[`calcA`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md),
[`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)

## Examples

``` r
library(nprcgenekeepr)
ped1Alleles <- nprcgenekeepr::ped1Alleles
guSE <- calcGUSE(ped1Alleles, threshold = 3, byID = FALSE, pop = NULL)
```
