library(jsonlite)
library(googledrive)
library(googlesheets4)
library(gargle)

access_token <- jsonlite::fromJSON(Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS"))

names(access_token)

library(gargle)
options(gargle_oauth_cache = ".secrets")
gargle::gargle_oauth_cache()



gs4_auth(scope = "https://www.googleapis.com/auth/drive")
drive_auth(token = gs4_token())

drive_find("screener-obligacji")

ss <- drive_get("screener-obligacji")

read_sheet(ss)

write_sheet(mtcars, ss, sheet = "mtcars")

# drive_auth()
# gs4_auth(token = drive_token())
#
# drive_user()
#
# drive_find("screener-obligacji")


