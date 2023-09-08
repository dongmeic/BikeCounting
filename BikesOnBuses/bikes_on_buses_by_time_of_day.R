# This script was created to aggregate bikes on buses by day parts
# By Dongmei Chen (dchen@lcog.org)
# On September 6th, 2023

options(warn = -1)

library(lubridate)
library(stringr)
library(sf)
source("C:/Users/clid1852/.0GitHub/BikeCounting/BikesOnBuses/bikes_on_buses_functions.R")
outpath <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeOnBuses/Output"
most_recent <- 2022
data <- readExcel(year=most_recent)
data$year <- year(data$date)
data$hour <- sapply(data$trip_end, function(x) convert_time_to_hour(x))
data$DayPart <- sapply(data$hour, function(x) get_parts_of_day(x))
inbound_dt <- agg_data()
outbound_dt <- agg_data(by="O")
inbound_spdf <- df2spdf(inbound_dt, 'longitude', 'latitude')
outbound_spdf <- df2spdf(outbound_dt, 'longitude', 'latitude')

st_write(st_as_sf(inbound_spdf), dsn=outpath, layer="Inbound_BOB_DayPart", 
         driver="ESRI Shapefile", delete_layer=TRUE)
st_write(st_as_sf(outbound_spdf), dsn=outpath, layer="Outbound_BOB_DayPart", 
         driver="ESRI Shapefile", delete_layer=TRUE)