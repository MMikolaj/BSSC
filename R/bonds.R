library(tidyverse)
library(rvest)


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


## dla każdego tickera wyciagam tabele z danymi i całość łącze w jedna tabele

## helpes fun ####
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

write.csv(catalyst_table, "Data/catalyst_table.csv", row.names = F)


## daty wyplat
## wyszukuje pelnej tabeli zawierajacej daty wyplat

daty_wyplaty <- tickery %>%
  map_df(~read_html(paste0("https://obligacje.pl/pl/obligacja/", .x)) %>%
           html_nodes(xpath=".//h4[contains(.,'wypłaty')]/following-sibling::div") %>%
           html_elements("li") %>%
           html_text() %>%
           as.Date() %>%
           data.frame("Ticker"=.x, "date"=.)
  )


### obligacje.pl

obligacjepl_table <- tickery %>%
  map_df(~read_html(paste0("https://obligacje.pl/pl/obligacja/", .x)) %>%
           html_elements("table") %>%
           html_table()  %>%
           .[[1]] %>%
           pivot_wider(names_from = X1, values_from = X2) %>%
           unnest(cols=everything()),
         .progress=T
  )

obligacjepl_table <- bind_cols(Ticker=tickery, obligacjepl_table)

### combining all together

daty_wyplat_w_details <- left_join(daty_wyplaty,
                                   select(catalyst_table, Ticker, Emitent=`Nazwa emitenta`,
                                          `Data wykupu`, `Wartosc nominalna`, `Wartosc emisji`, Waluta)
                                   )

daty_wyplat_w_details <- left_join(daty_wyplat_w_details,
          select(obligacjepl_table, Ticker, Oprocentowanie=`Typ oprocentowania:`))

daty_wyplat_w_details <- daty_wyplat_w_details %>%
  group_by(Ticker) %>%
  mutate(numer_wyplaty = paste("#",seq_along(Ticker)))



write.csv(daty_wyplat_w_details, "Data/daty_wyplat_obligacji_w_details.csv", row.names = F)

