# Docs staleness audit, slice 6c: `man/` marker-genetics, genotype and MHC pages (2026-10-01, S838)

Read-only audit. Nothing in the repo was changed except this report and the session records.

## Audit summary

- **Scope:** 35 of the 267 `man/*.Rd` pages, the "marker genetics, genotype and MHC" topic group (listed under Items
  audited). `man/` is generated from roxygen in `R/`, so a fix goes in the `R/*.R` roxygen block, then
  `devtools::document()`. Slices 6a (genetic-value and kinship) and 6b (pedigree QC and curation) took 72 pages. **160
  pages remain** by this session's count (267 .Rd files minus 107 audited). The "196 remain" figure carried in
  earlier records counted the `man/figures/` directory as a page and so ran one high.
- **Criterion:** does each checkable claim (argument list and defaults, return type and fields, described behavior,
  example runnability, `@seealso` targets, numbers) match today's code? Read from the implementation and by running the
  calls, not from the roxygen alone.
- **Method:** four read-only subagents (sets A-D, ids QA/QB/QC/QD, 8-9 pages each). This session re-ran or re-read the
  source for **all 4 moderate findings** (QA1, QA2, QB1, QC1); all held. Minor findings are the agent's own check:
  **R** = it re-read the code, **A** = it ran the call.
- **Coverage:** 35 of 35 pages. Every `@examples` block that exists ran without error and without warning (the six
  internal `.marker*`/`.parse*` pages have none). Every `@seealso` and `\link` target checked exists.
- **Findings:** 0 critical, **4 moderate, 25 minor** (29). 31 of 35 pages have no moderate finding. Items that are
  not findings (code-text wording, a claim confirmed, an unverifiable provenance note) are listed under Not counted.

## Findings: Moderate

| ID | Location | Claim | Evidence | Fix | Check |
|---|---|---|---|---|---|
| QA1 | `R/computeGenomicROH.R:19-27` (`@details`) | `genomeLength` is "the sum, per chromosome, of (max(pos) - min(pos)) among the full-coverage loci in `locusMetadata`"; "A fixed, shared denominator keeps `fRoh` comparable across a cohort" | `fullMeta` is also restricted to loci that are columns of `genotypeMatrix` (`:104-105`). The doc example with 4-locus metadata gives `fRoh` 0.2857 (denominator 1.4e6); the same metadata with only L1-L3 in the matrix gives 0.4444 (9e5), with no warning. Full-coverage metadata loci absent from the matrix are dropped silently | "...among the full-coverage loci in `locusMetadata` that are also columns of `genotypeMatrix`. The denominator is fixed across individuals within one call but changes with the matrix's locus set; full-coverage metadata loci absent from the matrix are excluded silently (only matrix loci lacking full coverage warn)" | S, A |
| QA2 | `R/hasGenotype.R:6-10, 14-17` | "Non-standard column names are accepted for this assessment"; checks "based on expected columns and legal domains" | The `first`/`second` presence tests use `tolower()` but the numeric tests read `genotype$first` exact-case: `data.frame(ID, first, second)` is TRUE, `data.frame(ID, First, Second)` is FALSE (re-run). No domain is checked: negative, NA and 1e9 doubles give TRUE (re-run) | "Only the `id` column is matched loosely (any column whose lower-cased name contains 'id'). Columns must be named exactly `first` and `second` and be numeric; no value-range check is made" | S, A |
| QB1 | `R/checkSequenceGenotypeFile.R:12-13` (description) | "Optionally cross-validates an accompanying locus-metadata sidecar by reusing `checkLocusMetadata`" | The only use is `checkLocusMetadata(locusMetadata)` at `:126-128`, which checks the sidecar's own structure. Nothing compares sidecar loci with genotype loci; the agent's `checkSequenceGenotypeFile(g[1,], data.frame(locus="ZZ", chrom="1", pos=5))` with genotype locus `L1` returned the genotype with no message. The `@param` text at `:35-48` is accurate | "Optionally validates the accompanying locus-metadata sidecar's own structure by reusing `checkLocusMetadata`; it is not cross-checked against the genotype's loci" | S, A |
| QC1 | `R/markerKinship.R:23-25` (`@details`) | "When neither individual in a pair has a shared heterozygous locus (the formula's denominator is zero), the pair's kinship is undefined" | The denominator is `4 * min(N_Aa(i), N_Aa(j))` (`nMinMat`, `:118-121`), so it is zero when EITHER individual has no heterozygous locus. Re-run: `h` homozygous everywhere, `x` and `y` heterozygous; `markerKinship()` gives NA and a warning for h-x and h-y while x-y is 0.375 | "When at least one individual in a pair has no heterozygous locus among the loci genotyped in both (so min(N_Aa(i), N_Aa(j)) = 0 and the denominator is zero), the pair's kinship is undefined; that entry is NA and a warning names the pair" | S, A |

