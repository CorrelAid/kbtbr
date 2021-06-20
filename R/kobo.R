#' @title Kobo Class
#' @description
#' Interface object for the Kobo API that can handle KoboClient instances
#' (sessions) for both API versions.
#' The Class exposes both generic and specific methods for HTTP requests /
#' interactions with the various endpoints.
#' @export
Kobo <- R6::R6Class("Kobo",
  private = list(
    session_v2 = NULL,
    session_v1 = NULL
  ), # <end private>

  public = list(
    #' @description
    #' Initialization method for class "Kobo".
    #' @param base_url_v2 character. The base URL of the API version 2
    #'  (known as /api/v2). For example: https://kobo.correlaid.org.
    #' @param base_url_v1 character. The base URL of the API of your KoBoCAT
    #'  API (also known as /api/v1). Defaults to NULL.
    #'  For example: https://kc.correlaid.org.
    #' @param kobo_token character. The API token. Defaults to requesting
    #'  the systen environment `KBTBR_TOKEN`.
    initialize = function(base_url_v2, base_url_v1 = NULL, kobo_token = Sys.getenv("KBTBR_TOKEN")) {
      private$session_v2 <- KoboClient$new(base_url_v2, kobo_token)

      if (!checkmate::test_null(base_url_v1)) {
          private$session_v1 <- KoboClient$new(base_url_v1, kobo_token)
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
    #' @param version character. Indicates on which API version the request
    #'  should be executed (available: `v1`, `v2`). Defaults to `v2`.
    get = function(path, query = list(format = "json"), version = "v2") {
      if (version == "v2") {
        private$session_v2$get(path = paste0("api/v2/", path), query = query)
      } else if (version == "v1") {
        if (checkmate::test_null(private$session_v1)) {
          usethis::ui_stop("Session for API v1 is not initalized.
          Please re-initalize the Kobo client with the base_url_v1 argument.")
        }
        private$session_v1$get(path = paste0("api/v1/", path), query = query)
      } else {
        usethis::ui_stop(
          "Invalid version. Must be either v1 or v2.
          Come back in a couple of years."
        )
      }
    },

    #' @description
    #' Wrapper for the POST method of internal session objects.
    #' @param path character. Path component of the endpoint.
    #' @param body R list or json-like string. A data payload to be sent
    #' to the server.
    #' @param version character. Indicates on which API version the request
    #'  should be executed (available: `v1`, `v2`). Defaults to `v2`.
    post = function(path, body, version = "v2") {
      if (version == "v2") {
        if (path != "imports/"){
          private$session_v2$post(path = paste0("api/v2/", path), body = body)
        } else {
          private$session_v2$post(path = path, body = body)
        }
      } else if (version == "v1") {
        if (checkmate::test_null(private$session_v1)) {
          usethis::ui_stop("Session for API v1 is not initalized.
          Please re-initalize the Kobo client with the base_url_v1 argument.")
        }
        private$session_v1$post(path = paste0("api/v1/", path), body = body)
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
      res_list <- self$get("assets/")
    },

    #' @description
    #' High-level POST request to clone an asset. `assets` endpoint
    #' (due to default to `v2`, no further specification is needed).
    #' @param clone_from character. UID of the asset to be cloned.
    #' @param name character. Name of the new asset.
    #' @param asset_type character. Type of the new asset. Can be
    #' "block", "question", "survey", "template".
    clone_asset = function(clone_from, name, asset_type) {
      body = list(
        "clone_from" = clone_from,
        "name" = name,
        "asset_type" = asset_type)
      self$post("assets/", body = body)
    },

    #' @description
    #' High-level POST request to deploy an asset.
    #' `assets/{uid}/deployment/` endpoint (due to
    #' default to `v2`, no further specification is needed).
    #' @param uid character. UID of the asset to be deployed.
    deploy_asset = function(uid) {
      body = list("active" = "true")
      endpoint = paste0("assets/",uid,"/deployment/")
      self$post(endpoint, body = body)
    },

    #' @description
    #' High-level POST request to create an empty asset. `assets/` endpoint
    #' (due to default to `v2`, no further specification is needed).
    #' @param name character. Name of the new asset.
    #' @param description character. Optional.
    #' @param sector character. Optional.
    #' @param country character. Optional.
    #' @param share_metadata boolean. Optional.
    #' @param asset_type character. Type of the new asset. Can be
    #' "block", "question", "survey", "template".
    create_asset = function(name,description,sector,
                            country,share_metadata,asset_type) {
      settings = list_as_json_char(
        list(
          "description"=description,
          "sector"=sector,"country"=country,
           "share_metadata"=share_metadata)
           )
      body = list(
        "name" = name,
        "settings"=settings,
        "asset_type" = asset_type)
      self$post("assets/", body = body)
    },

    #' @description
    #' High-level POST request to import an XLS form. `imports` endpoint
    #' (due to default to `v2`, no further specification is needed).
    #' @param name character. Name of the new asset.
    #' @param file character. The path to the file containing the XLS form.
    import_xls_form = function(name,file) {
      body = list(
        "name"=name,
        "library"="false",
        "file"=crul::upload(file))
      self$post("imports/", body = body)
    }
  ) # <end public>
)
