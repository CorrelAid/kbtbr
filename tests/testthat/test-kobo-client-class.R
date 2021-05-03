test_that("the class can be initalized", {
    base_url <- "https://kobo.correlaid.org/api/v2"
    kobo <- KoboClient$new(base_url = base_url, kobo_token = "faketoken")
    expect_equal(kobo$url, base_url)
    expect_equal(kobo$headers$Authorization, "Token faketoken")
})

test_that("get loads the assets on the asset path", {
  # the use_cassette command looks into the fixtures directory and checks 
  # whether a "cassette" with the given name already exists. if yes, it loads it. if no, the 
  # code is run and the response is saved as a cassette.
  session <- KoboClient$new("https://kobo.correlaid.org", kobo_token = Sys.getenv("KBTBR_TOKEN"))
  vcr::use_cassette("kobo-client-assets", {
    assets <- session$get(path = "api/v2/assets", list(format = "json")) # here we would put our R6 code that'd get data from kobo
  })
  expect_equal(assets$count, 8)
})
