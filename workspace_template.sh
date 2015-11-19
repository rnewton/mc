cd "$PROJECT_PATH"

# Sets up the project on the remote server to make it world accessible
setup_remote() {
    ssh -t "${MC_REMOTE_USER}@${MC_REMOTE_SERVER}" "\$HOME/.bin/clone $PROJECT_REPO \$HOME/$SLUGIFIED"
    update_vhosts
}

# Updates the vhost entries on the remote server (should include this project)
update_vhosts() {
    ssh -t "${MC_REMOTE_USER}@${MC_REMOTE_SERVER}" "/home/${MC_REMOTE_USER}/.bin/vhosts" || exit 1
}

# Pulls upstream changes into the current branch. Potentially dangerous.
rebase() {
    git stash -u
    git checkout "$PROJECT_TRACKING"
    git fetch
    git pull --rebase origin "$PROJECT_TRACKING"
    git checkout "$PROJECT_BRANCH"
    git pull --rebase origin "$PROJECT_TRACKING"
    git stash pop
}

# Enable file sync for this directory to the remote server
watch() {
    ssh -t "${MC_REMOTE_USER}@${MC_REMOTE_SERVER}" "mkdir -p ${PROJECT_REMOTE_PATH}" || exit 1
    ~/.bin/autorsync.rb "$AUTORSYNC_FILE"
}

