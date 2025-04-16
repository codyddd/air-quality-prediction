#!/usr/bin/bash
year=$1
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
sql="SELECT \
concat('s3://noaa-gsod-pds/', file_path) as file_path, \
concat('noaa-', station, '-', \`year\`, '.csv') as local_path \
FROM idx_noaa \
WHERE \`year\` = ${year}"

docker compose -p air-quality-prediction exec \
hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' \
--outputformat=csv2 --showHeader=false -e "$sql" > $SCRIPT_DIR/docker/hive/raw-data/s3-params-noaa.csv

downlaod_path="$SCRIPT_DIR/docker/hive/raw-data/noaa/$year/"
combined_file="noaa-${year}-combined.csv"
mkdir -p $downlaod_path
cat $SCRIPT_DIR/docker/hive/raw-data/s3-params-noaa.csv | parallel --progress -j 100 --colsep ',' aws s3 --no-sign-request cp {1} ${downlaod_path}{2}
rm ${downlaod_path}${combined_file}
awk -F, '{print $2}' $SCRIPT_DIR/docker/hive/raw-data/s3-params-noaa.csv | parallel --progress -j 100 sed '1d' ${downlaod_path}{1} >> ${downlaod_path}${combined_file}

load_sql="LOAD DATA LOCAL INPATH '/var/raw-data/noaa/${year}/${combined_file}' OVERWRITE INTO TABLE raw_noaa PARTITION (\`year\` = ${year});"
echo $load_sql
docker compose -p air-quality-prediction exec \
hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' \
--outputformat=csv2 --showHeader=false -e "$load_sql"



