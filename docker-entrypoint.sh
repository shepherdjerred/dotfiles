#!/bin/bash
set -e

TARGET_USER="jerred"
CURRENT_UID="$(id -u)"
CURRENT_GID="$(id -g)"

# If running as root with HOST_UID/HOST_GID set, remap user and drop privileges
if [[ "$CURRENT_UID" == "0" ]] && [[ -n "${HOST_UID:-}" ]]; then
    TARGET_UID="${HOST_UID}"
    TARGET_GID="${HOST_GID:-$HOST_UID}"

    # Modify the target user to have the host's UID/GID
    usermod -u "$TARGET_UID" "$TARGET_USER" 2>/dev/null || true
    groupmod -g "$TARGET_GID" "$TARGET_USER" 2>/dev/null || true

    # Fix ownership of key directories
    chown -R "$TARGET_UID:$TARGET_GID" "/home/$TARGET_USER" 2>/dev/null || true
    chown -R "$TARGET_UID:$TARGET_GID" /home/linuxbrew 2>/dev/null || true

    # Fix ownership of cache directories (typically mounted as volumes)
    # These may be shared across containers for build caching
    CACHE_DIRS=(
        "/workspace/.cargo/registry"
        "/workspace/.cargo/git"
        "/workspace/.cache/sccache"
    )
    for dir in "${CACHE_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            chown -R "$TARGET_UID:$TARGET_GID" "$dir" 2>/dev/null || true
        fi
    done

    # Switch to the user and execute
    exec gosu "$TARGET_USER" "$@"
fi

# If running as non-root with unknown UID, add entry to passwd/group
if [[ "$CURRENT_UID" != "0" ]] && ! getent passwd "$CURRENT_UID" &>/dev/null; then
    # Add user to passwd if we have write access
    if [[ -w /etc/passwd ]]; then
        echo "${TARGET_USER}:x:${CURRENT_UID}:${CURRENT_GID}::/home/${TARGET_USER}:/home/linuxbrew/.linuxbrew/bin/fish" >> /etc/passwd
    fi
    if [[ -w /etc/group ]] && ! getent group "$CURRENT_GID" &>/dev/null; then
        echo "${TARGET_USER}:x:${CURRENT_GID}:" >> /etc/group
    fi
fi

exec "$@"
