# Genetic Value Analysis

## Overview

The **genetic value analysis** is the heart of `nprcgenekeepr`. It ranks
the animals in a colony by how much each one contributes to the colony’s
genetic diversity, so that managers can prioritize genetically valuable
animals for breeding and retention (Vinson and Raboin 2015). The ranking
rests on two complementary metrics:

- **mean kinship** – the average kinship coefficient between an animal
  and all animals in the population (itself included). A *low* mean
  kinship is good: it means the animal is only distantly related to the
  rest of the colony, so its genes are under-represented and worth
  propagating.
- **genome uniqueness** – the percentage of an animal’s alleles that are
  *rare* in the population (carried by no more than a few animals),
  estimated by a gene-drop simulation. A *high* genome uniqueness is
  good: it means the animal carries alleles that would be lost if it
  were not bred.

[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
computes both, ranks the population, and also returns colony-level
diversity summaries. This article runs the whole analysis from R, using
the `examplePedigree` data set that ships with the package. The Shiny
app
([`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md))
drives the same
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
through its Genetic Value Analysis tab; here we script it directly.

## Setup

``` r

library(nprcgenekeepr)
set_seed(1L)
```

Genome uniqueness is estimated by a gene-drop simulation – founder
alleles are dropped down the pedigree at random and the rare ones
counted – so the genome uniqueness values (and the
founder-genome-equivalent below) differ between runs unless the seed is
fixed.
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
does **not** set a seed internally, so we call
[`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
once, up front, to make everything reproducible.
([`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
is a thin, version-stable wrapper around
[`set.seed()`](https://rdrr.io/r/base/Random.html).) Mean kinship is
computed deterministically from the pedigree and does not depend on the
seed.

## From studbook to a population

The analysis needs a quality-controlled pedigree and a defined
**population of interest** – the animals whose genetic value we want to
rank.

``` r

breederPed <- qcStudbook(examplePedigree,
  minSireAge    = 2.0,
  minDamAge     = 2.0,
  reportChanges = FALSE,
  reportErrors  = FALSE
)
```

[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
validates and standardizes the studbook (checking parentage, sexes,
dates, and minimum parent age). Next we choose the population of
interest. Here it is the animals that have **at least one known parent**
(so they are not founders) and are **still in the colony** (no exit
date). We mark them with
[`setPopulation()`](https://github.com/rmsharp/nprcgenekeepr/reference/setPopulation.md)
and trim the pedigree to those animals plus the ancestors needed to
compute their kinships.

``` r

focalAnimals <- breederPed$id[!(is.na(breederPed$sire) &
  is.na(breederPed$dam)) &
  is.na(breederPed$exit)]
breederPed <- setPopulation(ped = breederPed, ids = focalAnimals)
trimmedPed <- trimPedigree(focalAnimals, breederPed)

length(focalAnimals)  # animals in the population of interest
#> [1] 327
dim(trimmedPed)        # those animals plus the ancestors kinship needs
#> [1] 704  14
```

## Running the analysis

``` r

gv <- reportGV(trimmedPed,
  guIter   = 50, # gene-drop iterations; use >= 1000 in practice
  guThresh = 1,  # an allele is "unique" if carried by <= this many animals
  byID     = TRUE
)
names(gv)
#>  [1] "report"          "kinship"         "gu"              "fe"             
#>  [5] "fg"              "fgSE"            "neGD"            "neSexRatio"     
#>  [9] "neVariance"      "maleFounders"    "femaleFounders"  "nMaleFounders"  
#> [13] "nFemaleFounders" "total"
```

> The small `guIter` above keeps this article quick to render. For real
> analyses use `guIter >= 1000`; the genome-uniqueness estimates
> stabilize only with many iterations.

[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
returns a list. The two elements you will use most are `report` (the
ranked table) and `kinship` (the pairwise kinship matrix, which
[`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
consumes when forming breeding groups – see the *Forming Breeding
Groups* article). The rest summarize founder diversity (below).

## The ranking report

`report` is a data frame with one row per animal in the population of
interest, already sorted from most to least genetically valuable.

``` r

rpt <- gv[["report"]]
dim(rpt)
#> [1] 327  18
names(rpt)
#>  [1] "id"              "sex"             "age"             "birth"          
#>  [5] "exit"            "population"      "origin"          "sire"           
#>  [9] "dam"             "indivMeanKin"    "zScores"         "gu"             
#> [13] "guSE"            "totalOffspring"  "livingOffspring" "parentage"      
#> [17] "value"           "rank"
head(rpt[, c("id", "sex", "age", "indivMeanKin", "zScores", "gu",
  "value", "rank")], 8)
#>       id sex  age indivMeanKin    zScores gu      value rank
#> 1 1SPLS8   F  7.9  0.010663266 -0.9714998 79 High Value    1
#> 2 KZM9RB   M 30.1  0.003292539 -2.3044922 74 High Value    2
#> 3 WK89I9   F 21.1  0.012121545 -0.7077708 64 High Value    3
#> 4 CFD12A   M 20.8  0.011388376 -0.8403640 57 High Value    4
#> 5 01QRQ4   F 18.2  0.003727064 -2.2259085 54 High Value    5
#> 6 G25E3F   F  7.8  0.014794992 -0.2242792 52 High Value    6
#> 7 CLSVU6   F 23.9  0.009512525 -1.1796107 50 High Value    7
#> 8 50D77I   F 20.1  0.010806022 -0.9456824 50 High Value    8
```

The key columns:

| Column | Meaning |
|----|----|
| `indivMeanKin` | the animal’s mean kinship (lower = less related to the colony = better) |
| `zScores` | mean kinship standardized across the population (mean 0, SD 1) |
| `gu` | genome uniqueness, as a percentage (higher = carries rarer alleles = better) |
| `totalOffspring` / `livingOffspring` | offspring counts |
| `value` | a `High Value` / `Low Value` (occasionally `Undetermined`) flag |
| `rank` | integer rank, 1 = most valuable |

The `rank` and `value` columns come from the ranking scheme in
`orderReport()` and
[`rankSubjects()`](https://github.com/rmsharp/nprcgenekeepr/reference/rankSubjects.md),
which sorts the population into ordered tiers:

1.  imported founders with no offspring;
2.  animals with genome uniqueness above 10%, by **descending genome
    uniqueness** (ties broken by ascending mean kinship) – this is where
    carrying rare alleles earns a high rank;
3.  the remaining animals whose standardized mean kinship is at or below
    0.25 (i.e. no more related to the colony than about average), by
    **ascending mean kinship** – least related ranked highest;
4.  everyone else, flagged `Low Value`, by ascending mean kinship.

Tiers 1–3 are flagged `High Value`. Because tier 2 ranks on genome
uniqueness and tier 3 on mean kinship, the two metrics can disagree –
and the top of the table shows it:

``` r

head(rpt[, c("id", "indivMeanKin", "gu", "rank")], 3)
#>       id indivMeanKin gu rank
#> 1 1SPLS8  0.010663266 79    1
#> 2 KZM9RB  0.003292539 74    2
#> 3 WK89I9  0.012121545 64    3
```

An animal need not have the very lowest mean kinship to rank first;
carrying rare alleles (high genome uniqueness) can place it ahead of a
slightly less related animal. That is the point of using both metrics
rather than either one alone.

``` r

table(rpt$value)
#> 
#> High Value  Low Value 
#>        207        120
```

## Colony-level diversity

Alongside the per-animal ranking,
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
reports two whole-colony measures of how much of the original founders’
diversity survives (Lacy 1989):

``` r

c(foundersKnown = gv$total,
  maleFounders  = gv$nMaleFounders,
  femaleFounders = gv$nFemaleFounders)
#>  foundersKnown   maleFounders femaleFounders 
#>             20              3             17
round(c(fe = gv$fe, fg = gv$fg, fgSE = gv$fgSE), 2)
#>     fe     fg   fgSE 
#> 109.67  47.62   0.29
```

- **Founder equivalents** (`fe = 1 / sum(p^2)`, where `p` is each
  founder’s proportional genetic contribution) is the *effective* number
  of founders – the number of equally contributing founders that would
  give the same diversity as the actual, unequal contributions. It is
  deterministic, so it has no sampling standard error.
- **Founder genome equivalents** (`fg`) goes further, also accounting
  for the founder alleles *lost* to genetic drift over the generations
  (estimated from the same gene drop). Because some alleles are always
  lost, `fg` is smaller than `fe`. Because `fg` is a Monte Carlo
  estimate,
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  also returns `fgSE`, its sampling standard error (shown above and
  displayed inline as `fg +/- fgSE` wherever FG appears); it shrinks
  roughly as `1 / sqrt(iterations)`. At small iteration counts `fg` also
  carries a slight finite-sample (Jensen) bias that the standard error
  does not capture, so prefer more iterations when the precision of `fg`
  matters.

Together they say, in effect, “the colony’s diversity is equivalent to
this many ideal founders” – a smaller number signals a narrower gene
pool.

## Key arguments

| Argument | Default | Meaning |
|----|----|----|
| `ped` | – | the (trimmed, QC’d) pedigree with a `population` column |
| `guIter` | `1000L` | gene-drop iterations (more = more stable genome uniqueness) |
| `guThresh` | `1L` | an allele is “unique” if carried by no more than this many animals |
| `pop` | `NULL` | animal IDs to treat as the population (default: the `population` column) |
| `byID` | `TRUE` | count an individual’s homozygous alleles once when scoring uniqueness |

## See also

- The **Studbook Quality Control** article –
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  validates and standardizes the studbook this analysis consumes, the
  first step before ranking.
- The **Building a Focal-Animal Pedigree Offline** article – build a
  focal-animal pedigree from files with no database, via
  [`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md).
- The **Forming Breeding Groups** article –
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  uses the kinship matrix this analysis returns to assemble genetically
  diverse groups.
- The **Age-Sex Pyramid Plots** article – picture the colony’s age and
  sex structure with
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md).
- [`rankSubjects()`](https://github.com/rmsharp/nprcgenekeepr/reference/rankSubjects.md)
  – the ranking scheme applied to a report.
- [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  – pairwise kinship coefficients from a pedigree.
- [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  – the Shiny app that performs this workflow interactively.

**References.**

Lacy RC (1989). “Analysis of Founder Representation in Pedigrees:
Founder Equivalents and Founder Genome Equivalents.” *Zoo Biology*
8(2):111-123.

Vinson A, Raboin MJ (2015). “A Practical Approach for Designing Breeding
Groups to Maximize Genetic Diversity in a Large Colony of Captive Rhesus
Macaques (*Macaca mulatta*).” *Journal of the American Association for
Laboratory Animal Science* 54(6):700-707.
