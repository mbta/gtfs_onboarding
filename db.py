from logging import basicConfig, info, debug, warn, DEBUG
import click
import json

import os

import sqlite3
import csv

from timeit import default_timer as timer
from datetime import timedelta

class Encoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, set):
            return tuple(o)
        elif isinstance(o, str):
            return o.encode('unicode_escape').decode('ascii')
        return super().default(o)

class StructuredMessage:
    def __init__(self, message, /, **kwargs):
        self.message = message
        self.kwargs = kwargs

    def __str__(self):
        e = Encoder()
        s = " ".join([f"{k}={e.encode(v)}" for k,v in self.kwargs.items()])
        return f'{self.message:>24} >>> {s}'

_ = StructuredMessage   # optional, to improve readability

EXAMPLE_FEED_URL = "https://cdn.mbtace.com/archive/20201002.zip"

DATA_TYPES = {
    "stop_sequence": "int"
}

@click.group()
def cli():
    pass

def create_db(gtfs_path, db_path):
    import glob

    with sqlite3.connect(db_path) as conn:
        info(_("connected to database", db_path=db_path))
        cursor = conn.cursor()


        info(_("reading gtfs files", path=gtfs_path))
        for file in glob.glob("*.txt", root_dir=gtfs_path):
            print()
            debug(_("reading gtfs file", filename=file))

            (table, ext) = os.path.splitext(os.path.basename(file))
            assert ext == ".txt"


            start, end = None, None
            with open(os.path.join(gtfs_path, file)) as csv_file:
                csvreader = csv.DictReader(csv_file)

                start = timer()
                populate_db(table, csvreader, cursor)
                end = timer()

            info(_("committing table", table=table, duration=str(timedelta(seconds=end-start) / timedelta(milliseconds=1)) + "ms"))
            conn.commit()


def populate_db(table_name, csv_reader: csv.DictReader, db_cursor: sqlite3.Cursor):
    keys = csv_reader.fieldnames
    fields = ", ".join([(key + " " + DATA_TYPES.get(key, "text")) for key in keys])

    debug(_("creating table", table=table_name))
    db_cursor.execute(f"CREATE TABLE {table_name} ({fields})")


    values = [[value for value in row.values()] for row in csv_reader]

    debug(_("inserting data", table=table_name))
    db_cursor.executemany(
        f"INSERT INTO {table_name} VALUES ({','.join(['?' for _ in keys])})", values
    )

def download_gtfs(gtfs_feed_zip_url=EXAMPLE_FEED_URL, out_folder="feed"):
    import io
    import requests
    from zipfile import ZipFile

    res = requests.get(gtfs_feed_zip_url)
    zip = ZipFile(io.BytesIO(res.content), "r")
    zip.extractall(out_folder)


@cli.command()
@click.argument('gtfs_feed_zip_url', type=click.STRING)
@click.argument('out_folder', type=click.Path())
def load_db(gtfs_feed_zip_url=EXAMPLE_FEED_URL, out_folder="feed"):
    """Download GTFS_FEED_ZIP_URL to OUT_FOLDER

    Generate a sqlite3 database named "$OUT_FOLDER".db
    """
    download_gtfs(gtfs_feed_zip_url, out_folder)

    db_path = out_folder + ".db"
    if os.path.exists(db_path):
        os.remove(db_path)

    create_db(out_folder, db_path)


if __name__ == '__main__':
    basicConfig(level=DEBUG, style="{", format='{asctime} {levelname:>8} {module:>6}:{funcName:<15} {message}')

    cli()
