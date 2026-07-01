# roxygen2 `@examples` Policy

**Status:** Ratified convention (living standards doc). Governs all future
`R/*.R` documentation edits.
**Origin:** issue #103 Stage 7, from the harmonization audit
`docs/audits/ROXYGEN_HARMONIZATION_AUDIT_2026-06-29.md` (Finding 1 / §7).
**Scope:** developer-facing only. This file lives under `docs/` (which is
`.Rbuildignore`d, line 15), so it ships nowhere and renders as no user help.
Do **not** restate this policy in rendered user surfaces (man pages,
vignettes, `NEWS`).

---

## 1. Which exported functions must carry `@examples`

**Every _directly callable_ exported function carries an `@examples` block.**
A function is directly callable when a user could reasonably invoke it from
the console or a script.

### Exempt (documented carve-out)

These exported objects are **exempt** from the `@examples` requirement,
because they are framework-invoked rather than directly callable, or they only
build UI:

| Category | Examples | Why exempt |
|---|---|---|
| Shiny module UI/server | `mod*UI`, `mod*Server` (e.g. `modInputUI`, `modInputServer`) | Only meaningful inside a running app / `moduleServer` session. |
| App entry points | `appUI`, `appServer` | Build/serve the app; require a live Shiny session. |
| Pure-UI tab builders | `getChangedColsTab`, `getErrorTab` | Return a Shiny UI object (`tabPanel()`); nothing to demonstrate standalone. |
| Deprecated aliases | `makeGrpNum` | Defer to the canonical function; an example would advertise deprecated use. A deprecated *launcher* (`runGeneKeepR`) may still show a guarded launch pattern. |

**Not exempt just because the name looks UI-ish.** A function is exempt only
when its body genuinely builds Shiny UI or requires a session. Two functions
the original audit mislabeled "tab-UI" — `shouldShowChangedColsTab` (returns a
logical) and `processQcStudbookResult` (returns a list of data frames) —
contain **no Shiny code**, are directly callable, and therefore **do** carry
examples. When in doubt, read the body, not the name.

Do **not** chase a literal 100% coverage: the exemptions above are deliberate.

---

## 2. The single guard ladder

Pick the **lowest** rung an example can honestly sit on:

1. **Bare runnable (default).** Use when the example is cheap, deterministic,
   and side-effect-free (console/`message()` output is fine), with inputs from
   a bundled `data/` dataset, an `inst/` file via `system.file()`, or inline
   literals. If the function writes files, write them under `tempdir()` and the
   example can still be bare-runnable. This is the strongly preferred rung —
   a runnable example is executed by `R CMD check` and so is continuously
   verified.
2. **`\donttest{}`.** Reserve for examples that are correct and safe but
   genuinely **slow** (long-running). Executed under
   `R CMD check --run-donttest` (and increasingly on CRAN), so do **not** use
   it to hide network/EHR dependence.
3. **`\dontrun{}`.** Only for examples that genuinely **cannot run** in a check
   environment: they need a live LabKey/EHR or network connection
   (all `Rlabkey`/LabKey functions — e.g. `getDemographics`,
   `getLkDirectAncestors`, `getLkDirectRelatives`, `setLabKeyDefaults`),
   launch the interactive Shiny app (`runModularApp`, `runGeneKeepR`), or
   require an on-disk resource the package does not ship. Never use `\dontrun`
   merely to silence a slow or noisy but runnable example.

**`if (interactive()) { ... }` is retired as an example guard.** Use
`\dontrun{}` for app launchers instead.

---

## 3. Reference exemplars

Model new examples on these (bare-runnable, self-building inputs from bundled
data): `getSpeciesGestation.R`, `applyKinshipOverrides.R`, `kinship.R`,
`calcA.R`. For a file-reading example, `getPedigree.R` shows the house pattern
(`system.file("testdata", "qcPed.csv", package = "nprcgenekeepr")`).

Bundled inputs commonly used in examples: `qcPed`, `lacy1989Ped`,
`rhesusPedigree`, `qcBreeders`, `pedGood` and the `ped*` QC-demo studbooks,
`speciesGestation`, `ped1Alleles` (see `R/data.R`).

---

## 4. Verification

Examples are executed by `R CMD check`. After adding or re-rung-ing any
example:

- Keep each `#'` example line within the 80-char lint limit (the `#' ` prefix
  is 3 chars, so raw example code stays <= 77).
- Re-run `devtools::document()`; the change is intended rendered `man/` drift
  (unlike the zero-drift earlier stages).
- Gate with `R CMD check --as-cran` (which runs the runnable and `\donttest`
  examples). A green check is the proof a runnable example is correct.
