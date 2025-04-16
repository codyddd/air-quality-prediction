#!/usr/bin/bash
year=$1
month=$2
sql="INSERT OVERWRITE TABLE ods_openaq_addr PARTITION (\`year\` = ${year}, \`month\` = ${month})  \
SELECT location_id, sensors_id, \`location\`, \`datetime\`, \
unix_timestamp(substr(\`datetime\`, 1, 19)) + cast(substr(\`datetime\`, 20, 3) as int) * -3600, \
lat, lon, \`parameter\`, units, \`value\`, a.country, a.country_name, a.state, a.city_name \
FROM ods_openaq o \
LEFT JOIN dim_coor_addr a \
  ON a.latitude = o.lat \
  AND a.longitude = o.lon \
WHERE \`year\` = ${year}
AND \`month\` = ${month}"
docker compose -p air-quality-prediction exec -T \
    hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' -e "$sql"