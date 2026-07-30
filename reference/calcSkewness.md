# Calculate bias-adjusted sample skewness

Part of the Genetic Value Analysis

## Usage

``` r
calcSkewness(x, na.rm = TRUE)
```

## Arguments

- x:

  A numeric vector.

- na.rm:

  Logical; remove `NA` values before computing. Default `TRUE`.

## Value

The bias-adjusted sample skewness, a single number; `NA` when degenerate
(see Details).

## Details

The bias-adjusted Fisher-Pearson standardized skewness coefficient,
`G1 = g1 * sqrt(n * (n - 1)) / (n - 2)`, where `g1 = m3 / m2^1.5` and
`m2`/`m3` are the second/third central sample moments of `x` – the
"Method 2" adjustment of Joanes and Gill (1998), the same convention
SPSS, SAS, and Excel report by default and the `type = 2` option in the
`moments`/`e1071` CRAN packages. A positive value indicates a longer
right tail; negative, a longer left tail; `0`, a symmetric distribution.

Returns `NA` when `x` has fewer than 3 non-`NA` values (`n <= 2`, the
adjustment term divides by `n - 2`) or has zero variance (all remaining
values identical) – both would otherwise divide by zero.

## References

Joanes, D.N. and Gill, C.A. (1998) "Comparing measures of sample
skewness and kurtosis." *Journal of the Royal Statistical Society:
Series D (The Statistician)*, 47(1), 183-189.

## See also

[`calcKurtosis`](https://github.com/rmsharp/nprcgenekeepr/reference/calcKurtosis.md)

Other genetic value analysis:
[`calcA()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md),
[`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
[`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
[`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
[`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md),
[`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
[`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md),
[`calcGeneDiversity()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGeneDiversity.md),
[`calcKurtosis()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcKurtosis.md),
[`calcNeSexRatio()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md),
[`calcNeVariance()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeVariance.md),
[`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md)

## Examples

``` r
calcSkewness(c(1, 2, 3, 4, 100)) # 2.232396, a long right tail
#> [1] 2.232396
calcSkewness(c(1, 2, 3, 4, 5)) # 0, symmetric
#> [1] 0
```
