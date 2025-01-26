#' Make genetic diversity dashboard
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' @param geneticDiversityStats named vector of genetic diversity statistics
#' @param file filename to store image in. Defaults to
#'  \emph{images/geneticDiversity.png}
#' @importFrom gplots heatmap.2
#' @import RColorBrewer
#' @importFrom grDevices colorRampPalette dev.off png
#' @noRd
##makeGeneticDiversityDashboard <- function(geneticDiversityStats,
##                                      file = "images/geneticDiversity.png") {
##  my_palette <- colorRampPalette(c("red", "yellow", "green"))(n = 3)
##  rnames <- geneticDiversityStats[,1]  # assign labels in column 1 to "rnames"
##  headings <- c("Breeding Group", "Value", "Origin", "Production",
##                "Inbreeding", "Flags")
##
##  # (optional) defines the color breaks manually for a "skewed" color
##  # transition
##  col_breaks = c(0,1,  # for red
##                 2,  # for yellow
##                 3)#,  # for green
##                 #4)
##
##  mat_data <-
##    data.matrix(geneticDiversityStats[ , 2:ncol(geneticDiversityStats)])
##  rownames(mat_data) <- rnames
##  grDevices::png(file,    # create PNG for the heat map
##      width = 5*300,        # 5 x 300 pixels
##      height = 5*300,
##      res = 300,            # 300 pixels per inch
##      pointsize = 8)        # smaller font size
##  heatmap.2(mat_data,
##            #cellnote = mat_data,  # same data set for cell labels
##            main = "Genetic Diversity", # dashboard title
##            notecol="black",      # change font color of cell labels to black
##            density.info="none",  # turns off density plot inside color legend
##            trace="none",         # turns off trace lines inside the heat map
##            margins =c(15,9),     # widens margins around plot
##            col=my_palette,       # use on color palette defined earlier
##            breaks=col_breaks,    # enable color transition at specified
##                                  # limits
##            dendrogram="none",    # only draw a row dendrogram
##            key = FALSE,
##            labCol = headings[-1],
##            colsep = 1:ncol(mat_data),
##            rowsep = 1:nrow(mat_data),
##            sepcolor = "white",
##            sepwidth = c(0.01, 0.05),
##            Rowv = "NA",
##            Colv="NA")
##  grDevices::dev.off()               # close the PNG device
##
##}
##
