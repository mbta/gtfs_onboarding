{
	description = "GTFS Onboarding Flake";

	nixConfig.extra-substituters = [
		"https://tweag-jupyter.cachix.org"
	];
	nixConfig.extra-trusted-public-keys = [
		"tweag-jupyter.cachix.org-1:UtNH4Zs6hVUFpFBTLaA4ejYavPo5EFFqgd7G7FxGW9g="
	];


	inputs.devshell.url = "github:numtide/devshell";
	inputs.flake-parts.url = "github:hercules-ci/flake-parts";
	inputs.jupyterWith.url = "github:GTrunSec/jupyterWith/chore";

	inputs.nixpkgs.url = "flake:nixpkgs";

	inputs.devshell.inputs.nixpkgs.follows = "/nixpkgs";

	inputs.flake-parts.inputs.nixpkgs-lib.follows = "/nixpkgs";

	inputs.jupyterWith.inputs.nixpkgs.follows = "/nixpkgs";
	inputs.jupyterWith.inputs.nixpkgs-stable.follows = "/nixpkgs";

	inputs.sqlite-notebook.url = "github:firestack/sqlite-notebook/feat/jupyter-with-module";
	inputs.sqlite-notebook.inputs.nixpkgs.follows = "/nixpkgs";
	inputs.sqlite-notebook.inputs.flake-utils.follows = "/jupyterWith/flake-utils";

	outputs = inputs@{ self, flake-parts, jupyterWith, devshell, ... }:
		flake-parts.lib.mkFlake { inherit inputs; } {
			imports = [
				devshell.flakeModule
				./gtfs.nix
			];

			systems = [
				"aarch64-darwin"
				"aarch64-linux"
				"i686-linux"
				"x86_64-darwin"
				"x86_64-linux"
			];

			perSystem = { system, pkgs, lib, self', inputs', ... }: {
				apps.interactive-read-only = let
					notebook_dir = pkgs.symlinkJoin {
						name = "notebook-work-dir";
						paths = [
							self
						];
						postBuild = "ln -s ${self'.packages.gtfs-db} $out/feed.db";
					};
				in {
					type = "app";
					program = pkgs.writeShellApplication {
						name = "test";
						text = lib.concatStringsSep "\n" [
							"${self'.packages.default}/bin/${self'.packages.default.meta.mainProgram} --notebook-dir=${notebook_dir}"
						];
					};
				};
				packages.default = self'.packages.lab;

				devshells.default = {
					packages = [
						self'.packages.python

						pkgs.sqlite

						pkgs.nil
					];
				};

				packages.lab = self'.legacyPackages.jupyterlab.config.build;
				packages.lab-sqlite = self'.legacyPackages.jupyterlab-sqlite.config.build;
				packages.lab-python = self'.legacyPackages.jupyterlab-python.config.build;

				legacyPackages.jupyterWithModules.pkgs = { nixpkgs = pkgs; };

				legacyPackages.jupyterWithModules.python = {
					kernel.python.default = {
						enable = true;
						displayName = "Python3 Kernel";
						env = self'.packages.python;
					};
				};

				legacyPackages.jupyterWithModules.sqlite = {
					imports = [
						inputs.sqlite-notebook.jupyterWithModules.${system}.default
					];

					kernel.sqlite.default.enable = true;
				};

				legacyPackages.jupyterlab = inputs.jupyterWith.lib.${system}.mkJupyterlabEval ({
					imports = [
						self'.legacyPackages.jupyterWithModules.pkgs
						self'.legacyPackages.jupyterWithModules.python
						self'.legacyPackages.jupyterWithModules.sqlite
					];
				});

				legacyPackages.jupyterlab-python = inputs.jupyterWith.lib.${system}.mkJupyterlabEval ({
					imports = [
						self'.legacyPackages.jupyterWithModules.pkgs
						self'.legacyPackages.jupyterWithModules.python
					];
				});

				legacyPackages.jupyterlab-sqlite = inputs.jupyterWith.lib.${system}.mkJupyterlabEval ({
					imports = [
						self'.legacyPackages.jupyterWithModules.pkgs
						self'.legacyPackages.jupyterWithModules.sqlite
					];
				});

				packages.python = pkgs.python3.withPackages (ps:
					with ps; [
						ps.ipykernel
						ps.sqlalchemy
						(ps.ipython-sql.overridePythonAttrs (_: {
							version = "0.5.0-eb274844b4a619463149e0d57df705e1bba47635";
							src = pkgs.fetchFromGitHub {
								owner = "catherinedevlin";
								repo = "ipython-sql";
								rev = "eb274844b4a619463149e0d57df705e1bba47635";
								hash = "sha256-MNR6TDKdkHTtVWMWg1hmk+Uf5/r/caNdLImyoPqKW+Q=";
							};
						}))
						ps.pandas
						ps.requests

						ps.scipy
						ps.matplotlib

						ps.click
					]);

				checks = {
					defaultPackage = self'.packages.default;
					defaultDevshell = self'.devShells.default;

					inherit (self'.packages)
						python lab lab-sqlite lab-python;
				};
			};
		};
}
