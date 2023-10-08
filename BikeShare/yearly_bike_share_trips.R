# This script was created to organize the yearly bike share trips data
# By Dongmei Chen (dchen@lcog.org)
# On September 5th, 2023

library(lubridate)
library(stringr)
library(dplyr)
library(sf)
library(sp)
source("C:/Users/clid1852/.0GitHub/BikeCounting/BikeShare/bike_share_functions.R")

path <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeShare"
inpath <- paste0(path, "/Data/Trips")
outpath <- paste0(path, "/Output")

df <- get_data_multiyears(2019:2022)
ndf <- organize_yearly_data(df)
#write.csv(ndf, paste0(outpath, "/Bike_Share_Trips_all_years.csv"), row.names = FALSE)

#aggdata_daily <- aggregate_data_daily(ndf)

aggdata_yearly <- aggregate_data_yearly(ndf)
write.csv(aggdata_yearly, paste0(outpath, "/Yearly_Bike_Share_Trips.csv"), row.names = FALSE)

agg_spdf <- df2spdf(aggdata_yearly, 'Longitude', 'Latitude')
st_write(st_as_sf(agg_spdf), dsn = outpath, layer = "Yearly_Bike_Share_Trips", 
         driver = "ESRI Shapefile", delete_layer = TRUE)  # ignore the warning message

sum_avg_df <- summarize_aggdata(aggdata_yearly)
write.csv(sum_avg_df, paste0(outpath, "/Sum_Bike_Share_Trips_all_years.csv"), row.names = FALSE)

sum_avg_spdf <- df2spdf(sum_avg_df, 'Longitude', 'Latitude')
st_write(st_as_sf(sum_avg_spdf), dsn = outpath, layer = "Sum_Bike_Share_Trips_all_years", 
         driver = "ESRI Shapefile", delete_layer = TRUE)
