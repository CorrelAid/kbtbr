test_that("the class can be initalized", {
    base_url <- "https://kobo.correlaid.org/api/v2"
    kobo <- KoboClient$new(base_url = base_url, kobo_token = "faketoken")
    expect_equal(kobo$url, base_url)
    expect_true(is.character(kobo$headers$Authorization))
})

test_that("get loads the assets on the asset path", {
  # the use_cassette command looks into the fixtures directory and checks 
  # whether a "cassette" with the given name already exists. if yes, it loads it. if no, the 
  # code is run and the response is saved as a cassette.
  vcr::use_cassette("internal-client-assets", {
    session <- KoboClient$new("https://kobo.correlaid.org/v2/api", kobo_token = Sys.getenv("KBTBR_TOKEN"))
    assets <- session$get(path = "assets") # here we would put our R6 code that'd get data from kobo
  })
  parsed_assets <- assets$parse("UTF-8") %>%
    jsonlite::fromJSON()
  print(assets)
  expect_equal(parsed_assets$count, 6)
})
