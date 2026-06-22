# Forming Breeding Groups

## Overview

`nprcgenekeepr` can assemble candidate animals into one or more
**breeding groups** that keep close relatives apart while spreading
genetic diversity across the colony, following the approach of Vinson
and Raboin (2015). Groups can be formed three ways:

- **unconstrained** – members are drawn subject only to a kinship
  ceiling;
- **harem** – each group is seeded with a single male and filled with
  other animals;
- **target sex ratio** – each group is filled toward a chosen
  females-per-male ratio.

This article walks the whole pipeline – from a raw studbook to formed
groups – entirely from R, using the `examplePedigree` data set that
ships with the package. The Shiny app
([`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md))
drives the same functions through a point-and-click interface; here we
script them directly.

## Setup

``` r

library(nprcgenekeepr)
set_seed(1L)
```

Group formation makes random draws – which group to fill next, which
animal to add, which males to use as harem sires – so two runs differ
unless the seed is fixed.
[`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
does **not** set a seed internally, so we call
[`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
once, up front, to make everything below reproducible.
([`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
is a thin, version-stable wrapper around
[`set.seed()`](https://rdrr.io/r/base/Random.html).)

## From studbook to candidate list

Breeding-group formation needs two ingredients: a **list of candidate
animals** and a **kinship matrix** giving the relatedness of every
candidate to every other. Both are derived from a quality-controlled
pedigree.

``` r

breederPed <- qcStudbook(examplePedigree,
  minParentAge  = 2.0,
  reportChanges = FALSE,
  reportErrors  = FALSE
)
```

[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
validates and standardizes the studbook (checking parentage, sexes,
dates, and minimum parent age). Next we mark the focal population –
here, the non-founders still in the colony (those with at least one
known parent) – and trim the pedigree to those animals plus the
ancestors needed to compute their kinships.

``` r

focalAnimals <- breederPed$id[!(is.na(breederPed$sire) &
  is.na(breederPed$dam)) &
  is.na(breederPed$exit)]
breederPed <- setPopulation(ped = breederPed, ids = focalAnimals)
trimmedPed <- trimPedigree(focalAnimals, breederPed)

length(focalAnimals)
#> [1] 327
dim(trimmedPed)
#> [1] 704  13
```

[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
runs the genetic value analysis and – the part we need here – returns
the **kinship matrix** for the trimmed pedigree.

``` r

trimmedGeneticValue <- reportGV(trimmedPed,
  guIter   = 50, # genome-uniqueness iterations; use >= 1000 in practice
  guThresh = 3,
  byID     = TRUE,
  updateProgress = NULL
)
kmat <- trimmedGeneticValue[["kinship"]]
dim(kmat)
#> [1] 327 327
```

> The small `guIter` above keeps this article quick to render. For real
> analyses use `guIter >= 1000`; the genome-uniqueness estimates
> stabilize only with many iterations.

Finally, choose the candidates – here, animals born before 2013 that are
still in the colony.

``` r

candidates <- trimmedPed$id[trimmedPed$birth < as.Date("2013-01-01") &
  !is.na(trimmedPed$birth) &
  is.na(trimmedPed$exit)]
length(candidates)
#> [1] 280
```

## Harem groups

With `harem = TRUE`,
[`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
seeds each of the `numGp` groups with one eligible male and then fills
it with other animals, never placing two animals whose kinship exceeds
`threshold` (default `0.015625`, i.e. 1/64 – the kinship of second
cousins) in the same group.

``` r

haremGrp <- groupAddAssign(
  kmat = kmat,
  ped  = trimmedPed,
  candidates = candidates,
  iter  = 10, # group-search iterations; use >= 1000 in practice
  numGp = 6,
  harem = TRUE
)
```

The result is a list with two elements, `group` and `score`. `group`
holds one character vector of animal IDs per group, followed by a final
element collecting any candidates left unplaced (a lone `NA` when every
candidate was assigned):

``` r

names(haremGrp)
#> [1] "group" "score"
lengths(haremGrp$group) # size of each group; the last is the unplaced pool
#> [1] 30 33 32 28 39 28  1
haremGrp$group[[1]]     # the first harem group
#>  [1] "J1R2EW" "3DTD2N" "FL170P" "465ERA" "99BMJW" "K3TNHP" "DRXMW4" "ESUIAF"
#>  [9] "1CIRC9" "S056D5" "2F6J3U" "PI4VHT" "WLMGS1" "RVHVTZ" "3SKITJ" "AIHJ8Z"
#> [17] "3GECJJ" "TXZUKC" "5W621W" "B228Q6" "MTCAIG" "FB5L3N" "13B1QL" "B1WVCN"
#> [25] "SCFSBF" "5EDLL7" "KZY6PD" "WNEAS6" "AZ3L0D" "0IIAEN"
```

## Groups with a target sex ratio

Passing a non-zero `sexRatio` (females per male) fills each group toward
that ratio instead of using a single harem sire. Here we aim for nine
females per male.

``` r

sexRatioGrp <- groupAddAssign(
  kmat = kmat,
  ped  = trimmedPed,
  candidates = candidates,
  iter     = 10,
  numGp    = 6,
  sexRatio = 9.0
)
lengths(sexRatioGrp$group)
#> [1]  35  25  24  30  31  29 106
```

`harem` and `sexRatio` are alternative strategies – use one or the
other. Because the sex-ratio constraint caps how many animals of each
sex a group can hold, more candidates may be left in the trailing
unplaced element than in the harem case; raising `iter` lets the search
place more of them.

## Key arguments

| Argument | Default | Meaning |
|----|----|----|
| `candidates` | – | character vector of animal IDs to place |
| `kmat` | – | kinship matrix from `reportGV()[["kinship"]]` |
| `ped` | – | the (trimmed) pedigree the candidates belong to |
| `numGp` | `1` | number of groups to form |
| `threshold` | `0.015625` | maximum within-group kinship (1/64 = second cousins) |
| `minAge` | `1.0` | minimum age (years) to be placed |
| `harem` | `FALSE` | seed each group with a single male |
| `sexRatio` | `0.0` | target females per male (0 = unconstrained) |
| `iter` | `1000` | group-search iterations (more = better groups) |

## See also

- The **Studbook Quality Control** article –
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  validates and standardizes a studbook, the first step before forming
  groups.
- The **Building a Focal-Animal Pedigree Offline** article – build a
  focal-animal pedigree from files with no database, via
  [`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md).
- The **Genetic Value Analysis** article –
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  produces the kinship matrix
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  consumes here, and ranks animals by mean kinship and genome
  uniqueness.
- The **Age-Sex Pyramid Plots** article – picture the colony’s age and
  sex structure with
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md).
- [`rankSubjects()`](https://github.com/rmsharp/nprcgenekeepr/reference/rankSubjects.md)
  – the ranking scheme applied to a genetic value report.
- [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  – pairwise kinship coefficients from a pedigree.
- [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  – the Shiny app that performs this workflow interactively.

**Reference.** Vinson A, Raboin MJ (2015). “A Practical Approach for
Designing Breeding Groups to Maximize Genetic Diversity in a Large
Colony of Captive Rhesus Macaques (*Macaca mulatta*).” *Journal of the
American Association for Laboratory Animal Science* 54(6):700-707.
