## pack <- available.packages() # use only a beginning of session to limit
## API use.

imports <- c(
  "anytime",
  "data.table",
  "futile.logger",
  "htmlTable",
  "lubridate",
  "Matrix",
  "plotrix",
  "readxl",
  "Rlabkey",
  "shiny",
  "stringi",
  "utils",
  "WriteXLS"
)
#pack["ggplot2","Depends"]
test <- pack[imports %in% dimnames(pack)[[1L]], "Imports"]
get_simple_dependencies <- function(name, types) {
  dependencies <- pack[name, types]
  dependencies <- stringi::stri_split_fixed(dependencies, pattern = ",")[[1L]]
  dependencies <- stringi::stri_trim_both(dependencies)
  dependencies <- stringi::stri_split_fixed(dependencies, pattern = " ",
                                            simplify = TRUE)
  dependencies <- stringi::stri_split_fixed(dependencies, pattern = "\\",
                                            simplify = TRUE)[, 1L]
  #dependencies <- stringi::stri_split_fixed(dependencies,
  #                                 pattern = " ",
  #                                 n = 1, omit_empty = TRUE,
  #                                 simplify = TRUE)
  dependencies[!dependencies == "utils"]
}
imports <- imports[!imports == "utils"]
new_imports <- imports
repeat {
  imports_len <- length(new_imports)
  for (i in seq_along(imports)) {
    new_imports <- unique(c(
      new_imports,
      get_simple_dependencies(imports[i], "Imports")
    ))
    if (any("gtools" %in% new_imports)) {
      cat(paste0("package ", imports[i], " imports gtools\n"))
    }
  }
  cat(paste0(
    "imports_len == ",
    imports_len,
    "; length(new_imports) == ",
    length(new_imports),
    "\\n"
  ))
  if (length(new_imports) <= imports_len)
    break
}
