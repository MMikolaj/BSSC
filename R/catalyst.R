library(tidyverse)
library(rvest)

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


catalyst <- "https://gpwcatalyst.pl/notowania-obligacji-obligacje-korporacyjne"

## wyszykuje podstron dla każdego tickera
catalyst_podstrony <- read_html(catalyst) %>%
  html_elements(".table-responsive .col1") %>%
  html_node("a") %>%
  html_attr("href")

## filtruje puste linki
catalyst_podstrony <- catalyst_podstrony[which(!is.na(catalyst_podstrony))]

## wyciągam same tickery z wektora z adresami podstron
tickery <- str_split(catalyst_podstrony, "=", simplify = T)[,2]

save(tickery, file="Data/shared_data/tickery.RData")


## dla każdego tickera wyciagam tabele z danymi i całość łącze w jedna tabele

get_catalyst_table <- possibly(.f= get_catalyst_table, otherwise = NA)

### get table ####
catalyst_table <- map(catalyst_podstrony, ~ get_catalyst_table(.x), .progress=T)

catalyst_table <- bind_rows(catalyst_table)

catalyst_table <- bind_cols(Ticker=tickery, catalyst_table)

catalyst_table <- catalyst_table %>%
  mutate(
    `Wartosc nominalna` = coalesce(`Wartość nominalna (PLN)`, `Wartość nominalna (EUR)`),
    `Wartosc emisji` = coalesce(`Wartość emisji (PLN)`, `Wartość emisji (EUR)`),
    `Odsetki skumulowane` = coalesce(`Odsetki skumulowane (wartość w PLN)`,`Odsetki skumulowane (wartość w EUR)`),
    Waluta = ifelse(!is.na(`Wartość nominalna (PLN)`),"PLN",
                    ifelse(!is.na(`Wartość emisji (EUR)`), "EUR", "nieznana"))) %>%
  select(-contains("EUR"), -contains("PLN"))

save(catalyst_table, file="Data/shared_data/catalyst_table.RData")


