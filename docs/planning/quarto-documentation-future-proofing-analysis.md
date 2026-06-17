# Quarto vs. R Markdown — Documentation Future-Proofing Analysis

**Status:** Analysis + recommendation (Session 104, 2026-06-17). The deliverable is this
document; no documents were converted. Adopting any path below is a separate, owner-approved
session.

**Question (owner's framing):** Should `nprcgenekeepr`'s documentation be migrated from
R Markdown to Quarto to **future-proof** it? Build time is *not* the owner's concern — it is
only a guardrail here, because the package is currently archived on CRAN over elapsed-time
limits and a documentation change must not make resubmission harder.

---

## TL;DR — Recommendation

**Adopt Quarto on a partial / hybrid basis, not as a wholesale conversion.**

- **Keep the four CRAN vignettes on `knitr`/`rmarkdown`.** This is the lower-risk *and* the
  forward-safe choice: R Markdown is officially "not going away," is actively maintained
  CRAN-critical infrastructure, and the Quarto vignette engine adds an external Quarto-CLI
  dependency that CRAN's check machines do not guarantee — a poor trade for an
  already-archived package, in exchange for benefits the CRAN vignette engine largely disables
  anyway.
- **Move new and non-CRAN documentation to Quarto, where it carries no CRAN risk and its
  advantages actually land:** the pkgdown website/articles, the long-form manual, any slide
  decks, and the `inst/extdata/` developer docs (two of which are already `.qmd`).

This honors the future-proofing goal — it *does* adopt Quarto, deliberately, where it pays
off — while keeping the CRAN-facing surface on the engine that is purpose-built for CRAN and
is not being retired.

This is the owner's decision; §7 lists the three options plainly so a different call is easy
to make. Every load-bearing claim below was independently web-researched and then survived an
adversarial attempt to refute it (high confidence) — see §8.

---

## 1. What the package actually ships

| Surface | Files | Engine today | Built by CRAN? |
|---|---|---|---|
| CRAN vignette — tutorial | `vignettes/ColonyManagerTutorial.Rmd` | `knitr::rmarkdown_notangle` | Yes (but all chunks `eval=FALSE` — screenshots only) |
| CRAN vignette — interactive | `vignettes/a2interactive.Rmd` | `knitr::rmarkdown_notangle` | Yes (runs real analysis) |
| CRAN vignette — manual | `vignettes/a3manual.Rmd` + 13 `manual_components/_*.Rmd` children | `knitr::knitr` | Yes (assembles child docs) |
| CRAN vignette — simulation | `vignettes/simulatedKValues.Rmd` | `knitr::rmarkdown_notangle` | Yes (gene-drop sim at n=10/100/1000) |
| Website | pkgdown site (rmsharp.github.io/nprcgenekeepr) | pkgdown + knitr | No |
| Repo docs | `README.Rmd`, `NEWS.Rmd` | knitr → github_document | No |
| Dev docs | `inst/extdata/claude_code.qmd`, `inst/extdata/software_design_doc.qmd`, `inst/extdata/meeting_notes.Rmd` | **already Quarto** (2) + 1 Rmd | No (build-ignored) |

`DESCRIPTION`: `VignetteBuilder: knitr`; `Suggests` includes `knitr`, `rmarkdown`, `markdown`;
**no Quarto dependency anywhere.** There is no precompute pattern: the `.html`/`.R`/`.md`
files in `vignettes/` are stale, git-ignored local renders.

**Implication:** the long-form *manual* is the one document whose shape (multi-part,
cross-referenced) most rewards Quarto — and it is currently a CRAN vignette. That tension is
addressed in §6.

---

## 2. Is R Markdown a dead end? No.

This is the core of the future-proofing worry, and the evidence is consistent and on the
record:

- **Posit's official position:** "R Markdown is not going away! … It will continue to be
  actively supported. There are no plans for deprecation… we are going to continue to maintain
  them (smaller improvements and bug fixes) for a long time to come." (quarto.org FAQ for
  R Markdown users.)
