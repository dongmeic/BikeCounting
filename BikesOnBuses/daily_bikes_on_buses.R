# This script was created to aggregate daily bikes on buses
# By Dongmei Chen (dchen@lcog.org)
# On September 6th, 2023

library(odbc)
source("C:/Users/clid1852/.0GitHub/BikeCounting/BikesOnBuses/bikes_on_buses_functions.R")
outpath <- 'T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeOnBuses/Output'

most_recent = 2022
data <- readExcel(year=most_recent)
data$weekday <- as.character(wday(data$date, label=TRUE, abbr=FALSE))
data$month <- months(data$date)
data$season <- ifelse(data$month %in% c("December", "January", "February"), "Winter",
                     ifelse(data$month %in% c("March", "April", "May"), "Spring",
                            ifelse(data$month %in% c("June", "July", "August"), "Summer", "Fall")))

data$seasonOrder <- ifelse(data$season == "Spring", 1, 
                          ifelse(data$season == "Summer", 2, 
                                 ifelse(data$season == "Fall", 3, 4)))

data$monthOrder <- ifelse(data$month == "January", 1, 
                         ifelse(data$month == "February", 2, 
                                ifelse(data$month == "March", 3, 
                                       ifelse(data$month == "April", 4, 
                                              ifelse(data$month == "May", 5, 
                                                     ifelse(data$month == "June", 6, 
                                                            ifelse(data$month == "July", 7, 
                                                                   ifelse(data$month == "August", 8, 
                                                                          ifelse(data$month == "September", 9, 
                                                                                 ifelse(data$month == "October", 10, 
                                                                                        ifelse(data$month == "November", 11, 12)))))))))))

data$weekdayOrder <- ifelse(data$weekday == "Monday", 1, 
                           ifelse(data$weekday == "Tuesday", 2, 
                                  ifelse(data$weekday == "Wednesday", 3, 
                                         ifelse(data$weekday == "Thursday", 4, 
                                                ifelse(data$weekday == "Friday", 5, 
                                                       ifelse(data$weekday == "Saturday", 6, 7))))))

datedf <- unique(data[,c('date', 'season', 'month', 'weekday', 'seasonOrder', 'monthOrder', 'weekdayOrder')])

stop.path <- "T:/Data/LTD Data/StopsSince2011"
stops <- st_read(dsn = stop.path, layer = "October 2022")
zeros <- c("0", "00", "000", "0000")
stops$stop_numbe <- ifelse(nchar(stops$stop_numbe) == 5, stops$stop_numbe,
                   paste0(zeros[(5 - nchar(stops$stop_numbe))], stops$stop_numbe))
stopdf <- unique(data[,c('stop', 'route')])
length(unique(stopdf$stop))

# read UGB boundary
con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "rliddb.int.lcog.org,5433",
                 Database = "RLIDGeo",
                 Trusted_Connection = "True")

sql = "
SELECT 
OBJECTID AS id,
ugbcityname AS city,
Shape.STAsBinary() AS geom
FROM dbo.UGB;
"
ugb <- st_read(con, geometry_column = "geom", query = sql) %>% st_set_crs(2914) %>% filter(city %in% c("Eugene", "Springfield", "Coburg"))
stops <- st_transform(stops, 2914)
stop_in_ugb <- st_join(stops, ugb, join = st_within)
names(stop_in_ugb)[1] <- 'stop'
stops <- stop_in_ugb[, c('stop', 'stop_name', 'latitude', 'longitude', 'city')]
stopdf <- merge(stops, stopdf, by="stop")
dim(stopdf)
length(unique(stopdf$stop))
aggdata <- aggregate(x=list(qty = data$qty), 
                     by=list(date = data$date, stop = data$stop, route=data$route), 
                     FUN=sum)
out_df <- get_daily_aggdata(df=data, dir="O")
in_df <- get_daily_aggdata(df=data, dir="I")
aggdata <- merge(aggdata, out_df, by=c("date", "stop", "route"), all=TRUE)
aggdata <- merge(aggdata, in_df, by=c("date", "stop", "route"), all=TRUE)
head(aggdata)
aggdata <- merge(aggdata, stopdf, by=c("stop", "route"))
aggdata <- merge(aggdata, datedf, by="date")
write.csv(aggdata, paste0(outpath, "/Daily_Bikes_On_Buses.csv"), row.names = FALSE)
spdf <- df2spdf(aggdata, 'longitude', 'latitude')
st_write(st_as_sf(spdf), dsn = outpath, layer = "Daily_Bikes_On_Buses", 
         driver = "ESRI Shapefile", delete_layer = TRUE)

sumdf <- aggregate(x=list(qty = aggdata$qty, 
                          out_qty = aggdata$out_qty, 
                          in_qty = aggdata$in_qty), 
                   by=list(stop = aggdata$stop, route=aggdata$route), 
                   FUN=sum)

avgdf <- aggregate(x=list(avgqty = aggdata$qty), 
                   by=list(stop = aggdata$stop, route=aggdata$route), 
                   FUN=mean)
sumdf$pct_out <- (sumdf$out_qty / sumdf$qty) * 100
sum_avg_df <- merge(sumdf, avgdf, by=c("stop", "route"))
sum_avg_df <- merge(sum_avg_df, stopdf, by=c("stop", "route"))
range(sum_avg_df$avgqty)
dim(sum_avg_df)
names(sum_avg_df)
route_avg <- aggregate(x=list(avgqty=sum_avg_df$avgqty), by=list(route=sum_avg_df$route), FUN=mean)
range(route_avg$avgqty)

routes <- st_read(dsn = 'T:/Data/LTD Data/2022 Fall LTD Routes and Stops', layer="Fall_2022_Routes")
st_write(st_as_sf(routes), dsn = outpath, layer = "Daily_Bikes_On_Buses_Routes", 
         driver = "ESRI Shapefile", delete_layer = TRUE)
names(routes)[1] <- "route"
routes <- merge(routes, route_avg, by="route")
write.csv(sum_avg_df, paste0(outpath, "/Sum_Bikes_On_Buses.csv"), row.names = FALSE)
st_write(st_as_sf(routes), dsn = outpath, layer = "Daily_Bikes_On_Buses_Routes", 
         driver = "ESRI Shapefile", delete_layer = TRUE)

sum_avg_spdf <- df2spdf(sum_avg_df, 'longitude', 'latitude')
names(sum_avg_spdf)
st_write(st_as_sf(sum_avg_spdf), dsn=outpath, layer="Sum_Bikes_On_Buses", driver="ESRI Shapefile", delete_layer=TRUE)
