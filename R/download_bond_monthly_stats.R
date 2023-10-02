source("R/variables.R")
library(httr)
library(lubridate)



## statystyki transakcji z ostatniego miesiaca
## najpierw scigam możliwie najnowszy plik ze statystykami miesiecznymi


## customowa funkcja do pobrania i zapisu pliku ze statystykami

download_statystyki_miesieczne <- function(miesiac, filename){


  path <- paste0("https://gpwcatalyst.pl/pub/CATALYST/statystyki/statystyki_miesieczne/20230",
                 miesiac,
                 "_CAT.xls")


  download.file(path,
                destfile =paste0(filename)#,mode = "wget"
                )


}



# testuje czy można ściagnać statystyki z poprzedniego miesiaca (na początku nowego miesiaca mogę być jeszcze niedostępne)
# jeśli nie ma pliku dla miesiaca poprzedniego, sciaga z miesiaca wcześniejszego
## najpierw potrzebuje zrobić zapytanie do strony, jesli zwroci 404 to znaczy ze pliku nie ma i musze sprobowac dla miesiaca wczesniejszego

head <- httr::HEAD(paste0("https://gpwcatalyst.pl/pub/CATALYST/statystyki/statystyki_miesieczne/20230",
                          miesiac_do_ekstrakcji,
                          "_CAT.xls"))

head

if(grepl(pattern = "404", head$url)) {

  download_statystyki_miesieczne(miesiac_do_ekstrakcji-1, statystyki_filename)

  ## pomocniczna zmienna, ktora pozniej przyda sie do nagłówka kolumny w tabeli ze statystykami
  ## miesiac do ekstacji to miesiac juz o jeden wczesniej niz obecna data zatem wyzej wystarczy tylko odjac jeden
  miesiac_rok_statystyk <-  format(Sys.Date()- months(2), "%B %Y")

} else {

  download_statystyki_miesieczne(miesiac_do_ekstrakcji, statystyki_filename)

  miesiac_rok_statystyk <-  format(Sys.Date()- months(1), "%B %Y")
}

