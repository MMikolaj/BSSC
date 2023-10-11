library(tidyr)
library(dplyr)
library(purrr)
library(rvest)
library(stringr)

cat("Pakiety wczytane")

## helper fun ####
get_catalyst_table <- function(x){

  res <-  read_html(paste("https://gpwcatalyst.pl/", x, sep=''))  %>%
    html_elements("table") %>%
    html_table() %>%
    .[[2]] %>%
    pivot_wider(names_from = X1, values_from = X2) %>%
    unnest(cols=everything())

  return(res)

}

get_catalyst_table <- possibly(.f= get_catalyst_table, otherwise = NA)

cat("Funkcja gotowa")
#### ekstrakcja z catalyst


catalyst_korporacyjne <- "https://gpwcatalyst.pl/notowania-obligacji-obligacje-korporacyjne"
catalyst_korporacyjne

read_html(catalyst_korporacyjne)
print("read dziala")
# wyszykuje podstron dla każdego tickera
catalyst_korporacyjne_podstrony <- read_html(catalyst_korporacyjne) %>%
  html_elements(".table-responsive .col1") %>%
  html_node("a") %>%
  html_attr("href")

catalyst_korporacyjne_podstrony
#
# catalyst_skarbowe<- "https://gpwcatalyst.pl/notowania-obligacji-obligacje-skarbowe"
#
# ## wyszykuje podstron dla każdego tickera
# catalyst_skarbowe_podstrony <- read_html(catalyst_skarbowe) %>%
#   html_elements(".table-responsive .col1") %>%
#   html_node("a") %>%
#   html_attr("href")
#
# catalyst_podstrony <- c(catalyst_korporacyjne_podstrony, catalyst_skarbowe_podstrony)
#
#
# ## filtruje puste linki
# catalyst_podstrony <- catalyst_podstrony[which(!is.na(catalyst_podstrony))]
#
# print(catalyst_podstrony)
#
# ## wyciągam same tickery z wektora z adresami podstron
# tickery <- str_split(catalyst_podstrony, "=", simplify = T)[,2]
#
# print(tickery)

## dla każdego tickera wyciagam tabele z danymi i całość łącze w jedna tabele



### get table ####
# catalyst_table <- map(catalyst_podstrony[1:10], ~ get_catalyst_table(.x), .progress=T)
#
# catalyst_table <- bind_rows(catalyst_table)
#
# catalyst_table <- bind_cols(Ticker=tickery, catalyst_table)
#
# catalyst_table <- catalyst_table %>%
#   mutate(
#     `Wartosc nominalna` = coalesce(`Wartość nominalna (PLN)`, `Wartość nominalna (EUR)`),
#     `Wartosc emisji` = coalesce(`Wartość emisji (PLN)`, `Wartość emisji (EUR)`),
#     `Odsetki skumulowane` = coalesce(`Odsetki skumulowane (wartość w PLN)`,`Odsetki skumulowane (wartość w EUR)`),
#     Waluta = ifelse(!is.na(`Wartość nominalna (PLN)`),"PLN",
#                     ifelse(!is.na(`Wartość emisji (EUR)`), "EUR", "nieznana"))) %>%
#   select(-contains("EUR"), -contains("PLN"))
#
# catalyst_table
########################################################################################################
########################################################################################################
### obligacje.pl

## daty wyplat
## wyszukuje pelnej tabeli zawierajacej daty wyplat
#
# daty_wyplaty <- tickery %>%
#   map_df(~read_html(paste0("https://obligacje.pl/pl/obligacja/", .x)) %>%
#            html_nodes(xpath=".//h4[contains(.,'wypłaty')]/following-sibling::div[1]") %>%
#            html_elements("li") %>%
#            html_text() %>%
#            as.Date() %>%
#            data.frame("Ticker"=.x, "date"=.),
#          .progress=T
#   )
#
# #####  obligacjep.pl dane #############
#
# obligacjepl_table <- tickery %>%
#   map_df(~read_html(paste0("https://obligacje.pl/pl/obligacja/", .x)) %>%
#            html_elements("table") %>%
#            html_table()  %>%
#            .[[1]] %>%
#            pivot_wider(names_from = X1, values_from = X2) %>%
#            unnest(cols=everything()),
#          .progress=T
#   )
#
# obligacjepl_table <- bind_cols(Ticker=tickery, obligacjepl_table)
#
#

### combining all together

### to jest potrzebne do kalendarza (NA RAZIE POMIJAM)

# daty_wyplat_w_details <-  left_join(daty_wyplaty,
#                                    select(catalyst_table, Ticker, Emitent=`Nazwa emitenta`,
#                                           `Data wykupu`, `Wartosc nominalna`, `Wartosc emisji`, Waluta)) %>%
#                           left_join(.,
#                                    select(obligacjepl_table, Ticker, Oprocentowanie=`Typ oprocentowania:`)) %>%
#                           group_by(Ticker) %>%
#                           mutate(numer_wyplaty = paste("#",seq_along(Ticker)))



# save(tickery,
#      catalyst_table,
#      # daty_wyplaty,
#      # daty_wyplat_w_details, (ODKOMENTOWAC POZNIEJ)
#      # obligacjepl_table,
#      file="Data/shared_data/obligacje_data.RData")


