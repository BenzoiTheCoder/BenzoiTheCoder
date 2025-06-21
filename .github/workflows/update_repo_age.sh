#!/bin/bash

set -e

# Fetch repo info
repo_info=$(curl -s "https://api.github.com/repos/${GITHUB_REPOSITORY}")
created_at=$(echo "$repo_info" | jq -r .created_at)

# Convert timestamps
created_ts=$(date -d "$created_at" +%s)
now_ts=$(date +%s)

# Calculate age in days
days=$(( (now_ts - created_ts) / 86400 ))

# Build badge markdown
badge_url="https://img.shields.io/badge/Repo%20Age-${days}%20days-blue"
badge_md="<!-- ci-actions: repository date -->\n![Repo Age](${badge_url})"

# Replace or update the badge line in README.md
# Find the line with the comment and replace it with the comment + badge
awk '
  BEGIN { found=0 }
  {
    if ($0 ~ /<!-- ci-actions: repository date -->/) {
      print "<!-- ci-actions: repository date -->"
      print "![Repo Age]('"$badge_url"')"
      found=1
      getline # Skip the next line (old badge)
    } else {
      print
    }
  }
  END {
    if (!found) {
      print "<!-- ci-actions: repository date -->"
      print "![Repo Age]('"$badge_url"')"
    }
  }
' README.md > README.tmp && mv README.tmp README.md
