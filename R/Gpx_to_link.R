library(tidyverse)
library(here)
library(XML)
library(lubridate)
library(ggmap)
library(geosphere)


# parse GPX file
path_tmp <- paste0( here("reference", "AnelloMontalto_panchinone.gpx"))
parsed <- htmlTreeParse(file = path_tmp, useInternalNodes = TRUE)
# get values via via the respective xpath
coords <- xpathSApply(parsed, path = "//trkpt", xmlAttrs)
elev   <- xpathSApply(parsed, path = "//trkpt/ele", xmlValue)
ts_chr <- xpathSApply(parsed, path = "//trkpt/time", xmlValue)

# combine into df
# Sys.timezone(location = TRUE)
dat_df <- data.frame(
    ts_POSIXct = ymd_hms(ts_chr, tz = "Europe/Rome"),
    lat = as.numeric(coords["lat",]),
    lon = as.numeric(coords["lon",]),
    elev = as.numeric(elev)
)
head(dat_df)


# compute distance (in meters) between subsequent GPS points
dat_df <-
    dat_df %>%
    mutate(lat_lead = lead(lat)) %>%
    mutate(lon_lead = lead(lon)) %>%
    rowwise() %>%
    mutate(dist_to_lead_m = distm(c(lon, lat), c(lon_lead, lat_lead), fun = distHaversine)[1,1]) %>%
    ungroup()

# compute time elapsed (in seconds) between subsequent GPS points
dat_df <-
    dat_df %>%
    mutate(ts_POSIXct_lead = lead(ts_POSIXct)) %>%
    mutate(ts_diff_s = as.numeric(difftime(ts_POSIXct_lead, ts_POSIXct, units = "secs")))

# compute metres per seconds, kilometres per hour
dat_df <-
    dat_df %>%
    mutate(speed_m_per_sec = dist_to_lead_m / ts_diff_s) %>%
    mutate(speed_km_per_h = speed_m_per_sec * 3.6)

# remove some columns we won't use anymore
dat_df <-
    dat_df %>%
    select(-c(lat_lead, lon_lead, ts_POSIXct_lead, ts_diff_s))
head(dat_df) %>% as.data.frame()


# plot elevation ----------------------------------------------------------
plt_elev <-
    ggplot(dat_df, aes(x = ts_POSIXct, y = elev)) +
    geom_line() +
    labs(x = "Time", y = "Elevation [m]") +
    theme_grey(base_size = 14)
plt_elev


# Plot speed --------------------------------------------------------------
plt_speed_km_per_h <-
    ggplot(dat_df, aes(x = ts_POSIXct, y = speed_km_per_h)) +
    geom_line() +
    labs(x = "Time", y = "Speed [km/h]") +
    theme_grey(base_size = 14)
plt_speed_km_per_h


# Plot run path -----------------------------------------------------------
plot(x = dat_df$lon, y = dat_df$lat,
     type = "l", col = "blue", lwd = 3,
     xlab = "Longitude", ylab = "Latitude")


# Plot run path {ggmap}-----------------------------------------------------------


# google API --------------------------------------------------------------
#https://console.cloud.google.com/google/maps-apis/credentials?project=woven-grail-384817
# stored in Renviron

# get the map background
bbox <- make_bbox(range(dat_df$lon), range(dat_df$lat))
dat_df_map <- get_googlemap(center = c(mean(range(dat_df$lon)), mean(range(dat_df$lat))), zoom = 14)
# no Google token alternative:
# dat_df_map <- get_map(bbox, maptype = "toner-lite", source = "stamen")

# data frame to add distance marks
dat_df_dist_marks <-
    dat_df %>%
    mutate(dist_m_cumsum = cumsum(dist_to_lead_m)) %>%
    mutate(dist_m_cumsum_km_floor = floor(dist_m_cumsum / 1000)) %>%
    group_by(dist_m_cumsum_km_floor) %>%
    filter(row_number() == 1, dist_m_cumsum_km_floor > 0)

# generate plot
plt_path_fancy <-
    ggmap(dat_df_map) +
    geom_point(data = dat_df, aes(lon, lat, col = elev),
               linewidth = 1, alpha = 0.5) +
    geom_path(data = dat_df, aes(lon, lat),
              linewidth = 0.3) +
    geom_label(data = dat_df_dist_marks, aes(lon, lat, label = dist_m_cumsum_km_floor),
               linewidth = 3) +
    labs(x = "Longitude",
         y = "Latitude",
         color = "Elev. [m]",
         title = "Anello Montalto Pavese dal panchinone")
plt_path_fancy
