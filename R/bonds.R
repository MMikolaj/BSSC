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

## daty wyplat
## wyszukuje pelnej tabeli zawierajacej daty wyplat

daty_wyplaty <- tickery[1] %>%
  map_df(~read_html(paste0("https://obligacje.pl/pl/obligacja/", .x)) %>%
        html_nodes(xpath=".//h4[contains(.,'wypłaty')]/following-sibling::div") %>%
        html_elements("li") %>%
        html_text() %>%
        as.Date() %>%
        data.frame("ticker"=.x, "date"=.)
  )



