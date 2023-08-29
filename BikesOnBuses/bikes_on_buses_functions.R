library(readr)
library(sf)
library(readxl)
library(dplyr)
library(tools)
library(lubridate)
library(stringr)
library(glue)
library(sp)

options(rstudio.help.showDataPreview = FALSE)
stop.paths <- paste0("T:/Data/LTD Data/", c("2013 Fall_Oct2013_Routes and Stops/Fall 2013 LTD Stops", 
                                           "2014 Fall Oct2014_Routes and Stops",
                                           "2015 Fall LTD Routes and Stops",
                                           "2016 Fall LTD Routes and Stops",
                                           "2016 Winter LTD Routes and Stops",
                                           "2018 Fall LTD Routes and Stops",
                                           "2019 Fall LTD Routes and Stops",
                                           rep("2020 Winter LTD Routes and Stops", 2),
                    "2022 Fall LTD Routes and Stops"))

stop.layers <- c("Fall 2013 LTD Stops", "fall 2014 stops + routes", "Fall 2015 LTD Stops+routes", 
                "Fall 2016 LTD stops", "Winter 2016 LTD Stops+Routes", "Fall_2018_Stops",
                "Fall_2019_Stops", rep("Winter_2020_Stops", 2), "Fall_2022_Stops")

stop.df <- data.frame(year=2013:2022, path=stop.paths, layer=stop.layers)

df2spdf <- function(df, lon_col_name, lat_col_name, trans = TRUE){
  lonlat <- sp::CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  lon_col_no <- which(names(df)==lon_col_name)
  lat_col_no <- which(names(df)==lat_col_name)
  xy <- data.frame(df[,c(lon_col_no,lat_col_no)])
  coordinates(xy) <- c(lon_col_name, lat_col_name)
  proj4string(xy) <- lonlat
  spdf <- sp::SpatialPointsDataFrame(coords = xy, data = df)
  if(trans){
    spdf <- spTransform(spdf, CRS('+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0 +y_0=0 +k=1 +units=m +nadgrids=@null +wktext +no_defs +type=crs'))
  }
  return(spdf)
}

mapping <- function(plotvar, spdf, nclr=8, col="BrBG", sty="kmeans", legtlt='BPH', 
                    title='Bikes Per Hour in CLMPO'){
  plotclr <- rev(brewer.pal(nclr,col))
  class <- classIntervals(plotvar, nclr, style=sty)
  colcode <- findColours(class, plotclr) 
  par(mfrow=c(1,1),mar=c(0,0,2,0))
  plot(MPOBound, col='grey')
  plot(spdf, pch=16, col=colcode, cex=3, add=T)
  legend("topright", legend=names(attr(colcode, "table")),
         fill=attr(colcode, "palette"), cex=0.9, bty="n", title=legtlt)
}

readSheet <- function(path = "T:/Data/LTD Data/BikeOnBuses/Monthly", 
                      fileName = "LTD Bike Count_2013.xlsx",
                      sheetName = "bike count_Jan13"){
  year <- parse_number(fileName)
  stop.path <- stop.df[stop.df$year==year, "path"]
  layer <- stop.df[stop.df$year==year, "layer"]
  if(fileName == "April 2013.xlsx"){
    data <- read_excel(path = paste0(path, "/", fileName), sheet = sheetName,
                       col_types = c("text", "text", "numeric", "text", 
                                     "text", "text", "text", "text", 
                                     "text", "numeric", "numeric", "numeric", 
                                     "numeric", "text", "numeric"))
    
    data$date <- strptime(data$date, "%m/%d/%Y")
    data$trip_end <- strptime(data$trip_end, "%H:%M")
    data$time <- strptime(data$time, "%H:%M")
    data$route <- ifelse(data$route == '01', '1', data$route)
    data <- data[month(data$date)==4,]
  }else{
    data <- read_excel(path = paste0(path, "/", fileName), sheet = sheetName, 
                       col_types = c("text", "date", "numeric", "date", "date", "text", "text", "text", 
                                     "text", "numeric", "numeric", "text","numeric", "text", "numeric"))
  }
  stops.to.remove <- unique(grep('anx|arr|ann|escenter|garage', data$stop, value = TRUE))
  # remove the stops with letters
  data <- subset(data, !(stop %in% stops.to.remove)) %>% select(-c(latitude, longitude))
  # convert EmX
  Emx <- c("101", "102", "103", "104", "105")
  data$route <- ifelse(data$route %in% Emx, "EmX", data$route)
  # make the stop numbers to 5 digits
  zeros <- c("0", "00", "000", "0000")
  data$stop <- ifelse(nchar(data$stop) == 5, data$stop,
                      paste0(zeros[(5 - nchar(data$stop))], data$stop))
  data$MonthYear <- paste(as.character(month(data$date, label=TRUE, abbr=FALSE)),
                          year(data$date))
  stops.df <- get.stop.coordinates(stop.path=stop.path,layer=layer)
  if(class(stops.df$stop) == "numeric"){
    stops.df$stop <- as.character(stops.df$stop)
  } 
  stops.df$stop <- ifelse(nchar(stops.df$stop) == 5, stops.df$stop,
                          paste0(zeros[(5 - nchar(stops.df$stop))], stops.df$stop))
  data <- merge(data, stops.df, by = 'stop')
  return(data)
}

