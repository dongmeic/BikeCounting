# This script was created to organize the bike share trips data by day parts
# By Dongmei Chen (dchen@lcog.org)
# On August 9th, 2023

library(lubridate)
library(stringr)
library(dplyr)
library(sf)
source("C:/Users/clid1852/.0GitHub/BikeCounting/BikeShare/bike_share_functions.R")

path <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeShare"
inpath <- paste0(path, "/Data/Trips")
outpath <- paste0(path, "/Output")
year = "2022"
files <- list.files(inpath)[grep(year, list.files(inpath))]

selected_vars <- c('User.ID', 'Route.ID', 'Start.Hub', 
                   'Start.Latitude', 'Start.Longitude',
                   'Start.Date', 'Start.Time', 
                   'End.Hub', 'End.Latitude', 'End.Longitude',
                   'End.Date', 'End.Time', 'Bike.ID', 'Bike.Name',
                   'Distance..Miles.', 'Duration')

for(file in files){
  #print(file)
  if(file == files[1]){
    df <- read.csv(paste0(inpath, "/", file))
    df <- df[, selected_vars]
  }else{
    ndf <- read.csv(paste0(inpath, "/", file))
    ndf <- ndf[, selected_vars]
    df <- rbind(df, ndf)
  }
}

excludedIDs <- c(717565, 742339, 764038, 819845, 1228447, 
                 1354709, 1897910, 2184703, 2207685)
df <- df[!(df$User.ID %in% excludedIDs),]

df$Minutes <- unlist(lapply(df$Duration, function(x) toMinutes(x)))
df <- df[!(df$Start.Latitude == " - " | df$Start.Longitude == " - " | df$End.Latitude == " - " | df$End.Longitude == "- "), ]
cols <- c("Start.Latitude", "Start.Longitude", "End.Latitude", "End.Longitude")
df <- df %>%
  mutate(across(all_of(cols), function(x) as.numeric(x)))

mdf <- df[(df$Start.Latitude >= 43.97865 & df$Start.Latitude <= 44.16123) & 
            (df$Start.Longitude >= -123.2321 & df$Start.Longitude <= -122.8281) & 
            (df$End.Latitude >= 43.97865 & df$End.Latitude <= 44.16123) &
            (df$End.Longitude >= -123.2321 & df$End.Longitude <= -122.8281), ]

mdf <- mdf[!(mdf$Start.Longitude == mdf$End.Longitude & mdf$Start.Latitude == mdf$End.Latitude),]
ndf <- organize_points(mdf)
ndf$Date <- as.Date(ndf$Date, "%Y-%m-%d")
ndf$Weekday <- as.character(wday(ndf$Date, label=TRUE, abbr=FALSE))
ndf$Month <- months(ndf$Date)
ndf$Season <- ifelse(ndf$Month %in% c("December", "January", "February"), "Winter",
                     ifelse(ndf$Month %in% c("March", "April", "May"), "Spring",
                            ifelse(ndf$Month %in% c("June", "July", "August"), "Summer", "Fall")))
ndf$SeasonOrder <- ifelse(ndf$Season == "Spring", 1, 
                          ifelse(ndf$Season == "Summer", 2, 
                                 ifelse(ndf$Season == "Fall", 3, 4)))
ndf$WeekdayOrder <- ifelse(ndf$Weekday == "Monday", 1, 
                           ifelse(ndf$Weekday == "Tuesday", 2, 
                                  ifelse(ndf$Weekday == "Wednesday", 3, 
                                         ifelse(ndf$Weekday == "Thursday", 4, 
                                                ifelse(ndf$Weekday == "Friday", 5, 
                                                       ifelse(ndf$Weekday == "Saturday", 6, 7))))))
ndf$Year <- year(ndf$Date)
write.csv(ndf, paste0(outpath, "/Bike_Share_Trips.csv"), row.names = FALSE)
#MPOBound <- st_read(dsn = "X:/Data/Transportation", layer="MPO_Bound")
spdf <- df2spdf(ndf, 'Longitude', 'Latitude')
st_write(st_as_sf(spdf), dsn = outpath, layer = "Bike_Share_Trips", 
         driver = "ESRI Shapefile", delete_layer = TRUE)

datedf <- unique(ndf[,c("Date", "Month", "Season", "Weekday", "SeasonOrder", "WeekdayOrder")])
datedf$MonthOrder <- ifelse(datedf$Month == "January", 1, 
                            ifelse(datedf$Month == "February", 2, 
                                   ifelse(datedf$Month == "March", 3, 
                                          ifelse(datedf$Month == "April", 4, 
                                                 ifelse(datedf$Month == "May", 5, 
                                                        ifelse(datedf$Month == "June", 6, 
                                                               ifelse(datedf$Month == "July", 7, 
                                                                      ifelse(datedf$Month == "August", 8, 
                                                                             ifelse(datedf$Month == "September", 9, 
                                                                                    ifelse(datedf$Month == "October", 10, 
                                                                                           ifelse(datedf$Month == "November", 11, 12)))))))))))
