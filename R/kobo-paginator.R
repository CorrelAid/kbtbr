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
      private$client <- assert_class(client, "KoboClient")
    },
    #' @description
    #' @param path
    #' @param query
    #' @param ... Additional parameters passed to internally
    #'  called `KoboClient$get()`.
    get = function(path, query, ...) {
      assert_string(path)
      assert_string(query)
      private$page(path, query, ...)
    },
    #' @description
    #' Set the initial response
    #' @details
    #' Usually, the page method would revoke a first response in the
    #' normal way, using its `next` element to walk over all subsequent
    #' pages. In some settings, the user might provide this initial response
    #' object already.
    set_first_response = function(response, force_reset = FALSE) {
      assert_list(response)
      if (!(force_reset || is.null(private$resps))) {
        stop("There are already existing responses. Use 'force_reset = TRUE' to reset/delete them.")
      }
      private$resps <- list(response)
    },
    get_responses = function() {
      return(private$resps)
    }
  ),
  private = list(
    resps = NULL,
    page = function(path, query, sleep = 0.5, ...) {
      tmp <- list()

      # Retrieve initial response

      # Initialize Pagination
      tmp[[1]] <- private$resps[[1]] %||% self$client$get(path, query, ...)
      next_link <- tmp[[1]][["next"]]
      cnt <- 1

      repeat {
        if (is.null(next_link)) {
          message(sprintf("Iterated over %s pages.", cnt))
          break
        }

        # New iteration
        Sys.sleep(sleep)
        cnt <- cnt + 1
        tmp_path <- private$resolve_next(next_link)

        tmp[[cnt]] <- self$client$get(tmp_path, query, ...)
        tmp[[cnt]]$raise_for_status()
        next_link <- tmp[[cnt]][["next"]]
      }

      private$resps <- tmp
    },
    resolve_next = function(link) {
      # Subtract base path etc. from
      resolved <- gsub(
        pattern = paste0("^", self$client$get_base_url()),
        replacement = "",
        x = link
      )
      return(resolved)
    }
  )
)
