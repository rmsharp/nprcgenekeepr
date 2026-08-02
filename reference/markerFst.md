# Compute a between-center allele-frequency differentiation statistic (Fst)

Estimates Hudson's Fst – a population-level, between-center genetic
differentiation statistic – from two centers' marker genotype matrices,
at each locus genotyped in both centers, pooled across loci. Unlike
[`resolveCrossCenterIds`](https://github.com/rmsharp/nprcgenekeepr/reference/resolveCrossCenterIds.md)
(Slice 4), this is a two-*dataset* comparison with no per-animal
identity linkage involved – exactly the capability audit's own Dimension
6/8 framing of "identity-by-state / allele-frequency differentiation
between centers."

## Usage

``` r
markerFst(genotypeMatrixA, genotypeMatrixB)
```

## Arguments

- genotypeMatrixA:

  a character matrix as returned by
  [`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md)
  for Center A: rows are individual `id`s, columns are loci, and each
  cell is that individual's two alleles at that locus, sorted and joined
  by `"/"` (or `NA` if not genotyped at that locus).

- genotypeMatrixB:

  the same shape as `genotypeMatrixA`, for Center B.

## Value

A list with two elements: `perLocus`, a named numeric vector of Hudson's
Fst at each locus genotyped in both centers (names taken from the
shared, biallelic loci; `NA` for an excluded locus); and `pooledFst`,
the single ratio-of-sums summary across all valid loci (`NA` if no locus
is valid).

## Details

**Why Hudson's estimator, not Weir & Cockerham (1984) or Nei's Gst.**
This slice's Pre-RED research (a 3-angle research pass plus an
independent adversarial verification) found:

- Weir & Cockerham (1984) – the estimator most often reached for by name
  – becomes biased by the *ratio* of the two populations' sample sizes
  when repurposed for a pairwise comparison between two specific, named
  populations (as opposed to its original assumption of several
  populations sharing identical drift): Bhatia, Patterson, Sankararaman
  & Price (2013) demonstrate this empirically (their Table 1 –
  resampling one population to a smaller size shifted the Weir-Cockerham
  estimate by more than 8 standard errors, while Hudson's estimate was
  essentially unchanged) and explicitly, repeatedly recommend Hudson's
  estimator for exactly this two-named-population case. This matters
  concretely here because real per-center marker panels are expected to
  have modest, plausibly unequal sample sizes (design constraint D2 of
  the issue \#130 plan).

- The adversarial verification pass additionally found that the simple
  two-term \\(MSP-MSG)/(MSP+(n_c-1)MSG)\\ form initially considered for
  "Weir & Cockerham (1984)" is not actually what that name refers to in
  the literature or in independent software (`scikit-allel`,
  `hierfstat`) – the true estimator has a third, heterozygosity-driven
  variance component, and the two-term special case differed from the
  full estimator by roughly 40% on a hand-computed check. Implementing
  the truncated formula under a "Weir & Cockerham" citation would have
  shipped a wrong, mislabeled statistic.

- Nei's Gst is not a single unambiguous formula either: at least three
  numerically different two-population specializations exist across Nei
  (1973), Nei & Chesser (1983), and Nei (1986/1987), differing by up to
  a factor of 2 for the same input data – and neither Bhatia et
  al. (2013) nor Meirmans & Hedrick (2011) recommend any of them over
  Hudson's estimator for this scenario.

- Hudson's estimator (as given in closed form by Bhatia et al. 2013) is
  also the algebraically simplest of the three – a single ratio, no
  ANOVA/variance-component decomposition – so it carries the least
  residual formula risk while still matching this package's base-R-only,
  no-new-hard-dependency design constraint (D2).

**Pooling across loci: ratio of sums, not mean of per-locus ratios.**
Bhatia et al. (2013) show that averaging per-locus Fst values directly
is materially biased (their own worked example: a more than 2-fold
difference for the same data, driven by loci with small denominators)
and explicitly recommend summing numerators and denominators separately
before dividing once. `pooledFst` here follows that recommendation; it
is deliberately not the mean of `perLocus`.

**Reference allele.** Each shared, biallelic locus has exactly two
alleles by construction
([`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md)
enforces this within each center's own file); the alphabetically-first
allele observed across *both* centers' non-missing genotypes at that
locus is used as the consistent reference allele for that locus's
frequency comparison. (A locus whose combined, cross-center allele set
exceeds two distinct alleles – e.g. each center's file is independently
biallelic but the two centers used different marker labels for the same
locus name – is not defended against; this function assumes the two
files genuinely describe the same marker panel.)

**Undefined/edge cases.** A locus present in only one center's matrix is
silently excluded from both `perLocus` and the pooled sums (a plain
locus-name intersection, not a warned condition). A locus with zero
genotyped individuals in either center, or one that is monomorphic for
the same allele in both centers (an exact `0/0`), is excluded with a
warning naming the locus – `NA`, not an error, matching
[`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)'s
and
[`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)'s
precedent for the same kind of no-shared-informative-evidence case. A
per-locus (or pooled) Fst value may legitimately be negative – sampling
noise smaller than expected under the null – and is never clamped to
zero.

## References

Hudson, R. R., Slatkin, M., & Maddison, W. P. (1992). Estimation of
levels of gene flow from DNA sequence data. *Genetics*, 132(2), 583-589.
[doi:10.1093/genetics/132.2.583](https://doi.org/10.1093/genetics/132.2.583)

Bhatia, G., Patterson, N., Sankararaman, S., & Price, A. L. (2013).
Estimating and interpreting FST: The impact of rare variants. *Genome
Research*, 23(9), 1514-1521.
[doi:10.1101/gr.154831.113](https://doi.org/10.1101/gr.154831.113)

## See also

[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md),
[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md),
[`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)

## Examples

``` r
library(nprcgenekeepr)
genotypeA <- data.frame(
  id = c("A1", "A1", "A2", "A2"),
  locus = c("L1", "L2", "L1", "L2"),
  allele1 = c("A", "A", "A", "A"),
  allele2 = c("A", "B", "B", "A"),
  stringsAsFactors = FALSE
)
genotypeB <- data.frame(
  id = c("B1", "B1", "B2", "B2"),
  locus = c("L1", "L2", "L1", "L2"),
  allele1 = c("B", "B", "A", "B"),
  allele2 = c("B", "B", "B", "B"),
  stringsAsFactors = FALSE
)
matrixA <- buildMarkerGenotypeMatrix(genotypeA)
matrixB <- buildMarkerGenotypeMatrix(genotypeB)
markerFst(matrixA, matrixB)
#> $perLocus
#>        L1        L2 
#> 0.2000000 0.6666667 
#> 
#> $pooledFst
#> [1] 0.4545455
#> 
```
