#!/bin/bash

TOKEN=$1

# For each file in docs directory
while IFS= read -r -d '' file
do
  # If it contains "REMOTE" string
    if grep -q REMOTE "$file"; then
        tail -n +2 "$file" > tmpfile && mv tmpfile "$file"
        REPO=$(jq '.repo' < "$file" | sed 's/"//g')
        DIR=$(jq '.path' < "$file" | sed 's/"//g')
        FILE_NAME=$(jq '.file' < "$file" | sed 's/"//g')
        URL="https://api.github.com/repos/$REPO/contents/$DIR$FILE_NAME"
        # Replace file with content from $file of $repo with $branch
	    curl --header "Authorization: token $TOKEN" \
            --header 'Accept: application/vnd.github.v3.raw' \
            --remote-name \
            --location "$URL"
        ls -al
        echo "Old file:"
        cat "$file"
        cat "$FILE_NAME" > "$file"
        echo "New file:"
        cat "$file"
    fi
done <   <(find docs/ -name '*.md' -print0)
