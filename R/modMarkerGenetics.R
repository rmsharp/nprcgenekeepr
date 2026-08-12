## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Marker Genetics Shiny Module

# nolint start: commented_code_linter.
## Issue #153 Slice 5, D1 vocabulary discipline: "LD block"/"linkage block"
## throughout, never bare "haplotype" -- reserved for issue #148's classical
## named-MHC-allele meaning (sequencing-audit vocabulary-overlap finding).
## Persistent, non-dismissable per markerLdBlock()'s own caveat column
## (R/markerLdBlock.R's .markerLdBlockCaveat) -- restated here as static UI
## markup (not a togglable notification) since a caveat a curator can
## dismiss is not persistent.
# nolint end: commented_code_linter.
.linkageLdBlockCaveatText <- paste(
  "This LD-block statistic is a descriptive measure only -- not a",
  "rigorous, pedigree-aware LD-block measure. Classical linkage-",
  "disequilibrium theory assumes random mating, which a pedigreed colony",
  "violates. Prefer the Realized Relatedness Variance table above for",
  "pedigree-valid estimates."
)

## D9: any exported block/LD statistic table carries MORE identifying power
## than a single-locus statistic (issue #153 design doc sec 2.15), so it
## routes through the same curator-controlled gate issue #150 established --
## this module's own warning text for that gate, distinct from
## R/modDeidentifiedExport.R's whole-pedigree warning.
.linkageExportWarningText <- paste(
  "This export removes identifying ids from the idsUsed column (populated",
  "only when the founders-only restriction above is used) -- it does not",
  "verify or enforce who you may share it with. Confirming that your",
  "institution's data-sharing and authorization policies permit this",
  "export and its intended recipient(s) is your responsibility, not this",
  "tool's."
)

## D7: any sequence-derived export (raw genotype matrix AND derived summary
## tables) routes through the same curator-controlled gate issue #150
## established -- genotype/allele values themselves are never perturbed, so
## the confirm-gate/labeling pattern below is the only real protection
## (issue #152 design doc sec 3 D7).
.sequenceExportWarningText <- paste(
  "This export de-identifies ids in the genotype matrix and F_ROH table --",
  "genotype and allele values themselves are never altered, since there",
  "is no scientifically-valid way to obscure an allele call while",
  "preserving its validity. Confirming that your institution's",
  "data-sharing and authorization policies permit this export and its",
  "intended recipient(s) is your responsibility, not this tool's."
)

#' Build the sequence export's transformation manifest (issue #152 Slice 5)
#'
#' A "non-sensitive... auditable" record of how a de-identified sequence
#' export was produced: export timestamp, package version, the exact
#' \code{\link{computeGenomicROH}} parameters used, the exported row/locus
#' counts, and a copy of the confirm-gate warning text shown to the curator.
#' Deliberately never includes the id map or any raw pre-obfuscation value
#' -- mirrors \code{.buildDeidentificationManifest}'s shape
#' (\code{R/modDeidentifiedExport.R}), adapted to this export's own actual
#' parameters (no \code{size}/\code{maxDelta}/\code{linkedDateShift} apply
#' here).
#'
#' @param genotypeMatrix the exported (already de-identified) genotype
#' matrix -- only its dimensions are used.
#' @param rohTable the exported (already de-identified) F_ROH table -- only
#' its row count is used.
#' @param minSnp,minBp the \code{\link{computeGenomicROH}} parameters used
#' to produce \code{rohTable}.
#' @param warningText the D7 institutional-responsibility warning text shown
#' at the confirm gate.
#' @return A one-row data.frame with columns \code{timestamp},
#' \code{packageVersion}, \code{nIndividuals}, \code{nLoci}, \code{minSnp},
#' \code{minBp}, \code{warningText}.
#' @noRd
.buildSequenceExportManifest <- function(genotypeMatrix, rohTable, minSnp,
                                          minBp, warningText) {
  data.frame(
    timestamp = format(Sys.time()),
    packageVersion = getVersion(date = FALSE),
    nIndividuals = nrow(genotypeMatrix),
    nLoci = ncol(genotypeMatrix),
    minSnp = minSnp,
    minBp = minBp,
    warningText = warningText,
    stringsAsFactors = FALSE
  )
}

