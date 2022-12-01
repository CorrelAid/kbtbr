# functions to write
# url builder (take base url, asset type and identifier and output format?)
# if we write the functions outside the classes and set them later in the class
# code readability is higher imo

#' @title Repair URL by appending trailing slash
#' @param path The path, for example appended to the base URL.
#' @return The path string with optionally an appended trailing slash.
#' @noRd
append_slash <- function(path) {
  if (substr(path, nchar(path), nchar(path)) != "/") {
    return(paste0(path, "/"))
  } else {
    return(path)
  }
}

#' Helper function to convert R list to JSON-like string
#'
#' @description
#' Converts R lists to JSON-like strings for POST request's body.
#'
#' #' @keywords internal
#'
#' @param list R list that should be converted to the JSON-like string
#'
#' @examples
#' \dontrun{
#' example_body <- list_as_json_char(list(
#'   "name" = "A survey object created via API/R",
#'   "asset_type" = "survey"
#' ))
#' }
#'
list_as_json_char <- function(list) {
  as.character(toJSON(x = list, pretty = TRUE, auto_unbox = TRUE))
}


#' @title Access Read-Only Active Bindings
#'
#' @description
#' Template function to create a read-only active binding.
#' @param private Pointer to the private env of an object
#' @param field character(1) the name of the active binding field. It is assumed
#' that a private field prefixed with a single dot exists, that serves as
#' storage.
#' @param val The value passed to the active binding. If it is not missing,
#' the function will stop.
#' @return The value of the active binding-related storage field.
read_only_active <- function(private, field, val) {
  assert_string(field)
  if (!missing(val)) {
    stop(sprintf("Field '%s' is read-only.", field))
  } else {
    return(private[[paste0(".", field)]])
  }
}
