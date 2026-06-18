# Hypothetical 17-animal pedigree

A hypothetical pedigree. It has the following structure:
structure(list(id = c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
"K", "L", "M", "N", "O", "P", "Q"), sire = c("Q", NA, "A", "A", NA, "D",
"D", "A", "A", NA, NA, "C", "A", NA, NA, "M", NA), dam = c(NA, NA, "B",
"B", NA, "E", "E", "B", "J", NA, NA, "K", "N", NA, NA, "O", NA), sex =
c("M", "F", "M", "M", "F", "F", "F", "M", "F", "F", "F", "F", "M", "F",
"F", "F", "M"), gen = c(1, 1, 2, 2, 1, 3, 3, 2, 2, 1, 1, 2, 1, 1, 2, 3,
0), population = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE)), .Names = c("id",
"sire", "dam", "sex", "gen", "population"), row.names = c(NA, -17L),
class = "data.frame")

## Usage

``` r
data(smallPed)
```

## Format

An object of class `data.frame` with 17 rows and 6 columns.
