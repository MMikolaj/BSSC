library(tidyr)
library(dplyr)
library(stringr)
library(readxl)

source("R/variables.R")

load("Data/shared_data/catalyst_table.RData")
load("Data/shared_data/obligacje_pl_data.RData")
## ok udało sie pobrac statystyki teraz musze wyciagac z nich dane

sheet <- "notowania"
print(sheet)
print(statystyki_filename)

## najpierw wyciagam tylko pierwsza kolumne, zeby odczytac z niej pozycje kolejnych kategorii obligacji (korporacyjne, skarbowe itd)
statystyki_col1 <- readxl::read_excel(path = statystyki_filename, sheet=sheet, range = cellranger::cell_cols(1), col_names = F) %>%
  .[,1] %>%
  unlist() %>%
  as.vector()

## wyciagam pozycje wierszy dla kolejnych kategorii
statystyki_korporacyjne_start <- which(grepl("korpo", statystyki_col1))
statystyki_korporacyjne_end <- which(grepl("spółdzielcze", statystyki_col1))
statystyki_skarbowe_start <- which(grepl("skarbowe", statystyki_col1))
statystyki_skarbowe_end <- which(grepl("Listy zastawne hipoteczne", statystyki_col1))

##
## wyciagam rok i miesiac statytyk z pierwszej zakladki excelki
miesiac_rok_statystyk <- readxl::read_excel(path=statystyki_filename, sheet = "ogółem", range="A6", col_names = F) %>% pull

## ok teraz wyciagam  odpowiednie dane
statystyki_dane <-
  readxl::read_excel(
    statystyki_filename,
    sheet = sheet,
    range = cellranger::cell_rows(c(seq(from=(statystyki_korporacyjne_start+3), to=(statystyki_korporacyjne_end-1), by=1),
                                    seq(from=(statystyki_skarbowe_start+3), to=(statystyki_skarbowe_end-1), by=1))),
    col_names = F
  )

colnames(statystyki_dane) <- c("Kod_ISIN", "Ticker", "Rynek", "Waluta_notowania", "Wolumen", "N_transakcji", "N_dni_z_transakcjami", "Obroty_tys_PLN", "Obroty_tys_EUR", "Pakietowe_Wolumen", "Pakietowe_N_transakcji", "Pakietowe_wartosc_obrotu_tys_PLN")



obligacje_final_table <- left_join(catalyst_table,
                                  select(obligacjepl_table, Ticker, `Rynek:`,`Typ oprocentowania:`, `Zabezpieczenie:`)) %>%
                        left_join(., select(statystyki_dane, Ticker,  N_transakcji, N_dni_z_transakcjami, Obroty_tys_PLN, Obroty_tys_EUR)) %>%
                         left_join(., last_and_next_payment_dates)

### uporządkować


obligacje_final_table_pop <- obligacje_final_table %>%
  mutate(`Typ oprocentowania`=sub("stałe |zmienne ", "", `Typ oprocentowania:`)) %>%
  separate(`Typ oprocentowania:`, into=c("WIBOR", "Oprocentowanie"), sep=" \\+ ") %>%
  mutate(Oprocentowanie = ifelse(is.na(Oprocentowanie), WIBOR, Oprocentowanie),
         WIBOR = str_remove(WIBOR, "\\d%|\\d\\.\\d*%"),
         Obroty_tys_EUR=ifelse(Obroty_tys_PLN==Obroty_tys_EUR,NA, Obroty_tys_EUR ),
         Obroty_tys=coalesce(Obroty_tys_PLN, Obroty_tys_PLN)
         # Waluta = ifelse(!is.na(`Wartość nominalna (PLN)`), "PLN", "EUR"),
         # `Wartość nominalna`=coalesce(`Wartość nominalna (PLN)`, `Wartość nominalna (EUR)`),
         # `Wartość emisji`=coalesce(`Wartość emisji (PLN)`, `Wartość emisji (EUR)`),
         # `Odsetki skumulowane` = coalesce(`Odsetki skumulowane (wartość w PLN)`, `Odsetki skumulowane (wartość w EUR)`),
         # `Odsetki skumulowane`=sub(",", ".", `Odsetki skumulowane`)
  ) %>%
  select(Ticker, `Nazwa emitenta`,Waluta,`Rynek`=`Rynek:`,`Wartosc nominalna`,
         `Data poprzedniej wypłaty`=Data_poprzedniej_wyplaty,`Data nastepnej wypłaty`= Data_najblizszej_wyplaty,
         `Rodzaj oprocentowania obligacji`, WIBOR,Oprocentowanie,`Oprocentowanie w bieżącym okresie odsetkowym (%)`, `Odsetki skumulowane`,
         `Liczba transakcji`=N_transakcji, `Liczba dni z transakcjami`=N_dni_z_transakcjami, `Obroty [tys.]`=Obroty_tys,
         `Data autoryzacji`, `Data pierwszego notowania`,`Data wykupu`,`Wartosc emisji`,
         `Zabezpieczenie`=`Zabezpieczenie:`,`Strona www emitenta`) %>%
  rename_with(.fn = ~paste(., miesiac_rok_statystyk), .cols = c(`Liczba transakcji`, `Liczba dni z transakcjami`, `Obroty [tys]`))

print(head(obligacje_final_table_pop))

write.csv(obligacje_final_table_pop, paste0("Data/obligacje_final_table",".csv"), row.names = F)

