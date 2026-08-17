# Pedigree Diagram: Duplicate-Occurrence-Selection Centering Fix — Investigation

> **STATUS: INVESTIGATION ONLY — NO DESIGN RATIFIED.** This document is deliberately **not** an
> implementation plan. Session 598 (2026-08-16) ran a research/verify/adversarial-critique
> workflow against the previously-designed fix and found a genuine, live-verified correctness gap
> *inside the design's own claimed scope* (§5.2). Presented with that finding via `AskUserQuestion`,
> the owner chose **"Hold — needs a redesign session"** over shipping the flawed design as-is or
> patching it with an unverified guard invented on the spot. This document exists so a future
> session does not have to re-derive any of the evidence below — it should start directly at §6
> (Open Questions a Redesign Must Resolve).

## 0. What this addresses (and what it deliberately does not)

`docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md` (S592, implemented S593-S596
as Tracks 1-3) disclosed 2 separate costs of Track 3's parent-span clamp:

1. **Child-centering quality degradation** (9→53 of 251 edges over a 200-unit threshold) — **this
   document's subject.**
2. **D1 bar-vs-bar x-overlap residual worsening** (9→116 hits) — a *different* problem, explicitly
   out of scope here. `BACKLOG.md`'s Track 3 follow-up item now names a separate, not-yet-designed
   "bar-aware detect-and-jog repair" for that one; this document does not touch it.

The collision-avoidance plan's own §2.4/§8/§9 name a **deferred, not-adopted** third mechanism —
the "duplicate-occurrence-selection root fix" — as the way to improve child-centering beyond what
Track 3's clamp alone achieves. `BACKLOG.md` (found S596, 2026-08-16) calls this candidate "Track
4" informally, matching the collision-avoidance plan's own §8/§9 wording. **This session confirmed
that name is an unfortunate collision, not a new track number** — see §1.

## 1. Naming collision, flagged so a future session doesn't get confused

**"Track 4" already means something else, ratified and shipped:**
`docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` — the `preferAnchor()`
gen→mateCount→id tie-break and `matingUnits$gen == genOf[[anchor]]` invariant (which `gen` row a
mating unit lands on). This is explicitly cited as "already decided, do not re-litigate" by the
collision-avoidance plan's own §1.1, and confirmed **completely untouched** by everything in this
document (§4.1 item 5).

The collision-avoidance plan's §8/§9 separately use the bare word "Track 4" as shorthand for the
duplicate-occurrence-selection fix (`docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`
§2.4: *"matching Track 4 §8's own precedent for 'not adopted, not precluded' candidates"* — itself
a slightly garbled cross-reference, since §8 is a section of the *same* document, not of the
gen-aware-anchor plan). `BACKLOG.md` inherited this shorthand. **Recommendation for whatever plan
eventually ships this fix: do not call it "Track 4."** This document refers to it as **"the
duplicate-occurrence-selection fix"** or **"fix (a)"** (its name in the original S592 candidate
design, §2 below) throughout, and a future session should pick a name that doesn't collide with
the shipped gen-aware-anchor plan — e.g. folding it into a renumbered slice of a fresh plan
document, or simply "the centering fix."

## 2. The original design (S592, historical input — Verified, Not Ratified as originally stated)

Extracted verbatim from the S592 12-agent research/design workflow's own journal transcript
(`/Users/rmsharp/.claude/projects/-Users-rmsharp-Development-nprcgenekeepr/5f68259f-6622-4bdd-8531-d2c60ad9fcb0/subagents/workflows/wf_57184bfd-eb7/journal.jsonl`,
entry index 19 — still present as of this session), candidate **"Direct Three-Point Patch: Local-Occurrence
Selection + Bar Row Offset + Parent-Span Clamp"**. Two of its three fixes already shipped near-verbatim:
fix (b) = Track 1 (D1 bar row offset), fix (c) = Track 3 (parent-span clamp). **Fix (a)
(local-occurrence substitution) is this document's subject — never adopted.**

