#!/usr/bin/env bash
# Vendor Claude skills from the npx installer's store into this repo.
#
# `npx mattpocock/skills` writes real skill content to ~/.agents/skills and
# symlinks it into ~/.claude/skills with relative paths that assume the latter
# is a real directory. Ours is a mkOutOfStoreSymlink into this repo, so those
# links dangle on a fresh clone. This script copies the real content in as
# plain files so the skills are self-contained and reproducible.
#
# Idempotent: re-run it after any `npx mattpocock/skills` update.
# Only skills present in the store are synced; repo-only skills (e.g. ones you
# added by hand) are left untouched.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SRC="${HOME}/.agents/skills"
DEST="${DIR}/home/.claude/skills"

if [ ! -d "$SRC" ]; then
  echo "error: skills store not found at $SRC" >&2
  echo "run 'npx mattpocock/skills' first (it populates ~/.agents/skills)." >&2
  exit 1
fi

mkdir -p "$DEST"
count=0
for path in "$SRC"/*/; do
  name="$(basename "$path")"
  rm -rf "${DEST:?}/${name}"          # drop any stale copy or broken symlink
  cp -R "$path" "$DEST/$name"         # vendor the real content
  rm -rf "$DEST/$name/.git"           # never track a nested repo
  count=$((count + 1))
done

echo "vendored $count skill(s) from $SRC into home/.claude/skills/"
echo "review with 'git status', then commit."
