Initial temperature trend exploration: Yolo County
================

This data was obtained from the NOAA Climate Data Online archive (<https://www.ncdc.noaa.gov/cdo-web/datasets/GHCND/locations/FIPS:06113/detail>). There are 19 stations in the Yolo County:

| NAME                                 |  LATITUDE|  LONGITUDE|
|:-------------------------------------|---------:|----------:|
| WOODLAND 1 WNW, CA US                |   38.6829|  -121.7940|
| BROOKS CALIFORNIA, CA US             |   38.7383|  -122.1447|
| WOODLAND 2.8 SE, CA US               |   38.6471|  -121.7322|
| DAVIS 6.3 W, CA US                   |   38.5613|  -121.8522|
| DAVIS 1.2 SE, CA US                  |   38.5425|  -121.7210|
| DAVIS 1.6 NNW, CA US                 |   38.5744|  -121.7512|
| DAVIS 2.4 W, CA US                   |   38.5592|  -121.7802|
| DAVIS 5.8 WNW, CA US                 |   38.5728|  -121.8402|
| DAVIS 2.3 W, CA US                   |   38.5586|  -121.7780|
| DAVIS 0.8 NE, CA US                  |   38.5618|  -121.7241|
| DAVIS 1.7 SE, CA US                  |   38.5405|  -121.7107|
| DAVIS 1.1 SE, CA US                  |   38.5427|  -121.7234|
| DAVIS 6.1 WNW, CA US                 |   38.5780|  -121.8453|
| DAVIS 1.4 SSE, CA US                 |   38.5381|  -121.7225|
| DAVIS 0.7 NNE, CA US                 |   38.5630|  -121.7294|
| DAVIS 2.7 W, CA US                   |   38.5523|  -121.7855|
| DAVIS 2 WSW EXPERIMENTAL FARM, CA US |   38.5349|  -121.7761|
| DAVIS 1.1 ENE, CA US                 |   38.5592|  -121.7162|
| WINTERS, CA US                       |   38.5252|  -121.9777|

For now, we are looking at data from January 2000-June 2019, although we can grab more data in the future if needed. Note that not all stations provide the same amount of data!

Listed fields in the CSV:

-   TOBS: Temperature at observation time
-   TMAX: Max temperature
-   TMIN: Min temperature
-   TAVG: Average temperature
-   PRCP: Precipitation
-   MDPR: Multi-day precipitation total
-   DAPR: Number of days in MDPR
-   SNOW: snowfall
-   SNWD: Snow depth
-   WT01: Fog
-   WT03: Thunder
-   WT05: Hail
-   WT11: High or damaging winds
-   MDWM: Multiday wind movement
-   DAWM: Number of days in MDWM
-   WDMV: Total wind movement

<!-- -->

    ## [1] "Station WOODLAND 1 WNW, CA US has DAPR, MDPR, PRCP, SNOW, SNWD, TMAX, TMIN, WT01"
    ## [1] "Station BROOKS CALIFORNIA, CA US has TAVG, TMAX, TMIN"
    ## [1] "Station WOODLAND 2.8 SE, CA US has DAPR, MDPR, PRCP, SNOW, SNWD"
    ## [1] "Station DAVIS 6.3 W, CA US has PRCP, SNOW"
    ## [1] "Station DAVIS 1.2 SE, CA US has DAPR, MDPR, PRCP, SNOW, SNWD"
    ## [1] "Station DAVIS 1.6 NNW, CA US has DAPR, MDPR, PRCP, SNOW"
    ## [1] "Station DAVIS 2.4 W, CA US has PRCP, SNOW"
    ## [1] "Station DAVIS 5.8 WNW, CA US has DAPR, MDPR, PRCP, SNOW"
    ## [1] "Station DAVIS 2.3 W, CA US has DAPR, MDPR, PRCP, SNOW"
    ## [1] "Station DAVIS 0.8 NE, CA US has DAPR, MDPR, PRCP, SNOW"
    ## [1] "Station DAVIS 1.7 SE, CA US has PRCP, SNOW, SNWD"
    ## [1] "Station DAVIS 1.1 SE, CA US has DAPR, MDPR, PRCP, SNOW"
    ## [1] "Station DAVIS 6.1 WNW, CA US has DAPR, MDPR, PRCP, SNOW, SNWD"
    ## [1] "Station DAVIS 1.4 SSE, CA US has DAPR, MDPR, PRCP, SNOW"
    ## [1] "Station DAVIS 0.7 NNE, CA US has DAPR, MDPR, PRCP, SNOW"
    ## [1] "Station DAVIS 2.7 W, CA US has DAPR, MDPR, PRCP, SNOW, SNWD"
    ## [1] "Station DAVIS 2 WSW EXPERIMENTAL FARM, CA US has DAWM, MDWM, PRCP, SNOW, SNWD, TMAX, TMIN, TOBS, WDMV, WT01"
    ## [1] "Station DAVIS 1.1 ENE, CA US has DAPR, MDPR, PRCP, SNOW"
    ## [1] "Station WINTERS, CA US has PRCP, SNOW, SNWD, TMAX, TMIN, TOBS, WT01, WT03, WT05, WT11"