**Root cause identified at design time:** `.positionMatingUnitForest()`'s child-centering formula
(`finalUnitX[[uid]] <- (min(kidX) + max(kidX)) / 2`) always resolves a child to its one **real**
occurrence, even when that child is *also* a duplicated individual (mates a co-sibling under the
same union). A duplicated child's real occurrence reflects wherever *her own* anchored subtree
settled — not her position as a sibling under the union being centered.

**Proposed fix (3-pass restructuring):**

```r
## Pass 1 (UNCHANGED formula -- today's exact code)
rawFinalUnitX[[uid]] <- (min(kidX) + max(kidX)) / 2   # kidX from REAL occurrences only

## rawDupX pre-pass (Track 6 Sec 2.2 formula, unchanged arithmetic)
rawDupX <- rawFinalUnitX[duplicates$matingUnitId] + minSep * 0.4

## Pass 2 (NEW -- fix a): substitute a child's real x with its duplicate's x IFF that
## duplicate's union has an OTHER parent who is ALSO a child of the SAME union U
for (each union U, each kid in its children) {
  dupRows <- which(duplicates$realId == kid)
  qualifying <- Filter(dupRows, function(dr) {
    v <- duplicates$matingUnitId[dr]
    otherParent <- setdiff(c(matingUnits$sire[v], matingUnits$dam[v]), kid)
    length(otherParent) == 1 && otherParent %in% kids   # otherParent also a child of U
  })
  if (any qualifying) effectiveX[kid] <- rawDupX[qualifying[radix tie-break][1]]
}
correctedFinalUnitX[[uid]] <- (min(effectiveX) + max(effectiveX)) / 2

## Pass 3 = Track 3's clamp (ALREADY SHIPPED) -- consumes correctedFinalUnitX
```

**Design-time verified number** (P1×P2/A/Y/W/C2 fixture, issue #160 comment 1): Y's real
occurrence anchors `__union_4` (Y×W); her duplicate `__dup_Y_1` sits at `__union_3` (A×Y,
consanguineous). Substituting: `correctedFinalUnitX[__union_1]` = (A=-75 + dup-Y=63)/2 = **-6**,
vs. the reported buggy raw 90 (outside the [-195,0] parent span).

**Design's own disclosed limitations:** narrow scope (only fires for this exact structural
pattern); no compounding across chained consanguineous relationships (Pass 2 always reads Pass-1
raw values); O(unions×duplicates) inner loop; doesn't touch the duplicate dashed-connector edge.
**Not disclosed at design time, found this session (§5.2): can move the union's center in the
wrong direction when one individual mates 2+ different co-siblings of the same union.**

## 3. Fresh verification against current HEAD (this session)

Tracks 1-3 have all shipped since the design above was written — this section re-derives its
claims against the actual current code rather than trusting them carried forward.

### 3.1 Exact current insertion point

`R/makePedigreeDiagramData.R`, current pipeline order inside `.positionMatingUnitForest()`:

| Step | Lines | What it does |
|---|---|---|
| Pass 1 (unchanged raw formula) | **966-974** | `finalUnitX[[uid]] <- (min(kidX)+max(kidX))/2` |
| **← fix (a)'s Pass 2 would insert here** | **974-994** | (gap — nothing here today) |
| Track 3's clamp (shipped) | **994-1003** | `finalUnitX[[uid]] <- min(max(finalUnitX[[uid]], lo), hi)` |
| Write clamped values to `nodes$x` | **1005** | `nodes$x[match(matingUnits$id, nodes$id)] <- ...` |
| `dupX` (Track 6 §2.2 formula, unchanged) | **1007-1010** | `dupX <- finalUnitX[duplicates$matingUnitId] + minSep*0.4` — now reads the **clamped** value |

Confirms the design's own stated splice point exactly, at these concrete current line numbers.
`dupX`'s formula is unchanged; only the fact that it now reads a *clamped* `finalUnitX` (Track 3
wasn't in the picture at design time) is new — fix (a)'s Pass 2 must land before line 994 so both
the clamp and `dupX` consume its corrected value.

