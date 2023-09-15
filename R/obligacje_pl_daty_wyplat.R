library(tidyverse)
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


## ostatnia wyplata i najblizsza


## przetwarzam tabele z datami wyplat korzystajac z funkcji pomocniczej
last_and_next_payment_dates <-full_join(
  daty_wyplaty %>% filter(date>Sys.Date()) %>% group_by(Ticker) %>% top_n(-1) %>% rename(Data_najblizszej_wyplaty=date),
  daty_wyplaty %>% filter(date<Sys.Date()) %>% group_by(Ticker) %>% top_n(1) %>% rename(Data_poprzedniej_wyplaty=date)
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

### to jest potrzebne do kalendarza

daty_wyplat_w_details <-  left_join(daty_wyplaty,
                                   select(catalyst_table, Ticker, Emitent=`Nazwa emitenta`,
                                          `Data wykupu`, `Wartosc nominalna`, `Wartosc emisji`, Waluta)) %>%
                          left_join(.,
                                   select(obligacjepl_table, Ticker, Oprocentowanie=`Typ oprocentowania:`)) %>%
                          group_by(Ticker) %>%
                          mutate(numer_wyplaty = paste("#",seq_along(Ticker)))



save(daty_wyplat_w_details,obligacjepl_table,last_and_next_payment_dates, file="Data/shared_data/obligacje_pl_data.RData")

