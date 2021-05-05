test_that("the class can be initalized", {
    base_url <- "https://kobo.correlaid.org"
    kobo <- Kobo$new(base_url_v2 = base_url, kobo_token = Sys.getenv("KBTBR_TOKEN"))
    assets <- kobo$get_assets()
    expect_true(is.list(assets))
    str(assets, 1)
})