### 3.2 Data structures — confirmed unchanged

- `childEdges$to` (`.buildMatingUnitForest()`, lines 511-519): built exclusively from
  `ids <- as.character(ped$id)` — **always a real id**, never a `__dup_*` id. No code path assigns
  a duplicate id here.
- `duplicates$realId` / `duplicates$matingUnitId` (lines 490-499): both still exist with the same
  meaning (`realId` = the individual being duplicated, `matingUnitId` = the union where this
  duplicate occurrence sits).
- `matingUnits$sire` / `matingUnits$dam` (lines 461-462): built exclusively from real pedigree
  rows — a duplicate's "other parent" (used in Pass 2's qualifying check) is **always** a real id,
  never itself a duplicate id (resolves one of the critique's asked-about edge cases outright, §5.2).

### 3.3 Track 1 / Track 2 interaction — confirmed none

`.positionMatingUnitForest()` has a single call site (`makePedigreeMatingLayout()` line 1153).
Track 1 (D1 bar `barY` offset) lives entirely inside `.addRectilinearWaypoints()` (a separate
function, called at line 1459 — strictly downstream). Track 2 (`.resolveEdgeNodeCollisions()`) is
called at line 1466 — also strictly downstream, and per its own contract never mutates an existing
node's `x`/`y`. **Neither can interact with fix (a):** the return value of
`.positionMatingUnitForest()` is only ever *read* by both, never fed back into it.

### 3.4 Live-verified numbers, current HEAD

Using the exact fixture from `tests/testthat/test_resolveEdgeNodeCollisions.R:271-281`
(`.commentOneFixture()`, confirmed byte-identical to what Track 2's own tests use — also the exact
fixture rendered as both plates in this session's kinship2/nprcgenekeepr visual comparison):

- **Current shipped `__union_1` (P1×P2) x = 0.12** — confirmed **outside** the `[-195, 0]` parent
  span by 0.12 units. This is a real discrepancy from the design-time prediction of exactly `0`:
  the shipped pipeline's final exact-de-collision "nudge apart" pass (lines ~1029-1040) finds the
  clamped value (`0`) exactly tied with P2's own x (also 0, same generation) and nudges it by
  epsilon (1e-3 abstract → 0.12px) to break the tie. Design-time analysis predates this exact
  re-derivation and didn't account for the nudge.
- **Hand-simulated fix (a) Pass 2 on this fixture: -6px**, exactly reproducing the design-time
  figure, freshly re-derived against current code (script:
  `scratchpad/simulate_pass2.R` from this session's workflow — ephemeral, not committed). No
  de-collision nudge would be needed either (`-6` doesn't tie with anything at gen 0).
- Confirmed scope-honest on this fixture: `__union_2`/`__union_3`/`__union_4` are unchanged by
  Pass 2 (no other kid has a qualifying duplicate).
- Zero `__jog_*`/`__bar_*`/`__drop_*` ids exist in `.positionMatingUnitForest()`'s own returned
  node set for this fixture — those are added later, by Track 1/2, confirming §3.3.

## 4. Grep-based evidence inventory (mandatory per `SESSION_RUNNER.md`'s Planning Sessions discipline)

### 4.1 Symbol-by-symbol

- **`finalUnitX`** — 2 production hits outside the loop itself (`R/makePedigreeDiagramData.R:966`
  declaration, `:972` Pass-1 formula, `:1001` Track 3 clamp, `:1005` sync to `nodes$x`, `:1009`
  feeds `dupX`). Tests: 3 dedicated invariant blocks in `test_positionMatingUnitForest.R` (see
  §4.3). No hits in any vignette source file.
- **`childEdges`** — built `:511-519`, consumed at `:604, :704, :757, :780-781, :800, :970
  (Pass-1's own kids lookup), :1156, :1308, :1417, :1590-1591`. Tests: `test_buildMatingUnitForest.R`
  (10 hits, structural — untouched by fix (a), which reads but never writes `childEdges`),
  `test_addRectilinearWaypoints.R` (3 hits, downstream D1 consumer), `test_makePedigreeMatingLayout.R:218,504,1091`,
  `test_positionMatingUnitForest.R:1055,1058` (the Track 6 invariant helper — §4.3).
- **`duplicates$realId` / `duplicates$matingUnitId`** — production `:713, 1009 (the "rawDupX"
  formula fix (a) proposes moving earlier), 1013, 1287-1296 (node styling), 1349, 1402-1456
  (dashed-connector edge construction), 1646`. Tests: `test_buildMatingUnitForest.R` (6 hits,
  structural), `test_makePedigreeMatingLayout.R` (9 hits, structural only, no golden-x checks),
  `test_positionMatingUnitForest.R:150,321,862-863` (feed golden-x assertions — reviewed §4.2).
- **`rawDupX`** — zero hits anywhere in the repo. A genuinely new identifier; no naming collision.
- **`dupX`** — production `:1007-1013` (the exact block fix (a)'s "rawDupX pre-pass" would need
  to relocate), `:1401-1403` (dashed-connector left/right determination, downstream consumer).
  Tests: `test_positionMatingUnitForest.R:215,322` (1 golden `expectPos(dupAt4, 0.65, 2L)` — §4.2).
- **`.positionMatingUnitForest`** — single definition (`:584`), single call site (`:1153`).
  Confirmed strict one-way dependency: nothing downstream can feed back into it (§3.3). ~90 total
  references across `tests/`, `docs/`, `PROJECT_LEARNINGS.md`, `HANDOFFS.md`, `CHANGELOG.md`,
  `BACKLOG.md` — overwhelmingly narrative/historical.

### 4.2 Existing golden-value tests — empirically checked against Pass 2's actual qualification rule

Not trusted as "should be none" — the qualification rule was run against every fixture an existing
golden-x-value test uses:

| Fixture | Used by | Mating units | Duplicates | Pass-2-qualifying unions |
|---|---|---|---|---|
| `5A6DFT`→...→`GA204Z` father-daughter loop | `test_positionMatingUnitForest.R:229-278` | 4 | 1 | **0** (parent-child loop, not sibling-sibling) |
| 9-subject `P1/P2/A/Y/X/W/C1/C2/GC` "Track C" fixture | `test_positionMatingUnitForest.R:1188-1219`, `test_makePedigreeMatingLayout.R:1271-1319`, `vignettes/articles/kinship2-fidelity-validation.qmd` §Track C | 4 | 2 | **1** (`__union_1`, P1×P2 — A×Y is a genuine sibling-consanguineous mating) |
| `trimPedigree(c("8LKBV9","FJIB3R","GA204Z"), real)` (S583 headline case) | `test_positionMatingUnitForest.R:1142-1186` | 3 | 1 | **0** |
| Full real 375-individual bundled fixture | `test_positionMatingUnitForest.R:610-654,1099-1104` | 237 | 102 | **0** |

**Finding: Pass 2 is not unconditionally a no-op against existing fixtures** — the 9-subject Track
C fixture genuinely qualifies. Hand-traced and numerically confirmed: `__union_1`'s raw Pass-1
value is `1.0` (kids A=0.0, Y=2.0); Pass-2's correction pulls it to `0.2`; **Track 3's clamp still
forces the same boundary (`0`) either way**, purely because this toy fixture's `P1`/`P2` are only 1
abstract unit apart. **This is scale-fragile, not proof of general safety** — the same topology at
the issue #160 pixel scale (§3.4) genuinely diverges (`0.12` shipped → `-6` under Pass 2). A future
implementation must not treat this test's current silence as a clean bill of health (also flagged
independently by the test-blast-radius critique, §5.3).

- `dupX` golden value `test_positionMatingUnitForest.R:322` (`expectPos(dupAt4, 0.65, 2L)`) is on
  the 0-qualifying `5A6DFT`/`GA204Z` fixture — unaffected.
- No golden `scaled$x`/`nodes$x` assertions exist in `test_makePedigreeMatingLayout.R` beyond the
  2 already covered above.

### 4.3 Current Track 3/Track 6 invariant tests (`test_positionMatingUnitForest.R`)

1. **`:1000-1017`** — Track 4 (gen-aware anchor, §1) invariant. Not touched by fix (a) (reads
   `gen`, not `x`).
2. **`:1033-1105`** — *"Track 6 §2.4 invariant, LOOSENED by Track 3"*: `finalUnitX` must equal
   EITHER the raw formula OR that value clamped to `[min(sireX,damX), max(sireX,damX)]`. **This is
   the test fix (a) most directly reopens** — its `checkInvariant()` helper (`:1051-1086`) computes
   only 2 disjuncts; Pass 2 would produce a legitimate 3rd (`correctedFinalUnitX`, clamped) this
   helper doesn't currently accept. **Currently run only against the 2 zero-qualifying fixtures**
   (small linear `:1088`, real 375-individual `:1099-1104`) — see §5.3 finding, this must change.
3. **`:1107-1127`** — zero exact x/gen coincidence, real 375-fixture. Structural; unaffected.
4. **`:1142-1186`** — Track 3's own S583 headline case. 0 qualifying duplicates (§4.2) — unaffected.
5. **`:1188-1219`** — Track 3 on the Track C fixture. **This is the one existing test that DOES
   qualify for Pass 2** — passes today only by scale coincidence (§4.2).

### 4.4 Vignette/article staleness check

No hits for `__union_1`, literal coordinate values, or Pass-2-relevant identifiers in any
`vignettes/*.Rmd` or `vignettes/articles/*.qmd` **source** file. The one exception:
`vignettes/articles/kinship2-fidelity-validation.qmd:151-221` ("Track C — consanguineous-marker
propagation") uses the exact qualifying 9-subject fixture and embeds 3 real screenshots — but its
prose/table assert edge colors/widths/dogleg counts only, no x-coordinates, and §4.2's numeric
trace confirms `__union_1`'s final rendered x does not move under fix (a) on this fixture. Still,
**a future implementation session should re-screenshot-verify this vignette rather than trust the
arithmetic alone**, since it's the only shipped documentation asset resting on this exact fixture
shape.

## 5. Adversarial critique findings (3 independent lenses, this session's workflow)

### 5.1 Invariant preservation (Track 2/3/4/6) — `designStillSound: true`, 1 major, 1 major, 1 minor

Confirmed sound: the insertion point, the impossibility of Track 2 running before
`.positionMatingUnitForest()`, and the "Pass 2 reads only Pass-1 snapshots" no-cycle claim (safe
*as written*, but only if the implementation actually snapshots `rawFinalUnitX`/`rawDupX` before
Pass 2's loop starts mutating anything — an implementation-discipline obligation, not something
guaranteed by the current code shape; **minor**, worth a dedicated test).

**Major, must address:** the design names Learning 585's radix-ordering discipline for its
tie-break ("qualifying[radix-ordered tie-break][1]") but never operationalizes it — no stated sort
key, no explicit `method = "radix"`. Worse: `duplicates` (lines 478-499) is built via a plain
structural `for` loop, not `order()`/`sort()`, so `which(duplicates$realId == kid)` is **already**
deterministic by construction. An implementer taking "radix-ordered tie-break" literally and adding
an `order()` call on a character id column *without* `method = "radix"` would **reintroduce** the
exact locale-dependent non-determinism class Learnings 585/588 already had to fix elsewhere in this
same function's neighborhood — in a spot that was previously safe.

**Major, must address:** the tie-break branch (a kid with 2+ simultaneously-qualifying duplicates)
is exercised by **zero** existing fixtures — confirmed against every fixture in §4.2's table. A
RED-phase test set that doesn't add a fixture forcing this branch ships it with no coverage of its
own reason for existing.

### 5.2 Edge cases — `designStillSound: false` (the finding that triggered the hold decision)

Two of the design's own flagged-as-worth-checking edge cases are **resolved, no action needed**
(confirmed by direct code read + live fixture runs): a duplicate's "other parent" can never itself
be a duplicate id (§3.2); a dangling free-pass parent cannot propagate `NA` into Pass 2 (Pass 2
never dereferences a union's *own* parent x, unlike Track 3's clamp, so Track 3's own dangling-parent
guard is not needed here).

**Major, must address — the live-verified wrong-direction case:** Pass 2's qualification rule only
inspects the *duplicate's* union ("is the duplicate's other parent also a child of U") and never
checks whether the child's *real* occurrence is itself already tied to an equally-local
sibling-consanguineous union. When one sibling (B) mates **two different** co-siblings under the
same union U (A×B and B×C, both children of U), B's real occurrence — already sitting at its
natural sibling-row position among A/B/C — gets unconditionally swapped for the *other* mating's
duplicate-derived x.

**Verified live, not just reasoned about** (fixture: P1/P2 → A,B,C; A×B anchored by A; B×C anchored
by C, so B is duplicated only at B×C): real x for A,B,C = `{-0.5, 0.5, 1.5}`; Pass-1 raw midpoint =
`0.5`; substituting B → `dup_B_1`'s raw x (`1.9`) gives a Pass-2-corrected midpoint of `0.7` —
**farther** from the constructed true center (`-0.75`) than the unmodified `0.5` was. This pattern
("child mates a co-sibling of the same union") is the design's **own stated scope**, not an
excluded shape — it cannot be waved off by the "narrow scope, doesn't fix everything else"
disclaimer, because within its own claimed scope the correction can point the wrong way. Track 3's
clamp happened to absorb the difference in the tested fixture (both `0.5` and `0.7` clamp to the
same boundary) — a coincidence of that fixture's proportions, not a structural guarantee. **No
test in the existing corpus, and no risk item in the original S592 design, covers this shape.**

**Minor, not blocking:** a child *can* concretely have 2+ simultaneously-qualifying duplicates
(verified live with a 3-sibling-mate fixture) — ties into the tie-break coverage gap above.
**Note:** the "no compounding across chained relationships" limitation degrades gracefully only in
the *bounded* sense (Track 3's clamp still caps the worst case at the parent-span boundary, no
worse than today) — it does **not** degrade gracefully in the *correctness* sense, since an
in-span-but-wrong-direction outcome (like §5.2's main finding) is possible and the clamp does
nothing to catch that (the clamp bounds range, not correctness of position within the range).

### 5.3 Test blast radius & TDD sequencing — `designStillSound: true`, 2 major, 1 minor

**Major, must address:** the collision-avoidance plan's own §2.3/§9 record shows Track 3 needed a
**dedicated PRE-RED `AskUserQuestion`** specifically because reopening Track 6 §2.4's ratified
invariant is "a scope decision in its own right, separate from the ordinary RED→GREEN gate." The
design under review explicitly admits fix (a) does the same thing a second time ("Track 6 §2.4's
formula wording is semantically extended... matches how Track 3's clamp already required its own
disclosed reopening") — **but no planning doc currently contains a drafted PRE-RED gate section for
fix (a) itself** (only a passing one-line mention). Confirmed via `docs/planning/` grep. **Any
future implementation session must draft and pose its own dedicated PRE-RED reopening
`AskUserQuestion`, naming this as a second reopening of Track 6 §2.4 — inheriting Track 3's
disclosure is not sufficient.**

**Major, must address:** `checkInvariant()` (§4.3 item 2), the exact test the design says needs a
3rd disjunct, is currently invoked only against 2 zero-qualifying fixtures. If a RED-phase change
widens the helper without *also* adding a qualifying fixture (e.g. the Track C 9-subject fixture,
or `.commentOneFixture()`) to its call list, **the reopened invariant assertion would pass
trivially both before and after fix (a) ships** — the new disjunct becomes dead code the test's own
docstring would falsely claim to cover.

**Minor:** the "no existing golden test changes" premise is true only by the scale-coincidence
documented in §4.2 — worth a scale-realistic regression test distinct from the point-fixture #160
reproduction, so an unrelated future change to scale constants doesn't silently stop exercising
Pass 2 at all.

## 6. Open Questions a Redesign Must Resolve

A future session picking this up should treat these as the actual work, not re-run the
verification above (all fresh as of 2026-08-16, current HEAD `f7afa0fd`+):

1. **Design a qualification rule that doesn't misfire on §5.2's pattern.** The naive fixes
   considered and rejected live this session (documented here so they aren't re-tried blind):
   "abstain when more than one of U's children has a qualifying duplicate" does **not** exclude the
   counter-example (only B qualifies there — A and C don't). "Abstain when more than one child of U
   is itself duplicated at all" also doesn't exclude it (same reason). The real difficulty: B has
   **two** legitimate sibling-consanguineous relationships under the same union (A×B and B×C), and
   the single-real/single-duplicate-per-mating data model has no way to represent "B's position
   relative to both A and C simultaneously" — this may need either a per-relationship weighting
   scheme, a rule that only substitutes when the duplicate's union's own child set doesn't overlap
   with a *third* union's presence, or accepting a narrower structural precondition than the
   original design's. Worth a fresh multi-candidate design pass, not a single patch.
2. **Operationalize or drop the radix tie-break** (§5.1) — likely simplest to drop it explicitly
   (document that `which()`'s structural-insertion-order result is already deterministic) rather
   than add an `order()` call that risks reintroducing Learning 585's defect class. Either way,
   needs an explicit test fixture forcing 2+ qualifying duplicates for one kid (§5.1).
3. **Draft the PRE-RED reopening `AskUserQuestion`** for whatever final design is adopted, before
   any RED test is written (§5.3) — naming it explicitly as a second reopening of Track 6 §2.4.
4. **Add a qualifying fixture to `checkInvariant()`'s call list** (§4.3/§5.3) when widening it to a
   3rd disjunct, so the reopened invariant actually exercises the new branch.
5. **Add a scale-realistic regression test** distinct from the toy Track C fixture (§4.2/§5.3).
6. **Pick a name that isn't "Track 4"** for whatever plan eventually ships this (§1).
7. Re-screenshot-verify `vignettes/articles/kinship2-fidelity-validation.qmd`'s Track C section
   (§4.4) once a design ships, rather than trusting the arithmetic alone.

## 7. Decision log (this session)

- User selected **"Track 3 trade-offs decision"** from the Phase 0 priorities picker, then
  **"Scope Track 4 (centering)"** specifically (separating it from the D1 bar-vs-bar residual,
  which stays a distinct, unstarted follow-up).
- Presented with §5.2's live-verified wrong-direction finding, user selected **"Hold — needs a
  redesign session"** over shipping the original design with a disclosed limitation, or patching it
  with an unverified guard. This document is the resulting record.

## References

- `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md` — Tracks 1-3 (shipped),
  §2.4/§8/§9 (this fix's origin and deferral).
- `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` — the *other*, already-shipped
  "Track 4" (gen-aware anchor selection) — see §1's naming-collision note.
- `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md` — Track 6, whose
  §2.4 formula this fix would (a second time) reopen.
- S592 original design source: workflow journal
  `/Users/rmsharp/.claude/projects/-Users-rmsharp-Development-nprcgenekeepr/5f68259f-6622-4bdd-8531-d2c60ad9fcb0/subagents/workflows/wf_57184bfd-eb7/journal.jsonl`
  (entry index 19).
- This session's own verification/critique workflow: run id `wf_9d347c8d-cca`, transcript dir
  `/Users/rmsharp/.claude/projects/-Users-rmsharp-Development-nprcgenekeepr/35248b9b-b6e4-48b2-9fb3-d981fda4ed45/subagents/workflows/wf_9d347c8d-cca/journal.jsonl`.
- `BACKLOG.md` — Track 3's disclosed-trade-offs follow-up item (this document's parent task).
- `PROJECT_LEARNINGS.md` Learning 585 / Learning 588 — the radix-ordering non-determinism class
  §5.1's tie-break finding references.
