# obfuscateId creates a vector of ID aliases of specified length

ID aliases are pseudorandom sequences of alphanumeric upper case
characters where the letter "O" is not included for readability.. User
has the option of providing a character vector of aliases to avoid
using. Because aliases are alphanumeric, they never contain a period
("."), honoring the ID rule enforced at data input by `qcStudbook`.

## Usage

``` r
obfuscateId(id, size = 10L, existingIds = character(0L))
```

## Arguments

- id:

  character vector of IDs to be obfuscated (alias creation).

- size:

  character length of each alias

- existingIds:

  character vector of existing aliases to avoid duplication.

## Value

A named character vector of aliases where the name is the original ID
value.

## Examples

``` r
library(nprcgenekeepr)
integerIds <- 1L:10L
obfuscateId(integerIds, size = 4L)
#>      1      2      3      4      5      6      7      8      9     10 
#> "T9SY" "WIJ0" "QG1D" "5WUL" "QSGT" "CJHJ" "6Q25" "PCL0" "LX44" "NN6X" 
characterIds <- paste0(paste0(sample(LETTERS, 1L, replace = FALSE)), 1L:10L)
obfuscateId(characterIds, size = 4L)
#>     T1     T2     T3     T4     T5     T6     T7     T8     T9    T10 
#> "W6KG" "6S5G" "108U" "ZND7" "JVD4" "L2JH" "TJGT" "8D18" "3KX8" "8LJF" 
```
