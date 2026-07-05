# Run the Modular Version of GeneKeepR (Deprecated)

`runModularApp()` has been renamed to
[`runGeneKeepR`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md),
a name that says what the function does. `runModularApp()` is now a
soft-deprecated alias that launches the application via
[`runGeneKeepR`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md).
Existing callers continue to work.

## Usage

``` r
runModularApp(port = 6013L, launch.browser = TRUE)
```

## Arguments

- port:

  Integer port number for the Shiny server (default 6013)

- launch.browser:

  Logical; whether to launch browser (default TRUE)

## Value

Returns the error condition of the Shiny application when it terminates
(from
[`runGeneKeepR`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)).

## See also

[`runGeneKeepR`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md),
the function this now launches.

## Examples

``` r
if (FALSE) { # \dontrun{
library(nprcgenekeepr)
runModularApp()
} # }
```
