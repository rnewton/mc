#!/usr/bin/env bash

cmd_version() {
    echo "mc 0.0.1"
}

cmd_usage() {
    cmd_version
    echo
    cat <<_EOF
Usage:

    $PROGRAM
        List the current project workspace details. If no workspace is loaded,
        list the available workspaces.
    $PROGRAM (list|ls)
        List the available workspaces.
    $PROGRAM (create|c)
        Create a new workspace.
    $PROGRAM (edit|e)
        Edit an existing workspace.
    $PROGRAM (delete|d) workspace-name
        Delete a workspace.
    $PROGRAM (.|go) workspace-name
        Switch to a workspace.
    $PROGRAM help
        Show this text.
    $PROGRAM version
        Show version info.
_EOF
}

cmd_create() {
    # Gather details
    read -p "Enter project name: " PROJECT_NAME
    SLUGIFIED="$(echo -n "${PROJECT_NAME}" | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' | tr A-Z a-z)"

    read -p "Enter repository: github.com/$MC_DEFAULT_REPO_OWNER/" REPO
    if [ -z "$REPO" ]; then
        echo "Must specify a repository"
        exit 1
    fi
    REPO="git@github.com:${MC_DEFAULT_REPO_OWNER}/${REPO}.git"

    read -p "Enter the name of your branch (default: feature/$SLUGIFIED): " BRANCH
    BRANCH=${BRANCH:-"feature/$SLUGIFIED"}

    read -p "Enter the name of the remote tracking branch (default: master): " TRACKING
    TRACKING=${TRACKING:-"master"}

    read_yes_no "Run \`ant init\`" ANT_INIT

    PROJECT_PATH="${MC_LOCAL_PATH}/${SLUGIFIED}"
    PROJECT_REMOTE_PATH="${MC_REMOTE_PATH}/${SLUGIFIED}"
    PROJECT_RSYNC="${MC_REMOTE_USER}@${MC_REMOTE_SERVER}:${PROJECT_REMOTE_PATH}"

    echo
    echo "Check your settings:"
    echo "Project path: ${PROJECT_PATH}"
    echo "Remote path: ${PROJECT_REMOTE_PATH}"
    echo "Repository: ${REPO} - ${BRANCH} -> ${TRACKING}"
    echo "Init: ${ANT_INIT}"
    echo

    read -p "Okay? [Enter to confirm]" confirm

    # Create project workspace
    WORKSPACE_FILE="$HOME/.desk/desks/${SLUGIFIED}.sh"
    AUTORSYNC_FILE="$HOME/.desk/desks/${SLUGIFIED}.yml"
    touch "$WORKSPACE_FILE"
    echo "# Description: ${MC_JIRA_URL}/browse/$SLUGIFIED" >> "$WORKSPACE_FILE"
    echo "############################################################" >> "$WORKSPACE_FILE"
    echo "export SLUGIFIED=\"$SLUGIFIED\"" >> "$WORKSPACE_FILE"
    echo "export PROJECT_PATH=\"$PROJECT_PATH\"" >> "$WORKSPACE_FILE"
    echo "export PROJECT_REMOTE_PATH=\"$PROJECT_REMOTE_PATH\"" >> "$WORKSPACE_FILE"
    echo "export PROJECT_REPO=\"$REPO\"" >> "$WORKSPACE_FILE"
    echo "export PROJECT_BRANCH=\"$BRANCH\"" >> "$WORKSPACE_FILE"
    echo "export PROJECT_TRACKING=\"$TRACKING\"" >> "$WORKSPACE_FILE"
    echo "export PROJECT_JIRA_URL=\"${MC_JIRA_URL}/browse/$SLUGIFIED\"" >> "$WORKSPACE_FILE"
    echo "export AUTORSYNC_FILE=\"${AUTORSYNC_FILE}\"" >> "$WORKSPACE_FILE"
    echo "############################################################" >> "$WORKSPACE_FILE"
    echo "" >> "$WORKSPACE_FILE"

    cat "$(dirname $(realpath "$0"))/workspace_template.sh" >> "$WORKSPACE_FILE"

    touch "$AUTORSYNC_FILE"
    cat "$(dirname $(realpath "$0"))/autorsync_template.yml" >> "$AUTORSYNC_FILE"
    echo "- from: '$PROJECT_PATH'" >> "$AUTORSYNC_FILE"
    echo "  to: '$PROJECT_RSYNC'" >> "$AUTORSYNC_FILE"

    # Checkout the project
    git clone "$REPO" "$PROJECT_PATH" || exit 1
    pushd "$PROJECT_PATH" > /dev/null
    git fetch
    git checkout -b "$BRANCH" origin/"$TRACKING" || exit 2
    popd > /dev/null

    # Build
    if [ "$ANT_INIT" != "n" ]; then
        pushd "$PROJECT_PATH" > /dev/null
        ant init
        popd > /dev/null
    fi

    cmd_go "$SLUGIFIED"
}

cmd_delete() {
    if [ -z "$1" ]; then
        echo "Must specify a workspace"
        exit 1
    fi

    PROJECTPATH="${MC_LOCAL_PATH}/$1" 
    WORKSPACEFILE="$HOME/.desk/desks/$1.sh" 
    AUTORSYNCFILE="$HOME/.desk/desks/$1.yml"

    if [ ! -d "$PROJECTPATH" ] || [ ! -f "$WORKSPACEFILE" ]; then
        echo "Project path or workspace file not setup correctly. Not deleting anything"
        echo "Check $PROJECTPATH and $WORKSPACEFILE"
        exit 2
    fi

    read -p "Are you sure you want to delete $1 ($PROJECTPATH and $WORKSPACEFILE)? [Enter to confirm]" confirm

    rm -rf "$PROJECTPATH"
    rm "$WORKSPACEFILE"
    rm "$AUTORSYNCFILE"
}

cmd_go() {
    desk . "$1"
}

cmd_edit() {
    desk edit "$1"
}

cmd_list() {
    desk ls
}

cmd_current() {
    desk
}

read_yes_no() {
    echo -en "$1 (y|n) "

    conf=""
    while [[ ! $conf =~ ^[yn]$ ]]; do read -n 1 -r -s conf; done
        echo $conf

    export "$2"="$conf"
}

SETTINGS="$HOME/.mc"

if [ ! -f "$SETTINGS" ]; then
    echo "No MC settings file found at" "${SETTINGS}"
    exit 1
else
    source "$SETTINGS"
fi

if [ -z "$MC_REMOTE_USER" ]; then echo "Missing MC_REMOTE_USER"; exit 1; fi
if [ -z "$MC_REMOTE_SERVER" ]; then echo "Missing MC_REMOTE_SERVER"; exit 1; fi

if [ -z "$MC_LOCAL_PATH" ]; then echo "Missing MC_LOCAL_PATH"; exit 1; fi
if [ -z "$MC_REMOTE_PATH" ]; then echo "Missing MC_REMOTE_PATH"; exit 1; fi

if [ -z "$MC_JIRA_URL" ]; then echo "Missing MC_JIRA_URL"; exit 1; fi

PROGRAM="${0##*/}"

case "$1" in
    help|--help) shift;       cmd_usage "$@" ;;
    version|--version) shift; cmd_version "$@" ;;
    create|c) shift;          cmd_create "$@" ;;
    edit|e) shift;            cmd_edit "$@" ;;
    delete|d) shift;          cmd_delete "$@" ;;
    list|ls) shift;           cmd_list "$@" ;;
    go|.) shift;              cmd_go "$@" ;;
    *)                        cmd_current "$@" ;;
esac
exit 0