locdf <- unique(ndf[,c("Location", "Latitude", "Longitude", "OriginDestination")])
stations <- read.csv("C:/Users/clid1852/.0GitHub/BikeCounting/BikeMap/BikeShareStations.csv")
stations$name <- str_replace(stations$name, " @", ",")
stations$City <- ifelse(stations$name %in% c('PeaceHealth RiverBend', 'RiverBend Annex', 'Heartfelt House'), "Springfield", "Eugene")
names(stations) <- c("StationID", "Location", "Longitude", "Latitude", "City")
nlocdf <- ndf[!(ndf$Location %in% stations$Location), c("Location", "Longitude", "Latitude")]
nlocdf$StationID <- NA
nlocdf <- nlocdf[,c("StationID", "Location", "Longitude", "Latitude")]
nlocdf <- unique(nlocdf) 
for(loc in unique(nlocdf$Location)){
  nlocdf[nlocdf$Location == loc,"Longitude"] <- mean(nlocdf[nlocdf$Location == loc,"Longitude"])
  nlocdf[nlocdf$Location == loc,"Latitude"] <- mean(nlocdf[nlocdf$Location == loc,"Latitude"])
}
nlocdf <- unique(nlocdf)
nlocspdf <- df2spdf(nlocdf, 'Longitude', 'Latitude')
ugb <- st_read(dsn = "T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeCounts/ReviewBikeCounts/ReviewBikeCounts.gdb",
               layer = "CLMPO_UGB")
ugb <- st_transform(ugb, 3857)
inside.polygon <- over(nlocspdf, as(ugb[,"ugbcityname"], 'Spatial'))
nlocdf$City <- inside.polygon$ugbcityname
hub_df <- ndf[ndf$Location %in% stations$Location,]
dim(hub_df)
unique(hub_df$OriginDestination)
aggdata <- aggregate(x=list(NoTrips = hub_df$RouteID, NoUsers = hub_df$UserID), 
                     by=list(Date = hub_df$Date, Location = hub_df$Location), 
                     FUN=function(x) length(x))
aggdata <- merge(aggdata, get_aggdata(df=hub_df, OrgDst="Origin"), by=c("Location", "Date"))
aggdata <- merge(aggdata, get_aggdata(df=hub_df, OrgDst="Destination"), by=c("Location", "Date"))
aggdata <- merge(aggdata, stations, by="Location")
aggdata <- merge(aggdata, datedf, by="Date")
write.csv(aggdata, paste0(outpath, "/Daily_Bike_Share_Trips.csv"), row.names = FALSE)
sumdf <- aggregate(x=list(NoTrips = aggdata$NoTrips, 
                          NoUsers = aggdata$NoUsers, 
                          OrgTrips = aggdata$OrgTrips, 
                          OrgUsers = aggdata$OrgUsers, 
                          DstTrips = aggdata$DstTrips, 
                          DstUsers = aggdata$DstUsers), 
                   by=list(Location = aggdata$Location), 
                   FUN=sum)
avgdf <- aggregate(x=list(AvgNoTrips = aggdata$NoTrips, 
                          AvgNoUsers = aggdata$NoUsers), 
                   by=list(Location = aggdata$Location), 
                   FUN=mean)
sumdf$PctTrips <- (sumdf$OrgTrips / sumdf$NoTrips) * 100
sumdf$PctUsers <- (sumdf$OrgUsers / sumdf$NoUsers) * 100
sumdf <- merge(sumdf, stations, by="Location")
sum_avg_df <- merge(sumdf, avgdf, by="Location")
write.csv(sum_avg_df, paste0(outpath, "/Sum_Bike_Share_Trips.csv"), row.names = FALSE)
agg_spdf <- df2spdf(aggdata, 'Longitude', 'Latitude')
st_write(st_as_sf(agg_spdf), dsn = outpath, layer = "Daily_Bike_Share_Trips", 
         driver = "ESRI Shapefile", delete_layer = TRUE)
sum_avg_spdf <- df2spdf(sum_avg_df, 'Longitude', 'Latitude')
st_write(st_as_sf(sum_avg_spdf), dsn = outpath, layer = "Sum_Bike_Share_Trips", 
         driver = "ESRI Shapefile", delete_layer = TRUE)
