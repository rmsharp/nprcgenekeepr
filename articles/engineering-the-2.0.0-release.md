# Engineering nprcgenekeepr 2.0.0: Modular Architecture, Expanded Capability, and an AI-Assisted Development Process

## Section 1 – From Monolith to Modules: the Shiny Architecture Transformation

For most of its life, `nprcgenekeepr` shipped **two coexisting Shiny
applications** that implemented the same features twice. The original,
`inst/application/` – a single `server.r` (1,304 lines) plus a short
`ui.r` (53 lines) that sourced eight separate `uitp*.R` panel files –
ran alongside a newer, module-based rewrite (`R/appUI.R`,
`R/appServer.R`, and a growing set of `R/mod*.R` files). The two had
already begun to drift: different tab identifiers, different default
parameters, a bug fixed in one but not the other. Maintaining both was
tracked as this project’s single biggest source of friction for adding
new features (issue \#27).

“Completing the conversion” meant bringing the modular app to full
feature parity with the monolith, validating it end to end, and then
retiring the monolith outright – not a gradual coexistence, a hard
cutover. That work ran as a **nine-phase, vertical-slice migration** –
each phase one TDD session (RED -\> GREEN -\> REFACTOR with phase
gates), each phase leaving a working application behind it – from
Session 22 to Session 35 (2026-06-03 to 2026-06-06).

![](engineering-the-2.0.0-release_files/figure-html/fig-commit-pace-1.png)

Figure 1: Commits per month across the full v1.0.8 -\> v2.0.0 range
(`4548aa1b`..`8ca8bb24`, 512 non-merge commits, as of 2026-07-09). The
June 2026 spike overlaps the nine-phase modularization migration
(Session 22-35, 2026-06-03 to 2026-06-06), but June also carried other,
unrelated work – this chart is overall project pace, not a count of
module-migration commits alone.

[Figure 1](#fig-commit-pace) situates the migration inside the wider
effort: the project moved from occasional, pre-methodology commits in
late 2025 to a sustained pace once the SESSION_RUNNER methodology took
hold in Session 1 (2026-05-30), peaking in June 2026 – the same month
the module migration ran – before settling into a
testing-and-release-hardening pace in July.

### Architecture, before and after

[Figure 2](#fig-architecture) contrasts the two designs directly. The
monolith’s `server.r` was a single large reactive block reading and
writing shared state through ordinary R variables in one scope. The
modular app instead composes independent `modXServer()` functions, each
returning a named list of `reactive()` closures;
[`appServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/appServer.md)
wires those returns into one `shared <- reactiveValues(...)` object and
passes `reactive(shared$...)` down to the modules that need it – an
explicit, if still informal, module contract (documented as XARCH-2 in
the migration plan).

``` mermaid
flowchart TB
  subgraph Before["Before -- inst/application/, port 6012"]
    direction TB
    ui1["ui.r (53 lines)<br/>sources 8 uitp*.R panel files"] --> srv1
    srv1["server.r (1,304 lines)<br/>one monolithic reactive block"]
  end
  subgraph After["After -- R/appUI.R + R/appServer.R, port 6013"]
    direction TB
    ui2["appUI.R<br/>composes 10 modXXXUI() calls"]
    srv2["appServer.R<br/>shared reactiveValues()"]
    mods["10 R/mod*.R modules:<br/>modInput, modPedigree, modPyramid,<br/>modGeneticValue, modSummaryStats,<br/>modBreedingGroups, modGvAndBgDesc,<br/>modORIPReporting, modGeneticDiversity,<br/>modPotentialParents"]
    ui2 --> mods
    srv2 --> mods
    mods -- "reactive() returns" --> srv2
  end
```

Figure 2: The legacy monolith (`inst/application/`, deleted at Phase 9,
commit `3db018d1`) versus the modular app now launched by
[`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
(default port 6013, as of 2026-07-09).
[`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
– the modular app’s original launcher – is now a soft-deprecated alias
that calls
[`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md),
so pre-existing callers keep working.

The cutover was declared in Phase 9 (Session 35):
[`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
became the canonical launcher via
[`lifecycle::deprecate_soft()`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)-aliasing,
and `inst/application/` – 17 files, including `server.r`, `ui.r`, and
the eight `uitp*.R` panels – was deleted in that same, standalone commit
(`3db018d1`, with the alias and orphan cleanup following in
`24992e0b`/`53a9e5e0`/`a1618c48`). Because deletion was its own commit
rather than folded into a parity change, reverting the cutover – had the
modular app proven insufficient – would have been a single `git revert`,
not an unpicking of nine phases of work. As of 2026-07-09, that revert
was never needed.

### The modules today

|  | Module | Responsibility | Lines of code | Test files |
|:---|:---|:---|---:|---:|
| 10 | modSummaryStats | Summary Statistics | 921 | 7 |
| 5 | modInput | Data Input and Quality Control | 716 | 5 |
| 1 | modBreedingGroups | Breeding Groups | 524 | 4 |
| 3 | modGeneticValue | Genetic Value Analysis | 523 | 3 |
| 7 | modPedigree | Pedigree Browser | 401 | 3 |
| 8 | modPotentialParents | Potential Parents | 344 | 3 |
| 6 | modORIPReporting | ORIP Reporting | 325 | 2 |
| 9 | modPyramid | Age-Sex Pyramid | 160 | 2 |
| 2 | modGeneticDiversity | Genetic Diversity | 140 | 1 |
| 4 | modGvAndBgDesc | Genetic Value and Breeding Group Description | 56 | 1 |

Table 1: The ten Shiny modules mounted in the modular app, as of
2026-07-09 (`4,731` total lines across `R/mod*.R`, `R/appUI.R`, and
`R/appServer.R`).

[Table 1](#tbl-modules) lists all ten `R/mod*.R` files that exist in the
package as of 2026-07-09; together with `R/appUI.R` and `R/appServer.R`
they total 4,731 lines. Six of the ten – `modInput`, `modPedigree`,
`modPyramid`, `modGeneticValue`, `modSummaryStats`, and
`modBreedingGroups` – came out of the nine-phase migration itself.
`modGvAndBgDesc` was mounted early in that migration (Phase 2, Session
23). `modORIPReporting` exists and is wired into both
[`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
and
[`appServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/appServer.md),
but only mounts at runtime for an ONPRC site configuration
([`shouldShowOripTab()`](https://github.com/rmsharp/nprcgenekeepr/reference/shouldShowOripTab.md)),
matching the migration plan’s explicit decision to keep it
unwired-but-undeleted rather than build out its functionality.
`modGeneticDiversity` and `modPotentialParents` are **not** migration
artifacts – they were added afterward, as new capabilities in their own
right; Section 2 (new features) covers them.

### The nine-phase migration

| Phase | What shipped | Risk | Session(s) | Commit sha | Status |
|:--:|:---|:--:|:--:|:---|:---|
| 1 | Founder table added to the Summary Stats tab; kinship download moved to the module-internal getKinshipMatrix(); dual-name z-score lookup fix. | LOW-MEDIUM | 22 | 596f6bc9 | DONE |
| 2 | Mounted the GvAndBgDesc description tab; resolved an HTML-id collision with the Genetic Value tab. | LOW | 23 | ef6a9f4c | DONE |
| 3 | Re-exposed the genome-uniqueness threshold selector (default 4); added a subset/filter export. | MEDIUM | 24 | not quoted in source plan | DONE |
| 4 | Genotype-file merge restored for both separate- and common-pedigree input modes. | MEDIUM | 25 | not quoted in source plan | DONE |
| 5 | Breeding Groups: per-group downloads, a per-group kinship view, and a group selector (new "Group Detail" tab). | MEDIUM | 26 | not quoted in source plan | DONE |
| 6 | Breeding Groups: seed-group pre-seeding; exposed three previously inert controls; corrected a 100x default-iteration drift (1000 -\> 10). | MEDIUM | 27 | not quoted in source plan | DONE |
| 7 | Focal-animal / LabKey pedigree build restored (live-EHR path; verification was environmentally limited to a mocked seam). | HIGH | 29 | not quoted in source plan | DONE |
| 8 | shinytest2 E2E harness enabled end-to-end -- expanded into a 4-session subplan (8a-8d, issue \#39) plus a 7-part hardening pass (8e-1..8e-7, issue \#40, Session 37-50). | HIGH | 31-34 (8a-8d) + 37-50 (8e-1..8e-7) | not quoted in source plan | DONE (expanded into 4-session subplan 8a-8d, issue \#39 CLOSED S34; further hardened 8e-1..8e-7, issue \#40, S37-S50) |
| 9 | Declared the modular app canonical: runGeneKeepR() now launches it directly; inst/application/ (17 files) deleted; runModularApp() became the soft-deprecated alias. | HIGH (irreversible) | 35 | 3db018d1/24992e0b/53a9e5e0/a1618c48 | DONE |

Table 2: The nine-phase, vertical-slice migration from monolith to
modular app, Session 22 to Session 35 (2026-06-03 to 2026-06-06).

[Table 2](#tbl-phases) summarizes all nine phases. Phases 1, 2, and 9
are anchored to directly-verified commit shas; phases 3 through 7 are
verified only by their `CHANGELOG.md` session-close-out entries – the
source migration plan does not quote a sha for those phases, and this
article does not invent one. Phase 8 deserves a specific correction
against an earlier, looser characterization of this migration (“phases
1-9 all marked DONE”): it was not a single-session parity phase like its
neighbors. It expanded into its own four-session subplan (8a-8d, Session
31-34, issue \#39, closed at Session 34) and, after that, a further
seven-part hardening pass (8e-1 through 8e-7, Session 37-50, issue \#40)
– documented in the subplan’s own body text and in `CHANGELOG.md`, not
visible from the migration plan’s phase header alone. Phase 9, by
contrast, was the irreversible step: declaring the modular app canonical
and deleting the monolith outright, which is why it carries a HIGH risk
rating even though it shipped in a single session.
