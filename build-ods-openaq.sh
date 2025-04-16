#!/usr/bin/bash
year=$1
month=$2
sql="INSERT OVERWRITE TABLE ods_openaq PARTITION (\`year\` = ${year}, \`month\` = ${month})  \
SELECT location_id, sensors_id, \`location\`, \`datetime\`, \
unix_timestamp(substr(\`datetime\`, 1, 19)) + cast(substr(\`datetime\`, 20, 3) as int) * -3600, \
lat, lon, \`parameter\`, units, \`value\` \
FROM raw_openaq \
WHERE \`year\` = ${year}
AND \`month\` = ${month}"
docker compose -p air-quality-prediction exec -T \
    hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' -e "$sql"
