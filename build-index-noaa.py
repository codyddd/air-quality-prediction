import boto3
from botocore.client import Config
from botocore import UNSIGNED
import re
from pyhive import hive
import csv

class StorageNOAA:
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
        return 'noaa-gsod-pds'


def extract_params(prefix):
    match = re.search(r'(\d{4})/(\d+).csv', prefix)
    if match:
        return {
            "year": match.group(1),
            "station": match.group(2),
            "file_path": prefix
        }

def download_remote_data(file_name):
    source_s3 = StorageNOAA.conn()

    locations = source_s3.list_objects_v2(Bucket=StorageNOAA.getBucket())
    file = open(f"./docker/hive/raw-data/{file_name}", "a")
    headers = ['year', 'station', 'file_path']
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
        locations = source_s3.list_objects_v2(Bucket=StorageNOAA.getBucket(), ContinuationToken=locations['NextContinuationToken'])
    return

def load_to_hive(conn, file_name):
    sql = f"LOAD DATA LOCAL INPATH '/var/raw-data/{file_name}' OVERWRITE INTO TABLE idx_noaa"
    cursor = conn.cursor()
    cursor.execute(sql)
    cursor.close()

def main():
    file_name = "index-noaa.csv"
    download_remote_data(file_name)
    conn = hive.Connection(host='localhost', port=10000)
    load_to_hive(conn, file_name)

if __name__ == '__main__':
    main()