#' Marker Genetics Module - UI Function
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} containing the marker-genetics UI: a marker
#'   genotype file upload control, a guidance area, and the pedigree-vs-
#'   marker mean-kinship comparison table.
#'
#' @seealso \code{\link{modMarkerGeneticsServer}}
#' @importFrom shiny NS div h3 h4 fluidRow column wellPanel fileInput
#' @importFrom shiny uiOutput tabsetPanel tabPanel checkboxInput numericInput
#' @importFrom shiny actionButton downloadButton helpText
#' @importFrom DT DTOutput
#' @family Shiny modules
#' @export
modMarkerGeneticsUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "markerGenetics",

    h3("Marker Genetics"),
    fluidRow(
      column(4L,
             wellPanel(
               fileInput(ns("genotypeFile"),
                         "Select Marker Genotype File (CSV)",
                         accept = ".csv"),
               fileInput(ns("genotypeFileB"),
                         paste("Select Center B Marker Genotype File",
                               "(CSV, for Cross-Center comparison)"),
                         accept = ".csv"),
               fileInput(ns("linkageGenotypeFile"),
                         paste("Select Marker Genotype File (CSV,",
                               "multiallelic-tolerant, for Linkage and LD",
                               "Block Metrics)"),
                         accept = ".csv"),
               fileInput(ns("locusMetadataFile"),
                         paste("Select Locus Metadata File (CSV, for",
                               "Linkage and LD Block Metrics)"),
                         accept = ".csv")
             )
      ),
      column(8L,
             uiOutput(ns("guidance")),
             tabsetPanel(
               tabPanel("Kinship Comparison",
                        DT::DTOutput(ns("comparisonTable"))),
               tabPanel("Heterozygosity",
                        DT::DTOutput(ns("heterozygosityTable"))),
               tabPanel("Parentage Exclusion",
                        DT::DTOutput(ns("exclusionTable"))),
               tabPanel("Cross-Center",
                        DT::DTOutput(ns("crossCenterTable"))),
               tabPanel("Candidate Parent Assignment",
                        DT::DTOutput(ns("candidateAssignmentTable"))),
               tabPanel("Linkage and LD Block Metrics",
                        h4("Locus Metadata Coverage"),
                        uiOutput(ns("locusMetadataGuidance")),
                        DT::DTOutput(ns("locusMetadataTable")),
                        h4("Realized Relatedness Variance"),
                        fluidRow(
                          column(6L,
                                 numericInput(ns("nChr"),
                                              "Chromosome count:",
                                              value = 20L, min = 1L)),
                          column(6L,
                                 numericInput(
                                   ns("mapLength"),
                                   "Total autosomal map length (Morgans):",
                                   value = 28.0, min = 0.01
                                 ))
                        ),
                        helpText(paste(
                          "Defaults are for rhesus macaque (Macaca",
                          "mulatta); adjust for other species or datasets."
                        )),
                        DT::DTOutput(ns("realizedRelatednessTable")),
                        h4("LD Block Statistic"),
                        div(class = "alert alert-warning",
                            .linkageLdBlockCaveatText),
                        checkboxInput(
                          ns("ldBlockFoundersOnly"),
                          "Restrict to founders only (optional)",
                          value = FALSE
                        ),
                        DT::DTOutput(ns("ldBlockTable")),
                        actionButton(
                          ns("ldBlockExportPreview"),
                          "Generate De-Identified Export Preview"
                        ),
                        uiOutput(ns("ldBlockExportGuidance")),
                        actionButton(ns("ldBlockConfirmExport"),
                                     "Confirm Export"),
                        downloadButton(
                          ns("downloadLdBlockExport"),
                          "Download De-Identified LD Block Metrics"
                        )),
               tabPanel("Genomic ROH (F_ROH)",
                        helpText(paste(
                          "Reuses the genotype file and locus metadata file",
                          "uploaded above (issue #152) -- no separate upload",
                          "needed."
                        )),
                        fluidRow(
                          column(6L,
                                 numericInput(
                                   ns("rohMinSnp"),
                                   "Minimum SNP count per ROH segment:",
                                   value = 50L, min = 1L
                                 )),
                          column(6L,
                                 numericInput(
                                   ns("rohMinBp"),
                                   "Minimum ROH segment span (bp):",
                                   value = 1000000.0, min = 1.0
                                 ))
                        ),
                        DT::DTOutput(ns("sequenceRohTable")),
                        actionButton(
                          ns("sequenceExportPreview"),
                          "Generate De-Identified Export Preview"
                        ),
                        uiOutput(ns("sequenceExportGuidance")),
                        actionButton(ns("sequenceConfirmExport"),
                                     "Confirm Export"),
                        downloadButton(
                          ns("downloadSequenceGenotype"),
                          "Download De-Identified Genotype Matrix"
                        ),
                        downloadButton(
                          ns("downloadSequenceRoh"),
                          "Download De-Identified F_ROH Table"
                        ),
                        downloadButton(
                          ns("downloadSequenceManifest"),
                          "Download Export Manifest"
                        ))
             )
      )
    )
  )
}

