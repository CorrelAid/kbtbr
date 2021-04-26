test_that("the class can be initalized", {
    base_url <- "https://kobo.correlaid.org/api/v2"
    kobo <- KoboClient$new(base_url = base_url, kobo_token = "faketoken")
    expect_false(kobo$v1_enabled)
    expect_equal(kobo$base_url, base_url)
})