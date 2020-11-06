# handling_missing_data_labor_bureau.r
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

# plot the series as column plot
random_unemployed %>%
  ggplot(aes(x = date, y = rate)) +
    geom_col()
    
# plot the series as geom_line
random_unemployed %>%
  ggplot(aes(x = date, y = rate)) +
  geom_line()

# fill the values in different col to see differences
# in time series
random_unemployed_fill <-
  random_unemployed %>%
  mutate(rate_fill = rate) %>%
  fill(rate_fill)

# plot the series as column plot with the fileld values
random_unemployed_fill %>%
  ggplot() +
  geom_line(aes(x = date, y = rate_fill), color = 'red') +
  geom_line(aes(x = date, y = rate), color = 'black')

# plot the series as geom_line with the filled values
random_unemployed_fill %>%
  ggplot(aes(x = date, y = rate)) +
  geom_line()

# plot true vs filled values 
ggplot() +
    geom_point(aes(x = unemployed$rate, y = random_unemployed_fill$rate_fill))


# a window that avoids lookahead when doing
# rolling mean
roll_window_no_lookahead <- function(x) {
  if (!is.na(x[3])) {
    return(x[3])
  }
  else {
    return(mean(x, na.rm = TRUE))
  }
}
random_unemployed_fill %>%
  mutate(rate_roll_avg = rollapply(c(NA, NA, rate), 3, roll_window_no_lookahead))


# rolling mean with a lookahead
roll_window_with_lookahead <- function(x) {
  if (!is.na(x[2]))
    return(x[2])
  else
    return(mean(x, na.rm = TRUE))
}
random_unemployed_fill %>%
  mutate(rate_roll_avg = rollapply(c(NA, rate, NA), 3, roll_window_with_lookahead))


# linear interpolation imputation
random_unemployed_fill <-
  random_unemployed_fill %>%
  mutate(rate_li = na.approx(rate, rule = 0))

# polynomial interpolation
random_unemployed_fill <-
  random_unemployed_fill %>%
  mutate(rate_sp = na.spline(rate))
