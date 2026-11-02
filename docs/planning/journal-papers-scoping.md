# Journal papers: scoping

**Session:** S1113, 2026-10-31 to 2026-11-01. **Status:** scoping done, no paper text written.
Journal rules below are as read on 2026-10-31; re-read them before submitting.

## 1. Mark's rulings

| Question | Ruling | What follows |
|---|---|---|
| Which paper first | The software paper, in *The R Journal* | Sections 3 and 4 |
| Who writes | Mark drafts, Claude helps | Claude checks claims against sources, runs figures and edits. AI help is disclosed |
| Is any center using the package today | "Not sure yet" | **The first open item.** No submission date until it is answered (section 5) |
| Who to invite as co-authors, of Amanda Vinson, Michael Raboin, Matthew Schultz and Terry Therneau | "None of the above" | No co-author named so far. All four stay package authors in `DESCRIPTION`; paper authorship is separate. The 2015 paper is cited, not reused |

## 2. What changed during this session

CRAN accepted 3.0.0 (Uwe Ligges: "Thanks, on its way to CRAN"), and CRAN's package page shows
**Version 3.0.0, Published 2026-11-01**. That meets *The R Journal*'s CRAN rule and the backlog's
"a released 3.0.0 to cite". Plan Phase 10 (`docs/planning/cran-3.0.0-submission-plan.md`) is still
owed and comes before any paper work. CRAN's check page should be read a few days after
publication, because a paper should not cite a release with an open check problem.

## 3. *The R Journal*: its rules against the package

From `https://journal.r-project.org/submissions.html`.

| Rule (quoted) | Package today | State |
|---|---|---|
| "must be available on CRAN or Bioconductor" | 3.0.0 published 2026-11-01 | Met |
| "no more than 20 pages" | 54 new exports in 3.0.0 alone (182 to 236), so the paper must choose | Constraint |
| "demonstrated use (e.g., citations in publications...)" | None on record (section 5) | **Open** |
| "advantages over any competing packages or existing approaches" | PMx and kinship2 are known comparators; no full scan done | **Owed** (section 6) |
| "unit tests that verify output values" | 496 test files; validation articles below; check a sample when drafting | Likely met |
| "a vignette describing a full workflow" | `vignette("a2interactive")` | Likely met |
| version control "linked in the package's CRAN `DESCRIPTION`" | `URL:` names the GitHub repository | Met |
| "actively maintained and sufficiently mature" | On CRAN since at least 2020-06-02 (CRAN database timeline), 2.0.0 and 3.0.0 this year | Met |
| "not sufficiently substantial" is a rejection reason | 236 exported functions, a Shiny app | Not a concern |

**Not settled:** the submissions page mentions neither fees nor generative AI, and
`journal.r-project.org/about.html` returned 404. The author guide was not found. Ask the editors
about AI disclosure before drafting: 4,189 of 5,631 non-merge commits carry a Claude trailer (first
on 2026-04-02), so the paper must say so whatever the rule is. The trailers name each model used.

**Possible fallback:** JOSS, if *The R Journal* declines. It has no fees and a required AI section,
but the same evidence-of-use bar. It should not also get a paper on the same work unless the
journals' overlap rules allow it; *The R Journal* says articles must not be "submitted for
publication elsewhere".

## 4. What the paper can draw on

**The published reference.** Vinson & Raboin 2015, *JAALAS* 54(6):700-707, PMC4671785. It computes
mean kinship with kinship2, estimates genome uniqueness by gene drop, ranks animals and forms groups
by repeated random assignment, on a colony of "approximately 4000" rhesus macaques. Its software is
"a user-friendly R-based software package, available upon request to the authors", unnamed. Its
results are simulated groups plus one example, with **no measured change in a colony**.

