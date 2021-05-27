BASE_URL <- "https://kobo.correlaid.org"
#' -----------------------------------------------------------------------------
#' Testing basic properties, construction

test_that("the error from KoboClient is propagated correctly if we fail to provide a token", {
    withr::with_envvar(
        new = c("KBTBR_TOKEN" = ""),
        code = {
            expect_error(
                object = Kobo$new(base_url_v2 = BASE_URL),
                regexp = "No valid token detected."
            )
        }
    )
})

test_that("Kobo is initialized correctly if we provide a kobo_token manually with empty envvar.", {
    withr::with_envvar(
        new = c("KBTBR_TOKEN" = ""),
        code = {
            kobo_obj <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = "foo")
            expect_identical(
                class(kobo_obj),
                c("Kobo", "R6")
            )
        }
    )
})

test_that("we get a message if we do not specify base_url_v1, but Kobo is initialized.", {
    expect_message({
        kobo_obj <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = "foo")
    }, regexp = "You have not passed base_url_v1. This means you cannot use")
    expect_identical(
                class(kobo_obj),
                c("Kobo", "R6")
            )
})
#' -----------------------------------------------------------------------------
#' Testing $get_* methods
test_that("Request to v1 throws error if v1 session is not initialized", {
    kobo <- Kobo$new(base_url_v2 = BASE_URL)
    expect_error(kobo$get("submissions/", version = "v1"),
        regexp = "Session for API v1 is not initalized"
    )
})

test_that("Kobo can fetch assets", {
    # the use_cassette command looks into the fixtures directory and checks 
    # whether a "cassette" with the given name already exists. if yes, it loads it. if no, the 
    # code is run and the response is saved as a cassette.
    vcr::use_cassette("kobo-get-assets", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        assets <- kobo$get_assets()
    })
    expect_setequal(names(assets), c("count", "next", "previous", "results"))
    expect_true(all(c("url", "owner", "kind", "name", "asset_type") %in% colnames(assets$results)))
    expect_equal(nrow(assets$results), 8)
    expect_equal(assets$count, 8)
})

test_that("Kobo can fetch assets using simple get", {
    vcr::use_cassette("kobo-get-assets-simple-get", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        assets <- kobo$get("assets/") # trailing slash again!
    })
    expect_setequal(names(assets), c("count", "next", "previous", "results"))
    expect_true(all(c("url", "owner", "kind", "name", "asset_type") %in% colnames(assets$results)))
    expect_equal(nrow(assets$results), 8)
    expect_equal(assets$count, 8)
})


vcr::use_cassette("kobo-get-404", {
    test_that("non existing route throws 404 error", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        expect_error(kobo$get("doesnotexist/"), regexp = "404")
    })
})

test_that("non-existing kobo host throws error", {
        kobo <- Kobo$new(base_url_v2 = "https://nokobohere.correlaid.org", kobo_token = Sys.getenv("KBTBR_TOKEN"))
        expect_error(kobo$get("assets/"), regexp = "^SSL.+certificate.+")
})

