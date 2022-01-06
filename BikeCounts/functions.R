
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

readSheet <- function(fileName = "LTD Bike Count_2013.xlsx",
                      sheetName = "bike count_Jan13",
                      stop.path="T:/Data/LTD Data/2020 Winter LTD Routes and Stops",
                      layer="Winter_2020_Stops"){
    data <- read_excel(path = paste0(path, fileName), sheet = sheetName, 
             col_types = c("text", "date", "numeric", "date", "date", "text", "text", "text", 
                            "text", "numeric", "numeric", "text","numeric", "text", "numeric"))
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
    dates <- sort(unique(data$date))
    routes <- unique(data$route)
    for(i in 1:length(dates)){
        d <- dates[i]
        for(j in 1:length(routes)){
          r <- routes[j]
          data$DailyRtQty[data$date==d & data$route==r] <- sum(data$qty[data$date==d & data$route==r], na.rm = TRUE)
        }
        data$DailyQty[data$date==d] <- sum(data$qty[data$date==d], na.rm = TRUE)
      }
    stops.df <- get.stop.coordinates(stop.path=stop.path,layer=layer)
    data <- merge(data, stops.df, by = 'stop')
    return(data)
}

get.stop.coordinates <- function(stop.path="T:/Data/LTD Data/2020 Winter LTD Routes and Stops",
                                layer="Winter_2020_Stops"){
  stops <- readOGR(dsn = stop.path, layer = layer, verbose = FALSE, 
                   stringsAsFactors = FALSE)
  # convert to data frame
  colnames <- c("stop_numbe", "longitude", "latitude")
  stops.df <- stops@data[, colnames]
  names(stops.df)[1] <- "stop"
  return(stops.df)
}

readExcel <- function(fileName = "LTD Bike Count_2013.xlsx"){
    sheets <- excel_sheets(paste0(path,fileName))
    for(i in 1:length(sheets)){
        if(i==1){
            df <- readSheet(fileName = fileName, sheetName = sheets[i])
        }else{
            ndf <- readSheet(fileName = fileName, sheetName = sheets[i])
            df <- rbind(df, ndf)
        }
    }
    return(df)
}
