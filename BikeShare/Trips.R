# This script was created to organize bike share trips data
# By Dongmei Chen (dchen@lcog.org)
# On January 23th, 2022

library(lubridate)
source("T:/DCProjects/GitHub/RLearning/geocoding_functions.R")

inpath <- "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/Trips"
outpath <- "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/Output/review"
  
files <- list.files(inpath)
fileso <- list.files(outpath)
#files[which(!(files %in% fileso))]
  

selected_vars <- c('User.ID', 'Route.ID', 'Start.Hub', 
                   'Start.Latitude', 'Start.Longitude',
                   'Start.Date', 'Start.Time', 
                   'End.Hub', 'End.Latitude', 'End.Longitude',
                   'End.Date', 'End.Time', 'Bike.ID', 'Bike.Name',
                   'Distance..Miles.', 'Duration')

#test <- read.csv("T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/trips_2019-05-01_2019-05-31.csv")

########################################### Collect Data ###############################################
organize_points <- function(trips){
  #trips <- read.csv(paste0(inpath, "/", file))
  org <- trips[,c('Route.ID', 'Bike.ID', 'User.ID', 
                  'Start.Hub', 'Start.Latitude', 'Start.Longitude',
                  'Start.Date', 'Start.Time', 'Path.ID',
                  'Distance..Miles.', 'Minutes')]
  names(org) <- c("RouteID", "BikeID", 'UserID',
                  "Location", "Latitude", "Longitude",
                  "Date", "Time", 'PathID',
                  'Distance', 'Minutes')
  org$OriginDestination <- rep("Origin", dim(org)[1])
  dst <- trips[,c('Route.ID', 'Bike.ID', 'User.ID', 'End.Hub',
                  'End.Latitude', 'End.Longitude',
                  'End.Date','End.Time', 'Path.ID',
                  'Distance..Miles.', 'Minutes')]
  names(dst) <- c("RouteID", "BikeID", 'UserID',
                  "Location", "Latitude", "Longitude", 
                  "Date", "Time", 'PathID',
                  'Distance', 'Minutes')
  dst$OriginDestination <- rep("Destination", dim(dst)[1])
  df <- rbind(org, dst)
  return(df)
}

toMinutes <- function(x){
  h <- as.numeric(strsplit(x, ":")[[1]][1])
  m <- as.numeric(strsplit(x, ":")[[1]][2])
  s <- as.numeric(strsplit(x, ":")[[1]][3])
  
  res <- h*60 + m + s/60
  
  return(res)
}

#file = files[1]
#geocode_hubs <- function(file){
  df1 <- read.csv(paste0(inpath, "/", file))
  df1 <- df1[df1$Start.Latitude != " - " | df1$Start.Longitude != " - " | df1$End.Latitude != " - " | df1$End.Longitude != " - ",]
  df2 <- df1[df1$Start.Hub != "" & df1$End.Hub != "", selected_vars]
  df3 <- df1[df1$Start.Hub == "" & df1$End.Hub != "", selected_vars]
  df4 <- df1[df1$Start.Hub != "" & df1$End.Hub == "", selected_vars]
  
  starthub_google_crd <- df3[ , c("Start.Latitude", "Start.Longitude")]
  
  ptm <- proc.time()
  for(i in 1:dim(starthub_google_crd)[1]){
    df3$Start.Hub[i] <- unlist(strsplit(rev_geocode_google(starthub_google_crd[i,], api_key)$address,","))[1]
    print(paste(i, df3$Start.Hub[i]))
  }
  proc.time() - ptm
  
  df3$Start.Hub <- str_remove(df3$Start.Hub, "Eugene: ")
  
  endhub_google_crd <- df4[ , c("End.Latitude", "End.Longitude")]
  
  ptm <- proc.time()
  for(i in 1:dim(endhub_google_crd)[1]){
    df4$End.Hub[i] <- unlist(strsplit(rev_geocode_google(endhub_google_crd[i,], api_key)$address,","))[1]
    print(paste(i, df4$End.Hub[i]))
  }
  proc.time() - ptm
  
  df4$End.Hub <- str_remove(df4$End.Hub, "Eugene: ")
  
  df5 <- rbind(df2, df3)
  df6 <- rbind(df5, df4)
  return(df6)
}

#for(file in files){
  df <- geocode_hubs(file)
  if(file=='trips_peace_health_rides_05_01_2019-05_31_2019.csv'){
    colnames(df)[which(colnames(df)=='Distance')] <- "Distance..Miles."
  }
  write.csv(df, paste0(outpath, "/", file), row.names = FALSE)
  print(file)
}

# file <- "trips_peace_health_rides_05_01_2019-05_31_2019.csv"
# testdf <- read.csv(paste0(outpath, "/", file))

for(file in fileso){
  if(file == fileso[1]){
    df <- read.csv(paste0(outpath, "/", file))
    df$Start.Date <- as.Date(df$Start.Date, format = "%Y-%m-%d")
    df$End.Date <- as.Date(df$End.Date, format = "%Y-%m-%d")
    df <- df[selected_vars]
  }else{
    ndf <- read.csv(paste0(outpath, "/", file))
    
    if(file=='trips_peace_health_rides_05_01_2019-05_31_2019.csv'){
      ndf$Start.Date <- as.Date(ndf$Start.Date, format = "%m/%d/%Y")
      ndf$End.Date <- as.Date(ndf$End.Date, format = "%m/%d/%Y")
      #colnames(ndf)[which(colnames(ndf)=='Distance')] <- "Distance..Miles."
    }else{
      ndf$Start.Date <- as.Date(ndf$Start.Date, format = "%Y-%m-%d")
      ndf$End.Date <- as.Date(ndf$End.Date, format = "%Y-%m-%d")
    }
    ndf <- ndf[selected_vars]
    df <- rbind(df, ndf)
  }
  print(file)
}