- **The original author, directly:** Yihui Xie, *"With Quarto Coming, is R Markdown Going
  Away? No."* (2022) — "Rest assured that we will still actively maintain it… It is not
  imperative to switch."
- **Actually maintained, today:** `rmarkdown` 2.31 (CRAN 2026-03-26, with a GPLv3→MIT relicense
  in April 2026 — institutional investment, not wind-down) and `knitr` 1.51 (CRAN 2025-12-20),
  both with commits into mid-2026, neither archived. Xie was laid off from Posit (last day
  2023-12-31) **but Posit funds him as a contractor to keep maintaining `knitr` and
  `rmarkdown`** (the only ecosystem package dropped was `DT`).
- **Structurally un-droppable:** `knitr` has ~800 reverse-imports and 2,000+ reverse-suggests
  and is the engine **Quarto itself uses to run R**. CRAN cannot let `.Rmd` vignettes stop
  building without cascading breakage across thousands of packages.
- **Still the documented default:** *R Packages (2e)* (Wickham & Bryan) — itself built with
  Quarto — still teaches vignettes with `rmarkdown::html_vignette` and does not present `.qmd`
  as a vignette option.

**The honest nuance (the real future-proofing cost of staying):** Posit will put **no major
new features** into R Markdown — "some new features may only exist in Quarto." So the liability
of staying on `.Rmd` is **feature stagnation and community mindshare drift, not breakage or
abandonment.** That is a real but slow-moving cost, and it weighs on *new* documentation far
more than on four working vignettes.

---

## 3. What would converting these vignettes to Quarto actually buy?

For a **single-language (R-only)** package shipping **CRAN HTML vignettes**, most of Quarto's
marketed advantages are not realizable, because the CRAN vignette engine is deliberately
stripped down (`theme: none`, `minimal: true`, embedded resources) "to keep the HTML vignettes
reasonable in size and… publishable on CRAN" (quarto-r docs, called a "deliberate limitation
of the current implementation").

| Quarto advantage | Realizable in a CRAN vignette here? |
|---|---|
| Multi-language (Python/Julia/Observable) | **No** — package is R-only |
| Books/websites, cross-format single-source | **Partly** — applies to the manual/site, not to CRAN vignettes |
| Typst / advanced PDF layout | **No** — explicitly advised against for CRAN ("Typst may not be available") |
| Callouts, tabsets, Bootstrap-5 theming | **No** — Bootstrap is disabled by the minimal CRAN format |
| Native cross-references (fig/tbl/sec/eq) | **Yes** — the one genuinely realized gain |
| Better defaults / authoring experience | Marginal for documents this simple |

So the concrete upside of converting the *CRAN vignettes* is essentially "native
cross-references plus being on the toolchain that gets new features" — modest, set against a
new external dependency and migration effort.

---

## 4. The cost side: Quarto vignettes on CRAN add real risk

- **External-CLI dependency.** A live Quarto vignette requires `VignetteBuilder: quarto`,
  `%\VignetteEngine{quarto::html}`, and `SystemRequirements: Quarto command line tool`. That is
  a non-pure-R binary (it bundles its own pandoc/Deno) that must be present on every
  contributor, CI, and **CRAN check** machine.
- **CRAN does not guarantee Quarto.** Only pandoc is a documented CRAN toolchain component.
  The Quarto CLI was **confirmed missing on CRAN's macOS check flavors in 2025** (the `quarto`
  package itself had to add test-skips because its tests failed there). The Quarto team's
  position: "CRAN would need to add the Quarto binary to their setup… entirely up to the R Core
  Team."
- **Documented CRAN friction.** A new Quarto vignette engine has produced a real CRAN NOTE —
  "Package has 'vignettes' subdirectory but apparently no vignettes" — because the engine is
  only discoverable after the package is installed. It fails *soft* (a missing CLI yields a
  placeholder stub, not an ERROR), but for a package being **un-archived**, adding a new class
  of platform-dependent check noise is the wrong direction.
