#!/usr/bin/env bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

#
# ensureUserAndId()
# Description:  Used to add a new user and remove any existing one. Normally this is anti normalicy however it's very
#               much a needed function when dealing with docker images that need to reuse existing users at times.
#
# @arg [1]: Desired user name and user id. Format string as (myuser:2000 or myuser)
# @arg [2]: Desired group name and group id. Format string as (mygroup:2000 or mygroup)
#
# @TODO
# - validate user.
# - validate group.
# - should we reset permissions?
#   find / -user application
#   find / -group application
#   find / -user <OLDUID> -exec chown -h <NEWUID> {} \;
#   find / -group <OLDGID> -exec chgrp -h <NEWGID> {} \;
#
function ensureUserAndId() {

    # exit if no user argument passed.
    if [[ -z "${1}" ]]; then echo "[ERROR]::[missing user]::[${1}]"; return 1; fi

    local DRY_RUN=false
    local DESIRED_USER=${1}
    local DESIRED_GROUP=${2:-$DESIRED_USER}
    local DESIRED_USER_NAME=$(echo $1 | cut -d":" -f1)
    local DESIRED_UID=$(echo $1 | cut -d":" -f2)
    local DESIRED_GROUP_NAME=$(echo ${2:-$DESIRED_USER_NAME} | cut -d":" -f1)
    local DESIRED_GUID=$(echo ${2:-$DESIRED_USER_ID} | cut -d":" -f2)
    local CURRENT_UID=$(getent passwd "${DESIRED_USER_NAME}" | cut -d":" -f3 )
    local CURRENT_GUID=$(getent group "${DESIRED_GROUP_NAME}" | cut -d":" -f3 )
    local NEXT_AVAILABLE_UID=$(($(getent passwd | grep -v nobody | cut -d":" -f3 | sort -n | tail -n 1) + 1))
    local NEXT_AVAILABLE_GUID=$(($(getent group | grep -v nogroup | cut -d":" -f3 | sort -n | tail -n 1) + 1))
    local EXISTING_USER_NAME_WITH_DESIRED_UID=$(getent passwd "${DESIRED_UID}" | cut -d: -f1)
    local EXISTING_GROUP_NAME_WITH_DESIRED_GUID=$(getent group "${DESIRED_GUID}" | cut -d: -f1)

    # reset variables if user didn't pass in an id. (RESULT will have user name if id wasn't passed in, this resets it)
    if [ "${DESIRED_USER_NAME}" == "${DESIRED_UID}" ]; then DESIRED_UID=""; fi
    if [ "${DESIRED_GROUP_NAME}" == "${DESIRED_GUID}" ]; then DESIRED_GUID=""; fi

    # use next available ids if none passed.
    if [ -z "${DESIRED_UID}"  ]; then DESIRED_UID=${NEXT_AVAILABLE_UID}; fi
    if [ -z "${DESIRED_GUID}"  ]; then DESIRED_GUID=${NEXT_AVAILABLE_GUID}; fi

    echo "{CONFIG}+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "[DEBUG]::[DESIRED_USER]::[${DESIRED_USER}]"
    echo "[DEBUG]::[DESIRED_GROUP]::[${DESIRED_GROUP}]"
    echo "[DEBUG]::[DESIRED_USER_NAME]::[${DESIRED_USER_NAME}]"
    echo "[DEBUG]::[DESIRED_UID]::[${DESIRED_UID}]"
    echo "[DEBUG]::[DESIRED_GROUP_NAME]::[${DESIRED_GROUP_NAME}]"
    echo "[DEBUG]::[DESIRED_GUID]::[${DESIRED_GUID}]"
    echo "[DEBUG]::[CURRENT_UID]::[${CURRENT_UID}]"
    echo "[DEBUG]::[CURRENT_GUID]::[${CURRENT_GUID}]"
    echo "[DEBUG]::[NEXT_AVAILABLE_UID]::[${NEXT_AVAILABLE_UID}]"
    echo "[DEBUG]::[NEXT_AVAILABLE_GUID]::[${NEXT_AVAILABLE_GUID}]"
    echo "[DEBUG]::[EXISTING_USER_NAME_WITH_DESIRED_UID]::[${EXISTING_USER_NAME_WITH_DESIRED_UID}]"
    echo "[DEBUG]::[EXISTING_GROUP_NAME_WITH_DESIRED_GUID]::[${EXISTING_GROUP_NAME_WITH_DESIRED_GUID}]"
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

    #
    # {Group}+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    #

    # guid in use already, move to new guid.
    if [[ "${DESIRED_GROUP_NAME}" != "${EXISTING_GROUP_NAME_WITH_DESIRED_GUID}" && ! -z "${EXISTING_GROUP_NAME_WITH_DESIRED_GUID}" ]]; then
        echo "[DEBUG]::[guid in use already, move to new guid]::[${EXISTING_GROUP_NAME_WITH_DESIRED_GUID}]::[${DESIRED_GUID}]->[${NEXT_AVAILABLE_GUID}]"
        if [ "${DRY_RUN}" == true ]; then
            echo [DRY RUN]::[groupmod -g "${NEXT_AVAILABLE_GUID}" "${EXISTING_GROUP_NAME_WITH_DESIRED_GUID}"]
        else
            groupmod -g "${NEXT_AVAILABLE_GUID}" "${EXISTING_GROUP_NAME_WITH_DESIRED_GUID}"
        fi
    fi

    # if the group exists under a different GUID, change it.
    if [[ ! -z "${CURRENT_GUID}" && ! -z "${DESIRED_GUID}" && "${CURRENT_GUID}" != "${DESIRED_GUID}" ]]; then
    	echo "[DEBUG]::[group exists under a different GUID, change it.]::[${DESIRED_GROUP_NAME}]::[${CURRENT_GUID}]->[${DESIRED_GUID}]"

        if [ "${DRY_RUN}" == true ]; then
            echo [DRY RUN]::[groupmod -g "${DESIRED_GUID}" "${DESIRED_GROUP_NAME}"]
        else
            groupmod -g "${DESIRED_GUID}" "${DESIRED_GROUP_NAME}"
        fi
    fi

    # group does not exist already, add it with desired guid.
    if [[ -z "${CURRENT_GUID}" ]]; then
        echo "[DEBUG]::[group does not exist already, add it with desired guid.]::[${DESIRED_GROUP_NAME}]::[${DESIRED_GUID}]"

        if [ "${DRY_RUN}" == true ]; then
            echo [DRY RUN]::[groupadd -g "${DESIRED_GUID}" "${DESIRED_GROUP_NAME}"]
        else
            groupadd -g "${DESIRED_GUID}" "${DESIRED_GROUP_NAME}"

        fi
    fi

    #
    # {User}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    #

    # uid in use already, move to new uid
    if [[ "${DESIRED_USER_NAME}" != "${EXISTING_USER_NAME_WITH_DESIRED_UID}" && ! -z "${EXISTING_USER_NAME_WITH_DESIRED_UID}" ]]; then
        echo "[DEBUG]::[UUID in use already, move to new UUID]::[${EXISTING_USER_NAME_WITH_DESIRED_UID}]::[${DESIRED_UID}]->[${NEXT_AVAILABLE_UID}]"

        if [ "${DRY_RUN}" == true ]; then
            echo [DRY RUN]::[usermod -u "${NEXT_AVAILABLE_UID}" "${EXISTING_USER_NAME_WITH_DESIRED_UID}"]
        else
            usermod -u "${NEXT_AVAILABLE_UID}" "${EXISTING_USER_NAME_WITH_DESIRED_UID}"
        fi
    fi

    # if the user exists under a different UID, change it.
    if [[ ! -z "${CURRENT_UID}" && ! -z "${DESIRED_UID}" && "${CURRENT_UID}" != "${DESIRED_UID}" ]]; then
    	echo "[DEBUG]::[user exists under a different UID, change it.]::[${DESIRED_USER_NAME}]::[${CURRENT_UID}]->[${DESIRED_UID}]"

        if [ "${DRY_RUN}" == true ]; then
            echo [DRY RUN]::[usermod -g "${DESIRED_GROUP_NAME}" -u "${DESIRED_UID}" "${DESIRED_USER_NAME}"]
        else
            usermod -g "${DESIRED_GROUP_NAME}" -u "${DESIRED_UID}" "${DESIRED_USER_NAME}"
        fi
    fi

    # user does not exist already, add it with desired uid.
    if [[ -z "${CURRENT_UID}" ]]; then
        echo "[DEBUG]::[user does not exist already, add it with desired UID.]::[${DESIRED_USER_NAME}]::[${DESIRED_UID}]"

        if [ "${DRY_RUN}" == true ]; then
            echo [DRY RUN]::[useradd -g "${DESIRED_GROUP_NAME}" -s /sbin/nologin --create-home --system --uid "${DESIRED_UID}" "${DESIRED_USER_NAME}"]
        else
            useradd -g "${DESIRED_GROUP_NAME}" -s /sbin/nologin --create-home --system --uid "${DESIRED_UID}" "${DESIRED_USER_NAME}"
        fi
    fi

    return 0
}

function testEnsureUserAndId() {

    # existing group name.
    ensureUserAndId "www-data:33" "www-data:33"
    ensureUserAndId "www-data:1234" "www-data:1234"

    # new group name.
    ensureUserAndId "myuser:33" "my-data:33"
    ensureUserAndId "myuser:1234" "my-data:1234"

    # new user and new group
    ensureUserAndId "myuser" "mygroup"
    ensureUserAndId "myuser:2222" "mygroup:2222"
    ensureUserAndId "myuser:2222" "mygroup:2222"
    ensureUserAndId "myuser" "mygroup:2222"
    ensureUserAndId "myuser:2222" "mygroup"
}


ensureUserAndId "${1:-}" "${2:-}"