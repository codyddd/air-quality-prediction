#!/usr/bin/bash
year=$1
sql="INSERT OVERWRITE TABLE ods_noaa_addr PARTITION (\`year\` = ${year}) \
SELECT o.station, o.\`date\`, o.ts, o.latitude, o.longitude, o.elevation, o.name, o.temp, o.temp_attributes, \
o.dewp, o.dewp_attributes, o.slp, o.slp_attributes, o.stp, o.stp_attributes, o.visib, o.visib_attributes, \
o.wdsp, o.wdsp_attributes, o.mxspd, o.gust, o.max, o.max_attributes, o.min, o.min_attributes, \
o.prcp, o.prcp_attributes, o.sndp, o.frshtt, a.country, a.country_name, a.state, a.city_name \
FROM ods_noaa AS o \
LEFT JOIN dim_coor_addr a \
  ON a.latitude = o.latitude \
  AND a.longitude = o.longitude \
WHERE o.\`year\` = ${year}"
docker compose -p air-quality-prediction exec -T \
    hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' -e "$sql"