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
This folder contains the workflows that must be installed into the repos containing the dependency, these workflows then triggers the update chain.
Here are the steps that are needed to install them.


### Token
The first step is to create an access token for the package index.
It is recommended that a [fine grained access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#fine-grained-personal-access-tokens) is used.
The token should only grant access to the index repo and must have the '"Contents" repository permissions (write)' permission.

Then you must install the token in the depending repo, the updater workflow expect the nae `PKG_UPDATE_TOKEN`.


### General Process of Installing the Workflow
The installations of workflows is not straight forward.
First you must activate (uncomment) the `pull_request` trigger and push it.
The net effect is that it will run once and GitHub will pick it up then.
Afterwards you have to disable that trigger again.


### DaCe
For DaCe the `dace-updater.yml` must be added to the DaCe repo.
Follow the steps above and place it in its [own dedicated PR](https://github.com/GridTools/dace/pull/12).
Note that it only works if this PR is is included in the `gt4py-next-integration` branch, see [these instructions](https://github.com/GridTools/dace/pull/1).

The workflow listens for pushes to tags for the form `__gt4py-next-integration_*`, if such a push is detected, it will then inform the index repo about the new version.


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

