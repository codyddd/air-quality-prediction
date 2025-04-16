#!/usr/bin/bash
year=$1
month=$2
country=$3
echo $year $country
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo $SCRIPT_DIR
sql="SELECT \
concat('s3://openaq-data-archive/', file_path) as file_path, \
concat('openaq-', country, '-', \`date\`,'.csv.gz') as local_path \
FROM idx_openaq \
WHERE \`year\` = ${year} \
AND \`month\` = ${month} \
AND country = '${country}'"
echo $sql

docker compose -p air-quality-prediction exec \
hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' \
--outputformat=csv2 --showHeader=false -e "$sql" > $SCRIPT_DIR/docker/hive/raw-data/s3-params-openaq.csv

downlaod_path="$SCRIPT_DIR/docker/hive/raw-data/openaq/$year/$month/"
combined_file="openaq-${year}-${month}-combined.csv"
mkdir -p $downlaod_path
cat $SCRIPT_DIR/docker/hive/raw-data/s3-params-openaq.csv | parallel --progress -j 100 --colsep ',' aws s3 --no-sign-request cp {1} ${downlaod_path}{2}
rm ${downlaod_path}${combined_file}
awk -F, '{print $2}' $SCRIPT_DIR/docker/hive/raw-data/s3-params-openaq.csv | parallel --progress -j 100 "zcat ${downlaod_path}{1} | sed '1d'" >> ${downlaod_path}${combined_file}

load_sql="LOAD DATA LOCAL INPATH '/var/raw-data/openaq/${year}/${month}/${combined_file}' OVERWRITE INTO TABLE raw_openaq PARTITION (\`year\` = ${year}, \`month\` = ${month});"
echo $load_sql
docker compose -p air-quality-prediction exec \
hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' \
--outputformat=csv2 --showHeader=false -e "$load_sql"