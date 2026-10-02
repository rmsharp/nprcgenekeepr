# Create an Excel workbook with worksheets

Create an Excel workbook with worksheets

## Usage

``` r
create_wkbk(file, df_list, sheetnames, replace = FALSE)
```

## Arguments

- file:

  filename of workbook to be created

- df_list:

  list of data frames to be added as worksheets to workbook

- sheetnames:

  character vector of worksheet names

- replace:

  Specifies if the file should be replaced if it already exist (default
  is FALSE).

## Value

`TRUE` if the Excel file was successfully created. `FALSE`, with a
warning, if the file already exists and `replace` is `FALSE`. Other
problems are signaled as errors rather than returned as `FALSE`;
examples are a number of `sheetnames` that differs from the length of
`df_list` and an invalid worksheet name.

## Examples

``` r
library(nprcgenekeepr)

make_df_list <- function(size) {
  df_list <- list(size)
  if (size <= 0) {
    return(df_list)
  }
  for (i in seq_len(size)) {
    n <- sample(2:10, 2, replace = TRUE)
    df <- data.frame(matrix(data = rnorm(n[1] * n[2]), ncol = n[1]))
    df_list[[i]] <- df
  }
  names(df_list) <- paste0("A", seq_len(size))
  df_list
}
df_list <- make_df_list(3)
sheetnames <- names(df_list)
wkbkFile <- file.path(tempdir(), "example_excel_wkbk.xlsx")
create_wkbk(
  file = wkbkFile,
  df_list = df_list,
  sheetnames = sheetnames,
  replace = FALSE
)
#> [1] TRUE
if (file.exists(wkbkFile)) {
  file.remove(wkbkFile)
}
#> [1] TRUE
```
