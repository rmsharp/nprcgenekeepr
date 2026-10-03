# Plan: route every direct sex letter in `R/` through `sexCodes`

*Session 873, 2026-10-02. Planning only: no `R/` or test file was changed. Owner decision (S872):
"all", meaning every direct sex letter in `R/` goes through the internal `sexCodes` constant
(`R/sexCodes.R`). Closes PED-2, NEW-29, PED-7 in
`docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md` when the last stage ships. Owner answered section 5 on
2026-10-02 (S873 follow-up): keep the literal `groupAddAssign` default and exempt that one line; leave
`convertSexCodes.R` and the two fixtures alone. Plan is now approved.*

## 1. What changes and why it is safe

`sexCodes <- c(male = "M", female = "F", hermaphrodite = "H", unknown = "U")` is already the single
source of truth, and 6 files use it (XARCH-4, guarded by `tests/testthat/test_sexCodes.R`). This
plan finishes the job for the remaining files. It is a **behavior-preserving refactor**: each
`"M"` becomes `sexCodes[["male"]]`, which is the same one-element unnamed string.

**Trap:** `sexCodes["male"]` (single bracket) keeps the name and breaks `identical(x, "M")`. Use
`[[ ]]` for one code. A multi-code `%in%` set may use `sexCodes[c("hermaphrodite", "unknown", "male")]`
because `%in%` ignores names.

## 2. Evidence: grep inventory (S873, `R/*.R`, roxygen `#'` and comment lines excluded)

Searches run: quoted `"M"|"F"|"H"|"U"` (both quote styles) next to `==`, `!=`, `%in%`, `identical(`,
`<-`, `c(`; then each hit read in context.

| Form | Lines | Files |
|---|---|---|
| A. Comparison / membership (`==`, `!=`, `%in%`, `identical`) | 37 | calcNeSexRatio 2, correctParentSex 4, createColonySnapshot 2, getKinshipWithMaleStatus 2, getPotentialParents 2, getProductionStatus 1, getSexRatioWithAdditions 2, getSpeciesMinBreedingAge 2, makePedigreeDiagramData 6 (965-966, 1090-1091, 1262-1263), modORIPReporting 8, modPyramid 2, reportGV 2, resolveBreedingAge 2 |
| B. Assigned sex value | 3 | addParents 54, 62; correctUnknownParentMeanKinship 172; (correctParentSex 97-98 already counted in A) |
| C. Argument / default literal | 3 | checkParentAge 148, 151 (`resolveBreedingAge(sp, "M", ...)`); groupAddAssign 179 (`ignore = list(c("F", "F"))`, an **exported** default shown in `man/groupAddAssign.Rd:13`) |
| D. Converter vocabulary | 12 | `convertSexCodes.R` 45-56 (raw spellings in, letters out, factor levels) |
| E. Test-data fixtures | 2 | `createPedOne.R:19`, `createPedSix.R:47` (`sex = c(...)` data columns) |
| Not sex (must not be flagged) | 5 | `convertFromCenter.R:28` (`"F"` = FALSE), `convertStatusCodes.R:40` (`"U"` in UNKNOWN), `obfuscateId.R:53-54` (alphabet), `qcStudbook.R:412` (`"F"` = FALSE) |

Count note: S872 reported 40 comparison lines in 16 files by a looser measure; this inventory splits
by form (A+B+C = 43 code lines in 17 files, plus D and E). The scope below is A+B+C = 17 files.

Existing safety net (test files naming each function): all 16 functions in A-C are covered except
**`getSexRatioWithAdditions` (0 test files; reached only through `calculateSexRatio`)**. Its stage
adds one direct characterization test first.

## 3. Decisions proposed (defaults; owner can overrule)

1. **D (`convertSexCodes.R`): leave as is and allowlist.** It is the converter that *defines* the
   vocabulary and also lists raw input spellings (`"M"`, `"MALE"`, `"1"`); rewriting it adds no
   safety. S872 gotcha already says the guard must not flag it.
