# Deprecated alias for makeGroupNum

`makeGrpNum` has been renamed to
[`makeGroupNum`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGroupNum.md)
for consistency with
[`makeGroupMembers`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGroupMembers.md).
It remains as a deprecated wrapper that issues a warning and then calls
`makeGroupNum`.

## Usage

``` r
makeGrpNum(numGp)
```

## Arguments

- numGp:

  integer value indicating the number of groups that should be formed
  from the list of IDs. Default is 1.

## Value

Initial grpNum list

## See also

[`makeGroupNum`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGroupNum.md)
