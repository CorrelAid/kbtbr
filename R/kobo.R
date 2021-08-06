#' @title Kobo Class
#' @description
#' Interface object for the Kobo API that can handle KoboClient instances
#' (sessions) for both API versions.
#' The Class exposes both generic and specific methods for HTTP requests /
#' interactions with the various endpoints.
#' @export
Kobo <- R6::R6Class("Kobo",
    private = list(
        select_prep_client = function(path, version) {
            if (version == "v2") {
                return(list(
                    client = self$session_v2,
                    path = paste0("api/v2/", path))
                )
            } else if (version == "v1") {
                if (checkmate::test_null(self$session_v1)) {
                    usethis::ui_stop(
                        paste(
                            "Session for API v1 is not initalized.",
                            "Please re-initalize the Kobo client with the",
                            "base_url_v1 argument.")
                    )
                } 
                return(list(
                    client = self$session_v1,
                    path = paste0("api/v1/", path)
                ))
            } else {
                usethis::ui_stop(
                    "Invalid version. Must be either v1 or v2.
                    Come back in a couple of years."
                )
            }
        }
    ),
    public = list(
        #' @field session_v2 KoboClient session for v2 of the API
        session_v2 = NULL,
        #' @field session_v1 KoboClient session for v1 of the API
        session_v1 = NULL,

        #' @description
        #' Initialization method for class "Kobo".
        #' @param base_url_v2 character. The base URL of the API version 2
        #'  (known as /api/v2). For example: https://kobo.correlaid.org.
        #' @param base_url_v1 character. The base URL of the API of your KoBoCAT
        #'  API (also known as /api/v1). Defaults to NULL.
        #'  For example: https://kc.correlaid.org.
        #' @param kobo_token character. The API token. Defaults to requesting
        #'  the systen environment `KBTBR_TOKEN`.
        #' @param session_v2 KoboClient. Alternatively, pass directly
        #' a KoboClient instance for the API version v2.
        #' @param session_v1 KoboKlient. In addition to session_v2 one can pass
        #' also a KoboClient instance for the API version v1.
        initialize = function(base_url_v2 = NULL, base_url_v1 = NULL,
                              kobo_token = Sys.getenv("KBTBR_TOKEN"),
                              session_v2 = NULL, session_v1 = NULL) {

            # one has to pass at least base_url_v2 or session_v2
            if (!xor(
                checkmate::test_null(base_url_v2),
                checkmate::test_null(session_v2)
            )) {
                stop("Either base_url_v2 or session_v2 must be provided")
            }

            if (!checkmate::test_null(base_url_v2)) {
                self$session_v2 <- KoboClient$new(base_url_v2, kobo_token)
            } else {
                self$session_v2 <- session_v2
            }

            if (!checkmate::test_null(base_url_v1)) {
                self$session_v1 <- KoboClient$new(base_url_v1, kobo_token)
            } else if (!checkmate::test_null(session_v1)) {
                self$session_v1 <- session_v1
            } else {
                # TODO: add to warning once we know what functnality is covered by v1.
                usethis::ui_info("You have not passed base_url_v1. This means you cannot use the following functions:")
            }
        },
        #' @description
        #' Wrapper for the GET method of internal session objects.
        #' @param path character. Path component of the endpoint.
        #' @param query list. A named list which is parsed to the query
        #'  component. The order is not hierarchical.
        #' @param version character. Indicates on which API version the request should be executed (available: `v1`, `v2`). Defaults to `v2`.
        #' @param format character. the format to request from the server. either 'json' or 'csv'. defaults to 'json'
        #' @param parse whether or not to parse the HTTP response. defaults to TRUE.
        #' @return a list encoding of the json server reply if parse=TRUE.
        #'   Otherwise, it returns the server response as a crul::HttpResponse
        #'   object.
        get = function(path, query = list(), version = "v2", format = "json",
                       parse = TRUE) {
            if (!format %in% c("json", "csv")) {
                usethis::ui_stop("Unsupported format. Only 'json' and 'csv' are supported")
            }
            
            query$format <- format
            
            # Select client
            obj <- private$select_prep_client(path, version)
            res <- obj$client$get(obj$path, query)
            res$raise_for_status()

            if (parse && format == "json") {
                res$raise_for_ct_json()
                return(jsonlite::fromJSON(res$parse("UTF-8")))
            } else if (parse && format == "csv") {
                usethis::ui_stop(
                    "TODO: Not supported yet"
                )
            } else if (parse) {
                usethis::ui_stop(
                    "TODO: Not supported yet"
                )
            }
            return(res)
        },

        #' @description
        #' Wrapper for the POST method of internal session objects.
        #' @param path character. Path component of the endpoint.
        #' @param body R list. A data payload to be sent to the server.
        #' @param version character. Indicates on which API version the request
        #'  should be executed (available: `v1`, `v2`). Defaults to `v2`.
        #' @return Returns an object of class `crul::HttpResponse`.
        post = function(path, body, version = "v2") {
            if (version == "v2") {
                if (path != "imports/") {
                    self$session_v2$post(path = paste0("api/v2/", path), body = body)
                } else {
                    self$session_v2$post(path = path, body = body)
                }
            } else if (version == "v1") {
                if (checkmate::test_null(self$session_v1)) {
                    usethis::ui_stop("Session for API v1 is not initalized.
          Please re-initalize the Kobo client with the base_url_v1 argument.")
                }
                self$session_v1$post(path = paste0("api/v1/", path), body = body)
            } else {
                usethis::ui_stop(
                    "Invalid version. Must be either v1 or v2.
          Come back in a couple of years."
                )
            }
        },

        #' @description
        #' Example method to send a GET request to the `assets` endpoint
        #' (due to default to `v2`, no further specification is needed).
        get_assets = function() {
            self$get("assets/")
        },

        #' @description
        #' Get an asset given its id.
        #' @param id character. ID of the asset within the Kobo API.
        #' @return Asset. object of class [kbtbr::Asset]
        get_asset = function(id) {
            res <- self$get(glue::glue("assets/{id}/"))
            Asset$new(res, self)
        },

        #' High-level POST request to clone an asset. `assets` endpoint
        #' (due to default to `v2`, no further specification is needed).
        #' @param clone_from character. UID of the asset to be cloned.
        #' @param new_name character. Name of the new asset.
        #' @param asset_type character. Type of the new asset. Can be
        #' "block", "question", "survey", "template".
        #' @return Returns an object of class `crul::HttpResponse`.
        clone_asset = function(clone_from, new_name, asset_type) {
            body <- list(
                "clone_from" = clone_from,
                "name" = new_name,
                "asset_type" = asset_type
            )
            self$post("assets/", body = body)
        },

        #' @description
        #' High-level POST request to deploy an asset.
        #' `assets/{uid}/deployment/` endpoint (due to
        #' default to `v2`, no further specification is needed).
        #' @param uid character. UID of the asset to be deployed.
        #' @return Returns an object of class `crul::HttpResponse`.
        deploy_asset = function(uid) {
            body <- list("active" = "true")
            endpoint <- paste0("assets/", uid, "/deployment/")
            self$post(endpoint, body = body)
        },

        #' @description
        #' High-level POST request to import an XLS form. `imports` endpoint
        #' (due to default to `v2`, no further specification is needed).
        #' @param name character. Name of the new asset.
        #' @param file_path  character. The path to the XLS form file.
        #' @return Returns an object of class `crul::HttpResponse`.
        import_xls_form = function(name, file_path) {
            body <- list(
                "name" = name,
                "library" = "false",
                "file" = crul::upload(file_path)
            )
            self$post("imports/", body = body)
        }
    ) # <end public>
)
