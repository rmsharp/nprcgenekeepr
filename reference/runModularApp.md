# Run the Modular Version of GeneKeepR (Deprecated)

`runModularApp()` has been renamed to
[`runGeneKeepR`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md),
a name that says what the function does. `runModularApp()` is now a
soft-deprecated alias that launches the application via
[`runGeneKeepR`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md),
passing all arguments through. Existing callers continue to work. Called
directly, it emits a lifecycle message ("was deprecated in nprcgenekeepr
2.0.0"); soft deprecation is silent for calls made from inside another
package.

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

Called for its side effect; blocks until the app is stopped. Returns,
invisibly, the value passed to
[`shiny::stopApp()`](https://rdrr.io/pkg/shiny/man/stopApp.html)
(normally `NULL`), as
[`runGeneKeepR`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
does.

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
