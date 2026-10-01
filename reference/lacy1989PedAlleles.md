# Gene-drop alleles for lacy1989Ped (5000 iterations)

A dataframe produced by `geneDrop` on `lacy1989Ped` with 5000
iterations.

## Usage

``` r
data(lacy1989PedAlleles)
```

## Format

A dataframe with 14 rows and 5002 columns. There are 5000 columns (`V1`
to `V5000`), one for each iteration in `geneDrop` containing alleles
randomly selected at each generation of the pedigree using Mendelian
rules.

Column 5001 is the `id` column with two rows for each member of the
pedigree (2 \* 7).

Column 5002 is the `parent` column with values of `sire` and `dam`
alternating.

## Source

lacy1989Ped is a dataframe containing the small example pedigree used by
Robert C. Lacy in "Analysis of Founder Representation in Pedigrees:
Founder Equivalents and Founder Genome Equivalents" Zoo Biology
8:111-123 (1989).
