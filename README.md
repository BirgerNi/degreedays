
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- `devtools::build_readme()` -->

# degreedays

<!-- badges: start -->

[![R-CMD-check](https://github.com/BirgerNi/degreedays/workflows/R-CMD-check/badge.svg)](https://github.com/BirgerNi/degreedays/actions)
<!-- badges: end -->

The goal of degreedays is to download heating degree days from weather
stations throughout Germany from DWD Climate Data Center (CDC) and
provide some convenience functions.

Data set description:

Recent monthly degree days according to VDI 3807 for Germany, quality
control not completed yet, version v19.3, last accessed: 2021-12-02.

More information may be found on the
[opendata-server](https://opendata.dwd.de/climate_environment/CDC/derived_germany/techn/monthly/heating_degreedays/hdd_3807/recent/DESCRIPTION_derivgermany_techn_monthly_heating_degreedays_hdd_3807_recent_en.pdf).

## Installation

You can install the development version of degreedays from GitHub.

``` r
# install.packages("devtools")
devtools::install_github("BirgerNi/degreedays")
```

## Usage

You can download the whole data set with `download_dwd_data`.

``` r
library(degreedays)
df <- download_dwd_data()
df
```

    #> # A tibble: 70,635 × 7
    #>       id   lon   lat station                year_month monthly_degree_days n_hdd
    #>    <int> <dbl> <dbl> <chr>                       <mth>               <dbl> <dbl>
    #>  1     3  6.09  50.8 AACHEN (WEWA)            2010 Jan                643.    31
    #>  2    44  8.24  52.9 GROSSENKNETEN            2010 Jan                703.    31
    #>  3    71  8.98  48.2 ALBSTADT-BADKAP          2010 Jan                742.    31
    #>  4    73 13.0   48.6 ALDERSBACH-KRIESTORF     2010 Jan                722.    31
    #>  5    78  7.91  52.5 ALFHAUSEN                2010 Jan                703.    31
    #>  6    91  9.34  50.7 ALSFELD-EIFA             2010 Jan                731.    31
    #>  7   102  8.13  53.9 ALTE WESER (AWST)        2010 Jan                677.    31
    #>  8   131 12.9   51.1 ALTGERINGSWALDE          2010 Jan                776.    31
    #>  9   142 11.3   48.4 ALTOMUENSTER-MAISBRUNN   2010 Jan                725.    31
    #> 10   150  8.12  49.7 ALZEY                    2010 Jan                690.    31
    #> # … with 70,625 more rows

You may want to convert data to tsibble and keep only complete or almost
complete data sets.

``` r
tidy_hdd(df, threshold = 0.95)
#> # A tsibble: 62,187 x 7 [1M]
#> # Key:       id [440]
#>       id   lon   lat station       year_month monthly_degree_days n_hdd
#>    <int> <dbl> <dbl> <chr>              <mth>               <dbl> <dbl>
#>  1    44  8.24  52.9 GROSSENKNETEN   2010 Jan               703.     31
#>  2    44  8.24  52.9 GROSSENKNETEN   2010 Feb               569.     28
#>  3    44  8.24  52.9 GROSSENKNETEN   2010 Mär               458      31
#>  4    44  8.24  52.9 GROSSENKNETEN   2010 Apr               320.     28
#>  5    44  8.24  52.9 GROSSENKNETEN   2010 Mai               298.     29
#>  6    44  8.24  52.9 GROSSENKNETEN   2010 Jun                93.7    14
#>  7    44  8.24  52.9 GROSSENKNETEN   2010 Jul                 0       0
#>  8    44  8.24  52.9 GROSSENKNETEN   2010 Aug                42.9     6
#>  9    44  8.24  52.9 GROSSENKNETEN   2010 Sep               192.     25
#> 10    44  8.24  52.9 GROSSENKNETEN   2010 Okt               309.     27
#> # … with 62,177 more rows
```

Calculate the monthly mean for a given period with
`calc_monthly_mean()`.

``` r
df %>%
  tidy_hdd(threshold = 0.95) %>%
  calc_monthly_mean(from = 2006, to = 2020)
#> # A tibble: 5,306 × 4
#>       id station       month monthly_mean
#>    <int> <chr>         <dbl>        <dbl>
#>  1    44 GROSSENKNETEN     1        556. 
#>  2    44 GROSSENKNETEN     2        492. 
#>  3    44 GROSSENKNETEN     3        453. 
#>  4    44 GROSSENKNETEN     4        307. 
#>  5    44 GROSSENKNETEN     5        193. 
#>  6    44 GROSSENKNETEN     6         71.9
#>  7    44 GROSSENKNETEN     7         34.5
#>  8    44 GROSSENKNETEN     8         31.9
#>  9    44 GROSSENKNETEN     9        142. 
#> 10    44 GROSSENKNETEN    10        278. 
#> # … with 5,296 more rows
```
