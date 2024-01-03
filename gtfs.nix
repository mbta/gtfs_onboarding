{
	perSystem = { lib, pkgs, self', ... }: let
			getGtfs = url: hash: pkgs.fetchzip {
				inherit url hash;
				stripRoot = false;
			};

			createDb = gtfs_data: filename: pkgs.runCommand filename { src = gtfs_data; } (lib.concatStringsSep "\n" [
				"${self'.packages.python}/bin/python ${./db.py} create-db ${gtfs_data} out.db"
				"mv out.db $out"
			]);
		in {
			packages.gtfs = self'.packages.mbta-gtfs-20201002;
			packages.gtfs-db = self'.packages.mbta-gtfs-20201002-db;

			packages.mbta-gtfs-20201002
				= getGtfs
					"https://cdn.mbtace.com/archive/20201002.zip"
					"sha256-LvCKEl+TvSe4XB3fes083cfa3KHL/tR4QQ1hTXvgMUA=";

			packages.mbta-gtfs-20201002-db
				= createDb
					self'.packages.mbta-gtfs-20201002
					"mbta-gtfs-20201002.db";

			packages.mbta-gtfs
				= getGtfs
					"https://cdn.mbta.com/MBTA_GTFS.zip"
					"sha256-PBsLqe7TY919e8HcATocI2GAVlLGr0fp4JjAAwNMzms=";

			packages.mbta-gtfs-db
				= createDb
					self'.packages.mbta-gtfs
					"mbta-gtfs.db";

			packages.denver-rtd-gtfs
				= getGtfs
					"https://www.rtd-denver.com/files/gtfs/google_transit.zip"
					"sha256-W5+f9gbIbJdgHUV+R+JSZdzK3JhzloiYfmTgCtpaN+s=";

			packages.denver-rtd-gtfs-db
				= createDb
					self'.packages.denver-rtd-gtfs
					"denver-rtd-gtfs.db";

			packages.nyc-bronx-gtfs
				= getGtfs
					"http://web.mta.info/developers/data/nyct/bus/google_transit_bronx.zip"
					"sha256-oj9UpPRO6MjoN0pMaaw1uCjY+cClqNEP/fB24Ziwbwg=";

			packages.nyc-bronx-gtfs-sqlitedb
				= createDb
					self'.packages.nyc-bronx-gtfs
					"nyc-bronx-gtfs.db";

			packages.nyc-manhattan-gtfs
				= getGtfs
					"http://web.mta.info/developers/data/nyct/bus/google_transit_manhattan.zip"
					"sha256-d8R59u5rcrHwDROiCB6V9Dwv6CSGAmp9EKJGaWf5HlM=";

			packages.nyc-manhattan-gtfs-db
				= createDb
					self'.packages.nyc-manhattan-gtfs
					"nyc-manhattan-gtfs.db";
		};
}
