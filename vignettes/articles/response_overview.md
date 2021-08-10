Response overview
================

-   [Use cases](#use-cases)
    -   [Get general information about an asset (Timm)](#get-general-information-about-an-asset-timm)
    -   [Get responses to a survey (Timm)](#get-responses-to-a-survey-timm)
    -   [Get permissions of an asset ()](#get-permissions-of-an-asset)
    -   [Get form metadata (Frie)](#get-form-metadata-frie)
    -   [File Downloads (Frie)](#file-downloads-frie)
-   [Overview / Comparison](#overview-comparison)
    -   [Data from the `url` url](#data-from-the-url-url)
    -   [Data from the `data` url](#data-from-the-data-url)
-   [In depth analysis](#in-depth-analysis)
    -   [Asset data frame](#asset-data-frame)
    -   [Survey](#survey)
    -   [Question](#question)
        -   [Content](#content)

``` r
base_url <- Sys.getenv("KBTBR_BASE_URL")
token <- Sys.getenv("KBTBR_TOKEN")

kobo <- Kobo$new(base_url, token)
assets <- kobo$get("assets/")$results
```

Get an element of each asset type:

``` r
first_of_type <- assets %>% 
  group_by(asset_type) %>% 
  arrange(desc(deployment__submission_count)) %>% # reverse sort by submissions to get a survey with submissions
  slice(1)
first_of_type$asset_type
```

    ## [1] "block"    "question" "survey"   "template"

**Important**: `url` and `data` URLs contain almost all of the relevant information.

Use cases
=========

Get general information about an asset (Timm)
---------------------------------------------

Get the name of an asset:

``` r
colnames(assets)
```

    ##  [1] "url"                          "date_modified"               
    ##  [3] "date_created"                 "owner"                       
    ##  [5] "summary"                      "owner__username"             
    ##  [7] "parent"                       "uid"                         
    ##  [9] "tag_string"                   "settings"                    
    ## [11] "kind"                         "name"                        
    ## [13] "asset_type"                   "version_id"                  
    ## [15] "has_deployment"               "deployed_version_id"         
    ## [17] "deployment__identifier"       "deployment__active"          
    ## [19] "deployment__submission_count" "permissions"                 
    ## [21] "downloads"                    "data"

Get the uid of an asset:

``` r
assets$uid
```

    ##  [1] "aMPwk5HB3C6nt3e7yH2Ppo" "a84jmwwdPEsZMhK7s2i4SL" "ajzghKK6NELaixPQqsm49e"
    ##  [4] "aZX4ysiPdP3JHnTMbnu2n2" "aRo4wg5utWT7dwdnQQEAE7" "aSmGHTKbLZWu2uc4HzEbtn"
    ##  [7] "akx2SZbwn65hGBAWgBYwiQ" "a7AV5JhRHKf8EWGBJLswwC" "a45JAGjSNac4tQGREXR79e"
    ## [10] "a9BzPvnNLub346sr8M7R33"

Additional information to the assets:

``` r
summary(str(assets, max.level = 1))
```

    ## 'data.frame':    10 obs. of  22 variables:
    ##  $ url                         : chr  "https://kobo.correlaid.org/api/v2/assets/aMPwk5HB3C6nt3e7yH2Ppo/?format=json" "https://kobo.correlaid.org/api/v2/assets/a84jmwwdPEsZMhK7s2i4SL/?format=json" "https://kobo.correlaid.org/api/v2/assets/ajzghKK6NELaixPQqsm49e/?format=json" "https://kobo.correlaid.org/api/v2/assets/aZX4ysiPdP3JHnTMbnu2n2/?format=json" ...
    ##  $ date_modified               : chr  "2021-05-15T19:06:24.927986Z" "2021-05-15T18:50:36.054416Z" "2021-05-13T16:59:25.147719Z" "2021-05-03T15:01:49.807891Z" ...
    ##  $ date_created                : chr  "2021-05-15T19:05:17.311721Z" "2021-05-15T18:50:36.054394Z" "2021-04-28T19:52:13.144873Z" "2021-02-25T15:29:57.813770Z" ...
    ##  $ owner                       : chr  "https://kobo.correlaid.org/api/v2/users/api_user/?format=json" "https://kobo.correlaid.org/api/v2/users/api_user/?format=json" "https://kobo.correlaid.org/api/v2/users/api_user/?format=json" "https://kobo.correlaid.org/api/v2/users/super_admin/?format=json" ...
    ##  $ summary                     :'data.frame':    10 obs. of  6 variables:
    ##  $ owner__username             : chr  "api_user" "api_user" "api_user" "super_admin" ...
    ##  $ parent                      : chr  NA NA NA "https://kobo.correlaid.org/api/v2/collections/cjpaoCes6BZiCbzn9Tv6bA/?format=json" ...
    ##  $ uid                         : chr  "aMPwk5HB3C6nt3e7yH2Ppo" "a84jmwwdPEsZMhK7s2i4SL" "ajzghKK6NELaixPQqsm49e" "aZX4ysiPdP3JHnTMbnu2n2" ...
    ##  $ tag_string                  : chr  "" "" "" "" ...
    ##  $ settings                    :'data.frame':    10 obs. of  4 variables:
    ##  $ kind                        : chr  "asset" "asset" "asset" "asset" ...
    ##  $ name                        : chr  "This is a cloned survey (via API/R)" "A survey object created via API/R" "test_built_from_scratch" "Template survey applications" ...
    ##  $ asset_type                  : chr  "survey" "survey" "survey" "template" ...
    ##  $ version_id                  : chr  "vN7gDMN3Td8BEw8T56jkdz" "vrFx4VXXPVf6nThHWShbT4" "v39addKozAjjUTpsr8eYRm" "vMD7uBPhuWpRMCmJuKVrHp" ...
    ##  $ has_deployment              : logi  TRUE FALSE TRUE FALSE TRUE TRUE ...
    ##  $ deployed_version_id         : chr  "vN7gDMN3Td8BEw8T56jkdz" NA "v39addKozAjjUTpsr8eYRm" NA ...
    ##  $ deployment__identifier      : chr  "https://kc.correlaid.org/api_user/forms/aMPwk5HB3C6nt3e7yH2Ppo" NA "https://kc.correlaid.org/api_user/forms/ajzghKK6NELaixPQqsm49e" NA ...
    ##  $ deployment__active          : logi  FALSE FALSE TRUE FALSE TRUE TRUE ...
    ##  $ deployment__submission_count: int  0 0 0 0 4 2 1 0 0 0
    ##  $ permissions                 :List of 10
    ##  $ downloads                   :List of 10
    ##  $ data                        : chr  "https://kobo.correlaid.org/api/v2/assets/aMPwk5HB3C6nt3e7yH2Ppo/data/?format=json" "https://kobo.correlaid.org/api/v2/assets/a84jmwwdPEsZMhK7s2i4SL/data/?format=json" "https://kobo.correlaid.org/api/v2/assets/ajzghKK6NELaixPQqsm49e/data/?format=json" "https://kobo.correlaid.org/api/v2/assets/aZX4ysiPdP3JHnTMbnu2n2/data/?format=json" ...

    ## Length  Class   Mode 
    ##      0   NULL   NULL

Get responses to a survey (Timm)
--------------------------------

``` r
url_data <- first_of_type$url %>% 
  map(function(url) {
    kobo$get(removeBaseUrl(url))
  }) %>% 
  set_names(paste0(first_of_type$asset_type, "_url"))

str(url_data$survey_url, max.level = 1)
```

    ## List of 39
    ##  $ url                            : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/?format=json"
    ##  $ owner                          : chr "https://kobo.correlaid.org/api/v2/users/api_user/?format=json"
    ##  $ owner__username                : chr "api_user"
    ##  $ parent                         : NULL
    ##  $ ancestors                      : NULL
    ##  $ settings                       :List of 4
    ##  $ asset_type                     : chr "survey"
    ##  $ date_created                   : chr "2021-05-02T12:12:11.859577Z"
    ##  $ summary                        :List of 6
    ##  $ date_modified                  : chr "2021-05-02T12:41:54.037442Z"
    ##  $ version_id                     : chr "vGEYKrPXZhge2uYk4toEKs"
    ##  $ version__content_hash          : chr "9487faea38af0b94b0f165fe6a78b0f4fc8e1aa3"
    ##  $ version_count                  : int 6
    ##  $ has_deployment                 : logi TRUE
    ##  $ deployed_version_id            : chr "vGEYKrPXZhge2uYk4toEKs"
    ##  $ deployed_versions              :List of 4
    ##  $ deployment__identifier         : chr "https://kc.correlaid.org/api_user/forms/aRo4wg5utWT7dwdnQQEAE7"
    ##  $ deployment__links              :List of 8
    ##  $ deployment__active             : logi TRUE
    ##  $ deployment__data_download_links:List of 6
    ##  $ deployment__submission_count   : int 4
    ##  $ report_styles                  :List of 3
    ##  $ report_custom                  : Named list()
    ##  $ map_styles                     : Named list()
    ##  $ map_custom                     : Named list()
    ##  $ content                        :List of 6
    ##  $ downloads                      :'data.frame': 2 obs. of  2 variables:
    ##  $ embeds                         :'data.frame': 2 obs. of  2 variables:
    ##  $ koboform_link                  : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/koboform/?format=json"
    ##  $ xform_link                     : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/xform/?format=json"
    ##  $ hooks_link                     : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/hooks/?format=json"
    ##  $ tag_string                     : chr ""
    ##  $ uid                            : chr "aRo4wg5utWT7dwdnQQEAE7"
    ##  $ kind                           : chr "asset"
    ##  $ xls_link                       : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/xls/?format=json"
    ##  $ name                           : chr "kbtbr Testing Survey"
    ##  $ assignable_permissions         :'data.frame': 9 obs. of  2 variables:
    ##  $ permissions                    :'data.frame': 8 obs. of  4 variables:
    ##  $ data                           : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/data/?format=json"

Retrieve the `content` from the survey\_url:

``` r
str(url_data$survey_url$content, max.level = 2)
```

    ## List of 6
    ##  $ schema      : chr "1"
    ##  $ survey      :'data.frame':    25 obs. of  10 variables:
    ##   ..$ name                 : chr [1:25] "start" "end" "Q1" NA ...
    ##   ..$ type                 : chr [1:25] "start" "end" "begin_score" "score__row" ...
    ##   ..$ $kuid                : chr [1:25] "dCWJ0qKC4" "m28GgoH7K" "dr9fq65" "kr9ur31" ...
    ##   ..$ $autoname            : chr [1:25] "start" "end" "Q1" "Work" ...
    ##   ..$ label                :List of 25
    ##   ..$ required             : logi [1:25] NA NA FALSE FALSE FALSE FALSE ...
    ##   ..$ kobo--score-choices  : chr [1:25] NA NA "ys4jh05" NA ...
    ##   ..$ select_from_list_name: chr [1:25] NA NA NA NA ...
    ##   ..$ hint                 :List of 25
    ##   ..$ parameters           : chr [1:25] NA NA NA NA ...
    ##  $ choices     :'data.frame':    29 obs. of  5 variables:
    ##   ..$ name      : chr [1:29] "1" "2" "3" "4" ...
    ##   ..$ $kuid     : chr [1:29] "NPp8OR3md" "LnI83gRXp" "u6ot3527d" "gRoco4Pev" ...
    ##   ..$ label     :List of 29
    ##   ..$ list_name : chr [1:29] "ys4jh05" "ys4jh05" "ys4jh05" "ys4jh05" ...
    ##   ..$ $autovalue: chr [1:29] "1" "2" "3" "4" ...
    ##  $ settings    : Named list()
    ##  $ translated  : chr [1:2] "hint" "label"
    ##  $ translations: logi NA

Get permissions of an asset ()
------------------------------

Get form metadata (Frie)
------------------------

File Downloads (Frie)
---------------------

Overview / Comparison
=====================

Data from the `url` url
-----------------------

`GET` the data from the `url` URL.

``` r
# data from "url" url
url_data <- first_of_type$url %>% 
  map(function(url) {
    kobo$get(removeBaseUrl(url))
  }) %>% 
  set_names(paste0(first_of_type$asset_type, "_url"))
```

``` r
assets_names <- tibble(name = colnames(assets), type = "assets")
# extract the names from the object
url_data %>% 
  map_dfr(function(el) {
    names(el)
  }) %>% 
  pivot_longer(everything(), names_to = "type", values_to = "name") %>% 
  bind_rows(assets_names) %>% # combine with assets_df 
  janitor::tabyl(name, type) %>%   
  knitr::kable()
```

| name                                |     assets|    block\_url|    question\_url|    survey\_url|                                                                                                                                                                                                                        template\_url|
|:------------------------------------|----------:|-------------:|----------------:|--------------:|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| ancestors                           |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| asset\_type                         |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| assignable\_permissions             |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| content                             |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| data                                |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| date\_created                       |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| date\_modified                      |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| deployed\_version\_id               |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| deployed\_versions                  |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| deployment\_\_active                |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| deployment\_\_data\_download\_links |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| deployment\_\_identifier            |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| deployment\_\_links                 |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| deployment\_\_submission\_count     |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| downloads                           |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| embeds                              |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| has\_deployment                     |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| hooks\_link                         |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| kind                                |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| koboform\_link                      |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| map\_custom                         |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| map\_styles                         |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| name                                |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| owner                               |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| owner\_\_username                   |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| parent                              |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| permissions                         |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| report\_custom                      |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| report\_styles                      |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| settings                            |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| summary                             |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| tag\_string                         |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| uid                                 |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| url                                 |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| version\_\_content\_hash            |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| version\_count                      |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| version\_id                         |          1|             1|                1|              1|                                                                                                                                                                                                                                    1|
| xform\_link                         |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| xls\_link                           |          0|             1|                1|              1|                                                                                                                                                                                                                                    1|
| All asset types have the same elem  |  ents in t|  heir `url` r|  eturn object. W|  e also see th|  at quite a lot of metadata seems to be already available in the assets data frame that we get from the `assets/` endpoint (cross-checking that the values are indeed the same would be beneficial - an attempt is made down below).|

Data from the `data` url
------------------------

``` r
data_data <- first_of_type$data %>% 
  map(function(url) {
    # "data" url seems to be 404 except for surveys, so try-catch it
    # might also be different if we use questions, blocks, templates more seriously?
    tmp <- tryCatch(
      kobo$get(removeBaseUrl(url))$results,
      error = function(e) e$message
    )
    tmp
  }) %>% 
  set_names(paste(first_of_type$asset_type, "data", sep = "_"))

str(data_data, max.level = 2)
```

    ## List of 4
    ##  $ block_data   : chr "Not Found (HTTP 404)"
    ##  $ question_data: chr "Bad Request (HTTP 400)"
    ##  $ survey_data  :'data.frame':   4 obs. of  35 variables:
    ##   ..$ _id                                                                        : int [1:4] 104 105 106 107
    ##   ..$ _notes                                                                     :List of 4
    ##   ..$ Q1/Leisure_time                                                            : chr [1:4] "3" "4" "1" "3"
    ##   ..$ Taking_all_things_to_ould_you_say_you_are                                  : chr [1:4] "2" "1" "2" "4"
    ##   ..$ I_would_like_to_ask_y_much_or_not_at_all/People_you_know_personally        : chr [1:4] "2" "3" "1" "4"
    ##   ..$ _validation_status                                                         :'data.frame':  4 obs. of  0 variables
    ##   ..$ _uuid                                                                      : chr [1:4] "aca8c44f-6327-4024-9187-c9e10151c940" "7ab504ec-1a1e-49e5-960c-39b77f5e00c5" "3b98cf99-b651-422b-ace9-c242ca8f9717" "8a12d9e0-68ab-4df6-a7e7-294a8eb66d15"
    ##   ..$ _tags                                                                      :List of 4
    ##   ..$ I_would_like_to_ask_y_much_or_not_at_all/People_you_meet_for_the_first_time: chr [1:4] "2" "3" "3" "1"
    ##   ..$ Generally_speaking_dealing_with_people                                     : chr [1:4] "1" "1" "8" "8"
    ##   ..$ Did_you_do_voluntary_in_the_last_6_months                                  : chr [1:4] "2" "2" "9" "9"
    ##   ..$ _xform_id_string                                                           : chr [1:4] "aRo4wg5utWT7dwdnQQEAE7" "aRo4wg5utWT7dwdnQQEAE7" "aRo4wg5utWT7dwdnQQEAE7" "aRo4wg5utWT7dwdnQQEAE7"
    ##   ..$ I_would_like_to_ask_y_much_or_not_at_all/People_of_another_nationality     : chr [1:4] "2" "3" "2" "1"
    ##   ..$ I_would_like_to_ask_y_much_or_not_at_all/Your_family                       : chr [1:4] "2" "2" "1" "4"
    ##   ..$ meta/instanceID                                                            : chr [1:4] "uuid:aca8c44f-6327-4024-9187-c9e10151c940" "uuid:7ab504ec-1a1e-49e5-960c-39b77f5e00c5" "uuid:3b98cf99-b651-422b-ace9-c242ca8f9717" "uuid:8a12d9e0-68ab-4df6-a7e7-294a8eb66d15"
    ##   ..$ _status                                                                    : chr [1:4] "submitted_via_web" "submitted_via_web" "submitted_via_web" "submitted_via_web"
    ##   ..$ I_would_like_to_ask_y_much_or_not_at_all/People_in_your_neighborhood       : chr [1:4] "2" "1" "2" "1"
    ##   ..$ formhub/uuid                                                               : chr [1:4] "1f37921296654b91b8cc11e152956764" "1f37921296654b91b8cc11e152956764" "1f37921296654b91b8cc11e152956764" "1f37921296654b91b8cc11e152956764"
    ##   ..$ end                                                                        : chr [1:4] "2021-05-02T14:35:35.092+02:00" "2021-05-02T14:36:36.740+02:00" "2021-05-02T14:44:30.817+02:00" "2021-05-02T16:17:10.920+02:00"
    ##   ..$ Q1/Friends_and_acquaintances                                               : chr [1:4] "1" "3" "2" "2"
    ##   ..$ _submission_time                                                           : chr [1:4] "2021-05-02T12:35:45" "2021-05-02T12:36:47" "2021-05-02T12:44:41" "2021-05-02T14:17:12"
    ##   ..$ I_would_like_to_ask_y_much_or_not_at_all/People_of_another_religion        : chr [1:4] "2" "2" "2" "1"
    ##   ..$ Q1/Politics                                                                : chr [1:4] "3" "3" "2" "2"
    ##   ..$ _attachments                                                               :List of 4
    ##   ..$ Q1/Family                                                                  : chr [1:4] "3" "2" "3" "3"
    ##   ..$ start                                                                      : chr [1:4] "2021-05-02T14:34:33.302+02:00" "2021-05-02T14:36:11.481+02:00" "2021-05-02T14:42:11.950+02:00" "2021-05-02T14:44:30.930+02:00"
    ##   ..$ _submitted_by                                                              : logi [1:4] NA NA NA NA
    ##   ..$ _geolocation                                                               :List of 4
    ##   ..$ Q1/Work                                                                    : chr [1:4] "2" "1" "4" "2"
    ##   ..$ All_in_all_how_woul_would_you_say_it_is                                    : chr [1:4] "4" "8" "5" "3"
    ##   ..$ __version__                                                                : chr [1:4] "vhWtJRry8cSn5PBEda3oDy" "vhWtJRry8cSn5PBEda3oDy" "vGEYKrPXZhge2uYk4toEKs" "vGEYKrPXZhge2uYk4toEKs"
    ##   ..$ Some_people_feel_the_your_life_turns_out                                   : chr [1:4] "6" "3" "8" "10"
    ##   ..$ Q1/Religion                                                                : chr [1:4] "2" "2" "3" "3"
    ##   ..$ Upload_an_arbitrary_file                                                   : chr [1:4] NA NA "E0QLjvNUYAAe-s_-14_44_17.jpeg" NA
    ##   ..$ Please_indicate_wher_the_map_is_Hamburg                                    : chr [1:4] NA NA "53.555892 9.948884 0 0" "53.894588 10.79745 0 0"
    ##  $ template_data: chr "Not Found (HTTP 404)"

For the `data` url, we get a mixed pattern. For survey objects, the results contain the submissions to the survey as a data frame or an empty list if there are no submissions (*not* an empty data frame with the variables!). For the template and the block types, we get a 404, for the question type a 400 (bad request). This must be further investigated whether this is a bug of the CorrelAid server or as intended, e.g. by testing this on the official Kobo server. Most of the metadata for questions, templates and blocks is in the "content" element of the `url` data - see below - so it might be well that there is intentionally no "data" for this type.

In depth analysis
=================

**in bold** are elements that seem to be particularly interesting for us and the construction of response classes.

Asset data frame
----------------

``` r
colnames(assets)
```

    ##  [1] "url"                          "date_modified"               
    ##  [3] "date_created"                 "owner"                       
    ##  [5] "summary"                      "owner__username"             
    ##  [7] "parent"                       "uid"                         
    ##  [9] "tag_string"                   "settings"                    
    ## [11] "kind"                         "name"                        
    ## [13] "asset_type"                   "version_id"                  
    ## [15] "has_deployment"               "deployed_version_id"         
    ## [17] "deployment__identifier"       "deployment__active"          
    ## [19] "deployment__submission_count" "permissions"                 
    ## [21] "downloads"                    "data"

-   **`asset_type`**

``` r
table(assets$asset_type)
```

    ## 
    ##    block question   survey template 
    ##        2        1        6        1

-   **`url`** and **`data`**: urls that'll give us more information about the specific assets

``` r
assets %>% 
  select(url, data)
```

    ##                                                                             url
    ## 1  https://kobo.correlaid.org/api/v2/assets/aMPwk5HB3C6nt3e7yH2Ppo/?format=json
    ## 2  https://kobo.correlaid.org/api/v2/assets/a84jmwwdPEsZMhK7s2i4SL/?format=json
    ## 3  https://kobo.correlaid.org/api/v2/assets/ajzghKK6NELaixPQqsm49e/?format=json
    ## 4  https://kobo.correlaid.org/api/v2/assets/aZX4ysiPdP3JHnTMbnu2n2/?format=json
    ## 5  https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/?format=json
    ## 6  https://kobo.correlaid.org/api/v2/assets/aSmGHTKbLZWu2uc4HzEbtn/?format=json
    ## 7  https://kobo.correlaid.org/api/v2/assets/akx2SZbwn65hGBAWgBYwiQ/?format=json
    ## 8  https://kobo.correlaid.org/api/v2/assets/a7AV5JhRHKf8EWGBJLswwC/?format=json
    ## 9  https://kobo.correlaid.org/api/v2/assets/a45JAGjSNac4tQGREXR79e/?format=json
    ## 10 https://kobo.correlaid.org/api/v2/assets/a9BzPvnNLub346sr8M7R33/?format=json
    ##                                                                                 data
    ## 1  https://kobo.correlaid.org/api/v2/assets/aMPwk5HB3C6nt3e7yH2Ppo/data/?format=json
    ## 2  https://kobo.correlaid.org/api/v2/assets/a84jmwwdPEsZMhK7s2i4SL/data/?format=json
    ## 3  https://kobo.correlaid.org/api/v2/assets/ajzghKK6NELaixPQqsm49e/data/?format=json
    ## 4  https://kobo.correlaid.org/api/v2/assets/aZX4ysiPdP3JHnTMbnu2n2/data/?format=json
    ## 5  https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/data/?format=json
    ## 6  https://kobo.correlaid.org/api/v2/assets/aSmGHTKbLZWu2uc4HzEbtn/data/?format=json
    ## 7  https://kobo.correlaid.org/api/v2/assets/akx2SZbwn65hGBAWgBYwiQ/data/?format=json
    ## 8  https://kobo.correlaid.org/api/v2/assets/a7AV5JhRHKf8EWGBJLswwC/data/?format=json
    ## 9  https://kobo.correlaid.org/api/v2/assets/a45JAGjSNac4tQGREXR79e/data/?format=json
    ## 10 https://kobo.correlaid.org/api/v2/assets/a9BzPvnNLub346sr8M7R33/data/?format=json

-   general metadata:
-   **`name`**: name of the asset
-   **`owner`** and **`owner__username`**: the api url for the owner and the human-readable username
-   **`uid`**: the unique id of the asset, used in the urls.. but i suppose it doesn't make a lot of sense to use this to construct urls ourselves given that they are always nicely handed to us by the API
-   `settings`: sector, country where it was deployed, description given by the user

``` r
colnames(assets$settings)
```

    ## [1] "sector"         "country"        "description"    "share-metadata"

``` r
str(assets$settings)
```

    ## 'data.frame':    10 obs. of  4 variables:
    ##  $ sector        :'data.frame':  10 obs. of  2 variables:
    ##   ..$ label: chr  "Other" NA "Other" NA ...
    ##   ..$ value: chr  "Other" NA "Other" NA ...
    ##  $ country       :'data.frame':  10 obs. of  2 variables:
    ##   ..$ label: chr  "Germany" NA "Germany" NA ...
    ##   ..$ value: chr  "DEU" NA "DEU" NA ...
    ##  $ description   : chr  "" NA "" NA ...
    ##  $ share-metadata: logi  NA NA FALSE NA FALSE FALSE ...

-   `version` and `deployment*` columns: information about the version and the current deployment

``` r
assets %>% 
  select(starts_with("deployment"), version_id)
```

    ##                                            deployment__identifier
    ## 1  https://kc.correlaid.org/api_user/forms/aMPwk5HB3C6nt3e7yH2Ppo
    ## 2                                                            <NA>
    ## 3  https://kc.correlaid.org/api_user/forms/ajzghKK6NELaixPQqsm49e
    ## 4                                                            <NA>
    ## 5  https://kc.correlaid.org/api_user/forms/aRo4wg5utWT7dwdnQQEAE7
    ## 6  https://kc.correlaid.org/api_user/forms/aSmGHTKbLZWu2uc4HzEbtn
    ## 7  https://kc.correlaid.org/api_user/forms/akx2SZbwn65hGBAWgBYwiQ
    ## 8                                                            <NA>
    ## 9                                                            <NA>
    ## 10                                                           <NA>
    ##    deployment__active deployment__submission_count             version_id
    ## 1               FALSE                            0 vN7gDMN3Td8BEw8T56jkdz
    ## 2               FALSE                            0 vrFx4VXXPVf6nThHWShbT4
    ## 3                TRUE                            0 v39addKozAjjUTpsr8eYRm
    ## 4               FALSE                            0 vMD7uBPhuWpRMCmJuKVrHp
    ## 5                TRUE                            4 vGEYKrPXZhge2uYk4toEKs
    ## 6                TRUE                            2 vJEfSwVjJE2z4vfWoAcrKr
    ## 7                TRUE                            1 vCHJLzRcCKrSLDzPKbKcFB
    ## 8               FALSE                            0 ve66TcLYqgsfpeQRyA9YZn
    ## 9               FALSE                            0 vvvbx6kAbsWDsqahxFxfmx
    ## 10              FALSE                            0 vSEHjmUidgBcfC56tGsDuJ

-   `permissions`: permissions for this asset, one row per user and permission given.

``` r
str(assets$permissions[[1]], max.level = 1)
```

    ## 'data.frame':    8 obs. of  4 variables:
    ##  $ url       : chr  "https://kobo.correlaid.org/api/v2/assets/aMPwk5HB3C6nt3e7yH2Ppo/permission-assignments/pafJxbJ393kwMa6h2azqes/?format=json" "https://kobo.correlaid.org/api/v2/assets/aMPwk5HB3C6nt3e7yH2Ppo/permission-assignments/prbeRno37N6BrVxYecE6bE/?format=json" "https://kobo.correlaid.org/api/v2/assets/aMPwk5HB3C6nt3e7yH2Ppo/permission-assignments/pFQLp9k7E5gdNpVfQ7kgHn/?format=json" "https://kobo.correlaid.org/api/v2/assets/aMPwk5HB3C6nt3e7yH2Ppo/permission-assignments/pnTHhhhVh9QjSfrWxyFNmN/?format=json" ...
    ##  $ user      : chr  "https://kobo.correlaid.org/api/v2/users/api_user/?format=json" "https://kobo.correlaid.org/api/v2/users/api_user/?format=json" "https://kobo.correlaid.org/api/v2/users/api_user/?format=json" "https://kobo.correlaid.org/api/v2/users/api_user/?format=json" ...
    ##  $ permission: chr  "https://kobo.correlaid.org/api/v2/permissions/add_submissions/?format=json" "https://kobo.correlaid.org/api/v2/permissions/change_asset/?format=json" "https://kobo.correlaid.org/api/v2/permissions/change_submissions/?format=json" "https://kobo.correlaid.org/api/v2/permissions/delete_submissions/?format=json" ...
    ##  $ label     : chr  "Add submissions" "Edit form" "Edit submissions" "Delete submissions" ...

Survey
------

``` r
surveyObject <- url_data$survey_url
```

In the following you can see a summary of the information you can retrieve from the `surveyObject`, which is a list of 39 elements. The elements of the type `list` of the `surveyObject` have to be accessed separately to get the resprective sublists (number of sublists given in column `Length`). Elements of type `NULL` do not comprise any information and hence, are not displayed separately below.

``` r
summary(surveyObject)
```

    ##                                 Length Class      Mode     
    ## url                             1      -none-     character
    ## owner                           1      -none-     character
    ## owner__username                 1      -none-     character
    ## parent                          0      -none-     NULL     
    ## ancestors                       0      -none-     NULL     
    ## settings                        4      -none-     list     
    ## asset_type                      1      -none-     character
    ## date_created                    1      -none-     character
    ## summary                         6      -none-     list     
    ## date_modified                   1      -none-     character
    ## version_id                      1      -none-     character
    ## version__content_hash           1      -none-     character
    ## version_count                   1      -none-     numeric  
    ## has_deployment                  1      -none-     logical  
    ## deployed_version_id             1      -none-     character
    ## deployed_versions               4      -none-     list     
    ## deployment__identifier          1      -none-     character
    ## deployment__links               8      -none-     list     
    ## deployment__active              1      -none-     logical  
    ## deployment__data_download_links 6      -none-     list     
    ## deployment__submission_count    1      -none-     numeric  
    ## report_styles                   3      -none-     list     
    ## report_custom                   0      -none-     list     
    ## map_styles                      0      -none-     list     
    ## map_custom                      0      -none-     list     
    ## content                         6      -none-     list     
    ## downloads                       2      data.frame list     
    ## embeds                          2      data.frame list     
    ## koboform_link                   1      -none-     character
    ## xform_link                      1      -none-     character
    ## hooks_link                      1      -none-     character
    ## tag_string                      1      -none-     character
    ## uid                             1      -none-     character
    ## kind                            1      -none-     character
    ## xls_link                        1      -none-     character
    ## name                            1      -none-     character
    ## assignable_permissions          2      data.frame list     
    ## permissions                     4      data.frame list     
    ## data                            1      -none-     character

Here you have a more detailed overview with the elements of type character, `logical` and `numeric` displayed.

``` r
str(surveyObject, max.level = 1)
```

    ## List of 39
    ##  $ url                            : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/?format=json"
    ##  $ owner                          : chr "https://kobo.correlaid.org/api/v2/users/api_user/?format=json"
    ##  $ owner__username                : chr "api_user"
    ##  $ parent                         : NULL
    ##  $ ancestors                      : NULL
    ##  $ settings                       :List of 4
    ##  $ asset_type                     : chr "survey"
    ##  $ date_created                   : chr "2021-05-02T12:12:11.859577Z"
    ##  $ summary                        :List of 6
    ##  $ date_modified                  : chr "2021-05-02T12:41:54.037442Z"
    ##  $ version_id                     : chr "vGEYKrPXZhge2uYk4toEKs"
    ##  $ version__content_hash          : chr "9487faea38af0b94b0f165fe6a78b0f4fc8e1aa3"
    ##  $ version_count                  : int 6
    ##  $ has_deployment                 : logi TRUE
    ##  $ deployed_version_id            : chr "vGEYKrPXZhge2uYk4toEKs"
    ##  $ deployed_versions              :List of 4
    ##  $ deployment__identifier         : chr "https://kc.correlaid.org/api_user/forms/aRo4wg5utWT7dwdnQQEAE7"
    ##  $ deployment__links              :List of 8
    ##  $ deployment__active             : logi TRUE
    ##  $ deployment__data_download_links:List of 6
    ##  $ deployment__submission_count   : int 4
    ##  $ report_styles                  :List of 3
    ##  $ report_custom                  : Named list()
    ##  $ map_styles                     : Named list()
    ##  $ map_custom                     : Named list()
    ##  $ content                        :List of 6
    ##  $ downloads                      :'data.frame': 2 obs. of  2 variables:
    ##  $ embeds                         :'data.frame': 2 obs. of  2 variables:
    ##  $ koboform_link                  : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/koboform/?format=json"
    ##  $ xform_link                     : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/xform/?format=json"
    ##  $ hooks_link                     : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/hooks/?format=json"
    ##  $ tag_string                     : chr ""
    ##  $ uid                            : chr "aRo4wg5utWT7dwdnQQEAE7"
    ##  $ kind                           : chr "asset"
    ##  $ xls_link                       : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/xls/?format=json"
    ##  $ name                           : chr "kbtbr Testing Survey"
    ##  $ assignable_permissions         :'data.frame': 9 obs. of  2 variables:
    ##  $ permissions                    :'data.frame': 8 obs. of  4 variables:
    ##  $ data                           : chr "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/data/?format=json"

Finally, all the sublists displayed separately in - roughly - decreasing order of interest, whereby the sublist `content` might be of particular interest.

``` r
surveyObject$content  
```

    ## $schema
    ## [1] "1"
    ## 
    ## $survey
    ##     name        type     $kuid                                 $autoname
    ## 1  start       start dCWJ0qKC4                                     start
    ## 2    end         end m28GgoH7K                                       end
    ## 3     Q1 begin_score   dr9fq65                                        Q1
    ## 4   <NA>  score__row   kr9ur31                                      Work
    ## 5   <NA>  score__row   tf9rd50                                    Family
    ## 6   <NA>  score__row   mk6mc53                 Friends_and_acquaintances
    ## 7   <NA>  score__row   lr5sh35                              Leisure_time
    ## 8   <NA>  score__row   ob3me97                                  Politics
    ## 9   <NA>  score__row   ai6cp87                                  Religion
    ## 10  <NA>   end_score  /dr9fq65                                      <NA>
    ## 11  <NA>  select_one   or5gr65 Taking_all_things_to_ould_you_say_you_are
    ## 12  <NA>  select_one   uf68v87   All_in_all_how_woul_would_you_say_it_is
    ## 13  <NA>  select_one   ks56k46 Did_you_do_voluntary_in_the_last_6_months
    ## 14  <NA>  select_one   va0xx85    Generally_speaking_dealing_with_people
    ## 15  <NA> begin_score   tb2px63  I_would_like_to_ask_y_much_or_not_at_all
    ## 16  <NA>  score__row   xg6fl64                               Your_family
    ## 17  <NA>  score__row   yj6dy23               People_in_your_neighborhood
    ## 18  <NA>  score__row   ke1im15                People_you_know_personally
    ## 19  <NA>  score__row   wh7ei00        People_you_meet_for_the_first_time
    ## 20  <NA>  score__row   qy1kf43                People_of_another_religion
    ## 21  <NA>  score__row   ip2pc55             People_of_another_nationality
    ## 22  <NA>   end_score  /tb2px63                                      <NA>
    ## 23  <NA>       range   gt1yj76  Some_people_feel_the_your_life_turns_out
    ## 24  <NA>    geopoint   fd0cf28   Please_indicate_wher_the_map_is_Hamburg
    ## 25  <NA>        file   dq0sb99                  Upload_an_arbitrary_file
    ##                                                                                                                                                                                                                                                                                              label
    ## 1                                                                                                                                                                                                                                                                                             NULL
    ## 2                                                                                                                                                                                                                                                                                             NULL
    ## 3                                                                                                                                                                                                                         Please say, for each of the following, how important it is in your life.
    ## 4                                                                                                                                                                                                                                                                                             Work
    ## 5                                                                                                                                                                                                                                                                                           Family
    ## 6                                                                                                                                                                                                                                                                        Friends and acquaintances
    ## 7                                                                                                                                                                                                                                                                                     Leisure time
    ## 8                                                                                                                                                                                                                                                                                         Politics
    ## 9                                                                                                                                                                                                                                                                                         Religion
    ## 10                                                                                                                                                                                                                                                                                            NULL
    ## 11                                                                                                                                                                                                                                              Taking all things together, would you say you are:
    ## 12                                                                                                                                                                                                         All in all, how would you describe your state of health these days? would you say it is
    ## 13                                                                                                                                                                                                                                                 Did you do voluntary work in the last 6 months?
    ## 14                                                                                                                                                                      Generally speaking, would you say that most people can be trusted or that you can't be too careful in dealing with people?
    ## 15                                                                                                   I would like to ask you how much you trust people from various groups. Could you tell me for each whether you trust people from this group completely, somewhat, not very much or not at all?
    ## 16                                                                                                                                                                                                                                                                                     Your family
    ## 17                                                                                                                                                                                                                                                                     People in your neighborhood
    ## 18                                                                                                                                                                                                                                                                      People you know personally
    ## 19                                                                                                                                                                                                                                                              People you meet for the first time
    ## 20                                                                                                                                                                                                                                                                      People of another religion
    ## 21                                                                                                                                                                                                                                                                   People of another nationality
    ## 22                                                                                                                                                                                                                                                                                            NULL
    ## 23 Some people feel they have completely free choice and control over their lives, and other people feel that what they do has no real effect on what happens to them. Please use the scale to indicate how much freedom of choice and control you feel you have over the way your life turns out?
    ## 24                                                                                                                                                                                                                                                   Please indicate where on the map is "Hamburg"
    ## 25                                                                                                                                                                                                                                                                     Upload an arbitrary file...
    ##    required kobo--score-choices select_from_list_name
    ## 1        NA                <NA>                  <NA>
    ## 2        NA                <NA>                  <NA>
    ## 3     FALSE             ys4jh05                  <NA>
    ## 4     FALSE                <NA>                  <NA>
    ## 5     FALSE                <NA>                  <NA>
    ## 6     FALSE                <NA>                  <NA>
    ## 7     FALSE                <NA>                  <NA>
    ## 8     FALSE                <NA>                  <NA>
    ## 9     FALSE                <NA>                  <NA>
    ## 10       NA                <NA>                  <NA>
    ## 11     TRUE                <NA>               rz4sr22
    ## 12    FALSE                <NA>               ve2ix92
    ## 13    FALSE                <NA>               am8gn27
    ## 14    FALSE                <NA>               zl1iq13
    ## 15    FALSE             uy4om18                  <NA>
    ## 16    FALSE                <NA>                  <NA>
    ## 17    FALSE                <NA>                  <NA>
    ## 18    FALSE                <NA>                  <NA>
    ## 19    FALSE                <NA>                  <NA>
    ## 20    FALSE                <NA>                  <NA>
    ## 21    FALSE                <NA>                  <NA>
    ## 22       NA                <NA>                  <NA>
    ## 23    FALSE                <NA>                  <NA>
    ## 24    FALSE                <NA>                  <NA>
    ## 25    FALSE                <NA>                  <NA>
    ##                                      hint            parameters
    ## 1                                    NULL                  <NA>
    ## 2                                    NULL                  <NA>
    ## 3                                    NULL                  <NA>
    ## 4                                    NULL                  <NA>
    ## 5                                    NULL                  <NA>
    ## 6                                    NULL                  <NA>
    ## 7                                    NULL                  <NA>
    ## 8                                    NULL                  <NA>
    ## 9                                    NULL                  <NA>
    ## 10                                   NULL                  <NA>
    ## 11                                   NULL                  <NA>
    ## 12                                   NULL                  <NA>
    ## 13                                   NULL                  <NA>
    ## 14                                   NULL                  <NA>
    ## 15                                   NULL                  <NA>
    ## 16                                   NULL                  <NA>
    ## 17                                   NULL                  <NA>
    ## 18                                   NULL                  <NA>
    ## 19                                   NULL                  <NA>
    ## 20                                   NULL                  <NA>
    ## 21                                   NULL                  <NA>
    ## 22                                   NULL                  <NA>
    ## 23 1 = "None at all", 10 = "a great deal" start=1;end=10;step=1
    ## 24                                   NULL                  <NA>
    ## 25                                   NULL                  <NA>
    ## 
    ## $choices
    ##    name     $kuid                      label list_name $autovalue
    ## 1     1 NPp8OR3md             Very important   ys4jh05          1
    ## 2     2 LnI83gRXp            quite important   ys4jh05          2
    ## 3     3 u6ot3527d              not important   ys4jh05          3
    ## 4     4 gRoco4Pev       not at all important   ys4jh05          4
    ## 5     1 4oLFnV3ws                 Very happy   rz4sr22          1
    ## 6     2 PAmAPsyFM                Quite happy   rz4sr22          2
    ## 7     3 G8ZTNvrsz             Not very happy   rz4sr22          3
    ## 8     4 p2PSwo7yN           Not at all happy   rz4sr22          4
    ## 9     8 ZUOsXVxA0                 Don't know   rz4sr22          8
    ## 10    9 gTT51LFcs                  No answer   rz4sr22          9
    ## 11    1 FSr5OYH5Z                  Very good   ve2ix92          1
    ## 12    2 ePIcIfywO                       Good   ve2ix92          2
    ## 13    3 97eDDuzaO                       Fair   ve2ix92          3
    ## 14    4 BIcgTk7PF                       Poor   ve2ix92          4
    ## 15    5 TI1TEmjKI                  Very poor   ve2ix92          5
    ## 16    8 UPQRPVpZN                 Don't know   ve2ix92          8
    ## 17    9 696pTgkEM                  No answer   ve2ix92          9
    ## 18    1 rhWu34seb                        Yes   am8gn27          1
    ## 19    2 eNbB8K507                         No   am8gn27          2
    ## 20    8 kg9naDqjC                 Don't know   am8gn27          8
    ## 21    9 7AFKIlHDu                  No answer   am8gn27          9
    ## 22    1 IKCXDYXCk Most people can be trusted   zl1iq13          1
    ## 23    2 Jvg4jninb       Can't be too careful   zl1iq13          2
    ## 24    8 VSWHtAmIg                 Don't know   zl1iq13          8
    ## 25    9 Utj6uO20z                  No answer   zl1iq13          9
    ## 26    1 UrdKQbo8g           Trust completely   uy4om18          1
    ## 27    2 mCJO9kEu8             Trust somewhat   uy4om18          2
    ## 28    3 UlmwVnpew     Do not trust very much   uy4om18          3
    ## 29    4 cMmSDIUwH       Do  not trust at all   uy4om18          4
    ## 
    ## $settings
    ## named list()
    ## 
    ## $translated
    ## [1] "hint"  "label"
    ## 
    ## $translations
    ## [1] NA

``` r
surveyObject$settings
```

    ## $sector
    ## $sector$label
    ## [1] "Other"
    ## 
    ## $sector$value
    ## [1] "Other"
    ## 
    ## 
    ## $country
    ## $country$label
    ## [1] "Germany"
    ## 
    ## $country$value
    ## [1] "DEU"
    ## 
    ## 
    ## $description
    ## [1] "Yet another testing form for package development"
    ## 
    ## $`share-metadata`
    ## [1] FALSE

``` r
surveyObject$downloads 
```

    ##   format
    ## 1    xls
    ## 2    xml
    ##                                                                                url
    ## 1 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/?format=json.xls
    ## 2 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/?format=json.xml

``` r
surveyObject$summary
```

    ## $geo
    ## [1] TRUE
    ## 
    ## $labels
    ## [1] "Please say, for each of the following, how important it is in your life."
    ## [2] "Work"                                                                    
    ## [3] "Family"                                                                  
    ## [4] "Friends and acquaintances"                                               
    ## [5] "Leisure time"                                                            
    ## 
    ## $columns
    ## [1] "name"                  "type"                  "label"                
    ## [4] "required"              "kobo--score-choices"   "select_from_list_name"
    ## [7] "hint"                  "parameters"           
    ## 
    ## $languages
    ## [1] NA
    ## 
    ## $row_count
    ## [1] 21
    ## 
    ## $default_translation
    ## NULL

``` r
surveyObject$deployment__links 
```

    ## $url
    ## [1] "https://ee.correlaid.org/y6PKgSLC"
    ## 
    ## $single_url
    ## [1] "https://ee.correlaid.org/single/y6PKgSLC"
    ## 
    ## $single_once_url
    ## [1] "https://ee.correlaid.org/single/71008a4dad5f8c5541759ddb818a5760"
    ## 
    ## $offline_url
    ## [1] "https://ee.correlaid.org/x/y6PKgSLC"
    ## 
    ## $preview_url
    ## [1] "https://ee.correlaid.org/preview/y6PKgSLC"
    ## 
    ## $iframe_url
    ## [1] "https://ee.correlaid.org/i/y6PKgSLC"
    ## 
    ## $single_iframe_url
    ## [1] "https://ee.correlaid.org/single/i/y6PKgSLC"
    ## 
    ## $single_once_iframe_url
    ## [1] "https://ee.correlaid.org/single/i/71008a4dad5f8c5541759ddb818a5760"

``` r
surveyObject$permissions  
```

    ##                                                                                                                          url
    ## 1 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/permission-assignments/pGnVn25TznLDuRD2cXk9EM/?format=json
    ## 2 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/permission-assignments/pVkNG7R8p8DB9QGUChEAnf/?format=json
    ## 3 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/permission-assignments/pKXPkdHGUD9mGRMiWYf68y/?format=json
    ## 4 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/permission-assignments/pTXkUT6tGpJvfzBvREEWcF/?format=json
    ## 5 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/permission-assignments/pMfchFkNuYbgcRqqmShWpr/?format=json
    ## 6 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/permission-assignments/psZMVKDEfee7uPFTfo7HCM/?format=json
    ## 7 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/permission-assignments/pgYtnZ956vAmmXimzqBWQL/?format=json
    ## 8 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/permission-assignments/pPJePYMC3gnRxeDN9hWkGr/?format=json
    ##                                                            user
    ## 1 https://kobo.correlaid.org/api/v2/users/api_user/?format=json
    ## 2 https://kobo.correlaid.org/api/v2/users/api_user/?format=json
    ## 3 https://kobo.correlaid.org/api/v2/users/api_user/?format=json
    ## 4 https://kobo.correlaid.org/api/v2/users/api_user/?format=json
    ## 5 https://kobo.correlaid.org/api/v2/users/api_user/?format=json
    ## 6 https://kobo.correlaid.org/api/v2/users/api_user/?format=json
    ## 7 https://kobo.correlaid.org/api/v2/users/api_user/?format=json
    ## 8 https://kobo.correlaid.org/api/v2/users/api_user/?format=json
    ##                                                                        permission
    ## 1      https://kobo.correlaid.org/api/v2/permissions/add_submissions/?format=json
    ## 2         https://kobo.correlaid.org/api/v2/permissions/change_asset/?format=json
    ## 3   https://kobo.correlaid.org/api/v2/permissions/change_submissions/?format=json
    ## 4   https://kobo.correlaid.org/api/v2/permissions/delete_submissions/?format=json
    ## 5         https://kobo.correlaid.org/api/v2/permissions/manage_asset/?format=json
    ## 6 https://kobo.correlaid.org/api/v2/permissions/validate_submissions/?format=json
    ## 7           https://kobo.correlaid.org/api/v2/permissions/view_asset/?format=json
    ## 8     https://kobo.correlaid.org/api/v2/permissions/view_submissions/?format=json
    ##                  label
    ## 1      Add submissions
    ## 2            Edit form
    ## 3     Edit submissions
    ## 4   Delete submissions
    ## 5       Manage project
    ## 6 Validate submissions
    ## 7            View form
    ## 8     View submissions

``` r
surveyObject$deployed_versions 
```

    ## $count
    ## [1] 2
    ## 
    ## $`next`
    ## NULL
    ## 
    ## $previous
    ## NULL
    ## 
    ## $results
    ##                      uid
    ## 1 vGEYKrPXZhge2uYk4toEKs
    ## 2 vhWtJRry8cSn5PBEda3oDy
    ##                                                                                                            url
    ## 1 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/versions/vGEYKrPXZhge2uYk4toEKs/?format=json
    ## 2 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/versions/vhWtJRry8cSn5PBEda3oDy/?format=json
    ##                               content_hash               date_deployed
    ## 1 9487faea38af0b94b0f165fe6a78b0f4fc8e1aa3 2021-05-02T12:41:36.532642Z
    ## 2 561e3789013d5b0e7ac8939b7ce31a824067aec0 2021-05-02T12:33:25.779708Z
    ##                      date_modified
    ## 1 2021-05-02 12:41:36.532642+00:00
    ## 2 2021-05-02 12:33:25.779708+00:00

``` r
surveyObject$deployment__links 
```

    ## $url
    ## [1] "https://ee.correlaid.org/y6PKgSLC"
    ## 
    ## $single_url
    ## [1] "https://ee.correlaid.org/single/y6PKgSLC"
    ## 
    ## $single_once_url
    ## [1] "https://ee.correlaid.org/single/71008a4dad5f8c5541759ddb818a5760"
    ## 
    ## $offline_url
    ## [1] "https://ee.correlaid.org/x/y6PKgSLC"
    ## 
    ## $preview_url
    ## [1] "https://ee.correlaid.org/preview/y6PKgSLC"
    ## 
    ## $iframe_url
    ## [1] "https://ee.correlaid.org/i/y6PKgSLC"
    ## 
    ## $single_iframe_url
    ## [1] "https://ee.correlaid.org/single/i/y6PKgSLC"
    ## 
    ## $single_once_iframe_url
    ## [1] "https://ee.correlaid.org/single/i/71008a4dad5f8c5541759ddb818a5760"

``` r
surveyObject$deployment__data_download_links 
```

    ## $xls_legacy
    ## [1] "https://kc.correlaid.org/api_user/exports/aRo4wg5utWT7dwdnQQEAE7/xls/"
    ## 
    ## $csv_legacy
    ## [1] "https://kc.correlaid.org/api_user/exports/aRo4wg5utWT7dwdnQQEAE7/csv/"
    ## 
    ## $zip_legacy
    ## [1] "https://kc.correlaid.org/api_user/exports/aRo4wg5utWT7dwdnQQEAE7/zip/"
    ## 
    ## $kml_legacy
    ## [1] "https://kc.correlaid.org/api_user/exports/aRo4wg5utWT7dwdnQQEAE7/kml/"
    ## 
    ## $xls
    ## [1] "https://kc.correlaid.org/api_user/reports/aRo4wg5utWT7dwdnQQEAE7/export.xlsx"
    ## 
    ## $csv
    ## [1] "https://kc.correlaid.org/api_user/reports/aRo4wg5utWT7dwdnQQEAE7/export.csv"

``` r
#surveyObject$report_styles  # commented out because quite long but empty
surveyObject$report_custom  
```

    ## named list()

``` r
surveyObject$map_styles 
```

    ## named list()

``` r
surveyObject$map_custom 
```

    ## named list()

``` r
surveyObject$embeds 
```

    ##   format
    ## 1    xls
    ## 2  xform
    ##                                                                                  url
    ## 1   https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/xls/?format=json
    ## 2 https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/xform/?format=json

``` r
surveyObject$assignable_permissions 
```

    ##                                                                               url
    ## 1           https://kobo.correlaid.org/api/v2/permissions/view_asset/?format=json
    ## 2         https://kobo.correlaid.org/api/v2/permissions/change_asset/?format=json
    ## 3         https://kobo.correlaid.org/api/v2/permissions/manage_asset/?format=json
    ## 4      https://kobo.correlaid.org/api/v2/permissions/add_submissions/?format=json
    ## 5     https://kobo.correlaid.org/api/v2/permissions/view_submissions/?format=json
    ## 6  https://kobo.correlaid.org/api/v2/permissions/partial_submissions/?format=json
    ## 7   https://kobo.correlaid.org/api/v2/permissions/change_submissions/?format=json
    ## 8   https://kobo.correlaid.org/api/v2/permissions/delete_submissions/?format=json
    ## 9 https://kobo.correlaid.org/api/v2/permissions/validate_submissions/?format=json
    ##                                       label
    ## 1                                 View form
    ## 2                                 Edit form
    ## 3                            Manage project
    ## 4                           Add submissions
    ## 5                          View submissions
    ## 6 View submissions only from specific users
    ## 7                          Edit submissions
    ## 8                        Delete submissions
    ## 9                      Validate submissions

Question
--------

``` r
question_url_data <- url_data$question_url
str(question_url_data, max.level = 1)
```

    ## List of 39
    ##  $ url                            : chr "https://kobo.correlaid.org/api/v2/assets/a7AV5JhRHKf8EWGBJLswwC/?format=json"
    ##  $ owner                          : chr "https://kobo.correlaid.org/api/v2/users/api_user/?format=json"
    ##  $ owner__username                : chr "api_user"
    ##  $ parent                         : NULL
    ##  $ ancestors                      : NULL
    ##  $ settings                       : Named list()
    ##  $ asset_type                     : chr "question"
    ##  $ date_created                   : chr "2021-03-20T20:50:19.480897Z"
    ##  $ summary                        :List of 6
    ##  $ date_modified                  : chr "2021-03-20T20:51:13.674659Z"
    ##  $ version_id                     : chr "ve66TcLYqgsfpeQRyA9YZn"
    ##  $ version__content_hash          : chr "682d1ed422869db649902c7dad59104ecde05ac5"
    ##  $ version_count                  : int 2
    ##  $ has_deployment                 : logi FALSE
    ##  $ deployed_version_id            : NULL
    ##  $ deployed_versions              :List of 4
    ##  $ deployment__identifier         : NULL
    ##  $ deployment__links              : Named list()
    ##  $ deployment__active             : logi FALSE
    ##  $ deployment__data_download_links: Named list()
    ##  $ deployment__submission_count   : int 0
    ##  $ report_styles                  :List of 3
    ##  $ report_custom                  : Named list()
    ##  $ map_styles                     : Named list()
    ##  $ map_custom                     : Named list()
    ##  $ content                        :List of 5
    ##  $ downloads                      :'data.frame': 2 obs. of  2 variables:
    ##  $ embeds                         :'data.frame': 2 obs. of  2 variables:
    ##  $ koboform_link                  : chr "https://kobo.correlaid.org/api/v2/assets/a7AV5JhRHKf8EWGBJLswwC/koboform/?format=json"
    ##  $ xform_link                     : chr "https://kobo.correlaid.org/api/v2/assets/a7AV5JhRHKf8EWGBJLswwC/xform/?format=json"
    ##  $ hooks_link                     : chr "https://kobo.correlaid.org/api/v2/assets/a7AV5JhRHKf8EWGBJLswwC/hooks/?format=json"
    ##  $ tag_string                     : chr ""
    ##  $ uid                            : chr "a7AV5JhRHKf8EWGBJLswwC"
    ##  $ kind                           : chr "asset"
    ##  $ xls_link                       : chr "https://kobo.correlaid.org/api/v2/assets/a7AV5JhRHKf8EWGBJLswwC/xls/?format=json"
    ##  $ name                           : chr "Age"
    ##  $ assignable_permissions         :'data.frame': 3 obs. of  2 variables:
    ##  $ permissions                    :'data.frame': 3 obs. of  4 variables:
    ##  $ data                           : chr "https://kobo.correlaid.org/api/v2/assets/a7AV5JhRHKf8EWGBJLswwC/data/?format=json"

### Content

The `content` list shows us more information / metadata about the question:

``` r
question_url_data$content
```

    ## $schema
    ## [1] "1"
    ## 
    ## $survey
    ##    name    type     $kuid $autoname                     hint             label
    ## 1 start   start nYhk8kpZU     start                     NULL              NULL
    ## 2   end     end RwoJDDvfL       end                     NULL              NULL
    ## 3   age integer   fx6oz83       age Please specify your age. what is your age?
    ##   required        constraint
    ## 1       NA              <NA>
    ## 2       NA              <NA>
    ## 3    FALSE . > 0 and . < 120
    ## 
    ## $settings
    ## named list()
    ## 
    ## $translated
    ## [1] "hint"  "label"
    ## 
    ## $translations
    ## [1] NA

This corresponds to the `survey` sheet of the question in XLSForm which we can check by comparing to the XLS downloadable here: <https://kobo.correlaid.org/api/v2/assets/a7AV5JhRHKf8EWGBJLswwC.xls>.

``` r
# TODO: figure out how to download this with R - the downloads data frame has a weird format query argument set to json.xls which probably comes from getting the data with format=json instead of via the browser interface
question_url_data$downloads
```

    ##   format
    ## 1    xls
    ## 2    xml
    ##                                                                                url
    ## 1 https://kobo.correlaid.org/api/v2/assets/a7AV5JhRHKf8EWGBJLswwC/?format=json.xls
    ## 2 https://kobo.correlaid.org/api/v2/assets/a7AV5JhRHKf8EWGBJLswwC/?format=json.xml

``` r
download_url <- question_url_data$downloads %>% filter(format == "xls") %>% pull(url)
```

The `start` and `end` rows are there because Kobo will by default always collect metadata about the start and end of the survey (cf [XLSForm documentation](https://xlsform.org/en/#metadata))

as we saw above in the comparison table, quite a bit of metadata is also contained in the assets data frame.

``` r
common_names <- intersect(names(question_url_data), colnames(assets))
common_names
```

    ##  [1] "url"                          "owner"                       
    ##  [3] "owner__username"              "parent"                      
    ##  [5] "settings"                     "asset_type"                  
    ##  [7] "date_created"                 "summary"                     
    ##  [9] "date_modified"                "version_id"                  
    ## [11] "has_deployment"               "deployed_version_id"         
    ## [13] "deployment__identifier"       "deployment__active"          
    ## [15] "deployment__submission_count" "downloads"                   
    ## [17] "tag_string"                   "uid"                         
    ## [19] "kind"                         "name"                        
    ## [21] "permissions"                  "data"

let's see whether they're actually the same

``` r
question_df <- assets %>% filter(uid == question_url_data$uid)

# for each of the names, extract the object and compare
comparison_df <- common_names %>% 
  map_dfr(function(name) {
    # from assets dataframe
    from_asset <- question_df[[name]]
    from_url_data <- question_url_data[[name]]
    df <- tibble(
      name = name,
      class_asset = class(from_asset),
      length_asset = length(from_asset),
      class_url_data = class(from_url_data),
      is_identical = identical(from_asset, from_url_data))
    df
  })
  
comparison_df 
```

    ## # A tibble: 22 x 5
    ##    name            class_asset length_asset class_url_data is_identical
    ##    <chr>           <chr>              <int> <chr>          <lgl>       
    ##  1 url             character              1 character      TRUE        
    ##  2 owner           character              1 character      TRUE        
    ##  3 owner__username character              1 character      TRUE        
    ##  4 parent          character              1 NULL           FALSE       
    ##  5 settings        data.frame             4 list           FALSE       
    ##  6 asset_type      character              1 character      TRUE        
    ##  7 date_created    character              1 character      TRUE        
    ##  8 summary         data.frame             6 list           FALSE       
    ##  9 date_modified   character              1 character      TRUE        
    ## 10 version_id      character              1 character      TRUE        
    ## # ... with 12 more rows

Look at those which are not identical, they seem to be mostly rooted in differences in serialization (`data.frame` vs `list`):

``` r
question_df$parent
```

    ## [1] NA
