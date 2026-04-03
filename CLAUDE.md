## SESSION PROTOCOL — FOLLOW BEFORE DOING ANYTHING

**Read and follow `SESSION_RUNNER.md` step by step.** It is your operating procedure for every session. It tells you what to read, when to stop, and how to close out.

**Three rules you will be tempted to violate:**
1. **Orient first** — Read SAFEGUARDS.md → SESSION_NOTES.md → BACKLOG.md → run `python3 methodology_dashboard.py` → git status → report findings → WAIT FOR THE USER TO SPEAK
2. **1 and done** — One deliverable per session. When it's complete, close out. Do not start the next thing.
3. **Auto-close** — When done: evaluate previous handoff, self-assess, document learnings, write handoff notes, commit, report, STOP.

`SESSION_RUNNER.md` documents known failure modes and their countermeasures. The protocol compensates for documented tendencies to skip orientation, skip close-out, and continue past the deliverable.

---

# nprcgenekeepr

## Project Overview

**nprcgenekeepr** (Version 1.0.8) is an R package implementing Genetic Tools for Colony Management. Initially conceived and developed as a Shiny web application at the Oregon National Primate Research Center (ONPRC), it has been enhanced to have more capability as a Shiny application and to expose functions for use either interactively or in R scripts.

This work has been supported in part by NIH grants P51 RR13986 to the Southwest National Primate Research Center and P51 OD011092 to the Oregon National Primate Research Center.

### Core Functions

1. **Quality Control** - Validation of studbooks from text files, Excel workbooks, and LabKey EHR pedigrees. Checks include:
   - Parent record verification
   - Sex validation (no male dams, female sires)
   - Duplicate detection
   - Date validation
   - Minimum parent age verification (default 2 years)

2. **Pedigree Creation** - Building pedigrees from animal lists using LabKey EHR integration via `Rlabkey` package

3. **Age-Sex Pyramid Plots** - Visual display of living animals by age and sex for demographic analysis

4. **Genetic Value Analysis Reports** - Ranking scheme using:
   - Mean kinship (indicates inter-relatedness with colony)
   - Genome uniqueness (indicates presence of rare alleles)
   - Animals with low mean kinship or high genome uniqueness rank higher

5. **Breeding Group Formation** - Creating potential breeding groups that:
   - Avoid mating of closely related animals
   - Support optional sex ratio constraints
   - Support harem group configuration
   - Maximize genetic diversity

### Package Structure

- `R/` - Package functions and Shiny modules
- `inst/application/` - Original monolithic Shiny application (server.R, ui.R)
- `inst/extdata/` - Example data and configuration files
- `tests/testthat/` - Unit tests

### Running the Application

```r
library(nprcgenekeepr)
runGeneKeepR()
```

### Key References

Vinson, A; Raboin, MJ. "A Practical Approach for Designing Breeding Groups to Maximize Genetic Diversity in a Large Colony of Captive Rhesus Macaques (*Macaca mulatta*)" *Journal of the American Association for Laboratory Animal Science*, 2015 Nov, Vol.54(6), pp.700-707

### Online Documentation

https://rmsharp.github.io/nprcgenekeepr/

---

## Development Process Contract

This project uses **Strict Test-Driven Development (TDD)**.
Deviation is a defect.

### TDD Rules:
- Write tests before implementation code
- Each feature branch should include tests
- Ensure both happy paths and all non-happy paths are tested
- Ensure potential edge cases are tested
- Maintain >80% code coverage for new code
- Run full test suite before merging
- Tests should be fast, isolated, and deterministic

### TDD Phases

#### RED
- Write tests only
- Tests must fail
- No implementation code
- No production logic
- No refactoring

#### GREEN
- Write the minimum implementation required to pass tests
- No new functionality
- No refactoring
- No optimization

#### REFACTOR
- Improve structure and readability
- No behavior changes
- All tests must remain passing

### Enforcement Rules

- The assistant MUST declare the current phase at the top of every response.
- The assistant MUST refuse requests that violate the current phase.
- The assistant MUST ask permission before transitioning between phases.
- Skipping phases is forbidden.
- Writing implementation code during RED is a violation.
- Ensure potential edge cases are tested
- Maintain >80% code coverage for new code
- Run full test suite before merging
- Tests must be fast, isolated, and deterministic

### Error Handling

If a response violates TDD:
1. The assistant must acknowledge the violation.
2. The assistant must correct itself.
3. The assistant must reissue a compliant response.

This file supersedes general coding instincts.
