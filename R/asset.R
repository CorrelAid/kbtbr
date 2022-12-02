#' Asset
#' Class to hold an asset
Asset <- R6::R6Class("Asset",
  public = list(

    # Public Methods ===========================================================

    #' @description
    #' Constructs a new instance of class [Asset].
    #' @param asset_list list. a list with the asset data, such as obtained through a call to assets/{id}
    #' @param kobo Kobo instance. Instance of class Kobo used internally to make requests to the API.
    initialize = function(asset_list, kobo) {
      # check that everything exists in list that we need
      needed_names <- c("uid", "name", "url", "data", "owner__username", "asset_type")
      if (!test_subset(needed_names, names(asset_list))) {
        missing_elements <- setdiff(needed_names, names(asset_list))
        ui_stop(
          sprintf("Argument asset_list is missing the following required elements: %s", toString(missing_elements))
        )
      }

      private$.uid <- asset_list$uid
      private$.name <- assert_string(asset_list$name)
      private$.asset_url <- assert_string(asset_list$url)
      private$.data_url <- asset_list$data
      private$.owner_username <- assert_string(asset_list$owner__username)
      private$.type <- assert_string(asset_list$asset_type)

      # kobo instance
      private$.kobo <- assert_class(kobo, c("R6", "Kobo"))
    },

    #' get_submissions
    #' @description get submissions to a survey/form
    #' @return tibble. submissions as a tibble. if no submissions were made yet, the tibble will have no columns.
    get_submissions = function() {
      if (private$.type != "survey") {
        ui_stop("Only valid for assets of type 'survey'. Current asset is of type '{private$.type}'.")
      }
      path <- sprintf("assets/%s/data/", private$.uid)
      private$.kobo$get(path)$results %>%
        tibble::as_tibble()
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
  ),
  private = list(

    # Private Fields ===========================================================

    # Storage fields for Active Bindings ---------------------------------------

    .uid = NA,
    .name = NA,
    .asset_url = NA,
    .data_url = NA,
    .owner_username = NA,
    .type = NA,
    .kobo = NULL
  ),
  active = list(

    # Active Bindings ==========================================================

    #' @field uid
    #' uid of the asset.
    uid = function(value) {
      read_only_active(private, "uid", value)
    },
    #' @field name
    #' name of the asset.
    name = function(value) {
      read_only_active(private, "name", value)
    },
    #' @field asset_url
    #' asset_url of the asset. takes the form of assets/{uid}/
    #' Contains most of the information about an asset such as meta data, permissions, xls form content and
    #' links to other related endpoints.
    asset_url = function(value) {
      read_only_active(private, "asset_url", value)
    },
    #' @field data_url
    #' data_url of the asset. This can be used to get data related to the asset.
    #' Most useful for the asset type `survey` where this URL
    #' gives access to the submissions to the survey.
    data_url = function(value) {
      read_only_active(private, "data_url", value)
    },
    #' @field owner_username
    #' username of the owner of the asset.
    owner_username = function(value) {
      read_only_active(private, "owner_username", value)
    },
    #' @field type
    #' type of the asset. Type of the asset, e.g. survey, question, block or template.
    type = function(value) {
      read_only_active(private, "type", value)
    }
  )
)
