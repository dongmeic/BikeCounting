
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
    spdf <- spTransform(spdf,  CRS("+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0 +y_0=0 +k=1 +units=m +nadgrids=@null +wktext +no_defs +type=crs"))
  }
  return(spdf)
}

get_aggdata <- function(df=hub_df, OrgDst="Origin"){
  df <- df[df$OriginDestination == OrgDst,]
  aggdata <- aggregate(x=list(NoTrips = df$RouteID, NoUsers = df$UserID), 
                       by=list(Date = df$Date, Location = df$Location), 
                       FUN=function(x) length(x))
  
  if(OrgDst=="Origin"){
    names(aggdata)[3:4] <- c("OrgTrips", "OrgUsers")
  }else{
    names(aggdata)[3:4] <- c("DstTrips", "DstUsers")
  }
  
  return(aggdata)    
}
