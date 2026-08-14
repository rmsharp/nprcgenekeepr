# Plan — Fully Reproduce the kinship2 Supplementary-Material PDF's Results

**Status:** RATIFIED (2026-08-13, this session). All 4 judgment-call questions (Q1-Q4,
§10) were ratified via `AskUserQuestion`; the owner selected this document's own
recommended option in every case, with no changes requested. See §10 for the recorded
outcome. This plan is ready for Track C, A, or B implementation (in any order) in
future sessions.
**Session:** S562 (2026-08-13)
**Origin:** Owner-directed ("duplicate the work done in that PDF... I assumed you would
need to develop new capabilities"), following up on
`docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md` (S549), which
audited `nprcgenekeepr` against the PDF and judged 2 of its 4 findings "no action,
capability-fit" rather than gaps. This plan revisits that judgment at the owner's
explicit direction: the goal here is not gap triage but literal reproduction of
everything the PDF demonstrates.
**Touches (planned, future sessions):** `R/kinship.R`, a new `R/pedigreeShrink.R` (or
similar — name TBD, §10 Q3), `R/makePedigreeDiagramData.R`, `R/columnSchema.R` (maybe —
§6 Track B), `tests/testthat/test_kinship.R` and new sibling test files, `NEWS.Rmd`.
**Does NOT touch:** the Shiny UI, by default (Track A and Track B are scoped
script-callable-only pending §10 ratification — see D-A2/D-B2); the existing
`trimPedigree()`/`removeUninformativeFounders()` (a different problem — kept unchanged,
§4); the existing `makeAvailable()`/breeding-group "available animals" concept (a
different, unrelated meaning of "available" — see the naming trap in §6.3).
**Workstream:** `docs/methodology/workstreams/DESIGN_WORKSTREAM.md`.

> **Scope.** Design (not implement) how to close the 3 remaining gaps between
> `nprcgenekeepr`'s current capability and everything demonstrated in
> `inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf`: (A) X-chromosome
> kinship (Table S2), (B) a `pedigree.shrink()` equivalent (the trimming section), and
> (C) the `edgeStyle="rectilinear"` consanguineous-marker color/width propagation the
> S549 audit's Finding #2 left as a deferred follow-up. Tracks A/B/C are independent —
> different files, no shared code — but bundled into one planning document because they
> share one origin (the same PDF, the same audit) and one goal (full reproduction).
> **Implementation is explicitly NOT bundled**: per `SESSION_RUNNER.md`'s vertical-slice
> rule, 3 different capabilities means 3+ separate implementation sessions, never one.

---

## 1. Scope caveat — carried forward from the S549 audit, still binding

The full 17-subject `fam1` pedigree is **not reconstructible** from this repository's
materials (Figure 1 lives in kinship2's *main* paper, not this supplement, and is not
bundled anywhere in this repo — confirmed by S549, re-confirmed not to have changed
since). This plan inherits that same boundary and adds one more:

**Track B (`pedigree.shrink()`) cannot be verified against the PDF's own printed
numbers at all**, even at the 10-subject Figure S1 scale. The supplement names *which*
subjects a shrink operation would trim (11–17, by id and trim-category only) but those
subjects belong to the unreconstructible 17-subject pedigree, never the 10-subject
Figure S1 subset this repo can build. There is no worked `pedigree.shrink()` example
in the PDF that this repo can numerically reproduce. Track B's verification strategy is
therefore necessarily different from Track A/C: cross-validate a ported implementation
directly against the **installed `kinship2::pedigree.shrink()`** on a self-constructed
fixture (matching the same evidence standard S549/S550 already used for the twin-kinship
work: reproduce the *real library's* output, not the *paper's* printed output, when the
paper's own worked numbers aren't reachable). This is stated here explicitly rather than
discovered partway through implementation — the fully-honest framing is "reproduce
kinship2's `pedigree.shrink()` capability, motivated by the PDF's description of it,"
not "reproduce the PDF's own shrink example," which does not exist at a reachable scale.

Track A (X-chromosome kinship) and Track C (rectilinear marker) do **not** have this
limitation — both verify directly against the PDF's own printed Table S2 values / Figure
S1's own rendered consanguineous marker, using the same 10-subject fixture S549/S550
already established.

---

## 2. Reconstructed fixture (shared across all 3 tracks, reused from S549/S550)

```r
fam1 <- data.frame(
  id   = as.character(1:10),
  sire = c(NA, NA, "1", "1", NA, NA, "3", "6", "6", "8"),
  dam  = c(NA, NA, "2", "2", NA, NA, "5", "4", "4", "7"),
  sex  = c("M","F","M","F","F","M","F","M","M","F")
)
```

Table S2 (X-chromosome kinship, the PDF's own printed values, for Track A's
verification target — transcribed via the same `pdftotext -layout` method S549 used,
not read visually):

| Pair | Table S2 (X-linked) | Table S1 (autosomal, for contrast) |
|---|---|---|
| kinship(1,1) (father, self) | 1.00 | 0.50 |
| kinship(2,2) (mother, self) | 0.50 | 0.50 |
| kinship(3,4) (full sibs, both from father 1) | 0.50 | 0.25 |
| kinship(1,3) (father-son) | 0.00 | 0.25 |
| kinship(1,4) (father-daughter) | 0.50 | 0.25 |
| kinship(2,3) (mother-son) | 0.25 | 0.25 |

(Full 10×10 table not reproduced here — the implementing session's own test fixture
should transcribe the complete matrix from the PDF directly, the same discipline S549
applied to Table S1, rather than trust this excerpt.)

---

## 3. Track A — X-chromosome kinship (Table S2)

### 3.1 Evidence: kinship2's own mechanism (deparsed from the installed namespace,
`kinship2::kinship.default`, the flat-vector method — the one structurally closest to
`nprcgenekeepr::kinship()`, not the S3 `pedigree`-object method)

