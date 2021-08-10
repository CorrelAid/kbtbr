# Load kbtbr package
# library(kbtbr)
library(dplyr)
library(purrr)
library(tidyr)
library(highcharter)

?kbtbr::Kobo

# Initialize new Kobo class
base_url <- Sys.getenv("KBTBR_BASE_URL")
token <- Sys.getenv("KBTBR_TOKEN")

kobo <- Kobo$new(base_url, token)
assets <- kobo$get_assets()$results

# Helper function
removeBaseUrl <- function(url){
  input_url <- gsub("https://kobo.correlaid.org/api/v2/", "", url)
  gsub("\\?format=json", "", input_url)
}


test_elements <- assets %>%
  group_by(asset_type) %>%
  arrange(desc(deployment__submission_count)) %>% # reverse sort by submissions to get a survey with submissions
  slice(1)
test_elements$asset_type


submissions <- test_elements %>%
  filter(asset_type == "survey") %>%
  pull(data) %>%
  removeBaseUrl() %>%
  kobo$get()




q1_family <- submissions$results$`Q1/Family` %>% as.factor()
levels(q1_family) <- c("1", "2", "3", "4")
levels(q1_family) <- c("Very important", "Quite important", "Not important", "Not at all important")

q1_leisure <- submissions$results$`Q1/Leisure_time` %>% as.factor()
levels(q1_leisure) <- c("1", "2", "3", "4")
levels(q1_leisure) <- c("Very important", "Quite important", "Not important", "Not at all important")

q1 <- data.frame(cbind(q1_family, q1_leisure))
q1 <- q1 %>% as_tibble()

q1 %>%
  count(q1_family, q1_leisure, .drop = FALSE)

q1_family <- q1_family %>% as_tibble() %>% rename("family" = "value") %>% group_by(family) %>%  count(family,.drop = FALSE)

hchart(q1_family, "column", hcaes(x = family, y = n))


q1_leisure <- submissions$results$`Q1/Leisure_time` %>% as.factor()
levels(q1_leisure) <- c("1", "2", "3", "4")
levels(q1_leisure) <- c("Very important", "Quite important", "Not important", "Not at all important")


q1_leisure <- q1_leisure %>% as_tibble() %>% rename("leisure" = "value") %>% group_by(leisure) %>%  count(leisure,.drop = FALSE)

hchart(q1_leisure, "column", hcaes(x = leisure, y = n))


