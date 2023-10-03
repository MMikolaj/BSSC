### zmienne wspoldzielone pomiedzy skryptami

## w zależnośći od dnia miesciąca są dostępne już statystyki za ostatni miesiąć lub za dwa miesiące wcześniej
## najpierw próbuje ściągnać za miesiąć poprzedni

 miesiac_do_ekstrakcji <- as.numeric(format(Sys.Date(), "%m"))-1

## nazwa pliku do zapisu statystyk (można pomyslec nad dodaniem do niej daty)

statystyki_filename <- paste0("Data/statystyki_obligacji.xls")

