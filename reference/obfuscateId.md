# Create ID aliases of a specified length

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

## See also

Other obfuscation:
[`mapIdsToObfuscated()`](https://github.com/rmsharp/nprcgenekeepr/reference/mapIdsToObfuscated.md),
[`obfuscateDate()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateDate.md),
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md),
[`obfuscateTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md)

## Examples

``` r
library(nprcgenekeepr)
integerIds <- 1L:10L
obfuscateId(integerIds, size = 4L)
#>      1      2      3      4      5      6      7      8      9     10 
#> "QX9S" "RG1Q" "SHIV" "VCBX" "7VUT" "9SYW" "IJ0Q" "G1D5" "WULQ" "SGTC" 
characterIds <- paste0(paste0(sample(LETTERS, 1L, replace = FALSE)), 1L:10L)
obfuscateId(characterIds, size = 4L)
#>     H1     H2     H3     H4     H5     H6     H7     H8     H9    H10 
#> "HJ6Q" "25PC" "L0LX" "44NN" "6X0W" "6KG6" "S5G1" "08UZ" "ND7J" "VD4L" 
```
