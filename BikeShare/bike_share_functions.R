
prj4str <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0 +y_0=0 +k=1 +units=m +nadgrids=@null +wktext +no_defs +type=crs"

organize_points <- function(trips){
  #trips <- read.csv(paste0(inpath, "/", file))
  org <- trips[,c('Route.ID', 'Bike.ID', 'User.ID', 
                  'Start.Hub', 'Start.Latitude', 'Start.Longitude',
                  'Start.Date', 'Start.Time',
                  'Distance..Miles.', 'Minutes')]
  names(org) <- c("RouteID", "BikeID", 'UserID',
                  "Location", "Latitude", "Longitude",
                  "Date", "Time", 
                  'Distance', 'Minutes')
  org$OriginDestination <- rep("Origin", dim(org)[1])
  dst <- trips[,c('Route.ID', 'Bike.ID', 'User.ID', 'End.Hub',
                  'End.Latitude', 'End.Longitude',
                  'End.Date','End.Time', 
                  'Distance..Miles.', 'Minutes')]
  names(dst) <- c("RouteID", "BikeID", 'UserID',
                  "Location", "Latitude", "Longitude", 
                  "Date", "Time",
                  'Distance', 'Minutes')
  dst$OriginDestination <- rep("Destination", dim(dst)[1])
  df <- rbind(org, dst)
  return(df)
}

convert_time_to_hour <- function(x){
  s <- unlist(str_split(x, ":"))
  return(as.numeric(s[1])+as.numeric(s[2])/60)
}

toMinutes <- function(x){
  h <- as.numeric(strsplit(x, ":")[[1]][1])
  m <- as.numeric(strsplit(x, ":")[[1]][2])
  s <- as.numeric(strsplit(x, ":")[[1]][3])
  
  res <- h*60 + m + s/60
  
  return(res)
}

get_parts_of_day <- function(x){
  if(x >= 21 | x <= 4){
    d <- "Night"
  }else if(x > 17 & x < 21){
    d <- "Evening"
  }else if(x > 12 & x <= 17){
    d <- "Afternoon"
  }else{
    d <- "Morning"
  }
  return(d)
}

agg_data <- function(df=data, by="Origin"){
  dt <- df[df$OrgDst == by,]
  aggdt <- aggregate(x=list(NoTrips=dt$RouteID, NoUsers = dt$UserID),
                     by=list(Location = dt$Location, Longitude = dt$Longitude, 
                             Latitude=dt$Latitude, DayPart=dt$DayPart),
                     FUN=function(x) length(unique(x)))
  return(aggdt)
}

df2spdf <- function(df, lon_col_name, lat_col_name, trans = TRUE){
  lonlat <- sp::CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  lon_col_no <- which(names(df)==lon_col_name)
  lat_col_no <- which(names(df)==lat_col_name)
  xy <- data.frame(df[,c(lon_col_no,lat_col_no)])
  coordinates(xy) <- c(lon_col_name, lat_col_name)
  proj4string(xy) <- lonlat
  spdf <- sp::SpatialPointsDataFrame(coords = xy, data = df)
  if(trans){
    spdf <- spTransform(spdf,  CRS(prj4str))
  }
  return(spdf)
}

get_aggdata <- function(df=hub_df, OrgDst="Origin", cat='daily'){
  df <- df[df$OriginDestination == OrgDst,]
  if(cat=='daily'){
    aggdata <- aggregate(x=list(NoTrips = df$RouteID, NoUsers = df$UserID), 
                         by=list(Date = df$Date, Location = df$Location), 
                         FUN=function(x) length(unique(x)))
  }else{
    aggdata <- aggregate(x=list(NoTrips = df$RouteID, NoUsers = df$UserID), 
                         by=list(Year = df$Year, Location = df$Location), 
                         FUN=function(x) length(unique(x)))
  }
  
  if(OrgDst=="Origin"){
    names(aggdata)[3:4] <- c("OrgTrips", "OrgUsers")
  }else{
    names(aggdata)[3:4] <- c("DstTrips", "DstUsers")
  }
  
  return(aggdata)    
}

