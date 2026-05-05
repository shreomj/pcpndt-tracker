library(rvest)
library(dplyr)
library(googlesheets4)
library(httr)

gs4_auth(path = "credentials.json")

url <- "https://pcpndt.karnataka.gov.in/Dashboard/Default.aspx"

page <- tryCatch({
  
  res <- RETRY(
    "GET",
    url,
    user_agent("Mozilla/5.0"),
    add_headers("Accept-Language" = "en-US,en;q=0.9"),
    times = 5,
    pause_base = 2,
    timeout(60)
  )
  
  print(status_code(res))
  stop_for_status(res)
  
  read_html(res)
  
}, error = function(e) {
  message("ERROR in scraping: ", e$message)
  quit(status = 1)
})

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
  "https://docs.google.com/spreadsheets/d/1kKm5xRHEClQFR-yRurSJAadaXDmYxfTOSs6jqwU7LjY/edit",
  df
)