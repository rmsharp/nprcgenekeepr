# Gene drop simulation based on the provided pedigree information

Part of Genetic Value Analysis

## Usage

``` r
geneDrop(
  ids,
  sires,
  dams,
  gen,
  genotype = NULL,
  n = 5000L,
  updateProgress = NULL
)
```

## Arguments

- ids:

  A character vector of unique IDs for a set of animals.

- sires:

  A character vector with IDS of the sires for the set of animals. `NA`
  is used for missing sires.

- dams:

  A character vector with IDS of the dams for the set of animals. `NA`
  is used for missing dams.

- gen:

  An integer vector indicating the generation number for each animal.

- genotype:

  A dataframe containing known genotypes. It has three columns: `id`,
  `first`, and `second`. The second and third columns contain the
  integers indicating the observed genotypes.

- n:

  integer indicating the number of iterations to simulate. Default is
  5000.

- updateProgress:

  function or NULL. If this function is defined, it will be called
  during each iteration to update a
  [`shiny::Progress`](https://rdrr.io/pkg/shiny/man/Progress.html)
  object.

## Value

A data.frame `id, parent, V1 ... Vn` A data.frame providing the maternal
and paternal alleles for an animal for each iteration. The first two
columns provide the animal's ID and whether the allele came from the
sire or dam. These are followed by `n` columns indicating the allele for
that iteration.

## Details

The gene dropping method from *Pedigree analysis by computer simulation*
by Jean W MacCluer, John L Vandeberg, and Oliver A Ryder (1986)
<doi:10.1002/zoo.1430050209> is used in the genetic value calculations.

Currently there is no means of handling knowing only one haplotype. It
will be easy to add another column to handle situations where only one
allele is observed and it is not known to be homozygous or heterozygous.
The new fourth column could have a frequency for homozygosity that could
be used in the gene dropping algorithm.

The genotypes are using indirection (integer instead of character) to
indicate the genes because the manipulation of character strings was
found to take 20-35 times longer to perform.

Adding additional columns to `genotype` does not significantly affect
the time require. Thus, it is convenient to add the corresponding
haplotype names to the dataframe using `first_name` and `second_name`.

Animal IDs (`ids`) must not contain a period ("."). A period is
disallowed because it causes problems across software environments (R
column-name and formula parsing, file-name extensions,
programming-language namespaces, and regular expressions); `geneDrop`
additionally relies on the period internally to recover the id and
parent of each allele row, so a period-bearing id would silently corrupt
the result. IDs containing a period are therefore rejected with an
error. The same rule is enforced at data input by
[`qcStudbook`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
and honored by all automatically generated IDs.

Animal IDs (`ids`) must also be unique. `geneDrop` indexes each animal's
parents and accumulates its simulated alleles by id, so duplicate ids
are rejected with an error. This invariant is established upstream by
[`qcStudbook`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
(via
[`removeDuplicates`](https://github.com/rmsharp/nprcgenekeepr/reference/removeDuplicates.md))
and by
[`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md),
both of which require unique ids.

## Examples

``` r
## We usually defined `n` to be >= 5000
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
allelesNew <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
  genotype = NULL, n = 50, updateProgress = NULL
)
genotype <- data.frame(
  id = ped$id,
  first_allele = c(
    NA, NA, "A001_B001", "A001_B002",
    NA, "A001_B002", "A001_B001"
  ),
  second_allele = c(
    NA, NA, "A010_B001", "A001_B001",
    NA, NA, NA
  ),
  stringsAsFactors = FALSE
)
pedWithGenotype <- addGenotype(ped, genotype)
pedGenotype <- getGVGenotype(pedWithGenotype)
allelesNewGen <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
  genotype = pedGenotype,
  n = 5, updateProgress = NULL
)
```
