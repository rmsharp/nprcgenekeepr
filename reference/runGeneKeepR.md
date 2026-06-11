# Run the GeneKeepR Shiny Application (Deprecated)

The original monolithic Shiny application has been retired.
`runGeneKeepR()` is now a soft-deprecated alias that launches the
modular application via
[`runModularApp`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md).
Existing zero-argument callers continue to work.

## Usage

``` r
runGeneKeepR(port = 6013L, launch.browser = TRUE)
```

## Arguments

- port:

  Integer port number for the Shiny server (default 6013).

- launch.browser:

  Logical; whether to launch a browser (default TRUE).

## Value

Returns the error condition of the Shiny application when it terminates
(from
[`runModularApp`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)).

## See also

[`runModularApp`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
for the modular application this now launches.

## Examples

``` r
if (interactive()) {
  library(nprcgenekeepr)
  runGeneKeepR()
}
```
