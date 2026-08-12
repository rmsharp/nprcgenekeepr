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
[`obfuscateGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenomicROH.md),
[`obfuscateGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md),
[`obfuscateLdBlocks()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md),
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md),
[`obfuscateTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md)

## Examples

``` r
library(nprcgenekeepr)
integerIds <- 1L:10L
obfuscateId(integerIds, size = 4L)
#>      1      2      3      4      5      6      7      8      9     10 
#> "D5WU" "LQSG" "TCJH" "J6Q2" "5PCL" "0LX4" "4NN6" "X0W6" "KG6S" "5G10" 
characterIds <- paste0(paste0(sample(LETTERS, 1L, replace = FALSE)), 1L:10L)
obfuscateId(characterIds, size = 4L)
#>     Y1     Y2     Y3     Y4     Y5     Y6     Y7     Y8     Y9    Y10 
#> "7JVD" "4L2J" "HTJG" "TUEI" "08D1" "83KX" "88LJ" "FLS7" "SJBP" "4MEN" 
```
