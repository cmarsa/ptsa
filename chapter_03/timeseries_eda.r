# timeseries_eda.r

# load packages
library(tidyverse)

# exlpore a typical time series in R:
# EuStockMarkets
head(EuStockMarkets)
plot(EuStockMarkets)

# a multiple time series object
class(EuStockMarkets)


# ts objects also have a few convenience functions:
frequency(EuStockMarkets)

# start and end to find the first and last time
# represented in the series
start(EuStockMarkets)
end(EuStockMarkets)

# window to take a temporal selection of the data
window(EuStockMarkets, start = 1997, end = 1998)

# There are pluses and minuses to the ts class. As mentioned earlier,ts and its deriva‐
# tive classes are used in many time series packages. Also, automatic setup of plotting
# parameters can be helpful. However, indexing can sometimes be tricky, and the
# process of accessing subsections of data with window can feel cumbersome over time.


#
# -------------------------------- HISTOGRAMS --------------------------------
#
# We’d like to, for example, take a histogram of the data, just as with
# most exploratory data analysis. We add a wrinkle by also taking a histogram of the
# differenced data because we want to use our time axis
hist(EuStockMarkets[, "SMI"], 30)
hist(diff(EuStockMarkets[, "SMI"], 30))

#  The histogram of the untransformed data (top) is extremely wide and does
# not show a normal distribution. This is to be expected given that the underlying data
# has a trend. We difference the data to remove the trend, and this transforms the data to
# a more normally shaped distribution (bottom).

# In a time series context, a hist() of the difference of the data is often more interest‐
# ing than a hist() of the untransformed data. After all, in a time series context, often
# (and particularly in finance) what is most interesting is how a value changes from one
# measurement to the next rather than the value’s actual measurement. This is particu‐
# larly true for plotting, because taking the histogram of data with a trend in it does not
# produce a very informative visualization.


#
# -------------------------------- SCATTER PLOTS --------------------------------
#
# The traditional method of using scatter plots is just as useful for time series data as it
# is for other kinds of data. We can use scatter plots to determine both how two stocks
# are linked at a specific time and how their price shifts are related over time
plot(EuStockMarkets[, "SMI"], EuStockMarkets[, "DAX"])
plot(diff(EuStockMarkets[, "SMI"]), diff(EuStockMarkets[, "DAX"]))

# The values of two different stocks over time
# The values of the daily changes in these two stocks over time (via differencing)
# with R’s diff() function


