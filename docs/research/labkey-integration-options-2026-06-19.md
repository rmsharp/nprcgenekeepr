# LabKey Integration Options for nprcgenekeepr

*A research/evaluation of how nprcgenekeepr connects to LabKey EHR servers today, what the underlying schema contract actually is across the three primate centers, and what (if anything) to change before CRAN re-submission.*

**Status / date / scope:** Research document, as of 2026-06-19. Scope = the LabKey/`Rlabkey` data-source integration of nprcgenekeepr v2.0.0 (CRAN-archived 2025-07-29, working toward re-submission). Covers `Rlabkey` API/auth/version risk, the EHR-module schema ground truth (base `LabKey/ehrModules`, plus `onprcEHRModules`, `snprcEHRModules`, `nircEHRModules`), and architectural alternatives. Out of scope: the genetic-analysis math, the Shiny app, and any non-LabKey data path. Audience: the maintainer (R. Mark Sharp) and future contributors. All time-relative claims are stamped "(as of 2026-06-19)".

**Method / provenance (Session 143):** Produced by a multi-agent research pass — five parallel investigators (Rlabkey/CRAN; the base `ehrModules`; ONPRC; SNPRC/NIRC; architecture/alternatives), then an adversarial verification stage that independently re-checked every load-bearing claim against its primary source, then a synthesis stage. Of 37 load-bearing claims, **33 were confirmed firsthand, 3 refuted** (corrected inline below — see the "Correction from review" notes and the appendix), and **1 marked uncertain**. Every claim about nprcgenekeepr's own code was additionally verified firsthand against the working tree by the session author; `Rlabkey`/CRAN claims cite pages fetched firsthand, and EHR-module claims cite files read firsthand via `gh api` against each repo's `develop` (default) branch. Anything that could only be settled against the live ONPRC/SNPRC servers is explicitly marked "(unverified — requires confirmation)" and collected in §8.

---

## 1. Executive Summary

nprcgenekeepr's entire LabKey integration is a single thin `Rlabkey::labkey.selectRows()` call in `R/getDemographics.R`, pulling seven columns from `study.demographics` (`Id`, `gender`, `birth`, `death`, `lastDayAtCenter`, and the two lookup-traversal columns `Id/parents/dam`, `Id/parents/sire`), after which the pedigree is walked client-side in pure R. This integration is **fundamentally sound**: every `labkey.selectRows()` option it uses is current and non-deprecated, `Rlabkey` is vendor-maintained by LabKey Corporation (current CRAN release 3.4.6, 2026-02-21, clean on all 13 platforms), and the `study.demographics` table plus the `parents` lookup are real, base-`ehrModules`-defined artifacts exercised by LabKey's own queries.

The risk is **not** API breakage. It is two concrete fragilities plus cross-center divergence. (1) `Rlabkey` is declared in `DESCRIPTION` with **no version floor**, while `Rlabkey` 3.x ratchets up a minimum *LabKey-server* version with nearly every release (3.2.0 needs server ≥ 24.1; 3.4.1 needs ≥ 24.12) — an install can pull a client too new for the ONPRC/SNPRC server. (2) The package supplies **no credentials**, relying implicitly on `Rlabkey`'s default `.netrc`/API-key mechanism, which is undocumented to users and untested. (3) The `parents`-lookup *value* differs by center (ONPRC returns curated genetic-preferred parents; SNPRC/NIRC return observed-only), and some pulled columns are runtime-injected by the base EHR Java customizer rather than stored.

**RECOMMENDATION:** Do **not** rewrite onto a direct REST/`httr2` client. Instead make four low-risk changes before re-submission — add an `Rlabkey` version floor, formalize a data-source adapter around the existing source-agnostic `getPedDirectRelatives()` seam, add explicit-but-optional `labkey.setDefaults(apiKey=)` auth with `.netrc` fallback, and move the hardcoded ONPRC defaults into config — then defer server-side query optimization until pull size is measured.

---

## 2. Current Integration (baseline ground truth)

nprcgenekeepr is an R package, currently v2.0.0, archived on CRAN 2025-07-29 and working toward re-submission. Its **entire** LabKey integration is one `Rlabkey` call: `Rlabkey::labkey.selectRows()` in `R/getDemographics.R` (documented in the package as "a thin wrapper"). The exact arguments used are `baseUrl`, `folderPath`, `schemaName`, `queryName`, `viewName=""`, `colSort=NULL`, `colFilter=NULL`, `containerFilter=NULL`, `colNameOpt="fieldname"`, `maxRows=NULL`, `colSelect=<cols>`, and `showHidden=TRUE` (`R/getDemographics.R:37-48`). Because `colFilter` and `maxRows` are both `NULL`, the call pulls the **entire** demographics table for the requested columns (no server-side filtering).

The query contract comes from `R/getSiteInfo.R`: `schemaName="study"`, `queryName="demographics"`, and `folderPath="/ONPRC/EHR"` for ONPRC or `"/SNPRC"` for SNPRC. The seven columns pulled (`lkPedColumns`, `R/getSiteInfo.R:71-74`) are `"Id"`, `"gender"`, `"birth"`, `"death"`, `"lastDayAtCenter"`, `"Id/parents/dam"`, `"Id/parents/sire"` — the last two being LabKey lookup-traversal columns through a `parents` lookup. These are remapped by position to `id`, `sex`, `birth`, `death`, `exit`, `dam`, `sire` (`mapPedColumns`, `R/getSiteInfo.R:75`); the remap itself happens via `names(pedSourceDf) <- siteInfo$mapPedColumns` in the walkers.

