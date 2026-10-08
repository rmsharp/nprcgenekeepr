# Make a genetic diversity heat map

Renders a red/yellow/green stoplight heat map of breeding-group genetic
diversity metrics. Each row is a breeding group and each column is a
metric; every cell is colored by its color index, where 1 is red (the
problem condition), 2 is yellow (watch), and 3 is green (healthy). A
metric that is undefined for a group (an `NA` index, such as Production
for a group with no breeding-age females) is drawn gray, never as a
verdict.

## Usage

``` r
makeGeneticDiversityHeatmap(stats)
```

## Arguments

- stats:

  A data frame with one row per breeding group. The first column holds
  the group label; every remaining column is a metric whose values are
  color indices in `c(1, 2, 3)` or `NA`.

## Value

A `ggplot` object: a
[`geom_tile`](https://ggplot2.tidyverse.org/reference/geom_tile.html)
heat map with metric headers across the top and group labels down the
left, filled red/yellow/green (gray for `NA`) from the color indices.

## Details

This function is agnostic to the number of metric columns: it draws one
tile per group-by-metric cell for whatever metric columns it is handed,
preserving their input order across the top of the plot. The metric
names are written level, centered over their column and in bold, and the
group names down the left are the same size (22 pt, 2.5 times the 8.8 pt
default), so both stay whole and readable at the size the app draws the
plot.

## Examples

``` r
stats <- data.frame(
  group = c("Group_1", "Group_2"),
  Value = c(1, 3), Origin = c(2, 3),
  Production = c(3, 2), Inbreeding = c(1, 2)
)
p <- makeGeneticDiversityHeatmap(stats)
```
