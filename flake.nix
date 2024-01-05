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

	outputs = inputs@{ self, flake-parts, jupyterWith, devshell, ... }:
		flake-parts.lib.mkFlake { inherit inputs; } {
			imports = [
				devshell.flakeModule
			];

			systems = [
				"aarch64-darwin"
				"aarch64-linux"
				"i686-linux"
				"x86_64-darwin"
				"x86_64-linux"
			];

			perSystem = { system, pkgs, self', inputs', ... }: {
				packages.default = self'.packages.lab;

				devshells.default = {
					packages = [
						pkgs.sqlite
						self'.packages.jupyterlab

						pkgs.nil
					];
				};

				packages.lab = self'.legacyPackages.jupyterlab.config.build;
				packages.lab-python = self'.legacyPackages.jupyterlab-python.config.build;

				legacyPackages.jupyterWithModules.pkgs = { nixpkgs = pkgs; };

				legacyPackages.jupyterWithModules.python = {
					kernel.python.default = {
						enable = true;
						displayName = "Python3 Kernel";
						env = self'.packages.python;
					};
				};

				legacyPackages.jupyterlab = inputs.jupyterWith.lib.${system}.mkJupyterlabEval ({
					imports = [
						self'.legacyPackages.jupyterWithModules.pkgs
						self'.legacyPackages.jupyterWithModules.python
					];
				});

				legacyPackages.jupyterlab-python = inputs.jupyterWith.lib.${system}.mkJupyterlabEval ({
					imports = [
						self'.legacyPackages.jupyterWithModules.pkgs
						self'.legacyPackages.jupyterWithModules.python
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
					]);
			};
		};
}
