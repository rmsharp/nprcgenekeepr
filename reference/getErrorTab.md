# Build the error-list tab panel

Build the error-list tab panel

## Usage

``` r
getErrorTab(errorLst, pedigreeFileName)
```

## Arguments

- errorLst:

  list of errors and changes made by `qcStudbook`

- pedigreeFileName:

  name of file provided by user on Input tab

## Value

A Shiny `tabPanel` titled "Error List" that holds the HTML-formatted
list of errors found by `qcStudbook`.
