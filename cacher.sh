#!/bin/bash
set -e

if [ -z "$PLUGIN_MOUNT" ]; then
    echo "Specify folders to cache in the mount property! Plugin won't do anything!"
    exit 0
fi

if [[ $DRONE_COMMIT_MESSAGE == *"[CLEAR CACHE]"* && -n "$PLUGIN_RESTORE" && "$PLUGIN_RESTORE" == "true" ]]; then
    if [ -d "/cache/$DRONE_REPO_OWNER/$DRONE_REPO_NAME" ]; then
        echo "Found [CLEAR CACHE] in commit message, clearing cache!"
        rm -rf "/cache/$DRONE_REPO_OWNER/$DRONE_REPO_NAME"
    fi
fi

if [[ $DRONE_COMMIT_MESSAGE == *"[NO CACHE]"* ]]; then
    echo "Found [NO CACHE] in commit message, skipping cache restore and rebuild!"
    exit 0
fi

IFS=','; read -ra SOURCES <<< "$PLUGIN_MOUNT"
if [[ -n "$PLUGIN_REBUILD" && "$PLUGIN_REBUILD" == "true" ]]; then
    # Create cache
    for source in "${SOURCES[@]}"; do
        if [ -d "$source" ]; then
            echo "Rebuilding cache to /cache/$DRONE_REPO_OWNER/$DRONE_REPO_NAME/$source from $source..."
            mkdir -p "/cache/$DRONE_REPO_OWNER/$DRONE_REPO_NAME/$source" && \
                rsync -aHA --delete "$source/" "/cache/$DRONE_REPO_OWNER/$DRONE_REPO_NAME/$source"
        else
            echo "$source does not exist, removing from cached folder..."
            rm -rf "/cache/$DRONE_REPO_OWNER/$DRONE_REPO_NAME/$source"
        fi
    done
elif [[ -n "$PLUGIN_RESTORE" && "$PLUGIN_RESTORE" == "true" ]]; then
    # Restore from cache
    for source in "${SOURCES[@]}"; do
        if [ -d "/cache/$DRONE_REPO_OWNER/$DRONE_REPO_NAME/$source" ]; then
            echo "Restoring cache for $source from /cache/$DRONE_REPO_OWNER/$DRONE_REPO_NAME/$source..."
            mkdir -p "$source" && \
                rsync -aHA --delete "/cache/$DRONE_REPO_OWNER/$DRONE_REPO_NAME/$source/" "$source"
        else
            echo "No cache for $source"
        fi
    done
else
    echo "No restore or rebuild flag specified, plugin won't do anything!"
fi
