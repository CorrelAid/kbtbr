#' @title KoboPaginator
#' @description
#' A class that implements link-header style pagination, as is used in
#' the Kobotoolbox API.
KoboPaginator <- R6::R6Class(
    private = list(
        client = NULL
    ),
    public = list(
        #' @description
        #' @param client KoboClient. An instance of a KoboClient that can
        #'  be used for the paginated requestes.
        initialize = function(client) {
            stopifnot("KoboClient" %in% class(client))

            private$client <- client
        },
        #' @description
        #' @param path
        #' @inheritParams 
        get = function(path, query, ...) {}
    )
)
