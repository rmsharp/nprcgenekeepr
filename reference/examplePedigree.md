# examplePedigree is a pedigree object created by `qcStudbook`

Represents pedigree from *ExamplePedigree.csv*.

- id:

  – character column of animal IDs

- sire:

  – the male parent of the animal indicated by the `id` column. Unknown
  sires are indicated with `NA`

- dam:

  – the female parent of the animal indicated by the `id` column.Unknown
  dams are indicated with `NA`

- sex:

  – factor with levels: "M", "F", "U". Sex specifier for an individual.

- gen:

  – generation number (integers beginning with 0 for the founder
  generation) of the animal indicated by the `id` column.

- birth:

  – Date vector of birth dates

- exit:

  – Date vector of exit dates

- age:

  – numerical vector of age in years

- ancestry:

  – character vector or NA with free-form text providing information
  about the geographic population of origin.

- origin:

  – character vector or `NA` (optional) that indicates the name of the
  facility that the individual was imported from if other than local.

- status:

  – character vector or NA. Flag indicating an individual's status as
  alive, dead, sold, etc. Transformed to factor {levels: ALIVE,
  DECEASED, SHIPPED, UNKNOWN}. Vector of standardized status codes with
  the possible values ALIVE, DECEASED, SHIPPED, or UNKNOWN

- recordStats:

  – character vector with value of `"added"` or `"original"`.

## Usage

``` r
examplePedigree
```

## Format

An object of class `data.frame` with 3694 rows and 12 columns.

## Examples

``` r
library(nprcgenekeepr)
data("examplePedigree")
exampleTree <- createPedTree(examplePedigree)
exampleLoops <- findLoops(exampleTree)
```
