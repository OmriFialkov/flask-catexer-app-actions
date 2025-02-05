#!/bin/bash

echo """
this script will remove all docker tags older than 7 days
from docker hub repo of this project
usage: ./docker-clean.sh
starting..
"""

sleep 2

#____________________________________________________________________________________________________

echo "fetching current tags in docker hub repo and showing them"

tags=$(curl -s -H "Authorization: Bearer $docker_token" \
    "https://hub.docker.com/v2/repositories/$docker_user/$docker_repo/tags/?page_size=100" \
    | jq '.results[] | {name: .name, created_at: (.tag_last_pushed | split("T")[0] | gsub("-"; "."))}')

echo "$tags"
sleep 2

#____________________________________________________________________________________________________

echo "comparing dates and calculating outdated tags out of tags shown.."
sleep 1

today_minus_week=$(date -d "-7 days" "+%Y.%m.%d")
echo "shortly tags which were created before $today_minus_week will be deleted from the docker hub repo"

for tag in $tags; do
    echo "checking tag $tag date"
    tag_date_only=$(echo $tag | jq -r '.created_at')
    if [[ $tag_date_only -lt $today_minus_week ]]; then
        echo "removing tag $tag"
        curl -X DELETE -H "Authorization: Bearer $docker_token" \
            "https://hub.docker.com/v2/repositories/$docker_user/$docker_repo/tags/$tag"
        echo "tag $tag was deleted!!!!!!!!!!!!!!!!!!!!!!!!!"
    else
        echo "tag $tag is not outdated, keeping him"
    fi
done
echo "deleted outdated tags, now showing remaining tags"
sleep 1
#____________________________________________________________________________________________________

echo "remaining tags:"

remaining_tags=$( curl -s "https://hub.docker.com/v2/repositories/crazyguy888/catexer-actions/tags" \
 | jq '.results[].name')

echo "$remaining_tags"

echo "done, now exiting.."
sleep 1

