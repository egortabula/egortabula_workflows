#!/bin/bash

# DEPRECATED: This script is now deprecated in favor of the automated GitHub Action.
# The .github/workflows/update_v1_tag.yml workflow automatically updates the v1 tag
# when new releases are published.
#
# Updates the "v1" tag to point to a newer release.
# To be executed whenever a new 1.x tag is created.
# Usage: ./retag_v1.sh <newer-existing-version>

currentBranch=$(git symbolic-ref --short -q HEAD)
if [[ ! $currentBranch == "main" ]]; then
 echo "Re-tagging is only supported on the main branch."
 exit 1
fi

# Get new version
new_version="$1";

if [[ "$new_version" == "" ]]; then
  echo "No new version supplied, please provide one"
  exit 1
fi

git tag -d v1 && git tag v1 v$new_version && git push origin --delete v1 && git push origin v1