get_yearly_data <- function(year){
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
  
  return(df)
}

get_data_multiyears <- function(year_range){
  for(year in year_range){
    print(year)
    if(year == min(year_range)){
      df = get_yearly_data(as.character(year))
    }else{
      ndf = get_yearly_data(as.character(year))
      df = rbind(df, ndf)
    }
  }
  return(df)
}

organize_yearly_data <- function(df){
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
  return(ndf)
}

get_stations <- function(){
  stations <- read.csv("C:/Users/clid1852/.0GitHub/BikeCounting/BikeMap/BikeShareStations.csv")
  stations$name <- str_replace(stations$name, " @", ",")
  stations$City <- ifelse(stations$name %in% c('PeaceHealth RiverBend', 'RiverBend Annex', 'Heartfelt House'), "Springfield", "Eugene")
  names(stations) <- c("StationID", "Location", "Longitude", "Latitude", "City")
  return(stations)
}

# get the location dataframe outside stations
get_locdf_out <- function(ndf){
  locdf <- unique(ndf[,c("Location", "Latitude", "Longitude", "OriginDestination")])
  stations <- get_stations()
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
  return(nlocdf)
}

aggregate_data_daily <- function(ndf){
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
  stations <- get_stations()
  hub_df <- ndf[ndf$Location %in% stations$Location,]
  #dim(hub_df)
  #unique(hub_df$OriginDestination)
  aggdata <- aggregate(x=list(NoTrips = hub_df$RouteID, NoUsers = hub_df$UserID), 
                       by=list(Date = hub_df$Date, Location = hub_df$Location), 
                       FUN=function(x) length(unique(x)))
  aggdata <- merge(aggdata, get_aggdata(df=hub_df, OrgDst="Origin"), by=c("Location", "Date"))
  aggdata <- merge(aggdata, get_aggdata(df=hub_df, OrgDst="Destination"), by=c("Location", "Date"))
  aggdata <- merge(aggdata, stations, by="Location")
  aggdata <- merge(aggdata, datedf, by="Date")
  return(aggdata)
}

aggregate_data_yearly <- function(ndf){
  stations <- get_stations()
  hub_df <- ndf[ndf$Location %in% stations$Location,]
  aggdata <- aggregate(x=list(NoTrips = hub_df$RouteID, NoUsers = hub_df$UserID), 
                       by=list(Year = hub_df$Year, Location = hub_df$Location), 
                       FUN=function(x) length(unique(x)))
  aggdata <- merge(aggdata, get_aggdata(df=hub_df, OrgDst="Origin", cat='yearly'), by=c("Location", "Year"))
  aggdata <- merge(aggdata, get_aggdata(df=hub_df, OrgDst="Destination", cat='yearly'), by=c("Location", "Year"))
  aggdata <- merge(aggdata, stations, by="Location")
  return(aggdata)
}

summarize_aggdata <- function(aggdata){
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
  stations <- get_stations()
  sumdf <- merge(sumdf, stations, by="Location")
  sum_avg_df <- merge(sumdf, avgdf, by="Location")
  return(sum_avg_df)
}

calculate_growth <- function(outdata, infield, outfield){
  for(loc in unique(outdata$Location)){
    years <- sort(unique(outdata[outdata$Location == loc,"Year"]))
    for(yr in years){
      if(yr==min(years)){
        outdata[outdata$Location==loc & outdata$Year==yr, outfield] <- NA
      }else{
        i <- which(years==yr)
        x1 <- outdata[outdata$Location==loc & outdata$Year==yr, infield]
        x2 <- outdata[outdata$Location==loc & outdata$Year==years[i-1], infield]
        n <- yr - years[i-1]
        outdata[outdata$Location==loc & outdata$Year==yr, outfield] <- (x1-x2)/(n*x2)
      }
    }
  }
  return(outdata)
}