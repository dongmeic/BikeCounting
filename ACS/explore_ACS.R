# This script was created to explore the ACS means of transportation to work data
# By Dongmei Chen (dchen@lcog.org)
# On January 27th, 2022

# Target area - 310M100US21660
# Bike - B08301018

inpath <- "T:/DCProjects/StoryMap/BikeCounting/ACS"

# B08301
read_table <- function(file, foldernm="B08301"){
  inpath <- paste0(inpath, "/", foldernm)
  data <- read.csv(paste0(inpath, "/", file))
  year <- as.numeric(substr(file, 8, 11))
  if(foldernm=="B08006"){
    cols <- c("B08006_014E", "B08006_014M", 
              "B08006_031E", "B08006_031M",
              "B08006_048E", "B08006_048M")
  }else{
    cols <- c("B08301_001E", "B08301_001M", 
              "B08301_018E", "B08301_018M")
  }
  
  dat <- data[-1,-which(names(data) %in% c("GEO_ID", "NAME"))]
  dat <- apply(dat[,cols], 2, as.numeric)
  if(foldernm=="B08301"){
    dat <- cbind(as.data.frame(dat), data[-1, c("GEO_ID", "NAME")])
  }else{
    dat <- cbind(t(as.data.frame(dat)), data[-1, c("GEO_ID", "NAME")])
    rownames(dat) <- NULL
  }
  dat$YEAR <- rep(year, dim(dat)[1])
  if(foldernm=="B08006"){
    dat$PCT <- dat$B08006_048E/dat$B08006_014E
  }else{
    dat$PCT <- dat$B08301_018E/dat$B08301_001E
  }
  return(dat)
}

files <- list.files(paste0(inpath, "/B08301"), pattern = "_data_with_overlays_")
for(file in files){
  if(file==files[1]){
    df <- read_table(file)
  }else{
    ndf <- read_table(file)
    df <- rbind(df, ndf)
  }
}

df[df$GEO_ID %in% c('310M100US21660', '310M200US21660', '310M300US21660',
                    '310M400US21660', '310M500US21660'),]
df[df$NAME %in% c('Eugene-Springfield, OR Metro Area', 'Eugene, OR Metro Area'),]
df_total <- df
boxplot(df_total$PCT~df_total$YEAR)

files <- list.files(paste0(inpath, "/B08301-310M100US21660"), 
                    pattern = "_data_with_overlays_")
for(file in files){
  if(file==files[1]){
    df <- read_table(file, foldernm="B08301-310M100US21660")
  }else{
    ndf <- read_table(file, foldernm="B08301-310M100US21660")
    df <- rbind(df, ndf)
  }
}

df_eug <- df

data <- df_total

# percent
data_means <- aggregate(data$PCT,                       
                        list(data$YEAR),
                        function(x) mean(na.omit(x)))

colnames(data_means)[1] <- "Year"

data_maxes <- aggregate(data$PCT,                       
                        list(data$YEAR),
                        function(x) max(na.omit(x)))

colnames(data_maxes)[1] <- "Year"

for(year in 2010:2019){
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

for(year in 2010:2019){
  sdf <- data[data$YEAR==year,]
  max <- max(na.omit(sdf$B08301_018E))
  print(paste0(year, ": ", sdf[sdf$B08301_018E==max,"NAME"]))
}


png(paste0(inpath, "/boxplot_bike_commuters.png"), width = 8, height = 6,
    units = "in", res = 300)
par(mar=c(2,4,1,1))
boxplot(df_total$PCT~df_total$YEAR, xlab="", 
        ylab="% Bike Commuters",
        col="grey", outcol="lightgrey")
par(new=T)
plot(df_eug$YEAR, df_eug$PCT, xlim=c(2009.5, 2019.5), 
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
points(x = data_maxes$Year[2:10],                             
       y = data_maxes$x[2:10])
lines(data_maxes$Year[2:10], data_maxes$x[2:10], 
      lwd=2, lty=2)
text(x = 2018,                               
     y = 0.085,
     labels = "Corvallis")
dev.off()


boxplot(df_total$B08301_018E~df_total$YEAR, xlab="", 
        ylab="No. Bike Commuters",
        col="grey", outcol="lightgrey")
par(new=T)
plot(df_eug$YEAR, df_eug$B08301_018E, xlim=c(2009.5, 2019.5), 
     ylim=range(na.omit(df_total$B08301_018E)), pch=19, cex=1.5,
     col="red", axes=F, xlab="", ylab="")
lines(df_eug$YEAR, df_eug$B08301_018E, 
      lwd=2, lty=2, col="red")

mean(df_total[grepl("Eugene", df_total$NAME), "B08301_001E"])
mean(df_total[grepl("Corvallis", df_total$NAME), "B08301_001E"])

mean(df_total[grepl("Eugene", df_total$NAME), "B08301_018E"])
mean(df_total[grepl("Corvallis", df_total$NAME), "B08301_018E"])

# B08006
files <- list.files(paste0(inpath, "/B08006"), 
                    pattern = "_data_with_overlays_")

for(file in files){
  if(file==files[1]){
    df <- read_table(file, foldernm = "B08006")
  }else{
    ndf <- read_table(file, foldernm = "B08006")
    df <- rbind(df, ndf)
  }
}

add_legend <- function(...){
  opar <- par(fig=c(0,1,0,1), oma=c(0,0,0,0),mar=c(0,0,0,0), new=TRUE)
  on.exit(par(opar))
  plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
  legend(...)
}


mean(df$PCT)
png(paste0(inpath, "/boxplot_bike_commuters_sex.png"), width = 8, height = 6,
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
text(x = df$YEAR,                               
     y = df$PCT+0.006,
     labels = paste0(round(df$PCT, 3)*100, "%"), col='red')
dev.off()
