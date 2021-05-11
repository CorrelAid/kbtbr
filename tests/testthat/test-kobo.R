base_url <- "https://kobo.correlaid.org"



#' -----------------------------------------------------------------------------
#' Testing basic properties, construction

test_that("the error from KoboClient is propagated correctly if we fail to provide a token", {
    withr::with_envvar(
        new = c("KBTBR_TOKEN" = ""),
        code = {
            expect_error(
                object = Kobo$new(base_url_v2 = base_url),
                regexp = "No valid token detected."
            )

            # b) `kobo_token` argument is provided, supersedes env var.
            #    is this propagated correctly to KoboClient?
            kobo_obj <- Kobo$new(base_url_v2 = base_url, kobo_token = "foo")
            expect_identical(
                class(kobo_obj),
                c("Kobo", "R6")
            )

            # c) `kobo_token` argument is provided, no baseurl for v1.
            kobo_obj <- Kobo$new(base_url_v2 = base_url, kobo_token = "foo")
            expect_identical(
                class(kobo_obj),
                c("Kobo", "R6")
            )
        }
    )
})

test_that("Kobo is initialized correctly if we provide a kobo_token manually with empty envvar.", {
    withr::with_envvar(
        new = c("KBTBR_TOKEN" = ""),
        code = {
            kobo_obj <- Kobo$new(base_url_v2 = base_url, kobo_token = "foo")
            expect_identical(
                class(kobo_obj),
                c("Kobo", "R6")
            )
        }
    )
})

test_that("we get a warning if we do not specify base_url_v1.", {
    expect_message(Kobo$new(base_url_v2 = base_url, kobo_token = "foo"),
        regexp = "You have not passed base_url_v1. This means you cannot use"
    )
})
#' -----------------------------------------------------------------------------
#' Testing $get_* methods
test_that("Request to v1 throws error if v1 session is not initialized", {
    kobo <- Kobo$new(base_url_v2 = base_url)
    expect_error(kobo$get("submissions/", version = "v1"),
        regexp = "Session for API v1 is not initalized"
    )
})

#' -----------------------------------------------------------------------------
#' Testing `$post_*`` methods