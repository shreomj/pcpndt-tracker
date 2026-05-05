library(rvest)
library(dplyr)
library(googlesheets4)

gs4_auth(path = "credentials.json")

library(httr)
library(rvest)

url <- "https://pcpndt.karnataka.gov.in/Dashboard/Default.aspx"

page <- read_html(
  GET(url, user_agent("Mozilla/5.0"))
)

df <- page %>%
  html_table(fill = TRUE) %>%
  .[[1]] %>%
  filter(District != "Total") %>%
  rename(
    district = District,
    f_form_scans = `Form-F Count`
  ) %>%
  mutate(
    f_form_scans = as.numeric(f_form_scans),
    time = Sys.time()
  )

sheet_append(
  "https://docs.google.com/spreadsheets/d/e/2PACX-1vR-pe0R7h5kOnfEcGCP5GClLXNgMAelKI58QQdj1nXSlRgGubP3hvpk9iaR7OLVzOWlVZAMMZdcTruL/pubhtml",
  df
)

#https://docs.google.com/spreadsheets/d/1kKm5xRHEClQFR-yRurSJAadaXDmYxfTOSs6jqwU7LjY/edit?usp=sharing
#https://docs.google.com/spreadsheets/d/e/2PACX-1vR-pe0R7h5kOnfEcGCP5GClLXNgMAelKI58QQdj1nXSlRgGubP3hvpk9iaR7OLVzOWlVZAMMZdcTruL/pubhtml