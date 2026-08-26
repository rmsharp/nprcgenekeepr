# Fidelity Validation Against kinship2

## Why this article exists

The [kinship2](https://cran.r-project.org/package=kinship2) R package is
the field’s standard reference implementation for pedigree kinship
computation and pedigree drawing (Sinnwell, Therneau & Schaid 2014). Its
own supplementary material (Sinnwell, Therneau & Schaid, “The kinship2 R
Package for Pedigree Data: Supplementary Material”) works a small,
fully-specified 10-subject example pedigree through kinship2’s own
kinship matrix, X-chromosome kinship matrix, and pedigree-trimming
(“shrink”) functions.

The ratified [kinship2 supplement full-reproduction
plan](https://github.com/rmsharp/docs/planning/kinship2-supplement-full-reproduction-plan.md)
closed 3 tracks against that supplement:

- **Track A** –
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  gained `chrtype = c("autosome", "x")` and `sex` arguments, reproducing
  the supplement’s X-chromosome kinship matrix (Table S2).
- **Track B** – new
  [`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md),
  a
  [`kinship2::pedigree.shrink()`](https://rdrr.io/pkg/kinship2/man/pedigree.shrink.html)
  equivalent over this package’s own `id`/`sire`/`dam` data-frame
  pedigree representation.
- **Track C** –
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
  consanguineous-mating visual marker (a distinct color/width on a
  blood-related couple’s mate-line edges) now propagates correctly onto
  `edgeStyle = "rectilinear"`’s dogleg-rerouted projection edges, not
  just the direct-style case.

Each track’s own implementing session (Track C: S563, Track A: S564,
Track B: S565) verified its own fixtures against a live, installed
`kinship2` 1.9.6.2 and recorded the results as hardcoded expected values
in `tests/testthat/test_kinship.R`, `test_shrinkPedigree.R`, and
`test_makePedigreeMatingLayout.R`. This article is the recorded,
side-by-side evidence for a reader who was not in those sessions: for
each track, the exact same fixture is run through **both** packages,
live, and the numeric and graphic output is shown together, not just
asserted equal in a test file. It is the same “validate before expose”
discipline as
[fg-se-validation.qmd](https://github.com/rmsharp/nprcgenekeepr/articles/fg-se-validation.qmd),
applied to a reference *package* instead of a reference *paper’s worked
numbers*.

**kinship2 is not a dependency of nprcgenekeepr.** Every comparison
below was generated once, offline, by
[`data-raw/kinship2FidelityValidation.R`](https://github.com/rmsharp/data-raw/kinship2FidelityValidation.R)
(kinship2 installed locally, used interactively – matching the same
evidence standard and the same “no new Suggests dependency” choice the 3
tracks’ own implementing sessions already made) and the resulting
numbers/images are embedded below, exactly as
[fg-se-validation.qmd](https://github.com/rmsharp/nprcgenekeepr/articles/fg-se-validation.qmd)
embeds its own offline validation study’s results rather than
recomputing them at render time.

``` r

# Reproduce (build-ignored; not run on render). Requires kinship2 installed
# locally (install.packages("kinship2")) and Chrome (chromote, an indirect
# Suggests dependency via shinytest2, for the nprcgenekeepr diagram
# screenshots):
#   Rscript data-raw/kinship2FidelityValidation.R
# Writes PNGs to vignettes/articles/kinship2-fidelity-validation-img/ and
# prints the numeric and structural-comparison summary below to the
# console.
```

## Track A – X-chromosome kinship (Table S2)

### Fixture

The kinship2 supplement’s own Figure S1 subset (reconstructed from Table
S1’s printed kinship values, per
[`KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md`](https://github.com/rmsharp/docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md)):
a 10-subject pedigree in which subjects 8 and 9 are full siblings
*declared* as a monozygotic (MZ) twin pair, and subject 10 is a child of
twin 8 – the load-bearing case for confirming a twin correction
propagates to a non-twin descendant, not just the declared pair.

### Numeric fidelity

Both packages compute the full 10x10 autosomal matrix and the full 10x10
X-linked matrix on the identical fixture (nprcgenekeepr’s own MZ-twin
correction supplies the same `relation`/`twinRelations` declaration to
each package in its own idiom):

| Comparison | max\|nprcgenekeepr − kinship2\| | Identical? |
|----|----|----|
| Autosomal kinship matrix (100 cells) | 0 | **Yes** |
| X-linked kinship matrix (100 cells) | 0 | **Yes** |

A few named cells, reproducing the supplement’s own Table S2
(self-kinship differs by sex on the X chromosome – a male’s self-kinship
is 1.0, not 0.5, since he carries a single X copy):

| Pair    | Relationship                          | nprcgenekeepr | kinship2 |
|---------|---------------------------------------|---------------|----------|
| (1, 1)  | male self                             | 1.0000        | 1.0000   |
| (2, 2)  | female self                           | 0.5000        | 0.5000   |
| (1, 3)  | father-son                            | 0.0000        | 0.0000   |
| (1, 4)  | father-daughter                       | 0.5000        | 0.5000   |
| (8, 9)  | declared MZ twins, X-linked           | 1.0000        | 1.0000   |
| (9, 10) | twin correction propagated to a child | 0.5625        | 0.5625   |

### Graphic fidelity

![Four heatmap panels arranged 2 by 2: nprcgenekeepr autosomal, kinship2
autosomal, nprcgenekeepr X-linked, kinship2 X-linked kinship matrices
for the same 10-subject pedigree, each pair visually identical to the
other.](kinship2-fidelity-validation-img/trackA-kinship-heatmaps.png)

Kinship matrix heatmaps for the 10-subject fixture: nprcgenekeepr’s
autosomal matrix (top left) against kinship2’s autosomal matrix (top
right), and nprcgenekeepr’s X-linked matrix (bottom left) against
kinship2’s X-linked matrix (bottom right). All 4 panels use the same
color scale; the two autosomal panels are pixel-for-pixel identical, as
are the two X-linked panels.

## Track B – `shrinkPedigree()` vs. `pedigree.shrink()`

### Fixture

The composite 16-subject fixture from `test_shrinkPedigree.R`,
constructed to exercise every removal phase of kinship2’s own algorithm
in one pedigree: an unavailable (ungenotyped) terminal leaf, an
unavailable founder couple with a single child, a childless “stray
marry-in” founder, a genotyped but non-informative individual, and a
priority-ordered affected-status reduction down to `maxBits = 1`.

### Numeric fidelity

| Comparison | nprcgenekeepr | kinship2 | Match? |
|----|----|----|----|
| Surviving subject set (8 of 16) | `C4, C4a, G3, L3, M1, P1, P2, P6` | `C4, C4a, G3, L3, M1, P1, P2, P6` | **Yes** |
| `bitSize` trajectory | `11 → 7 → 5 → 3 → 1` | `11 → 7 → 5 → 3 → 1` | **Yes** |

### Graphic fidelity

The same fixture, before and after shrinking, rendered by both packages.
kinship2’s own `plot.pedigree()` did not plot subject `P5` (an isolated,
mate-less, child-less founder) – expected behavior for a disconnected
singleton, not an error.

![kinship2 pedigree diagram of the full 16-subject fixture, standard
square/circle symbols connected by a strict-hierarchy
layout.](kinship2-fidelity-validation-img/trackB-kinship2-full.png)

kinship2’s own `plot.pedigree()` on the full 16-subject fixture.

![nprcgenekeepr pedigree diagram of the full 16-subject fixture, showing
all 16 declared subjects including the isolated founder P5 that
kinship2's own plot
omits.](kinship2-fidelity-validation-img/trackB-nprc-full.png)

[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md) +
`visNetwork` on the same full 16-subject fixture. Unlike kinship2’s own
plot, this rendering includes `P5`.

![kinship2 pedigree diagram of the shrunk 8-subject pedigree, with
unavailable individuals shown as unfilled nodes marked with a question
mark.](kinship2-fidelity-validation-img/trackB-kinship2-shrunk.png)

kinship2’s `pedigree.shrink()$pedObj` – shrunk to 8 subjects.
Unavailable (‘?’) individuals still shown, per kinship2’s own
convention.

![nprcgenekeepr pedigree diagram of the shrunk 8-subject pedigree,
showing the same 2 family groups as kinship2's own shrunk
diagram.](kinship2-fidelity-validation-img/trackB-nprc-shrunk.png)

[`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md)’s
own surviving pedigree, same 8 subjects, rendered the same way.

The two shrunk diagrams show the **same 8 surviving subjects in the same
2 family groups** – `{P1, P2, M1, G3, L3}` and `{C4, P6, C4a}` –
confirming the numeric surviving-set match above is also structurally
faithful, not just a matching id list.

## Track C – consanguineous-marker propagation

### Fixture

The 9-subject dogleg fixture from `test_makePedigreeMatingLayout.R`
(S563): `A` and `Y` are full siblings (children of `P1` x `P2`) who mate
with each other – the consanguineous union under test – while `A` also
anchors an unrelated union with founder `X`, and `Y` also anchors an
unrelated union with founder `W`. `A`’s own display generation is pulled
away from the consanguineous union’s generation by the `A` x `X` union,
forcing exactly one `edgeStyle = "rectilinear"` “dogleg” reroute on
`A`’s side only.

### Graphic fidelity

kinship2 draws a consanguineous mating as a **doubled connecting line**
between the two mates (visible directly between `A` and the left-hand
`Y`) and – independently of anything to do with consanguinity –
duplicates any individual who appears in more than one union (`Y`
appears twice, joined by a dashed connector).
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
uses a **distinct color and width** on the consanguineous union’s own
edges and *also* independently duplicates a multi-union individual with
a dashed connector – the two packages converge on the same
duplicate-node convention without having copied it from one another.

![kinship2 pedigree diagram showing subjects A and Y connected by a
doubled mate-line (the consanguinity marker) and Y appearing twice,
joined by a dashed
arc.](kinship2-fidelity-validation-img/trackC-kinship2.png)

kinship2’s own `plot.pedigree()`. The doubled line directly between `A`
and the near `Y` node is kinship2’s consanguinity marker; the dashed arc
connects `Y`’s two appearances (one per union she anchors).

![nprcgenekeepr pedigree diagram, direct edge style, showing the A-Y
consanguineous union marked in a distinct vermillion color and greater
width.](kinship2-fidelity-validation-img/trackC-nprc-direct.png)

`makePedigreeMatingLayout(edgeStyle = "direct")` – the A-Y union’s 2
mate edges render in vermillion (#D55E00) at width 4.

![nprcgenekeepr pedigree diagram, rectilinear edge style, showing the
consanguinity marker correctly carried onto A's right-angle dogleg
reroute as well as Y's direct
side.](kinship2-fidelity-validation-img/trackC-nprc-rectilinear.png)

`makePedigreeMatingLayout(edgeStyle = "rectilinear")` – the same marker
now propagates onto `A`’s dogleg-rerouted projection edges (this
session’s own fix), not just `Y`’s non-doglegged side.

| Edge style | Marked (vermillion) edges | Expected |
|----|----|----|
| `direct` | 2 | 2 (one edge per mate, no dogleg) |
| `rectilinear` | 3 | 3 (`A`’s 1 edge splits into 2 dogleg segments; `Y`’s 1 edge is unaffected) |

Both packages flag the *same* union as consanguineous, using their own
independent visual conventions – a thickened doubled line in kinship2, a
distinct color and width in nprcgenekeepr – and nprcgenekeepr’s marker
survives the more complex rectilinear dogleg reroute exactly as it does
the simple direct case.

## Structural verification

Tracks B and C’s diagram images above are, on their own, still just two
independently-rendered pictures placed side by side – a reader has to
trust that they show the same family structure. The [kinship2
structural/ topological comparison
plan](https://github.com/rmsharp/docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md)
closes that gap: `.extractKinship2Structure()` and
`.extractNprcStructure()` (both `@noRd`, zero `kinship2` dependency)
pull the real-individual-level parent-child edge set, mate-pair set, and
rendered-individual set out of kinship2’s own `pedigree` object and out
of
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
output respectively – at the level of *who is related to whom, and who
is shown at all*, not *which duplicate copy of a multi-union individual
each package’s layout happens to draw* (the two packages duplicate
different individuals for the same union above: `Y` in kinship2’s
rendering, `A` in nprcgenekeepr’s). `.comparePedigreeStructures()` then
diffs all three sets directly.

**A real gap in this comparator was found and fixed 2026-08-26.** The
original version diffed only the parent-child edge set and mate-pair set
– never the set of individuals actually displayed. An individual with
zero edges on *either* side (a fully isolated founder, like `P5` in
Track B’s full fixture, described above) is invisible to that diff: it
contributed no rows to either table regardless of whether either package
rendered it, so the comparator reported `identical = TRUE` on a pair of
images that visibly differ (16 rendered nodes vs. 15). The comparator
now also diffs the rendered-individual set on each side (`kinship2`’s
side computed from `align.pedigree()`’s own plot-grid placement, not
merely its `pedigree()` object’s declared `id` list) – see
`tests/testthat/test_comparePedigreeStructure.R`’s “individuals” test
block for the full regression coverage, including this exact Track B
fixture.

Run against this article’s own Track B and Track C fixtures, live, with
the fixed comparator:

| Fixture | Structurally identical to kinship2? |
|----|----|
| Track B, full (16 subjects) | **No** – nprcgenekeepr renders `P5`; kinship2’s own plot omits it (see [Graphic fidelity](#sec-trackb) above) |
| Track B, shrunk (8 subjects) | **Yes** |
| Track C (9 subjects, consanguineous dogleg) | **Yes** |

Track B’s shrunk fixture and Track C both remain a clean, no-discrepancy
match – `P5` does not survive
[`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md)’s
trim (an uninformative, unavailable founder with no descendants), so
Track B shrunk never exercises this case, and Track C’s fixture has no
isolated individuals at all. Track B’s *full* fixture is the one
genuine, real, and expected discrepancy: not a defect in either package,
but a real difference in what gets drawn – kinship2’s own rendering
convention silently drops a disconnected singleton, while
nprcgenekeepr’s does not. For colony-management use, showing every
declared individual (even one with no recorded relationships yet) is the
more useful default, not a bug to reconcile away.

## Caveats carried forward

- **kinship2 is not a package dependency.** Nothing above runs at
  `quarto render` time or in `R CMD check` – the numbers and images are
  the frozen output of one offline, interactively-run script, matching
  this package’s established precedent of never calling `kinship2::`
  live from committed test or documentation code.
- **The full 17-subject `fam1` pedigree from the kinship2 supplement’s
  main worked example is not reconstructable from this repository’s
  materials** (its source figure lives in the kinship2 *application
  note*, not the supplement PDF this repository ships). Track A’s
  fixture is the fully-specified 10-subject Figure S1 *subset*, per the
  audit’s own scope caveat – not a limitation introduced by this
  article.
- **Tracks B and C have no PDF-printed worked example at all** – the
  supplement names only *which* subjects a shrink trims, never their
  relationships, and says nothing about visual conventions. Both tracks’
  ground truth is a live, installed
  [`kinship2::pedigree.shrink()`](https://rdrr.io/pkg/kinship2/man/pedigree.shrink.html)
  / `plot.pedigree()` run on a fixture purpose-built to exercise the
  relevant algorithm, not a supplement-sourced value.
- **[`kinship2::pedigree()`](https://rdrr.io/pkg/kinship2/man/pedigree.html)’s
  sex-role validation is stricter than nprcgenekeepr’s own sire/dam
  columns.** Track C’s own committed test fixture lists one individual
  (`Y`) as a `sire` in one row despite her declared sex being female –
  valid input to
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md),
  which does not enforce sex/column-role consistency, but rejected by
  [`kinship2::pedigree()`](https://rdrr.io/pkg/kinship2/man/pedigree.html),
  which does. The validation script swaps that one row’s 2 column values
  (same 2 parents, same family structure) only for the kinship2-side
  object; every nprcgenekeepr call in this article uses the fixture
  exactly as committed.

## Verdict

**PASS, with one known and expected difference.** Track A’s autosomal
and X-linked kinship matrices are bit-for-bit identical to kinship2’s
own output across every one of 200 compared cells (100 autosomal + 100
X-linked), including the MZ-twin correction and its propagation to a
descendant. Track B’s
[`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md)
reproduces kinship2’s exact surviving subject set and exact `bitSize`
trajectory, and the *shrunk* pedigrees are the same 2 family groups –
confirmed by a real edge-set-and-individual-set diff, not just a visual
read ([Structural verification](#sec-structural)). Track B’s *full*
16-subject fixture is the one place the diagrams genuinely differ:
nprcgenekeepr renders the isolated founder `P5`; kinship2’s own
`plot.pedigree()` silently omits it. This is a real difference in what
gets drawn, not a defect in either package – and the structural
comparator now catches it explicitly instead of reporting a false
`identical = TRUE` (the gap that let this pass unnoticed until an
owner-directed image review caught it live, 2026-08-26). Track C’s
consanguineous-mating marker flags the same union kinship2 flags, under
both edge styles, using an independently-converged duplicate-node
convention for the same underlying multi-union case kinship2 also
duplicates – structurally confirmed identical. Track A, Track B’s shrunk
fixture, and Track C are cleared as faithful reproductions of the
kinship2 supplement’s own results; Track B’s full fixture is cleared as
an *understood, correctly-detected* difference, not a silent one.

## References

Sinnwell, J.P., Therneau, T.M., Schaid, D.J. (2014) “The kinship2 R
package for pedigree data.” *Human Heredity* 78(2):91-93.

Sinnwell, J.P., Therneau, T.M., Schaid, D.J. “The kinship2 R Package for
Pedigree Data: Supplementary Material.” Mayo Clinic (PMC manuscript
NIHMS593658); shipped in this repository at
`inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf`.

See also
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md),
[`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md),
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md),
and
[`kinship2-supplement-full-reproduction-plan.md`](https://github.com/rmsharp/docs/planning/kinship2-supplement-full-reproduction-plan.md).
