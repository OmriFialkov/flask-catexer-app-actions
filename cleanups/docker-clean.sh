#!/bin/bash

# CHANGE FOR YOUR OWN CHOICE OF DAYS CUTOFF
RETENTION_DAYS=7
#___________________________________________________________________________________________________

echo """
this script will remove all docker tags older than "$RETENTION_DAYS" days
from docker hub repo of this project
"""

# this variables are secrets fetched from github actions' runner environment..
docker_user="${DOCKER_USER}"
docker_repo="${DOCKER_REPO}"
docker_token="${DOCKERTOKEN}"

sleep 2

#____________________________________________________________________________________________________

echo ""
echo "fetching current tags in docker hub repo and showing them"

# accessing docker-hub api to fetch all current tags and using jq to format them to my choice.
tags=$(curl -s -H "Authorization: Bearer $docker_token" \
    "https://hub.docker.com/v2/repositories/$docker_user/$docker_repo/tags/?page_size=100" \
    | jq '[.results[] | {name: .name, created_at: (.tag_last_pushed | split("T")[0])}]')

echo "$tags"
sleep 2

#____________________________________________________________________________________________________

echo ""
echo "comparing dates and calculating outdated tags out of tags shown.."

# calculating today minus retention days using date -d
cutoff_date=$(date -d "-$RETENTION_DAYS days" "+%s")
echo ""
echo "Shortly, tags which were created before $(date -d "-$RETENTION_DAYS days") will be deleted from the docker hub repo"
echo ""

# using jq to iterate over tags with a while loop that reads tag in a line each iteration.
echo "$tags" | jq -c '.[]' | while IFS= read -r tag_object; do

    tag=$(echo "$tag_object" | jq -r '.name')
    tag_date_only=$(echo "$tag_object" | jq -r '.created_at')

    echo "checking tag $tag with date $tag_date_only"

    # comparing tag date with today minus 7 days with unix timestamp ("+%s")
    if [[ "$(date -d "$tag_date_only" "+%s")" -lt "$cutoff_date" ]]; then
        echo "removing tag $tag"
        curl -X DELETE -H "Authorization: Bearer $docker_token" \
            "https://hub.docker.com/v2/repositories/$docker_user/$docker_repo/tags/$tag/"
        echo "tag $tag was deleted!!!!!!!!!"
        echo ""
    else
        echo "tag $tag is not outdated, keeping it"
        echo ""
    fi
done

sleep 4 # to fetch reliable data from docker hub api - without sleep it shows deleted tags as well.
echo "deleted outdated tags, now showing remaining tags"
echo ""
#____________________________________________________________________________________________________

# showing remaining tags after deleting outdated tags
remaining_tags=$( curl -s -H "Authorization: Bearer $docker_token" \
    "https://hub.docker.com/v2/repositories/$docker_user/$docker_repo/tags/?page_size=100" \
    | jq '.results[].name')

echo "$remaining_tags"

echo ""
echo "docker hub tag-cleanup completed, now exiting.."
echo ""