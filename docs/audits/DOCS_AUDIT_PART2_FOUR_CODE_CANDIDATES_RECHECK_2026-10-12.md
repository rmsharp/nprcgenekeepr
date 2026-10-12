# Docs audit, part 2: the four likely code defects, re-checked against today's code (2026-10-12, S966)

Read-only audit. Nothing in the repo was changed except this report and the session records. No fix was made: every
fix below is a code change and needs your ruling and its own strict-TDD session.

## Audit summary

- **Scope:** the four "likely code or UI defects" that docs-audit slice 4 (S821 to S828, report
  `DOCS_STALENESS_AUDIT_SLICE4_2026-09-30.md:176-179`) listed as needing an owner decision, carried in `BACKLOG.md:16`
  (text `:109`, item "8 four likely code defects") without a re-check since S870. **Not covered:** the other clusters
  in that item (slices 6a to 6e, 7b, the rest of slice 8); they stay open in `BACKLOG.md`.
- **Criterion:** is the behavior slice 4 described still what the code does today, and what does a user of the app or
  the documentation now learn about it?
- **Method:** read the code at each cited place; grep every identifier across `R/`, `inst/`, `vignettes/` and
  `tests/`; dated the earlier doc fixes with `git log -S`; ran two probes from scratch scripts outside the repo (the
  pure function `qcStudbook()`, and the real Input module through `shiny::testServer(modInputServer)` with the test
  suite's own upload recipe, `tests/testthat/test_modInput_blankCells.R:21-36`).
- **Not done:** no browser-driven run, so what the Input tab draws is read from `R/appServer.R:236-296`, not seen; the
  guide pictures were not opened to see whether they show the controls in findings 1 and 2.
- **Result:** all four are still real in the code. Docs now say so for three of them; one wording error is left.
  **0 critical, 3 moderate, 1 minor.** One sub-claim of slice 4 is already fixed.

## Findings

### Finding 1: the "Upload list" choice uploads nothing (moderate, behavior; docs already say so)

- **Location:** `R/modBreedingGroups.R:40-43` (the choice), `:79` (the module's only `fileInput`, `ancestryRulesFile`),
  `:531-536` (the pool).
- **Evidence:** `"Upload list" = "custom"` is a radio choice; there is no control to give it a list. At `:531-536` only
  `"topRanked"` takes the ranked ids; `"custom"` and `"all"` both take `ped$id`. So today "Upload list" and "All
  available" give the same result. Tests pin this on purpose: `tests/testthat/test_modBreedingGroups.R:365`,
  `tests/testthat/test_modBreedingGroups_livingPool.R:152-155`.
- **Docs today:** correct. The manual (`vignettes/manual_components/_breeding_group_formation.Rmd:28`) says it behaves
  like "All available", and the roxygen (`R/modBreedingGroups.R:215-216`, fixed S841, 2026-10-01) says it has no upload
  control. Slice 4's BA1 and UG18 are fixed.
- **Impact:** a user who picks it expects their own list to be used and gets every living animal instead.
- **Your ruling:** (a) take the choice out (small; the Breeding Groups guide pictures may then need retaking, not
  checked); (b) build the upload (a feature, Effort M); (c) leave it, since the page says what it does.

### Finding 2: "Calculate Genome Uniqueness" and "Calculate Mean Kinship" do nothing (moderate, behavior; docs already say so)

- **Location:** `R/modGeneticValue.R:63-66`.
- **Evidence:** both are `checkboxInput(..., TRUE)`. The only places either name appears in the whole repo are those
  four lines and tests that set and read the input back (`tests/testthat/test_modGeneticValue.R:60-61, 151-155,
  799-816`). No `input$calc...`, no `input[[...]]` and no `reactiveValuesToList(input)` in the module. `reportGV()`
  calculates both unconditionally (`R/reportGV.R:222` for mean kinship, `:261` for genome uniqueness), and the tier ranking uses both
  (`R/modGeneticValue.R:54-55`, "Genome uniqueness first" / "Mean kinship first").
- **Docs today:** correct. `_genetic_value_analysis.Rmd:41-43` says "They currently have no effect" (S827, 2026-09-30).
  Slice 4's BA18 is fixed as wording.
- **Impact:** unchecking a box looks like it should skip a calculation and does not.
- **Your ruling:** (a) take both boxes out (two UI lines, three places in `test_modGeneticValue.R`, and the Genetic Value picture if it
  shows them, not checked); (b) wire them, which cannot mean what the labels say because the tier ranking uses both numbers; (c)
  leave them.

### Finding 3: the `groupAddAssign` help says "average" where the code uses the smallest group (minor, wording only)

- **Location:** `R/groupAddAssign.R:9-11` and `man/groupAddAssign.Rd:153` say the function "finds the set of groups with
  the largest average size".
- **Evidence:** the code scores a trial by `min(lengths(groupMembers))` (`R/groupAddAssign.R:284`, `:413`), keeps a
  trial only if its score beats the worst kept one (`:299`), and its own message says "by score (min group size)"
  (`:448`). The manual (`_breeding_group_algorithm.Rmd:72`) and `gvAndBgDesc.html:151` already say "smallest group".
  For one group the two readings agree; for several they differ.
- **The second half of slice 4's item, "or younger" (UG17), is already fixed:** the roxygen at `R/groupAddAssign.R:37-40`
  says an animal exactly the minimum age "is not ignored" (S844, 2026-10-01), as does `group_formation.html` (S826).
  `R/filterAge.R:26` keeps a pair at `age >= minAge`, which matches.
- **Your ruling:** none needed about the code. The wording fix is two places (roxygen, regenerated `man/` page): say
  "the largest smallest-group size". Say go and it is one small strict-TDD session.

### Finding 4: a pedigree file with `allele_1` / `allele_2` columns loads, and its genotypes are not used (moderate, behavior; docs already say so)

- **Location:** `R/fixColumnNames.R:38` (the underscore is stripped), `R/hasGenotype.R` (needs `first` and `second`),
  `R/modInput.R:523` (the app asks for column changes to be reported).
- **Evidence (the real Input module, "pedigree and genotypes in one file", integer alleles, 4 animals):**

  | Pedigree file columns | Cleaned columns after QC | Genotypes extracted | Errors / warnings | Column-change note |
  |---|---|---|---|---|
  | `allele_1`, `allele_2` | `..., allele1, allele2, ...` | **no** | 0 / 0 | one: "allele_1 and allele_2 to allele1 and allele2" |
  | `first`, `second` (control) | `..., first, second, ...` | yes | 0 / 0 | none |

  The same two results come from `qcStudbook()` alone (`hasGenotype()` FALSE and TRUE). So the file is accepted, the
  user is told the columns were renamed (the Changed Columns tab, `R/appServer.R:270-296`, read not seen), and nothing
  says the genotypes were then ignored. The Genetic Value run goes on without them.
- **Docs today:** correct. `input_format.html:85-89` says to name the columns `first` and `second`, whole numbers only,
  and that otherwise "the genotypes are then not used" (S825, 2026-09-30). Slice 4's UG2 and UG3 are fixed as wording.
- **Impact:** a user who chose "genotypes in one file" and used the other spelling, or text alleles, gets a
  genotype-free analysis with no warning on the screen.
- **Your ruling:** (a) leave it, since the page says so; (b) accept the underscore spelling as well; (c) show a notice
  when this option is chosen and no usable genotype columns result. (c) also covers text alleles and is the smallest
  change that ends the silence.

## Items audited

| Item | Today | Findings |
|---|---|---|
| "Upload list" (BA1, UG18) | still real in code; docs fixed | 1 |
| Two calculate checkboxes (BA18) | still real in code; docs fixed | 2 |
| `groupAddAssign` "average" (BA12) | still wrong in roxygen and `man/`; manual fixed | 3 |
| `groupAddAssign` "or younger" (UG17) | fixed S844 / S826 | none |
| `allele_1` / `allele_2` (UG2, UG3) | still real in code; docs fixed | 4 |

Coverage: 5 of 5 candidate claims examined (4 candidates, one with two halves).

## Structural observations

- Findings 1, 2 and 4 are one pattern: the app **accepts something it does not use and says nothing at the moment of
  use**. S825 to S841 handled each by writing it into the documentation, which is correct and is also where the
  trail ends. Finding 2 could be a gate: a test that every input a module's UI declares is read by its server or is on
  a short list. That is an idea, not measured: I did not count how many other inputs it would flag, and it would not
  catch finding 1 (that radio is read).
- Slice 4's own count held up: all four were real, none was a misread. Where a code check was cheap (the grep, the
  two probes) the claims survived; the three doc fixes were made correctly the first time.

## Comparison with slice 4

| Slice 4 claim | 2026-09-30 | 2026-10-12 |
|---|---|---|
| "Upload list" uploads nothing | likely defect | confirmed; docs say so |
| Two checkboxes have no effect | likely defect | confirmed; docs say so |
| "average" group size | wording error | still in roxygen and `man/` |
| "or younger" | wording error | fixed |
| `allele_1/allele_2` silently dropped | likely defect | confirmed; docs say so; the app shows only the rename note |

## Recommendations

1. **Finding 3, wording fix:** needs only your go-ahead. Effort S.
2. **Finding 4:** rule (a), (b) or (c). I would pick (c): a one-line notice. Effort S.
3. **Finding 2:** rule (a), (b) or (c). I would pick (a): two controls that do nothing. Effort S.
4. **Finding 1:** rule (a), (b) or (c). Your call; (b) is the only one that is a feature. Effort S for (a) or (c), M for (b).
5. Each ruling is its own session. None of them changes a calculated number.