The default `baseUrl` is now `"https://primeuat.ohsu.edu"` (the ONPRC PRIME UAT server, `R/getSiteInfo.R:67`). Older hardcoded values were SNPRC `"https://boomer.txbiomed.local:8080/labkey"` and `"https://vger.txbiomed.local:8080/labkey"`.

**Authentication:** there are no credentials in the code or in nprcgenekeepr's config file — the config supplies only `baseUrl`/`folderPath`/`schemaName`/`queryName`/columns. So `labkey.selectRows()` relies on `Rlabkey`'s **default** credential mechanism: a `.netrc`/`_netrc` file, or an API key set via `labkey.setDefaults()`. `Rlabkey` is declared in `Imports` with **no version constraint** (`DESCRIPTION:52`, the literal line `Rlabkey,`). Package `Depends: R (>= 4.1.0)`.

The pedigree walk is pure R over the single demographics pull: `getLkDirectRelatives()` embeds the fetch (`getDemographics()`, then a `while` loop over `getParents()`/`getOffspring()`), while `getPedDirectRelatives()` is a **source-agnostic** sibling that takes a `ped` data.frame, validates it (`if (!is.data.frame(ped)) stop(...)`, `R/getPedDirectRelatives.R:41-43`), and runs a functionally equivalent walk using the same shared helpers — so the data source is already abstractable behind that interface. (Note: the two walks are functionally analogous, not byte-identical; they differ in seeding and accumulation.) The package already `Suggests` and uses `mockery` to stub the LabKey path in tests.

The centers in scope are ONPRC (Oregon) and SNPRC (Southwest); NIRC is a plausible third. The relevant LabKey EHR-module repos are `LabKey/ehrModules` (shared base), `LabKey/onprcEHRModules`, `LabKey/snprcEHRModules`, and `LabKey/nircEHRModules`.

---

## 3. Rlabkey: API Surface, Authentication, and Version/Maintenance Risk

### 3.1 Maintenance risk is low

`Rlabkey` is actively and professionally maintained by **LabKey Corporation itself** (maintainer Cory Nathe, `cnathe@labkey.com`; original author Peter Hussey), not an at-risk volunteer. The current CRAN release is **3.4.6, published 2026-02-21** (as of 2026-06-19), and it passes CRAN checks cleanly on **all 13 tested platforms** with no NOTE/WARNING/ERROR; the package is neither orphaned nor archived [verified firsthand against the CRAN package page and check-results page]. The dependency footprint is modest: CRAN metadata lists `Depends: httr, jsonlite` and `Imports: Rcpp (>= 0.11.0)` (with `LinkingTo: Rcpp`); `Rcpp (>= 0.11.0)` is the only version-constrained dependency, and `NeedsCompilation: yes`. License is Apache-2.0.

> Correction carried from review: an earlier framing called `httr`/`jsonlite`/`Rcpp` all "Imports." In fact `httr` and `jsonlite` are **Depends** and only `Rcpp` is an Import — immaterial to the risk assessment but recorded for accuracy.

### 3.2 The exact selectRows call is on solid ground

Every parameter nprcgenekeepr passes to `labkey.selectRows()` exists in the current `Rlabkey` signature and none is deprecated. Precisely, the documented signature is a **superset**, not an exact match: `labkey.selectRows(baseUrl, folderPath, schemaName, queryName, viewName=NULL, colSelect=NULL, colFilter=NULL, colSort=NULL, maxRows=NULL, rowOffset=NULL, colNameOpt="caption", showHidden=FALSE, containerFilter=NULL, parameters=NULL)` — 14 parameters, of which nprcgenekeepr uses a subset (including `viewName`). The function exposes additional non-deprecated parameters (`parameters`, `rowOffset`) it does not use.

Specific options confirmed current and correct:

- **`colNameOpt="fieldname"`** accepts `'caption'` (default), `'fieldname'`, or `'rname'`. `'fieldname'` returns LabKey **field names** (the same identifiers used as arguments to labkey function calls — e.g. the lookup-traversal columns `Id/parents/dam`, `Id/parents/sire`), *not* physical database column names. This is the script-friendly, stable column form the pull depends on. The downstream remapping (`names(pedSourceDf) <- mapPedColumns`) renames columns **by position** after a `colSelect=lkPedColumns` pull, so it relies on the selected column set/order being preserved.
- **`colSelect` lookup traversal** with forward slashes (`Id/parents/dam`) is documented and supported, with LEFT-JOIN semantics (records without a matching lookup value still appear). One documentation typo exists: the prose once calls the delimiter a "backslash" while every example uses `/`; the functional separator is the forward slash, exactly as nprcgenekeepr uses it.
- **`showHidden=TRUE`** is valid and *redundant-but-correct*: since `Rlabkey` 2.3.1, `labkey.selectRows` automatically defaults `showHidden` to `TRUE` when a `colSelect` property is supplied (the declared signature default remains `FALSE`; the `TRUE` is a `colSelect`-triggered runtime override). Passing `TRUE` explicitly matches the package's own behavior.
- **`containerFilter=NULL`** is valid (server default = `Current` scope).

The richer `Rlabkey` surface nprcgenekeepr could adopt — `labkey.executeSql()` (server-side LabKey SQL), `makeFilter()`/`labkey.makeFilter()`, `labkey.getSchemas()`/`labkey.getQueries()`, `labkey.getDefaultViewDetails()`, `labkey.setDefaults()`, and a `labkey.security.*` family (e.g. `labkey.whoAmI`) — is current and documented.

### 3.3 Authentication: API key in netrc is the recommended mechanism