2. **E (fixtures in `createPedOne/Six`): leave.** They are example data, not logic.
3. **C (`groupAddAssign` default): change to `list(c(sexCodes[["female"]], sexCodes[["female"]]))`**
   like `filterPairs()`/`modBreedingGroups()` already do. Cost: the exported man page usage line
   would show `sexCodes[["female"]]`, an internal name users cannot see. Alternative: keep the literal
   default and allowlist that one line. Needs the owner's pick (section 5).

## 4. Stages (each stage = one session, strict TDD, 4 R files + the guard test = 5 files max)

**Guard design.** Extend `test_sexCodes.R` with a scan of *named files* that grows per stage, so the
suite stays green at every commit: a `convertedFiles` vector plus the existing
`findBareSexCodeLiterals()`, widened to `(==|!=|%in%)` and `identical(` forms and to
`<- "X"` / argument forms for the files in B/C. RED = add the stage's files to `convertedFiles`
(test fails, listing offending lines). GREEN = convert them. The last stage replaces the file list
with a scan of every `R/*.R` minus an explicit allowlist (`sexCodes.R`, `convertSexCodes.R`,
`createPedOne.R`, `createPedSix.R`, and the five non-sex lines above by exact trimmed text, never
a whole-file pass for `qcStudbook.R`), so a new bare letter anywhere fails CI.

| Stage | R files | Extra | Done when |
|---|---|---|---|
| 1 | calcNeSexRatio, createColonySnapshot, getSexRatioWithAdditions, getProductionStatus | new direct test for `getSexRatioWithAdditions` (RED-first, passes on old and new code) | guard green for these 4; their tests green |
| 2 | getSpeciesMinBreedingAge, resolveBreedingAge, checkParentAge, getKinshipWithMaleStatus | none | same |
| 3 | getPotentialParents, reportGV, modPyramid, correctUnknownParentMeanKinship | none | same |
| 4 | correctParentSex, addParents, modORIPReporting | none | same, plus ORIP module tests |
| 5 | makePedigreeDiagramData | hoist `male <- sexCodes[["male"]]` etc. out of the loops at 965/1090/1262 | pedigree-diagram tests (9 files) green; rendered output identical on a fixed pedigree before and after |
| 6 | groupAddAssign (per decision 3) | roxygen + `man/groupAddAssign.Rd` regen if default changes; flip guard to full `R/` scan; close PED-2/NEW-29/PED-7 in the triage report; remove the BACKLOG block; `CHANGELOG.md` | full guard green; `devtools::check()` codoc clean |

Every stage's DONE criteria (surface = local machine; CI is the second surface):
- Single-file tests for each touched function:
  `Rscript -e 'Sys.setenv(NOT_CRAN="true"); suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_X.R", reporter="summary")'`
- `lintr::lint_package()` after `load_all()` (lint close-out checklist).
- Stage 6 and any stage that touches `modORIPReporting`/`modPyramid`: the clean regression read from
  `CLAUDE.md` (full `test_dir`, `sum(failed)` and `sum(error)` both 0), plus `devtools::check()` at
  stage 6. The Shiny-module surface is exercised only by the shinytest2/e2e files; a green unit test
  does not prove a module renders, so stage 4 runs `test-e2e-orip-module.R`.
- No NEWS entry (internal refactor, no user-visible change); no `_pkgdown.yml` change (no new export).

## 5. Owner answers (2026-10-02, both recorded)

1. Decision 3: **keep the literal** `groupAddAssign` default and allowlist that one line by exact text. So
   stage 6 has no roxygen or `man/` change; its scope shrinks to the guard flip and the closures.
2. Decisions 1 and 2: **accepted** (leave `convertSexCodes.R` and the two fixtures alone).

## 6. Gotchas for the implementer

- `makePedigreeDiagramData.R:1840` has a parameter named `sexCodes` in `.shapeForVec` that shadows the
  constant inside that one closure; the sex comparisons at 965/1090/1262 are in other functions, but
  do not add a use inside `.shapeForVec` without renaming the parameter.
- `identical(sexOf[[p]], ...)`: keep `[[ ]]` access, never `[`.
- Hoist the constant lookup out of hot loops in `makePedigreeDiagramData.R`; the cost is small but
  the loops run per node (cap 1,500).
- Roxygen `@examples` legitimately show literal letters; the guard skips `#'` lines (as the existing
  test does).
