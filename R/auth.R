library(jsonlite)
library(googledrive)
library(googlesheets4)
library(gargle)

access_token <- jsonlite::fromJSON(Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS"))

names(access_token)

library(gargle)
options(gargle_oauth_cache = ".secrets")
gargle::gargle_oauth_cache()

drive_auth()
gs4_auth(token = drive_token())

drive_user()

drive_find("screener-obligacji") %>%
  sheet_write(mtcars, sheet = "mtcars")


df <- data.frame(x = 1:3, y = letters[1:3])



ss <- gs4_create("testy-hedgehog", sheets = df)

sheet_write(ss)
