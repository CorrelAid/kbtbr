# functions to write
# url builder (take base url, asset type and identifier and output format?)
# if we write the functions outside the classes and set them later in the class
# code readability is higher imo

#' @description
#' Converts R list into JSON-like string.
#'
#' @keywords internal
#'
#' @param list R list to be converted.

list_as_json_char <- function(list) {
  jsonlite::toJSON(x = list, pretty = TRUE, auto_unbox = TRUE) %>%
    as.character()
}
