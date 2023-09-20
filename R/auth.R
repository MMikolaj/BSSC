# library(package="googledrive")
# library(package="googlesheets4")
# library(gargle)
#
# googledrive::drive_auth(email="mikolajmazurkiewicz.90@gmail.com",   path = "unique-hash-365212-04f4baaa8232.json")
# gs4_auth_configure(client=gargle_oauth_client_from_json("client_secret_547108325504-m8ug42uhlfjbi37262pftuujndn93q3a.apps.googleusercontent.com.json")
# , api_key = "AIzaSyDpNroog8BnN0UAo-smm2_Klwy1Hu2y-QU")
#
# gs4_browse(ss="mtcat")
# # gs4_auth_configure(path = "client_secret_547108325504-m8ug42uhlfjbi37262pftuujndn93q3a.apps.googleusercontent.com.json")
#
# gs4_api_key()
# gs4_
# gs4_create(
#   "mtcat",
#   sheets = list(mtcars = mtcars)
# )
#
# gs4_user(
#
#
# )

access_token <- jsonlite::fromJSON(Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS"))

names(access_token)

library(gargle)
options(gargle::gargle_oauth_cache = ".secrets")
gargle::gargle_oauth_cache()
