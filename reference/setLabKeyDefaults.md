# Configure Rlabkey authentication for the current session

Sets up the credentials that
[`getDemographics`](https://github.com/rmsharp/nprcgenekeepr/reference/getDemographics.md)
(and any other `Rlabkey` call) uses to authenticate against the LabKey
EHR server. An API key, when available, is preferred; otherwise the
function falls back to a `.netrc`/`_netrc` file; when neither is present
it stops with an actionable error rather than letting `Rlabkey` fail
later with an opaque message.

## Usage

``` r
setLabKeyDefaults(siteInfo = getSiteInfo())
```

## Arguments

- siteInfo:

  list of site information as returned by
  [`getSiteInfo`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md).
  The elements used are `baseUrl`, `configFile`, `homeDir`, and
  `sysname`.

## Value

Invisibly, a list with elements `method` (one of `"apiKey"` or
`"netrc"`) and `baseUrl`. Stops with an error when no credential can be
found.

## Details

The API key is sourced, in order of precedence, from

1.  the environment variable `NPRCGENEKEEPR_LABKEY_APIKEY`, then

2.  an `apiKey` entry in the nprcgenekeepr configuration file.

When an API key is found,
[`labkey.setDefaults`](https://rdrr.io/pkg/Rlabkey/man/labkey.setDefaults.html)
is called with that key and `siteInfo$baseUrl`. When no API key is
found, the function checks for a netrc file (the `NETRC` environment
variable, then the home-directory `.netrc` on non-Windows or `_netrc` on
Windows) and, if present, leaves `Rlabkey` to use it. The API key is
never read from or written to the package sources; keep it in the
environment, the configuration file, or the netrc file only.

## Examples

``` r
if (FALSE) { # \dontrun{
## Requires an apiKey (env var or config) or a .netrc file to succeed.
library(nprcgenekeepr)
result <- tryCatch(
  setLabKeyDefaults(getSiteInfo(expectConfigFile = FALSE)),
  error = function(e) conditionMessage(e)
)
} # }
```
