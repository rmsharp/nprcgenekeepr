# Get the auto-generated unknown-ID format

Returns the `sprintf` template used to mint placeholder IDs for unknown
parents (see
[`addUIds`](https://github.com/rmsharp/nprcgenekeepr/reference/addUIds.md))
and to detect them. The format is the single source of truth shared by
ID *generation* and ID *detection*.

## Usage

``` r
getAutoIdFormat()
```

## Value

A single character string: the auto-ID `sprintf` format.

## Details

The value is read from `getOption("nprcgenekeepr.autoIdFormat")`,
defaulting to `"U%04d"` (a leading `"U"` plus a zero-padded integer) for
backward compatibility. Set it with
[`setAutoIdFormat`](https://github.com/rmsharp/nprcgenekeepr/reference/setAutoIdFormat.md).

## See also

[`setAutoIdFormat`](https://github.com/rmsharp/nprcgenekeepr/reference/setAutoIdFormat.md),
[`addUIds`](https://github.com/rmsharp/nprcgenekeepr/reference/addUIds.md)

## Examples

``` r
getAutoIdFormat()
#> [1] "U%04d"
```
