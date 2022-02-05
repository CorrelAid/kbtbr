#' Asset
#' Class to hold an asset
Asset <- R6::R6Class("Asset",
  active = list(
    #' @field uid
    #' uid of the asset.
    uid = function(value) {
      if (missing(value)) {
        return(private$.uid)
      } else {
        usethis::ui_stop("Read-only.")
      }
    },
    #' @field name
    #' name of the asset.
    name = function(value) {
      if (missing(value)) {
        return(private$.name)
      } else {
        usethis::ui_stop("Read-only.")
      }
    },
    #' @field asset_url
    #' asset_url of the asset. takes the form of assets/{uid}/
    #' Contains most of the information about an asset such as meta data, permissions, xls form content and
    #' links to other related endpoints.
    asset_url = function(value) {
      if (missing(value)) {
        return(private$.asset_url)
      } else {
        usethis::ui_stop("Read-only.")
      }
    },
    #' @field data_url
    #' data_url of the asset. This can be used to get data related to the asset.
    #' Most useful for the asset type `survey` where this URL
    #' gives access to the submissions to the survey.
    data_url = function(value) {
      if (missing(value)) {
        return(private$.data_url)
      } else {
        usethis::ui_stop("Read-only.")
      }
    },
    #' @field owner_username
    #' username of the owner of the asset.
    owner_username = function(value) {
      if (missing(value)) {
        return(private$.owner_username)
      } else {
        usethis::ui_stop("Read-only.")
      }
    },
    #' @field type
    #' type of the asset. Type of the asset, e.g. survey, question, block or template.
    type = function(value) {
      if (missing(value)) {
        return(private$.type)
      } else {
        usethis::ui_stop("Read-only.")
      }
    }
  ),
  private = list(
    .uid = NA,
    .name = NA,
    .asset_url = NA,
    .data_url = NA,
    .owner_username = NA,
    .type = NA,
    .kobo = NULL
  ),
  #' @param asset_list list. a list with the asset data, such as obtained through a call to assets/{id}
  #' @param kobo Kobo instance. Instance of class Kobo used internally to make requests to the API.
  public = list(
    initialize = function(asset_list, kobo) {
      # check that everything exists in list that we need
      needed_names <- c("uid", "name", "url", "data", "owner__username", "asset_type")
      if (!checkmate::test_subset(needed_names, names(asset_list))) {
        missing_elements <- setdiff(needed_names, names(asset_list)) %>% paste(collapse = ", ")
        usethis::ui_stop(glue::glue("Argument asset_list is missing the following required elements: {missing_elements}"))
      }

      private$.uid <- asset_list$uid
      private$.name <- asset_list$name
      private$.asset_url <- asset_list$url
      private$.data_url <- asset_list$data
      private$.owner_username <- asset_list$owner__username
      private$.type <- asset_list$asset_type

      # kobo instance
      checkmate::assert_class(kobo, c("R6", "Kobo"))
      private$.kobo <- kobo
    },
    #' to_list
    #' @return list representation of asset
    to_list = function() {
      list(
        uid = private$.uid,
        name = private$.name,
        asset_url = private$.asset_url,
        data_url = private$.data_url,
        owner_username = private$.owner_username,
        type = private$.type
      )
    }
  )
)
