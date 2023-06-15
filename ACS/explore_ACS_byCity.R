
library(ggplot2)
library(plotly)
library(scales)
library(ggpubr)

source("C:/Users/clid1852/.0GitHub/BikeCounting/ACS/explore_ACS_byCity_functions.R")

# get data
data1 <- get_data(foldernm="B08006")
data1

data2 <- get_data(foldernm="B08301")
data2

data3 <- get_data(foldernm="B01003")
data3

data <- cbind(data1[,-which(names(data1) %in% c("GEO_ID", "NAME", "YEAR"))],data3)
names(data)

# percentage of commuters
data$PCT2 <- data$B08006_001E/data$B01003_001E
data$City <- ifelse(grepl("Eugene city", data$NAME), "EUG", "SPR")
names(data)[which(names(data) == "YEAR")] <- "Year"

df <- data
names(df)[which(names(df) == "B08006_014E")] <- "Est"
names(df)[which(names(df) == "B08006_014M")] <- "MoE"

bike_commuters <- ggplot(df, aes(x = Year, y = Est, color=City)) + 
  geom_ribbon(aes(ymax = Est + MoE, ymin = Est - MoE), 
              fill="lightgrey",
              alpha = 0.4) +
  geom_line() + 
  geom_point(size = 2) + 
  scale_x_continuous(label = scales::label_number(accuracy = 1)) +
  scale_y_continuous(labels = label_number(suffix = " K", scale = 1e-3)) +
  #facet_grid(rows = vars(NAME)) + 
  theme_minimal(base_size = 12)+
  labs(title = "No. Bike Commuters in Eugene and Springfield",
       y = "ACS Estimate",
       caption = "Shaded area represents margin of error around the ACS estimate")

ggplotly(bike_commuters)

# figure 3
png(paste0(path, "/bike_commuters_by_city_with_MoE.png"), width = 8, height = 6,
    units = "in", res = 300)
print(bike_commuters)
dev.off()

df <- data
names(df)[which(names(df) == "PCT")] <- "% Bike Commuters"
names(df)[which(names(df) == "PCT2")] <- "% Work Commuters"

df1 <- df[,c("% Bike Commuters" , "Year", "City")]
df2 <- df[,c("% Work Commuters" , "Year", "City")]
names(df1)[1] <- "Percent"
names(df2)[1] <- "Percent"
df1$Category <- rep("% Bike Commuters", dim(df1)[1])
df2$Category <- rep("% Work Commuters", dim(df2)[1])

ndf <- rbind(df1, df2)
ndf$Percent <- round(ndf$Percent * 100,1)

pct_bike_work_commuters <- ggplot(ndf, aes(x = Year, y = Percent, color=City, shape=Category)) + 
  geom_line(linewidth = 2) + 
  geom_point(size = 4) + 
  scale_x_continuous(label = scales::label_number(accuracy = 1)) +
  theme_minimal(base_size = 12)+
  labs(title = "Percents of Bike Commuters and Work Commuters in Eugene and Springfield",
       y = "Percentage")

ggplotly(pct_bike_work_commuters)

pct_work_commuters <- ggplot(ndf[ndf$Category=="% Work Commuters",], 
                             aes(x = Year, y = Percent, color=City)) + 
  geom_line(linewidth = 1.25) + 
  geom_point(size = 3, shape=17) + 
  scale_x_continuous(label = scales::label_number(accuracy = 1)) +
  theme_minimal(base_size = 12)+
  labs(title = "Percent of Work Commuters",
       y = "Percentage")

pct_bike_commuters <- ggplot(ndf[ndf$Category=="% Bike Commuters",], 
                             aes(x = Year, y = Percent, color=City)) + 
  geom_line(linewidth = 1.25) + 
  geom_point(size = 3, shape=16) + 
  scale_x_continuous(label = scales::label_number(accuracy = 1)) +
  theme_minimal(base_size = 12)+
  labs(title = "Percent of Bike Commuters",
       y = "Percentage")

combined <- ggarrange(
  pct_work_commuters, pct_bike_commuters, labels = c("A", "B"),
  common.legend = TRUE, legend = "top",  ncol = 1, nrow = 2
)

# figure 4
png(paste0(path, "/percent_bike_work_commuters.png"), width = 8, height = 6,
    units = "in", res = 300)
print(combined)
dev.off()

df <- data
names(df)[which(names(df) == "B08006_031E")] <- "Male"
names(df)[which(names(df) == "B08006_048E")] <- "Female"

df1 <- df[,c("Male" , "Year", "City")]
df2 <- df[,c("Female" , "Year", "City")]
names(df1)[1] <- "ORGValue"
names(df2)[1] <- "ORGValue"
df1$Sex <- rep("Male", dim(df1)[1])
df2$Sex <- rep("Female", dim(df2)[1])

ndf <- rbind(df1, df2) %>%
  mutate(Value = ifelse(Sex == "Male", -ORGValue, ORGValue),
         Year = as.character(Year))

eug_sex <- ggplot(ndf[ndf$City == "EUG",], 
                  aes(x = Value, 
                      y = Year, 
                      fill = Sex)) + 
  geom_col(width = 0.95, alpha = 0.75) + 
  theme_minimal(base_size = 12) + 
  scale_x_continuous(
    labels = ~ number_format(scale = .001, suffix = "k")(abs(.x)),
    limits = 4200 * c(-1,1)
  ) + geom_label(aes(label=ORGValue))+
  labs(x = "", 
       y = "Year", 
       title = "EUG Bike Commuter Structure", 
       fill = "")

spr_sex <- ggplot(ndf[ndf$City == "SPR",], 
                  aes(x = Value, 
                      y = Year, 
                      fill = Sex)) + 
  geom_col(width = 0.95, alpha = 0.75) + 
  theme_minimal(base_size = 12) + 
  scale_x_continuous(
    labels = ~ number_format()(abs(.x)),
    limits = 600 * c(-1,1)
  ) + geom_label(aes(label=ORGValue))+
  labs(x = "", 
       y = "Year", 
       title = "SPR Bike Commuter Structure", 
       fill = "")

combined2 <- ggarrange(
  eug_sex, spr_sex, labels = c("A", "B"),
  common.legend = TRUE, legend = "bottom",  ncol = 2, nrow = 1
)

# figure 5
png(paste0(path, "/bike_commuter_structure.png"), width = 8, height = 6,
    units = "in", res = 300)
print(combined2)
dev.off()
