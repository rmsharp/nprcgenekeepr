# The config file's format and its reader: one decision (S1013, 2026-10-18)

**Status: RULED S1013 -- option A, "fix the reader" (the owner took the recommended option); BUILT S1014.** Decision session, no code, no tests. The ruling
was recorded as a READY build item (strict TDD, a later session); semicolons do not separate terms; the one open question, a whole list inside one pair
of quotes, was asked at S1014's PRE-RED and **the owner ruled it reads as one value** (the notes say to quote each name separately; the alternative, splitting
the two list settings on commas in `getSiteInfo()`, was not taken). S1014 also made an unclosed quote end at the end of its line (the prototype below turns
`center = "SNPRC` above two good lines into 1 setting; today's reader gives 3). The owner had said the documentation and the reader can each change
the other, so neither was fixed ahead of the pick; the candidates, evidence and sentences below are what the pick was made from.

## 1. Where the format is described today

| # | Place | What it says about the format |
|---|---|---|
| 1 | `inst/extdata/examples/example_nprcgenekeepr_config:1-15` | The only statement of rules (comments, separators, parentheses, quoting). |
| 2 | `data/exampleNprcgenekeeprConfig.RData` (`R/data.R:4-12`) | The loadable copy the README (`README.md:166-172`) and the manual (`vignettes/a3manual.md:137-147`) tell users to open with `View()`. **It is not the shipped file**: 34 lines against 87, an older copy with the same three wrong statements (below), two typos ("esssential", "columnn") and none of the newer notes (authentication, species overrides, center-specific `lkPedColumns`). `DOCS_STALENESS_AUDIT_SLICE6E_2026-10-01.md:268` checked only its length. No `data-raw/` script builds it. |
| 3 | `R/loadSiteConfig.R:6-10` | Says its reader "handles the documented configuration format (comment lines, blank lines, and multi-line / quoted / comma-separated values)". |
| 4 | `getTokenList()` help (`R/getTokenList.R:4-9`), `getSiteInfo()` help (`R/getSiteInfo.R:4-45`) | Name no rules. `getSiteInfo()` says only that seven values "are read from the configuration file". |
| 5 | README, manual, `_summary_of_major_functions.Rmd:57-68`, the colony-manager guide | Name the file and link the example; the guide does not mention the file. |

## 2. What the notes say against what the reader does

The reader is `readConfigLines()` (full-line `#` comments dropped) then `getTokenList()`: join all lines with a space; delete every double quote; put
spaces around every `=`; split on blanks and commas; the term before an `=` names a setting; its value is every term up to the term before the next
name; remove `(` and `)`. **It has been unchanged since 2017-09-13** (`git log -S'WHITE_SPACE' -- R/getTokenList.R` finds one commit, `5ca3e45fc`). The
notes' separator sentence was added nine days later (`26c97c4b3`, 2017-09-22), when the pattern already read `[[\p{WHITE_SPACE},]]+`: **the three wrong
statements below have been wrong since the day they were written.** No version of the program ever honored them, so no file that works today can have
relied on them.

Measured S1013 through the real chain (`readConfigLines()` -> `getTokenList()`, and `getSiteInfo()` for the folder case); `<>` marks one value:

| Statement in the notes | Input | The reader gives | Verdict |
|---|---|---|---|
| "Lines beginning with `#` are ignored"; "Empty lines are ignored" | (S1012 tests) | as stated | true |
| Terms separated by "blank characters, commas ... or newline characters" | `(Id, gender, birth)`; two lines with a trailing comma; `Id gender birth`; tab-separated | `<Id> <gender> <birth>` each time | true |
| Terms separated by **semicolons** | `(Id; gender; birth)` | `<Id;> <gender;> <birth>` | **false** (the `;` stays in the column name) |
| "Parentheses may be used for readability, but they are ignored" | the shipped file's two lists | seven values each | true for lists; also stripped inside a value (see 3) |
| A term "will need to be in quotes because [it has] characters that would serve to break up the definition" | `folderPath = "/My Folder/EHR"` | `</My> <Folder/EHR>`; `getSiteInfo()$folderPath` has length 2 | **false** (quotes are deleted before the split, so they never protect anything) |
| | `folderPath = "/Lab, East/EHR"` | `</Lab> <East/EHR>` | **false** |
| `http://deepthought:8080/labkey` "would become ... four terms" | the same address unquoted, and quoted | `<http://deepthought:8080/labkey>` both ways | **false** (`:` and `/` do not separate) |
| (the example file's own line 72-73: "no spaces or commas in the path") | `"C:/Users/Jane Doe/x.csv"` | `<C:/Users/Jane> <Doe/x.csv>` | true, and it contradicts the quoting sentence above |

**Behaviors no sentence mentions** (a user cannot know them): an `=` inside a value starts a bogus second setting (`baseUrl = "http://h/labkey?a=b"` gives
`baseUrl=<http://h/labkey?a> <=>` and a setting named `http://h/labkey?a`); round brackets inside a value are removed after the split (`"/Lab (old)/EHR"` gives
`</Lab> <old/EHR>`); **a setting with an empty value takes the next setting's name as its value** (`apiKey =` then `center = "SNPRC"` gives `apiKey=<center> <=>`, so
`getConfigApiKey()` would return `center`; as the last setting it gives `<NA> <=>`); a `#` ending a setting's line joins the value (a former `BACKLOG.md` item, now folded into `:168`); when a
setting appears twice the first wins; names are read in any case (S1012). A byte-order mark at the start of the file is handled (checked: the first name equals `center`).

## 3. The candidates

**A. Fix the reader so the notes become true** (same file format). A double quote keeps a term whole (blank, comma, `=`, round brackets inside it); a `#` that
*starts a word* begins a comment to the end of the line (so `labkey#top` unquoted stays whole); an empty value is empty; blanks, commas, tabs and line breaks
still separate; semicolons still do not (the notes lose that sentence). Effort M, strict TDD. **Measured with a throwaway prototype** (appendix; scratch only,
`R/` untouched): over 19 forms of a file, 11 read exactly as before (the shipped file; an unquoted address; lists with commas, blanks, tabs, two lines,
no parentheses; a backslash path; `#` in an address; a semicolon list; an unquoted value with a blank) and 8 change, **every one of them a form that reads wrongly
today** (quoted blank, comma, `=`, or brackets; empty value in the middle or last; a trailing comment; a Windows path with a blank). With the prototype swapped into
the package, the 86 test blocks of 12 test files that read a config file pass unchanged (0 failed, 0 errors; the same 86 pass with the current reader, and a control shows
the swap reaches `getConfigApiKey()`: `apiKey = "two words"` reads `two` now and `two words` with the prototype). **One real risk:** a whole list inside one pair of quotes works
today (`lkPedColumns = "Id, gender, birth"` gives three values, because quotes do nothing) and would read as one value. The build session decides whether
`getSiteInfo()` splits the two list settings (`lkPedColumns`, `mapPedColumns`) on commas to keep that form working, or documents the change. Not measured: how many
centers' files do this (the shipped example does not).

**B. Correct the notes to describe the reader as it is** (no code). The notes say: quotes have no effect and may be left out; a value must not hold a blank, a comma,
an `=` or round brackets; a `#` must start its own line; separators are blanks, commas, tabs and line breaks (not semicolons); never leave a value blank. Effort S. Every existing file
reads as before; the traps in section 2 stay, now documented. A test pins each stated rule.

**C. A standard format.** Measured S1013 with the installed or scratch-installed packages (`yaml` 2.3.12, `config` 0.3.2, `configr` 0.3.6, `RcppTOML` 0.2.3, `ini` 0.3.1,
`jsonlite` 2.0.0; the project's `renv` untouched). **None reads the existing file as it is, with no conversion first:**

| Reader | The shipped file, unchanged | Adds to `DESCRIPTION` | Other measured behavior |
|---|---|---|---|
| `yaml::read_yaml` | no error, but the whole file comes back as **one string** (the 7 settings are lost, silently) | none (already in Suggests; move to Imports) | `key: value` form: a blank in a quoted value, an unquoted address and a trailing comment are fine, an empty value gives `NULL`, a duplicate key is an error; a bare `NO` reads as `FALSE`; an old `center = "SNPRC"` line reads as one string, so old files need detecting |
| `config::get` | error "subscript out of bounds" | none new (needs `yaml`) | needs a `default:` section; **runs R code in the file**: `center: !expr paste('R','code','ran')` returned `R code ran` (`yaml` alone refuses without `eval.expr = TRUE`) |
| `configr::read.config` | `FALSE` when it guesses the type and when json, ini or toml is forced; one string when yaml is forced | `jsonlite`, `ini`, `RcppTOML` (+`Rcpp`), `stringr`, `glue` | on a file with only single-value settings it guesses TOML and works, but a real file always has the two lists |
| `RcppTOML::parseToml` | error "could not determine value type" | `RcppTOML` (+`Rcpp`) | the closest to today's file: after changing **only** the two lists' `(` `)` to `[` `]` the shipped file parses to the same 7 settings; blank, comma, `=`, `#` inside quotes and a trailing comment are fine; an unquoted word, an empty value and a duplicate key are errors; `"C:\Users\me"` is an error (needs single quotes); a dotted name becomes a nested table |
| `ini::read.ini` | error "object 'lastSection' not found" (no section header) | none new | with a `[site]` header it keeps the quote characters and returns a list as one string |
| `jsonlite::fromJSON` | error (the file has comments) | none new | cannot hold comments, which the notes depend on |

Whatever is chosen, every center edits its `~/.nprcgenekeepr_config`; the loader must tell an old-format file from a new one (`yaml` and `configr` return a string or `FALSE`
without complaint); and the exported `getTokenList()` needs a keep-or-deprecate ruling. Effort M-L.

## 4. Proposed sentences, one per place (for A; B and C differ as noted)

| Place | Proposed sentence |
|---|---|
| 1. notes, separators (`:8-10`) | "Terms are separated by blanks, commas or line breaks; a semicolon does not separate terms." |
| 1. notes, quoting (`:12-15`) | "Put a value in double quotes when it holds a blank, a comma, an equals sign or round brackets; it is then read as one term (an address such as http://deepthought:8080/labkey needs no quotes)." |
| 1. notes, comments (`:3`) | "A # that begins a word starts a comment that runs to the end of the line, on a line of its own or after a setting." |
| 2. the loadable copy | Rebuild it from the shipped file so it carries these same notes; add the build script that does not exist today. |
| 4. `getTokenList()` help | "The term before each equals sign names a setting and the terms after it, up to the next name, are its value; terms are separated by blanks, commas or line breaks, a term in double quotes is kept whole, and a # that begins a word starts a comment." |
| 4. `getSiteInfo()` help | "The format of the configuration file is described in the notes at the top of the example file, `example_nprcgenekeepr_config`, in the package's `extdata/examples` folder." |
| 3, 5. `loadSiteConfig()` help, README, manual, guide | No change (the `loadSiteConfig()` parenthesis is true under A). |

Under **B** the quoting sentence becomes "Quotes have no effect and may be left out; a value must not hold a blank, a comma, an equals sign or round brackets", the comment sentence
becomes "A # must start its own line", and a blank value is called out as a trap. Under **C** the notes are rewritten for the chosen format and gain a migration paragraph.

## 5. Recommendation

**A.** It is the only direction under which the notes' promises for quoting and comments become true without every center editing its file; the shipped file and ten other forms read
as before, and the forms that change are the ones that read wrongly today. It also fixes the blank-value trap (a wrong API key, `center`) that B only documents. The cost is one
compatibility decision (a whole list inside one pair of quotes) for the build session. **B** is the right pick if the owner wants no program change at all. **C** is not
recommended: nothing reads today's file as it is, so it costs every center an edit and a detection step, and it adds a dependency for a file of eleven settings.

## Appendix: the throwaway prototype (scratch only; not in `R/`)

```r
# Rules: a double quote groups (content literal); blanks and commas outside quotes separate; '=' outside quotes is
# its own term; '(' and ')' outside quotes are dropped; '#' that STARTS a word begins a comment to the end of the
# line; an empty value is character(0). Same return shape as getTokenList().
protoTokenList <- function(lines) {
  chars <- strsplit(paste(lines, collapse = "\n"), "")[[1L]]
  toks <- list(); cur <- character(); inq <- FALSE; hadq <- FALSE; incom <- FALSE
  flush <- function() {
    if (length(cur) || hadq) toks[[length(toks) + 1L]] <<- list(t = paste(cur, collapse = ""), q = hadq)
    cur <<- character(); hadq <<- FALSE
  }
  for (ch in chars) {
    if (incom) { if (ch == "\n") incom <- FALSE; next }
    if (inq) { if (ch == "\"") inq <- FALSE else cur <- c(cur, ch); next }
    if (ch == "\"") { inq <- TRUE; hadq <- TRUE; next }
    if (ch == "#" && !length(cur) && !hadq) { incom <- TRUE; next }
    if (ch == "=") { flush(); toks[[length(toks) + 1L]] <- list(t = "=", q = FALSE); next }
    if (grepl("[[:space:],]", ch)) { flush(); next }
    if (ch %in% c("(", ")")) next
    cur <- c(cur, ch)
  }
  flush()
  isEq <- vapply(toks, function(x) identical(x$t, "=") && !x$q, logical(1L))
  nameAt <- which(c(isEq[-1L], FALSE))
  ends <- c(nameAt[-1L] - 1L, length(toks))
  list(param = vapply(toks[nameAt], function(x) x$t, character(1L)),
       tokenVec = lapply(seq_along(nameAt), function(k) {
         from <- nameAt[k] + 2L
         if (from > ends[k]) character(0L) else vapply(toks[from:ends[k]], function(x) x$t, character(1L))
       }))
}
```

Reproduce the section 2 table with `readConfigLines()` then `getTokenList()` on a temporary file per input; swap the prototype in with
`unlockBinding("getTokenList", ns); assign("getTokenList", protoTokenList, envir = ns)` (`ns <- asNamespace("nprcgenekeepr")`) and run `testthat::test_file()` on
`test_getTokenList.R`, `test_getParamDef.R`, `test_readConfigLines.R`, `test_getConfigApiKey.R`, `test_getSiteInfo.R`, `test_loadSiteConfig.R`,
`test_loadSpeciesOverrides.R`, `test_setLabKeyDefaults.R`, `test_modSiteConfig.R`, `test_appUI_siteinfo.R`, `test_defaultSiteParams.R` and `test_getLkDirectAncestors.R`
(86 blocks).
