library(tidyr)
library(dplyr)
library(purrr)
library(rvest)
load("Data/shared_data/tickery.RData")

## daty wyplat
## wyszukuje pelnej tabeli zawierajacej daty wyplat

daty_wyplaty <- tickery %>%
  map_df(~read_html(paste0("https://obligacje.pl/pl/obligacja/", .x)) %>%
           html_nodes(xpath=".//h4[contains(.,'wypłaty')]/following-sibling::div[1]") %>%
           html_elements("li") %>%
           html_text() %>%
           as.Date() %>%
           data.frame("Ticker"=.x, "date"=.),
         .progress=T
  )



### obligacje.pl dane

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

### to jest potrzebne do kalendarza (NA RAZIE POMIJAM)

# daty_wyplat_w_details <-  left_join(daty_wyplaty,
#                                    select(catalyst_table, Ticker, Emitent=`Nazwa emitenta`,
#                                           `Data wykupu`, `Wartosc nominalna`, `Wartosc emisji`, Waluta)) %>%
#                           left_join(.,
#                                    select(obligacjepl_table, Ticker, Oprocentowanie=`Typ oprocentowania:`)) %>%
#                           group_by(Ticker) %>%
#                           mutate(numer_wyplaty = paste("#",seq_along(Ticker)))



save(daty_wyplaty,
     # daty_wyplat_w_details, (ODKOMENTOWAC POZNIEJ)
     obligacjepl_table, file="Data/shared_data/obligacje_pl_data.RData")

