#!/usr/bin/bash
year=$1
sql="INSERT OVERWRITE TABLE ods_noaa PARTITION (\`year\` = ${year}) \
SELECT station, cast(\`date\` as date) AS \`date\`, unix_timestamp(cast(\`date\` as date)) AS ts, \
latitude, longitude, elevation, \`name\`, temp, temp_attributes, dewp, dewp_attributes, slp, slp_attributes, \
stp, stp_attributes, visib, visib_attributes, wdsp, wdsp_attributes, mxspd, gust, max, max_attributes, \
min, min_attributes, prcp, prcp_attributes, sndp, frshtt \
FROM raw_noaa \
WHERE \`year\` = ${year}"
docker compose -p air-quality-prediction exec -T \
    hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' -e "$sql"