LabKey's currently recommended authentication for scripts and client libraries (including `Rlabkey`) is an **API key stored in a netrc file** using `apikey` as the login and the API key as the password: `machine <host> login apikey password API_KEY`. The netrc file is named `.netrc` on Linux/Mac and `_netrc` on Windows, lives in the home directory, and must be owner-only readable (permissions 400 or 600). LabKey's own docs frame the API-key path as preferred because it "avoids copying and storing your credentials on the client machine." Because nprcgenekeepr's only LabKey code is a bare `labkey.selectRows()` call with no credential handling, it falls back on exactly this `Rlabkey` default mechanism (netrc file, or an API key set in-session via `labkey.setDefaults()`).

Important operational and nuance points:

- **API keys must be enabled by a site administrator first** (Admin Console → Site Settings → Configure API Keys → "Let users create API Keys"; not enabled by default). Keys are revocable (via Delete, without affecting the account) and can be configured to expire (Never / 7 / 30 / 90 / 180 / 365 days, admin-chosen — expiration is optional). If lost, a key is never shown again and must be regenerated.
- **Legacy email+password is NOT formally deprecated or discouraged** in LabKey documentation. The apikey wiki frames API keys as an *alternative* credential (revocable, expiring, suited for service accounts and SSO/2FA users), not as a ranking that calls password login "discouraged." In the `Rlabkey` client specifically, when both an apiKey and email/password are set via `labkey.setDefaults`, the **apiKey takes preference** and email/password is not used (per `man/labkey.setDefaults.Rd`). API-key support landed in `Rlabkey` 2.1.130; username/password via `labkey.setDefaults` in 2.3.4.
- **Session keys** are LabKey's mechanism for compliance/PHI/audited environments (declared intended use, IRB number, PHI level per login); they expire at browser-session end. This is *relevant* because ONPRC/SNPRC EHR is regulated, but no mandate that regulated installs *must* use session keys was found — so whether a static netrc API key is sufficient for unattended use is **(unverified — requires confirmation)** against the live servers.

### 3.4 The real risk: an unpinned client outrunning the server

`Rlabkey` 3.x ratchets up its minimum *LabKey-Server* requirement quickly: per `Rlabkey` NEWS, **3.2.0 is "only supported for LabKey Server v24.1 or later"** and **3.4.1 "requires LabKey Server v24.12 or later"**; 3.0.0 adds a 23.9.0 floor specifically for WAF SQL-parameter encoding in `labkey.executeSql` (reversible via `labkey.setWafEncoding(FALSE)`). Because nprcgenekeepr's `DESCRIPTION:52` declares `Rlabkey,` with no version operator, an install pulls the newest CRAN `Rlabkey` (currently 3.4.6) and its 24.12 server floor — which an older ONPRC/SNPRC EHR server may not satisfy. `Rlabkey` 3.4.5 also "switched to using path-first URLs for LabKey server requests" (a server-interaction change to watch when validating against a specific server version, though it does not alter the `selectRows` argument contract).

---

## 4. Schema/Query Ground Truth from the EHR Modules

All file:path references in this section were verified firsthand against the `develop` (default) branch of the respective `LabKey/*EHRModules` repos as of 2026-06-19.

### 4.1 What `study.demographics` and the `parents` lookup actually are (base `ehrModules`)

- **`study.demographics` is a study DATASET, not a module SQL query**: id=1012, category "Colony Management", `demographicData="true"`, type Standard (`ehr/resources/referenceStudy/study/datasets/datasets_manifest.xml`). It natively exposes `Id` (varchar), `gender` (varchar), `sire` (varchar), `dam` (varchar), `birth` (timestamp), `death` (timestamp) as plain columns on the dataset (`.../datasets_metadata.xml`, demographics table block). So nprcgenekeepr's pulled `Id`/`gender`/`birth`/`death` all exist as dataset fields.
- **`lastDayAtCenter` is NOT a stored field** — it is a computed `ExprColumn` injected onto the demographics table at runtime by Java in `DefaultEHRCustomizer.customizeDemographics()`, defined as `COALESCE(death, max Departure date for non-'Alive' animals)`, `JdbcType.TIMESTAMP` (`ehr/src/org/labkey/ehr/table/DefaultEHRCustomizer.java`, ~lines 678-695). It is absent from the stored dataset metadata. **Consequence:** nprcgenekeepr's `exit` column only exists when the EHR customizer runs; `death` is the reliable fallback.
- **The `parents` lookup is base-EHR**, not center code. `DefaultEHRCustomizer.customizeAnimalTable()` (lines ~1145-1149) wraps the animal `Id` column with a `QueryForeignKey` named `Parents` pointing at query `study.demographicsParents`, keyed `Id->Id`. So `Id/parents/dam` resolves to `demographicsParents.dam`.

> **Correction carried from the adversarial review (a refuted claim):** the dam/sire sub-columns are *not* supplied by `ParentsDemographicsProvider`/`study.parentageSummary`, as one investigation thread asserted. `ParentsDemographicsProvider` does exist and registers a demographics property named `parents`, but that property is a **list** of parentage records exposing `date`/`parent`/`relationship`/`method` sub-fields — it has **no `dam`/`sire` sub-columns**, so `Id/parents/dam` cannot resolve through it. The `dam`/`sire` lookup is the `DefaultEHRCustomizer` → `study.demographicsParents` wiring described above. This matters if anyone later goes looking for where `Id/parents/dam` comes from.