df <- df[!(df$Start.Latitude == " - " | df$Start.Longitude == " - " | df$End.Latitude == " - " | df$End.Longitude == "- "), ]
dim(df[(df$Start.Hub == "" | df$End.Hub == ""), ])
df <- df[!(df$Start.Hub == "" | df$End.Hub == ""), ]

df$Minutes <- unlist(lapply(df$Duration, function(x) toMinutes(x)))

unique(df$Start.Hub[grep("HEDCO", df$Start.Hub)])
df$Start.Hub[grep("University of Oregon Station - Bay", df$Start.Hub)]  <- "UO Station"
df$Start.Hub[grep("U of O Station", df$Start.Hub)]  <- "UO Station"
df$Start.Hub[grep("University of Oregon", df$Start.Hub)] <- str_replace(df$Start.Hub[grep("University of Oregon", df$Start.Hub)], 
                                                                        "University of Oregon", "UO")
df$Start.Hub[grep("EMU|Erb Memorial Union", df$Start.Hub)] <- "Erb Memorial Union"
df$Start.Hub[grep("Eugene Station", df$Start.Hub)] <- "Eugene Station"
df$Start.Hub[grep("Police Dept", df$Start.Hub)] <- "UO Police Department"
df$Start.Hub[grep("HEDCO", df$Start.Hub)]  <- "HEDCO Education Building"
df$Start.Hub[grep("Virtual", df$Start.Hub)] <- str_replace(df$Start.Hub[grep("Virtual", df$Start.Hub)], 
                                                                        " \\(Virtual Hub\\)", "")

df$End.Hub[grep("University of Oregon Station - Bay", df$End.Hub)]  <- "UO Station"
df$End.Hub[grep("U of O Station", df$End.Hub)]  <- "UO Station"
df$End.Hub[grep("University of Oregon", df$End.Hub)] <- str_replace(df$End.Hub[grep("University of Oregon", df$End.Hub)], 
                                                                        "University of Oregon", "UO")
df$End.Hub[grep("EMU|Erb Memorial Union", df$End.Hub)] <- "Erb Memorial Union"
df$End.Hub[grep("Eugene Station", df$End.Hub)] <- "Eugene Station"
df$End.Hub[grep("Police Dept", df$End.Hub)] <- "UO Police Department"
df$End.Hub[grep("HEDCO", df$End.Hub)]  <- "HEDCO Education Building"
df$End.Hub[grep("Virtual", df$End.Hub)] <- str_replace(df$End.Hub[grep("Virtual", df$End.Hub)], 
                                                                  " \\(Virtual Hub\\)", "")
df$Path.ID = paste(df$Start.Hub, "-", df$End.Hub)

# library(rgdal)
# library(raster)
# 
# mpob <- readOGR(dsn="V:/Data/Transportation", layer="MPO_Boundary")
# mpob <- spTransform(mpob, CRS("+init=epsg:4326"))
# 
# > extent(mpob)
# class      : Extent 
# xmin       : -123.2321 
# xmax       : -122.8281 
# ymin       : 43.97865 
# ymax       : 44.16123 

write.csv(df, "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/trips_all.csv",
          row.names=FALSE)

mdf <- df[(df$Start.Latitude >= 43.97865 & df$Start.Latitude <= 44.16123) & 
           (df$Start.Longitude >= -123.2321 & df$Start.Longitude <= -122.8281) & 
           (df$End.Latitude >= 43.97865 & df$End.Latitude <= 44.16123) &
           (df$End.Longitude >= -123.2321 & df$End.Longitude <= -122.8281), ]

mdf <- mdf[!(mdf$Start.Longitude == mdf$End.Longitude & mdf$Start.Latitude == mdf$End.Latitude),]

ndf <- organize_points(mdf)

write.csv(ndf, "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/trips_org_dst.csv",
          row.names=FALSE)

pathname <- as.data.frame(table(df$Path.Name))
tail(pathname[order(pathname$Freq),])

########################################### Select Stations ##################################################
#ndf <- read.csv("T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/trips_org_dst.csv")
orgdf <- ndf[ndf$OriginDestination == "Origin", ]
orgdf[orgdf$Location != "",]
#orgdf <- orgdf[orgdf$Location != "",]

sites <- orgdf$Location
sitedf <- as.data.frame(table(sites))

tail(sitedf[order(sitedf$Freq),],50)$sites
hist(sitedf$Freq)
 
########################################### Aggregate Data by Year ###########################################
# trips and duration by year
df_trips <- transform(aggregate(x=list(Trips = df1$Route.ID), 
                                by=list(Year = year(df1$Start.Date)), 
                                FUN=function(x) length(unique(x))), 
                                Growth=ave(Trips,FUN=function(x) c(NA, diff(x)/x[-length(x)]))) 
df_trips
                                                                                                              
df_users <- transform(aggregate(x=list(Users = df1$User.ID), 
                                by=list(Year = year(df1$Start.Date)), 
                                FUN=function(x) length(unique(x))), 
                      Growth=ave(Users,FUN=function(x) c(NA, diff(x)/x[-length(x)]))) 

df_users

df_duration <- transform(aggregate(x=list(Duration = df1$Minutes), 
                                by=list(Year = year(df1$Start.Date)), 
                                FUN=mean), 
                      Growth=ave(Duration,FUN=function(x) c(NA, diff(x)/x[-length(x)]))) 

df_duration
