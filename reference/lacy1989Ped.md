# Small hypothetical pedigree (Lacy 1989)

Small hypothetical pedigree (Lacy 1989)

## Usage

``` r
data(lacy1989Ped)
```

## Format

An object of class `data.frame` with 7 rows and 5 columns.

## Source

lacy1989Ped is a dataframe containing the small hypothetical pedigree of
three founders and four descendants used by Robert C. Lacy in "Analysis
of Founder Representation in Pedigrees: Founder Equivalents and Founder
Genome Equivalents" Zoo Biology 8:111-123 (1989).

The founders (`A`, `B`, `E`) have unknown parentages and are assumed to
have independent ancestries.

- id:

  character column of animal IDs

- sire:

  the male parent of the animal indicated by the `id` column. Unknown
  sires are indicated with `NA`

- dam:

  the female parent of the animal indicated by the `id` column.Unknown
  dams are indicated with `NA`

- gen:

  generation number (integers beginning with 0 for the founder
  generation) of the animal indicated by the `id` column.

- population:

  logical vector with all values set TRUE