## Findings: Minor

| ID | Location | Claim and evidence | Check |
|---|---|---|---|
| QA3 | `R/hasGenotype.R:6-8` | "mapped to integers": the code only requires `is.numeric`, so doubles give TRUE | A |
| QA4 | `R/hasGenotype.R:6` | The `id` test is a substring match: a column named `valid` passes | A |
| QA5 | `R/addGenotype.R:12-16` | Returns a plain `data.frame` (from `merge(all = TRUE)`), not a "pedigree object"; adds integer `first`/`second` columns (codes from 10001) and adds rows for genotype ids absent from `ped`. 375 rows in, 375 out for `rhesusPedigree` | A |
| QA6 | `R/addGenotype.R:12-14` | The allele columns are columns 2 and 3 by position, not by name; not stated | R |
| QA7 | `R/chooseAlleles.R:3-7` | "`a1`: first allele for each individual" contradicts "equal length vectors ... for one individual" (they are per-iteration alleles of one parent); unequal lengths recycle `a2` silently: `chooseAlleles(1:4, 1:2)` gives `1 2 1 2` | A |
| QA8 | `R/assignAlleles.R:3-13` | `n` is used only when `parent` is NA; for a known parent the length comes from the parent's alleles | R |
| QA9 | `R/assignAlleles.R:3-13` | The `stop("sire and dam must have had alleles assigned: logic error")` path is undocumented | A |
| QA10 | `R/buildMarkerGenotypeMatrix.R:15-19` | A cell is NA only when there is no record is not quite true: a record with a missing allele gives the string `"NA/NA"` (unvalidated input only) | A |
| QA11 | `R/buildMarkerGenotypeMatrix.R` | Duplicate id x locus rows overwrite one another, last wins; undocumented | A |
| QA12 | `R/buildMarkerGenotypeMatrix.R:15-16` | "sorted alphabetically" is `pmin`/`pmax` string collation, locale-dependent (here `"a/A"`) | A |
| QA13 | `R/getGenotypes.R:3-7` | `sep` applies only to the non-Excel branch; `fileName` is not only a "temporary" path; returns a raw `read.table` frame with `na.strings = c("", "NA")`; the example reads `qcPed.csv`, a pedigree, as `pedCsv` | R |
| QA14 | `R/makeCEPH.R:11-17` | `id`, `sire`, `dam` are parallel vectors over all individuals, not one individual; duplicate ids error with `duplicate row.names`, not mentioned | A |
| QA15 | `R/parseMhcHaplotypeCalls.R:3-12` | Whitespace-only or whitespace-plus-`?` values are not treated as missing (`"  ?"` gives haplotype `"  "`, uncertain TRUE); trimming is assumed upstream | A |
| QA16 | `R/parseMhcHaplotypeCalls.R:13-18` | Rows are all `haplotype1` rows then all `haplotype2` rows, not interleaved per animal | A |
| QB2 | `R/checkGenotypeFile.R:5-12` | No error conditions listed: stops on fewer than 3 columns, a first column without "id", a column named `first`/`second`, and a numeric allele above 10000 ("collision"). `@return` says "column types and number required" are checked but no types are | A |
| QB3 | `R/checkLocusMetadata.R:6-12, 36-40` | `@return` omits that column 2/3/4 names are forced to `chrom`/`pos`/`cM` (`:56-60`) | R |
| QB4 | `R/checkLocusMetadata.R:7-12` | "chrom present" means non-NA; an empty-string chrom counts as present (`coverage` "full") | A |
| QC2 | `R/markerLdBlock.R:~118-126` | "(D', a chi-squared-based generalization of r2)" reads as one statistic; the function returns two columns, `Dprime` and `r2` | R |
| QC3 | `R/markerLdBlock.R` `@details`/`@return` | Undocumented: `stop()` when no locus has a non-NA chrom; loci missing from `locusMetadata` or the matrix are dropped silently; a zero-row frame with the full column shape when no chromosome has 2+ loci | R |
| QC4 | `R/markerRealizedRelatednessVariance.R` `@param nChr` | "integer ... a single positive value": any numeric above 0 passes (20.5); the error text says "positive integer" but is not enforced | R |
| QC6 | `R/markerAlleleFrequency.R` `@return` | An all-NA locus returns `numeric(0)`; not documented | A |
| QC7 | `R/markerHeterozygosity.R` | `markerExpectedHeterozygosity` gives He = 1.0 for a locus with no genotyped individual, and that value enters `meanHe`; the doc is silent (see Code candidates) | A |
| QD2 | `R/markerParentageLikelihood.R` `.markerTransmissionProbability` | "For a biallelic locus": the code is `mean(alleles == refAllele)` and the likelihood function uses it multi-allelically (non-reference alleles lumped); the stated values {0, 0.5, 1} hold | R |
| QD3 | `R/data.R:~141-165` `lacy1989PedAlleles` | No `@format`; prose sits in a `\describe{}` with no `\item`. Facts hold: 14 x 5002 (V1..V5000, id, parent) | A |
| QD4 | `R/data.R:~266` `pedWithGenotype` | Same `\describe{}` structure; 280 x 12 and the names are right; types not stated (sex factor, first/second numeric) | A |

