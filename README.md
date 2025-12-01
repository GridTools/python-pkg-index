# Custom GT4Py Python Package Index Server
This repo hosts the custom packages that are needed to use GT4Py, these currently includes:
- [GridTools/dace](https://github.com/GridTools/dace), currently only for the `next`.
- [ghex-org/GHEX](https://github.com/ghex-org/GHEX)


# Usage
The repo is intended to work fully automatically, orchestrated by GitHub actions.
See also the design section below.

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

> According to the [documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#repository_dispatch) the
> `repository_dispatch` trigger (the one that is used such that _other_ repo can start the update) only works when
> the workflow file is located on the default branch!

## `generator.py`
Script for updating the static pages.
It works by scanning subfolders, currently `dace` and `ghex`, and creates an index based on all Python packages it founds in them.
It is usually run by by the workflow automatically.

## `issue_update.sh`
A simple script that allows to issue a manual remote update of the index.
For more information please see its help output.

## `update_workflows`
This folder contains the workflows that must be installed into the repos containing the dependency.
These workflows then triggers the update chain.

### DaCe
For DaCe the `dace-updater.yml` must be added to the DaCe repo.
It listens for pushes to tags `__gt4py-next-integration_*`, i.e. the ones that we use to tag our releases.
There is an [_experimental_ branch](https://github.com/GridTools/dace/pull/12) that tests the workflow using the [development index](https://github.com/philip-paul-mueller/test_package_index).
It kind of works, however, currently only pushes related to the branch itself are detected, i.e. the branch that contains the workflow file.
This means, that the workflow file must be included inside `gt4py-next-integration` branch, that is used to deploy the thing, which is not so nice.   
As an experiment, I changed the default branch from `main` to the experimental one, without success, but it might be due to the mentioned "unintended side effects" that a popup was informing me.

## Token
In order for the _depending_ repo to issue an update request an access token is needed.
This can either be a normal (classic) access token, that needs to grant read access to the repository.
The other possibility is to use a fine grained access token, in which case only the '"Contents" repository permissions (write)' permission has to be granted.


# Design and Working
The index works currently in "pull mode".
This means that the dependent repos, i.e. DaCe or GHEX, informs the index (this repo), that a new version is available.
The index will then download the depending repo, build the Python package and update the html pages.

However, it would be conceptually simpler, if the index is passive, i.e. if the dependent repos would build the Python package themself and push it to the index.
This design, "push mode", should become the new operation mode in the future.


# TODO:
- Install in DaCe
- Install in GHEX
- Configure the page to use `main` as source.