get.stop.coordinates <- function(stop.path="T:/Data/LTD Data/2020 Winter LTD Routes and Stops",
                                 layer="Winter_2020_Stops"){
  stops <- st_read(dsn = stop.path, layer = layer, quiet = TRUE)
  year <- parse_number(layer)
  if(year %in% 2013:2018){
    names(stops) <- tolower(names(stops))
    stops <- st_transform(stops, 4326)
    stops$longitude <- st_coordinates(stops)[, "X"]
    stops$latitude <- st_coordinates(stops)[, "Y"]
  }
  # convert to data frame
  colnames <- c("stop_numbe", "longitude", "latitude")
  stops.df <- as.data.frame(stops)[, colnames]
  names(stops.df)[1] <- "stop"
  return(stops.df)
}
#T:\Data\LTD Data\MonthlyBoardings\2022 Ridership

readExcel <- function(year){
  if(year>=2022){
    path <- glue("T:/Data/LTD Data/MonthlyBoardings/{year} Ridership")
    files <- grep("and", list.files(path), value = TRUE, invert = TRUE)
    for(i in 1:length(files)){
      if(i==1){
        df <- readSheet(path = path, fileName = files[i], sheetName = "bike counts")
      }else{
        ndf <- readSheet(path = path, fileName = files[i], sheetName = "bike counts")
        df <- rbind(df, ndf)
      }
    }
  }else{
    path = "T:/Data/LTD Data/BikeOnBuses/Monthly"
    fileName = glue("LTD Bike Count_{year}.xlsx")
    sheets = excel_sheets(paste0(path,"/", fileName))
    for(i in 1:length(sheets)){
      if(i==1){
        df <- readSheet(path = path, fileName = fileName, sheetName = sheets[i])
      }else{
        ndf <- readSheet(path = path, fileName = fileName, sheetName = sheets[i])
        df <- rbind(df, ndf)
      }
    }
  }
  return(df)
}

agg <- function(data=outbd_data){
  aggdata <- aggregate(x=list(qty = data$qty), by=list(stop_name = data$stop_name), FUN=sum)
  locdata <- aggregate(x=list(latitude = data$latitude, longitude= data$longitude), 
                       by=list(stop_name = data$stop_name), FUN=first)
  aggdata <- merge(aggdata, locdata, by='stop_name')
  spdf <- df2spdf(aggdata, 'longitude', 'latitude')
  return(spdf)
}

exportdata <- function(data=outbd_data, b="outbound", export=FALSE){
  outdata <- aggregate(x=list(Counts = data$qty), by=list(Year = year(data$date), Location = data$stop_name), FUN=sum)
  locdata <- aggregate(x=list(latitude = data$latitude, longitude= data$longitude), 
                       by=list(stop_name = data$stop_name), FUN=first)
  names(locdata) <- c('Location', 'Latitude', 'Longitude')
  outdata <- merge(outdata, locdata, by = 'Location')
  outdata <- outdata[rev(order(outdata$Counts)),]
  
  for(loc in unique(outdata$Location)){
    years <- sort(unique(outdata[outdata$Location == loc,"Year"]))
    for(yr in years){
      if(yr==min(years)){
        outdata[outdata$Location==loc & outdata$Year==yr,"Growth"] <- NA
      }else{
        i <- which(years==yr)
        x1 <- outdata[outdata$Location==loc & outdata$Year==yr,"Counts"]
        x2 <- outdata[outdata$Location==loc & outdata$Year==years[i-1],"Counts"]
        n <- yr - years[i-1]
        outdata[outdata$Location==loc & outdata$Year==yr,"Growth"] <- (x1-x2)/(n*x2)
      }
    }
  }
  routes_stops <- unique(data[,c('route', 'stop_name')])
  names(routes_stops) <- c("Route", "Location")
  output <- merge(outdata, routes_stops, by="Location")
  if(export){
    write.csv(output, paste0('T:/Tableau/tableauBikesOnBuses/Datasources/AggregatedBikesOnBuses_', b,'.csv'), row.names = FALSE)
  }
  return(output)
}

