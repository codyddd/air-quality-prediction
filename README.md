# Air Quality Prediction

Follow this instruction to properly deploy this application locally.
- Initialize Python enviroment according to `requirements.txt`
- Run ./docker/compose.sh to set up docker containers
- When Hive server container is up and running, execute ./init-hive.sh to initialize Hive database
- Run `python ./build-index-noaa.py` to build an index on all the files available on S3 for NOAA
- Run `python ./build-index-openaq.py` to build an index on all the files available on S3 for OpenAQ
- Run `bash ./download-noaa.sh` to download NOAA files and load them to hive as raw data
- Run `bash ./download-openaq.sh` to download OpenAQ files and load them to hive as raw data
- Run `bash ./build-ods-noaa.sh` to transform NOAA data to proper data type
- Run `bash ./build-ods-openaq.sh` to transform OpenAQ data to proper data type
- Run `bash ./build-dim-location.sh` to extract all unique combination of latitude and longitude from NOAA and OpenAQ datasets, then using a third-party API services to map them to city
- Run `bash ./build-ods-noaa-addr.sh` to curate NOAA data with corresponding city
- Run `bash ./build-ods-openaq-addr.sh` to curate OpenAQ data with corresponding city

For data scientists, install `jupyter lab` and work on `training.ipynb` for model training tasks and collaboration.

To serve a AQI prediction server, run `python serve.py`

This application depends on `parallel` package, install it with `sudo apt install parallel` for Ubuntu Server.
