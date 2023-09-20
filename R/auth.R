

access_token <- jsonlite::fromJSON(Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS"))

names(access_token)

library(gargle)
options(gargle::gargle_oauth_cache = ".secrets")
gargle::gargle_oauth_cache()
