#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles

# Ask for the password once, then keep sudo's cache fresh so long cask downloads
# don't let it expire before a cask's own sudo call runs.
sudo -v
while true; do sudo -n -v 2>/dev/null; sleep 50; kill -0 "$$" 2>/dev/null || exit; done &
trap 'kill $! 2>/dev/null' EXIT

# darwin-rebuild runs as root, and git refuses to read a repo owned by another user
# unless it is listed as a safe.directory in root's git config.
if ! sudo git config --global --get-all safe.directory | grep -qxF "$DIR"; then
  sudo git config --global --add safe.directory "$DIR"
fi
sudo darwin-rebuild switch --flake ~/.dotfiles#mac