- **A dedicated per-animal parentage query already exists.** In the base module, `study.demographicsParents` (`tableDbType=NOT_IN_DB`) returns `Id`, `dam` (`damType='Observed'`), `sire` (`sireType='Observed'`), `numParents` (and `modified`), `SELECT`ing from `study.demographics` `UNION ALL ehr.supplemental_pedigree`, with `dam`/`sire` FK to `study.animal.id`. The exact traversal nprcgenekeepr depends on is itself exercised inside the base module: `parentsIncorrectGender.sql` self-joins demographics via `LEFT JOIN demographics d2 ON d1.Id.parents.dam = d2.Id` and `... d1.Id.parents.sire = d3.Id` — confirming the contract is real and live.
- The base module also ships `study.demographicsOffspring`, an `ehr.kinship` table (`Id`, `Id2`, `coefficient`) and `ehr.kinshipSummary` (`= ehr.kinship WHERE Id != Id2`) populated by R pipeline scripts (`populateKinship.r`/`populateInbreeding.r`), an `inbreeding` study dataset, and `Pedigree` reports — i.e. kinship/inbreeding are available **server-side** rather than requiring client-side computation, *if* the center has run the pipeline.
- **Versioning:** the `ehr` module uses `ManageVersion:true` with no pinned version string (`ehr/module.properties`); schema versioning is carried by dated dbscript file ranges. Release cadence is monthly (release branches through release26.6 as of June 2026; default branch `develop`). So the schema contract tracks whatever LabKey release the center server runs, not anything nprcgenekeepr controls.

### 4.2 ONPRC

nprcgenekeepr's ONPRC contract maps cleanly onto `onprcEHRModules`, but **every column except literal `Id`/`gender`/`birth`/`death` is supplied by the BASE `ehrModules`, not ONPRC overrides**:

- ONPRC's `study.Demographics.query.xml` is a **metadata-only overlay** (display titles, FK display lookups, participant-view URLs; the `study.animal` FK on `dam`/`sire` is even commented out). It does not redefine `gender`/`birth`/`death`/`dam`/`sire`. (Correction from review: the *base* `ehr` `Demographics.query.xml` is *also* a metadata-only overlay; the physical columns come from the EHR study DATASET definition, not from either `.query.xml`.)
- The `parents` lookup and `lastDayAtCenter` are both base-EHR constructs (the `DefaultEHRCustomizer` wirings above); no ONPRC override of either exists.
- **What ONPRC genuinely overrides is the BODY of `study.demographicsParents.sql`.** Instead of the base raw `demographics.dam/sire UNION supplemental_pedigree`, ONPRC coalesces **curated, genetic-preferred** parentage: `dam = coalesce(genetic-parentage, study.birth.dam, observed-parentage)`, `sire = coalesce(genetic-parentage, study.birth.sire)`, where genetic parentage is drawn from `study.parentage WHERE method in ('Genetic','Provisional Genetic') AND enddate IS NULL`. So nprcgenekeepr's `Id/parents/dam` at ONPRC returns the **curated genetic-or-observed parent, not the raw `demographics.dam`** — this is the correct pedigree value, but it means behavior differs by center. ONPRC's `demographicsParents` also exposes `geneticdam`, `fostermom`, `surrogatedam`, `observeddam`, and `damType`/`sireType`.
- ONPRC additionally exposes dedicated, directly-usable genetics queries nprcgenekeepr currently ignores: `study.pedigree` (`id`/`dam`/`sire`/numeric gender/status, built on `demographicsParents WHERE numParents>0`), `study.kinshipAverage` (mean kinship over living same-species population, reading `ehr.kinshipSummary`), and `study.GeneticValueRanking` (`meanKinship`/`zscore`/`genomeUniqueness`/`rank`/`GeneticValue`) — overlapping exactly with nprcgenekeepr's own mean-kinship/genome-uniqueness/ranking computations.
- **Deployment facts:** `onprc_ehr/module.properties` declares `SupportedDatabases: mssql` (SQL Server only), and container paths follow `/ONPRC/...`. There is **no** `primeuat`/`ohsu`/PRIME-R hostname reference anywhere in the module source (code search returned 0 hits) — the `primeuat.ohsu.edu` baseUrl and `/ONPRC/EHR` folderPath are nprcgenekeepr runtime config, **not attested in the module repo** and therefore **(unverified — requires confirmation)** against the live server.

### 4.3 SNPRC and NIRC — cross-center divergence

All three centers expose `schemaName="study"`, `queryName="demographics"`, with `dam`/`sire` reachable, so nprcgenekeepr's core contract holds at SNPRC and is plausible for NIRC. But the plumbing diverges:

- **`study.parentageSummary` is center-defined, not base.** The base repo ships only the Java provider plus `parentageTypes.tsv`; ONPRC, SNPRC, and NIRC each ship their own `parentageSummary.sql`, and the SQL diverges sharply. ONPRC sources parentage from `study.parentage` (carrying `method` values such as `Genetic`, filtered by `qcstate.publicdata=true` and `enddate is null`) UNIONed with two `study.birth` branches hardcoded to `'Observed'`. **SNPRC and NIRC use an identical, simpler query**: `study.demographics.dam`/`.sire` (UNION ALL), each hardcoding `method='Observed'`, with no `study.parentage` and no `study.birth` union. **So the genetic-vs-observed method distinction collapses to `'Observed'` at SNPRC/NIRC, whereas ONPRC preserves `Genetic`/`Observed`.**
- SNPRC's `study.demographics` carries `dam`/`sire` as **direct** columns (FK to `study.animal.id`), and its default view exposes plain `dam`/`sire` — but nprcgenekeepr requests `Id/parents/dam`/`Id/parents/sire`, which resolve via the base lookup; the direct columns and the lookup are two paths to the same `dam`/`sire`.
- SNPRC's own `demographicsParents.sql` *is* richer than NIRC's (it coalesces genetic calls and emits `damType`/`sireType` of `Genetic`/`Provisional Genetic`/`Observed`), so SNPRC has a `study.parentage` table with genetic methods even though its `parentageSummary` ignores them. NIRC's `demographicsParents.sql` only uses `demographics.dam`/`.sire` and ends with `-- TODO: Incorporate fostering? Genetic testing?`.
- **A dedicated, ready-made `study.Pedigree` query exists at SNPRC and NIRC** (`Id`, `Dam`, `Sire`, numeric gender 1/2/3, numeric status 0/1, species, `source='Demographics'`) that nprcgenekeepr could consume directly instead of walking demographics client-side — *but* its gender/status are **numerically coded** and the source expression differs per center: SNPRC uses `gender.origGender` (`'M'`/`'F'`), NIRC uses `gender.meaning` (`'male'`/`'female'`). The `demographics.gender` **lookup target also differs**: ONPRC/SNPRC point at `ehr_lookups.gender_codes.code`, while NIRC has no `gender_codes` FK and reads `gender.meaning`.
- **`lastDayAtCenter` availability differs.** SNPRC's `Demographics.query.xml` declares a literal `lastDayAtCenter` column; NIRC's does not, so NIRC relies on the base `DefaultEHRCustomizer`-computed `ExprColumn`. (Correction from review: `lastDayAtCenter` is **not** produced by `DepartureDemographicsProvider`/`study.demographicsMostRecentDeparture`, as one thread asserted — that provider exposes a differently-named `MostRecentDeparture` property. `lastDayAtCenter` is the `DefaultEHRCustomizer` `COALESCE(death, max Departure date)` `ExprColumn`. Practical upshot for nprcgenekeepr is unchanged: it resolves at SNPRC (literal) and NIRC (base-computed).)

**Net:** the core contract is real and grounded in the shared base module, but the per-center variation in parentage curation, gender encoding, and `lastDayAtCenter` provenance clearly argues for **configuration over hardcoding**.

---

## 5. Alternative / Updated Integration Approaches

| Approach | What changes | Effort | Benefit | Risk |
|---|---|---|---|---|
| **A. Add `Rlabkey` version floor** | Replace `Rlabkey,` in `DESCRIPTION` with a pinned range/floor matching the target server's supported client | Minutes | Removes the unversioned-dependency hazard; makes CRAN re-submission reproducible | Low. Must choose a floor consistent with the *actual* ONPRC/SNPRC server version (currently unverified) |
| **B. Formalize a data-source adapter** around `getDemographics()` | Introduce a dispatcher (e.g. `getPedigreeSource(source=...)`) returning a normalized `ped` data.frame (`id,sex,birth,death,exit,dam,sire`); make `getLkDirectRelatives` delegate its walk to `getPedDirectRelatives`; add a `file` adapter | ~1–2 days (mostly tests + refactor) | Pluggable source (labkey \| file \| other-EHR); offline/deterministic testing; isolates the brittle pull | Low–medium. The seam already exists; main cost is test coverage. No new external behavior |
| **C. Explicit optional auth** via `labkey.setDefaults(apiKey=, baseUrl=)` | Read `apiKey`/`baseUrl` from config or env; prefer when present; fall back to `.netrc` | ~0.5 day | LabKey's preferred method; testable via `mockery`; clearer errors when auth is missing | Low. Keep `apiKey` out of the repo (env/home only). API-key path needs site-admin enablement |
| **D. Move hardcoded ONPRC defaults to config / clear error** | Move `baseUrl`/`folderPath`/lookup columns out of `getSiteInfo()`'s no-config branch; reconcile example-config drift (flat `dam`/`sire` vs `Id/parents/dam`) | ~0.5 day | Eliminates the single hardcoded-query single point of failure | Low |
| **E. Server-side filter (`makeFilter`/`colFilter`) or `executeSql`** parentage query | Replace `colFilter=NULL` full-table pull with focal-Id filter, or a focused `SELECT Id, Id.parents.sire, Id.parents.dam` via `labkey.executeSql` | ~1 day | Less data transferred; possibly faster | Medium. Only worth it if pulls are large (unmeasured). `executeSql` uses **dot** notation (`Id.parents.dam`), so it is not a drop-in of the slash-form `lkPedColumns`; trades a stable `selectRows` contract for an explicit-SQL one |
| **F. Consume center `study.Pedigree` / `ehr.kinship` directly** | Switch source from `demographics` to the center's ready-made `Pedigree` query (and optionally read server-side kinship) | ~1 day + per-center decode | Normalized pedigree in one query; reuses server-side kinship | Medium. Numeric gender/status need per-source decode; gender source expr differs per center; gated on the query being present and permissioned for the service account at each center |
| **G. Direct `httr2`/REST rewrite** | Replace `Rlabkey` with a hand-rolled REST client | High | Full control of the HTTP layer | **High — NOT recommended.** Would re-implement auth, session/CSRF handling, and netrc credential resolution that `Rlabkey` provides for free, increasing maintenance burden on a package working toward re-submission |

Notes on what `Rlabkey` gives you "for free" (relevant to rejecting G): the LabKey rAPI doc states verbatim that "Rlabkey handles `sessionid` and authentication internally" and passes the sessionid as an HTTP header for all calls in the R session, with credentials supplied via netrc. **(Unverified — requires confirmation)** is the stronger framing that `Rlabkey` also internally handles "type coercion" and "lookup traversal": the cited source does not support those — lookup traversal is resolved **server-side** by LabKey's query syntax (Rlabkey just passes column names through), and the docs are silent on client-side type coercion. A REST rewrite would chiefly need to re-implement session/credential handling, and — because LabKey lists "Fetching CSRF Token" as its own topic — possibly CSRF-token management for any write operations.

