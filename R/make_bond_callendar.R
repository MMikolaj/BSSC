
source("C://Dropbox/R_projs/gielda/R/funs.R")

daty_wyplat_w_details <- read.csv("Data/daty_wyplat_obligacji_w_details.csv")

daty_wyplat_to_calendar<- daty_wyplat_w_details %>%
  transmute(start = as.Date(date),
         summary=paste(Ticker, numer_wyplaty),
         description=paste("Ticker:", Ticker, "<br>",
                           "Emitent:", Emitent, "<br>",
                           "Data wykupu:", Data.wykupu, "<br>",
                           "Wartość nominalna:", Wartosc.nominalna, "<br>",
                           "Wartość emisji:", Wartosc.emisji,"<br>",
                           "Waluta obligacji:", Waluta, "<br>",
                           "Oprocentowanie:", Oprocentowanie)

  )



apply(daty_wyplat_to_calendar, 1, post_event,
      callendar_id = select_calendar_id("Obligacje Catalyst"),
      start = "start",
      summary = "summary",
      description = "description")

