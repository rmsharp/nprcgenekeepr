# Calculate bias-adjusted sample excess kurtosis

Part of the Genetic Value Analysis

## Usage

``` r
calcKurtosis(x, na.rm = TRUE)
```

## Arguments

- x:

  A numeric vector.

- na.rm:

  Logical; remove `NA` values before computing. Default `TRUE`.

## Value

The bias-adjusted sample excess kurtosis, a single number; `NA` when
degenerate (see Details).

## Details

The bias-adjusted Fisher-Pearson standardized EXCESS kurtosis
coefficient, `G2 = ((n + 1) * g2 + 6) * (n - 1) / ((n - 2) * (n - 3))`,
where `g2 = m4 / m2^2 - 3` and `m2`/`m4` are the second/fourth central
sample moments of `x` – the "Method 2" adjustment of Joanes and Gill
(1998), the same convention SPSS, SAS, and Excel report by default and
the `type = 2` option in the `moments`/`e1071` CRAN packages. Excess
(not raw) kurtosis: a normal distribution reads `0`. Positive values
indicate heavier tails / a sharper peak than normal; negative, lighter
tails / a flatter peak.

Returns `NA` when `x` has fewer than 4 non-`NA` values (`n <= 3`, the
adjustment term divides by `(n - 2) * (n - 3)`) or has zero variance
(all remaining values identical) – both would otherwise divide by zero.

## References

Joanes, D.N. and Gill, C.A. (1998) "Comparing measures of sample
skewness and kurtosis." *Journal of the Royal Statistical Society:
Series D (The Statistician)*, 47(1), 183-189.

## See also

[`calcSkewness`](https://github.com/rmsharp/nprcgenekeepr/reference/calcSkewness.md)

Other genetic value analysis:
[`calcA()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md),
[`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
[`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
[`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
[`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md),
[`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
[`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md),
[`calcGeneDiversity()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGeneDiversity.md),
[`calcNeSexRatio()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md),
[`calcNeVariance()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeVariance.md),
[`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md),
[`calcSkewness()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcSkewness.md)

## Examples

``` r
calcKurtosis(c(1, 2, 3, 4, 100)) # 4.986866, heavy-tailed
#> [1] 4.986866
calcKurtosis(c(1, 2, 3, 4, 5)) # -1.2, flatter than normal
#> [1] -1.2
```
