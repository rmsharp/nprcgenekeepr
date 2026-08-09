# Issue #136 Plan — Name (non-ID) Node Labels for the Pedigree Diagram

**Status:** Design/scoping document (Pre-RED) — no `R/`/`tests/`/`man/` content changes this session.
**Session:** S488 (2026-08-08).
**Origin:** GitHub issue #136 ("Show names (not just ID) as Pedigree Diagram node labels
(data-model gated)"); `docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md` Finding #8 /
Recommendation #7; `docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md` Tier 2,
second in the owner's standing order #133 > #136 > #137 > #138 (set S436).
**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` (owner-picked this session
via `AskUserQuestion` over the literal `DESIGN_WORKSTREAM.md` task mapping — #136 is a data-model and
rendering-contract change, not a UI layout/zone design).

> **Scope.** This document is a design/architecture plan only. It changes no `R/`, `tests/`, or
> `man/` content by itself. Implementation happens in a future session against the slice contracts
> ratified in §4.

---

## 1. Context

### 1.1 What issue #136 says (verbatim)

> kinship2's `id` argument is positionally substitutable, letting a caller pass any string per node
> -- its vignette demonstrates embedding a name alongside the ID via `\n`-joined text.
> nprcgenekeepr's diagram always shows exactly `ped$id` as both node id and label
> (`R/makePedigreeDiagramData.R:41`), because the pedigree data model it consumes has no "name"
> column at all.
>
> **Impact:** Minor for a studbook-ID-driven colony-management workflow, where IDs already are the
> primary key colony managers work from -- but would matter if a future workflow wants human-readable
> names shown directly on the diagram.
>
> **Audit disposition:** the audit recommended **no action** -- gated by the pedigree data model
> lacking a name field, not by a diagram-rendering limitation. Filed here per owner direction
> (session 436) to track the idea for future consideration. Revisit only if/when a name column is
> added to the underlying pedigree data structure.

The issue also carries an owner comment (S436) requiring that any implementing plan include a
documentation phase updating `vignettes/articles/colony-manager-guide.qmd` and/or
`vignettes/manual_components/_pedigree_browser.Rmd`.

### 1.2 What is already decided (do not re-litigate)

- **Priority order.** #136 follows #133 in the owner's standing Tier 2 order (set S436, preserved
  verbatim by the S480 sequencing audit). This document does not re-derive that ordering.
- **D2 visNetwork stands.** The technology choice (visNetwork, not kinship2) was ratified in
  `docs/planning/issue129-pedigree-diagram-tree-visualization-plan.md` and re-affirmed when Option 2
  was adopted (S457/S458). #136 does not reopen it.
- **kinship2-naming-convention overlay.** The owner directed (S436) that where nprcgenekeepr adds a
  data-model concept kinship2 already names, it should reuse kinship2's own naming. Note that this
  overlay has *no purchase here*: kinship2 has no "name" column — it overloads its `id` argument
  (§2.4). This is a real difference from #133, where `affected` was a direct kinship2 borrowing.
- **Documentation-checklist obligations apply.** Tutorial/article (owner comment on #136) and
  `NEWS.Rmd` (`CLAUDE.md`'s standing checklist) are owed in the implementing session, not deferred.
- **The Vertical Slice Session allowance does not yet apply.** No prior session pre-declared a layer
  contract for #136 (`SESSION_RUNNER.md` §Vertical Slice Sessions, gate (a)) — this document *is*
  that pre-declaration.

### 1.3 What this session's research confirmed — and where the issue is wrong

Five parallel research lenses (data model, render chain, layout geometry, kinship2/domain fit, prior
decisions), each adversarially verified, plus this session's own direct verification (every finding
in §2 below was re-derived first-hand rather than inherited). **Three findings materially change the
problem from how the issue frames it:**

1. **The premise "always shows exactly `ped$id` as both node id and label" is true only of *real
   individual* nodes — `label` is already a fully independent channel, and `label != id` already
   ships in production.** Duplicate-occurrence nodes carry `id = "__dup_<realId>_<n>"` with
   `label = <realId>` (`R/makePedigreeDiagramData.R:906`), and mating-union nodes carry a non-empty
   `id` with `label = ""` (`:929`). #136 is therefore **not** a request to build a label mechanism —
   the mechanism exists and is exercised on two node classes today. The whole question reduces to
   *what string is placed in the existing `label` column for real individuals* (§2.2).
2. **The issue's own file:line citation is stale, and its "no name column at all" claim needs
   qualification.** `R/makePedigreeDiagramData.R:41` is now a `# nolint` directive, not the label
   assignment. And the schema *does* contain `first_name`/`second_name` — but these are **allele
   names, not animal names** (`R/headerDisplayNames.R:52-53` maps them to "First Allele"/"Second
   Allele"). The substantive claim (no *animal-name* column) holds, but the near-miss names are a
   live collision hazard for anyone naming a new column (§2.1). This is exactly the
   `PROJECT_LEARNINGS.md` Learning 485 trap, re-encountered.
3. **The binding constraint is geometry, not the data model.** The audit gated #136 on "the data
   model lacks a name field," which is the cheap half. The expensive half is that this diagram
   abandoned auto-layout for hand-computed fixed coordinates (S459-S461), so **nothing adjusts
   spacing for label width** — and at today's spacing, 25.6% of adjacent label-bearing node pairs sit
   48 layout units apart while the nodes themselves are ~50 units across. Every id in the real
   fixture is exactly 6 characters; there is effectively **zero horizontal headroom** for longer
   strings (§2.3). By contrast kinship2 — the comparison that generated this issue — *measures* its
   label text (`strwidth`/`strheight`) when laying out, so it can afford arbitrary label strings in a
   way this package cannot without new work (§2.4).

---

## 2. Evidence-based inventory

Every claim below was verified first-hand this session against current `master`
(`a5b13c45` + this session's own claim commit), not inherited from the issue, the audit, or a
research agent's summary.

### 2.1 The pedigree column schema, and the name-collision check

`.nprcColumnSchema` (`R/columnSchema.R:15-24`) is the single source of truth, exposing three
independently-ordered roles:

| Role | Contents (verbatim) |
|---|---|
| `required` | `id`, `sire`, `dam`, `sex`, `birth` |
| `include` | `id`, `sex`, `age`, `birth`, `exit`, `population`, `condition`, `origin`, `first_name`, `second_name` |
| `possible` | `id`, `sire`, `dam`, `sex`, `species`, `gen`, `birth`, `exit`, `death`, `age`, `ancestry`, `population`, `origin`, `status`, `condition`, `departure`, `spf`, `vasxOvx`, `pedNum`, `first`, `second`, `first_name`, `second_name`, `recordStatus`, `affected` |

**Adjacent-name rule-out (the Learning 485 discipline — read the documentation, do not guess from the
name).** This covers the plausibly-adjacent candidates, not a recital of all 25 `possible` entries;
the two that matter are the first row, and `condition`/`status`, which #133 already ruled out by the
same method:

| Candidate | What it actually means | Source | Fit? |
|---|---|---|---|
| `first_name` / `second_name` | **Allele/haplotype names**, not animal names — displayed as "First Allele"/"Second Allele" | `R/headerDisplayNames.R:52-53`; `R/data.R:358-359` ("a generic name for the first haplotype"); `R/geneDrop.R:24` | **No** — and a dangerous near-miss |
| `first` / `second` | Allele *codes* (the numeric counterpart of the above) | `R/headerDisplayNames.R:50-51` ("First Allele Code") | No |
| `condition` | Research-protocol/SPF status ("assumed to be naive") | ruled out for #133, `PROJECT_LEARNINGS.md` Learning 485 | No |
| `status` | Vital status factor (`ALIVE`/`DECEASED`/`SHIPPED`/`UNKNOWN`) | ruled out for #133, Learning 485 | No |
| `recordStatus` | Provenance marker ("Original/ Added") | `R/headerDisplayNames.R:56` | No |

**Conclusion: no animal-name column exists.** The issue's substantive claim survives — but
`first_name`/`second_name` mean something else entirely and sit one underscore away from any
"…_name" column a future session might invent.

**Empirical domain check.** None of the 8 bundled pedigree fixtures carries any animal-name column;
all identify animals by `id` alone:

| Fixture | Header |
|---|---|
| `obfuscated_rhesus_mhc_ped.csv` | `id, sire, dam, sex, gen, birth, exit, age` |
| `obfuscated_rhesus_mhc_ped_affected.csv` | …`, affected` |
| `ExamplePedigree.csv` | `id, sire, dam, sex, gen, birth, exit, age, ancestry, origin, status` |
| `deidentified_jmac_ped.csv` | `id, species, geographic.origin, sex, status, birth, death, dam, dam.type, sire, sire.type, from.center, departure` |
| `rhesusPedigree_fromCenter.csv` | …`, fromCenter` |
| `obfuscated_rhesus_mhc_breeder_genotypes.csv` | `id, first_name, second_name` (**genotypes, not a pedigree** — the only home of the `*_name` columns) |

### 2.2 How an unrecognized column reaches the diagram, and what `label` does today

**Passthrough mechanism (exact).** `qcStudbook()` does not filter unknown columns — it *reorders*
them:

```r
# R/qcStudbook.R:317-319
cols      <- intersect(getPossibleCols(), colnames(sb))
novelCols <- colnames(sb)[!colnames(sb) %in% cols]
sb        <- sb[, c(cols, novelCols)]
```

Schema-recognized columns come first in schema order; unrecognized ("novel") columns are appended.
**Consequence: adding a column to `.nprcColumnSchema$possible` is *not* required for it to survive
upload — it only changes column ordering and formal recognition.**

**Name-normalization behaviour (verified empirically, not read off the source alone).**
`fixColumnNames()` (`R/fixColumnNames.R:19-70`) lowercases, then strips spaces, periods, and
underscores, with a special-case restore for `firstname`/`secondname` → `first_name`/`second_name`
(`:33-38`, issue #117). Round-tripping candidate spellings through `qcStudbook()`:

| Input header | Survives as | Verdict |
|---|---|---|
| `name` | `name` | **round-trips exactly** |
| `Name`, `NAME` | `name` | case-folds onto the same column — good |
| `animal_name` | `animalname` | mangled (underscore stripped) |
| `callName` | `callname` | mangled (case-folded) |
| `first_name` | `first_name` | preserved — **but means "First Allele"** |

This makes `name` the only spelling that is stable under the normalizer *and* free of the allele
collision.

**What the node data frames carry today.** Both builders set `label` explicitly:

| Node class | `id` | `label` | Source |
|---|---|---|---|
| Real individual (`makePedigreeDiagramData()`) | `ped$id` | `ped$id` | `R/makePedigreeDiagramData.R:75-82` |
| Real individual (`makePedigreeMatingLayout()`) | `realIds` | `realIds` | `:894-899` |
| **Duplicate occurrence** | `__dup_<realId>_<n>` | **`duplicates$realId`** | `:904-911` |
| **Mating union** | `__union_<n>` | **`""`** (empty) | `:924-932` |

The last two rows are the finding that reframes this issue: **`label` is already decoupled from `id`
and already differs from it in production.** A `label` change touches no id-keyed machinery.

**Which builder actually renders the live tab.** `R/modPedigree.R` calls
`makePedigreeMatingLayout()`, not `makePedigreeDiagramData()` (the same trap #133 documented). Any
label change must touch **both** functions to be coherent, but only the former ships on the live app.

**Consumers of node `id` — all safe under a label-only change**, because every one of them keys on
`id`, never on the displayed string:

| Consumer | Mechanism | Source | Affected by label change? |
|---|---|---|---|
| Click-to-navigate | strips reserved prefixes, maps via `duplicateToReal` | `R/modPedigree.R:593-597` | No |
| Reserved-prefix filters | `^__union_\|^__dup_\|^__drop_\|^__bar_\|^__proj_` | `:552-553`, `:593` | No |
| `highlightNearest` | edge-graph traversal by id | `:556-570` | No |
| Legend | separate widget instance | `:476-515` | No |
| PNG export | canvas capture | (issue #131) | Renders whatever is drawn |
| **Search dropdown** | `nodesIdSelection(values = <real ids>)` | `:549-555` | **YES — see below** |

### 2.3 Geometry: the real constraint

**The layout is fixed-coordinate and text-unaware.** Since S459-S461 the diagram abandons vis.js
hierarchical layout for hand-computed coordinates with `visPhysics(enabled = FALSE)` /
`visNodes(physics = FALSE)` (`R/modPedigree.R:457`). Positions are `pos$x * xScale` and
`pos$gen * yScale` with `xScale <- 120L`, `yScale <- 150L`
(`R/makePedigreeDiagramData.R:843-844, 948-949`). **Nothing in this pipeline measures label text.**

**Shape family.** Real individuals use `dot`/`square` (from `shapeMap`,
`R/makePedigreeDiagramData.R:37`) at `size = 25L` (`:898`). These are vis.js *fixed-size icon*
shapes: the node does not grow to fit its label, and the label is drawn **below** the node. (This is
the same shape-family distinction that bit S487's legend row — `PROJECT_LEARNINGS.md` Learning 487.)
So a longer label does not enlarge the node; it widens the text drawn beneath it, which can overlap
a neighbour's text.

**Measured spacing on the real 375-individual fixture** (`obfuscated_rhesus_mhc_ped.csv`, through
`qcStudbook()` + `makePedigreeMatingLayout()` — 739 nodes, of which 502 are label-bearing):

| Metric | Value |
|---|---|
| Current id length | **exactly 6 characters for every individual** (min = median = max) |
| Adjacent label-bearing gap, 25th pct | **48 units** |
| Adjacent label-bearing gap, median | 120 units |
| Adjacent pairs < 50 units apart | **126 (25.6%)** |
| Adjacent pairs < 80 units apart | 245 (49.7%) |
| Node diameter (`size = 25L`) | ~50 units |

**Reading:** for the tightest quarter of the diagram — the mate pairs flanking a union dot — nodes
sit 48 units apart centre-to-centre while each is ~50 units across. A centred 6-character label at
vis.js's default 14px font is already approximately edge-to-edge with its neighbour's. **There is no
spare horizontal room.** Any label materially longer than today's 6 characters will overlap in the
crowded quarter of a real pedigree unless the design supplies a mitigation (truncation, a spacing
increase, an opt-in toggle, or two-line stacking).

This is the single most important input to the design, and it is *not* what the audit flagged.

### 2.4 The kinship2 comparison, verified at source

kinship2 **1.9.6.2** is installed (as local reference material only — it is in neither `DESCRIPTION`
nor `renv.lock`, and this design adds no dependency). Its `plot.pedigree` signature begins
`function (x, id = x$id, status = x$status, affected = x$affected, ...)`, and the validation applied
to a caller-supplied `id` is a length check:

```r
if (!missing(id)) { if (length(id) != n) stop("Wrong length for id") }
```

**The issue's claim is accurate**: `id` is genuinely positionally substitutable as display text.
(Adversarial verification found the stronger phrasing "*only* a length check" to be overstated —
there is at least one further content-dependent path in kinship2's label handling — so this document
claims only substitutability plus the length contract, which is what the design actually relies on.)

**An important disambiguation the issue elides:** `plot.pedigree()`'s `id` is a *display-label*
argument; the `pedigree()` **constructor**'s `id` is the structural linking key and is **not**
substitutable. The same split already exists here — visNetwork's node `id` is structural, `label` is
display — and it is exactly what makes this change safe (§2.2).
(Worth stating explicitly, because the sibling issue #145's kinship2 citations from this same audit
family were found unreliable by S482's spike — this one holds up.)

**But the more useful finding is the disanalogy.** kinship2's plotting code measures its label text
when laying out — `strwidth("ABC", units = "inches", cex = cex)` and
`max(strheight(id, units = "inches", cex = cex))` appear in its layout arithmetic. kinship2 can
afford arbitrary label strings *because its layout is text-aware*. nprcgenekeepr's fixed-coordinate
layout is not. **"kinship2 can do this" therefore does not imply "this is cheap here."**

### 2.5 The search dropdown will change behaviour for free — and misleadingly

`R/modPedigree.R:549-555` enables `nodesIdSelection` with an explicit `values` list but **does not
set `useLabels`**. In visNetwork, `useLabels` defaults to `TRUE`
(`visOptions()`: `nodesIdSelection = list(enabled = FALSE, selected = NULL, style = '...',
useLabels = TRUE, main = "Select by id")`), and the bundled widget JS honours it:

```js
// visNetwork.js:1017-1022 (the params.values branch this app uses)
option.value = tmp_node[0].id;
if (tmp_node[0].label && params.useLabels) { option.text = tmp_node[0].label; }
else { option.text = tmp_node[0].id; }
```

**Consequence:** the moment real individuals' `label` becomes a name, the "Select by id" dropdown
silently starts listing **names** while its own header still reads "Select by id", and a colony
manager can no longer find an animal by typing its studbook ID. This is a genuine, shipped-behaviour
regression that no unit test on the nodes data frame would catch — it is a `useLabels`/`main`
decision the design must make explicitly, not discover in QA.

### 2.6 De-identification: the strongest constraint, and it is not in the issue

`obfuscatePed()` (`R/obfuscatePed.R:29-49`) scrubs **only** three things:

```r
alias    <- obfuscateId(ped$id, ...)   # :31
ped$sire <- alias[ped$sire]            # :32
ped$dam  <- alias[ped$dam]             # :33
ped$id   <- alias                      # :34
for (col in names(ped)) {              # :35-39
  if (any(inherits(ped[[col]], "Date"))) ped[[col]] <- obfuscateDate(...)
}
```

`id`/`sire`/`dam`, plus any **Date**-classed column, plus a recomputed `age`. **Every other column —
including a character `name` column — passes through completely unchanged.**

**Consequence:** shipping a `name` column without a matching `obfuscatePed()` change creates a
*silent de-identification failure*. A curator who "de-identifies" a pedigree and shares it would
export scrubbed IDs **alongside intact real animal names** — worse than not obfuscating at all,
because the scrubbed IDs give false assurance that the file is safe. This matters here more than for
any prior pedigree-diagram issue: a name is the only genuinely PII-shaped field this package has ever
contemplated adding, and there is an open issue (#150) for a de-identified pedigree-export workflow
that would inherit the defect.

Two further egress paths carry the column out of the app regardless of the diagram: the Pedigree
Browser's CSV export writes the whole data frame, and the Diagram tab's PNG export (issue #131) bakes
whatever the labels show into a raster image.

### 2.7 Structural traps a future implementer will hit

| # | Trap | Evidence | Consequence for the design |
|---|---|---|---|
| 1 | **Adding any new column to the nodes data frame breaks the rectilinear edge style** | `R/makePedigreeDiagramData.R:1237` — `finalNodes <- rbind(keptNodes, newNodes[, names(keptNodes)])`, where `newNodes` is built with a fixed column set (`:1221-1236`) | Change the **value** of the existing `label` column. Do **not** add a `name`/`displayName` node column. (This is the exact gap S486 hit for #133.) |
| 2 | **Synthesized rows can never carry a name** | `addParents()`/`rbindFill()` fill unlisted columns with `NA`; `addUIds()` mints `U####` placeholders | A per-node fallback to `id` is **mandatory**, not cosmetic — without it those nodes render blank |
| 3 | **`removeDuplicates()` compares whole rows** | `R/removeDuplicates.R:45` — `p <- unique(ped)` | Two previously byte-identical duplicate rows whose `name` values differ would now survive de-duplication and fail QC downstream. Narrow, but real, and worth a RED test |
| 4 | **`fixColumnNames()` rewrites any header containing `ego`** | `R/fixColumnNames.R:45` — `gsub("ego", "id", cols, fixed = TRUE)` | `ego_name` → `idname`. Accept only the bare spelling `name`; do not offer alias spellings |
| 5 | **`getFocalAnimalPed()` assigns column names positionally for 7 columns** | hardcoded 7-element `names()` assignment | An 8-column LabKey source silently gets `NA` as the 8th column name. Argues for scoping v1 to file upload and filing this separately |
| 6 | **The legend canvas is already at its height limit** | `R/modPedigree.R:476-515`; `stepY` retuned 65→54 for the 6th row (S487, Learning 487) | Do not add a legend row for #136 |
| 7 | **`.nprcColumnSchema` is *not* the only column vocabulary** — several others remain unconsolidated after issue #123's partial merge | `R/getDateColNames.R`, `R/headerDisplayNames.R`, `R/toCharacter.R:24`, `R/fixColumnNames.R:19-70`; and **four separate copies** of a diagram-local `required <- c("id","sire","dam","sex","gen")` inside the target file itself (`R/makePedigreeDiagramData.R:29, 199, 454, 822`) | Registering `name` in `$possible` is not automatically enough. Verified: `headerDisplayNames(c("affected","species","name","id"))` returns `NA NA NA "Ego ID"` — the drift is live, and `affected` (S486) is itself an un-synced instance |

### 2.8 Existing test surface that pins current behaviour

Exactly four assertions pin label/column behaviour, all in
`tests/testthat/test_makePedigreeMatingLayout.R`:

| Line | Assertion | Still true under an optional-column design? |
|---|---|---|
| `:112` | `expect_equal(dupRows$label, dupRealId)` | Yes, for a name-less pedigree |
| `:115` | `expect_equal(realRows$label, realRows$id)` | Yes, for a name-less pedigree |
| `:132` | `expect_equal(unionRow$label, "")` | Yes, unconditionally |
| `:437-438` | `expect_setequal(names(default$nodes), c("id","label","shape","title","size","x","y"))` | Yes, **provided no new node column is added** (trap 1) |

`makePedigreeDiagramData()`'s own label assignment has **zero** test coverage today.

**A ready-made RED template exists:** `tests/testthat/test_species_first_class.R`, from the issue #46
work that made `species` first-class, pins exactly the "schema-recognized vs. novel-column"
distinction a `name` column needs.

---

## 3. Design decisions

**Owner-ratified framing (this session, via `AskUserQuestion`, before this section was drafted):**
(1) names exist at **some centers, inconsistently** — the feature must degrade gracefully per animal
and may never assume a name is present; (2) the framing is an **optional `name` column plus an
off-by-default display toggle**, mirroring issue #133's shape. The alternatives (tooltip-only,
decline, configurable label-source) were presented with honest cases and not chosen.

**D1 — Column name and type: `name`, character, optional.**
`name` is the only candidate spelling that round-trips `fixColumnNames()` unchanged while
case-folding `Name`/`NAME` onto it (§2.2, verified empirically). It is collision-free in the pedigree
pipeline (§2.1). Rejected: `first_name`/`second_name` (**already mean "First/Second Allele"** — §2.1),
`animal_name` (→ `animalname`), `callName` (→ `callname`), `ego_name` (→ `idname`, trap 4).
Type is character; coerce defensively with `as.character()` at the label-construction site (the
`affected` precedent) so direct API callers who bypass `qcStudbook()` are also safe.

**D2 — Register `name` in `.nprcColumnSchema$possible` only — not `include`.**
Registration is *not* required for the column to reach the diagram (the `novelCols` passthrough
already delivers it — §2.2). It buys canonical column ordering, roxygen documentation, and presence
in `getSiteInfo()$possibleCols`. It is deliberately **not** added to `include`, which drives
`reportGV()`/`gvaConvergence()` output columns — a name is not a genetic-value report field, and
adding it there would change those reports' shape for no benefit.

**A `headerDisplayNames()` entry is optional and is consciously skipped**, matching #133's treatment
of `affected`. Note this is a *knowing* inconsistency, not an oversight: that map has drifted from
the schema for `species` and `affected` alike (trap 7), and it has no caller inside `R/` — it is
exported and used only by `vignettes/a2interactive.Rmd`. A future session may reconcile all three at
once; #136 should not do it piecemeal.

**D3 — Label form: augment, do not replace. *(Ratified §8.)***
Three forms are possible: `id` (today), `name` (replace), `id\nname` (augment). The toggle switches
**`id` (default) ↔ `id` + name (augmented)**; a name-only mode is declined:
- kinship2's own vignette — the precedent the issue cites — frames this as "add additional
  information **under** each subject", i.e. name *in addition to* ID, never instead of it.
- The PNG export (#131) bakes labels into a raster with no tooltip. A name-only label produces an
  exported diagram containing **no studbook ID anywhere** — useless as a colony-management artifact.
- The ID remains the stable key every other surface (click-to-navigate, dropdown values, CSV) uses.

**D4 — Per-node fallback to `id` is mandatory.**
`label <- ifelse(is.na(name) | !nzchar(name), id, <D3 form>)`. Required twice over: by the owner's
"some centers, inconsistently" answer, and structurally by synthesized parents/`U####` placeholders
(trap 2), which can never carry a name.

**D5 — Change the `label` *value*; add no new nodes column.** Forced by trap 1.

**D6 — Pin `useLabels = FALSE` on the search dropdown.**
Without this the "Select by id" dropdown silently begins listing names while still calling itself
"Select by id", and ID search — the colony manager's primary lookup — breaks (§2.5). Pinning
`useLabels = FALSE` makes the dropdown's current behaviour explicit and unchanged regardless of label
mode. (A future enhancement could offer name search with an honest `main` caption; out of scope here.)

**D7 — Implement in *both* `makePedigreeDiagramData()` and `makePedigreeMatingLayout()`**, duplicated
rather than factored, following the #135-precedent-as-ratified-in-#133 D4. Only the latter is on the
live Shiny path (`R/modPedigree.R:446`), but the former is exported public API.

**D8 — `obfuscatePed()` must scrub `name`, in the same slice that introduces the column.**
Non-negotiable given §2.6. **Ratified treatment (§8): replace values with `NA`** rather than alias
them — an obfuscated pedigree has no use for a fake name, aliasing invites the assumption that the
alias is stable across exports, and D4's per-node fallback makes those nodes render as plain IDs,
i.e. exactly the pre-#136 appearance.

**D9 — Fixture: a new sibling CSV, not an in-place edit** (the #133 `..._affected.csv` precedent,
with a `data-raw/` generator and a seeded RNG). It must deliberately include: animals with names,
animals with `NA`/empty names (the "inconsistent" case, D4), and at least one deliberately long name
(the geometry case, D10).

**D10 — Geometry mitigation: truncate the displayed name; keep the full name in the tooltip.**
Forced by §2.3 — at the 25th percentile the diagram has *zero* horizontal headroom beyond today's
uniform 6-character IDs. Because the toggle is off by default (owner-ratified), crowding is opt-in,
but it must still be bounded. **Ratified (§8):** truncate the *displayed* name with an ellipsis at a
documented character budget, and append the full, un-truncated name to the existing HTML tooltip —
**HTML-escaped via the existing `.escapeHtml()`**, since vis.js renders `title` as innerHTML (labels
are canvas-drawn and need no escaping). The exact budget is a Pre-RED decision for the implementing
session, empirically calibrated against a live render (§8 Dragon 1).

**D11 — No new legend row.** The legend encodes node *appearance* classes (shape→sex, affected
colour); a label mode is not one. This also avoids re-tuning a canvas already at its height limit
(trap 6).

**D12 — v1 scope is the file-upload path only.** The LabKey/EHR path ships no name field today, and
`getFocalAnimalPed()`'s positional 7-column `names()` assignment would silently mis-name an 8th
column (trap 5). That latent bug should be filed separately rather than fixed under #136.

---

## 4. Implementation plan — vertical slices (one session each)

Mirrors issue #133's own two-slice split, and the same split the #133 work actually shipped
(schema commit separate from rendering commit).

### Slice 1 — Data model + de-identification

**Scope:** `name` becomes a recognized, optional, character pedigree column that is correctly
scrubbed by de-identification. **No visible change to the app.**

**Touches:** `R/columnSchema.R` (one word), `R/getPossibleCols.R` roxygen + `man/getPossibleCols.Rd`,
`R/obfuscatePed.R` (D8), `inst/extdata/examples/<new fixture>.csv` + `data-raw/<generator>.R`,
`tests/testthat/test_name_first_class.R` (new, modelled on `test_species_first_class.R`),
`tests/testthat/test_obfuscatePed.R`.

**DONE looks like:**
- `"name" %in% getPossibleCols()` is `TRUE`; the column survives `qcStudbook()` as `character`.
- `obfuscatePed()` demonstrably removes name values (a RED test that fails before the change).
- A RED test pinning trap 3 (`removeDuplicates()` + differing names).
- Zero change to any existing assertion (the four pins in §2.8 all still hold).

**Verification:** clean regression read (`0 failed`/`0 error`, warning count unchanged from the
current 10-warning baseline); `devtools::check()` at the documented pre-existing baseline;
`lintr::lint_package()` clean on touched files. Phase 3E: **n/a** — no runtime behaviour changes.

### Slice 2 — Label rendering + toggle + documentation

**Scope:** the Diagram tab can display names, off by default.

**Touches:** `R/makePedigreeDiagramData.R` (label construction in both builders, D7; tooltip line,
D10), `R/modPedigree.R` (the toggle control + `useLabels = FALSE`, D6),
`tests/testthat/test_makePedigreeDiagramData.R`, `test_makePedigreeMatingLayout.R`,
`test_modPedigree.R`, `NEWS.Rmd` → re-rendered `NEWS.md`,
`vignettes/manual_components/_pedigree_browser.Rmd` **and**
`vignettes/articles/colony-manager-guide.qmd` (the owner's #136 comment requires the documentation
phase), `inst/extdata/ui_guidance/input_format.html` (documents the accepted column for users).

**DONE looks like:**
- Toggle defaults to ID; a name-less pedigree renders byte-identically to today.
- With names present and the toggle on, labels show the D3 form with per-node fallback (D4).
- Duplicate-occurrence nodes show their real individual's name (they currently show its ID —
  `:906` — and must stay semantically parallel).
- The dropdown still lists IDs and is still captioned "Select by id".

**Verification:** the Slice 1 matrix **plus** a mandatory live `shinytest2`/`chromote` check with
**screenshots** — not widget-JSON assertions alone. Learning 487 is explicit that JSON content
assertions cannot see clipping or overlap, and §2.3 says overlap is the expected failure mode here.
Both `edgeStyle` values must be checked (the rectilinear path is where trap 1 bites).

---

## 5. Impact analysis

| Surface | Impact | Action |
|---|---|---|
| Pedigree Browser **Table** tab + CSV export | A `name` column appears automatically | None — expected; note in docs |
| Diagram **search dropdown** | Would change silently | **Pinned** by D6 |
| Diagram **PNG export** | Shows whatever labels show | Addressed by D3 (augment keeps the ID) |
| **`obfuscatePed()`** | Would leak names | **Fixed** by D8 (Slice 1) |
| Rectilinear edge style | Breaks on any new node column | Avoided by D5 |
| Legend | Unchanged | D11 |
| LabKey/EHR path | Out of scope | D12; file trap 5 separately |
| `reportGV()`/`gvaConvergence()` | Unchanged | Guaranteed by D2 (`possible`, not `include`) |
| Existing tests | Unchanged | §2.8 — all four pins survive |

**Close-out checklists triggered** (`CLAUDE.md`): tutorial/article **and** `NEWS.Rmd` in Slice 2's own
session; `a2interactive.Rmd` deferred (it reproduces the render chain twice); lint on touched files;
`gh issue close 136` when Slice 2 ships. Citation checklist (#120): **N/A** — a display label is not
a statistic or estimator.

---

## 6. Here be dragons

1. **Multi-line (`\n`) label support is assumed, not verified.** D3's augmented form depends on the
   bundled vis-network rendering `"id\nname"` as two lines. This session could not confirm it from
   the minified bundle. **The implementing session must verify it hands-on at Pre-RED before
   committing to D3's form** — this project has twice had a design's rendering assumption fail
   exactly this way (S465's `hidden = TRUE`; S487's shape family). If it does not hold, fall back to
   a single-line `"id (name)"` form.
2. **The truncation budget (D10) cannot be derived on paper.** §2.3 gives the spacing distribution,
   but the mapping from characters to canvas pixels depends on the default font. Calibrate live.
3. **Two-line labels double label height.** Vertical pitch is `yScale = 150L` against a
   ~50-unit node, so there is more vertical than horizontal headroom — but this is unmeasured.
4. **The 10-warning regression baseline is now root-caused but unfixed** (S487's Housekeeping item).
   Do not read a changed warning count as caused by this work without checking that item first.
5. **`makePedigreeDiagramData()` has zero label test coverage**, so D7's second half ships with no
   regression net unless Slice 2 adds one.

---

## 7. Alternatives considered

| Alternative | Case for it | Why not chosen |
|---|---|---|
| **Decline / close as won't-fix** | The audit's own disposition; no name data ships anywhere; zero geometry headroom | Owner confirmed names *do* exist at some centers — the gate the audit named has partly lifted |
| **Tooltip-only** | Zero geometry risk, zero dropdown coupling, cheapest real value | Owner chose on-canvas labels; tooltip is retained *in addition* (D10) |
| **Configurable label-source column** | Flexible; would serve cross-center IDs and GVA metrics | Research showed both headline uses are *not* cheap: `resolveCrossCenterIds()` discards the non-canonical ID, and GVA metrics are not available to the Diagram tab. Cost is real, benefit speculative |
| **Name in the node `id`** | Simplest-looking | Would break click-to-navigate, `duplicateToReal`, and all five reserved-prefix guards |

---

## 8. Owner ratification record

**RATIFIED — S488, 2026-08-08, via `AskUserQuestion` (two rounds).**

**Round 1 — framing, posed *before* §3 was drafted** (the audit's own disposition was "no action", so
the framing could not be assumed):

| Question | Owner's answer |
|---|---|
| Do NPRC centers actually record animal names? | **"Some centers, inconsistently"** — names exist but are not universal; the feature must degrade gracefully per animal and may never assume presence |
| Which framing? | **Optional `name` column + off-by-default display toggle** (over: tooltip-only; decline/won't-fix; configurable label-source column) |

The first answer is load-bearing, not background: it is what makes D4's per-node fallback a hard
requirement rather than a nicety, and it is what lifted the audit's original "data-model gated / no
action" disposition. The three unchosen alternatives are recorded with their honest cases in §7.

**Round 2 — the four decisions that were genuine judgment calls rather than forced by the evidence
in §2.7** (D1, D4, D5, D7, D11, D12 are determined by the structural traps and were not put to a
vote):

| Decision | Ratified as | Over |
|---|---|---|
| **D3** label form | **Augment — ID + name** | name-only; a three-state toggle |
| **D6** search dropdown | **Pin `useLabels = FALSE`** | follow-labels-and-recaption; show "ID — name" |
| **D10** geometry | **Truncate displayed, full name in tooltip** | widen `xScale`; accept overlap |
| **D8** obfuscation | **Drop values to `NA`** | generated alias; drop the column |

All four were ratified as recommended, with no changes requested.

---

## 9. Provenance

**Research method.** Five parallel read-only research lenses (data model, render chain, layout
geometry, kinship2/domain fit, prior decisions), each of whose principal claims was then put to an
independent adversarial verifier instructed to refute it. One claim was partially refuted (an
over-stated "hard MIT-license constraint"); it is not relied on here — this design adds no package
dependency, so no licence argument is needed.

**Independent verification.** Every load-bearing fact in §2 was additionally re-derived first-hand
this session rather than accepted from an agent summary, including: the `label ≠ id` precedent
(`:906`, `:929`); the `first_name`/`second_name` allele meaning; the `qcStudbook()` `novelCols`
passthrough; the empirical column round-trip test (`name` survives, `animal_name`/`callName` are
mangled); the spacing distribution on the real 375-individual fixture; `useLabels`'s default and the
bundled widget JS that consumes it; kinship2's length-only `id` validation; and — most consequential
— `obfuscatePed()`'s scrub set. Two agent citations were found imprecise and corrected here
(`finalNodes` is at `:1237`, not `:1238`; the issue's own `:41` citation is stale, the real site is
`:77`). This follows `PROJECT_LEARNINGS.md` Learning 485's rule for consuming multi-agent research.

**Known gap.** Multi-line label rendering (§6 Dragon 1) is the one assumption this design could not
verify and deliberately does not assert.

