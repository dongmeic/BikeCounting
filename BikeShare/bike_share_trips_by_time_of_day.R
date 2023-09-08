# This script was created to aggregate bike share trips by day parts
# By Dongmei Chen (dchen@lcog.org)
# On September 7th, 2023

options(warn = -1)
library(stringr)
library(sf)
library(lubridate)
source("C:/Users/clid1852/.0GitHub/BikeCounting/BikeShare/bike_share_functions.R")

path <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeShare/Output"
data <- read.csv(paste0(path, "/Bike_Share_Trips.csv"))
data$Date <- as.Date(data$Date, "%Y-%m-%d")
head(data)

data$Hour <- sapply(data$Time, function(x) convert_time_to_hour(x))
data$DayPart <- sapply(data$Hour, function(x) get_parts_of_day(x))
names(data)[which(names(data) == 'OriginDestination')] <- 'OrgDst'
Origin_dt <- agg_data()
Destination_dt <- agg_data(by="Destination")
Origin_spdf <- df2spdf(Origin_dt, 'Longitude', 'Latitude')
Destination_spdf <- df2spdf(Destination_dt, 'Longitude', 'Latitude')
st_write(st_as_sf(Origin_spdf), dsn=path, layer="Origin_Bike_Share_DayPart", driver="ESRI Shapefile", delete_layer=TRUE)
st_write(st_as_sf(Destination_spdf), dsn=path, layer="Destination_Bike_Share_DayPart", driver="ESRI Shapefile", delete_layer=TRUE)
