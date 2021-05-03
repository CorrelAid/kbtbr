test_that("the class can be initalized", {
    base_url <- "https://kobo.correlaid.org"
    kobo <- Kobo$new(base_url_v2 = base_url, kobo_token = Sys.getenv("KBTBR_TOKEN"))

    vcr::use_cassette("kobo-get-assets", {
        assets <- kobo$get_assets()
    })
    expect_setequal(names(assets), c("count", "results", "next", "previous"))
    expect_equal(assets$count, 8)
    expect_equal(length(assets$results), 8)
})