# BikeCounting
The repository is to organize bike counting related datasets (bike counts, bike shares, bikes on buses, bike facilities and infrastructure, etc.) collected in CLMPO.

# Bike counts

Bicycle counts in Central Lane MPO area combine both permanent and short-term tube counts. There are 16 permanent counters that are collecting data continuously and data is accessible from [Eco-Visio](https://www.eco-visio.net/v5/login/?callback=%2Fv5%2F#::) with credentials. Six [short-term bike counting tubes](https://www.eco-counter.com/produits/pyro-evo-range-en/urban-postevo/) are rotated manually every two weeks from March to October among the locations determined by a process described in the Section 2 Data Collection (page 19) in [the ODOT bicycle count data report](https://www.oregon.gov/odot/Programs/ResearchDocuments/304-761%20Bicycle%20Counts%20Travel%20Safety%20Health.pdf#page=24). The CLMPO bike counts can be viewed and downloaded from the [data portal](https://www.lcog.org/thempo/page/bicycle-counts). The data includes various spatial and temporal information about bike counts with a temporal resolution of hourly. 

# Bike shares

Bike share data is provided by [Cascadia Mobility](https://forthmobility.org/CascadiaMobility) through the [PeaceHealth Rides](https://peacehealthrides.com/) program and is accessible [here](https://peacehealthrides.com/opendata). The bike share is organized and presented in the [MPO data portal](https://www.lcog.org/thempo/page/peacehealth-rides-bike-share-program). More explanations on the bike share data can be found [here](https://github.com/NABSA/gbfs). Account credentials are required to access the [PeachHealth Rides data portal](https://data.socialbicycles.com/) for bike trips and hub data.

# Bike on buses

Bike on buses data is provided by LTD monthly since 2013.

# Bike facilities and infrastructure (bike map)

The [interactive bike map](https://arcg.is/09XWmC) is built using [ArcGIS Web AppBuilder](https://developers.arcgis.com/web-appbuilder/). The 'about' widget describes the map layers and basic map design. The 'layer list' is used to toggle on and off layers.

The bike facilities data is available on [RLID](https://www.rlid.org/). The map also includes bike shops, bike share stations, bike racks, bike friendly business, bike lockers, and bike fixit stations. Bike shops in Eugene are listed [here](https://www.eugene-or.gov/3260/Bike-Repair-Rentals). Bike shops and bike racks are provided by City of Eugene. Bike share locations are from the [map on PeaceHealth Rides](https://www.peacehealthrides.com/). The bike share stations are [organized](https://github.com/dongmeic/BikeCounting/blob/main/BikeMap/BikeShareStations.ipynb) from the [open data portal](https://peacehealthrides.com/opendata/station_information.json). Bike lockers, and bike fixit stations are from previous work by Chrissy. The bike facilities data was further modified by reviewing the NULL status and changing some status to built, adding to the existing built ones. The LTD stops are from the Winter 2019 version.

The bike-friendly business data is from Travel Oregon provided with business name, address, and coordinates. The coordinates are mostly from the InfoUSA (now Data Axle USA) business data by matching the business names, since a few provided coordinates are not accurate. If there is not a match, the coordinates are from Google Maps by manually typing in the address or using `geopy`. The discrepancy between the two approaches is not neglectable in some addresses because geopy can't get the exact addresses. As such, coordinates values from the manual searching are retained. There are six points located outside of the MPO boundary. The coordinates were reviewed between data sources to correct errors, although the data was not checked one by one.

<!---[Eugene bike map](https://www.eugene-or.gov/DocumentCenter/View/4268/Eugene-Bike-Map---English?bidId=);
[Springfield bike map](https://www.eugene-or.gov/DocumentCenter/View/4270/Springfield-Bike-Map---English?bidId=);
[previous bike map](https://lcog.maps.arcgis.com/apps/webappviewer/index.html?id=c598924750d94d06a372bb467ec9a01e)--->
