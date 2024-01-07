# gtfs_onboarding
A [Jupyter Notebook](https://docs.jupyter.org/en/latest/#what-is-a-notebook)
workspace for exploring [GTFS][GTFS] data via 
[SQLite3](https://www.sqlite.org/index.html) and optionally [Python](https://www.python.org/).
Configured and provided via [Nix][nix].


## Table of Contents
1. [Getting Started](#getting-started)
	1. [Requirements](#requirements)
	2. [(Very) Quick Start](#very-quick-start)
	3. [Local Quick Start with persistance (save and resume)](#local-quick-start-with-persistance-save-and-resume)
	4. [Opening the notebook](#opening-the-notebook)
2. [Notes](#notes)
	1. [Running specific kernels](#running-specific-kernels)
		1. [Running the SQLite Kernel without Python and the Python Kernel](#running-the-sqlite-kernel-without-python-and-the-python-kernel)
		2. [Running the Python Kernel without the SQLite3 Kernel](#running-the-python-kernel-without-the-sqlite3-kernel)
	2. [Loading different GTFS feeds](#loading-different-gtfs-feeds)
	3. [Firefox Slowness](#firefox-slowness)

## Getting Started
### Requirements
- a [Nix][nix] installation [^nix-installer]
	- must have the following `experimental-features`[^at-time-of-writing]
		- `flakes`
		- `nix-command`

### (Very) Quick Start
> [!WARNING]
> Using this method, you __cannot__ save your progress.
>
> Use the [Local Quick Start](#local-quick-start-with-persistance-save-and-resume)
> method if you wish to save your progress.
>
> This method is great for quickly getting the notebook up
> and running with all data populated, but not great for
> learners who wish to save their progress.
>
> This is because the notebook will be downloaded to the
> nix store and will be read-only.

Using [Nix][nix], we can start [JupyterLab](https://jupyter.org/)
and load the notebook with a single command. 


```sh
: nix run github:firestack/gtfs_onboarding.nix#interactive-read-only
```

This command does the following:
1. Runs the nix flake app named `interactive-read-only` which
	1. downloads the [flake repository](https://github.com/firestack/gtfs_onboarding.nix)
		into the nix store then:
		- builds the jupyter lab and kernels needed.
		- downloads the associated GTFS data and:
			- creates a SQLite3 database using the downloaded 
				GTFS data.
	1. starts `jupyter-lab` in a directory containing:
		- the notebooks and associated data.
		- the GTFS SQLite database.
1. next, follow the instructions in the [section: opening the notebook](#opening-the-notebook).

---

### Local Quick Start with persistance (save and resume)
1) Clone this repository
	```sh
	: git clone https://github.com/firestack/gtfs_onboarding.nix.git
	```
2) Enter the directory
	```sh
	: cd ./gtfs_onboarding.nix
	```

#### Direnv
3.
	1. load the necessary dependencies into your shell using `direnv`
		```
		: direnv allow
		```

	4. Then run the `jupyter-lab` command to start the notebook server.
		```sh
		: jupyter-lab
		```

#### Nix Flakes
3.
	1. Run via nix flakes
		```sh
		: nix run
		```

---

### Opening the notebook

> [!IMPORTANT]
> __(Prerequisite)__ Start Jupyter Notebook
> - [(Very) Quick Start](#very-quick-start)
> - [Local Quick Start](#local-quick-start-with-persistance-save-and-resume)


1. In the terminal output, find and click on link with
authentication token

> [!TIP]
> afterwards, you can just navigate to
> [`localhost:8888`](http://localhost:8888) in that same
> browser.

Here's an example of the links to look out for in the terminal window.
> ```
> To access the server, open this file in a browser:
> 	file:///.jupyter/runtime/jpserver-00000-open.html
> Or copy and paste one of these URLs:
> 	http://localhost:8888/lab?token=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
> 	http://127.0.0.1:8888/lab?token=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
> ```

2. Open file `GTFS Onboarding.sqlite3.ipynb`
	1. For a Python notebook, you can also open `GTFS Onboarding.python.ipynb`
3. Enjoy!

## Notes
### Running specific kernels
#### Running the SQLite Kernel without Python and the Python Kernel
Runs the notebook with only the SQLite kernel loaded. 
This will skip downloading the python dependencies and 
building the Python environment.
```sh
: nix run .#lab-sqlite
```

#### Running the Python Kernel without the SQLite3 Kernel
Runs the notebook with only the Python kernel loaded.
This will download the Python dependencies and configure
the Python environment and will not download or build
the SQLite kernel.
```sh
: nix run .#lab-python
```

---

### Loading different GTFS feeds
The [gtfs.nix file](./gtfs.nix) contains content addressed[^at-time-of-writing]
definitions for other [GTFS][GTFS] feeds which can be loaded.
These can be loaded into the environment using the [Local start method](#local-quick-start-with-persistance-save-and-resume) and 
building the relevant GTFS database.

For example, the command
```sh
: nix build -o mbta-20201002.db .#mbta-gtfs-20201002
# OR
: nix build -o mbta-20201002.db github:firestack/gtfs_onboarding.nix#mbta-gtfs-20201002
```
will download the archived GTFS feed and build a SQLite3
database, and then link it to a file in your working 
directory named `mbta-20201002.db`.

Then, in the notebook, you'll need to change the name of the
database passed to the open command.

Alternatively, you can build the database and overwrite the `feed.db` link:
```sh
: nix build -o feed.db .#mbta-gtfs-20201002
```

---

### Firefox Slowness
__JupyterLab__ seems to have difficulty running on Firefox,
with symptoms of being extremely slow and unresponsive.
Using Safari or Chrome have been a stable alternative for
running the notebooks[^at-time-of-writing].

---

[nix]: https://nixos.org/
[GTFS]: https://gtfs.org/

[^nix-installer]: [Nix installer which enables flakes and nix-command by default](https://github.com/DeterminateSystems/nix-installer/)
[^at-time-of-writing]: At time of writing.
