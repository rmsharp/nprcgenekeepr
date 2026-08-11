# De-Identified Export Module - Server Function

De-Identified Export Module - Server Function

## Usage

``` r
modDeidentifiedExportServer(id, pedigree)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- pedigree:

  reactive returning the current pedigree data.frame
  (`shared$currentPedigree`, D1) – not a fresh upload, unlike
  [`modCrossCenterIdentityServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modCrossCenterIdentityServer.md).

## Value

A list with reactive components:

- `exportedPedigree` - the most recent
  [`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
  output

- `map` - the corresponding id alias map (`obfuscatePed`'s `map=TRUE`
  return)

- `manifest` - the D4 transformation manifest, built from the EXACT
  parameters that produced `exportedPedigree` (captured at preview time,
  not re-read from live input state – a curator who tweaks the
  configuration after previewing but before exporting must not get a
  manifest describing different parameters than what was actually
  exported)

- `confirmed` - logical: has the modal confirm gate been accepted for
  the current preview. Resets to `FALSE` whenever the preview is
  regenerated (mirrors
  [`modCrossCenterIdentityServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modCrossCenterIdentityServer.md)'s
  own D5 stale-confirmation -reset pattern), so a stale confirmation can
  never silently unlock exports for changed output.

Downloads are not hard-gated on `confirmed` (mirroring
`modCrossCenterIdentityServer`'s own precedent exactly) – per this
issue's own ratified framing, "curator-controlled" means a confirmation
dialog and warning text, not real access control (sec 1.2).

## See also

[`modDeidentifiedExportUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modDeidentifiedExportUI.md)
for the user interface.

[`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
for the underlying de-identification.

Other Shiny modules:
[`modBreedingGroupsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md),
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md),
[`modCrossCenterIdentityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modCrossCenterIdentityServer.md),
[`modCrossCenterIdentityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modCrossCenterIdentityUI.md),
[`modDeidentifiedExportUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modDeidentifiedExportUI.md),
[`modGeneticDiversityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityServer.md),
[`modGeneticDiversityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityUI.md),
[`modGeneticValueServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md),
[`modGeneticValueUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md),
[`modGvAndBgDescServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescServer.md),
[`modGvAndBgDescUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescUI.md),
[`modInputServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputServer.md),
[`modInputUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md),
[`modMarkerGeneticsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsServer.md),
[`modMarkerGeneticsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsUI.md),
[`modMatePairServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMatePairServer.md),
[`modMatePairUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMatePairUI.md),
[`modORIPReportingServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingServer.md),
[`modORIPReportingUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingUI.md),
[`modPedigreeServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md),
[`modPedigreeUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeUI.md),
[`modPotentialParentsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsServer.md),
[`modPotentialParentsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md),
[`modPyramidServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidServer.md),
[`modPyramidUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidUI.md),
[`modSummaryStatsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsServer.md),
[`modSummaryStatsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsUI.md)
