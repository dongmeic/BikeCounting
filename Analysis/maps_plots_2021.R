
options(warn = -1)
library(rgdal)

BikeCounts <- readOGR(dsn="T:/DCProjects/StoryMap/BikeCounting/BikeCounts/Output", layer="Mean_Daily_Bike_Counts_2021")
BikeShare <- readOGR(dsn="T:/DCProjects/StoryMap/BikeCounting/BikeShare/Output", layer="Sum_Bike_Share_Trips")
BikesOnBuses <- readOGR(dsn="T:/DCProjects/StoryMap/BikeCounting/BikeOnBuses/Output", layer="Sum_Bikes_On_Buses")

# high count cuts
countsCut <- 521 # bike counts
shareCut <- 21.3 # bike share trips
BOBCut <- 2.15 # bikes on buses (average daily)
BOBtCut <- 600 # bikes on buses (total)

bc <- BikeCounts[BikeCounts$AvDlyCn > countsCut,]
bs <- BikeShare[BikeShare$AvgNoTrips > shareCut,]
bob <- BikesOnBuses[BikesOnBuses$avgqty > BOBCut & BikesOnBuses$qty > BOBtCut,]

coordd2dataframe <- function(shp){
  df <- as.data.frame(shp@coords)
  names(df) <- c("x", "y")
  return(df)
}

bc_co <- coordd2dataframe(bc)
bs_co <- coordd2dataframe(bs)
bob_co <- coordd2dataframe(bob)


MPOBound <- readOGR(dsn = "V:/Data/Transportation", layer="MPO_Bound")

outpath <- "T:/DCProjects/StoryMap/BikeCounting/figures"
pdf(paste0(outpath, "/high_bike_counts_loc.pdf"), width = 8, height = 5)
par(mar=c(1,1,1,1))
plot(MPOBound)
plot(bc, col='blue', cex=2, add=T)
text(bc_co$x, bc_co$y, bc$Site_Nm, pos = 3, col = "blue")
plot(bs, col='red', pch=2, cex=2, add=T)
text(bs_co$x, bs_co$y, bs$Location, pos = 3, col = "red")
plot(bob, col='green', pch=1, cex=2, add=T)
text(bob_co$x, bob_co$y, bob$stop_name, pos = 3, col = "green")
legend("topright", c("Bike Counts", "Bike Share", "Bikes on Buses"), 
       pch = c(3, 2, 1), col=c("blue", "red", "green"),
       cex = rep(1.5,3))
dev.off()
