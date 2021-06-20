#' Asset
#' Class to hold an asset
Asset <- R6::R6Class("Asset",
                     private = list(
                       uid = NA,
                       name = NA,
                       asset_url = NA,
                       data_url = NA,
                       owner_username = NA,
                       type = NA,
                       kobo = NULL
                     ),
                     #' @param asset_list list. a list with the asset data, such as obtained through a call to assets/{id}
                     #' @param kobo Kobo instance. Instance of class Kobo used internally to make requests to the API.
                     public = list(
                       initialize = function(asset_list, kobo) {
                         private$uid = asset_list$uid
                         private$name = asset_list$name
                         private$asset_url = asset_list$url
                         private$data_url = asset_list$data
                         private$owner_username = asset_list$owner__username
                         private$type = asset_list$asset_type
                         private$kobo = kobo
                       },
                       #' to_list
                       #' @return list representation of asset
                       to_list = function() {
                         list(
                           uid = private$uid,
                           name = private$name,
                           asset_url = private$asset_url,
                           data_url = private$data_url,
                           owner_username = private$owner_username,
                           type = private$type
                         )
                       }
                     ))
