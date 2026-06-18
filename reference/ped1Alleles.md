# Gene-drop alleles example (baboon pedigree)

A dataframe created by the `geneDrop` function.

## Usage

``` r
data(ped1Alleles)
```

## Format

A dataframe with 554 rows and 6 variables

- V1:

  alleles assigned to the parents of the animals identified in the `id`
  column during iteration 1 of gene dropping performed by `geneDrop`.

- V2:

  alleles assigned to the parents of the animals identified in the `id`
  column during iteration 1 of gene dropping performed by `geneDrop`.

- V3:

  alleles assigned to the parents of the animals identified in the `id`
  column during iteration 1 of gene dropping performed by `geneDrop`.

- V4:

  alleles assigned to the parents of the animals identified in the `id`
  column during iteration 1 of gene dropping performed by `geneDrop`.

- id:

  character vector of animal IDs provided to the gene dropping function
  `geneDrop`.

- parent:

  the parent type ("sire" or "dam") of the parent who supplied the
  alleles as assigned during each of the 4 gene dropping iterations
  performed by `geneDrop`.

## Source

example baboon pedigree file provided by Deborah Newman, Southwest
National Primate Center.