IDs QB5 and QD5 are not used (see Not counted).

## Not counted

- QB5: `checkMhcHaplotypeFile`'s "(the bundled `rhesusGenotypes` shape)" was checked and is accurate.
- QD5: `pedWithGenotypeReport`'s "reportGV with 10,000 iterations" cannot be verified from the object and no `data-raw/`
  script generates it; the structure (a list of 14 elements) is consistent. Unverifiable, not false.
- QC5 and QD1 are one item: the warning text "share no shared genotyped loci" in `R/markerParentageExclusion.R` and
  `R/markerParentageLikelihood.R` is redundant wording in the code, not in roxygen.
- Examples ran clean on every page that has them; none contains a stated-output comment to check except
  `computeGenomicROH` (4e5 and 0.2857143, as stated) and the `checkMhcHaplotypeFile` `tryCatch` ("Error produced").

## Code candidates (owner decision, strict TDD; not doc fixes)

1. **`markerExpectedHeterozygosity` returns He = 1.0 for an all-NA locus** (`1 - sum(empty table)`), inflating
   `meanHe` (agent's run: `perLocus` L2 = 1.0, `meanHe` 0.75). `markerObservedHeterozygosity` returns NA in the analogous
   case. Fix: NA, or exclude the locus from `meanHe`. Not re-run by me.
2. **`computeGenomicROH` silently drops full-coverage metadata loci absent from the matrix**, so `fRoh` changes with
   the matrix's locus set (QA1). Intended or a warning owed?
3. **`hasGenotype` accepts `First`/`Second` in its name checks and then returns FALSE** (`R/hasGenotype.R:22-35`,
   QA2, re-run), and its `id` test is a substring match.
4. **`checkSequenceGenotypeFile` never reconciles the sidecar against the genotype's loci** (QB1): a locus-set
   mismatch passes silently.
5. **`checkGenotypeFile` `stri_c(format(...), sep = ", ")` has no `collapse`** (`R/checkGenotypeFile.R:41-44`), so
   several offending alleles do not join into one string, and the message embeds source indentation.
6. **`checkLocusMetadata` counts an empty-string `chrom` as present** (`:68-72`, QB4).
7. **`buildMarkerGenotypeMatrix` turns a missing allele into `"NA/NA"` and silently overwrites duplicate id x locus
   rows** (QA10, QA11); safe only if `checkMarkerGenotypeFile` always runs first.
8. **`chooseAlleles` silently recycles unequal-length inputs** (QA7); `.markerAlleleFrequencyTable` returns
   `numeric(0)` for an all-NA locus (QC6), which callers may not expect.

## Items audited

| Page | Findings |
|---|---|
| addGenotype | QA5, QA6 |
| assignAlleles | QA8, QA9 |
| buildMarkerGenotypeMatrix | QA10, QA11, QA12 |
| chooseAlleles | QA7 |
| getGenotypes | QA13 |
| hasGenotype | QA2, QA3, QA4 |
| makeCEPH | QA14 |
| computeGenomicROH | QA1 |
| dot-parseMhcHaplotypeCalls | QA15, QA16 |
| checkGenotypeFile | QB2 |
| checkLinkageMarkerGenotypeFile | none |
| checkLocusMetadata | QB3, QB4 |
| checkMarkerGenotypeFile | none |
| checkMhcHaplotypeFile | none |
| checkSequenceGenotypeFile | QB1 |
| mhcHaplotypeCarriers | none |
| mhcHaplotypeFrequency | none |
| dot-markerAlleleFrequencyTable | QC6 |
| markerExpectedHeterozygosity | QC7 |
| markerObservedHeterozygosity | none |
| markerFst | none |
| markerKinship | QC1 |
| markerLdBlock | QC2, QC3 |
| markerRealizedRelatednessVariance | QC4 |
| markerParentageExclusion | none |
| dot-markerOppositeHomozygoteCount | none |
| markerParentageLikelihood | none |
| dot-markerFlaggedSlotPedigree | none |
| dot-markerTransmissionProbability | QD2 |
| dot-markerTwoSourceGenotypeProbability | none |
| lacy1989PedAlleles | QD3 |
| ped1Alleles | none |
| pedWithGenotype | QD4 |
| pedWithGenotypeReport | none |
| rhesusGenotypes | none |

## Structural observations

- **Two moderate findings are "the check does less than its description says"** (QA2 `hasGenotype`, QB1
  `checkSequenceGenotypeFile`), the same drift as slice 6b's error-reporting pages. Both pair with a code candidate.
- **Silent subsetting** is the common thread behind QA1, QC3 and QA11: a function drops or overwrites input without a
  message, and the roxygen does not say so.
- **The numeric estimators (`markerFst`, `markerParentageLikelihood`, `mhcHaplotypeFrequency`) are clean.** Their
  documents were written with the formulas and edge cases in view; the drift is in the file-checkers and glue.
- **Datasets (5) are clean on facts**; only Rd structure (`\describe{}` without `\item`) is off.

## Comparison with prior audits

| Metric | Slice 6a (36 pages) | Slice 6b (36 pages) | Slice 6c (35 pages) |
|---|---|---|---|
| Moderate / minor | 9 / 45 | 20 / 37 | 4 / 25 |
| Findings per page | 1.5 | 1.6 | 0.8 |
| Pages with a moderate finding | not tallied | not tallied | 4 of 35 |

The lower rate may reflect that much of this group is recent (issue #152 onward) code; that is a guess, not measured.

## Recommendations

1. Fix the 29 findings in the `R/*.R` roxygen, then `devtools::document()` (the S835/S837 pattern), as the next
   session. Decide code candidates 1-4 first, since QA1, QA2 and QB1 would change if the code changes.
2. Slice 6d: the next topic group of `man/` (160 pages remain; candidates: the `modXxxServer`/`modXxxUI` Shiny modules
   (~28), the `obfuscate*` and de-identification functions, the pedigree-tree and getter helpers).
