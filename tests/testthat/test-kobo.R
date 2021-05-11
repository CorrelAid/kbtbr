BASE_URL <- "https://kobo.correlaid.org"

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
        expect_error(kobo$get("assets/"), regexp = "SSL certificate problem: unable to get local issuer certificate")
})

