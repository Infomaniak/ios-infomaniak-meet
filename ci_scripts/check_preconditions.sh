#!/bin/sh
set -e

# CI_COMMIT - The Git commit hash that Xcode Cloud uses for the current build.

# Ensure we have a commit hash
if [ -z "$CI_COMMIT" ]; then
  echo "Error: CI_COMMIT variable is not set."
  exit 1
fi

# Retrieve the commit title from the given commit hash
commit_title="$(git log --format=%s -n 1 "$CI_COMMIT")"

# Check if the commit title begins with the expected string
if [[ "$commit_title" == chore:\ Release\ build* ]]; then
  echo "Commit title is valid. Continuing..."
else
  echo "Error: The commit title is not 'chore: Release build'."
  exit 1
fi