```r
function (id, dadid, momid, sex, chrtype = "autosome", ...) {
  chrtype <- match.arg(casefold(chrtype), c("autosome", "x"))
  ...
  n <- length(id)
  pdepth <- kindepth(id, dadid, momid)
  if (chrtype == "autosome") {
    # ... identical to the existing algorithm nprcgenekeepr::kinship() already has ...
  } else if (chrtype == "x") {
    if (missing(sex) || length(sex) != n) stop("invalid sex vector")
    kmat <- diag(ifelse(sex > 2, NA, c((3 - sex)/2, 0)))   # founders: males self-kinship=1, females=0.5
    mrow <- match(momid, id, nomatch = n + 1)
    drow <- match(dadid, id, nomatch = n + 1)
    for (depth in 1:max(c(1, pdepth))) {
      for (j in (1:n)[pdepth == depth]) {
        if (sex[j] == 1) {                      # male: X comes from mother ONLY
          kmat[, j] <- kmat[j, ] <- kmat[mrow[j], ]
          kmat[j, j] <- 1
        } else if (sex[j] == 2) {                # female: same avg-of-parents formula as autosomal
          kmat[, j] <- kmat[j, ] <- (kmat[mrow[j], ] + kmat[drow[j], ]) / 2
          kmat[j, j] <- (1 + kmat[mrow[j], drow[j]]) / 2
        } else {
          kmat[, j] <- kmat[j, ] <- NA; kmat[j, j] <- NA   # unknown sex: no defensible value
        }
      }
    }
  }
  kmat
}
```

Three facts, each load-bearing for the design decision below:

1. **kinship2 unifies autosomal and X-linked kinship under one function**, dispatched by
   a `chrtype` parameter — not two separate functions. The autosomal branch is
   byte-identical in spirit to `nprcgenekeepr::kinship()`'s existing algorithm (same
   depth-loop, same `mrow`/`drow` naming already noted in the twin-kinship plan's §1.3).
2. **The X-linked branch needs one new input `kinship()` does not currently have: `sex`.**
   kinship2's own `kinship.default()` signature makes `sex` a *formal* parameter but only
   *validates* it (`missing(sex)`/length check) inside the `chrtype == "x"` branch —
   `chrtype = "autosome"` callers can omit it entirely. This is the direct precedent for
   how to add it to `nprcgenekeepr::kinship()` without disrupting any existing call site.
3. **The MZ-twin correction (already ported into `nprcgenekeepr::kinship()`, S551)
   applies identically inside the X-linked branch** in kinship2's own S3 `pedigree`
   method (`if (havemz) kmat[mzindex] <- (diag(kmat))[mzindex[, 1]]` appears inside both
   the autosome and the x branch). A design that added `chrtype` without also applying
   the existing `havemz`/`mzindex` correction inside the new X-linked loop would silently
   regress twin-kinship parity for any colony with both a declared MZ pair *and* an
   X-linked kinship request — a real, if narrow, trap.

### 3.2 Design decision D-A1 — where does X-linked kinship live?

