# gtfs_onboarding
A Jupyter Notebook workspace for exploring GTFS data via SQLite3.

## Getting Started
### (Very) Quick Start
This method is great for quickly getting the notebook up and running
with all data populated

Using nix, we can start the JupyterLab and notebook with a single command. 

> [!WARNING]
> Using this method, you __cannot__ save your progress.
>
> This is because the notebook will be downloaded to the
> nix store and will be read-only.
> 
> You can save your progress to a file outside the nix store,
> but changes will not be picked up by subsequent runs of
> this command.

```
nix run github:firestack/gtfs_onboarding.nix/feat/sqlite-kernel
```

This command shall download the repository into the nix store, then build the jupyter lab and kernels needed.

Simultaneously, it'll download the associated GTFS data and create a SQLite3 database from the data.

Then, nix will run a command which starts `jupyter-lab` in a directory containing the notebooks, associated data, and the GTFS SQLite database.

Then continue with the [section: opening the notebook](#opening-the-notebook).

---

### Local Quick Start with persistance (save and resume)
1) Clone this repository
2) Enter the directory

#### Direnv
If using `direnv`, first run
```
direnv allow
```
To load the nesisary dependencies into your shell.

Then run
```
jupyter-lab
```
to start the notebook server.

#### Nix run
```
nix run .#lab
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
>	To access the server, open this file in a browser:
>		file:///.jupyter/runtime/jpserver-00000-open.html
>	Or copy and paste one of these URLs:
>		http://localhost:8888/lab?token=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
>		http://127.0.0.1:8888/lab?token=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
> ```

2. Open file `GTFS Onboarding.ipynb`
3. Enjoy!

## Notes
### Firefox Slowness
JupyterLab seems to have difficulty running on Firefox, with symptoms of being extremely slow and unresponsive. Using Safari or Chrome have been
a stable alternative for running the notebook, as of writing.
