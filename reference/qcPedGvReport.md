# Genetic-value report for qcPed

qcPedGvReport is a genetic value report for illustrative purposes only.
It is used in examples and unit tests with the nprcgenekeepr package. It
was created using the following commands.

- set_seed(10)

- qcPedGvReport \<- reportGV(nprcgenekeepr::qcPed, guIter = 10000)

- save(qcPedGvReport, file = "data/qcPedGvReport.RData")

## Usage

``` r
data(qcPedGvReport)
```

## Format

An object of class `list` (inherits from `GVnprcmanag`) of length 8.

## Examples

``` r
qcPedGvReport <- nprcgenekeepr::qcPedGvReport
```
