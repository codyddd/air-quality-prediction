import boto3
from botocore.client import Config
from botocore import UNSIGNED
import re
from datetime import datetime
from pyhive import hive
import csv

class StorageOpenAQ:
    @staticmethod
    def conn():
        return boto3.client(
            's3', 
            region_name='us-east-1', 
            aws_access_key_id=None, 
            aws_secret_access_key=None, 
            config=Config(signature_version=UNSIGNED)
        )
    @staticmethod
    def getBucket():
        return 'openaq-data-archive'

def extract_params(prefix):
    # records/csv.gz/locationid=1/year=2006/month=11/location-1-20061127.csv.gz
    # records/csv.gz/provider=stateair/country=xk/locationid=7674/year=2023/month=04/location-7674-20230405.csv.gz
    path_fraction = prefix.split('/')[2:]
    filename = path_fraction.pop()
    match = re.search(r'location-\d+-(\d{8}).csv.gz', filename)
    date = datetime.strptime(match.group(1), '%Y%m%d').strftime('%Y-%m-%d')
    params = {k: v for k, v in (item.split('=') for item in path_fraction)}
    missing_keys = {"provider": "", "country": ""}
    return {**missing_keys, **params, "date": date, "file_path": prefix}
    
def download_remote_data(file_name):
    source_s3 = StorageOpenAQ.conn()
    prefix = f'records/csv.gz/'

    locations = source_s3.list_objects_v2(Bucket=StorageOpenAQ.getBucket(), Prefix=prefix)
    file = open(f"./docker/hive/raw-data/{file_name}", "w")
    headers = ['provider', 'country', 'locationid', 'year', 'month', 'date', 'file_path']
    writer = csv.DictWriter(file, fieldnames=headers)
    count = 0 
    while 'NextContinuationToken' in locations:
        for obj in locations.get('Contents', []):
            file_path = obj['Key']
            print(file_path)
            params = extract_params(file_path)
            writer.writerow(params)
            count += 1
            if count > 10:
                return
        locations = source_s3.list_objects_v2(Bucket=StorageOpenAQ.getBucket(), Prefix=prefix, ContinuationToken=locations['NextContinuationToken'])
    return

def load_to_hive(conn, file_name):
    sql = f"LOAD DATA LOCAL INPATH '/var/raw-data/{file_name}' OVERWRITE INTO TABLE idx_openaq"
    cursor = conn.cursor()
    cursor.execute(sql)
    cursor.close()

def main():
    # print(extract_params('records/csv.gz/locationid=1/year=2006/month=11/location-1-20061127.csv.gz'))
    # print(extract_params('records/csv.gz/provider=stateair/country=xk/locationid=7674/year=2023/month=04/location-7674-20230405.csv.gz'))
    # exit()
    file_name = "index-openaq.csv"
    download_remote_data(file_name)
    conn = hive.Connection(host='localhost', port=10000)
    load_to_hive(conn, file_name)

if __name__ == '__main__':
    main()