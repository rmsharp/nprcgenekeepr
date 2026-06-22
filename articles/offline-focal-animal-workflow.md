# Building a Focal-Animal Pedigree Offline

## Overview

Often you do not want a whole colony pedigree – you want the pedigree of
a short list of **focal animals**: a few breeders, the candidates for a
study, or the residents of a proposed group, together with everyone they
are genetically linked to. `nprcgenekeepr` builds that focal pedigree
two ways:

- **online** –
  [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
  reads the focal IDs from a file and pulls the surrounding pedigree
  from a LabKey / EHR database;
- **offline** –
  [`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
  does the same thing from a **second file** you supply, so the workflow
  needs **no database connection** at all.

This article covers the offline path. Use it when you have a
focal-animal ID list and a pedigree file on disk and either no LabKey
access or no need for it – on a laptop, behind a firewall, or with a
studbook exported from another system. The two functions are siblings by
design:
[`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
reads the focal IDs exactly as
[`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
does, then builds the same connected pedigree component from your file
instead of from the database.

The Shiny app
([`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md))
drives this same offline path from its Input tab (see the *In the Shiny
app* section below); here we script it directly.

## Setup

``` r

library(nprcgenekeepr)
```

[`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
runs no random simulation – it is deterministic – so, unlike the
genetic-value and breeding-group analyses, this article needs no
[`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
call to be reproducible.

## The two inputs

The offline workflow takes two separate files:

- a **focal-animal ID file** (`fileName`) – a CSV, delimited text, or
  Excel file whose **first column** is the list of focal animal IDs. The
  column may have any header; only the first column is read. Any other
  columns are ignored.
- a **pedigree file** (`pedigreeFileName`) – a CSV, delimited text, or
  Excel file that must contain at least the columns `id`, `sire`, and
  `dam`. Any additional columns (`sex`, `birth`, `exit`, …) are carried
  through to the result unchanged.

Both files are read with a header row. The `sep` argument sets the field
separator for delimited text (default `","`); it is ignored for Excel
files, which are detected automatically.

## A self-contained example

The clearest way to see the workflow is to build both files inline. Here
is a four-animal pedigree – two founders (`A`, `B`) and their two
offspring (`C`, `D`) – written to a temporary CSV, with a one-line focal
file naming a single focal animal, `C`:

``` r

ped <- data.frame(
  id   = c("A", "B", "C", "D"),
  sire = c(NA, NA, "A", "A"),
  dam  = c(NA, NA, "B", "B"),
  stringsAsFactors = FALSE
)
pedFile <- tempfile(fileext = ".csv")
write.csv(ped, pedFile, row.names = FALSE)

focalFile <- tempfile(fileext = ".csv")
write.csv(data.frame(id = "C"), focalFile, row.names = FALSE)
```

``` r

getFocalAnimalPedFromFile(focalFile, pedFile)
#>   id sire  dam
#> 1  A <NA> <NA>
#> 2  B <NA> <NA>
#> 3  C    A    B
#> 4  D    A    B
```

Although we asked only for `C`, the result has four rows. The function
returns `C`’s **full connected pedigree component**: its parents `A` and
`B` (ancestors), and its full sibling `D` – a **collateral** relative
pulled in because it shares both parents. Building the connected
component, not just the direct ancestors, is what makes the result
usable for kinship and breeding-group work, where an animal’s relatives
matter as much as its ancestry.

## Using the bundled colony data

The package ships a realistic pair you can use the same way: a five-ID
focal list and the example colony pedigree it resolves into. Reference
them with [`system.file()`](https://rdrr.io/r/base/system.file.html),
which returns the path inside the installed package.

``` r

focalListFile <- system.file("extdata", "focalAnimalsShortList.csv",
  package = "nprcgenekeepr")
pedigreeFile <- system.file("extdata", "ExamplePedigree.csv",
  package = "nprcgenekeepr")

colonyPed <- getFocalAnimalPedFromFile(focalListFile, pedigreeFile)
dim(colonyPed)
#> [1] 2922   11
names(colonyPed)
#>  [1] "id"       "sire"     "dam"      "sex"      "gen"      "birth"   
#>  [7] "exit"     "age"      "ancestry" "origin"   "status"
```

Five focal animals expand to a connected component of several thousand –
a reminder that in a real colony a handful of animals can be linked,
through shared ancestors and descendants, to a large fraction of the
studbook. The returned columns are exactly those of the pedigree file
(here `id`, `sire`, `dam`, `sex`, `gen`, `birth`, `exit`, `age`,
`ancestry`, `origin`, `status`).

``` r

head(colonyPed[, c("id", "sire", "dam", "sex")])
#>        id sire  dam sex
#> 2  VJ08BW <NA> <NA>   F
#> 22 SUFWJI <NA> <NA>   F
#> 23 9747LE <NA> <NA>   F
#> 32 RMJKJ4 <NA> <NA>   F
#> 40 WTE53B <NA> <NA>   F
#> 42 HHFN1E <NA> <NA>   F
all(read.csv(focalListFile)[[1]] %in% colonyPed$id) # the focal IDs are included
#> [1] TRUE
```

The result is returned in pedigree-file order, so
[`head()`](https://rdrr.io/r/utils/head.html) shows founder records (no
known `sire` or `dam`); the focal animals themselves sit deeper in the
table. A quality-control pass with
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
– see the *Studbook Quality Control* article – is the usual next step
before any analysis.

## When a file cannot be read

[`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
is the application boundary, so it is **fail-soft**: it never throws. On
any failure it returns a classed `nprcgenekeeprFileErr` object – a list
with a `message` element naming why the read failed – which you test for
with [`inherits()`](https://rdrr.io/r/base/class.html):

``` r

result <- getFocalAnimalPedFromFile(focalListFile, tempfile(fileext = ".csv"))
inherits(result, "nprcgenekeeprFileErr")
#> [1] TRUE
result$message
#> [1] "Pedigree file not found."
```

``` r

strangers <- tempfile(fileext = ".csv")
write.csv(data.frame(id = "NOSUCHID"), strangers, row.names = FALSE)
getFocalAnimalPedFromFile(strangers, pedigreeFile)$message
#> [1] "None of the focal IDs were found in the pedigree file."
```

The full set of reasons:

| `message` | Cause |
|----|----|
| `The focal animal ID list file could not be read.` | the focal-id file is missing or unreadable |
| `A pedigree file must be supplied to build the focal pedigree offline.` | `pedigreeFileName` was omitted (`NULL`) |
| `Pedigree file not found.` | the pedigree file path does not exist |
| `The pedigree file must contain columns id, sire, and dam.` | the pedigree file is missing a required column |
| `The pedigree file could not be read.` | any other pedigree read failure |
| `None of the focal IDs were found in the pedigree file.` | the files read, but no focal ID matched any pedigree `id` |

This fail-soft contract is specific to the offline file path. The online
[`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
instead returns an `nprcgenekeeprErr` on a database failure, so code
that handles both paths should check for each class. In the Shiny app,
an `nprcgenekeeprFileErr` surfaces as a **File Read Error** row on the
Errors tab, with its `message` as the detail.

## In the Shiny app

To do the same thing interactively, launch
[`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
and, on the **Input** tab:

1.  under **File Content**, choose *“Focal animals only; pedigree built
    from database”*;
2.  upload your focal-animal ID file under **Select Focal Animals
    File**;
3.  upload your pedigree file under **Optional: Pedigree File (build
    offline; no database)** – supplying this second file is what runs
    the workflow offline (leave it empty and the app falls back to the
    LabKey/database path);
4.  click **Read and Check Pedigree**.

The app then calls
[`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
for you and routes any `nprcgenekeeprFileErr` to the Errors tab.

## Key arguments

| Argument | Default | Meaning |
|----|----|----|
| `fileName` | – | path to the focal-animal ID file (CSV, delimited text, or Excel); the first column holds the IDs |
| `pedigreeFileName` | `NULL` | path to the pedigree file; must contain at least `id`, `sire`, and `dam` columns |
| `sep` | `","` | field separator for delimited text files; ignored for Excel |

## See also

- The **Studbook Quality Control** article –
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  validates and standardizes a pedigree, the usual next step once you
  have a focal pedigree.
- The **Genetic Value Analysis** article – rank a quality-controlled
  pedigree by mean kinship and genome uniqueness with
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md).
- The **Forming Breeding Groups** article – assemble genetically diverse
  breeding groups with
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md).
- The **Age-Sex Pyramid Plots** article – picture the colony’s age and
  sex structure with
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md).
- [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
  – the online sibling that pulls the surrounding pedigree from a LabKey
  / EHR database instead of a file.
- [`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md)
  – the lower-level function that walks the pedigree file to build the
  connected component (and exposes the `unrelatedParents` option, which
  [`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
  leaves at its default).
- [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  – the Shiny app, whose Input tab drives this same offline workflow
  interactively.

**Reference.**

Vinson A, Raboin MJ (2015). “A Practical Approach for Designing Breeding
Groups to Maximize Genetic Diversity in a Large Colony of Captive Rhesus
Macaques (*Macaca mulatta*).” *Journal of the American Association for
Laboratory Animal Science* 54(6):700-707.
