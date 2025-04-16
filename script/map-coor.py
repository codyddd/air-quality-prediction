import requests
import argparse
import csv


def get_station_details(lat, lon, proxy=''):
    """Reverse geocoding using Nominatim API"""
    print(f"https://nominatim.openstreetmap.org/reverse.php?lat={lat}&lon={lon}&zoom=10&format=jsonv2")
    headers = {
        'User-Agent': 'Wget/1.12 (linux-gnu)', 
        'Accept-Encoding': 'gzip, deflate', 
        'Accept-Language': 'en',
    }
    url = f"{proxy}https://nominatim.openstreetmap.org/reverse.php?lat={lat}&lon={lon}&zoom=10&format=jsonv2"
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = response.json()
        
        return {
            'latitude': lat,
            'longitude': lon,
            'country': data.get('address', {}).get('country_code', ''),
            'country_name': data.get('address', {}).get('country', ''),
            'state': data.get('address', {}).get('ISO3166-2-lvl4', ''),
            'city_name': data.get('name', '')
        }
    except Exception as e:
        print(f"Error processing coordinates ({lat}, {lon}): {str(e)}")
        return {}


parser = argparse.ArgumentParser(description="Map latitude and longitude to city")
parser.add_argument('--lat', type=str, required=True, help="latitude")
parser.add_argument('--lon', type=str, required=True, help="longitude")
parser.add_argument('--output', type=str, required=True, help="output file path, e.g. /tmp/some-file.csv")
parser.add_argument('--proxy', type=str, default='', required=False, help="proxy to use, e.g. https://some.proxy-url.com/")


args = parser.parse_args()

latitude = args.lat
longitude = args.lon
output = args.output
proxy = args.proxy

details = get_station_details(latitude, longitude, proxy)
print(f'coordinate ({latitude}, {longitude}) mapped to {details["city_name"]}, {details["country_name"]}')
file = open(output, "a")
headers = ['latitude', 'longitude', 'country', 'country_name', 'state', 'city_name']
writer = csv.DictWriter(file, fieldnames=headers)
writer.writerow(details)