**New since that paper, by release** (`NEWS.Rmd`; the selection for the paper is Mark's):

- **By 2.0.0:** public CRAN package, Shiny app rewritten as modules, Potential Parents, 14 species in
  the gestation table.
- **3.0.0 pedigree and kinship:** interactive Diagram, MZ twin correction to kinship,
  `shrinkPedigree()`, X-chromosome kinship.
- **3.0.0 genetic value and groups:** configurable ranking scheme, candidate groupings, ancestry
  guardrails with an audit record, Mate Pair Analysis.
- **3.0.0 data sources and sharing:** Marker Genetics (parentage, candidate parents, F_ROH), MHC
  haplotype reporting, Cross-Center Identity, De-Identified Export.
- **3.0.0 monitoring and speed:** Genetic-Health Trends with rebuilt earlier snapshots; genetic
  value on the shipped example about 0.2 s instead of about 3 s.

**Validation already written:** `vignettes/articles/fg-se-validation.qmd`,
`vignettes/articles/kinship2-fidelity-validation.qmd`, `vignettes/gvaConvergence.Rmd`,
`vignettes/simulatedKValues.Rmd`.

**Worked-example data:** `examplePedigree` (3,694 animals) and
`inst/extdata/examples/deidentified_jmac_ped.csv` (2,590 Japanese macaques). **Mark to confirm** what
each may be described as, and where it came from, before a paper says so.

**Not a draft:** `vignettes/articles/engineering-the-2.0.0-release.qmd` says Claude Code directed its
own drafting, so under Mark's ruling it is a source of facts to verify, not text to reuse.

**Funding wording:** `DESCRIPTION` limits the NIH grants to work "up to and including version 1.0".
The paper's acknowledgment must say the same, and Mark supplies anything later.

## 5. Evidence of use: the first open item

The repository records no center using the package. What can be measured is thin and does not
show research use:

| Signal | Value (2026-10-31) | Limit |
|---|---|---|
| CRAN downloads, 2019-01-01 to 2026-10-30 | 13,838 (280 in October 2026) | RStudio mirror only; includes robots and updates |
| GitHub forks and stars | 4 and 0 | Says nothing about use |
| Issue authors other than Mark | 1 | |
| Published paper citing the package | none found by one web search | Not an exhaustive search |

**Who acts:** Mark asks the centers. A dated written sentence from each, saying what the package is
used for, is what a paper can cite. The outreach drafts are the natural channel, since 3.0.0 is now
listed: `docs/planning/nprc-outreach-announcement-plan.md` could ask that question. That plan is not
changed here, and its drafts still need Mark's review.

**If no center is using it:** Mark's own research use may satisfy JOSS's minimum ("at minimum by the
developers themselves, and ideally by others"). *The R Journal* gives citations as its example, so
ask its editors. Otherwise the paper waits for outreach to produce users.

## 6. The other candidates

**Applied colony paper (later).** It cannot claim the software "improves" management without a
center's real data and a measured result, and nobody has arranged either. Likely home: *JAALAS*,
whose mission covers "facility operations, management" and which published the 2015 paper. Depends on
section 5.

**Retrospective paper (later, optional).** Needs records and memory that are not in this repository.
The source summary's "adoption by National Primate Research Centers" is unverified.

**Owed before drafting: a comparator scan.** Only two are confirmed so far: PMx (Lacy, Ballou &
Pollak 2012, *Methods in Ecology and Evolution* 3(2):433-437) and kinship2 (Sinnwell, Therneau &
Schaid 2014, as cited in the fidelity article). The scan compares what each does, with sources read.

## 7. The journal list

The names were never received. In the 2026-09-26 session transcript the journal headings of the
pasted summary are already blank, and only the four in the summary's closing recommendation survive
as text. **These names are Claude's inference from the description under each blank heading,** not
recovered text. Mark may correct them from the original conversation. Nothing depends on them now.

| Tier | Inferred | State as read 2026-10-31 |
|---|---|---|
| 1 | JOSS | No fees; evidence of use; six months of public history (the repository dates from 2017); AI section required |
| 1 | *Bioinformatics* | Weak fit, no colony-management category; open access with charges; "not acceptable to use LLMs ... to draft papers" |
| 1 | *BMC Bioinformatics* | Page redirected to a login; not read |
| 2 | *American Journal of Primatology*, *Journal of Medical Primatology*, *Zoo Biology* | Not read; Wiley refused automated access |
| 3 | *Molecular Ecology Resources* | Not read; a third-party page reports charges since August 2025 |
| 3 | *Methods in Ecology and Evolution* (weak guess) | Not read; Wiley refused automated access. It published PMx |
| 4 | *The R Journal* | **Chosen** (section 3) |
| 4 | *Journal of Statistical Software* | Weak fit; wants "comprehensive" implementations of broad statistical classes; no fees |
| 5 | *JAALAS* | 2024 author page: no submission or page charges listed, though not clearly for both AALAS journals; 2026 rules not read |
| 5 | *Comparative Medicine* | A search summary said it merged into *JAALAS*. **Not confirmed:** the 2024 author pages read still say AALAS "publishes two journals" |

**Wiley pages:** a browser user-agent was refused by Claude Code's permission system as bot-check
circumvention, and no archived copy was tried for the same reason. A person has to read these, and
only if one becomes a candidate.

## 8. Next, in order

1. **Claude, next session:** CRAN plan Phase 10.
2. **Mark:** find out whether any center uses the package (section 5), and confirm the data
   descriptions (section 4).
3. **Mark:** ask *The R Journal*'s editors about AI disclosure and fees. Claude can draft the message.
4. **Claude, one session:** the comparator scan (section 6).
5. **Mark, with Claude checking:** an outline choosing what fits 20 pages, then the draft, with a
   claim-source map per `methodology/workstreams/RESEARCH_DOCUMENTATION_WORKSTREAM.md`.

## 9. Sources read

| Source | Read how | Result |
|---|---|---|
| `joss.readthedocs.io`: `submitting.html`, `policies.html`, `review_criteria.html` | Fetch | Read |
| `journal.r-project.org/submissions.html` | Fetch | Read; `about.html` returned 404 |
| `jstatsoft.org`: `about`, `about/submissions`, `mission`, `authors` | Fetch | Read |
| `academic.oup.com/bioinformatics/pages/author-guidelines` | Fetch | Read, final part as a summary; `charges` returned 404 |
| PMC4671785 (the 2015 paper) | Fetch | First half verbatim, through the start of the Discussion; the rest only as a summary, not relied on here |
| PMC11267439, PMC12379635; AALAS PDFs 63/1 p99 and 63/4 p439 | Fetch, plain download | Read; `aalas.org` author pages returned an empty shell |
| `cran.r-project.org/web/packages/nprcgenekeepr/`; `cranlogs.r-pkg.org`; `crandb.r-pkg.org` | Plain download | Read; `crandb` still showed 2.0.0 when CRAN's page showed 3.0.0 |
| PMx publication | Search result summary only | Citation to confirm at the comparator scan |
