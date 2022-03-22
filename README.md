The repository is to organize bike counting related datasets (bike counts, bike shares, bikes on buses, bike facilities and infrastructure, etc.) collected in CLMPO. The US Census ACS [Table B08301: Means of Transportation to Work](https://censusreporter.org/tables/B08301/) ([download](https://data.census.gov/cedsci/table?q=Table%20B08301&g=0100000US%243100000&tid=ACSDT5Y2020.B08301)) and [Table B08006: Sex of Workers by Means of Transportation to Work](https://censusreporter.org/tables/B08006/) ([download](https://data.census.gov/cedsci/table?q=Table%20B08006&g=310XX00US21660&tid=ACSDT5Y2020.B08006)) are also reviewed to understand the number and percent of bike commuters in the metropolitan area.

# Data
## Bike counts

Bicycle counts in Central Lane MPO area combine both permanent and short-term tube counts. There are 16 permanent counters that are collecting data continuously and data is accessible from [Eco-Visio](https://www.eco-visio.net/v5/login/?callback=%2Fv5%2F#::) with credentials. Six [short-term bike counting tubes](https://www.eco-counter.com/produits/pyro-evo-range-en/urban-postevo/) are rotated manually every two weeks from March to October among the locations determined by a process described in the Section 2 Data Collection (page 19) in [the ODOT bicycle count data report](https://www.oregon.gov/odot/Programs/ResearchDocuments/304-761%20Bicycle%20Counts%20Travel%20Safety%20Health.pdf#page=24). The CLMPO bike counts can be viewed and downloaded from the [data portal](https://www.lcog.org/thempo/page/bicycle-counts). The data includes various spatial and temporal information about bike counts with a temporal resolution of hourly. Bikes per hour (BPH) is chosen as an indicator to [explore](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Explore_Bike_Counts.ipynb) the spatial and temporal patterns.

## Bike shares

Bike share data is provided by [Cascadia Mobility](https://forthmobility.org/CascadiaMobility) through the [PeaceHealth Rides](https://peacehealthrides.com/) program and is accessible [here](https://peacehealthrides.com/opendata). The bike share is organized and presented in the [MPO data portal](https://www.lcog.org/thempo/page/peacehealth-rides-bike-share-program). More explanations on the bike share data can be found [here](https://github.com/NABSA/gbfs). Account credentials are required to access the [PeachHealth Rides data portal](https://data.socialbicycles.com/) for the bike trips data. The data portal also covers members, hubs and bikes data. Bike shares are explored and visualized in the [(near) real-time bike availability](https://public.tableau.com/views/RealTimeBikeShareAvailability/BikeShareAvailability?:language=en-US&:display_count=n&:origin=viz_share_link), [monthly paths and counts](https://public.tableau.com/views/MonthlyBikeShareTrips/MapofPaths?:language=en-US&:display_count=n&:origin=viz_share_link), and [yearly patterns](https://public.tableau.com/shared/5P9Z6MMBR?:display_count=n&:origin=viz_share_link). For the real-time data visualization, a [web data connector](https://github.com/KeshiaRose/JSON-XML-WDC) is applied.

## Bike on buses

Bike on buses data is provided by LTD monthly since 2013. The April and October data can be explored by routes in the [MPO data portal](https://www.lcog.org/thempo/page/bikes-buses). The monthly data is [aggregated](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Explore_Bikes_On_Buses.ipynb) to show the stations with the most frequent bikes on buses.

## Bike facilities and infrastructure (bike map)

The [interactive bike map](https://arcg.is/09XWmC) is built using [ArcGIS Web AppBuilder](https://developers.arcgis.com/web-appbuilder/). The 'about' widget describes the map layers and basic map design. The 'layer list' is used to toggle on and off layers.

The bike facilities data is available on [RLID](https://www.rlid.org/). Only "built" facilities are included in the maps and data analysis. The map also includes bike shops, bike share stations, bike racks, bike friendly business, bike lockers, and bike fixit stations. Bike shops in Eugene are listed [here](https://www.eugene-or.gov/3260/Bike-Repair-Rentals). Bike shops and bike racks are provided by City of Eugene. Bike share locations are from the [map on PeaceHealth Rides](https://www.peacehealthrides.com/). The bike share stations are [organized](https://github.com/dongmeic/BikeCounting/blob/main/BikeMap/BikeShareStations.ipynb) from the [open data portal](https://peacehealthrides.com/opendata/station_information.json). Bike lockers, and bike fixit stations are from previous work by Chrissy. The bike facilities data was further modified by reviewing the NULL status and changing some status to built, adding to the existing built ones. The LTD stops are from the Winter 2019 version.

The bike-friendly business data is from Travel Oregon provided with business name, address, and coordinates. The coordinates are mostly from the InfoUSA (now Data Axle USA) business data by matching the business names, since a few provided coordinates are not accurate. If there is not a match, the coordinates are from Google Maps by manually typing in the address or using `geopy`. The discrepancy between the two approaches is not neglectable in some addresses because geopy can't get the exact addresses. As such, coordinates values from the manual searching are retained. There are six points located outside of the MPO boundary. The coordinates were reviewed between data sources to correct errors, although the data was not checked one by one.

<!---[Eugene bike map](https://www.eugene-or.gov/DocumentCenter/View/4268/Eugene-Bike-Map---English?bidId=);
[Springfield bike map](https://www.eugene-or.gov/DocumentCenter/View/4270/Springfield-Bike-Map---English?bidId=);
[previous bike map](https://lcog.maps.arcgis.com/apps/webappviewer/index.html?id=c598924750d94d06a372bb467ec9a01e)--->

# Analysis
## Spatial overlay between bike counts and bike facility type
To understand the bike count distribution among the bike facility types, a spatial join links the two dataset with the nearest function. Setting 10 meters as the reference for road width based the maximum lane width 15 feet and the typical two-lane roadway, the bikes per hour data is aggregated by bike lane type to compare.

## Data aggregation on bike counts, bike share counts and bikes on buses counts
Bike counts, bike share counts, and bikes on buses counts are aggregated from multi-year data using summary statistics, saved as spatial data, and uploaded to the [online bike map](https://arcg.is/K59Oi0) for reference. Bike counting data includes average bikes per hour during 2012 and 2020, total origin and destination bike share station trips during 2019 - 2021, and average annual total counts on bikes on buses during 2013 - 2021.

## Exploratory data analysis
To understand the bike counting spatial patterns, hot spot analysis is conducted in R and ArcGIS Pro.

### Heat map in R

### Hot spot analysis in ArcGIS Pro
