# functions to write
# url builder (take base url, asset type and identifier and output format?)
# if we write the functions outside the classes and set them later in the class
# code readability is higher imo

#' @title Infix Coalesce Operator
#' @describtion Makes coalesce chainable, as often used in
#' tidyverse packages.
#' @noRd 
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
