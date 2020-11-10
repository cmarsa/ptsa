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
# 
# The apparent correlations in Figure 3-3 are interesting, but even if they are true cor‐
# relations (and there is reason to doubt they are), these are not correlations we can
# monetize as stock traders. By the time we know whether a stock is going up or down,
# the stocks it is correlated with will have also gone up or down, since we are taking
# correlations of values at identical time points. What we need to do is find out whether
# the change in one stock earlier in time can predict the change in another stock later
# in time. To do this, we shift one of the differences of the stocks back by 1 before look‐
# ing at the scatter plot. Read the following code carefully; notice that we are still differ‐
# encing, but now we are also applying a lag to one of the differenced time series
plot(stats::lag(diff(EuStockMarkets[, "SMI"]), 1),
     diff(EuStockMarkets[, "DAX"]))

# This result tells us a number of important things:
#   • With time series data, while we may use the same exploratory techniques as with
# non-time-series data, mindless application won’t work. We need to think about
# how to exploit the same techniques but with reshaped data.
# • Oftentimes it’s the relationship between data at different points or the change
# over time that is most informative about how your data behaves.
# • The plot in Figure 3-4 shows why it can be difficult to be a stock trader. If you are
# a passive investor and wait it out, you might benefit from the long-term rising
# trend. However, if you are trying to make predictions about the future, you can
# see that it’s not easy!
  

# R’s lag() function may not move data in the temporal direction
# you expect. The lag() function is a forward time shift. This is
# important to remember, as you wouldn’t want to move data in the
# wrong temporal direction given a specific use case, and both for‐
# ward and backward shifts in time are reasonable for different use
# cases.


#
# -------------------------------- ROLLING WINDOWS --------------------------------
#
# A common function distinct to time series is a window function, which is any sort of
# function where you aggregate data either to compress it  or to smooth it
# In addition to the applications already discussed, smoothed data and windowaggregated data make for informative exploratory visualizations.
# We can calculate a moving average and other calculations that involve some linear
# function of a series of points with base R’s filter() function, as follows:
x <- rnorm(n = 100, mean = 0, sd = 10) + 1:100
mn <- function(n) {
  return(rep(1 / n, n))
}

plot(x, type = 'l', lwd = 1)
lines(stats::filter(x, mn(5)), col = 2, lwd = 3, lty = 2)
lines(stats::filter(x, mn(50)), col = 3, lwd = 3, lty = 3)      

# ^^^^
# Two exploratory curves produced via a rolling mean smoothing. We might
# use these to look for a trend in particularly noisy data or to decide what sorts of devia‐
# tions from linear behavior are interesting to investigate versus which are likely just
# noise.      
# 
# If we are looking for functions that are not linear combinations of all points in the
# window, we can’t use filter() because it relies on a linear transformation of the
# data. However, we can use zoo. The rollapply() function from the zoo package is
# quite handy

library(zoo)
f1 <- rollapply(zoo(x), 20,
                function(w) min(w),
                align = 'left',
                partial = TRUE)
f2 <- rollapply(zoo(x), 20, function(w) min(w),
                align = 'right', partial = TRUE)

plot(x, lwd = 1, type = 'l')
lines(f1, col = 2, lwd = 3, lty = 2)
lines(f2, col = 3, lwd = 3, lty = 3)


# If you look into base R, you will realize that many functions already exist as imple‐
# mentations of an expanding window, such as cummax and cummin. You can also easily
# repurpose cumsum to create a cumulative mean. In the following plot, we show both
# an expanding window max and an expanding window mean
plot(x, type = 'l', lwd = 1)
lines(cummax(x), col = 2, lwd = 3, lty = 2)
lines(cumsum(x) / 1:length(x), col = 3, lwd = 3, lty = 3)

# If you need a custom function with a rolling window, you can use rollapply() as we
# did for a rolling window. In this case, you need to specify a sequence of window sizes
# rather than a single scalar. 
plot(x, type = 'l', lwd = 1)
lines(rollapply(zoo(x), seq_along(x), function(w) max(w),
                partial = TRUE, align = 'right'),
      col = 2, lwd = 3, lty = 2)
lines(rollapply(zoo(x), seq_along(x), function(w) mean(w),
                partial = TRUE, align = 'right'),
      col = 3, lwd = 3, lty = 3)