- **The Quarto maintainer's own advice:** Christophe Dervieux (Posit, Quarto) — *"I would not
  advise to use [the Quarto vignette extension] for a CRAN vignette, but for an in-private
  organization package I can see the need."*
- **Build time (guardrail, not the driver):** both engines run R chunks via the *same* `knitr`,
  so conversion cannot reduce the simulation cost and adds fixed per-document overhead
  (~1.9 s/doc in one benchmark). It would slightly *increase* check time. Since timing isn't the
  owner's concern this is secondary — but it confirms conversion offers nothing on the axis that
  archived the package.

---

## 5. Migration is cheap and reversible — which is *why* there's no rush

This cuts against urgency in both directions: because converting later is easy, there is little
penalty for staying now.

- Quarto renders **most `.Rmd` unmodified** via its own `knitr` engine; conversion is mostly
  rename `.Rmd`→`.qmd` + adjust YAML (`output:` → `format:`, the `%\VignetteEngine` line).
  Reversible by renaming back.
- **What needs hand-work here:** the `a3manual.Rmd` child-include structure (13 `child=`
  chunks), the `kableExtra` tables with `latex_options`, the `knitr::rmarkdown_notangle`
  engine choice, and relative paths to the `shiny_app_use/` screenshots.
- **Incremental adoption is supported:** pkgdown handles a **mixed** `.qmd`/`.Rmd` article set
  (since pkgdown 2.1.0, 2024-07) via a `_quarto.yml` `project: render: ['*.qmd']` so rmarkdown
  keeps handling the `.Rmd` files. Known rough edges exist (HTML-only, callouts unsupported,
  pkgdown can lag new Quarto features) but the path is official.

---

## 6. Recommended path — hybrid adoption

**Principle:** put each document on the engine that fits *where it is consumed*. CRAN-built
artifacts stay on the CRAN-native engine; author-controlled surfaces (where you can install
Quarto) move to Quarto.

**6.1 Keep on `knitr`/`rmarkdown` (no change):**
the four CRAN vignettes + `manual_components/*.Rmd`. Zero CRAN risk, officially supported
indefinitely, and endorsed for this exact case by the Quarto maintainer.

**6.2 Adopt Quarto, no CRAN exposure:**

1. **Developer docs in `inst/extdata/`** — already `.qmd` for two of three; standardize the
   third (`meeting_notes.Rmd`) if/when convenient. Zero-cost; these are build-ignored.
2. **The pkgdown website** — author *new* articles in Quarto; pkgdown's mixed mode lets existing
   `.Rmd` vignettes continue to render the site unchanged. New long-form/tutorial web content is
   where cross-references, theming, and single-source actually pay off.
3. **Any slide decks / talks** — Quarto (`revealjs`) for new presentation material.

**6.3 The one strategic question worth deciding deliberately — the manual.**
`a3manual.Rmd` is both a CRAN vignette *and* the document that would benefit most from Quarto
(multi-part, cross-referenced). Two coherent options, owner's call:

- **(a) Leave it as a knitr CRAN vignette** (status quo; simplest).
- **(b) Reposition the manual as a Quarto long-form document on the website** (pkgdown
  article or standalone Quarto book) and drop it from the CRAN vignette set, keeping only the
  lighter tutorials as CRAN vignettes. This gains Quarto's long-form features *and* removes the
  heaviest assembly from the CRAN build — but it changes what ships to CRAN, so it is a
  deliberate scope decision, not a mechanical one.

