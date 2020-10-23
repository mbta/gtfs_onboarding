import sqlite3
import io
import os
import sys
from zipfile import ZipFile
import requests
import glob
import csv

EXAMPLE_FEED_URL = "https://cdn.mbtace.com/archive/20201002.zip"

DATA_TYPES = {
    "stop_sequence": "int"
}

def load_db(gtfs_feed_zip_url):
    if os.path.exists("feed.db"):
        os.remove("feed.db")
    res = requests.get(gtfs_feed_zip_url)
    zip = ZipFile(io.BytesIO(res.content), "r")
    zip.extractall("feed")
    conn = sqlite3.connect('feed.db')
    c = conn.cursor()

    for file in glob.glob("feed/*.txt"):
        table = file.split("feed/")[1].split(".")[0]
        with open(file) as csv_file:
            csvreader = csv.DictReader(csv_file)
            keys = csvreader.fieldnames
            fields = ", ".join([(key + " " + DATA_TYPES.get(key, "text")) for key in keys])
            c.execute(f"CREATE TABLE {table} ({fields})")
            values = [[v for v in row.values()] for row in csvreader]
            c.executemany(
                f"INSERT INTO {table} VALUES ({','.join(['?' for key in keys])})", values
            )
    conn.commit()

    conn.close()


if __name__ == '__main__':
    try:
        load_db(sys.argv[1])
    except IndexError:
        load_db(EXAMPLE_FEED_URL)
