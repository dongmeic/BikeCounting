# This script was created to export aggregated bikes per hour by hour, weekday, month and season
# By Dongmei Chen (dchen@lcog.org)
# On June 20th, 2023

options(warn = -1)
library(readxl)
library(lubridate)
library(rgdal)
library(stringr)

inpath <- 'T:/Data/COUNTS/Nonmotorized Counts/Summary Tables/Bicycle/'
data <- read.csv(paste0(inpath, 'Bicycle_HourlyForTableau.csv'))
range(data$Year)