| Option | Mechanism | Pros | Cons | Verdict |
|---|---|---|---|---|
| **(a) Extend `kinship()` itself** with `chrtype = "autosome"` (default) and a new `sex = NULL` parameter, mirroring kinship2's own unification and the twin-kinship plan's own D1 precedent (extend, don't duplicate) | One algorithm, one source of truth; `chrtype = "autosome"` (the default) is fully backward-compatible — every existing call site (all now carrying `twinRelations = NULL` too) is unaffected; the X-linked depth-loop is structurally close enough to the existing autosomal loop that this is a moderate, not large, diff | A third orthogonal parameter dimension on an already 6-parameter function (`id, father.id, mother.id, pdepth, sparse, twinRelations, chrtype, sex` = 8); `sex` becomes conditionally-required exactly the same awkward shape D2 of the twin-kinship plan already rejected doing for `twinRelations`'s own validation — but here kinship2's own precedent accepts that shape, so it is not a novel risk | **Recommended** |
| **(b) A new, separate function** (e.g. `kinshipXChrom()`) reimplementing the depth-loop traversal independently for the X-linked case | Keeps `kinship()`'s signature untouched | Duplicates the recursive traversal a second time (the same DRY objection the twin-kinship plan's own D1 raised and rejected for the analogous choice); the MZ-twin correction (§3.1 point 3) would need porting into *two* places instead of one, a real correctness trap if the second copy drifts | Rejected as primary, same reasoning as the ratified twin-kinship D1 |

**Recommendation: (a).** Consistent with the already-ratified precedent (twin-kinship
D1) for the same class of decision.

### 3.3 Design decision D-A2 — how far does propagation go?

The twin-kinship plan's own Slice 2/3 propagated `twinRelations` through 4 script
functions and the full Shiny app, because that was a real, silently-wrong-today
*correctness* gap in every kinship-driven calculation. X-chromosome kinship is
different: it is a **new, opt-in analysis mode**, not a correctness fix to an existing
one — nothing today is silently wrong for lack of it, and the S549 audit's own Finding
#4 impact assessment (no existing BACKLOG/GitHub item requests X-linked-specific
analysis; the package's stated mission is genome-wide/autosomal relatedness) still
holds as *context*, even though the owner has now overridden its "no action" verdict for
the reproduction goal itself.

| Option | Scope | Pros | Cons | Verdict |
|---|---|---|---|---|
| **(a) Core algorithm only** — `kinship(..., chrtype=, sex=)` ships as a script-callable capability; `reportGV()`/`gvaConvergence()`/`createSimKinships()`/`cumulateSimKinships()` and the Shiny app are **not** touched | Fully satisfies "reproduce Table S2"; smallest, cleanest, most reversible slice; matches the audit's own capability-fit read that this isn't a targeted use case yet | A script user wanting X-linked genetic-value/breeding-group analysis has no path to it without calling `kinship()` directly and building their own downstream logic | **Recommended** |
| **(b) Full propagation**, mirroring the twin-kinship plan's 3-slice shape exactly (script functions, then Shiny) | Symmetric with the twin-kinship precedent; a complete capability | Substantially larger effort for a capability with no identified user demand (per the audit itself); `gvaConvergence()`'s own convergence heuristics have not been checked for X-linked-kinship-range assumptions (higher ceiling values — male self-kinship = 1.0, not 0.5) any more than they were for MZ-twin identity (an open dragon the twin-kinship plan itself flagged and left unresolved, §6 item 3 there) | Deferred, not rejected — a legitimate future extension if real demand appears |

**Recommendation: (a).** This is the judgment call this plan puts to ratification
(§10 Q1) — it is the one place Track A's scope could reasonably grow much larger.

### 3.4 Vertical slice — Track A, one session