---

## 6. Risks (prioritized)

1. **Unpinned `Rlabkey` can outrun the server.** *Severity: high. Likelihood: medium-high* (rises every `Rlabkey` minor release). A fresh install pulls `Rlabkey` 3.4.6 with its server ≥ 24.12 floor; an older ONPRC/SNPRC EHR server would fail. **Mitigation:** Approach A (version floor matching the actual server) + verify the live server version.

2. **No credential strategy is documented or tested.** *Severity: high. Likelihood: medium.* The package silently depends on `Rlabkey`'s default netrc/API-key resolution; if the admin has not enabled API keys, or netrc is misconfigured, the call fails with a raw `Rlabkey`/`httr` error. **Mitigation:** Approach C (explicit optional `apiKey` + clear "no credential found" error) and a setup doc; optionally a `labkey.whoAmI`/`labkey.getSchemas` fail-fast probe before `getDemographics()`.

3. **`lastDayAtCenter` and the `parents` lookup are runtime-injected, not stored.** *Severity: medium. Likelihood: low–medium.* If a deployment serves `demographics` without the active EHR customizer, or NIRC's non-literal `lastDayAtCenter` path is hit, those columns can be null/absent. **Mitigation:** treat `death` as the reliable `exit` fallback; add a per-center runtime column-presence probe; document these as base-EHR dependencies.

4. **Cross-center semantic divergence (silent).** *Severity: medium. Likelihood: high* (it is already true). ONPRC returns curated genetic-preferred parents; SNPRC/NIRC collapse method to `'Observed'`; gender encoding differs (`gender_codes.code` vs `gender.meaning`). nprcgenekeepr sees only post-coalesce `dam`/`sire`, so genetic-vs-observed handling is fixed server-side and invisible to the client. **Mitigation:** document that nprcgenekeepr deliberately consumes curated parentage and that semantics differ by center; normalize gender at the source boundary with a center-aware decoder via the `getPedDirectRelatives` seam.

5. **Config drift / single hardcoded query.** *Severity: medium. Likelihood: medium.* The example config uses flat `dam`/`sire` (SNPRC template) while the ONPRC fallback uses `Id/parents/dam`; both remap to the same downstream contract, so this is a maintenance burden rather than a broken shared contract. **Mitigation:** Approach D.

6. **No deterministic test of the live call.** *Severity: low–medium. Likelihood: high.* `test_getDemographics.R` skips on CRAN and on any network failure, so the integration is never exercised deterministically. **Mitigation:** a mocked adapter test + recorded fixture (the package already `Suggests`+uses `mockery`).

7. **`primeuat.ohsu.edu` / `/ONPRC/EHR` are unattested runtime config.** *Severity: low. Likelihood: low.* Not in any module repo. **Mitigation:** verify against the live PRIME-R server; keep as config, not code.

---

## 7. Recommendation

`Rlabkey` itself is **low maintenance risk** — vendor-maintained, CRAN-clean on all 13 platforms, and the exact option set nprcgenekeepr uses is current and non-deprecated. So the re-submission risk from this dependency is **server-compatibility and credential-config, not API breakage**, and a REST rewrite (Approach G) is explicitly **not** recommended. Prioritized, actionable list:

### Quick wins (do before re-submission)

1. **Add an `Rlabkey` version floor** — *what:* replace `Rlabkey,` with a pinned floor/range in `DESCRIPTION:52`. *Why:* removes the only unversioned dependency, a concrete CRAN re-submission hazard, and prevents pulling a server-incompatible client. *Effort:* minutes (then `R CMD check`). *File:* `DESCRIPTION`. *Caveat:* choose the floor to match the actual server version (see Open Questions) — pick conservatively if unknown.

2. **Move hardcoded ONPRC defaults into config; reconcile drift** — *what:* push `baseUrl`/`folderPath`/`lkPedColumns` out of `getSiteInfo()`'s no-config branch into a shipped default config (or reduce the fallback to a clear error), and align the example config's flat `dam`/`sire` with the documented lookup form. *Why:* eliminates the single hardcoded-query point of failure and the SNPRC-vs-ONPRC representation inconsistency. *Effort:* ~0.5 day. *Files:* `R/getSiteInfo.R`, `inst/extdata/example_nprcgenekeepr_config`.

3. **Add explicit optional API-key auth with netrc fallback** — *what:* if `apiKey`/`baseUrl` are present in config/env, call `labkey.setDefaults(apiKey=, baseUrl=)`; otherwise fall back to `.netrc`. Add a clear error when no credential is found. *Why:* LabKey's preferred method; testable; better failure messages. Keep `apiKey` out of the repo. *Effort:* ~0.5 day. *Files:* `R/getSiteInfo.R`/`R/getDemographics.R` + a setup doc.

### Larger work (high value, do next)

4. **Formalize the data-source adapter around the existing `getPedDirectRelatives` seam** — *what:* introduce a dispatcher returning a normalized `ped` data.frame, make `getLkDirectRelatives` delegate its walk to the source-agnostic `getPedDirectRelatives`, and add a `file` adapter. *Why:* `getPedDirectRelatives` is already a source-agnostic walker (`R/getPedDirectRelatives.R:41-43`), so the seam exists; this makes LabKey one pluggable provider, enables offline/deterministic tests, and isolates the brittle pull. *Effort:* ~1–2 days. *Files:* new dispatcher + `R/getLkDirectRelatives.R`, `R/getPedDirectRelatives.R`, tests.

