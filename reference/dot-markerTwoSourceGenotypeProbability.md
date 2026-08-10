# Offspring genotype probability given two allele-transmission sources

Internal helper for
[`markerParentageLikelihood`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md)
(issue \#147 Slice 1, D2). Computes the probability of an offspring's
genotype given two independent sources of one transmitted allele each –
either could be a real parent's own
[`.markerTransmissionProbability`](https://github.com/rmsharp/nprcgenekeepr/reference/dot-markerTransmissionProbability.md),
or the population reference-allele frequency standing in for an
unrelated/unknown source (H2, or an untyped second parent under dyad
conditioning). This one function covers all four H1/dyad, H1/trio,
H2/dyad, and H2/trio cases simply by which `t1`/`t2` values are passed
in – verified at this session's Pre-RED to reduce exactly to
Hardy-Weinberg genotype frequencies when both `t1` and `t2` equal the
population frequency.

## Usage

``` r
.markerTwoSourceGenotypeProbability(t1, t2, genoStr, refAllele)
```

## Arguments

- t1, t2:

  each a probability (in `[0, 1]`) that the corresponding source
  transmits `refAllele`.

- genoStr:

  the offspring's genotype string at this locus.

- refAllele:

  the reference allele at this locus.

## Value

A numeric scalar probability in `[0, 1]`.
