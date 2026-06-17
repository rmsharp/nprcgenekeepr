# Set the auto-generated unknown-ID format

Sets the `sprintf` template used to mint and detect placeholder IDs for
unknown parents (see
[`addUIds`](https://github.com/rmsharp/nprcgenekeepr/reference/addUIds.md)).
The format must have a non-empty literal prefix before its first `"%"`
(used for detection) and must consume a single integer (used for
generation), e.g. `"U%04d"` or `"AUTO%05d"`. The setting is stored in
`options(nprcgenekeepr.autoIdFormat=)` and read by
[`getAutoIdFormat`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md).

## Usage

``` r
setAutoIdFormat(format)
```

## Arguments

- format:

  A single character string: the auto-ID `sprintf` format.

## Value

The previous format, returned invisibly.

## See also

[`getAutoIdFormat`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md),
[`addUIds`](https://github.com/rmsharp/nprcgenekeepr/reference/addUIds.md)

## Examples

``` r
old <- setAutoIdFormat("AUTO%05d")
getAutoIdFormat()
#> [1] "AUTO%05d"
setAutoIdFormat(old) # restore
```
