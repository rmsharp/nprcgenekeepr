# Extract a kValue table from a kinship matrix

A `kValue` matrix has one row for each pair of individuals in the
kinship matrix and one column for each kinship matrix. A `kValue` matrix
has one row for each pair of individuals in the kinship matrix and one
column for each kinship matrix. Thus, in a kinship matrix with 20
individuals the kinship matrix will have 20 rows by 20 columns but only
the upper or lower triangle has unique information as the diagonal
values are each animal's self-kinship, \\(1 + F) / 2\\ (0.5 when not
inbred), and the upper triangle has the same values as the lower
triangle. The `kValue` table will have 210 rows. The calculation for the
number or row in the `kValue` table is \\20 + (20 \* 19) / 2\\ rows with
the 20 values from the kinship coeficient matrix diagonal and \\(20 \*
19) / 2\\ elements from one of either of the two triangles.

## Usage

``` r
kinshipMatrixToKValues(kinshipMatrix)
```

## Arguments

- kinshipMatrix:

  square kinship matrix. May or may not have named rows and columns.

## Value

data.frame object with columns `id_1`, `id_2`, and `kinship` where the
first two columns contain the IDs of the individuals in the kinship
matrix provided to the function and the `kinship` columm contains the
corresponding kinship coefficient. In contrast to the kinship matrix.
Each possible pairing of IDs appears once.

## Details

The `kValue` matrix for 1 kinship matrix for 20 individuals will have
210 rows and 3 columns. The first two columns are dedicated to the ID
pairs and the third column contains the pair's kinship coefficient.

Thus, the number of rows in the kValues matrix will be \\n + n(n-1) /
2\\ and the number of columns will be 3.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::smallPed
simParent_1 <- list(
  id = "A",
  sires = c("s1_1", "s1_2", "s1_3"),
  dams = c("d1_1", "d1_2", "d1_3", "d1_4")
)
simParent_2 <- list(
  id = "B",
  sires = c("s1_1", "s1_2", "s1_3"),
  dams = c("d1_1", "d1_2", "d1_3", "d1_4")
)
simParent_3 <- list(
  id = "E",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_4 <- list(
  id = "J",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_5 <- list(
  id = "K",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_6 <- list(
  id = "N",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
allSimParents <- list(
  simParent_1, simParent_2, simParent_3,
  simParent_4, simParent_5, simParent_6
)

extractKinship <- function(simKinships, id1, id2, simulation) {
  ids <- dimnames(simKinships[[simulation]])[[1]]
  simKinships[[simulation]][
    seq_along(ids)[ids == id1],
    seq_along(ids)[ids == id2]
  ]
}

extractKValue <- function(kValue, id1, id2, simulation) {
  kValue[
    kValue$id_1 == id1 & kValue$id_2 == id2,
    paste0("sim_", simulation)
  ]
}

simPed <- makeSimPed(ped, allSimParents)
simKinship <- kinship(
  simPed$id, simPed$sire,
  simPed$dam, simPed$gen
)
kValues <- kinshipMatrixToKValues(simKinship)
```
