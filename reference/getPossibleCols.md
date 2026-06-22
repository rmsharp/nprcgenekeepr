# Get possible column names for a studbook

Pedigree curation function

## Usage

``` r
getPossibleCols()
```

## Value

A character vector of the possible columns that can be in a studbook.
The possible columns are as follows:

- id:

  – character vector with unique identifier for an individual

- sire:

  – character vector with unique identifier for an individual's father
  (`NA` if unknown).

- dam:

  – character vector with unique identifier for an individual's mother
  (`NA` if unknown).

- sex:

  – factor (levels: "M", "F", "U") Sex specifier for an individual

- species:

  – character vector or `NA` (optional) naming the species of the
  individual (e.g. "rhesus"). Recognized as a first-class column rather
  than retained as an unrecognized novel column.

- gen:

  – integer vector with the generation number of the individual

- birth:

  – Date or `N` (optional) with the individual's birth date

- exit:

  – Date or `NA` (optional) with the individual's exit date (death, or
  departure if applicable)

- ancestry:

  – character vector or `NA` (optional) that indicates the geographic
  population to which the individual belongs.

- age:

  – numeric or `NA` (optional) indicating the individual's current age
  or age at exit.

- population:

  – an optional logical argument indicating whether or not the `id` is
  part of the extant population.

- origin:

  – character vector or `NA` (optional) that indicates the name of the
  facility that the individual was imported from. `NA` indicates the
  individual was not imported.

- status:

  – an optional factor indicating the status of an individual with
  levels `ALIVE`, `DEAD`, and `SHIPPED`.

- condition:

  – character vector or `NA` (optional) that indicates the restricted
  status of an animal. "Nonrestricted" animals are generally assumed to
  be naive.

- spf:

  – character vector or `NA` (optional) indicating the specific
  pathogen-free status of an individual.

- vasxOvx:

  – character vector indicating the vasectomy/ovariectomy status of an
  animal where `NA` indicates an intact animal and all other values
  indicate surgical alteration.

- pedNum:

  – integer vector indicating generation numbers for each id, starting
  at 0 for individuals lacking IDs for both parents.

## Examples

``` r
library(nprcgenekeepr)
getPossibleCols()
#>  [1] "id"           "sire"         "dam"          "sex"          "species"     
#>  [6] "gen"          "birth"        "exit"         "death"        "age"         
#> [11] "ancestry"     "population"   "origin"       "status"       "condition"   
#> [16] "departure"    "spf"          "vasxOvx"      "pedNum"       "first"       
#> [21] "second"       "first_name"   "second_name"  "recordStatus"
```
