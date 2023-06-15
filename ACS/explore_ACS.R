# This script was created to explore the ACS means of transportation to work data
# By Dongmei Chen (dchen@lcog.org)
# On January 27th, 2022

# Target area - 310M100US21660
# Bike - B08301018

inpath <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/ACS"
source("C:/Users/clid1852/.0GitHub/BikeCounting/ACS/explore_ACS_functions.R")
StartYear <- 2010
EndYear <- 2021
# get data from Table B08301
df <- get_data()
# quick view on Eug-Spr data
df[df$GEO_ID %in% c('310M100US21660', '310M200US21660', '310M300US21660',
                    '310M400US21660', '310M500US21660', '310M600US21660'),]
df[df$NAME %in% c('Eugene-Springfield, OR Metro Area', 'Eugene, OR Metro Area'),]
# quick view on the nationwide data (boxlot) 
df_total <- df
boxplot(df_total$PCT~df_total$YEAR)

df <- get_data(foldernm="B08301-310M100US21660")
df_eug <- df
data <- df_total

# aggregate percent by mean and max
data_means <- aggregate(data$PCT,                       
                        list(data$YEAR),
                        function(x) mean(na.omit(x)))

colnames(data_means)[1] <- "Year"

data_maxes <- aggregate(data$PCT,                       
                        list(data$YEAR),
                        function(x) max(na.omit(x)))

colnames(data_maxes)[1] <- "Year"

# check the metro with the maximum pct bike commuters
for(year in 2010:EndYear){
  sdf <- data[data$YEAR==year,]
  max <- max(na.omit(sdf$PCT))
  print(paste0(year, ": ", sdf[sdf$PCT==max,"NAME"]))
}

data_means_tot <- aggregate(data$B08301_018E,                       
                        list(data$YEAR),
                        function(x) mean(na.omit(x)))

colnames(data_means_tot)[1] <- "Year"

data_maxes_tot <- aggregate(data$B08301_018E,                       
                        list(data$YEAR),
                        function(x) max(na.omit(x)))

colnames(data_maxes_tot)[1] <- "Year"
# the maximum has been Corvallis since 2011
# this number will be used on the figure - boxplot_bike_commuters.png
n <- EndYear-StartYear+1

# check the metro with the maximum bike commuters
for(year in 2010:EndYear){
  sdf <- data[data$YEAR==year,]
  max <- max(na.omit(sdf$B08301_018E))
  print(paste0(year, ": ", sdf[sdf$B08301_018E==max,"NAME"]))
}

# figure 1
png(paste0(inpath, "/boxplot_bike_commuters.png"), width = 8, height = 6,
    units = "in", res = 300)
par(mar=c(2,4,1,1))
boxplot(df_total$PCT~df_total$YEAR, xlab="", 
        ylab="% Bike Commuters",
        col="grey", outcol="lightgrey")
par(new=T)
plot(df_eug$YEAR, df_eug$PCT, xlim=c(StartYear-0.5, EndYear+0.5), 
     ylim=range(na.omit(df_total$PCT)), pch=19, cex=1.5,
     col="red", axes=F, xlab="", ylab="")
lines(df_eug$YEAR, df_eug$PCT, 
      lwd=2, lty=2, col="red")
points(x = data_means$Year,                             
       y = data_means$x,
       col = "blue",
       pch = 16)
text(x = data_means$Year,                                
     y = data_means$x + 0.002,
     labels = paste0(round(data_means$x,4)*100, "%"),
     col = "blue")
text(x = df_eug$YEAR,                               
     y = df_eug$PCT+0.002,
     labels = paste0(round(df_eug$PCT,4)*100, "%"),
     col = "red")
text(x = 2017,                               
     y = 0.048,
     labels = "Eugene-Springfield", 
     col = "red")
points(x = data_maxes$Year[2:n],                             
       y = data_maxes$x[2:n])
lines(data_maxes$Year[2:n], data_maxes$x[2:n], 
      lwd=2, lty=2)
text(x = 2018,                               
     y = 0.085,
     labels = "Corvallis")
dev.off()

# quick view on no. bike commuters
boxplot(df_total$B08301_018E~df_total$YEAR, xlab="", 
        ylab="No. Bike Commuters",
        col="grey", outcol="lightgrey")
