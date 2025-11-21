# Custom GT4Py Python Package Index Server
This repo hosts the custom packages that are needed to use GT4Py, these currently includes:
- [GridTools/dace](https://github.com/GridTools/dace), currently only for the `next`.
- [ghex-org/GHEX](https://github.com/ghex-org/GHEX)

# Usage
The repo is intended to work fully automatically, orchestrated by GitHub actions.

## Workflow `update-python-pkg-index.yml`
This is the main workflow, in short it does:
- Pulls the repo, whose package should be updated.
- Creates a wheel from the repo that has been pulled.
- Tests if the wheel can be installed.
- Updated the package index, i.e. regenerates the `index.html` files, for this `generator.py` is used.
- Creates a commit containing the updated indexes and the generated wheel.
- Pushes the new commit directly to `main`.

The workflow can be started manually, either through the GitHub web interface or through the `issue_update.sh` script.
In either case some information have to be provided:
- The name of the repo on GitHub, generally referred to as "source repo".
- The owner (user or organization) that owns the repo, generally referred to as "source owner".
- The branch of the repo from which a Python package should be created, generally referred to as "dependency ref".

## `generator.py`
Script for updating the static pages.
It works by scanning subfolders, currently `dace` and `ghex`, and creates an index based on all Python packages it founds in them.
It is usually run by by the workflow automatically.

## `issue_update.sh`
A simple script that allows to issue a manual remote update of the index.
For more information please see its help output.

## `update_workflows`
This folder contains the workflows that must be installed into the repos containing the dependency.

### DaCe
For DaCe the `dace-updater.yml` must be added to the DaCe repo.
It listens for pushes to tags `__gt4py-next-integration_*`, i.e. the ones that we use to tag our releases.

**TODO:** Figuring out where it should life, because I am sure it must life in `main`.


## Token
In order for the _depending_ repo to issue an update request an access token is needed.
This can either be a normal (classic) access token, that needs to grant read access to the repository.
The other possibility is to use a fine grained access token, in which case only the '"Contents" repository permissions (write)' permission has to be granted.

# TODO:
- Install in DaCe
- Install in GHEX
- Configure the page to use `main` as source.

