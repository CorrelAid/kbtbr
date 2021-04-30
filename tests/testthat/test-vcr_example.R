# EXAMPLE VCR USAGE: RUN AND DELETE ME

foo <- function() crul::ok('https://httpbin.org/get')

test_that("foo works", {
  # the use_cassette command looks into the fixtures directory and checks 
  # whether a "cassette" with the given name already exists. if yes, it loads it. if no, the 
  # code is run and the response is saved as a cassette.
  vcr::use_cassette("testing", {
    x <- foo() # here we would put our R6 code that'd get data from kobo
  })
  expect_false(x)
})