par(new=T)
plot(df_eug$YEAR, df_eug$B08301_018E, xlim=c(StartYear-0.5, EndYear+0.5), 
     ylim=range(na.omit(df_total$B08301_018E)), pch=19, cex=1.5,
     col="red", axes=F, xlab="", ylab="")
lines(df_eug$YEAR, df_eug$B08301_018E, 
      lwd=2, lty=2, col="red")

# check the differences in population sizes and bike commuters
mean(df_total[grepl("Eugene", df_total$NAME), "B08301_001E"])
mean(df_total[grepl("Corvallis", df_total$NAME), "B08301_001E"])

mean(df_total[grepl("Eugene", df_total$NAME), "B08301_018E"])
mean(df_total[grepl("Corvallis", df_total$NAME), "B08301_018E"])

# get data from Table B08006
df <- get_data(foldernm="B08006")
mean(df$PCT)
# figure 2
png(paste0(inpath, "/bike_commuters_sex.png"), width = 8, height = 6,
    units = "in", res = 300)
par(mar=c(2,4,1,1))
layout(matrix(c(1,2,3), ncol=1), widths = c(8,8,8), heights = c(3.5,0.5,2), TRUE)
plot(df$YEAR, df$B08006_014E, ylim=c(min(df$B08006_048E), 
                                     max(df$B08006_014E)),
     xlab="", ylab="No. Bike Commuters",
     cex=1.5)
lines(df$YEAR, df$B08006_014E, lwd=2)
points(df$YEAR, df$B08006_031E, col='blue', cex=1.5)
lines(df$YEAR, df$B08006_031E, col='blue', lwd=2)
points(df$YEAR, df$B08006_048E, col='red', cex=1.5)
lines(df$YEAR, df$B08006_048E, col='red', lwd=2)
text(x = df$YEAR,                               
     y = df$B08006_014E-150,
     labels = df$B08006_014E)
text(x = df$YEAR,                               
     y = df$B08006_031E+150,
     labels = df$B08006_031E, col='blue')
text(x = df$YEAR,                               
     y = df$B08006_048E+150,
     labels = df$B08006_048E, col='red')
plot(NULL, xaxt='n', yaxt='n', bty='n', xlab='', ylab='', 
     xlim=0:1, ylim=0:1)
legend("center", c("Total", "Men", "Women"), horiz=TRUE, bty="n",
       lty = rep(1,3), pch = rep(1,3), col=c("black", "blue", "red"),
       cex = rep(1.2,3), lwd=rep(2,3))
plot(df$YEAR, df$PCT, xlab="", ylab="% Women bike commuters", 
     col="red", cex=1.5, ylim=c(range(df$PCT)[1], range(df$PCT)[2]+0.008))
lines(df$YEAR, df$PCT, col="red", lwd=2)
text(x = df$YEAR[1:(n-2)],                               
     y = df$PCT[1:(n-2)]+0.006,
     labels = paste0(round(df$PCT[1:(n-2)], 3)*100, "%"), col='red')
text(x = df$YEAR[(n-1):n]+0.18,                               
     y = df$PCT[(n-1):n]+0.006,
     labels = paste0(round(df$PCT[(n-1):n], 3)*100, "%"), col='red')
dev.off()

# check the rank
sdf = data[data$YEAR==2020,c('NAME', 'PCT')]
odf = sdf[order(sdf$PCT, decreasing = TRUE),]
head(odf, 10)
which(odf$NAME == "Portland-Vancouver-Hillsboro, OR-WA Metro Area")

# this figure is for illustration
df$PCT_M = 1-df$PCT
png(paste0(inpath, "/bike_commuters_sex_pct.png"), width = 4, height = 4,
    units = "in", res = 300)
par(mar=c(2,4,1,1))
plot(df$YEAR, df$PCT_M, pch=16, col='blue', cex=1.2, ylim=c(0.3, 0.7),
     xlab="Year", ylab="% Bike Commuters")
lines(df$YEAR, df$PCT_M, col='blue',lwd=2)
lines(df$YEAR, df$PCT, col="red", lwd=2)
points(df$YEAR, df$PCT, col='red', pch=16, cex=1.2)
dev.off()