5. **Add a deterministic mocked integration test + recorded fixture** — *what:* exercise the LabKey adapter off-network using `mockery` (already used in `test_getFocalAnimalPed.R`). *Why:* today `test_getDemographics.R` skips entirely without a live server, so the contract is never regression-tested. *Effort:* ~0.5 day. *File:* `tests/testthat/`.

### Defer until measured

6. **Server-side filtering or `executeSql` / consuming `study.Pedigree`/`ehr.kinship`** — *what:* Approaches E/F. *Why:* only worth it if pulls are large or if reusing server-side kinship is desired; both add per-source decode or SQL-contract maintenance. *Effort:* ~1 day each. **Recommend deferring** until pull size is measured and per-center query availability/permissions are confirmed.

These changes keep nprcgenekeepr on the well-supported `Rlabkey` path, harden exactly the two CRAN-relevant fragilities (unpinned dependency, undocumented auth), and exploit the abstraction seam that already exists — without taking on the maintenance burden of a hand-rolled client.

---

## 8. Open Questions / Items needing maintainer or live-server confirmation

1. **What LabKey Server version do the live ONPRC (`primeuat.ohsu.edu`) and SNPRC production servers run?** Determines whether the latest `Rlabkey` (3.4.6, server ≥ 24.12) is compatible and what version floor to pin in `DESCRIPTION` (Recommendation 1).
2. **Do the ONPRC/SNPRC EHR installations enforce compliance auth (session keys / declared PHI level per login)?** If so, a static netrc API key may be insufficient or disallowed for unattended use, changing the credential strategy.
3. **Has an admin enabled "Let users create API Keys" on the target servers?** If not, the API-key path cannot be used and netrc-password (or interactive) remains the only option; Recommendation 3 must keep `apiKey` optional.
4. **Which study folder under `/ONPRC` actually hosts demographics on the live server?** `/ONPRC/EHR` is plausible but not attested in the module repo (only `/ONPRC` and `/ONPRC/DCM/NHP Resources` are evidenced).
5. **Are `study.demographicsParents`, `study.Pedigree`, `study.kinshipAverage`, `ehr.kinship` present and permissioned for nprcgenekeepr's service account** at each center on the production build (vs the `develop` branch examined here)? Gates Approaches E/F.
6. **Does NIRC populate `study.parentage` with genetic calls at all,** given its `demographicsParents.sql` uses only `demographics.dam`/`.sire` and its TODO defers genetic testing?
7. **How large is a full demographics pull in practice?** The performance case for server-side filtering / `executeSql` only matters if the full-table pull is slow; for a few thousand animals the client-side walk is likely fine.
8. **Exact gender tokens returned via `colNameOpt='fieldname'` at each center** (raw `gender_codes.code` vs `gender.meaning` `'male'`/`'female'`), needed so the sex-validation QC decodes correctly per source.

---

## 9. Appendix: Claim–Source Table (load-bearing claims)

