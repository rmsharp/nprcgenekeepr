# Rank candidate replacement parents by a multilocus likelihood (LOD) score

For each recorded parent
[`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)
flags as Mendelian-inconsistent with its offspring's marker genotype,
ranks candidate replacement parents using a CERVUS-style multilocus
likelihood-ratio (LOD) score – the field's own answer to exactly this
problem shape (Meagher & Thompson 1986; operationalized by Marshall,
Slate, Kruuk & Pemberton 1998), independently validated as the captive
-primate-colony domain's de facto standard by de Groot et al. (2025), a
real captive macaque colony precedent already cited by
[`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md).
This is a report-only diagnostic: it never writes to
`pedigree$sire`/`pedigree$dam` – "requires curator review rather than
silently rewriting a pedigree," per the issue's own words.
[`markerParentageExclusion()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)
itself is untouched and remains the independent Mendelian-exclusion
check.

## Usage

``` r
markerParentageLikelihood(
  genotypeMatrix,
  pedigree,
  id = NULL,
  role = NULL,
  candidates = NULL,
  minLoci = 4L,
  maxExclusions = 2L
)
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
  standard pedigree shape used throughout this package.

- id:

  optional single offspring id to score. When `NULL` (together with
  `role`, the default), every (offspring, role) pair
  [`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)
  flags is auto-detected and scored.

- role:

  optional, one of `"sire"`/`"dam"` – the recorded -parent slot to score
  candidates for. Required together with `id` when scoring a single slot
  on demand (e.g. a curator's proactive check on an animal that is not
  (yet) flagged).

- candidates:

  optional character vector of candidate ids, used only together with an
  explicit `id`/`role`. When `NULL` (the default), candidates come from
  [`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)'s
  own `sires`/`dams` list for that `id` (auto-detection always uses this
  default – `candidates` has no effect in auto-detect mode).

- minLoci:

  integer; candidates scored on fewer than this many jointly -genotyped
  loci are flagged `lowPower = TRUE`. Default `4L`.

- maxExclusions:

  integer; passed through to
  [`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)
  for auto-detection, and used identically here for each candidate's own
  `excluded` diagnostic and for deciding whether a genotyped
  other-parent qualifies for trio conditioning. Default `2L`.

## Value

A data frame, one row per (offspring `id`, `role`, `candidateId`),
ranked by `LOD` descending within each (`id`, `role`) group: `id`,
`role`, `candidateId`, `LOD`, `delta` (gap to the next-ranked candidate
in the group; `NA` for the lowest-ranked row), `nLociUsed`, `excluded`
(the same opposite-homozygote diagnostic
[`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)
uses, parameterized against this candidate – never overloading that
function's own `flagged` column), `lowPower`. A zero-row data frame
(full column shape) is returned when no pair is checkable. This function
never modifies `pedigree`.

## Details

**Formula.** For each jointly-genotyped locus, the per-locus likelihood
ratio compares H1 (the candidate is the true parent) against H2 (the
candidate is an unrelated individual, drawn at random from the
colony-wide reference population) using ordinary Mendelian transmission
probabilities and Hardy-Weinberg population genotype frequencies (well
-defined because
[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md)
guarantees exactly two alleles per locus). When the offspring's other
recorded parent is genotyped and not itself Mendelian-excluded (its own
opposite-homozygote count against the offspring does not exceed
`maxExclusions`), it is incorporated as a known second parent at that
locus (a trio likelihood, matching Marshall et al. 1998's own formula,
which conditions on a known mother when scoring candidate fathers);
otherwise that locus falls back to a candidate-only (dyad) likelihood
using the population allele frequency in place of the unknown second
parent. `LOD` is the sum of per-locus log-likelihood ratios across all
jointly-genotyped loci between the offspring and the candidate.

**Reference-population allele frequencies are colony-wide**, computed
from every non-missing genotype call at that locus in `genotypeMatrix`
(the same "whatever subset is passed in" convention
[`markerExpectedHeterozygosity`](https://github.com/rmsharp/nprcgenekeepr/reference/markerExpectedHeterozygosity.md)
already uses) – matching the direct captive-colony precedent of de Groot
et al. (2025), who used colony-wide frequencies rather than an external
reference population. Structured/inbred captive pedigrees can violate
the underlying Hardy-Weinberg assumption, biasing the H2 null; this is a
documented limitation, not corrected here.

**No simulation-calibrated percentage confidence is reported.** CERVUS
-style confidence statistics require ~100,000-simulation Monte Carlo
calibration per parameter set – a materially larger, separable
engineering investment. Instead, `delta` (the LOD gap to the next
-ranked candidate within the same offspring/role group) and `nLociUsed`
are reported alongside the raw `LOD`, explicitly uncalibrated. **A
single Mendelian-incompatible (opposite-homozygote) locus drives `LOD`
to exactly `-Inf`** – a true probability-zero Mendelian impossibility
under this no-genotyping-error formula – which can happen even when
`excluded` is `FALSE` (i.e. the candidate's own opposite-homozygote
count is at or below `maxExclusions`, the tolerance threshold
[`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)
itself uses for ordinary genotyping error): `LOD` has no equivalent
error tolerance in this formula. A genotyping-error-tolerant extension
(Kalinowski, Taper & Marshall 2007) is deliberately deferred, pending
independent re-verification of that paper's own eqns 1-2 against its
primary source (this session's Pre-RED found a spotted internal
inconsistency in that paper's own Appendix, and its 2010 corrigendum was
unretrievable).

**Small marker panels (2-10 loci) are underpowered.** At this package's
realistic panel sizes, LOD-based assignment sits inside the literature's
own documented underpowered zone, and a full/half sibling of the true
parent can plausibly outrank it. `minLoci` is a fixed,
literature-informed, user-overridable heuristic (mirroring
[`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)'s
own `maxExclusions` precedent, not a mathematically-derived cutoff):
candidates scored on fewer than `minLoci` jointly-genotyped loci are
flagged `lowPower = TRUE` rather than silently ranked as if fully
powered.

**Ties** at small panel sizes are surfaced explicitly – every tied
candidate appears as its own row, never silently deduplicated or
dropped. Two candidates exactly tied (including two `-Inf` values, a
real, hand-verified case) report `delta = 0` between them, not `NaN`.

**A candidate/offspring pair sharing zero genotyped loci** is reported,
not silently dropped: `nLociUsed = 0L`, `LOD = NA_real_`,
`lowPower = TRUE`, `excluded = NA` (undefined, mirroring
[`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)'s
own convention for the same zero-shared-evidence case), with a warning
naming the pair.

## References

Meagher, T. R., & Thompson, E. (1986). The relationship between single
parent and parent pair genetic likelihoods in genealogy reconstruction.
*Theoretical Population Biology*, 29(1), 87-106.
[doi:10.1016/0040-5809(86)90007-1](https://doi.org/10.1016/0040-5809%2886%2990007-1)

Marshall, T. C., Slate, J., Kruuk, L. E. B., & Pemberton, J. M. (1998).
Statistical confidence for likelihood-based paternity inference in
natural populations. *Molecular Ecology*, 7(5), 639-655.
[doi:10.1046/j.1365-294x.1998.00374.x](https://doi.org/10.1046/j.1365-294x.1998.00374.x)

Kalinowski, S. T., Taper, M. L., & Marshall, T. C. (2007). Revising how
the computer program CERVUS accommodates genotyping error increases
success in paternity assignment. *Molecular Ecology*, 16(5), 1099-1106.
[doi:10.1111/j.1365-294X.2007.03089.x](https://doi.org/10.1111/j.1365-294X.2007.03089.x)

## See also

[`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md),
[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md),
[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md)

## Examples

``` r
library(nprcgenekeepr)
markerGenotype <- data.frame(
  id = c("O", "O", "D", "D", "C1", "C1", "C2", "C2"),
  locus = c("L1", "L2", "L1", "L2", "L1", "L2", "L1", "L2"),
  allele1 = c("A", "A", "A", "A", "A", "A", "B", "B"),
  allele2 = c("A", "B", "B", "A", "A", "B", "B", "B"),
  stringsAsFactors = FALSE
)
genotypeMatrix <- buildMarkerGenotypeMatrix(markerGenotype)
pedigree <- data.frame(id = "O", sire = "C2", dam = "D",
                        stringsAsFactors = FALSE)
markerParentageLikelihood(genotypeMatrix, pedigree, id = "O", role = "sire",
                           candidates = c("C1", "C2"), minLoci = 1L)
#>   id role candidateId       LOD delta nLociUsed excluded lowPower
#> 1  O sire          C1 0.4700036   Inf         2    FALSE    FALSE
#> 2  O sire          C2      -Inf    NA         2    FALSE    FALSE
```
