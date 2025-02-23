#!/bin/bash

echo """
this script will remove all docker tags older than 7 days
from docker hub repo of this project
usage: ./docker-clean.sh

starting..
"""

# this variables are secrets fetched from github actions' runner environment..
docker_user="${DOCKER_USER}"
docker_repo="${DOCKER_REPO}"
docker_token="${DOCKERTOKEN}"


sleep 2

#____________________________________________________________________________________________________

echo ""
echo "fetching current tags in docker hub repo and showing them"

# accessing docker hub api to fetch all current tags and using jq to format them to my choice.
tags=$(curl -s -H "Authorization: Bearer $docker_token" \
    "https://hub.docker.com/v2/repositories/$docker_user/$docker_repo/tags/?page_size=100" \
    | jq '[.results[] | {name: .name, created_at: (.tag_last_pushed | split("T")[0])}]')

echo "$tags"
sleep 2

#____________________________________________________________________________________________________

echo ""
echo "comparing dates and calculating outdated tags out of tags shown.."

# calculating today minus 7 days using date -d
today_minus_week=$(date -d "-7 days" "+%s")
echo ""
echo "shortly tags which were created before $(date -d "-7 days") will be deleted from the docker hub repo"
echo ""

# using jq to iterate over tags with a while loop that reads tag in a line each iteration.
echo "$tags" | jq -c '.[]' | while IFS= read -r tag_object; do

    tag=$(echo "$tag_object" | jq -r '.name')
    tag_date_only=$(echo "$tag_object" | jq -r '.created_at')

    echo "checking tag $tag with date $tag_date_only"

    # comparing tag date with today minus 7 days with unix timestamp ("+%s")
    if [[ "$(date -d "$tag_date_only" "+%s")" -lt "$today_minus_week" ]]; then
        echo "removing tag $tag"
        curl -X DELETE -H "Authorization: Bearer $docker_token" \
            "https://hub.docker.com/v2/repositories/$docker_user/$docker_repo/tags/$tag/"
        echo "tag $tag was deleted!!!!!!!!!"
        echo ""
        sleep 1
    else
        echo "tag $tag is not outdated, keeping it"
        echo ""
        sleep 1
    fi
done

echo "deleted outdated tags, now showing remaining tags"
echo ""
#____________________________________________________________________________________________________

# showing remaining tags after deleting outdated tags
remaining_tags=$( curl -s -H "Authorization: Bearer $docker_token" \
    "https://hub.docker.com/v2/repositories/crazyguy888/catexer-actions/tags/?page_size=100" \
    | jq '.results[].name')

echo "$remaining_tags"

echo ""
echo "docker hub tag-cleanup completed, now exiting.."
echo "docker hub tag-cleanup completed, now exiting.."
echo "docker hub tag-cleanup completed, now exiting.."
echo ""