# resampling_data_labor_bureau.r
# load libraries
library(tidyverse)
library(data.table)
library(readxl)
library(zoo)

# load data
unemployed <- read_excel(
  'data/input/labor_bureau/labor_bureau_1949_2020.xlsx',
  skip = 11
)

# tolower colnames
colnames(unemployed) <-
  colnames(unemployed) %>%
  tolower()


# gather month columns
unemployed <-
  unemployed %>%
  gather(key = 'month', value = 'rate', jan:dec)

# convert month names to month numbers
unemployed <-
  unemployed %>%
  mutate(month = match(month, tolower(month.abb)))

# concatenate month and year
unemployed <-
  unemployed %>%
  mutate(date = paste(month, year, sep = '/'))

# parse to datetime format
unemployed <-
  unemployed %>%
  mutate(date = parse_datetime(date, '%m/%Y'))

# deselect wrangling cols
unemployed <-
  unemployed %>%
  select(date, rate)

# sort by date
unemployed <-
  unemployed %>%
  arrange(date)

# generate random NA values
# in the tibbles
# first make random indexes
random_unemployed_idx <-
  sample(1:nrow(unemployed), .10 * nrow(unemployed))
# now make this indexes NAs on the rate column
random_unemployed <-
  unemployed %>%
  mutate(rate = ifelse(row_number() %in% random_unemployed_idx, NA, rate))


unemployed_datatbl <-
  data.table(unemployed)
rand_unemp_databl <-
  data.table(random_unemployed)

# downsample data to get rate for every january
unemployed_datatbl[seq.int(from = 1, to = nrow(unemployed_datatbl), by = 12)]

# summarize rate by year
unemployed_datatbl[, mean(rate), by = format(date, '%Y')]

# UPSAMPLING
# irregular time series

