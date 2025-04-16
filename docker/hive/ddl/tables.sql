CREATE TABLE IF NOT EXISTS `default`.`idx_openaq` (
    `provider` string,
    country string,
    locationid string,
    `year` string,
    `month` string,
    `date` string,
    file_path string
)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( 
  'escapeChar'='\\', 
  'quoteChar'='"', 
  'separatorChar'=',') 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';


CREATE TABLE IF NOT EXISTS `default`.`raw_openaq`(
  `location_id` string, 
  `sensors_id` string, 
  `location` string, 
  `datetime` string, 
  `lat` string, 
  `lon` string, 
  `parameter` string, 
  `units` string, 
  `value` string)
partitioned by (`year` int, `month` int)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( 
  'escapeChar'='\\', 
  'quoteChar'='"', 
  'separatorChar'=',') 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';



CREATE TABLE IF NOT EXISTS `default`.`ods_openaq`(
  `location_id` bigint, 
  `sensors_id` bigint, 
  `location` string, 
  `datetime` string, 
  `ts` bigint,
  `lat` string, 
  `lon` string, 
  `parameter` string, 
  `units` string, 
  `value` double)
partitioned by (`year` int, `month` int)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat';


CREATE TABLE IF NOT EXISTS `default`.`dim_openaq_location_addr`(
  `location` bigint, 
  `sensor` bigint,
  `latitude` string, 
  `longitude` string, 
  `country` string, 
  `country_name` string, 
  `state` string, 
  `city_name` string)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( 
  'escapeChar'='\\', 
  'quoteChar'='"', 
  'separatorChar'=',') 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';



CREATE TABLE IF NOT EXISTS `default`.`ods_openaq_addr`(
  `location_id` bigint, 
  `sensors_id` bigint, 
  `location` string, 
  `datetime` string, 
  `ts` bigint,
  `lat` double, 
  `lon` double, 
  `parameter` string, 
  `units` string, 
  `value` double,
  `country` string, 
  `country_name` string, 
  `state` string, 
  `city_name` string)
partitioned by (`year` int, `month` int)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat';


CREATE TABLE IF NOT EXISTS `default`.`idx_noaa` (
    `year` string,
    station string,
    file_path string
)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( 
  'escapeChar'='\\', 
  'quoteChar'='"', 
  'separatorChar'=',') 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';


CREATE TABLE IF NOT EXISTS `raw_noaa`(
  `station` string, 
  `date` string, 
  `latitude` string, 
  `longitude` string, 
  `elevation` string, 
  `name` string, 
  `temp` string, 
  `temp_attributes` string, 
  `dewp` string, 
  `dewp_attributes` string, 
  `slp` string, 
  `slp_attributes` string, 
  `stp` string, 
  `stp_attributes` string, 
  `visib` string, 
  `visib_attributes` string, 
  `wdsp` string, 
  `wdsp_attributes` string, 
  `mxspd` string, 
  `gust` string, 
  `max` string, 
  `max_attributes` string, 
  `min` string, 
  `min_attributes` string, 
  `prcp` string, 
  `prcp_attributes` string, 
  `sndp` string, 
  `frshtt` string)
partitioned by (`year` int)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( 
  'escapeChar'='\\', 
  'quoteChar'='"', 
  'separatorChar'=',') 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';


CREATE TABLE IF NOT EXISTS `ods_noaa`(
  `station` bigint, 
  `date` date, 
  `ts` bigint,
  `latitude` string, 
  `longitude` string, 
  `elevation` double, 
  `name` string, 
  `temp` double, 
  `temp_attributes` string, 
  `dewp` double, 
  `dewp_attributes` string, 
  `slp` double, 
  `slp_attributes` string, 
  `stp` double, 
  `stp_attributes` string, 
  `visib` double, 
  `visib_attributes` string, 
  `wdsp` double, 
  `wdsp_attributes` string, 
  `mxspd` double, 
  `gust` double, 
  `max` double, 
  `max_attributes` string, 
  `min` double, 
  `min_attributes` string, 
  `prcp` double, 
  `prcp_attributes` string, 
  `sndp` double, 
  `frshtt` double)
partitioned by (`year` int)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat';


CREATE TABLE `default`.`dim_noaa_station_addr`(
  `station` bigint, 
  `latitude` string, 
  `longitude` string, 
  `country` string, 
  `country_name` string, 
  `state` string, 
  `city_name` string)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( 
  'escapeChar'='\\', 
  'quoteChar'='"', 
  'separatorChar'=',') 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';


CREATE TABLE IF NOT EXISTS `ods_noaa_addr`(
  `station` bigint, 
  `date` date, 
  `ts` bigint,
  `latitude` string, 
  `longitude` string, 
  `elevation` double, 
  `name` string, 
  `temp` double, 
  `temp_attributes` string, 
  `dewp` double, 
  `dewp_attributes` string, 
  `slp` double, 
  `slp_attributes` string, 
  `stp` double, 
  `stp_attributes` string, 
  `visib` double, 
  `visib_attributes` string, 
  `wdsp` double, 
  `wdsp_attributes` string, 
  `mxspd` double, 
  `gust` double, 
  `max` double, 
  `max_attributes` string, 
  `min` double, 
  `min_attributes` string, 
  `prcp` double, 
  `prcp_attributes` string, 
  `sndp` double, 
  `frshtt` double,
  `country` string, 
  `country_name` string, 
  `state` string, 
  `city_name` string)
partitioned by (`year` int)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat';



CREATE TABLE IF NOT EXISTS `default`.`dim_coor_addr`(
  `latitude` string, 
  `longitude` string, 
  `country` string, 
  `country_name` string, 
  `state` string, 
  `city_name` string)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( 
  'escapeChar'='\\', 
  'quoteChar'='"', 
  'separatorChar'=',') 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';