**6.4 Explicitly NOT recommended:** converting the CRAN vignettes to live Quarto vignettes
(adds the CLI dependency for narrow benefit on an archived package), and using Quarto as the
*timing* fix (it can't help — see §4).

---

## 7. Decision for the owner

| Option | What it means | Verdict |
|---|---|---|
| **A. Full conversion** — all docs → Quarto, CRAN vignettes included | Adds Quarto-CLI `SystemRequirements`; new CRAN check risk; narrow realized benefit | **Not recommended** — wrong risk/benefit for an archived package |
| **B. Hybrid / partial adoption** (this doc's recommendation) | CRAN vignettes stay knitr; website + new docs + dev docs + slides → Quarto; manual per §6.3 | **Recommended** — captures the future-proofing benefit at near-zero CRAN risk |
| **C. Status quo** — stay fully on R Markdown | No change | **Safe but leaves value on the table** — forgoes Quarto where it's free of risk |

Default if unaddressed: **B**. None of this blocks the CRAN resubmission; it can proceed in
parallel or after.

---

## 8. Relationship to the CRAN 2.0.0 plan

- **Timing (CRAN plan Phase 2 / the deferred Phase 2b vignette work):** the correct,
  numeric-preserving fix is **precompute on the existing `knitr` engine** (`.Rmd.orig` →
  committed `.Rmd` via `knitr::knit()`), which removes the heavy gene-drop computation from
  CRAN's build while keeping `VignetteBuilder: knitr` and the exact displayed kinship numbers.
  **Quarto is not the lever for this** and the two efforts are independent.
- **This analysis does not change Phases 1–6** of `cran-2.0.0-submission-plan.md`. If the owner
  picks option B/C, the CRAN vignettes remain knitr and the plan is unaffected. Only option A
  (not recommended) would intersect the submission, by adding a `SystemRequirements` and
  reopening check-portability questions.

---

## 9. Sources (primary, web-verified)

**R Markdown longevity / maintenance status**
- Quarto FAQ for R Markdown users — https://quarto.org/docs/faq/rmarkdown.html
- JJ Allaire, "Announcing Quarto" (2022-07-28) — https://posit.co/blog/announcing-quarto-a-new-scientific-and-technical-publishing-system/
- Yihui Xie, "With Quarto Coming, is R Markdown Going Away? No." (2022-04) — https://yihui.org/en/2022/04/quarto-r-markdown/
- Yihui Xie, "Bye, RStudio/Posit!" (2024-01) — https://yihui.org/en/2024/01/bye-rstudio/ ; InfoWorld (2024-01-05) — https://www.infoworld.com/article/2335751/posit-lays-off-r-markdown-knitr-creator-yihui-xie.html
- CRAN: rmarkdown — https://cran.r-project.org/web/packages/rmarkdown/index.html ; knitr — https://cran.r-project.org/web/packages/knitr/index.html
- R Packages (2e), Vignettes — https://r-pkgs.org/vignettes.html

**Quarto vignettes on CRAN / engine constraints / maintainer guidance**
- Quarto HTML Vignettes ("minimal… deliberate limitation") — https://cran.r-project.org/web/packages/quarto/vignettes/hello.html ; advanced — https://quarto-dev.github.io/quarto-r/articles/advanced-vignettes.html
- quarto-r NEWS (vignette engine since 1.4; CRAN test-skip fixes) — https://quarto-dev.github.io/quarto-r/news/index.html
- quarto-cli Discussion #2307 (CRAN must add the binary; maintainer advises against for CRAN) — https://github.com/quarto-dev/quarto-cli/discussions/2307
- R-pkg-devel 2024Q1 ("apparently no vignettes" NOTE) — https://stat.ethz.ch/pipermail/r-package-devel/2024q1/010497.html
- Build-time overhead benchmark — https://github.com/quarto-dev/quarto-cli/issues/14156

**pkgdown / mixed mode / migration**
- pkgdown Quarto support (mixed `.qmd`/`.Rmd`) — https://pkgdown.r-lib.org/articles/quarto.html ; pkgdown 2.1.0 NEWS (2024-07-06) — https://pkgdown.r-lib.org/news/index.html
- Quarto "Using R" (renders most `.Rmd` unmodified; knitr backend) — https://quarto.org/docs/computations/r.html

**Timing fix (existing engine, for the CRAN plan)**
- rOpenSci precompute pattern — https://ropensci.org/blog/2019/12/08/precompute-vignettes/ ; r-hub vignettes — https://blog.r-hub.io/2020/06/03/vignettes/
