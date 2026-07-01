# Add ego records with NA parent IDs

Add ego records with NA parent IDs

## Usage

``` r
addIdRecords(ids, fullPed, partialPed)
```

## Arguments

- ids:

  character vector of IDs to be added as Ego records having NAs for
  parent IDs

- fullPed:

  a trimmed pedigree

- partialPed:

  a trimmed pedigree dataframe with uninformative founders removed.

## Value

Pedigree with Ego records added having NAs for parent IDs

## Examples

``` r
uPedOne <- data.frame(
  id = c("d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c("s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c("d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("F", "M", "F", "F", "F", "F", "M"),
  stringsAsFactors = FALSE
)
pedOne <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
  stringsAsFactors = FALSE
)
pedOne[!pedOne$id %in% uPedOne$id, ]
#>   id sire  dam sex
#> 1 s1 <NA> <NA>   M
newPed <- addIdRecords(ids = "s1", pedOne, uPedOne)
pedOne[!pedOne$id %in% newPed$id, ]
#> [1] id   sire dam  sex 
#> <0 rows> (or 0-length row.names)
newPed[newPed$id == "s1", ]
#>        id   sire    dam    sex
#>    <char> <char> <char> <char>
#> 1:     s1   <NA>   <NA>      M
```
