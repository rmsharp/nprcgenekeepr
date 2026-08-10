# Issue #149 Plan — Reviewed Cross-Center Identity-Mapping Workflow With Provenance Export

**Status:** RATIFIED (2026-08-10, this session). All four judgment-call decisions (Q1-Q4) were ratified via a single `AskUserQuestion` round; the owner selected this document's own recommended option in all four cases, with no changes requested. See §11 for the recorded outcome. This plan is ready for Slice 1 implementation in a future session.
**Session:** S503 (2026-08-10)
**Origin:** GitHub issue #149, Tier 2 step 1 ("Ready-to-Build Medium-Priority Features") of `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` — sequenced first in that tier as "the most contained, highest-readiness item, and because it establishes confirm/export UI conventions #150 (Tier 3, if greenlit) can reuse." Named there as needing "a non-fail-fast 'show all problems at once' validation surface, the app's first `showModal()`/`modalDialog()` confirmation gate, and a multi-artifact provenance export — none with any existing precedent to collide with."
**Touches (planned, future sessions):** `R/resolveCrossCenterIds.R` (internal-only extract-method refactor — see D2; zero change to its exported signature or documented contract; D10, if ratified, additively extends its merge-row column coverage), `R/checkCrossCenterMapping.R` (new, exported), `R/modCrossCenterIdentity.R` (new Shiny module), `R/appUI.R` (new top-level tab), `R/appServer.R` (new self-contained module wiring), `tests/testthat/test_resolveCrossCenterIds.R` (a new golden-master regression test pinning D2's validation-refactor behavior-preservation; all 7 existing test blocks must keep passing unmodified), `tests/testthat/test_checkCrossCenterMapping.R` (new), `tests/testthat/test_modCrossCenterIdentity.R` (new), `tests/testthat/test_moduleContract.R` (register the new module's reactive vocabulary), `_pkgdown.yml` (reference-coverage entries for `checkCrossCenterMapping()` in Slice 1 and for `modCrossCenterIdentityUI`/`modCrossCenterIdentityServer` in Slice 2), `NEWS.Rmd` (Slice 1 entry for the new exported function, Slice 2 entry for the new Shiny feature), `vignettes/articles/colony-manager-guide.qmd` and/or a new `vignettes/manual_components/*.Rmd` component (Slice 2).
**Does NOT touch:** `R/resolveCrossCenterIds.R`'s exported signature or any of its 7 existing test blocks' assertions (D2's validation-mechanism refactor is proven byte-identical there; D10 is a separately-flagged, explicitly-called-out additive change to a *different* part of the same function, not hidden inside D2's guarantee); `R/modMarkerGenetics.R`'s existing "Cross-Center" tab (a different concept — genotype-based Fst between two uploaded genotype files, not pedigree identity merging — confirmed structurally distinct, §2.8; not reused, renamed, or extended); `shared$currentPedigree` or any `appServer.R` dependency-injection wiring beyond this module's own two independent file uploads (D3 — a standalone review/export tool, not a new pedigree source feeding the rest of the app, this scope); `obfuscatePed()`/`obfuscateId()`/`mapIdsToObfuscated()` (de-identification is issue #150's separate concern — this workflow's whole premise is a curator reviewing real, identified cross-center records).
**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` — a new module boundary, a validation-surface architecture decision (extract-shared-helpers vs. duplicate vs. change an already-shipped function's contract), a scope-boundary decision (standalone tool vs. wired into downstream analysis), and the app's first confirm-gate UI pattern — not a pure visual-layout `DESIGN_WORKSTREAM.md` question, matching the #133/#136/#137/#145/#147 precedent for this shape of decision.

> **Scope.** Design (not implement) a Shiny workflow around the existing, exported `resolveCrossCenterIds()`: a non-fail-fast validation surface, a preview of the proposed merge, an explicit confirmation gate, and export of the mapping, validation results, merge summary, and provenance — per the issue's own text, retaining the "no-automatic-identity-inference policy."

---

## 1. Context

### 1.1 What issue #149 says (verbatim)

> ## Source
>
> `GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`: cross-center workflow ergonomics.
>
> `resolveCrossCenterIds(pedA, pedB, mapping)` safely merges pedigrees with a curator-confirmed ID map, but is script-callable only.
>
> Add a Shiny workflow to accept two pedigrees and a reviewer-supplied mapping; validate ID existence, uniqueness, collisions, and parent conflicts; preview proposed collapses and lineage changes; require explicit confirmation; and export the mapping, validation results, merge summary, and provenance.
>
> Retain the no-automatic-identity-inference policy. This issue operationalizes reviewed mapping; it must not guess identity from matching strings or markers.

Confirmed verbatim via `gh issue view 149 --json title,body,comments,state` at this session's Phase 1 (zero comments on the issue, state OPEN).

### 1.2 What is already decided (do not re-litigate)

- **Priority/sequencing position:** #149 is Tier 2's first item (`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md:217-224`) — "smallest of the three [Tier 2 items]: the hard part (the merge algorithm and its fail-fast validation) is already exported, documented, and fully tested."
- **The merge algorithm itself is not up for redesign.** `resolveCrossCenterIds()` (issue #130 Slice 4, S446) already implements the exact four checks the issue names (existence, uniqueness, collisions, conflicts — confirmed 1:1 in §2.2) and the "prefer whichever side has a non-`NA` value" lineage rule for `sire`/`dam` specifically. This document builds a review/operational UI *around* it, per both the issue's own framing and the 08-06 capability audit's characterization: "Safe merging exists... neither is yet an end-to-end operational program" (`GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-06.md:63`).
- **The no-automatic-identity-inference policy is explicit and non-negotiable**, per the issue's own closing line. This matches `resolveCrossCenterIds()`'s own D5 design (`docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md` §2E/§3): identity is established *only* by an explicit, curator-supplied `mapping` table, never inferred from matching id strings or marker genotypes. Nothing in this design proposes any inference mechanism.
- **A soft design-reuse pairing exists with issue #150** (Tier 3, policy-gated, not yet greenlit): "#149 and #150 both need a 'confirm + export with provenance' UI pattern; whichever ships first should design it reusably" (`GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md:104-106`). This document's D7/D8 (confirmation gate, export-artifact shape) are written generically enough to be reusable, but designing #150 itself is explicitly out of scope here.

### 1.3 What this session's research confirmed

- **No `showModal()`/`modalDialog()` usage exists anywhere in `R/`** (`grep -rln "modalDialog\|showModal" R/` → zero hits, re-confirmed independently by this session's own adversarial review pass) — the sequencing audit's prediction that this would be "the app's first... confirmation gate" holds exactly.
- **No two-independent-pedigree-upload precedent exists in any module.** Every existing module either consumes the single app-wide `shared$currentPedigree` (post-`modInput` QC) or takes its own single/paired *genotype* file(s) (`modMarkerGenetics`'s Kinship/Heterozygosity/Parentage-Exclusion tabs take one genotype file; its Cross-Center tab takes two genotype files, not two pedigrees).
- **`resolveCrossCenterIds()`'s four internal validation blocks map 1:1 onto the issue's four named checks** (§2.2) — strong forcing evidence for D2's extraction design, not a coincidence to design around.
- **No "provenance" or audit-trail helper of any kind exists in the codebase today** (`grep -rni provenance R/` → zero hits) — this is genuinely new vocabulary for the package's implementation, though the *word* already appears in four prior audit documents describing exactly this gap (§1.1-1.2 above), so the concept is well-anticipated even though no code exists yet.
- **No `actionButton`-gated "preview, then separately confirm" two-phase flow exists anywhere.** Every existing action button (`modInput`'s "Read and Check Pedigree", `modGeneticValue`'s "Run Analysis", `modBreedingGroups`'s "Form Groups") computes and immediately makes its result available in one step. This design's D7 confirmation gate is a genuinely new interaction shape for this app, not a variant of an existing one.
- **A same-session adversarial review pass (two independent agents — correctness-vs-source, and completeness/house-style — both against live source, not summaries) found one significant, previously-unaddressed technical gap** (`resolveCrossCenterIds()`'s merge step silently drops every non-`id`/`sire`/`dam` column for merged individuals, §2.12) **and one significant design-consistency gap** (the extracted conflict-check helper's row lookup depends on a rewrite step D2's original text never made explicit, §3 D2) — both incorporated into this revision, not left as caveats. See §10 Provenance for the full reconciliation.

---

## 2. Evidence-based inventory

### 2.1 `resolveCrossCenterIds()` — verified in full, the algorithm this workflow wraps

`R/resolveCrossCenterIds.R:92-193` (read in full). Signature: `resolveCrossCenterIds(pedA, pedB, mapping)`. Behavior, in the exact order it runs:

1. **Structural check** (both pedigrees): `id`/`sire`/`dam` columns present, else `stop()` immediately (`:93-103`).
2. **Structural check** (mapping): `idA`/`idB` columns present, else `stop()` (`:105-111`).
3. **Uniqueness check:** `anyDuplicated(mapping$idA) > 0 || anyDuplicated(mapping$idB) > 0` → `stop("...duplicate...")` (`:113-121`).
4. **Existence check:** every `mapping$idA` value must exist in `pedA$id`; every `mapping$idB` value must exist in `pedB$id` → `stop("...idA...")` / `stop("...idB...")` (`:123-138`).
5. **Collision check:** any id present in both `pedA$id` and `pedB$id` that is *not* named in `mapping` → `stop("...not declared...")` (`:140-151`). This check is pure `setdiff`/`intersect` arithmetic on character vectors — it cannot crash even against not-yet-validated data (verified empirically this session; see Dragon #2's corrected framing).
6. **Rewrite:** every mapped `pedB` id (its own row and any `sire`/`dam` pointer to it) is translated to its canonical `idA` value via a `translate` lookup vector (`:153-163`). This step is pure data preparation — no `stop()` anywhere in it.
7. **Per-pair conflict check + merge, inside one `lapply` over `mapping$idA`:** for each mapped pair, `rowA`/`rowB` are looked up **by the canonical `idA` value on both sides** (`rowB <- pedB[pedB$id == idA, ...]` — this only resolves correctly *because* step 6's rewrite already ran); `pickParent("sire")`/`pickParent("dam")` — a closure defined *inside* `resolveCrossCenterIds()` (`:169-180`) — returns the non-`NA` side's value, or `stop("...conflicting...")` if both sides are non-`NA` and different (`:172-178`). This is the one check that is **not** an upfront block — it fires lazily, per mapped pair, during merge-row construction, and it is the only check whose correctness depends on step 6 having already run (Dragon #3).
8. **Assemble:** unmapped rows from each side plus the merged rows, column-unioned via `bindPedigreeRows()` (`:17-33`, also in this file) (`:189-192`). **The merged rows built in step 7 carry only `id`/`sire`/`dam`** (`:182-185`) — no other column from `rowA`/`rowB` is copied through, even when both sides agree on a value (e.g. `sex`). `bindPedigreeRows()` itself does correct column-union/`NA`-fill on whatever it is given; the impoverishment happens upstream, in step 7's row construction. See §2.12 for the empirical confirmation and Dragon #1 for its consequence once this output is exported to non-programmer curators.

**All 7 `test_that()` blocks in `tests/testthat/test_resolveCrossCenterIds.R` must keep passing unmodified**, but only 5 of them assert `stop()`-message substrings (`expect_error()`); the other 2 assert positive merge/kinship values with no error substring at all (§2.2 below has the full breakdown). Any refactor must preserve every substring verbatim *and* the two positive-assertion blocks' exact output.

### 2.2 The issue's four named checks map 1:1 onto `resolveCrossCenterIds()`'s existing checks

| Issue's own wording | `resolveCrossCenterIds()` location | Today's failure mode |
|---|---|---|
| "ID existence" | §2.1 step 4 | `stop()`, first offending side only |
| "uniqueness" | §2.1 step 3 | `stop()`, whichever of idA/idB is checked first |
| "collisions" | §2.1 step 5 | `stop()`, only once existence/uniqueness are already clean |
| "parent conflicts" | §2.1 step 7 | `stop()` on the *first* conflicting pair/field found, mid-loop |

This 1:1 mapping is direct evidence that no new validation *logic* is needed — only a non-fail-fast presentation of logic that already exists and is already tested (D2).

**Exact test inventory** (re-verified directly against `tests/testthat/test_resolveCrossCenterIds.R`, not assumed): 7 `test_that()` blocks total. 2 assert positive output (`"collapses the transferred animal onto its real parents"`, `"produces correct, non-zero cross-center kinship"` — no `expect_error()` at all). 5 assert errors via 8 total `expect_error()` calls across 6 distinct substrings: `"idA"`, `"idB"` (×2, once for missing-mapping-reference and once for missing-required-column), `"duplicate"`, `"conflicting"`, `"not declared"`, `"dam"` (×2). A golden-master test for D2 must additionally pin the two positive-assertion blocks' exact output (`identical()`-level), not just re-verify the 6 substrings still trigger.

### 2.3 No `modalDialog()`/`showModal()` precedent anywhere in `R/`

Confirmed by `grep -rln "modalDialog\|showModal" R/` (zero hits) and by a full `grep -rniln confirm R/` sweep — every hit (`R/appServer.R`, `R/checkKinshipOverrides.R`, `R/checkTwinRelations.R`, `R/data.R`, `R/makePedigreeDiagramData.R`, `R/modPedigree.R`, `R/resolveCrossCenterIds.R` itself) is prose ("curator-confirmed") or a variable/parameter name, never a UI confirmation control. Re-confirmed independently by this session's own adversarial review.

### 2.4 The established file-upload → validate → preview shape: `modInput.R`

`R/modInput.R:51-237` (UI) and `:239-` (server, read in full). One `actionButton(ns("getData"), "Read and Check Pedigree")` triggers a QC pass whose results are shown across four result tabs (QC Summary / Errors / Warnings / Cleaned Data — a 5th, "Input Format," is static documentation, not a result tab), each error/warning/cleaned tab backed by its own `downloadButton` (`downloadErrors`/`downloadWarnings`/`downloadCleaned`, `:652-672`, each a plain `write.csv(..., file, row.names = FALSE)`). Downstream modules consume `cleanedStudbook()` once `isReady` is `TRUE` (`nrow(qcResults()$errors) == 0L && !is.null(qcResults()$cleaned)`) — there is **no explicit second "confirm" click**; review happens by the user looking at the QC Summary/Errors tabs before navigating elsewhere. This is the closest existing analog for "preview," but it does not have the issue's explicitly-requested confirmation gate (§1.3's last bullet).

### 2.5 The existing sidecar-file validators are fail-fast, not collect-all

`R/checkKinshipOverrides.R` (read in full) and `R/checkTwinRelations.R` both `stop()` on the *first* structural or domain problem found — the same fail-fast shape `resolveCrossCenterIds()` itself uses today, **not** the "show every problem at once" shape the issue explicitly asks for. Citing this precedent as a template for #149 would reproduce the exact ergonomics gap the issue exists to fix.

### 2.6 The actual house precedent for "show all problems at once" — a single mode-switch, not a fixed structural/domain split

`R/qcStudbook.R`'s own `reportErrors` parameter (roxygen `:57-64`, read in full): "if `TRUE` will scan **the entire file** and report back changes made to input and errors in **a list of list where each sublist is a type of change or error found**." Tracing the actual mechanism (`R/checkRequiredCols.R:33-52`, called from `qcStudbook()`) shows this is **one boolean gating both structural and domain checks identically**, not a fixed split where structural checks always `stop()` and domain checks always collect: with `reportErrors = TRUE`, even a *missing required column* (a structural problem) is collected into the returned error list rather than raising; with `reportErrors = FALSE` (the default), even a *domain* problem (e.g. invalid id characters) `stop()`s. This is the real house precedent for "show all problems at once" as a concept, but it is a **global all-stop-or-all-collect toggle**, not a template for the finer-grained, always-structural-stops/always-domain-collects split this document's own D2 proposes. §3 D2 explicitly rejects mirroring this single-flag mechanism for `resolveCrossCenterIds()` itself (Option C, §8/§11) precisely because it would couple an already-shipped function's public contract to a UI-only concern — `checkGenotypeFile()`'s own wording ("expected columns and legal domains," `R/checkGenotypeFile.R:7`) is cited only for its structural-vs-domain *vocabulary*, not as evidence that `qcStudbook()` already implements the specific two-tier split D2 proposes.

### 2.7 The established export convention: one `downloadButton` per artifact

Confirmed across the 8 of 10 non-trivial modules that export anything at all (`modGeneticValue.R`, `modBreedingGroups.R`, `modORIPReporting.R`, `modInput.R`, `modPotentialParents.R`, `modPedigree.R`, `modSummaryStats.R`, `modPyramid.R`): every exportable table or plot gets its own `downloadButton` + `downloadHandler(filename=, content=function(file) write.csv(...))` pair. Two non-trivial modules (`modGeneticDiversity.R`, `modMarkerGenetics.R`) have no export capability at all today (the 11th module, `modGvAndBgDesc`, is the documented stateless/informational exception). No module bundles multiple artifacts into one zip/multi-sheet download via Shiny — though the package does have an unrelated, non-Shiny multi-sheet-workbook helper (`R/create_wkbk.R`, used only by `makeExamplePedigreeFile.R`/`saveDataframesAsFiles.R`), confirming "no bundled-export mechanism" is a *Shiny-module* convention, not a package-wide limitation. §3 D8 follows the one-artifact-per-button convention rather than inventing a bundled-export mechanism.

### 2.8 `modMarkerGenetics.R`'s existing "Cross-Center" tab is a different concept

`R/modMarkerGenetics.R:35-37,50-51,239-325` (read in full). Its "Cross-Center" tab takes a **second genotype file** (`fileInput(ns("genotypeFileB"), ...)`) and computes `markerFst()` between two already-separate populations' marker data — it never references `pedigree`, `id`, `sire`, or `dam` at any point and has no concept of merging two pedigrees into one. Confirmed structurally distinct from what #149 asks for: reusing this tab's name or UI would conflate "between-population genetic differentiation" with "identity-linkage pedigree merge," two unrelated capabilities that happen to share the word "cross-center." Not reused, renamed, or extended (D1).

### 2.9 Module-contract requirements for a new module

`docs/architecture/module-contract.md` (read in full): `modXUI(id)` → a `tagList`; `modXServer(id, <named args>)` → a **named list of reactives**, mechanically checked by `tests/testthat/test_moduleContract.R` for every `mod*Server` except the one documented `modGvAndBgDescServer` exception (informational, stateless). Rule 4: "Return only what a consumer reads... 'Consumer' includes the test suite, not only `appServer`" — directly relevant to D9's return-vocabulary decision, since this module has no other module as a consumer (D3). Rule 3 names `pedigree`/`errors` as canonical vocabulary, but the reference implementation `modInput` itself already returns `errorLst`, not the literal word `errors` — in-codebase precedent that a more specific name is acceptable when it is clearer (D9 follows this).

### 2.10 `appUI.R`/`appServer.R` wiring — confirming a *tab within a module* can be fully self-contained

`R/appUI.R:244-248` / `R/appServer.R:430-439`: `modMarkerGeneticsServer` as a whole is wired with `kinshipMatrix` and `pedigree` (it is **not** a fully `shared$`-free module) — but its own Cross-Center tab specifically (§2.8) uses neither, since both genotype files are its own `fileInput`s. This is the precise, narrower claim D3/D4 rely on: a self-contained *feature* needs no new `shared$...` plumbing, not that every existing module avoids `shared$` coupling entirely.

### 2.11 `getVersion(date = FALSE)` — an existing, reusable provenance-stamp helper

`R/getVersion.R:15-24`: `getVersion(date = FALSE)` returns just the package version string (no `sessioninfo::package_info()` call, so it is fast to call at every export). Reused directly for D8's provenance artifact rather than reimplemented.

### 2.12 `resolveCrossCenterIds()`'s merge step silently drops every non-`id`/`sire`/`dam` column for merged individuals

Discovered by this session's own adversarial correctness review and independently verified: `resolveCrossCenterIds()`'s merge-row construction (`:182-185`) builds `data.frame(id = idA, sire = pickParent("sire"), dam = pickParent("dam"), ...)` — **only these three columns**, even when `rowA`/`rowB` carry other columns (e.g. `sex`) that both sides agree on. Empirically reproduced this session: a `pedA`/`pedB` pair both recording `sex = "M"` for the same physical animal (mapped `T1`/`X9`) produces a merged `T1` row with `sex = NA` — the agreeing value is silently discarded. `bindPedigreeRows()` then `NA`-fills this already-impoverished row against whatever extra columns the *unmapped* rows happen to carry; it is not itself the source of the problem. This is existing, already-shipped, already-tested behavior (no existing test exercises a non-`id`/`sire`/`dam` column, so nothing currently catches it) — but it has never been surfaced to a non-programmer curator before, since `resolveCrossCenterIds()` has been script-callable only. Exporting its output directly as a "Merged Pedigree" CSV (D8) is the first time this limitation becomes user-facing. See Dragon #1 and D10.

---

## 3. Design decisions

Ten decisions, D1-D10. Each states whether it is forced by the evidence above or a genuine judgment call; §11 collects the judgment calls into a ratification round.

**D1 — New, dedicated module `R/modCrossCenterIdentity.R`, its own top-level navbar tab. Forced by concept-distinctness (§2.8) and the module-contract's single-responsibility framing.**

Applying the Deletion Test (`ARCHITECTURE_WORKSTREAM.md` §Refactor Heuristics) to the alternative "fold into `modMarkerGenetics`'s Cross-Center tab": deleting a bolted-on pedigree-merge feature from that tab would disperse its complexity right back into a module whose entire existing vocabulary (`crossCenterGenotypeB`, `crossCenterTable`, a `markerFst()`-shaped reactive graph) is genotype-shaped, not pedigree-shaped — the two concepts would sit side-by-side under one confusing tab name, not integrate into one deeper abstraction. A new module is the "replace with a focused module that did not exist" branch of the Deletion Test.

**D2 — Extract `resolveCrossCenterIds()`'s four checks into shared, non-`stop()`ing internal helpers; add a new exported `checkCrossCenterMapping()` that calls the same helpers and collects every domain problem. Judgment call on the extraction mechanism specifically — ratify (§11 Q1). The *need* for a collect-all validator is forced (§1.1/§2.2/§2.6).**

Two-tier structure within the domain checks, matching §2.6's clarified precedent in spirit (a collect-all mode exists elsewhere in this house style) but implemented more granularly than `qcStudbook()`'s single flag, since existence/uniqueness and collision/conflict have a real data dependency between them (below):

- **Structural tier** (must be clean before anything else is even computable): `id`/`sire`/`dam` on both pedigrees, `idA`/`idB` on the mapping — `checkCrossCenterMapping()` `stop()`s here immediately, exactly like every existing `checkXxx()` function, since domain checks below are meaningless against a table missing its own columns.
- **Domain tier A** (existence, uniqueness): computed first; if either has hits, `checkCrossCenterMapping()` returns **only** those (a "fix these first" tier) rather than also attempting collision/conflict checks against mapped ids that may not even resolve to a real row.
- **Domain tier B** (collision, conflict): computed only once tier A is clean. Collision is a pure `setdiff`/`intersect` computation — safe regardless of row-lookup concerns (§2.1 step 5, confirmed empirically not to crash even against bad data, so it *could* run alongside tier A, but is grouped with conflict here for a simpler two-tier mental model, not a technical necessity). **Conflict requires the same `pedB` id-rewrite step `resolveCrossCenterIds()` already performs (§2.1 step 6) before any per-pair row lookup is meaningful** — confirmed empirically this session: looking up `pedB[pedB$id == idA, ]` *before* the rewrite (i.e., against `pedB` still keyed by its original `idB` values) silently returns an all-`NA` row, not an error. If `checkCrossCenterMapping()` ran the extracted conflict-check helper against un-rewritten `pedB`, it would **silently report zero conflicts even when real conflicts exist** — a false negative that defeats the validator's entire purpose. `checkCrossCenterMapping()` must therefore perform the identical rewrite (extracted as its own tiny, pure, already-`stop()`-free `.rewriteCrossCenterIds(pedB, mapping)` helper, reused as-is by both functions) before running the conflict check across **every** mapped pair and **both** fields, collecting every conflict found rather than stopping at the first (Dragon #2 restates this precisely for the implementing session).

Each of the four checks is extracted from `resolveCrossCenterIds()`'s current inline blocks into a small top-level `.checkXxx()` helper returning a **data.frame of problems** (`type`, `ids`, `message`; zero rows if none found) instead of calling `stop()` directly; `resolveCrossCenterIds()` itself is rewritten to call each helper in its **current exact order** and `stop()`s immediately on the first non-empty result — preserving today's behavior, message text, and all 7 existing test blocks byte-for-byte (proven via a new golden-master test, §5 Slice 1, matching the S496 `.markerOppositeHomozygoteCount()` extraction precedent).

The per-pair conflict check (`resolveCrossCenterIds()`'s `pickParent()` closure, §2.1 step 7) is extracted to a top-level `.pickCrossCenterParent(rowA, rowB, field)` returning `list(value=, source=, conflict=<logical>)` — **`source`** (`"A"`, `"B"`, `"both"`, or `NA`) is new relative to the original closure's plain return value, added specifically because D6's lineage-change preview and D8's provenance both need to know *which side* contributed each resolved value, and neither is derivable from a bare value/conflict pair. `resolveCrossCenterIds()`'s own `lapply` uses only `$value`/`$conflict` (ignoring `$source`), stopping on the first `conflict = TRUE` exactly as today (preserving "first conflicting pair wins" ordering, and keeping its output data.frame exactly `id`/`sire`/`dam`-shaped, unaffected by this addition); `checkCrossCenterMapping()` and D6's preview builder use all three fields, running the helper across every mapped pair and field.

**D3 — Scope boundary: a standalone review-and-export tool. The merged pedigree is a downloadable artifact, not fed into `shared$currentPedigree` or any other module's reactive graph this scope. Judgment call — ratify (§11 Q2).**

A curator who wants the merged result to drive downstream genetic-value/breeding-group analysis re-uploads the exported "Merged Pedigree" CSV through `modInput`'s existing "Pedigree(s) file only" path — a real, already-shipped, already-tested route, not a hypothetical one. This keeps blast radius to genuinely new files (§2.10 confirms a self-contained *feature* needs no new `shared$...` plumbing) and matches this batch's own established "report-only, no write-back" precedent (issue #147 D4, issue #130 D6 for `resolveCrossCenterIds()` itself).

**D4 — Two independent raw pedigree file uploads plus one mapping-table file upload; none coupled to `shared$currentPedigree`. Forced by D3.**

`fileInput(ns("pedAFile"), ...)`, `fileInput(ns("pedBFile"), ...)` (each requiring `id`/`sire`/`dam` columns, matching `resolveCrossCenterIds()`'s own structural requirement — reusing `read.csv()`, not a new parser), `fileInput(ns("mappingFile"), ...)` (requiring `idA`/`idB` columns), mirroring the sidecar-file upload convention already used for `kinshipOverrides`/`twinRelations` (help text stating the required column names directly in the UI, matching those precedents).

**D5 — Validation tab renders every issue `checkCrossCenterMapping()` finds, before any preview is attempted; the Preview/Confirm/Export tabs stay locked with a "resolve N issue(s) above" message while any issue remains. Forced once D2 is chosen.**

**D6 — Preview tab: once validation is clean, call `resolveCrossCenterIds()` (now guaranteed not to `stop()`) to compute the actual merged pedigree, and render a per-mapped-pair "lineage change" table** (`idA`, `idB`, pedA's sire/dam, pedB's sire/dam, the resolved sire/dam, and — via D2's new `source` field — which side each resolved value came from) **plus summary counts** (mapped-pair count, unmapped-pedA-only count, unmapped-pedB-only count, final merged row count). Forced by the issue's own text ("preview proposed collapses and lineage changes") once D2's validation-first gate and `source`-carrying return shape exist.

Note for reviewers: the *actual* merge is computed to build this preview, before the D7 confirmation click. This is intentional, not a gap in the confirmation gate — "preview, then confirm" is two sequential steps by design (see the merge before deciding whether to accept it), and D7's gate protects **export access**, not computation.

**D7 — Confirmation gate: `shiny::modalDialog()` (base shiny, no new dependency), showing the D6 summary counts, with "Confirm Merge" / "Cancel" buttons. Confirming sets a `reactiveVal` that unlocks the Export tab. Forced/strongly recommended — not put to a full ratification vote (demoted from an earlier draft's Q3; see §8 for the considered alternative).**

Because D3 rules out any write-back/mutation semantics, there is nothing for "confirm" to gate except access to the exports — matching this app's fully stateless-between-sessions design (nothing persists once the browser tab closes regardless). `modalDialog()` is the standard, idiomatic Shiny mechanism for exactly this kind of gate, needs no new dependency, and is the mechanism the sequencing audit itself already anticipated ("the app's first `showModal()`/`modalDialog()` confirmation gate," this document's own header Origin line) — treated here as low-controversy enough not to need a full ratification round, unlike D2/D3/D8/D10, whose alternatives carry real, materially different consequences.

**D8 — Five export artifacts, one `downloadButton` each (matching §2.7's established one-artifact-per-button convention): Merged Pedigree, Mapping, Validation Results, Merge Summary, Provenance. Judgment call on including "Merged Pedigree" as an explicit 5th artifact — ratify (§11 Q3). The other four are forced directly by the issue's own list.**

1. **Merged Pedigree** — the actual `resolveCrossCenterIds()` output (`write.csv(mergedPedigree(), file, row.names = FALSE)`), subject to §2.12's known column-coverage limitation for merged rows unless D10 is ratified to fix it. *Not named verbatim in the issue's own sentence*, but without it the tool produces no usable output — see §11 Q3.
2. **Mapping** — an echo of the confirmed `idA`/`idB` table, so the export set is self-documenting even without the original upload.
3. **Validation Results** — the full `checkCrossCenterMapping()` output (empty, since Export is only reachable once clean — still a useful audit artifact: "here is proof no problems were found").
4. **Merge Summary** — the D6 lineage-change table + counts, as a downloadable CSV (the same reactive backing both the Preview tab's `DT::renderDT()` and this download, matching `modInput.R`'s Cleaned-Data-tab-plus-download precedent, §2.4).
5. **Provenance** — a new internal helper, `.buildCrossCenterMergeProvenance()` (lives in `R/modCrossCenterIdentity.R`, module-internal glue, `@noRd`), producing a small data.frame: `timestamp` (`Sys.time()`), `pedAFileName`/`pedBFileName`/`mappingFileName` (from each `fileInput`'s own `$name` field — a user-supplied, unvalidated label; used for display only, never for identity/dedup logic, Dragon #5), `packageVersion` (`getVersion(date = FALSE)`, §2.11), `nPedA`/`nPedB`/`nMapped`/`nMerged`, and per-merged-individual `sireSource`/`damSource` (from D2's new `source` field — `"A"`/`"B"`/`"both"`).

**D9 — Module name `modCrossCenterIdentity`; new exported validator name `checkCrossCenterMapping()`, matching the `checkKinshipOverrides()`/`checkTwinRelations()`/`checkGenotypeFile()` naming family (§2.5). Server returns `list(mergedPedigree, issues, confirmed)` reactives — satisfying module-contract rule 2 and rule 4's "test suite is a consumer" clarification (§2.9) even though no other module consumes this one (D3), and following `modInput`'s own precedent (§2.9) that a clearer name can beat the literal canonical vocabulary. Forced once D1/D3 are chosen.**

**D10 — Should `resolveCrossCenterIds()`'s merge step also be fixed, in the same slice that already touches its internals, to stop silently dropping non-`id`/`sire`/`dam` columns for merged individuals (§2.12)? Judgment call — ratify (§11 Q4).**

This is discovered, not designed-for, and is orthogonal to D2 (D2 is about the *validation* mechanism being byte-identical; D10 is about the *merge* step's column coverage, a separate part of the same function). If ratified, the fix generalizes the existing `pickParent()`-style "prefer non-`NA`, error on differing non-`NA` values" resolution — via the same D2-introduced `.pickCrossCenterParent()` helper — to **every** column present on both `rowA` and `rowB`, not just `sire`/`dam`. This is an explicit, called-out, additive behavior change to `resolveCrossCenterIds()`'s output (previously-blank columns for merged rows may now be populated) — its own new test asserts the richer output directly; it is **not** folded into D2's "zero behavior change" golden-master claim, which continues to describe only the validation-mechanism refactor. Not fixing this leaves a silent, curator-facing data-loss trap the very first time this already-shipped function's output is surfaced to a non-programmer audience (§2.12, Dragon #1).

---

## 4. Interface catalog

| Interface | Input | Output | Error contract | Consumers |
|---|---|---|---|---|
| `checkCrossCenterMapping(pedA, pedB, mapping)` | Two pedigree data.frames (`id`/`sire`/`dam` + optionally other columns) and one mapping data.frame (`idA`/`idB`) | A `data.frame` of every domain problem found: `type` (`"existence"`/`"uniqueness"`/`"collision"`/`"conflict"`), `ids` (the offending id(s)), `message` (human-readable). Zero rows means clean. | `stop()`s only on a structural problem (missing required columns on any of the three inputs) — matches every existing `checkXxx()` convention (§2.5/§2.6). Never `stop()`s on a domain problem; those are rows in the returned data.frame. | `modCrossCenterIdentityServer` (Slice 2); the test suite (Slice 1) |
| `modCrossCenterIdentityServer(id)` | No named data args (self-contained per D3/D4 — its own 3 `fileInput`s are read internally, not passed as reactive parameters) | `list(mergedPedigree, issues, confirmed)`, each a `reactive()` per module-contract rule 2 | Upstream absence (`req()`-gated, e.g. before any file is uploaded); malformed uploads surface via `issues` (never silently swallowed), matching module-contract rule 5 | The test suite only, this scope (D3/D9) |

---

## 5. Implementation plan — vertical slices (one session each)

### Slice 1 — Validation core (R-function level only, no UI)

**Touches:** `R/resolveCrossCenterIds.R` (internal extraction, D2; additive column-coverage fix if D10 is ratified), `R/checkCrossCenterMapping.R` (new), `tests/testthat/test_resolveCrossCenterIds.R` (golden-master regression test added; all 7 existing test blocks must pass unmodified; a new test for D10 if ratified), `tests/testthat/test_checkCrossCenterMapping.R` (new, including a deliberate conflict-detection test proving the D2 rewrite-before-lookup requirement actually works — Dragon #2), `NEWS.Rmd` (new exported function), `_pkgdown.yml` (reference-coverage entry).

**What DONE looks like:** `checkCrossCenterMapping(pedA, pedB, mapping)` exists, exported, documented, returns a `data.frame` of every domain problem found (zero rows when clean) per D2's two-tier structure, and is proven — via a fixture with both an existence problem and a would-be collision, and a separate fixture with a genuine parent conflict — to report every real issue rather than silently missing any; `resolveCrossCenterIds()`'s exported behavior is byte-identical to today for its validation/error-detection paths (golden-master test: same inputs → same output or same error, `identical()`) and all 7 existing test blocks pass with zero modification to their assertions; if D10 is ratified, `resolveCrossCenterIds()`'s merge output additionally carries through agreeing non-`id`/`sire`/`dam` columns, verified by its own new, explicitly-labeled test.

**Verification:** `devtools::test_file()` on both targeted test files; full clean regression read (0 failed/0 error, matching S502's baseline); `lintr::lint_package()` on touched files; `devtools::check()` unchanged from baseline.

**Session boundary:** this phase is one session. Close out when done.

### Slice 2 — Full module: UI, confirm gate, exports, documentation

**Touches:** `R/modCrossCenterIdentity.R` (new — UI: 3 file inputs + validation table + preview table + `modalDialog()` confirm + 5 download buttons; server: reactives per D9; internal `.buildCrossCenterMergeProvenance()` helper), `R/appUI.R` (new top-level tab), `R/appServer.R` (self-contained wiring, no `shared$...` args needed per D3/§2.10), `tests/testthat/test_modCrossCenterIdentity.R` (new), `tests/testthat/test_moduleContract.R` (register the new module), `_pkgdown.yml` (reference-coverage entries for `modCrossCenterIdentityUI`/`modCrossCenterIdentityServer`), `NEWS.Rmd` (new Shiny feature entry), `vignettes/articles/colony-manager-guide.qmd` and/or a new `vignettes/manual_components/*.Rmd` component.

**What DONE looks like:** the full workflow works end-to-end in the running app — upload two pedigree files + a mapping file, see every validation issue at once (or a locked Preview/Export state until resolved — including a fixture deliberately exercising *multiple simultaneous* issues, not just the happy path), see the lineage-change preview once clean, confirm `modalDialog()`'s interaction actually renders correctly under this app's bslib/Bootstrap theme (Dragon #6), confirm the Validation/Preview `DT::renderDT()` tables' actual rendered cell text for `NA` `sire`/`dam` values is visually verified, not assumed (Dragon #7), click through the confirmation, and download all 5 artifacts — verified live, not only via `testServer()`.

**Verification:** full clean regression read; `lintr::lint_package()`; `devtools::check()` unchanged from baseline; a live `shinytest2`/`chromote` smoke test exercising the actual upload → validate → preview → confirm → export sequence against real fixture files (reusing `resolveCrossCenterIds()`'s own existing fixture shape, §2.1/§2.2, as a starting point — a real P1/P2/T1/S1 + X9/Q1/O1 pair of CSVs, extended with at least one deliberate conflict case); NEWS.Rmd, `_pkgdown.yml`, and tutorial/article checklists all satisfied same-session; citation checklist (#120) explicitly dispositioned N/A in this slice's own close-out (§9).

**Session boundary:** this phase is one session. Close out when done.

---

## 6. Impact analysis

**Blast radius is small and mostly additive.** Slice 1 touches one existing file (`R/resolveCrossCenterIds.R`) with a proven-behavior-preserving internal refactor for validation (plus an explicitly-flagged, separately-tested additive change if D10 is ratified); every other file in both slices is new. Slice 2's `appUI.R`/`appServer.R` touches are additive (one new `tabPanel`, one new self-contained server call) — no existing tab, reactive, or module signature changes.

**Performance:** no concern identified. `resolveCrossCenterIds()`'s existing `setdiff`/`intersect`/`lapply` operations are all vectorized and already handle the fixture sizes this workflow targets (curator-driven review of a handful to low hundreds of cross-center transfers at a time, not colony-scale bulk merges); nothing in this design changes its algorithmic complexity, and D10's generalization (checking more columns per pair) adds only a constant factor per mapped pair, not a new order of growth.

**Backward compatibility:** `resolveCrossCenterIds()`'s exported signature and all 7 existing test blocks are explicitly required to be unaffected for the validation/error-detection paths — this is a hard constraint (D2), not a goal. D10, if ratified, is an explicitly-flagged additive change to the merge output's column coverage (previously-`NA` columns may now be populated for merged rows) — script callers relying on the current, narrower output shape should be able to tolerate additional populated columns without breaking, but this is worth stating plainly in `NEWS.Rmd` as a behavior note, not silently bundled into a "no behavior change" claim.

**Module-contract compliance:** the new module registers in `test_moduleContract.R`'s guard list (D9); `modCrossCenterIdentityUI` returns a `tagList`; `modCrossCenterIdentityServer` returns a named list of reactives.

**Close-out checklists triggered** (`CLAUDE.md`): NEWS.Rmd applies **twice** — Slice 1 (new exported function `checkCrossCenterMapping()`) and Slice 2 (new Shiny feature), matching #147's own two-slice treatment of the identical shape; tutorial/article checklist applies Slice 2 (the session the tab first becomes real and usable); `a2interactive.Rmd` — **applies, deferred** (not N/A): `checkCrossCenterMapping()` is a new exported, script-callable function shipping with zero UI in Slice 1, the exact shape the standing rule is written for (its own sibling functions `checkKinshipOverrides()`/`checkTwinRelations()` are themselves still-uncovered examples of this same deferred bucket) — flag it for the next dedicated `a2interactive.Rmd` documentation pass, not same-session; citation checklist (#120) — N/A, explicitly dispositioned in §9; lint on touched files, each slice; `gh issue close 149` when Slice 2 ships; a dated `CHANGELOG.md` ledger entry for each slice's own close-out; `_pkgdown.yml` reference-coverage entries apply **twice** — Slice 1 (`checkCrossCenterMapping()`) and Slice 2 (`modCrossCenterIdentityUI`/`modCrossCenterIdentityServer`).

---

## 7. Here be dragons

1. **(Highest severity) `resolveCrossCenterIds()`'s merge step silently drops every non-`id`/`sire`/`dam` column for merged individuals (§2.12), and D8 is about to export that output directly to non-programmer curators for the first time.** A curator who uploads two pedigrees with agreeing `sex`/`birth`/`status` data for a transferred animal, confirms the merge, and downloads "Merged Pedigree" will see those fields blank for every merged individual — easily misread as a bug in the *new* tool rather than a pre-existing limitation of the wrapped function. §11 Q4 (D10) asks whether to fix this in Slice 1; if the owner declines, the Slice 2 UI/export must carry an explicit, prominent caveat (not just a footnote) that only `id`/`sire`/`dam` survive merging for now.

2. **The two-tier domain-check ordering inside `checkCrossCenterMapping()` (existence+uniqueness before collision+conflict, §3 D2) is load-bearing for the conflict check specifically, not cosmetic.** Confirmed empirically this session: looking up a merged pair's row by canonical `idA` *before* `pedB`'s ids have been rewritten (§2.1 step 6) silently returns an all-`NA` row, which would make `checkCrossCenterMapping()` report **zero conflicts even when real ones exist** — a false negative, not a crash (the collision check itself, being pure `setdiff`/`intersect`, cannot crash or misbehave this way; only the conflict check's row lookup is at risk). The implementing session must write a test that *injects* a real conflict and confirms `checkCrossCenterMapping()` actually reports it — not merely that no error is thrown.

3. **`pickParent()`'s extraction to `.pickCrossCenterParent()` changes where a well-tested closure's variables come from** (today it closes over `rowA`/`rowB`/`idA` from its enclosing `lapply` iteration; extracted, these become explicit parameters, and the new `source` field is genuinely new computed output, not a passthrough). Verify the extracted version produces `identical()` `value`/`conflict` output against the original for every case in the existing fixture, and manually verify `source` is correct for each of the "A only," "B only," and "both agree" cases before trusting D6/D8's consumption of it.

4. **The Preview tab computing the real merge before the D7 confirm click is a deliberate design choice (§3 D6 note), not an oversight** — a future reviewer unfamiliar with this document might mistake it for a gate that does nothing. State this explicitly in the implementing session's own code comments, not just in this document.

5. **`fileInput`'s `$name` field (used for D8's provenance filenames) is user-supplied text, not a validated identifier** — do not use it for anything except a human-readable provenance label; never treat it as authoritative for identity/dedup logic (a curator could rename a file to anything before upload).

6. **`shiny::modalDialog()` (D7) is this app's first-ever use of the function**, and it will render inside a `navbarPage()` themed with `bslib::bs_theme()` (`R/appUI.R`) — a combination this app has never exercised for a modal before. Nothing about this interaction has been visually verified; Slice 2's live `shinytest2` smoke test must confirm it actually renders and behaves correctly under this app's real theme before the confirmation gate ships, not just that the reactive gate logic is correct in a `testServer()` sense.

7. **The Validation/Preview `DT::renderDT()` tables (D5/D6) will routinely contain `NA` `sire`/`dam` values** (any founder in either uploaded pedigree). `PROJECT_LEARNINGS.md` Learning 501 (S502, the session immediately preceding this one) found that this exact rendering pipeline has at least one class of "special R value → silently blank cell, no text trace" behavior (`-Inf` serializing to JSON `null`, rendering blank with no way to distinguish it from a genuinely empty cell via `grepl()` on rendered HTML). Slice 2 must verify directly (e.g. via `app$get_js()` cell-text reads, per Learning 501's own corrective technique) how `NA` actually renders in these specific new tables — a table whose entire purpose is "show every problem clearly" must not silently confuse "blank because `NA`" with "blank because of a rendering quirk."

8. **Slice 2's live fixture needs deliberate `sire`/`dam`-conflict and collision cases, not just the happy path**, to visually verify the Validation tab actually surfaces multiple simultaneous issues at once (the entire point of D2) — a fixture that only exercises the clean-merge path would not prove the "show all problems at once" ergonomics the issue asks for.

---

## 8. Alternatives considered

Summary table for the judgment-call decisions (each also appears inline in §3; not repeated there).

| Decision | Recommended | Rejected alternative(s) | Why rejected |
|---|---|---|---|
| D2 validation architecture | Extract shared helpers; `resolveCrossCenterIds()` stops on first, `checkCrossCenterMapping()` collects all | Independently duplicate the 4 checks in a new function | Logic-drift risk — the exact class of risk the S496 `.markerOppositeHomozygoteCount()` extraction was designed to avoid |
| D2 validation architecture | Extract shared helpers | Add a `mode = "collect"` parameter to `resolveCrossCenterIds()` itself | Couples an already-shipped, `@export`ed, v2.0.0-era function's public contract to a UI-only concern; expands its documented interface for no external-caller benefit |
| D3 scope boundary | Standalone review/export tool; re-upload via `modInput` to use downstream | Wire the merged pedigree into `shared$currentPedigree` / a new `modInput` pedigree source | Substantially larger blast radius (dependency-injection wiring, a second pedigree-source decision point) with no existing precedent; the issue's own text says "export," not "feed into"; a legitimate future follow-on issue, not a blocker here |
| D7 confirmation mechanism | `shiny::modalDialog()` | A checkbox ("I have reviewed the preview above") gating an `actionButton`, no modal at all | No new UI machinery to learn, but needs extra reactive bookkeeping for "has it ever been checked," and reads as a weaker, easier-to-rush-past gate than a genuine interstitial dialog — low-stakes enough this document treats it as forced rather than ratified |
| D8 export artifact set | 5 artifacts, including the Merged Pedigree CSV | Exactly the 4 artifacts the issue's sentence literally names | A tool that validates, previews, and lets the curator confirm a merge but never lets them download the merged data itself would not deliver the feature's core value |
| D10 merge column coverage | Fix now, in Slice 1, as an explicit additive change | Ship as-is; document the id/sire/dam-only limitation prominently; file a separate follow-up issue | Simpler, smaller Slice 1 diff, but ships a curator-facing silent data-loss trap on day one of this being user-visible for the first time |

**A note on question independence (per this session's own adversarial review):** Q3 (D8) and, to a lesser extent, Q4 (D10) both assume Q2 (D3) resolves to its recommended "standalone export tool" option — if the owner instead picks Q2's alternative (wiring the merge into `shared$currentPedigree`), the "must be exportable to be useful" argument for Q3 weakens (the merge is already usable in-app without a download) and Q4 becomes even more clearly load-bearing (the same column-loss would then also silently corrupt in-app downstream analysis, not just an exported file). Q4/D10 itself is orthogonal to Q2 either way — the column-loss defect exists regardless of whether the merge output is exported or fed downstream.

---

## 9. Close-out checklist mapping

1. **Citation checklist (issue #120)** — **N/A.** This workflow surfaces already-existing pedigree fields and new operational/audit metadata (validation issues, merge counts, provenance timestamps) — it introduces no new displayed genetic statistic or estimator. State this explicitly in Slice 2's own close-out, matching #133's more cautious "state explicitly" framing rather than a silent omission.
2. **Tutorial/article documentation checklist (Session 436)** — applies, Slice 2, same session: `vignettes/manual_components/*.Rmd` (a new component, since this is a genuinely new workflow shape, not an addition to an existing tab's narrative) and/or `vignettes/articles/colony-manager-guide.qmd`.
3. **`NEWS.Rmd` entry checklist (Session 448)** — applies **twice**: Slice 1 (new exported function `checkCrossCenterMapping()`) and Slice 2 (new Shiny feature/tab), current development-version section both times — matching #147's own two-slice treatment of this identical shape (script-only function first, UI second).
4. **`a2interactive.Rmd` script-callable-function checklist (Session 450/478)** — **applies, deferred (not same-session)**, per its own standing rule: `checkCrossCenterMapping()` is a new exported, script-callable function (Slice 1 ships it with zero UI). This is the exact shape the checklist is written for — its own already-exported siblings `checkKinshipOverrides()`/`checkTwinRelations()` are themselves still sitting in this same "applies, deferred, not yet covered" bucket, confirming this is not a "Shiny-UI-only feature" exemption. Flag for a future dedicated documentation pass, not either slice's own close-out.
5. **`_pkgdown.yml` reference-coverage checklist (Session 496)** — applies **twice**: Slice 1 (`checkCrossCenterMapping()`) and Slice 2 (`modCrossCenterIdentityUI`/`modCrossCenterIdentityServer` — every existing `mod*UI`/`mod*Server` pair is individually listed there today, confirmed by direct inspection).
6. **GitHub issue close-out checklist** — `gh issue close 149 --reason completed --comment "..."` citing the `CHANGELOG.md` entry and verification evidence, in the same session Slice 2 ships (matching the #131/#134/#135/#137/#139/#142/#143/#144 precedent).
7. **Lint close-out checklist** — `lintr::lint_package()` on touched files, each slice, before that slice's own close-out.
8. **`CHANGELOG.md` ledger-format resolution (Session 325)** — each slice's own close-out prepends a dated `### YYYY-MM-DD · [issue #149] ...` entry above `## Legacy history`.

---

## 10. Provenance

This document was produced primarily by direct source-and-documentation reading, not a multi-agent research `Workflow` (unlike #137/#147, whose subject matter needed external literature synthesis; #149's subject matter is entirely internal-codebase architecture, better served by direct reads), followed by a same-session adversarial verification pass:

1. GitHub issue #149's own body/comments/state, fetched via `gh issue view 149 --json title,body,comments,state,createdAt,labels` (zero comments, confirmed verbatim in §1.1).
2. `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` (read in full) and `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-06.md` (read in full) — the two documents establishing #149's priority, sequencing, and the "confirm + export with provenance" characterization quoted throughout §1.
3. Direct, full reads of `R/resolveCrossCenterIds.R`, `tests/testthat/test_resolveCrossCenterIds.R`, `R/modMarkerGenetics.R` (upload/tab structure), `R/modInput.R` (UI + server, the closest existing analog), `R/checkKinshipOverrides.R`, `R/checkGenotypeFile.R`/`R/checkRequiredCols.R` (roxygen plus the actual `reportErrors` branching, for the structural-vs-domain wording), `R/qcStudbook.R` (roxygen, for the collect-all precedent), `docs/architecture/module-contract.md`, `tests/testthat/test_moduleContract.R`, `R/appUI.R`/`R/appServer.R` (the `modMarkerGenetics` wiring section), `R/getVersion.R`.
4. Targeted `grep` sweeps confirming zero `modalDialog()`/`showModal()` usage, zero `provenance`-related code, and the exact set of modules using `downloadHandler`/`actionButton` across `R/`.
5. Two prior planning documents in the same "shape" family for house-style structure: `docs/planning/issue147-likelihood-parentage-assignment-plan.md` (S495) and `docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md` (S491), both read in full for section structure and ratification-round format.

**A same-session adversarial review pass** (two independent agents against live source, not against each other's output — one checking every factual/technical claim above against the actual current code, one checking structural completeness and house-style consistency against the #147/#137 precedents and `CLAUDE.md`'s close-out rules) found:

- **One significant, previously-unaddressed technical defect** (§2.12/Dragon #1: `resolveCrossCenterIds()`'s merge step drops non-`id`/`sire`/`dam` columns for merged rows), now incorporated as D10/§11 Q4.
- **One significant design-consistency gap** (D2's original text never specified that the extracted conflict-check helper depends on `pedB`'s id-rewrite having already run; a naive implementation would silently under-report conflicts), now fixed directly in D2's own text and Dragon #2.
- **A factual overcount** ("all 6 tests" should have been "7 test blocks, 5 with `expect_error()` assertions"), corrected throughout §1-§5.
- **A mischaracterization of `qcStudbook()`'s actual mechanism** (a single global toggle, not a fixed structural-stops/domain-collects split), corrected in §2.6.
- **Three close-out-checklist accuracy errors** (the `a2interactive.Rmd` disposition, and the NEWS.Rmd/`_pkgdown.yml` checklists' Slice 1 applicability), corrected in §6/§9, following the exact precedent #147 itself already set for this identical shape (a script-only function in Slice 1, UI in Slice 2).
- **A missing Interface catalog section** (present in #147, absent here), added as new §4, which also resolved a set of stale `§11`-style cross-references that had been written assuming that section's presence.
- **Two missing dragons** (`modalDialog()` under this app's untested bslib theme; `DT::renderDT()`'s `NA`-rendering behavior, motivated directly by `PROJECT_LEARNINGS.md` Learning 501 from the immediately preceding session), added as Dragons #6-7.
- **A cross-question-dependency note** (Q3/Q4 both lean on Q2's answer), added at the end of §8.

`PROJECT_LEARNINGS.md` was grepped for prior findings specific to this feature area: no entries exist yet for "cross-center," "modalDialog," or "provenance" (this is the first substantive design work on #149's actual topic — everything before it was audit/sequencing history, §1.2). Learning 501 (DT rendering of special values) and Learning 490 (a `renderUI()` rebuild silently resetting a control's value unless it reads its own current state back) were surfaced by the adversarial review as directly relevant to this design's DT tables and `reactiveVal`-gated Export-tab unlock respectively, and are cited in Dragons #7 and (implicitly, as a pattern to re-check) #6.

---

## 11. Ratification status — forced vs. judgment-call decisions

**Forced by structural evidence gathered this session (no real choice, not put to a vote):** D1 (module boundary — Deletion Test applied to the rejected alternative, §3), D4 (forced by D3), D5 (forced by D2), D6 (forced by D2 once it exists), D7 (confirmation mechanism — low-controversy, `modalDialog()` is the standard idiom and the sequencing audit's own prediction), D9 (forced by D1/D3 plus the module-contract's own rules).

**Genuine judgment calls that must go through an `AskUserQuestion` ratification round before this plan is RATIFIED:**

**Q1 (D2) — How should the "show every problem at once" validator relate to `resolveCrossCenterIds()`'s existing fail-fast checks?**
- **Option A — Extract shared, non-`stop()`ing helpers** (including a shared, already-`stop()`-free `pedB` id-rewrite step, load-bearing per Dragon #2)**;** `resolveCrossCenterIds()` calls them and `stop()`s on the first non-empty result (unchanged behavior, golden-master-tested); the new `checkCrossCenterMapping()` calls the same helpers and collects everything. *(This document's recommendation.)*
- **Option B — Independently reimplement the four checks** in a new, separate `checkCrossCenterMapping()` with no code sharing with `resolveCrossCenterIds()`. *(Rejected in this document — logic-drift risk.)*
- **Option C — Add a `mode` parameter to `resolveCrossCenterIds()` itself** so it can either `stop()` or return a collected problem list. *(Rejected in this document — couples an already-shipped exported function's contract to a UI concern.)*

**Q2 (D3) — Does the confirmed merge feed anywhere else in the app this scope, or is it export-only?**
- **Option A — Standalone review/export tool.** The merged pedigree is a downloadable CSV; using it elsewhere means re-uploading through `modInput`'s existing pedigree-file path. *(This document's recommendation.)*
- **Option B — Wire the merged pedigree into `shared$currentPedigree`** (or offer it as an alternate pedigree source inside `modInput`), so a confirmed merge can drive genetic-value/breeding-group analysis in the same session without a re-upload round-trip. *(A legitimate alternative if the owner wants a tighter workflow now, at the cost of real additional scope — see §8. If chosen, it also raises D10/Q4's stakes, since the same column-loss defect would then silently propagate into in-app downstream analysis, not just an exported file.)*

**Q3 (D8) — Should the actual merged pedigree be an explicit, named export artifact?**
- **Option A — Yes, a 5th "Merged Pedigree" download**, alongside the 4 the issue's sentence literally names (mapping, validation results, merge summary, provenance). *(This document's recommendation — without it, the tool produces no usable output.)*
- **Option B — Exactly the 4 artifacts named in the issue's own text**, treating "merge summary" as a counts/changes-only report, not the full merged data. *(The issue-literal reading; leaves the tool's core output undeliverable unless "merge summary" is reinterpreted to include the full pedigree, which this document does not recommend conflating.)*

**Q4 (D10) — Should Slice 1 also fix `resolveCrossCenterIds()`'s silent data-loss of non-`id`/`sire`/`dam` columns for merged individuals (§2.12), now that this workflow is about to expose it to non-programmer curators for the first time?**
- **Option A — Yes, fix it in Slice 1**, generalizing `.pickCrossCenterParent()`'s "prefer non-`NA`, error on differing non-`NA` values" resolution to every shared column, verified by a new, explicitly-labeled test asserting the richer output (not folded into D2's byte-identical golden-master claim). *(This document's recommendation — the alternative ships a curator-facing silent data-loss trap on day one of this becoming user-visible.)*
- **Option B — Ship as-is.** Add a prominent, explicit caveat in the Slice 2 UI and in the exported CSV's own accompanying documentation ("only `id`/`sire`/`dam` are populated for merged individuals"); file a separate, later follow-up issue for the fix, keeping Slice 1 to exactly the original zero-behavior-change validation refactor. *(A legitimate alternative if the owner wants Slice 1's diff minimized, at the cost of shipping a known, user-visible gap.)*

Until Q1-Q4 are answered via `AskUserQuestion` (or the owner's plain-language equivalent), this document remains a **draft proposal**, not a ratified plan.

### Ratification outcome (2026-08-10, this session)

All four questions were posed via a single `AskUserQuestion` call. The owner selected **this document's own recommended option in all four cases, with no changes requested**:

- **Q1 (D2):** Option A — extract shared, non-`stop()`ing helpers (including the load-bearing `pedB` id-rewrite step); `resolveCrossCenterIds()` keeps its exact fail-fast behavior, `checkCrossCenterMapping()` collects everything.
- **Q2 (D3):** Option A — standalone review/export tool; the merged pedigree does not feed `shared$currentPedigree` or any other module this scope.
- **Q3 (D8):** Option A — the Merged Pedigree CSV is an explicit 5th export artifact, alongside Mapping, Validation Results, Merge Summary, and Provenance.
- **Q4 (D10):** Option A — Slice 1 also fixes `resolveCrossCenterIds()`'s silent non-`id`/`sire`/`dam` column loss for merged individuals, as an explicit, separately-tested additive change (not folded into D2's byte-identical golden-master claim).

This plan is now **RATIFIED** and ready for Slice 1 implementation (§5) in a future session.