#' Marker Genetics Module - Server Function
#'
#' Reads an uploaded long-format marker genotype file (D1 format: \code{id},
#' \code{locus}, \code{allele1}, \code{allele2}), validates and pivots it
#' (\code{\link{checkMarkerGenotypeFile}},
#' \code{\link{buildMarkerGenotypeMatrix}}),
#' estimates marker-based kinship independent of pedigree
#' (\code{\link{markerKinship}}), and surfaces a per-animal comparison of
#' pedigree-based mean kinship (\code{indivMeanKin}, already computed
#' upstream and passed in via \code{kinshipMatrix}) alongside the new
#' marker-based mean kinship (\code{markerMeanKin}) -- an independent check
#' on the pedigree-implied relatedness, not a replacement for it. A second
#' tab surfaces the heterozygosity diagnostic: per-animal observed
#' heterozygosity (\code{\link{markerObservedHeterozygosity}}) alongside
#' population-level expected heterozygosity
#' (\code{\link{markerExpectedHeterozygosity}}). A third tab surfaces the
#' Mendelian-exclusion parentage diagnostic
#' (\code{\link{markerParentageExclusion}}): the \code{pedigree}'s recorded
#' dam/sire cross-referenced against the uploaded genotypes, flagging any
#' recorded parent the genotype evidence contradicts. A fourth tab, "Cross-
#' Center", surfaces a between-population differentiation statistic
#' (\code{\link{markerFst}}) between the first uploaded file (implicitly
#' "Center A") and a second, independently uploaded Center B genotype file
#' -- a population-level, two-dataset comparison, unrelated to the
#' per-animal cross-center identity linking of
#' \code{\link{resolveCrossCenterIds}} (Slice 4). A fifth tab, "Candidate
#' Parent Assignment" (issue #147 Slice 2), surfaces
#' \code{\link{markerParentageLikelihood}}: for every (offspring, role) pair
#' the Parentage Exclusion tab's own diagnostic flags as Mendelian
#' -inconsistent, it ranks candidate replacement parents by a CERVUS-style
#' multilocus likelihood (LOD) score. This tab needs no new file input --
#' it reads the same uploaded genotype file and \code{pedigree} already
#' wired to the other tabs -- and is report-only, matching the Parentage
#' Exclusion tab's own precedent: it never writes to \code{pedigree}.
#'
#' A sixth tab, "Linkage and LD Block Metrics" (issue #153 Slice 5), wires in
#' three additional analyses. A locus-metadata file (\code{locus},
#' \code{chrom}, \code{pos}, optionally \code{cM}) is validated and
#' classified into a three-tier coverage report
#' (\code{\link{checkLocusMetadata}}, D2). The realized-relatedness-variance
#' table (\code{\link{markerRealizedRelatednessVariance}}, D3a) needs only
#' the existing \code{kinshipMatrix}/\code{pedigree} plus a curator-supplied
#' chromosome count and genetic-map length -- no genotype file at all. The
#' LD-block table (\code{\link{markerLdBlock}}, D3b) reads its OWN,
#' dedicated \code{linkageGenotypeFile} upload -- deliberately independent
#' of the other five tabs' shared \code{genotypeFile}, since Shiny renders
#' every \code{tabPanel}'s output bindings regardless of which tab is
#' visible: a multiallelic file uploaded through the shared input would
#' break the other five tabs' own DT outputs simultaneously, not just this
#' tab's (found empirically this session, correcting the original PRE-RED
#' plan). Validated through the multiallelic-tolerant sibling validator
#' (\code{\link{checkLinkageMarkerGenotypeFile}}) rather than
#' \code{\link{checkMarkerGenotypeFile}}. Any exported LD-block
#' table is de-identified (\code{\link{obfuscateLdBlocks}}) behind a
#' curator confirm-gate reusing \code{\link{modDeidentifiedExportServer}}'s
#' tested Generate-Preview -> Confirm -> Confirm-OK pattern (D9).
#'
#' This module never touches the existing single-locus genotype path
#' (\code{checkGenotypeFile}/\code{addGenotype}/\code{hasGenotype}/
#' \code{getGVGenotype}/\code{geneDrop}) -- the D1 long-format schema is a
#' new, sibling concern.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param kinshipMatrix reactive returning the full pedigree-based kinship
#'   matrix (row and column names are animal IDs), or \code{NULL} while
#'   upstream analysis has not yet been run.
#' @param pedigree reactive returning the current pedigree data frame
#'   (columns \code{id}, \code{sire}, \code{dam}), or \code{NULL} while
#'   upstream analysis has not yet been run.
#'
#' @return A list with fourteen reactive elements: \code{markerGenotype}, the
#'   raw uploaded genotype data frame (or \code{NULL} before upload);
#'   \code{markerKinshipMatrix}, the marker-based \code{id} x \code{id}
#'   kinship matrix (or \code{NULL}); \code{comparisonTable}, the per-animal
#'   \code{indivMeanKin}/\code{markerMeanKin} comparison data frame (or
#'   \code{NULL}); \code{heterozygosityTable}, the per-animal
#'   \code{ho}/\code{he} heterozygosity data frame (\code{he} is the
#'   population-wide mean expected heterozygosity, repeated per row) (or
#'   \code{NULL}); \code{exclusionTable}, the
#'   \code{\link{markerParentageExclusion}} flagged-pairs data frame (or
#'   \code{NULL} before a genotype file and a pedigree are both available);
#'   \code{crossCenterGenotypeB}, the raw uploaded Center B genotype data
#'   frame (or \code{NULL} before upload); \code{crossCenterTable}, the
#'   \code{\link{markerFst}} \code{locus}/\code{fst} data frame with a
#'   trailing \code{"Pooled"} row (or \code{NULL} before both center files
#'   are uploaded); \code{candidateAssignmentTable}, the
#'   \code{\link{markerParentageLikelihood}} ranked-candidate data frame (a
#'   zero-row, full-column-shape data frame when no pair is flagged; or
#'   \code{NULL} before a genotype file and a pedigree are both available);
#'   \code{isReady}, \code{TRUE} once \code{comparisonTable} has a value;
#'   \code{locusMetadataTable}, the \code{\link{checkLocusMetadata}} output
#'   (or \code{NULL} before a locus-metadata file is uploaded);
#'   \code{realizedRelatednessTable}, the
#'   \code{\link{markerRealizedRelatednessVariance}} output (or \code{NULL}
#'   before \code{pedigree}/\code{kinshipMatrix} are both available);
#'   \code{ldBlockTable}, the \code{\link{markerLdBlock}} output (or
#'   \code{NULL} before a genotype file and a locus-metadata file are both
#'   uploaded, or before a pedigree is available if the founders-only
#'   restriction is checked); \code{ldBlockExportTable}, the
#'   \code{\link{obfuscateLdBlocks}}-de-identified export preview (or
#'   \code{NULL} before "Generate De-Identified Export Preview" is clicked
#'   with both \code{ldBlockTable} and \code{pedigree} available); and
#'   \code{ldBlockExportConfirmed}, \code{FALSE} until the confirm-gate
#'   modal's own Confirm button is clicked for the current export preview.
#'
#' @seealso \code{\link{modMarkerGeneticsUI}}
#' @importFrom shiny moduleServer reactive renderUI observe req div
#' @importFrom shiny reactiveVal observeEvent showModal removeModal
#' @importFrom shiny modalDialog modalButton tagList p downloadHandler
#' @importFrom DT renderDT
#' @importFrom utils write.csv
#' @family Shiny modules
#' @export
modMarkerGeneticsServer <- function(id, kinshipMatrix, pedigree) {
  moduleServer(id, function(input, output, session) {

    ## Upstream absence (pedigree kinship not yet computed) is treated as
    ## not-ready (NULL), per module-contract rule 5 -- but a malformed
    ## uploaded genotype file is NOT caught here: checkMarkerGenotypeFile()/
    ## buildMarkerGenotypeMatrix()/markerKinship() are called with no
    ## surrounding tryCatch, so a real validation error surfaces as a
    ## genuine Shiny reactive error, not a silent NULL.
    safeRead <- function(r) tryCatch(r(), error = function(e) NULL)

    rawGenotype <- reactive({
      if (is.null(input$genotypeFile)) {
        return(NULL)
      }
      getGenotypes(input$genotypeFile$datapath, sep = ",")
    })

    genotypeMatrixR <- reactive({
      raw <- rawGenotype()
      if (is.null(raw)) {
        return(NULL)
      }
      ## checkSequenceGenotypeFile() is a confirmed strict superset of
      ## checkMarkerGenotypeFile()'s rule set (issue #152 Slice 5, Pre-RED
      ## Q1): same biallelic-only checks, plus a literal-"." rejection and a
      ## maxLoci soft-warning. This makes the existing genotypeFile input
      ## (and its Kinship Comparison/Heterozygosity tabs) genome-scale
      ## -capable with no new upload control or duplicate tab.
      checked <- checkSequenceGenotypeFile(raw)
      buildMarkerGenotypeMatrix(checked)
    })

    markerKmat <- reactive({
      gmat <- genotypeMatrixR()
      if (is.null(gmat)) {
        return(NULL)
      }
      markerKinship(gmat)
    })

    comparison <- reactive({
      mkmat <- markerKmat()
      if (is.null(mkmat)) {
        return(NULL)
      }
      markerMean <- meanKinship(mkmat)
      ids <- names(markerMean)

      pedKmat <- safeRead(kinshipMatrix)
      pedMean <- if (is.null(pedKmat)) {
        rep(NA_real_, length(ids))
      } else {
        as.numeric(meanKinship(pedKmat)[ids])
      }

      data.frame(
        id = ids,
        indivMeanKin = pedMean,
        markerMeanKin = as.numeric(markerMean),
        stringsAsFactors = FALSE,
        row.names = NULL
      )
    })

    heterozygosity <- reactive({
      gmat <- genotypeMatrixR()
      if (is.null(gmat)) {
        return(NULL)
      }
      ho <- markerObservedHeterozygosity(gmat)
      he <- markerExpectedHeterozygosity(gmat)

      data.frame(
        id = names(ho),
        ho = as.numeric(ho),
        he = he$meanHe,
        stringsAsFactors = FALSE,
        row.names = NULL
      )
    })

    exclusion <- reactive({
      gmat <- genotypeMatrixR()
      if (is.null(gmat)) {
        return(NULL)
      }
      ped <- safeRead(pedigree)
      if (is.null(ped)) {
        return(NULL)
      }
      markerParentageExclusion(gmat, ped)
    })

    rawGenotypeB <- reactive({
      if (is.null(input$genotypeFileB)) {
        return(NULL)
      }
      getGenotypes(input$genotypeFileB$datapath, sep = ",")
    })

    genotypeMatrixBR <- reactive({
      raw <- rawGenotypeB()
      if (is.null(raw)) {
        return(NULL)
      }
      ## Same checkSequenceGenotypeFile() superset swap as genotypeMatrixR()
      ## above (issue #152 Slice 5, Pre-RED Q1) -- keeps the Cross-Center
      ## tab's two inputs consistent with each other.
      checked <- checkSequenceGenotypeFile(raw)
      buildMarkerGenotypeMatrix(checked)
    })

    crossCenter <- reactive({
      gmatA <- genotypeMatrixR()
      gmatB <- genotypeMatrixBR()
      if (is.null(gmatA) || is.null(gmatB)) {
        return(NULL)
      }
      fst <- markerFst(gmatA, gmatB)

      data.frame(
        locus = c(names(fst$perLocus), "Pooled"),
        fst = c(as.numeric(fst$perLocus), fst$pooledFst),
        stringsAsFactors = FALSE
      )
    })

    candidateAssignment <- reactive({
      gmat <- genotypeMatrixR()
      if (is.null(gmat)) {
        return(NULL)
      }
      ped <- safeRead(pedigree)
      if (is.null(ped)) {
        return(NULL)
      }
      markerParentageLikelihood(gmat, ped)
    })

    ## --- Issue #153 Slice 5: Linkage and LD Block Metrics ------------------

    ## A DEDICATED upload, independent of rawGenotype()/genotypeFile above --
    ## NOT reused, unlike the original PRE-RED plan. Shiny renders every
    ## tabPanel's output bindings regardless of which tab is visible, so a
    ## multiallelic file fed through the SHARED input would break the other
    ## 5 tabs' own DT outputs simultaneously (found empirically this
    ## session: checkMarkerGenotypeFile() throwing on a multiallelic upload
    ## propagated through comparisonTable/heterozygosityTable/etc.'s own
    ## renderDT() calls). checkMarkerGenotypeFile()/genotypeMatrixR() above
    ## are otherwise completely untouched (D4/D6).
    rawLinkageGenotype <- reactive({
      if (is.null(input$linkageGenotypeFile)) {
        return(NULL)
      }
      getGenotypes(input$linkageGenotypeFile$datapath, sep = ",")
    })

    linkageGenotypeMatrixR <- reactive({
      raw <- rawLinkageGenotype()
      if (is.null(raw)) {
        return(NULL)
      }
      checked <- checkLinkageMarkerGenotypeFile(raw)
      buildMarkerGenotypeMatrix(checked)
    })

    locusMetadata <- reactive({
      if (is.null(input$locusMetadataFile)) {
        return(NULL)
      }
      raw <- getGenotypes(input$locusMetadataFile$datapath, sep = ",")
      checkLocusMetadata(raw)
    })

    ## No genotype file is needed here -- markerRealizedRelatednessVariance()
    ## (D3a) is pedigree-only (kinshipMatrix/pedigree, already module
    ## parameters) plus the curator-supplied nChr/mapLength below. Falls
    ## back to the rhesus-macaque default (20 chromosomes, 28 Morgans,
    ## matching markerRealizedRelatednessVariance()'s own roxygen example)
    ## when the UI's own numericInput default hasn't reached input$... yet
    ## (e.g. under shiny::testServer(), which does not auto-apply UI
    ## defaults) -- mirrors modDeidentifiedExportServer's own
    ## input-fallback-default pattern.
    realizedRelatedness <- reactive({
      ped <- safeRead(pedigree)
      kmat <- safeRead(kinshipMatrix)
      if (is.null(ped) || is.null(kmat)) {
        return(NULL)
      }
      nChr <- if (!is.null(input$nChr)) input$nChr else 20L
      mapLength <- if (!is.null(input$mapLength)) input$mapLength else 28.0
      if (is.na(nChr) || is.na(mapLength) || nChr <= 0L || mapLength <= 0L) {
        return(NULL)
      }
      markerRealizedRelatednessVariance(kmat, ped, nChr = nChr,
                                         mapLength = mapLength)
    })

    ldBlock <- reactive({
      gmat <- linkageGenotypeMatrixR()
      lmeta <- locusMetadata()
      if (is.null(gmat) || is.null(lmeta)) {
        return(NULL)
      }
      founderIds <- NULL
      if (isTRUE(input$ldBlockFoundersOnly)) {
        ped <- safeRead(pedigree)
        if (is.null(ped)) {
          ## Can't restrict to founders without a pedigree -- not-ready,
          ## not an error (module-contract rule 5: upstream absence).
          return(NULL)
        }
        founderIds <- getFounders(ped)
      }
      markerLdBlock(gmat, lmeta, founderIds = founderIds)
    })

    ## D9: any exported LD-block table routes through a curator confirm-gate
    ## reusing modDeidentifiedExportServer's tested Generate-Preview ->
    ## Confirm -> Confirm-OK pattern. ldBlockExportRaw snapshots the
    ## de-identified table at "Generate Preview" click time (not re-read
    ## from live reactives later), so a stale confirmation can never
    ## silently cover different content.
    ldBlockExportRaw <- reactiveVal(NULL)
    ldBlockConfirmed <- reactiveVal(FALSE)

    observeEvent(input$ldBlockExportPreview, {
      req(ldBlock())
      req(pedigree())
      ldBlockConfirmed(FALSE)
      map <- obfuscatePed(pedigree(), map = TRUE)$map
      ldBlockExportRaw(obfuscateLdBlocks(ldBlock(), map))
    })

    observeEvent(input$ldBlockConfirmExport, {
      req(ldBlockExportRaw())
      showModal(modalDialog(
        title = "Confirm De-Identified LD Block Metrics Export",
        p(.linkageExportWarningText),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(session$ns("ldBlockConfirmExportOk"), "Confirm Export",
                       class = "btn-success")
        )
      ))
    })

    observeEvent(input$ldBlockConfirmExportOk, {
      req(ldBlockExportRaw())
      ldBlockConfirmed(TRUE)
      removeModal()
    })

    ## --- Issue #152 Slice 5: Genomic ROH (F_ROH) ---------------------------

    ## Pre-RED Q1/Q2 ratification: NOT a dedicated upload -- reuses
    ## genotypeMatrixR() (now checkSequenceGenotypeFile()-validated, above)
    ## and locusMetadata() (the SAME reactive issue #153's own tab already
    ## populates from the shared locusMetadataFile input). Falls back to
    ## computeGenomicROH()'s own defaults (minSnp=50L, minBp=1e6) when the
    ## UI's numericInput default hasn't reached input$... yet, mirroring
    ## realizedRelatedness()'s own input-fallback-default pattern above.
    sequenceRohTable <- reactive({
      gmat <- genotypeMatrixR()
      lmeta <- locusMetadata()
      if (is.null(gmat) || is.null(lmeta)) {
        return(NULL)
      }
      minSnp <- if (!is.null(input$rohMinSnp)) input$rohMinSnp else 50L
      minBp <- if (!is.null(input$rohMinBp)) input$rohMinBp else 1000000.0
      if (is.na(minSnp) || is.na(minBp) || minSnp <= 0L || minBp <= 0L) {
        return(NULL)
      }
      ## locusMetadata() is checkLocusMetadata()'s OWN output (issue #153),
      ## which appends a `coverage` column -- 4 or 5 columns, never the raw
      ## 3/4 computeGenomicROH() expects (it re-runs checkLocusMetadata()
      ## internally and re-derives coverage itself). Strip it back to the
      ## raw shape before passing on -- found via this slice's own Phase 3E
      ## live verification (a real 4-column, with-cM fixture makes the
      ## double-check see 5 columns and throw; a 3-column, no-cM fixture
      ## silently mislabels `coverage` as `cM` instead, no error but wrong).
      lmeta <- lmeta[, setdiff(names(lmeta), "coverage"), drop = FALSE]
      computeGenomicROH(gmat, lmeta, minSnp = minSnp, minBp = minBp)
    })

    ## D7: any sequence-derived export routes through the same curator
    ## confirm-gate pattern as the LD-block export above -- 3 artifacts
    ## (de-identified genotype matrix, de-identified F_ROH table, manifest)
    ## snapshotted together at "Generate Preview" click time, per this
    ## slice's own Pre-RED Q3 ratification.
    sequenceExportRaw <- reactiveVal(NULL)
    sequenceExportConfirmed <- reactiveVal(FALSE)

    observeEvent(input$sequenceExportPreview, {
      req(genotypeMatrixR())
      req(sequenceRohTable())
      req(pedigree())
      sequenceExportConfirmed(FALSE)
      map <- obfuscatePed(pedigree(), map = TRUE)$map
      deidGenotype <- obfuscateGenotypeMatrix(genotypeMatrixR(), map)
      deidRoh <- obfuscateGenomicROH(sequenceRohTable(), map)
      minSnp <- if (!is.null(input$rohMinSnp)) input$rohMinSnp else 50L
      minBp <- if (!is.null(input$rohMinBp)) input$rohMinBp else 1000000.0
      manifest <- .buildSequenceExportManifest(
        deidGenotype, deidRoh, minSnp = minSnp, minBp = minBp,
        warningText = .sequenceExportWarningText
      )
      sequenceExportRaw(list(genotypeMatrix = deidGenotype, rohTable = deidRoh,
                              manifest = manifest))
    })

    observeEvent(input$sequenceConfirmExport, {
      req(sequenceExportRaw())
      showModal(modalDialog(
        title = "Confirm De-Identified Sequence Export",
        p(.sequenceExportWarningText),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(session$ns("sequenceConfirmExportOk"), "Confirm Export",
                       class = "btn-success")
        )
      ))
    })

    observeEvent(input$sequenceConfirmExportOk, {
      req(sequenceExportRaw())
      sequenceExportConfirmed(TRUE)
      removeModal()
    })

    output$comparisonTable <- DT::renderDT({
      tbl <- comparison()
      req(tbl)
      tbl
    })

    output$heterozygosityTable <- DT::renderDT({
      tbl <- heterozygosity()
      req(tbl)
      tbl
    })

    output$exclusionTable <- DT::renderDT({
      tbl <- exclusion()
      req(tbl)
      tbl
    })

    output$crossCenterTable <- DT::renderDT({
      tbl <- crossCenter()
      req(tbl)
      tbl
    })

    output$candidateAssignmentTable <- DT::renderDT({
      tbl <- candidateAssignment()
      req(tbl)
      tbl
    })

    output$locusMetadataGuidance <- renderUI({
      lmeta <- locusMetadata()
      if (is.null(lmeta)) {
        div(class = "alert alert-info",
            "Upload a locus-metadata file to see per-locus coverage.")
      } else {
        counts <- table(factor(lmeta$coverage,
                                levels = c("full", "partial", "none")))
        div(class = "alert alert-secondary",
            paste0(counts[["full"]], " full, ", counts[["partial"]],
                   " partial, ", counts[["none"]], " none."))
      }
    })

    output$locusMetadataTable <- DT::renderDT({
      tbl <- locusMetadata()
      req(tbl)
      tbl
    })

    output$realizedRelatednessTable <- DT::renderDT({
      tbl <- realizedRelatedness()
      req(tbl)
      tbl
    })

    output$ldBlockTable <- DT::renderDT({
      tbl <- ldBlock()
      req(tbl)
      tbl
    })

    output$ldBlockExportGuidance <- renderUI({
      if (is.null(safeRead(pedigree))) {
        div(class = "alert alert-warning",
            "Load a pedigree before generating a de-identified LD block",
            "metrics export.")
      } else if (!ldBlockConfirmed()) {
        div(class = "alert alert-info",
            "Generate a preview, then confirm the export to unlock the",
            "download.")
      }
    })

    output$downloadLdBlockExport <- downloadHandler(
      filename = function() {
        paste0("ld_block_metrics_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(ldBlockExportRaw(), file, row.names = FALSE)
      }
    )

    output$sequenceRohTable <- DT::renderDT({
      tbl <- sequenceRohTable()
      req(tbl)
      tbl
    })

    output$sequenceExportGuidance <- renderUI({
      if (is.null(safeRead(pedigree))) {
        div(class = "alert alert-warning",
            "Load a pedigree before generating a de-identified sequence",
            "export.")
      } else if (!sequenceExportConfirmed()) {
        div(class = "alert alert-info",
            "Generate a preview, then confirm the export to unlock the",
            "downloads.")
      }
    })

    output$downloadSequenceGenotype <- downloadHandler(
      filename = function() {
        paste0("sequence_genotype_matrix_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(sequenceExportRaw()$genotypeMatrix, file)
      }
    )

    output$downloadSequenceRoh <- downloadHandler(
      filename = function() {
        paste0("sequence_f_roh_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(sequenceExportRaw()$rohTable, file, row.names = FALSE)
      }
    )

    output$downloadSequenceManifest <- downloadHandler(
      filename = function() {
        paste0("sequence_export_manifest_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(sequenceExportRaw()$manifest, file, row.names = FALSE)
      }
    )

    output$guidance <- renderUI({
      if (is.null(comparison())) {
        div(
          class = "alert alert-info",
          paste(
            "Upload a marker genotype file to see the pedigree-vs-marker",
            "kinship comparison."
          )
        )
      }
    })

    # Signal data-ready when the comparison table is available (for E2E
    # testing).
    observe({
      req(comparison())
      session$sendCustomMessage("setDataReady", list(
        selector = paste0("#", session$ns("moduleContainer")),
        ready = TRUE
      ))
    })

    list(
      markerGenotype = reactive(rawGenotype()),
      markerKinshipMatrix = reactive(markerKmat()),
      comparisonTable = reactive(comparison()),
      heterozygosityTable = reactive(heterozygosity()),
      exclusionTable = reactive(exclusion()),
      crossCenterGenotypeB = reactive(rawGenotypeB()),
      crossCenterTable = reactive(crossCenter()),
      candidateAssignmentTable = reactive(candidateAssignment()),
      isReady = reactive(!is.null(comparison())),
      locusMetadataTable = reactive(locusMetadata()),
      realizedRelatednessTable = reactive(realizedRelatedness()),
      ldBlockTable = reactive(ldBlock()),
      ldBlockExportTable = reactive(ldBlockExportRaw()),
      ldBlockExportConfirmed = reactive(ldBlockConfirmed()),
      sequenceRohTable = reactive(sequenceRohTable()),
      sequenceExportGenotypeMatrix = reactive({
        raw <- sequenceExportRaw()
        if (is.null(raw)) NULL else raw$genotypeMatrix
      }),
      sequenceExportRohTable = reactive({
        raw <- sequenceExportRaw()
        if (is.null(raw)) NULL else raw$rohTable
      }),
      sequenceExportManifest = reactive({
        raw <- sequenceExportRaw()
        if (is.null(raw)) NULL else raw$manifest
      }),
      sequenceExportConfirmed = reactive(sequenceExportConfirmed())
    )
  })
}
