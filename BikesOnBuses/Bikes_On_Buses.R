# This script was created to organize the yearly bikes on buses
# By Dongmei Chen (dchen@lcog.org)
# On August 28th, 2023

source("C:/Users/clid1852/.0GitHub/BikeCounting/BikesOnBuses/bikes_on_buses_functions.R")

for(year in 2013:2022){
  print(year)
  if(year==2013){
    df <- readExcel(year=year)
  }else{
    ndf <- readExcel(year=year)
    df <- rbind(df, ndf)
  }
}
df$year <- year(df$date)
range(df$year)

data <- df
outbd_data <- data[data$dir == 'O',] #& (data$desc != "bike not accommodated")
inbd_data <- data[data$dir == 'I',]
spdf <- agg()

MPOBound <- st_read(dsn = "X:/Data/Transportation", layer="MPO_Bound", quiet=TRUE)

options(repr.plot.width=12, repr.plot.height=12)
par(mfrow=c(1,1),mar=c(0,0,2,0))
plot(MPOBound$geometry)
plot(spdf, add=TRUE, col='grey')
points(coordinates(spdf)[,'coords.x1'], coordinates(spdf)[,'coords.x2'], cex=spdf$qty/10000, col='red')

spdf_s <- spdf[!grepl(paste(c("Springfield Station, Bay", "Eugene Station, Bay"), collapse = "|"), spdf$stop_name),]

par(mfrow=c(1,1),mar=c(0,0,2,0))
plot(MPOBound$geometry)
plot(spdf, add=TRUE, col='grey')
points(coordinates(spdf_s)[,'coords.x1'], coordinates(spdf_s)[,'coords.x2'], cex=spdf$qty/5000, col='red')

outdata <- exportdata(export=TRUE)

sdata <- outdata[!grepl(paste(c("Springfield Station, Bay", "Eugene Station, Bay"),collapse = "|"), outdata$Location),]
options(repr.plot.width=8, repr.plot.height=8)
par(mfrow=c(1,1),mar=c(4,4,2,0))
boxplot(Counts~Year,data=sdata)

outdata <- exportdata(data=inbd_data, b="inbound", export=TRUE)
df <- transform(aggregate(x=list(Counts = data$qty), by=list(Year = year(data$date)), FUN=sum), Growth=ave(Counts, 
                                                                                                           FUN=function(x) c(NA, diff(x)/x[-length(x)])))

df

outdata <- exportdata(data=data, b="total", export=TRUE)
# combine yearly aggregated data
inpath <- "T:/Tableau/tableauBikesOnBuses/Datasources/AggregatedBikesOnBuses_"
total <- read.csv(paste0(inpath, "total.csv"))
total$Category <- 'Total'
inbd <- read.csv(paste0(inpath, "inbound.csv"))
inbd$Category <- 'Inbound'
outbd <- read.csv(paste0(inpath, "outbound.csv"))
outbd$Category <- 'Outbound'
outdata <- rbind(total, rbind(inbd, outbd))

spdf <- df2spdf(df=outdata, lon_col_name='Longitude', lat_col_name='Latitude')
outpath <- 'T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeOnBuses/Output'
st_write(st_as_sf(spdf), dsn = outpath, layer = "Yearly_Bikes_On_Buses", 
         driver = "ESRI Shapefile", delete_layer = TRUE)

