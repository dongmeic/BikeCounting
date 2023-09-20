
options(warn = -1)
library(sf)

BikeCounts <- st_read(dsn="T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeCounts/Output", layer="Mean_Daily_Bike_Counts")
BikeShare <- st_read(dsn="T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeShare/Output", layer="Sum_Bike_Share_Trips")
BikesOnBuses <- st_read(dsn="T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeOnBuses/Output", layer="Sum_Bikes_On_Buses")

# high count cuts
countsCut <- quantile(BikeCounts$AvDlyCn, 0.9) # bike counts
shareCut <- quantile(BikeShare$AvgNoTrips, 0.9) # bike share trips
BOBCut <- quantile(BikesOnBuses$avgqty, 0.98) # bikes on buses (average daily)
BOBtCut <- quantile(BikesOnBuses$qty, 0.98) # bikes on buses (total)

bc <- BikeCounts[BikeCounts$AvDlyCn >= countsCut,]
bs <- BikeShare[BikeShare$AvgNoTrips >= shareCut,]
bob <- BikesOnBuses[(BikesOnBuses$avgqty >= BOBCut) & (BikesOnBuses$qty >= BOBtCut),]

coordd2dataframe <- function(shp){
  df <- as.data.frame(st_coordinates(shp))
  names(df) <- c("x", "y")
  return(df)
}

bc_co <- coordd2dataframe(bc)
bs_co <- coordd2dataframe(bs)
bob_co <- coordd2dataframe(bob)

MPOBound <- st_read(dsn = "X:/Data/Transportation", layer="MPO_Bound")

outpath <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/figures"
pdf(paste0(outpath, "/high_bike_counts_loc.pdf"), width = 8, height = 5)
par(mar=c(1,1,1,1))
plot(MPOBound$geometry)
plot(bc, col='#3A54A4', pch=3, cex=2, add=T)
plot(bs, col='#771D48', pch=2, cex=2, add=T)
plot(bob, col='#48853E', pch=1, cex=2, add=T)
text(bc_co$x, bc_co$y, bc$Site_Nm, pos = 3, col = "#3A54A4")
text(bs_co$x, bs_co$y, bs$Location, pos = 3, col = "#771D48")
text(bob_co$x, bob_co$y, bob$stop_name, pos = 3, col = "#48853E")
legend("topright", c("Bike Counts", "Bike Share", "Bikes on Buses"), 
       pch = c(3, 2, 1), col=c("#3A54A4", "#771D48", "#48853E"),
       cex = rep(1.5,3))
dev.off()

BikesOnBuses_in <- BikesOnBuses[!is.na(BikesOnBuses$in_qty),]
sort(BikesOnBuses_in$in_qty, decreasing = TRUE)
unique(BikesOnBuses_in[BikesOnBuses_in$in_qty > 800, "stop_name"])

BikesOnBuses_out <- BikesOnBuses[!is.na(BikesOnBuses$out_qty),]
sort(BikesOnBuses_out$out_qty, decreasing = TRUE)
unique(BikesOnBuses_out[BikesOnBuses_out$out_qty > 1000, "stop_name"])
