#' Asset
#' Class to hold an asset
Asset <- R6::R6Class("Asset",
                     private = list(
                       uid = NA,
                       name = NA,
                       owner_username = NA,
                       type = NA,
                       url = NA,
                       data = NA
                     ),
                     #' @param asset_row list. a list, e.g. one row from the tibble/data frame that was returned by get_assets
                     public = list(
                       initialize = function(asset_row) {
                         private$uid = asset_row$uid
                         private$name = asset_row$name
                         private$owner_username = asset_row$owner__username
                         private$type = asset_row$asset_type
                         private$url = asset_row$url
                         private$data = asset_row$data
                       },
                       #' to_list
                       #' return list representation of asset
                       to_list = function() {
                         list(
                           uid = private$uid,
                           name = private$name,
                           owner_username = private$owner_username,
                           type = private$type,
                           url = private$url,
                           data = private$data
                         )
                       }
                     ))
