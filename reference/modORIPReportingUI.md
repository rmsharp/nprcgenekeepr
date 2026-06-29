# ORIP Reporting Module - UI Function

Creates user interface for ORIP (Office of Research Infrastructure
Programs) reporting. This module will contain formatted reports suitable
for submission to ORIP as part of primate center grant reporting
requirements.

## Usage

``` r
modORIPReportingUI(id)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

## Value

A `div` object containing the ORIP reporting UI.

## Details

The ORIP Reporting tab provides summary statistics and formatted reports
for submission to the Office of Research Infrastructure Programs. This
includes:

- Colony demographics summary

- Genetic diversity metrics

- Breeding program statistics

- Founder representation analysis

## See also

[`modORIPReportingServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingServer.md)
for server logic.
