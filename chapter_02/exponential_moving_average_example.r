# exponential_moving_average_example.r

# The EMA is a very handy tool. It lets us calculate an average over
# recent data. But, unlike a Simple Moving Average, we don't
# have to keep a window of samples around—we can update an
# EMA "online," one sample at a time
# But the perennial question is: how do you start an EMA?
# First, here are a couple of wrong ways.
# Let's assume that we have incoming data that looks like this:

id <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
x <- c(1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0)
exp <- tibble(id, x)



# The most straight-forward way to start an EMA is
# to simply let it take on some arbitrary constant (usually 0) as
# its initial value. This means the first values that the
# EMA returns will be biased towards this constant, and we have
# to feed in enough samples to "warm it up" before we can get
# decent numbers out.
ema_ord_0 <- function (r) {
  s <- 0
  list(
    update = function (x) {
      s <<- r * s + (1 - r) * x
    }
  )
}

m0 <- ema_ord_0(0.7)
y0 <- c()
for (i in 1:length(exp$x)) {
  y0[i] <- m0$update(exp$x[i])
}

exp <- exp %>%
  mutate(y = y0)

# plotting original and ord0 smoothing
ggplot(data = exp) +
  geom_point(aes(x = id, y = x)) +
  geom_line(aes(x = id, y = x)) +
  geom_point(aes(x = id, y = y0), color = 'red') +
  geom_line(aes(x = id, y = y0), color = 'red')

# The common alternative is to take the first sample as the
# initial value for the EMA. Code for that looks like:
ema_ord_1 <- function(r) {
  started <- FALSE
  s <- NULL
  list(
    update = function(x) {
      if (!started) {
        started <<- TRUE
        s <<- x
      }
      else {
        s <<- r * s + (1 - r) * x
      }
    }
  )
}

m1 <- ema_ord_1(0.7)
y1 <- c()
for (i in 1:length(x)) {
  y1[i] <- m1$update(exp$x[i])
}

exp <-
  exp %>%
  mutate(y1 = y1)

ggplot(data = exp) +
  geom_point(aes(x = id, y = x)) +
  geom_line(aes(x = id, y = x)) +
  geom_point(aes(x = id, y = y0), color = 'red') +
  geom_line(aes(x = id, y = y0), color = 'red') +
  geom_point(aes(x = id, y = y1), color = 'green') +
  geom_line(aes(x = id, y = y1), color = 'green')


ema_ord_correct <- function(r) {
  s <- 0
  extra <- 1
  list(
    update = function(x) {
      s <<- r * s + (1 - r) * x
      extra <<- r * extra
      s / (1 - extra)
    }
  )
}

m2 <- ema_ord_correct(0.5)
y2 <- c()
for (i in 1:length(x)) {
  y2[i] <- m2$update(exp$x[i])
}

exp <-
  exp %>%
  mutate(y2 = y2)

ggplot(data = exp) +
  geom_point(aes(x = id, y = x)) +
  geom_line(aes(x = id, y = x)) +
  geom_point(aes(x = id, y = y0), color = 'red') +
  geom_line(aes(x = id, y = y0), color = 'red') +
  geom_point(aes(x = id, y = y1), color = 'green') +
  geom_line(aes(x = id, y = y1), color = 'green') +
  geom_point(aes(x = id, y = y2), color = 'blue') +
  geom_line(aes(x = id, y = y2), color = 'blue')
