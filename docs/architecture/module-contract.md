# Shiny Module Contract

**Status:** Ratified convention (living standards doc). Governs all `mod*UI`/
`mod*Server` Shiny module pairs in `R/`.
**Origin:** issue #122 (XARCH-2), from
`docs/planning/issue122-module-contract-plan.md` section 4.4 -- the architecture
note that plan's Phase 5 committed to writing.
**Scope:** developer-facing only. This file lives under `docs/` (which is
`.Rbuildignore`d), so it ships nowhere and renders as no user help. Do **not**
restate this contract in rendered user surfaces (man pages, vignettes, `NEWS`).
**Enforcement:** `tests/testthat/test_moduleContract.R` mechanically checks rule 2
(named list of reactives) for every `mod*Server` in the package. Rules 1 and 3-6
are currently unenforced by a test -- reviewers are the check.

---

## The contract

```
modXUI(id)                      -> a tagList. No exceptions.
modXServer(id, <named args>)    -> a NAMED LIST OF REACTIVES, over a stable vocabulary.
```

Rules, in the order they bind:

1. **Every server argument that carries data is a `reactive()`.** No bare
   `reactiveValues` reads at the call site. No plain values.
2. **Every returned element is a `reactive()`.** No plain values, no bare `NULL`
   returns.
3. **The returned vocabulary is stable:** `pedigree`, `gvReport`, `kinship`,
   `errors`, `isReady` are the canonical names for those concepts wherever a
   module returns them. Data-frame columns use the canonical vocabulary (see
   `reportGV()`'s `indivMeanKin`/`gu`) -- never a per-consumer rename.
4. **Return only what a consumer reads.** A returned reactive with no consumer is
   dead weight -- delete it or wire it. "Consumer" includes the test suite, not
   only `appServer` (see `PROJECT_LEARNINGS.md` Learning 347(a): `modSummaryStats`'
   12 reactives were nearly deleted as "unread" because only `appServer`'s wiring
   was checked -- ~53 real test assertions across 4 files read them).
5. **Upstream absence is `req()`; upstream *malformedness* is an error that
   surfaces.** A blanket `tryCatch(..., error = function(e) NULL)` at the seam
   between modules is forbidden -- it makes a shape mismatch look like "no data
   yet."
6. **Every declared parameter is read, and every returned element is
   documented.** A parameter the body never reads is a lie the call site keeps
   telling.

## Reference implementation

`modInput` (`R/modInput.R`) satisfies all six rules and is the reference
implementation. Read it first when writing or reviewing a new module.

## Documented exceptions

Two deliberate departures from the letter of the contract -- both intentional,
both re-verify-before-touching:

- **`modGvAndBgDescServer` returns bare `NULL`, not a named list.** It is
  genuinely stateless (an informational-only tab, no reactive state to expose).
  See `docs/planning/issue122-module-contract-plan.md` section 10, open decision
  3. The guard test (below) carves this module out explicitly rather than
  silently.
- **`gestationTable` is passed into `modPotentialParentsServer` as a bare
  `reactiveValues` read**, not wrapped in `reactive()` (`R/appServer.R`:
  `gestationTable = shared$speciesOverrides$gestationTable`) -- violating rule 1
  literally. This is correct *only* because of R's lazy-argument semantics: the
  read is deferred until the promise is forced inside a reactive context, after
  boot has populated it (`R/modPotentialParents.R` documents this). **Do not
  "tidy" this into an eager `reactive()` wrapper** -- a promise forces once;
  wrapping it changes *when* it is forced, and it will silently serve stale data
  the day the config becomes re-loadable. See the module-contract plan's Dragon
  4.

## Guard test

`tests/testthat/test_moduleContract.R` exercises every `mod*Server` via
`shiny::testServer()`, with arguments mirroring `R/appServer.R`'s real call
sites, and asserts rule 2 (named list of reactives; every element
`is.function()`) for every module except the declared `modGvAndBgDescServer`
exception above. It does not mechanically check rules 1, 3, 5, or 6 -- those
remain a review-time discipline, not a test.
