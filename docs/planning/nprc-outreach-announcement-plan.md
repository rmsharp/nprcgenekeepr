# NPRC Outreach & Announcement Plan — nprcgenekeepr 2.0.0

**Status:** DRAFT — Phase 1 (contact roster) in progress
**Owner:** R. Mark Sharp, Ph.D. (package maintainer)
**Session:** S413 (2026-07-28)
**Deliverable type:** Planning session per `SESSION_RUNNER.md` §Planning Sessions — this
document is the deliverable; sending any correspondence is a separate, owner-executed
action outside this session (see §8, item 5).

---

## 1. Purpose

Announce, advertise, and correspond about **nprcgenekeepr 2.0.0** — free, open-source
genetic tools for primate colony management — to the national primate research center
(NPRC) network, and specifically to the **Nonhuman Primate Genetics and Genomics
Working Group** (the Consortium-level forum for NPRC faculty/staff doing genetic
analysis of nonhuman primates; see
<https://www.nprcresearch.org/research/page/Nonhuman_Primate_Genetics_and_Genomics_Working_Group>).

This plan covers: who to contact, what to say to each audience, which channels are
realistically available, a contact roster with sourcing, a generic timeline (no known
target event as of this writing), and ready-to-edit draft materials.

## 2. Why now

- **CRAN 2.0.0 was accepted and published 2026-07-26** — the freshest this release will
  ever be, and a natural news hook (`CHANGELOG.md`, Session 410).
- **Both companion public documentation articles are live and audited:**
  - *"Engineering nprcgenekeepr 2.0.0"* — the technical/process write-up
    (<https://rmsharp.github.io/nprcgenekeepr/articles/engineering-the-2.0.0-release.html>)
  - *"Colony Manager's Guide"* — the practical how-to-use walkthrough
    (<https://rmsharp.github.io/nprcgenekeepr/articles/colony-manager-guide.html>)

  Both went through independent adversarial review and a full live-link sweep before
  this session (see `CHANGELOG.md` Sessions 342–343, 398, 404–408). They are ready to be
  the "read deeper" links in any outreach.
- **The tool already has NPRC pedigree**, literally: built at ONPRC, funded in part by
  NIH grants P51 RR13986 (Southwest NPRC) and P51 OD011092 (Oregon NPRC), and it
  operationalizes a peer-reviewed method already known to this exact audience — Vinson,
  A; Raboin, MJ, *"A Practical Approach for Designing Breeding Groups to Maximize
  Genetic Diversity in a Large Colony of Captive Rhesus Macaques (Macaca mulatta),"*
  *JAALAS*, 2015. This is a stronger opening than a generic software pitch: the
  Working Group is not being asked to trust a new vendor, only to look at a free,
  citable implementation of a method some of them may already cite.

## 3. Audiences (three tiers)

### Tier 1 — NPRC Genetics and Genomics Working Group (primary target)

The natural home audience: geneticists and genomics staff across the 7 centers doing
the kind of colony-genetics work this package automates (studbook QC, kinship/genome-
uniqueness ranking, breeding-group design).

- **Leadership status:** Jeffrey Rogers (Associate Professor, Molecular and Human
  Genetics, Baylor College of Medicine; listed as Core Scientist, Wisconsin NPRC;
  `jr13@bcm.edu`) chaired this group and was still affiliated with it as of 2025 (owner
  confirmation). **Current (2026) chair status is unconfirmed** — background research in
  progress (see §6, §8 item 1).
- **General fallback contact:** `support@nhprc.org` (published on the Working Group's
  own page).
- **Named individual contact identified:** **Dr. Martha Lyke**, Staff Scientist, Cole
  Lab, Texas Biomedical Research Institute (host of Southwest NPRC), `mlyke@txbiomed.org`
  — corresponding author on a 2026 study of genetic structure in the SNPRC rhesus
  colony (<https://pubmed.ncbi.nlm.nih.gov/42316366/>), i.e. demonstrably doing current,
  directly relevant genetics work on an NPRC colony. A strong first substantive contact
  independent of the chair question.

### Tier 2 — Each center's director / research-coordination contact

The formal front door at each of the 7 centers — useful both as a courtesy
(leadership awareness) and as a route to the right internal person if a center has no
individual already identified in Tier 1 or Tier 3. See the roster in §6.

### Tier 3 — Colony managers and head veterinarians per center

The actual day-to-day users: the package's QC, Potential-Parents matching, and
breeding-group functions are operational tooling for whoever manages breeding records
and animal health at each colony — a distinct audience from the Working Group's
research-genetics focus, and arguably the audience with the most immediate practical
use for the tool.

- **Status:** background research in progress (a parallel research pass is
  specifically targeting named colony-manager/head-veterinarian contacts per center;
  results were not yet available when this draft was written — see §6 and the note at
  the top of this section once updated).

## 4. Key messages (tailored per audience)

**For the Working Group / geneticists (Tier 1):**
- Free, open-source (MIT license), R-native implementation of the Vinson & Raboin
  (2015) *JAALAS* breeding-group-design method — CRAN-published, not a one-off script.
- Genetic Value Analysis ranks animals by mean kinship (inter-relatedness) and genome
  uniqueness (rare-allele presence).
- Species-aware gestation length and minimum breeding ages now cover **14 common
  colony NHP species** (previously only rhesus macaque) — directly extends the tool's
  relevance beyond rhesus-only colonies.
- Both a Shiny GUI and a fully exposed R API — usable interactively by non-programmers
  or scripted into an existing analysis pipeline.
- Optional LabKey EHR integration for centers already on LabKey.

**For colony managers / veterinarians (Tier 3):**
- Automated studbook QC catches parent-record errors, sex-validation problems
  (no male dams / female sires), duplicates, bad dates, and under-age parents before
  they propagate into breeding decisions.
- New **Potential Parents** tab surfaces candidate sires/dams for animals with an
  unknown parent, screened by estimated conception date and species-specific
  gestation window — directly supports closing pedigree gaps.
- Age-sex pyramid plots give an at-a-glance demographic view of the living colony.
- Breeding-group formation respects sex-ratio and harem constraints while maximizing
  genetic diversity — a direct decision-support tool for breeding-plan meetings.

**For center directors / leadership (Tier 2):**
- A free, no-license-cost tool built by and for the NPRC network (NIH P51-funded
  origin at ONPRC/SNPRC), now CRAN-published, independently documented, and
  actively maintained — reduces duplicated in-house tool-building effort across
  centers.

## 5. Channels & tactics

1. **Direct correspondence to the Working Group** (Tier 1) — an email introducing the
   release, linking CRAN, GitHub, and the two pkgdown articles, and offering to present
   or demo the tool at an upcoming Working Group call. See Appendix A.
2. **Direct correspondence to each center's Tier 2/3 contacts** — a practitioner-focused
   variant of the same email (Appendix A2), sent once named Tier 3 contacts are
   confirmed (or to the Tier 2 director/coordination address as a fallback).
3. **Offer a live demo / short presentation** — the single highest-leverage tactic once
   a Working Group meeting slot can be arranged. Appendix C is written to support this
   directly.
4. **No centralized consortium "resource listing" or newsletter with a submission
   process was found.** The NPRC Genetics & Genomics public page
   (<https://nprc.org/areas/genetics-genomics/>) describes research highlights, not a
   community tool directory, and no submission mechanism is documented anywhere on the
   consortium site. Broader "advertising" beyond direct correspondence is therefore
   limited for now — direct correspondence is the primary available channel, not one
   option among many.
5. **Optional, out of this plan's built scope:** R-community channels (an R-bloggers
   post, rOpenSci, useR!-adjacent lists) could extend visibility to NHP-genetics-adjacent
   R users outside the NPRC consortium itself. Flagged as a possible future add-on, not
   drafted here, since the specific ask was the Working Group and the NPRC network.

## 6. Contact roster (as of 2026-07-28)

**Sourcing note:** Director and research-coordination-unit contacts below come from the
NPRC Consortium's own published contact page
(<https://www.nprcresearch.org/Research/Page/Contact_the_National_Primate_Research_Centers>),
fetched this session. Named genetics-relevant individual contacts marked "owner-sourced"
were supplied directly by the package owner during this session, independent of the
consortium contact page (cross-confirmed where the same name appears on both).
Colony-manager/head-veterinarian columns are placeholders pending the in-progress
background research pass — **do not treat blanks below as "none exists"; treat them as
"not yet confirmed."**

| Center (current official name) | Director | Research-coordination contact | Named genetics/scientific contact | Colony manager | Head veterinarian |
|---|---|---|---|---|---|
| California NPRC (UC Davis) | Karen Bales, PhD (Interim) | conductingresearch_cnprc@ucdavis.edu, (530) 752-0447 | *(not yet identified)* | *(pending)* | *(pending)* |
| Emory National Primate Research Center (recently renamed Emory National Biomedical Research Center; Atlanta) | R. Paul Johnson, MD | ENPRC-nprcresearch@emory.edu, (404) 727-7740 (also enprc-study-intent@emory.edu for research-initiation) | *(not yet identified)* | *(pending)* | *(pending)* |
| Oregon NPRC (OHSU, Beaverton) | Rudolf P. Bohm Jr., DVM, DACLAM | — | **Jon Hennebold, PhD** (Associate Director for Research), hennebjo@ohsu.edu (owner-sourced, cross-confirmed on consortium page) | *(pending)* | Director is himself DVM/DACLAM-credentialed — worth confirming whether he *is* the head-vet contact or delegates to a distinct role |
| Southwest NPRC (Texas Biomed, San Antonio) | Corinna Ross, PhD | SNPRCresearch@txbiomed.org, (210) 258-9822 | **Dr. Martha Lyke**, Staff Scientist, Cole Lab, mlyke@txbiomed.org (owner-sourced; see §3) | *(pending)* | *(pending)* |
| Tulane National Biomedical Research Center (Covington, LA) | Jay Rappaport, PhD | paye@tulane.edu, (985) 871-6486 | *(not yet identified)* | *(pending)* | *(pending)* |
| Washington National Biomedical Research Center (U. Washington, Seattle) | Deborah H. Fuller, PhD | nprcinfo@uw.edu, (206) 543-0440 | *(not yet identified — owner also found nprcinfo@uw.edu independently)* | *(pending)* | *(pending)* |
| Wisconsin NPRC (UW-Madison) | Ricardo Carrion, PhD | — | **Dr. Jessica Phillips** (Scientific Protocol Implementation), jphillips@primate.wisc.edu, (608) 209-7108 (owner-sourced, cross-confirmed on consortium page) | *(pending)* | *(pending)* |

**Working Group leadership:** Jeffrey Rogers, jr13@bcm.edu — status unconfirmed for
2026 (see §3, §8 item 1). Fallback: support@nhprc.org.

*(This table will be updated once the in-progress background contact research
completes; see the follow-up note planned for §9.)*

## 7. Timeline (generic — no known target event)

No publicly documented Working Group meeting cadence was found, so this timeline is
phased by completion criteria rather than calendar dates. Anchor to a real date once
one is known (e.g. a confirmed Working Group call).

| Phase | What DONE looks like | Notes |
|---|---|---|
| **1. Confirm the roster** | Working Group chair confirmed (or a documented best-available fallback), and a named colony-manager and/or head-veterinarian contact identified for all 7 centers, each with a source. | In progress this session — background research pass + owner's own lookups. |
| **2. Owner review & sign-off** | Owner has read and edited the draft correspondence (Appendices A/A2), confirmed exact recipients, and approved send order (Working Group first, per §5). | Owner-only step — cannot be delegated. |
| **3. Initial outreach — Working Group** | Email sent to the confirmed Working Group contact; either a reply received or a 2–3 week follow-up date reached with no reply. | First send, per §5 item 1. |
| **4. Per-center outreach** | Practitioner email (Appendix A2) sent to Tier 2/3 contacts at all 7 centers; replies/no-replies logged. | Per §5 item 2; can run in parallel with Phase 3 follow-up waiting, not necessarily strictly sequential. |
| **5. Offer & deliver a demo** | If the Working Group or any individual center responds positively, a short demo (Appendix C) is scheduled and delivered, or explicitly declined. | Highest-leverage tactic per §5 item 3. |
| **6. Follow-up & log** | Responses and any resulting adoption/feedback are tracked; genuine feature requests or bug reports feed into the normal GitHub-issue workflow, not a separate channel. | Closes the loop back into the project's existing process. |

Phases 2 onward are **owner-executed, real-world-calendar actions** (sending email,
waiting for replies, scheduling a call) — not further Claude Code sessions, except
where the owner wants help drafting a specific follow-up.

## 8. Risks / open decisions ("dragons" — not all phases are equally risky)

1. **Working Group chair unconfirmed.** If background research doesn't resolve who
   currently chairs the group, the fallback is the general `support@nhprc.org`
   address — lower-signal than a named individual. **Decision needed (owner):** send to
   the general address now, or hold for a confirmed name.
2. **Contact information may be stale.** Staff turnover is normal, and the fact that
   three of the seven centers have recently been renamed from "National Primate
   Research Center" to "National Biomedical Research Center" suggests active
   organizational change across the network right now — which raises the odds that
   other listed roles/contacts have also recently changed. Recommend a light-touch
   verification (e.g. a quick check of each center's current staff directory) before
   any mass-send, rather than trusting a single scraped contact page as final.
3. **Tone and authorship.** The email should come from the owner as the package's
   current maintainer, referencing the tool's ONPRC/SNPRC origin and its peer-reviewed
   methodological basis — framed as "here's a shared resource from within the network,"
   not a cold external vendor pitch.
4. **Avoid duplicate/conflicting contacts at the same institution** — e.g. if a Tier 1
   contact and a Tier 3 contact turn out to be the same person, or a center ends up
   with two separate emails. Worth a dedup pass once both contact lists (this plan's +
   the background research results) are merged, before any sends.
5. **This plan produces drafts only.** No correspondence is sent by an agent session.
   Every send is a deliberate, explicit action taken by the owner — consistent with
   this project's general rule that actions visible to external parties require
   explicit confirmation, not standing authorization from having asked for a plan.

## 9. Planning Session Checklist (`SESSION_RUNNER.md`)

- [x] Plan document written with sourced facts (grep-based evidence from this repo's
      own `DESCRIPTION`/`NEWS.md`/`CHANGELOG.md`, plus WebSearch/WebFetch-sourced facts
      about the external NPRC network, all cited inline).
- [ ] Contact roster (§6) finalized — pending in-progress background research; **this
      item blocks close-out** and will be updated in place once results return.
  - [ ] append a short **"Session 413 addendum"** note once the background research
      pass (`wf_13dc386e-06e`) completes, resolving any of: WG chair status, per-center
      colony-manager names, per-center head-veterinarian names, or any corrected
      official center names.
- [ ] Each phase in §7 has explicit completion criteria (done above) and is marked as
      an owner-executed action beyond Phase 1, not a further coding session.
- [ ] Close-out: evaluate S412's handoff, self-assess, write the `HANDOFFS.md` receipt,
      record the `CHANGELOG.md` ledger entry, commit, STOP.

---

## Appendix A — Draft outreach email (Working Group version)

> **Before sending:** confirm the actual recipient (§8 item 1), and personalize the
> greeting. This is a draft for the owner to edit, not a final send-ready text.

**Subject:** nprcgenekeepr 2.0.0 now on CRAN — open-source pedigree QC & breeding-group
tools for NPRC colonies

> Dear [Working Group chair / colleagues],
>
> I wanted to let the Genetics and Genomics Working Group know that **nprcgenekeepr**,
> an R package I maintain for genetic colony management, reached a major release
> (2.0.0) and was accepted onto CRAN on July 26, 2026.
>
> The package grew out of work at the Oregon National Primate Research Center and is
> supported in part by NIH grants P51 RR13986 (Southwest NPRC) and P51 OD011092
> (Oregon NPRC). It's a free, open-source (MIT license) implementation of the
> breeding-group-design approach described in Vinson & Raboin's 2015 *JAALAS* paper
> ("A Practical Approach for Designing Breeding Groups to Maximize Genetic Diversity in
> a Large Colony of Captive Rhesus Macaques"), extended since then with:
>
> - Studbook quality control (parent-record checks, sex validation, duplicate/date
>   checks, minimum parent age)
> - Genetic Value Analysis ranking animals by mean kinship and genome uniqueness
> - Breeding-group formation honoring sex-ratio and harem constraints
> - A new Potential Parents tool for matching animals with an unknown parent
> - Species-aware gestation length and minimum breeding ages now covering 14 common
>   colony NHP species (not just rhesus macaque)
> - Both a Shiny application and a fully exposed R API, plus optional LabKey EHR
>   integration
>
> It's free to install (`install.packages("nprcgenekeepr")`), documented at
> <https://rmsharp.github.io/nprcgenekeepr/>, and the source is on GitHub at
> <https://github.com/rmsharp/nprcgenekeepr>. Two articles there may be of particular
> interest: a practical [Colony Manager's
> Guide](https://rmsharp.github.io/nprcgenekeepr/articles/colony-manager-guide.html) and
> a technical [write-up of the 2.0.0
> engineering](https://rmsharp.github.io/nprcgenekeepr/articles/engineering-the-2.0.0-release.html).
>
> I'd be glad to give a short demo at an upcoming Working Group call if that would be
> useful — happy to tailor it to whatever would be most relevant to the group.
>
> Best regards,
> R. Mark Sharp, Ph.D.
> [affiliation / contact info]

## Appendix A2 — Draft outreach email (colony manager / veterinarian version)

> **Before sending:** confirm the actual recipient (§6/§8 item 2) and personalize.

**Subject:** Free open-source tool for studbook QC & breeding-group planning —
nprcgenekeepr 2.0.0

> Dear [colony manager / veterinarian name],
>
> I maintain **nprcgenekeepr**, a free, open-source R package built for day-to-day
> colony genetic management, and wanted to make sure it's on your radar in case it's
> useful at [Center].
>
> In practice, it: (1) catches studbook errors automatically — bad parent records,
> impossible sexes, duplicates, bad dates, under-age parents; (2) suggests candidate
> sires/dams for animals with a missing parent (a new feature in this release,
> screened by species-specific gestation windows); (3) plots an age-by-sex pyramid of
> the living colony for a quick demographic check; and (4) proposes breeding groups
> that respect sex-ratio/harem constraints while maximizing genetic diversity.
>
> It runs either as a point-and-click Shiny app or from the R console, needs no
> license fee (MIT license, free on CRAN), and can optionally read directly from a
> LabKey EHR pedigree if your center uses one. A practical walkthrough is here:
> <https://rmsharp.github.io/nprcgenekeepr/articles/colony-manager-guide.html>.
>
> Happy to answer questions or walk through it live if that would help.
>
> Best regards,
> R. Mark Sharp, Ph.D.
> [affiliation / contact info]

## Appendix B — One-page feature summary

**nprcgenekeepr — Genetic Tools for Colony Management**
*Free · Open-source (MIT) · On CRAN · <https://rmsharp.github.io/nprcgenekeepr/>*

Built at the Oregon National Primate Research Center; supported in part by NIH grants
P51 RR13986 (Southwest NPRC) and P51 OD011092 (Oregon NPRC). Implements the
breeding-group-design method of Vinson & Raboin (2015, *JAALAS*).

| Capability | What it does |
|---|---|
| **Quality control** | Validates studbooks from text/Excel files or LabKey EHR pedigrees: parent-record checks, sex validation, duplicate detection, date validation, minimum parent age (species-aware, sex-specific). |
| **Pedigree creation** | Builds pedigrees from an animal list via LabKey EHR integration. |
| **Potential Parents** *(new in 2.0.0)* | Suggests candidate sires/dams for animals with an unknown parent, using species-specific gestation windows across 14 NHP species. |
| **Age-sex pyramid plots** | Visual demographic snapshot of the living colony by age and sex. |
| **Genetic Value Analysis** | Ranks animals by mean kinship (relatedness to the colony) and genome uniqueness (rare-allele presence) — lower kinship / higher uniqueness ranks higher. |
| **Breeding group formation** | Proposes breeding groups that avoid mating close relatives, support optional sex-ratio constraints and harem configurations, and maximize genetic diversity. |

Available as a Shiny application (`runGeneKeepR()`) or a scriptable R API — use it
interactively or embed it in an existing pipeline.

**Get it:** `install.packages("nprcgenekeepr")` · Docs: rmsharp.github.io/nprcgenekeepr ·
Source: github.com/rmsharp/nprcgenekeepr · Contact: R. Mark Sharp (rmsharp@me.com)

## Appendix C — Presentation / demo outline (~15–20 minutes)

1. **Hook (2 min):** the Vinson & Raboin (2015) *JAALAS* method — likely already known
   to this audience — is now a maintained, free, CRAN-published tool, not a one-off
   script.
2. **What it replaces / augments (2 min):** manual studbook checking, ad hoc kinship
   spreadsheets, one-off breeding-group brainstorming.
3. **Live demo (8–10 min):**
   - Load a sample studbook, show the QC error report.
   - Show the Genetic Value Analysis ranking.
   - Show the new Potential Parents tab finding a candidate parent match.
   - Show breeding-group formation with a sex-ratio constraint.
4. **How to get it / how it fits your workflow (3 min):** CRAN install, Shiny app vs.
   R API, optional LabKey EHR integration, where the docs live.
5. **Ask (2 min):** feedback, feature requests (GitHub issues), and whether other
   centers would find a similar demo useful.

---

*Sources for external facts in this plan: NPRC Consortium contact page
(nprcresearch.org), NPRC Genetics and Genomics Working Group page (nprcresearch.org),
NPRC Genetics & Genomics resource page (nprc.org), Jeffrey Rogers' Baylor College of
Medicine faculty page, and facts supplied directly by the package owner during this
session (Dr. Martha Lyke, Jon Hennebold, Jessica Phillips contacts). Package facts
sourced from this repository's own `DESCRIPTION`, `NEWS.md`, `README.md`, and
`CHANGELOG.md`.*