**Scope:** `kinship(id, father.id, mother.id, pdepth, sparse = FALSE,
twinRelations = NULL, chrtype = "autosome", sex = NULL)` gains the X-linked branch,
ported from §3.1 verbatim (adapted to nprcgenekeepr's existing `n+1`
placeholder-row convention rather than kinship2's own `nomatch = n+1` idiom, to stay
consistent with the function's own established style). MZ-twin correction (§3.1 point 3)
applies inside the new branch too, reusing the same `mzgrp`/`mzindex` structures already
built once at the top of the function (no duplication — they are chrtype-agnostic).

**What does NOT change:** the `chrtype = "autosome"` (default) code path — byte-for-byte
identical output to today, provably so since the new branch is only reached when
`chrtype == "x"`; all 4 script-callable functions and the Shiny app (§3.3 D-A2).

**Files to touch:** `R/kinship.R` (new parameters, new branch); `tests/testthat/
test_kinship.R` (new test block: the §2 fixture's full X-linked matrix against Table
S2's transcribed values — father-daughter = 0.50 not 0.25 is the load-bearing
assertion that distinguishes a correct port from an accidental autosomal fallback;
male self-kinship = 1.0; an `chrtype = "autosome"` regression assertion pinning
backward compatibility; a combined X-linked + MZ-twin fixture, since §3.1 point 3
identified that interaction as untested by kinship2's own supplement and worth this
package's own explicit coverage).

**DONE looks like:** `devtools::check()` 0 errors/0 warnings; new tests pass, including
the father-daughter/male-self-kinship/twin-interaction assertions; full clean
regression read shows no new failures across the (now 8, post-twin-work)
production call sites and however many test call sites exist at implementation time
(re-count via the same AST method S550 used — do not trust this document's number,
which predates this session's own possible drift).

**Verify:** targeted `test_kinship.R` run; full clean regression read; full
`devtools::check()`.

**Session boundary:** one session, independent of Tracks B/C.

---

## 4. Track B — a `pedigree.shrink()` equivalent

### 4.1 Evidence: kinship2's own algorithm (deparsed from the installed namespace)

`pedigree.shrink(ped, avail, affected = NULL, maxBits = 16)` is an **orchestrator**
over 5 internal helpers, not a single self-contained function:

1. **`bitSize(ped)`** — trivial: `bits = 2 × nNonFounder − nFounder`. The stopping
   criterion.
2. **`findUnavailable(ped, avail)`** — iteratively removes **terminal** (leaf, no
   children) individuals with `avail == FALSE`, re-computing terminal status each pass
   (removing a leaf can make its parent a new leaf), until no more such removals are
   possible; then further excludes founders left with no available descendant
   (`excludeUnavailFounders`) and "stray marry-in" individuals
   (`excludeStrayMarryin`) — 2 more helpers this plan has not yet deparsed in full
   (flagged as an open item for the implementing session's own Pre-RED, not assumed
   here).
3. **`findAvailNonInform(ped, avail)`** — marks an *available* individual as
   effectively unavailable-for-removal-purposes if they have no children (not a
   parent) **and** are unaffected (`affected == 0`, `NA`-safe) **and** both their own
   parents are already available — i.e., they add no genotype information beyond what
   their parents already supply — then re-uses `findUnavailable()` to actually drop
   them.
4. **`findAvailAffected(ped, avail, affstatus)`** — the bit-size-reduction workhorse,
   called in `NA` → `0` → `1` affected-status priority order until `maxBits` is
   satisfied: for every available, non-parent individual matching the target
   `affstatus`, *trial-removes* each one independently, measures the resulting
   `bitSize`, and commits whichever single removal minimizes it (ties broken by
   `runif()` — kinship2's own non-deterministic tie-break, a trap noted in §4.3).
5. **`pedigree.trim(removeID, ped)`** — the actual row-removal primitive both 2 and 4
   call, trivial (`ped[-match(removeID, ped$id), ]` on kinship2's own S3 `pedigree`
   object).

`pedigree.shrink()` itself wires these into: trim unavailable → loop trim
available-but-uninformative until no change → loop trim by affected-status priority
(NA, then unaffected, then affected) one individual at a time until `bitSize ≤ maxBits`
or no more eligible individuals exist.

### 4.2 What nprcgenekeepr already has, and does not (confirmed by direct reading, not
assumed)

- **`affected`** already exists as an optional logical pedigree column (`R/
  columnSchema.R:23`, issue #133) — consumed today only by
  `makePedigreeDiagramData()`'s node-shading. **Directly reusable** for Track B without
  a new column.
- **No `available`/genotyped concept exists** in the sense kinship2's own `avail`
  argument means (a per-individual "do we have a DNA sample / genotype for this
  animal" flag). `R/makeAvailable.R`'s `available` is a **different, false-cognate**
  concept — a candidate pool for breeding-group formation (`modBreedingGroups.R`), not
  genotyping status. **This is a real naming trap** (§6.3) the implementing session
  must not conflate.
- **`trimPedigree()`/`removeUninformativeFounders()`** solve a **different** problem
  (already established by S549 Finding #3: proband-ancestor completeness, not
  bit-size/genotyping-cost reduction) and are **not** reused or modified by this track
  — a new, separate function family is the right shape, not an extension of these.
- **`bitSize` has no existing equivalent** anywhere in the package (confirmed by grep
  for `bitSize`/`bit.size`/`bits` — no matches outside this plan document and the
  audit).

### 4.3 Design decisions

**D-B1 — Naming**, forced by §4.2's naming trap: the new parameter must **not** be
called `available` (collides with the breeding-group concept in the same package's
public vocabulary, even though it is a different function's local parameter — a reader
skimming exported-function signatures should not have to disambiguate two unrelated
meanings of the same word). Recommend `genotyped` (states the actual real-world meaning
directly — "do we have a genotype for this individual" — rather than the more
abstract/overloaded `avail`, which is *also* kinship2's own name and *also* collides).
Function name: `shrinkPedigree()`, matching `trimPedigree()`'s own verb-first
camelCase convention. **Judgment call, ratify at §10 Q2.**

**D-B2 — Determinism**: kinship2's own `findAvailAffected()` breaks bitSize ties via
`runif()` against R's global RNG state — the *same* input pedigree can produce a
*different* trimmed result run-to-run unless the caller manages `set.seed()`
externally. This is a real property of the reference implementation, not a bug this
plan should silently "fix" without flagging: a faithful port reproduces it (bit-for-bit
behavioral parity with kinship2, including its non-determinism); a deterministic port
(e.g. break ties by lowest `id`, or by insertion order) diverges from kinship2's own
behavior but is more testable and more predictable for a colony manager relying on the
output. **Judgment call, ratify at §10 Q3.**

| Option | Mechanism | Pros | Cons | Verdict |
|---|---|---|---|---|
| **(a) Deterministic tie-break** (lowest `id`, string-sorted) | Reproducible test assertions; predictable for a real user re-running the same shrink | Diverges from kinship2's own reference behavior at the tie-break step specifically (though bit-size *targets* are still met identically) | **Recommended** |
| **(b) Faithful `runif()` port** | Bit-for-bit behavioral parity with kinship2, including its own non-determinism | Test assertions can only pin bit-size trajectories and *set* membership at each threshold, never a specific removal order when ties occur; a real user gets a different answer on every run for a tied pedigree, with no way to reproduce a prior result without externally managing a seed | Rejected as primary — this package's own existing conventions (e.g. `createSimKinships()`'s Monte Carlo work) always accept/document a `seed` parameter explicitly rather than relying on ambient global RNG state; a silent `runif()` dependency would be a new, undocumented pattern |

**Recommendation: (a).**

**D-B3 — Shiny wiring**: does this track ship a Shiny UI, or stay script-callable-only
(the `createSimKinships()`/`cumulateSimKinships()` precedent — confirmed by the
twin-kinship plan's own §2.4 to have **zero** in-package callers, purely
script-facing)?

| Option | Scope | Pros | Cons | Verdict |
|---|---|---|---|---|
| **(a) Script-callable only** | Matches the audit's own "not this package's targeted use case" read while still satisfying full reproduction; smallest slice; a linkage-analysis/genotyping-cost workflow is plausibly always going to be script-driven (external genotyping data merged in), not something the Shiny app's existing tabs are shaped around | No discoverable UI entry point for a non-scripting colony manager | **Recommended** |
| **(b) New Shiny tab/module** | Full parity with kinship2's own use as an interactive tool | A new UI surface for a capability with no identified demand (mirrors D-A2's own reasoning); `affected`/`genotyped` per-individual data entry via a Shiny upload flow is a nontrivial UX design question this document has not scoped at all | Deferred, not rejected |

**Recommendation: (a).** Same reasoning shape as D-A2.

### 4.4 Vertical slice — Track B, one session (with a Pre-RED sub-scope note)

**Scope:** new `R/shrinkPedigree.R`: `shrinkPedigree(ped, genotyped, affected = NULL,
maxBits = 16)`, porting §4.1's 5-helper algorithm over `nprcgenekeepr`'s own
data-frame pedigree representation (no kinship2 S3 `pedigree` object involved —
`nprcgenekeepr` pedigrees are plain data frames, the same distinction the S549 audit's
own Finding #3 already noted). `bitSize()` ports as a trivial one-liner (internal,
`.bitSize()` or similar, `# noRd`). `findUnavailable()`'s 2 sub-helpers
(`excludeUnavailFounders`/`excludeStrayMarryin`, §4.1 point 2) are **not yet
deparsed by this plan** — the implementing session's own Pre-RED must read them
(`getFromNamespace("excludeUnavailFounders", "kinship2")` and the `Strays` sibling)
before writing RED tests against assumed behavior, exactly the discipline the
twin-kinship plan's own §6 dragon 4 modeled for a smaller, analogous gap.

**What does NOT change:** `trimPedigree()`/`removeUninformativeFounders()` (a
different function family, per §4.2); the `affected` column's existing consumer
(`makePedigreeDiagramData()`, unaffected — this track only *reads* `affected`, never
writes it); `R/makeAvailable.R`'s own `available`-animal-list concept (untouched,
per the naming-trap boundary in §4.3 D-B1).

**Files to touch:** new `R/shrinkPedigree.R` (exported function + 4-5 internal
helpers); new `tests/testthat/test_shrinkPedigree.R` — verification strategy per §1:
cross-validate against **installed `kinship2::pedigree.shrink()`** on a
self-constructed fixture built specifically to exercise all 3 removal phases
(some genotyped-unavailable leaves, some genotyped-but-uninformative individuals,
enough bulk to force at least one affected-status-priority removal past `maxBits`),
asserting the same final `id` set and the same bit-size trajectory as kinship2's own
output on the identical fixture (with `set.seed()` pinned on the kinship2 side to
make its own tie-break reproducible for the comparison, per D-B2's own finding that
the reference itself is non-deterministic without one).

**DONE looks like:** `devtools::check()` 0 errors/0 warnings; the cross-validation
test passes (same trimmed-id set, same bit-size trajectory, as kinship2's own
`pedigree.shrink()` on the shared fixture); a documented `@examples` block
demonstrating the function against the bundled `examplePedigree`; full clean
regression read shows no new failures anywhere else in the package (a new,
independent file — zero expected interaction, but the read still confirms it).

**Verify:** targeted `test_shrinkPedigree.R` run; full clean regression read; full
`devtools::check()`; `lintr::lint_package()` on the new file.

**Session boundary:** one session, independent of Tracks A/C. The two
not-yet-deparsed sub-helpers (§4.1 point 2) may force this session's own Pre-RED to
re-scope narrower if they turn out to carry unexpected complexity — flagged here so
that possibility is not a surprise.

---

## 5. Track C — finish the `edgeStyle="rectilinear"` consanguineous-marker propagation

### 5.1 Evidence: the exact gap (`R/makePedigreeDiagramData.R`,
`.addRectilinearWaypoints()`)

Already fully scoped by the S549 Finding #2 deferred-follow-up note and confirmed by
direct reading this session (`R/makePedigreeDiagramData.R:1489-1531`, the "D2:
mate-line dogleg" loop): when a marked mate edge (one whose `color`/`width` were set
by `makePedigreeMatingLayout()`'s own consanguinity check, S555) gets D2-dogleg-rerouted
because its parent sits at a different generation than its own mating unit, the loop
builds 2 new projection edges (`newEdgeList`) but does not look up the original edge's
`color`/`width` before the original gets dropped (`dropMateEdge`) — the replacement
edges fall through to the generic `edgeColor <- "#2B7CE9"` / `NA_real_` width stamped
later (`R/makePedigreeDiagramData.R:1573-1574`). This is a **small, local, already
narrow-scoped fix** — the smallest of the 3 tracks by a wide margin — unlike Tracks
A/B, which are new capabilities.

### 5.2 No design decision needed — mechanically forced by the existing precedent

The fix mirrors the KEPT-edges color-preservation precedent already established a few
lines below in the same function (`R/makePedigreeDiagramData.R:1534-1554`, issue #137
D10 / S549 Finding #2's own `edgeStyle="direct"` fix): inside the `sides` loop
(§5.1), before dropping the original mate edge, look up its `color`/`width` from
`edges` (matching `edges$from == side$nodeId & edges$to == U`) and stamp both onto
the 2 new projection edges instead of the generic fallback — falling back to the
generic blue/`NA` width only when the original edge had no `color`/`width` set at all
(an ordinary, non-consanguineous mating), exactly mirroring the KEPT-edges guard's own
"only add the column fresh when it doesn't already exist" logic.

### 5.3 Vertical slice — Track C, smallest of the 3, one session (or foldable into
whichever of Track A/B's sessions has spare scope — see §10 Q4)

**Scope:** the D2 loop (`R/makePedigreeDiagramData.R:1513-1529`) gains a lookup of the
original mate edge's `color`/`width` (from `edges`, matched by `from`/`to`) before
building each projection edge's `data.frame()`, stamping those values instead of
`NA`/the generic default.

**Files to touch:** `R/makePedigreeDiagramData.R`; `tests/testthat/
test_makePedigreeDiagramData.R` (or the `makePedigreeMatingLayout` sibling, confirm
exact file at Pre-RED) — a new test using the **already-existing verified 12-row
fixture** S555's own `PROJECT_LEARNINGS.md` entry constructed specifically for this
exact scenario (an anchor double-anchoring 2 differently-gen'd units, one
consanguineous), asserting the marked edge's color/width survives onto both
projection edges.

**DONE looks like:** the 12-row fixture's marked mate edge, after D2 dogleg rerouting,
shows the consanguinity color/width on both projection edges, not the generic
fallback; `devtools::check()` 0 errors/0 warnings; full clean regression read;
`lintr::lint_package()` 0 lints.

**Verify:** targeted test run; full clean regression read; `devtools::check()`;
live `shinytest2` smoke test optional (a rendering-detail fix, not a new interaction
pattern — Phase 3E can likely rely on the targeted unit test plus a static review of
the rendered fixture, but the implementing session should state this explicitly
rather than silently skip Phase 3E).

**Session boundary:** one session, independent of Tracks A/B (or folded per §10 Q4).

---

## 6. Cross-track notes

### 6.1 Why 3 tracks in 1 plan, not 3 plans

All 3 originate from the same audit, the same PDF, and the same owner directive; a
single plan avoids 3x-duplicating this section's shared context (§1, §2) and the
provenance/ratification bookkeeping. They remain **independently implementable and
independently session-scoped** (§3.4, §4.4, §5.3 each stand alone) — this is a
grouping-for-planning-economy choice, not a bundling-for-implementation one. The
`SESSION_RUNNER.md` vertical-slice rule (`FM #26`) still applies at implementation
time: no future session may implement more than one track and call it "one slice."

### 6.2 Ordering recommendation (not forced — owner may reorder freely at pickup time)

**C, then A, then B** — smallest/lowest-risk first (C is a small bugfix-shaped diff
with a fixture already built), then A (a moderate, well-precedented signature
extension), then B (the only genuinely novel capability, with the most open evidence
gaps — §4.1 point 2's undeparsed helpers). This is a suggestion for whoever picks up
implementation, not a constraint this plan enforces.

### 6.3 The `available` naming trap (restated for visibility — already resolved by
D-B1, but worth a standalone callout since it is the single easiest mistake a rushed
implementing session could make)

`R/makeAvailable.R`'s `available`/`makeAvailable()` (breeding-group candidate pools,
`modBreedingGroups.R`) and kinship2's own `avail` argument (genotyping status,
`pedigree.shrink()`) are **unrelated concepts that happen to share an English word**.
Track B's own parameter is named `genotyped` (D-B1) specifically to avoid this
collision — an implementing session tempted to rename it back to `avail`/`available`
for closer fidelity to kinship2's own argument name should re-read this section first.

---

## 7. Close-out checklist mapping (per track, applies to whichever session implements
each)

- **Citation checklist (issue #120):** likely N/A for all 3 tracks (capability/fix
  additions to existing statistical functions, not new *displayed* statistics in the
  Shiny UI — Tracks A/B are script-callable-only per §3.3/§4.3's own recommendations,
  Track C is a rendering-correctness fix). Each implementing session should state this
  conclusion explicitly per the twin-kinship plan's own established precedent, rather
  than silently omit it.
- **Tutorial/article checklist (Session 436):** N/A for Track A/B under the
  script-callable-only recommendation (no new Shiny tab/control); applies to Track C
  only if the fix is judged worth a callout in `vignettes/articles/pedigree-diagram.qmd`'s
  existing "Consanguineous marker" section (a documentation-polish nice-to-have, not
  forced).
- **`NEWS.Rmd` entry checklist (Session 448):** applies to all 3 — Track A/B are new
  exported functions/parameters; Track C is a user-visible (if subtle) rendering fix.
- **`a2interactive.Rmd` checklist (Session 450/478):** applies to Track A (new
  parameter on the already-documented `kinship()`) and Track B (an entirely new
  script-callable function) — per that checklist's own standing rule, **deferred**,
  not same-session, until the capability has stabilized.
- **GitHub issue close-out:** none of the 3 tracks has a GitHub issue yet. Recommend
  filing 3 separate issues (matching the "recommend, don't unilaterally file"
  precedent) at whichever session picks up each track's implementation — not filed by
  this planning session.
- **Lint / `_pkgdown.yml` reference-coverage:** standard, per-implementing-session.

---

## 8. Provenance

Produced in Session S562 (2026-08-13) from direct evidence gathered this session:

1. `docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md` (S549) — the
   triggering findings (#2 deferred follow-up, #3, #4) and the 10-subject fixture,
   reused directly.
2. `docs/planning/twin-relations-kinship-computation-plan.md` (S550) — the direct
   structural precedent for D-A1 (extend vs. duplicate) and for this document's own
   section shape; its own §2.4 AST call-site counts are cited as needing re-verification
   at implementation time, not trusted as still-current.
3. kinship2's own `kinship.default`/`kinship.pedigree` (X-linked branch),
   `pedigree.shrink`, `bitSize`, `findUnavailable`, `findAvailNonInform`,
   `findAvailAffected`, `pedigree.trim` — all deparsed directly from the installed
   namespace this session (`getS3method()`/direct object printing), not the Rd
   documentation alone, matching S550's own evidence standard.
4. Direct reads of `R/kinship.R` (current, post-S551 twin-kinship state),
   `R/trimPedigree.R`, `R/removeUninformativeFounders.R`, `R/columnSchema.R`,
   `R/makeAvailable.R`, `R/makePedigreeDiagramData.R` (`.addRectilinearWaypoints()`
   in full) — all this session, all cited with file:line above.
5. `excludeUnavailFounders`/`excludeStrayMarryin` (kinship2's own 2 sub-helpers inside
   `findUnavailable()`) were **not** deparsed this session — flagged in §4.4 as an
   open Pre-RED item for Track B's own implementing session, not assumed.

No adversarial-verification pass was run this session, matching the twin-kinship
plan's own disclosed limitation. Flagged rather than silently omitted — particularly
relevant to §3.1 point 3 (the X-linked/MZ-twin interaction claim) and §4's algorithm
transcription, both load-bearing and independently checkable but not independently
re-verified by a second pass this session.

---

## 9. Alternatives considered

| Decision | Recommended | Rejected alternative | Why rejected |
|---|---|---|---|
| Track A mechanism | Extend `kinship()` with `chrtype`/`sex` | Separate `kinshipXChrom()` | Duplicates the recursive traversal; MZ-twin correction would need porting twice |
| Track A propagation | Core algorithm only | Full 4-function + Shiny propagation | No identified demand beyond reproduction itself; disproportionate to the stated goal |
| Track B naming | `genotyped` / `shrinkPedigree()` | `avail` / kinship2's own names | Collides with the pre-existing, unrelated `available`-animal-list concept |
| Track B determinism | Deterministic tie-break | Faithful `runif()` port | Matches this package's own existing explicit-seed convention; avoids unreproducible test assertions and unreproducible real-user results |
| Track B UI | Script-callable only | New Shiny tab | No identified demand; nontrivial UX design not scoped here |
| Grouping | 1 plan, 3 independently-sliced tracks | 3 separate plan documents | Shared context/provenance; tracks remain independently implementable regardless |

---

## 10. Ratification status — forced vs. judgment-call decisions

**Forced by evidence already gathered:** D-A1's underlying mechanism choice is not
independently forced (see the table in §3.2) but follows the already-ratified
twin-kinship D1 precedent so closely it is presented as a strong recommendation, not a
fresh open question; Track C (§5) has no judgment call at all — mechanically forced by
the existing KEPT-edges precedent.

**Genuine judgment calls requiring `AskUserQuestion` ratification before this plan is
RATIFIED:**

**Q1 (D-A2) — Track A propagation scope:**
- **Option A — Core algorithm only.** `kinship()` gains `chrtype`/`sex`; nothing else
  changes. *(Recommended.)*
- **Option B — Full propagation**, mirroring the twin-kinship plan's 3-slice shape
  (script functions, then Shiny).

**Q2 (D-B1) — Track B naming:**
- **Option A — `genotyped` parameter, `shrinkPedigree()` function name.** *(Recommended.)*
- **Option B — Match kinship2's own names (`avail`, `pedigree.shrink`-style)**, accepting
  the collision risk with the existing `available`-animal-list concept.

**Q3 (D-B2) — Track B determinism:**
- **Option A — Deterministic tie-break** (lowest id). *(Recommended.)*
- **Option B — Faithful `runif()` port**, matching kinship2's own non-determinism
  exactly.

**Q4 (D-B3, plus a scheduling question not yet asked above) — Track B UI, and Track C
folding:**
- **Option A — Track B script-callable only; Track C stays its own session.**
  *(Recommended for Track B's own UI question.)*
- **Option B — Track B gets a Shiny tab.**
- *(Track C folding is a scheduling convenience, not a design question — left to
  whichever future session picks up implementation, not ratified here.)*

### Ratification outcome (2026-08-13, this session)

All 4 questions were posed via a single `AskUserQuestion` call. The owner selected
**this document's own recommended option in every case, with no changes requested**:

- **Q1 (D-A2):** Option A — core algorithm only. `kinship()` gains `chrtype`/`sex`;
  the 4 script-callable functions and the Shiny app are explicitly **out of scope**
  unless a future session finds real demand. **RATIFIED.**
- **Q2 (D-B1):** Option A — `genotyped` parameter, `shrinkPedigree()` function name.
  **RATIFIED.**
- **Q3 (D-B2):** Option A — deterministic tie-break (lowest id), diverging from
  kinship2's own `runif()`-based non-determinism at the tie-break step only.
  **RATIFIED.**
- **Q4 (D-B3):** Option A — Track B stays script-callable only, no Shiny tab.
  **RATIFIED.**

This plan is now **RATIFIED** in full. Implementation begins with whichever track a
future session picks up (§6.2's C→A→B ordering is a suggestion, not a constraint).
This plan document itself changes no `R/`, `tests/`, or `man/` content — that remains
true after ratification, matching the twin-kinship plan's own precedent that
ratification closes the *design* session, not the implementation one.

**Note on GitHub issue filing:** none of the 3 tracks has a GitHub issue yet (§7). The
owner may wish to file 3 (one per track) before implementation begins, matching the
established "recommend, don't unilaterally file" precedent — not resolved here.