| Claim | Source | Verification status |
|---|---|---|
| `Rlabkey` current release is 3.4.6, published 2026-02-21, maintained by Cory Nathe / LabKey Corp (orig. author Peter Hussey); not orphaned | `https://cran.r-project.org/web/packages/Rlabkey/index.html` | Confirmed (firsthand WebFetch) |
| `Rlabkey` 3.4.6 passes CRAN checks on all 13 platforms, no NOTE/WARN/ERROR | `https://cran.r-project.org/web/checks/check_results_Rlabkey.html` | Confirmed (firsthand) |
| All `selectRows` params nprcgenekeepr uses exist and are non-deprecated; signature is a 14-param **superset** | `https://cran.r-project.org/web/packages/Rlabkey/refman/Rlabkey.html` | Confirmed, with correction (claim said "exact"; it is a superset, and the original quote omitted `viewName`/`parameters`) |
| `colNameOpt="fieldname"` returns LabKey **field** names (not physical DB names); downstream remap is by **position** | refman + `R/getDemographics.R:43`, `R/getSiteInfo.R:71-75`, `R/getLkDirectRelatives.R`, `R/getLkDirectAncestors.R` | Confirmed, with wording correction |
| `colSelect` supports forward-slash lookup traversal (`Id/parents/dam`); LEFT-JOIN semantics | `Rlabkey` refman (selectRows / getQueryDetails / getLookupDetails) | Confirmed (delimiter-typo caveat: prose says "backslash", examples use `/`) |
| `showHidden=TRUE` is redundant-but-correct (auto-`TRUE` under `colSelect` since 2.3.1) | `Rlabkey` NEWS 2.3.1 / 2.1.135; `man/labkey.selectRows.Rd` | Confirmed |
| Recommended auth = API key in netrc (`machine <host> login apikey password API_KEY`); nprcgenekeepr falls back on this | `…wiki-page.view?name=apikey` + `…name=netrc`; `R/getDemographics.R` | Confirmed (netrc naming/perms are on the linked `netrc` page) |
| Email+password NOT formally deprecated; in `Rlabkey`, apiKey takes preference if both set | `…name=apikey`; `Rlabkey` 3.4.6 `man/labkey.setDefaults.Rd`; NEWS 2.1.130/2.3.4 | Confirmed, with framing correction ("preference" is precise in the Rlabkey sense) |
| API keys must be admin-enabled; revocable; optionally expiring | `…name=apikey` | Confirmed; "to work at all" softened to "API-key path specifically" |
| `Rlabkey` 3.x raises server floor: 3.2.0 ≥ 24.1, 3.4.1 ≥ 24.12 (3.0.0 ≥ 23.9.0 is WAF-conditional); nprcgenekeepr `DESCRIPTION:52` has no version op | `Rlabkey` NEWS; `DESCRIPTION:52` | Confirmed |
| `study.demographics` is study dataset id=1012, "Colony Management", `demographicData=true` | `LabKey/ehrModules:ehr/.../datasets_manifest.xml` | Confirmed (firsthand `gh api`, `develop`) |
| demographics natively has `Id`/`gender`/`sire`/`dam` (varchar), `birth`/`death` (timestamp) | `…/datasets_metadata.xml` | Confirmed |
| `lastDayAtCenter` is a runtime `ExprColumn` = `COALESCE(death, max Departure)`, not stored | `…/DefaultEHRCustomizer.java` (~678-695) | Confirmed |
| `parents` lookup wired in base customizer → `study.demographicsParents` (`Id->Id`) | `DefaultEHRCustomizer.java` (~1145-1149) | Confirmed |
| `study.demographicsParents` returns `Id`/`dam`/`sire`/`numParents` (base: demographics UNION supplemental_pedigree) | `…/demographicsParents.sql` + `.query.xml` | Confirmed |
| The `Id.parents.dam`/`.sire` traversal is exercised inside the base module | `…/parentsIncorrectGender.sql` | Confirmed |
| dam/sire lookup is **NOT** supplied by `ParentsDemographicsProvider`/`parentageSummary` | `ParentsDemographicsProvider.java` + `DefaultEHRCustomizer.java` + `demographicsParents.*` | **Refuted** original attribution → corrected to `DefaultEHRCustomizer`→`demographicsParents` |
| ONPRC `Demographics.query.xml` is metadata-only; doesn't redefine columns | `LabKey/onprcEHRModules:…/Demographics.query.xml` vs base | Confirmed (base is also metadata-only; physical cols from dataset) |
| ONPRC overrides `demographicsParents.sql` to curated genetic-preferred `dam`/`sire` | `onprc_ehr/…/demographicsParents.sql` vs base | Confirmed |
| ONPRC `lastDayAtCenter` is base-computed, no ONPRC override | `DefaultEHRCustomizer.java`; `ONPRC_EHRCustomizer.java`; ONPRC `Demographics.query.xml` | Confirmed |
| ONPRC EHR is mssql-only; no `primeuat`/PRIME-R in module source | `onprc_ehr/module.properties`; code search (0 hits) | Confirmed |
| `parentageSummary.sql` is center-defined; ONPRC keeps `Genetic`, SNPRC/NIRC collapse to `'Observed'` | base tree + each center's `parentageSummary.sql` | Confirmed |
| SNPRC demographics has direct `dam`/`sire` (FK study.animal.id); nprcgenekeepr uses lookup path | `snprc_ehr:…/Demographics.query.xml`, `.qview.xml` | Confirmed |
| SNPRC & NIRC ship `study.Pedigree` (numeric gender/status); gender source differs (origGender vs meaning) | `snprc_ehr`/`nirc_ehr:…/Pedigree.sql` | Confirmed |
| demographics.gender lookup differs: ONPRC/SNPRC → `gender_codes.code`; NIRC → `gender.meaning` | each center `Demographics.query.xml` + NIRC `Pedigree.sql` | Confirmed |
| `lastDayAtCenter` literal at SNPRC, base-computed at NIRC; **NOT** from `DepartureDemographicsProvider` | base customizer + SNPRC/NIRC `Demographics.query.xml` | **Refuted** original mechanism → corrected to `DefaultEHRCustomizer`; XML facts confirmed |
| nprcgenekeepr fallback column set is the ONPRC-shaped contract | `R/getSiteInfo.R:56-87` (esp. 71-74); `R/getDemographics.R:37-48` | Confirmed (firsthand local read) |
| Entire integration = one `selectRows` (full pull); walk is pure-R client-side | `R/getDemographics.R`, `R/getLkDirectRelatives.R`, `R/getParents.R`, `R/getOffspring.R` | Confirmed |
| `getPedDirectRelatives` is source-agnostic (validates `ped`, runs equivalent walk) | `R/getPedDirectRelatives.R:28,41-43,48-59` | Confirmed (functionally equivalent, not byte-identical) |
| Config externalizes per-center params; only ONPRC fallback hardcoded | `R/getSiteInfo.R:37-44,65-75`; `inst/extdata/example_nprcgenekeepr_config` | Confirmed |
| Example config (flat `dam`/`sire`, SNPRC) vs ONPRC fallback (`Id/parents/dam`) differ | `example_nprcgenekeepr_config:42-43`; `R/getSiteInfo.R:71-73` | Confirmed; reframed as configurable per-site value, not broken shared contract |
| LabKey names `apiKey` (via `labkey.setDefaults`) preferred; "avoids storing credentials on the client" | `…name=apiSessionKey`; `man/labkey.setDefaults.Rd` | Confirmed (two assertions live on two pages) |
| `Rlabkey` handles session/auth internally (what a REST rewrite would re-implement) | `…name=rAPI`; selectRows refman | **Uncertain** as originally bundled → corrected: session/auth/netrc confirmed; "type coercion" and client-side "lookup traversal" NOT supported by source |
| `Rlabkey` is `Imports` with no floor; `Depends: httr, jsonlite`, `Imports: Rcpp (>= 0.11.0)` | CRAN page; `DESCRIPTION:52` | Confirmed, with correction (`httr`/`jsonlite` are **Depends**, not Imports, in the original claim's classification) |