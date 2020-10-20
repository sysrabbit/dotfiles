#!/usr/bin/env sh
mapfile -t SUBREDDITS < subreddits.txt
for sub in ${SUBREDDITS[*]}; do
    mkdir -p "$HOME/Logs/gallery-dl/$sub"
    gallery-dl "https://www.reddit.com/r/$sub" -q 2>> "$HOME/Logs/gallery-dl/$sub/$(date --rfc-3339=date).log"
done
exit 0
