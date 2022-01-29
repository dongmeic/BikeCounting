# This script was created to explore the ACS means of transportation to work data
# By Dongmei Chen (dchen@lcog.org)
# On January 27th, 2022

# Target area - 310M100US21660
# Bike - B08301018

inpath <- "T:/DCProjects/StoryMap/BikeCounting/ACS"

read_table <- function(file, foldernm="B08301"){
  inpath <- paste0(inpath, "/", foldernm)
  data <- read.csv(paste0(inpath, "/", file))
  year <- as.numeric(substr(file, 8, 11))
  cols <- c("B08301_001E", "B08301_001M", 
            "B08301_018E", "B08301_018M")
  dat <- data[-1,-which(names(data) %in% c("GEO_ID", "NAME"))]
  dat <- apply(dat[,cols], 2, as.numeric)
  if(foldernm=="B08301-310M100US21660"){
    dat <- cbind(t(as.data.frame(dat)), data[-1, c("GEO_ID", "NAME")])
    rownames(dat) <- NULL
  }else{
    dat <- cbind(as.data.frame(dat), data[-1, c("GEO_ID", "NAME")])
  }
  dat$YEAR <- rep(year, dim(dat)[1])
  dat$PCT <- dat$B08301_018E/dat$B08301_001E
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

files <- list.files(paste0(inpath, "/B08301-310M100US21660"), pattern = "_data_with_overlays_")
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
data_means <- aggregate(data$PCT,                       
                        list(data$YEAR),
                        function(x) mean(na.omit(x)))

colnames(data_means)[1] <- "Year"

for(year in 2010:2019){
  sdf <- data[data$YEAR==year,]
  max <- max(na.omit(sdf$PCT))
  print(paste(year, ": ", sdf[sdf$PCT==max,"NAME"]))
}

png(paste0(inpath, "/boxplot_bike_commuters.png"), width = 8, height = 6,
    units = "in", res = 300)
par(mar=c(2,4,1,1))
boxplot(df_total$PCT~df_total$YEAR, xlab="", 
        ylab="% Bike Commuters")
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
     y = data_means$x + 0.0012,
     labels = round(data_means$x,4),
     col = "blue")
text(x = df_eug$YEAR,                               
     y = df_eug$PCT+0.002,
     labels = round(df_eug$PCT,4),
     col = "red")
text(x = 2016,                               
     y = 0.08924934-0.001,
     labels = "Corvallis")
dev.off()
