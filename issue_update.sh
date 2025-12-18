#!/bin/bash

# Location of the repo that hosts the actuall index.
INDEX_ORGANIZATION="gridtools"
INDEX_REPO="python-pkg-index"
SCRIPT_FOLDER="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

SOURCE_REPO=""
SOURCE_ORG=""
DEPENDENCY_REF=""

while [ $# -gt 0 ]
do
	ARG="$1"
	shift
	case "${ARG}" in
	  --source-repo)
		if [ ! -z "${SOURCE_REPO}" ]
		then
			echo "Specified '--source-repo' multiple times, first time was '${SOURCE_REPO}', second time was '$1'." >&2
			exit 2
		fi
		SOURCE_REPO="$1"
		shift
	  ;;

  	  --source-org|--source-owner)
		if [ ! -z "${SOURCE_ORG}" ]
		then
			echo "Specified '--source-org/owner' multiple times, first time was '${SOURCE_ORG}', second time was '$1'." >&2
			exit 2
		fi
		SOURCE_ORG="$1"
		shift
	  ;;

	  --ref|--source-branch)
		if [ ! -z "${DEPENDENCY_REF}" ]
		then
			echo "Specified '--ref' multiple times, first time was '${DEPENDENCY_REF}', second time was '$1'." >&2
			exit 2
		fi
		DEPENDENCY_REF="$1"
		shift
	  ;;

	  --help|-h)
		cat << __EOF__
Allows to trigger the 'update-python-pkg-index' manually to update the GT4Py specific
dependencies. In order to work a token must be provided which is assumed to be '.token',
located along this script.
The script has the following options:
  --source-org | --source-owner:  The owner of the repo containing the dependency.
  --source-repo:  The repo containing the dependency.
  --source-ref | --ref:  The reference, git entity, from which the package should be build.

To token either needs to have full (write) access to the index repo, i.e. this repo,
or if it is a fine grained access token it needs to have the '"Contents" repository
permissions (write)' permission.

__EOF__
		exit 0
	  ;;

	  --*)
		echo "Unknown option '${ARG}'" >&2
		echo " try using '$0 --help'." >&2
		exit 3
	  ;;

	  *)
		echo "Unknown value '${ARG}'" >&2
		echo " try using '$0 --help'." >&2
		exit 4
	  ;;
	esac
done

if [ -z "${SOURCE_ORG}" ]
then
	echo "--source-org was not specified." >&2
	exit 5
elif [ -z "${SOURCE_REPO}" ]
then
	echo "--source-repo was not specified." >&2
	exit 5
elif [ -z "${DEPENDENCY_REF}" ]
then
	echo "--dependency-ref was not specified." >&2
	exit 5
fi

if [ ! -e ".token" ]
then
	echo "The file with the token, '.token' does not exist."
	echo " According to 'https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#create-a-repository-dispatch-event'"
	echo " a fine grained token with '\"Contents\" repository permissions (write)' is needed."
	exit 1
fi

curl -L -v --fail-with-body \
	-X POST \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $(cat .token)" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
  	"https://api.github.com/repos/${INDEX_ORGANIZATION}/${INDEX_REPO}/dispatches" \
  	-d '{"event_type":"update_package_index","client_payload":{"source_repo":"'"${SOURCE_REPO}"'","source_org":"'"${SOURCE_ORG}"'","dependency_ref":"'"${DEPENDENCY_REF}"'"}}'
CURL_RET=$?

if [ "${CURL_RET}" -ne 0 ]
then
	echo "POST to '${INDEX_ORGANIZATION}:${INDEX_REPO}' failed with error code '${CURL_RET}'"
	exit 1
fi

exit 0

