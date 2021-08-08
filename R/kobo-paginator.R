#' @title KoboPaginator
#' @description
#' A class that implements link-header style pagination, as is used in
#' the Kobotoolbox API.
#' @export
KoboPaginator <- R6::R6Class(
    public = list(
        client = NULL,
        #' @description
        #' @param client KoboClient. An instance of a KoboClient that can
        #'  be used for the paginated requestes.
        initialize = function(client) {
            stopifnot("KoboClient" %in% class(client))

            private$client <- client
        },
        #' @description
        #' @param path
        get = function(path, query, ...) {
            private$page(method = "get")
        },
        #' @description
        #' Set the initial response
        #' @details
        #' Usually, the page method would revoke a first response in the
        #' normal way, using its `next` element to walk over all subsequent
        #' pages. In some settings, the user might provide this initial response
        #' object already.
        set_first_response = function(response) {
            checkmate::assert_list(response)
            private$resps <- response
        },
        get_responses = function() {
            return(private$resps)
        }
    ),
    private = list(
        resps = NULL,
        page = function(path, query, sleep = 0, ...) {
            checkmate::assert_choice(method, "get")
            tmp <- list()
            
            # Retrieve initial response
            tmp[[1]] <- private$resps %||%
                self$client$get(path, query)
            cnt <- 1
            next_link <- tmp[[cnt]][["next"]]

            while (!is.null(next_link)) {
                tmp_path <- private$resolve_next(next_link)
                cnt <- cnt + 1
                tmp[[cnt]] <- self$client$get(tmp_path, query)
                tmp[[cnt]]$raise_for_status()

                next_link <- tmp[[cnt]][["next"]]
                Sys.sleep(sleep)
            }

            private$resps <- tmp
        },
        resolve_next = function(link) {
            # Subtract base path etc. from 
            resolved <- gsub(
                pattern = paste0("^", self$client$get_base_url()),
                replacement = "",
                x = link)
            return(resolved)
        }

    )
)
