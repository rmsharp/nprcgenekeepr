# Build the changed-columns tab panel

Build the changed-columns tab panel

## Usage

``` r
getChangedColsTab(errorLst, pedigreeFileName)
```

## Arguments

- errorLst:

  list of errors and changes made by `qcStudbook`

- pedigreeFileName:

  name of file provided by user on Input tab

## Value

A Shiny `tabPanel` titled "Changed Columns" that holds the
HTML-formatted list of column changes made by `qcStudbook`.
