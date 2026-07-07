# Studbook Quality Control

## Overview

Every analysis in `nprcgenekeepr` – genetic value, breeding-group
formation, the age-sex pyramid – starts from a **quality-controlled
pedigree**. Real studbooks arrive with inconsistent column names, mixed
date formats, sex codes that disagree with how an animal is actually
used as a parent, duplicated records, and impossible parentages.
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
is the single function that validates and standardizes a studbook before
anything else touches it; the *Genetic Value Analysis* and *Forming
Breeding Groups* articles both call it as their very first step.

[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
performs several families of checks:

- **required columns** – the studbook must contain `id`, `sire`, `dam`,
  `sex`, and `birth`;
- **identifier validity** – animal IDs must be alphanumeric (a period is
  not allowed, because it breaks formulas, file names, and namespaces
  across software environments);
- **sex consistency** – an animal used as a sire must be male and one
  used as a dam must be female;
- **date validity** – birth and exit dates must parse to real calendar
  dates;
- **duplicate detection** – the same ID must not appear in two
  conflicting records;
- **minimum parent age** – a parent must be at least `minParentAge`
  years old (default 2.0) at an offspring’s birth.

It runs in one of two modes, controlled by `reportErrors`:

- **production mode** (`reportErrors = FALSE`, the default) returns a
  clean, standardized data frame – silently correcting what it can
  safely repair and **stopping** on anything it cannot;
- **diagnostic mode** (`reportErrors = TRUE`) does not stop. It scans
  the whole studbook and returns a *list* of everything it found, so you
  can see every problem in one pass and fix the source data.

## Setup

``` r

library(nprcgenekeepr)
```

[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
is deterministic – it runs no random simulation – so, unlike the
genetic-value and breeding-group analyses (which seed a gene-drop
simulation), this article needs no
[`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
call to be reproducible.

## Cleaning a real studbook

The package ships `examplePedigree`, a realistic 3,694-animal studbook.
Running it through
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
in production mode returns a standardized pedigree ready for analysis.

``` r

ped <- qcStudbook(examplePedigree,
  minParentAge  = 2.0,
  reportChanges = FALSE,
  reportErrors  = FALSE
)
#> Warning: The `minParentAge` argument of `qcStudbook()` is deprecated as of nprcgenekeepr
#> 2.0.0.
#> ℹ Use minSireAge and minDamAge instead.
dim(ped)
#> [1] 3694   12
names(ped)
#>  [1] "id"           "sire"         "dam"          "sex"          "gen"         
#>  [6] "birth"        "exit"         "age"          "ancestry"     "origin"      
#> [11] "status"       "recordStatus"
head(ped[, c("id", "sire", "dam", "sex", "gen", "birth", "exit", "age")])
#>       id sire  dam sex gen      birth       exit age
#> 1 01WY5E <NA> <NA>   M   0 2005-07-07 2005-08-26 0.1
#> 2 02GZ4L <NA> <NA>   U   0 2004-07-05 2004-08-15 0.1
#> 3 079ZJK <NA> <NA>   F   0       <NA> 1975-01-16  NA
#> 4 08CF4C <NA> <NA>   F   0       <NA> 1966-03-19  NA
#> 5 093AB5 <NA> <NA>   M   0 2004-09-03 2005-01-29 0.4
#> 6 0CRGND <NA> <NA>   F   0 1982-04-01 1982-04-27 0.1
```

The result has standardized columns, founders (animals with no known
parent) marked generation 0, and an `age` column. Because
`examplePedigree` already carries an `age` column,
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
keeps it rather than recomputing ages against the current date, so this
article renders the same numbers every time. When the input has no `age`
column, ages are computed from `birth` to `exit` – or to today’s date
for animals still in the colony.

## What QC standardizes

Before testing for errors,
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
normalizes the studbook so downstream code sees consistent names and
codes. Column names are lower-cased and stripped of spaces, periods, and
underscores, and common aliases are renamed (`egoid` / `ego_id` -\>
`id`, `sireid` -\> `sire`, `damid` -\> `dam`, `birthdate` -\> `birth`).
Setting `reportChanges = TRUE` records exactly what was renamed. The
shipped `pedGood` data set has five columns – four with deliberately
messy headers (`ego_id`, `sire.id`, `dam_id`, `birth_date`) and an
already-canonical `sex` that QC leaves untouched:

``` r

chg <- qcStudbook(pedGood, reportChanges = TRUE, reportErrors = TRUE)
Filter(length, chg$changedCols)
#> $periodRemoved
#> [1] "sire.id to sireid"
#> 
#> $underScoreRemoved
#> [1] "ego_id, dam_id, and birth_date to egoid, damid, and birthdate"
#> 
#> $egoidToId
#> [1] "egoid to id"
#> 
#> $sireIdToSire
#> [1] "sireid to sire"
#> 
#> $damIdToDam
#> [1] "damid to dam"
#> 
#> $birthdateToBirth
#> [1] "birthdate to birth"
```

[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
also standardizes coded values: sex to `M` / `F` / `U` (from `MALE` /
`FEMALE` / `1` / `2` / …; by default the hermaphrodite codes `H` /
`HERMAPHRODITE` / `4` are folded into `U`), status to `ALIVE` /
`DECEASED` / `SHIPPED` / `UNKNOWN`, and ancestry to `INDIAN` / `CHINESE`
/ `HYBRID` / `JAPANESE` / `UNKNOWN` / `OTHER`. Character dates are
parsed to `Date`, and `UNKNOWN` parents become either `NA` or
auto-generated `Unnnn` placeholder IDs.

## Diagnosing problems without stopping

In diagnostic mode (`reportErrors = TRUE`) the function returns a list
whose named elements each hold one category of finding. A **clean**
studbook returns `NULL` – nothing to report:

``` r

is.null(qcStudbook(pedGood, reportErrors = TRUE))
#> [1] TRUE
```

The package ships small, purpose-built data sets that each trigger one
kind of problem; they make good worked examples.

**Sex inconsistency.** In `pedFemaleSireMaleDam`, `s1` is recorded
female but is the sire of two offspring, and `d1` is recorded male but
is used as a dam:

``` r

qcStudbook(pedFemaleSireMaleDam,
  reportErrors = TRUE)[c("femaleSires", "maleDams")]
#> $femaleSires
#> [1] "s1"
#> 
#> $maleDams
#> [1] "d1"
```

**Invalid dates.** `pedInvalidDates` contains `"205-06-19"` (a
three-digit year) and `"2002-16-22"` (month 16); the offending row
numbers are reported:

``` r

qcStudbook(pedInvalidDates, reportErrors = TRUE)$invalidDateRows
#> [1] "3" "4"
```

**Duplicate records.** `pedDuplicateIds` repeats animal `d1` in two
rows:

``` r

qcStudbook(pedDuplicateIds, reportErrors = TRUE)$duplicateIds
#> [1] "d1"
```

**A missing required column.** `pedMissingBirth` has no `birth` column
at all:

``` r

qcStudbook(pedMissingBirth, reportErrors = TRUE)$missingColumns
#> [1] "birth"
```

**An impossible parentage.** In `pedSameMaleIsSireAndDam`, `s1` is
listed as both a sire and a dam:

``` r

qcStudbook(pedSameMaleIsSireAndDam, reportErrors = TRUE)$sireAndDam
#> [1] "s1"
```

Diagnostic mode also reports parents younger than `minParentAge` at an
offspring’s birth (in `suspiciousParents`) and any ID containing a
period (in `invalidIdChars`).

## Production mode vs diagnostic mode

The two modes treat the same problems differently. Production mode fixes
what it can prove is safe and refuses to return a pedigree it cannot
trust; diagnostic mode never stops, so a single pass surfaces every
issue at once.

| Problem | Production mode (`reportErrors = FALSE`) | Diagnostic mode (`reportErrors = TRUE`) |
|----|----|----|
| Messy column names | corrected | `changedCols` (with `reportChanges = TRUE`) |
| Female sire / male dam | **corrected** (sex flipped) | `femaleSires` / `maleDams` |
| Exact duplicate record | **removed** | `duplicateIds` |
| Missing required column | **stops** | `missingColumns` |
| Invalid date | **stops** | `invalidDateRows` |
| Sire is also a dam | **stops** | `sireAndDam` |
| Parent below `minParentAge` | **stops** | `suspiciousParents` |
| Period in an ID | **stops** | `invalidIdChars` |

Production mode silently corrects the safe cases. We can confirm it on
`pedFemaleSireMaleDam` – `s1` becomes male and `d1` female – and on
`pedDuplicateIds`, where the repeated row is dropped:

``` r

qcStudbook(pedFemaleSireMaleDam)[, c("id", "sex")]
#>   id sex
#> 1 d1   F
#> 2 d2   F
#> 3 s1   M
#> 4 s2   M
#> 5 o1   F
#> 6 o2   F
#> 7 o3   F
#> 8 o4   M
nrow(pedDuplicateIds)             # before
#> [1] 9
nrow(qcStudbook(pedDuplicateIds)) # the duplicate row is gone
#> [1] 8
```

Run on data it cannot safely repair, production mode stops with a
message naming the offending rows – here, the invalid dates:

``` r

tryCatch(
  qcStudbook(pedInvalidDates),
  error = function(e) cat(conditionMessage(e))
)
#> Column 'birth' has invalid dates on row(s) 3 and 4.
```

The recommended workflow follows from this: run once in diagnostic mode
to see everything, correct the source studbook, then run in production
mode to get the clean pedigree the analyses consume.

## Key arguments

| Argument | Default | Meaning |
|----|----|----|
| `sb` | – | the studbook data frame to check |
| `minParentAge` | `2.0` | minimum age (years) a parent must be at an offspring’s birth; skipped when birth dates are missing |
| `reportChanges` | `FALSE` | record column-name corrections in `changedCols` |
| `reportErrors` | `FALSE` | diagnostic mode: scan everything and return a list of findings (or `NULL`) instead of a cleaned pedigree |

## See also

- The **Building a Focal-Animal Pedigree Offline** article – build a
  focal pedigree from files with no database; quality-control it here as
  the next step.
- The **Genetic Value Analysis** article – rank a quality-controlled
  pedigree by mean kinship and genome uniqueness with
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md).
- The **Forming Breeding Groups** article – assemble genetically diverse
  breeding groups from a quality-controlled pedigree with
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md).
- The **Age-Sex Pyramid Plots** article – picture the colony’s age and
  sex structure with
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md).
- [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  – the function documented here.
- [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  – the Shiny app, whose Quality Control tab drives this same function
  interactively.

**Reference.**

Vinson A, Raboin MJ (2015). “A Practical Approach for Designing Breeding
Groups to Maximize Genetic Diversity in a Large Colony of Captive Rhesus
Macaques (*Macaca mulatta*).” *Journal of the American Association for
Laboratory Animal Science* 54(6):700-707.
