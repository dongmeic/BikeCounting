# This script was created to organize the bike share trips data by day parts
# By Dongmei Chen (dchen@lcog.org)
# On August 9th, 2023

library(lubridate)
library(stringr)
library(dplyr)
library(sf)
library(sp)
source("C:/Users/clid1852/.0GitHub/BikeCounting/BikeShare/bike_share_functions.R")

path <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeShare"
inpath <- paste0(path, "/Data/Trips")
outpath <- paste0(path, "/Output")
year = "2022"
df <- get_yearly_data("2022")
ndf <- organize_yearly_data(df)
#write.csv(ndf, paste0(outpath, "/Bike_Share_Trips.csv"), row.names = FALSE)
#MPOBound <- st_read(dsn = "X:/Data/Transportation", layer="MPO_Bound")
# spdf <- df2spdf(ndf, 'Longitude', 'Latitude')
# st_write(st_as_sf(spdf), dsn = outpath, layer = "Bike_Share_Trips", 
#          driver = "ESRI Shapefile", delete_layer = TRUE)

aggdata <- aggregate_data_daily(ndf)
write.csv(aggdata, paste0(outpath, "/Daily_Bike_Share_Trips.csv"), row.names = FALSE)

agg_spdf <- df2spdf(aggdata, 'Longitude', 'Latitude')
st_write(st_as_sf(agg_spdf), dsn = outpath, layer = "Daily_Bike_Share_Trips", 
         driver = "ESRI Shapefile", delete_layer = TRUE) # ignore the warning message

sum_avg_df <- summarize_data_daily(aggdata)
write.csv(sum_avg_df, paste0(outpath, "/Sum_Bike_Share_Trips.csv"), row.names = FALSE)

sum_avg_spdf <- df2spdf(sum_avg_df, 'Longitude', 'Latitude')
st_write(st_as_sf(sum_avg_spdf), dsn = outpath, layer = "Sum_Bike_Share_Trips", 
         driver = "ESRI Shapefile", delete_layer = TRUE)
