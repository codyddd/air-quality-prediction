SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

sql_drop="DROP TABLE IF EXISTS dim_coor_addr_tmp"
docker compose -p air-quality-prediction exec -T \
hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' -e "$sql_drop"

sql_create="CREATE TABLE dim_coor_addr_tmp LIKE dim_coor_addr"
docker compose -p air-quality-prediction exec -T \
hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' -e "$sql_create"

rm $SCRIPT_DIR/docker/hive/raw-data/noaa-yr.csv
sql_noaa_yr="SELECT DISTINCT \`year\` FROM raw_noaa"
docker compose -p air-quality-prediction exec -T \
hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' \
--outputformat=csv2 --showHeader=false -e "$sql_noaa_yr" > $SCRIPT_DIR/docker/hive/raw-data/noaa-yr.csv

while read -r year
do
  rm $SCRIPT_DIR/docker/hive/raw-data/map-coor-noaa-$year.csv
  sql="SELECT DISTINCT latitude, longitude FROM raw_noaa WHERE \`year\` = ${year}"
  docker compose -p air-quality-prediction exec -T \
  hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' \
  --outputformat=csv2 --showHeader=false -e "$sql" \
  >> $SCRIPT_DIR/docker/hive/raw-data/map-coor-noaa-$year.csv
done < $SCRIPT_DIR/docker/hive/raw-data/noaa-yr.csv

while read -r year
do
  rm $SCRIPT_DIR/docker/hive/raw-data/dim-coor-addr-tmp-$year.csv
  cat $SCRIPT_DIR/docker/hive/raw-data/map-coor-noaa-$year.csv \
  | parallel --progress -j 10 --colsep ',' python $SCRIPT_DIR/script/map-coor.py --lat "{1}" --lon "{2}" --output $SCRIPT_DIR/docker/hive/raw-data/dim-coor-addr-tmp-$year.csv
done < $SCRIPT_DIR/docker/hive/raw-data/noaa-yr.csv

while read -r year
do
  sql_ins="LOAD DATA LOCAL INPATH '/var/raw-data/dim-coor-addr-tmp-$year.csv' INTO TABLE dim_coor_addr_tmp"
  docker compose -p air-quality-prediction exec -T hiveserver2 beeline -u "jdbc:hive2://localhost:10000/default" --showHeader=false -e "$sql_ins"
done < $SCRIPT_DIR/docker/hive/raw-data/noaa-yr.csv

sql_replace="INSERT OVERWRITE TABLE dim_coor_addr SELECT * FROM dim_coor_addr_tmp"
docker compose -p air-quality-prediction exec -T hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' -e "$sql_replace"