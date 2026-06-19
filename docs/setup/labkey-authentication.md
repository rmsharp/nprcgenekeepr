# Configuring LabKey authentication for nprcgenekeepr

*As of 2026-06-19. Applies to nprcgenekeepr's `Rlabkey`-based LabKey EHR
integration (`getDemographics()` and the pedigree pulls that use it).*

nprcgenekeepr reads pedigree/demographic data from a LabKey EHR server through
the `Rlabkey` package. Every such call must authenticate. `setLabKeyDefaults()`
configures that authentication for the current R session, and
`getDemographics()` calls it automatically before its first query, so a missing
credential now fails fast with a clear message instead of an opaque `Rlabkey`
error later.

## Credential precedence

`setLabKeyDefaults()` looks for a credential in this order and uses the first it
finds:

1. **API key from the environment variable `NPRCGENEKEEPR_LABKEY_APIKEY`.**
2. **API key from the `apiKey` token** in your nprcgenekeepr configuration file
   (`~/.nprcgenekeepr_config`, or `~/_nprcgenekeepr_config` on Windows).
3. **A netrc file** — the file named by the `NETRC` environment variable if
   set, otherwise `~/.netrc` (`~/_netrc` on Windows).

If none of these is found, `setLabKeyDefaults()` stops with an actionable error
telling you how to set one.

When an API key is found (cases 1 or 2) it is passed to
`Rlabkey::labkey.setDefaults(apiKey = , baseUrl = )` with the `baseUrl` from
`getSiteInfo()`. When only a netrc file is found (case 3), `Rlabkey` is left to
use it directly.

## Option A — API key (recommended)

LabKey's recommended mechanism for scripts and client libraries is an API key.

1. Have a LabKey **site administrator enable API keys** (Admin Console → Site
   Settings → Configure API Keys → "Let users create API Keys"). They are not
   enabled by default.
2. In LabKey, create an API key for your account (it is shown once — copy it).
3. Provide it to nprcgenekeepr by **either**:

   - Environment variable (keeps the secret out of files; works in CI):

     ```sh
     export NPRCGENEKEEPR_LABKEY_APIKEY="paste-your-key-here"
     ```

     or, from within R for the current session only:

     ```r
     Sys.setenv(NPRCGENEKEEPR_LABKEY_APIKEY = "paste-your-key-here")
     ```

   - **or** the `apiKey` token in your configuration file:

     ```
     apiKey = "paste-your-key-here"
     ```

The environment variable takes precedence over the configuration-file token
when both are set. Keep API keys out of shared or version-controlled files.

## Option B — netrc file

If you do not supply an API key, nprcgenekeepr falls back to a netrc file.
Create `~/.netrc` (or `~/_netrc` on Windows), readable only by you
(permissions `600`), with a line of the form:

```
machine YOUR.LABKEY.HOST login apikey password YOUR_API_KEY
```

See the LabKey netrc documentation:
<https://www.labkey.org/Documentation/wiki-page.view?name=netrc>

## Verifying

```r
library(nprcgenekeepr)
## Returns invisibly a list(method = "apiKey" | "netrc", baseUrl = ...),
## or stops with "No LabKey credential found." when nothing is configured.
result <- setLabKeyDefaults(getSiteInfo(expectConfigFile = FALSE))
```

## Notes

- Compliance/PHI environments may require LabKey **session keys** rather than a
  static API key. Confirm your center's policy before relying on an unattended
  netrc API key.
- The API key is never read from or written to the package sources; it lives
  only in your environment, configuration file, or netrc file.
