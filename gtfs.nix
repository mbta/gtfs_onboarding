{
	perSystem = { lib, pkgs, self', ... }: let
			getGtfs = url: hash: pkgs.fetchzip {
				inherit url hash;
				stripRoot = false;
			};
		in {
			packages.gtfs = self'.packages.mbta-gtfs-20201002;

			packages.mbta-gtfs-20201002
				= getGtfs
					"https://cdn.mbtace.com/archive/20201002.zip"
					"sha256-LvCKEl+TvSe4XB3fes083cfa3KHL/tR4QQ1hTXvgMUA=";

			packages.mbta-gtfs
				= getGtfs
					"https://cdn.mbta.com/MBTA_GTFS.zip"
					"sha256-PBsLqe7TY919e8HcATocI2GAVlLGr0fp4JjAAwNMzms=";

			packages.denver-rtd-gtfs
				= getGtfs
					"https://www.rtd-denver.com/files/gtfs/google_transit.zip"
					"sha256-W5+f9gbIbJdgHUV+R+JSZdzK3JhzloiYfmTgCtpaN+s=";

			packages.nyc-bronx-gtfs
				= getGtfs
					"http://web.mta.info/developers/data/nyct/bus/google_transit_bronx.zip"
					"sha256-oj9UpPRO6MjoN0pMaaw1uCjY+cClqNEP/fB24Ziwbwg=";

			packages.nyc-manhattan-gtfs
				= getGtfs
					"http://web.mta.info/developers/data/nyct/bus/google_transit_manhattan.zip"
					"sha256-d8R59u5rcrHwDROiCB6V9Dwv6CSGAmp9EKJGaWf5HlM=";
		};
}
