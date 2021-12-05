#' get dwd url
#'
#' Returns url for raw files
#'
#' @importFrom magrittr %>%
#' @importFrom stringr str_ends
#' @import dplyr
#' @import rvest
get_dwd_url <- function() {
  url_base <- "https://opendata.dwd.de/climate_environment/CDC/derived_germany/techn/monthly/heating_degreedays/hdd_3807/"

  url_files_historical <- read_html(paste0(url_base, "historical/")) %>%
    html_elements("a") %>%
    html_text() %>%
    .[stringr::str_ends(string = ., "csv")] %>%
    paste0(url_base, "historical/", .)
  url_files_recent <- read_html(paste0(url_base, "recent/")) %>%
    html_elements("a") %>%
    html_text() %>%
    .[str_ends(string = ., "csv")] %>%
    paste0(url_base, "recent/", .)

  c(url_files_historical, url_files_recent)
}


#' Download a single month from DWD server
#'
#' @param url url to the file on dwd server
#'
#' @importFrom lubridate ymd
#' @importFrom magrittr %>%
#' @importFrom readr read_delim
#' @importFrom tsibble yearmonth
download_dwd_data_single_file <- function(url) {
  cat("\nDownload", url, "\n")

  read_delim(file = url, delim = ";", skip = 3, trim_ws = TRUE) %>%
    select(id = `#ID`, lon = `geogr. Laenge`, lat = `geogr. Breite`,
               station = Station, year_month = Monat,
               monthly_degree_days = Monatsgradtage,
               n_hdd = `Anzahl Heiztage`) %>%
    mutate(id = as.integer(id),
           lon = as.numeric(lon),
           lat = as.numeric(lat),
           year_month = yearmonth(ymd(paste(year_month, "01"))),
           monthly_degree_days = as.numeric(monthly_degree_days))
}


#' get monthly hdd
#'
#' DWD Climate Data Center (CDC): Recent monthly degree days according
#' to VDI 3807 for Germany, quality control not completed yet, version v19.3
#'
#' @importFrom purrr map_dfr
#'
#' @export
download_dwd_data <- function() {
  url <- get_dwd_url()
  map_dfr(url, download_dwd_data_single_file)
}


#' tidy hdd
#'
#' Some opinionated tidying of the heating degree days dataframe:
#' * convert to tsibble
#' * keep only stations with sufficient data (completeness ≥ threshold)
#'
#' @param df_hdd dataframe from function get_montly_hdd
#' @param threshold keep only stations with sufficient data (completeness ≥ threshold)
#'
#' @importFrom magrittr %>%
#' @import dplyr
#' @import tsibble
#'
#' @export
#' @md
tidy_hdd <- function(df_hdd, threshold = 0.95) {
  df_hdd %>%
    as_tsibble(index = year_month, key = id) %>%
    # keep only stations with sufficient data (completeness ≥ threshold)
    group_by_key() %>%
    mutate(n = n()) %>%
    ungroup() %>%
    filter(n >= threshold*max(n)) %>%
    select(-n)
}


#' Calculate Monthly Mean
#'
#' Calculate monthly mean for given period
#'
#' @param df_hdd dataframe from function get_montly_hdd; should be tidyed before
#' @param from first year
#' @param to last year
#'
#' @importFrom lubridate month
#' @importFrom magrittr %>%
#' @importFrom tsibble yearmonth
#' @import dplyr
#'
#' @export
calc_monthly_mean <- function(df_hdd, from = 2011, to = 2020) {
  df_hdd %>%
    filter(year_month >= yearmonth(paste0(from, "-1-1")),
           year_month <= yearmonth(paste0(to, "-12-1"))) %>%
    mutate(month = month(year_month)) %>%
    as_tibble() %>%
    group_by(id, station, month) %>%
    summarise(monthly_mean = mean(monthly_degree_days), .groups = 'keep') %>%
    ungroup()
}
