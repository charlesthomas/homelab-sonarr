#!/bin/bash
URL=https://sonarr.crt.house/api/v3
TAG="sync"
TOKEN=
AUTH="X-Api-Key:${TOKEN}"

tagID=$(curl -s -H $AUTH $URL/tag | jq -r '.[] | select(.label=="${TAG}") .id')

for seriesID in $(curl -s -H $AUTH $URL/tag/detail/$tagID | jq -r .seriesIds[]); do
	for eID in $(curl -s -H $AUTH $URL/episode?seriesId=${seriesID} | jq -r .[].episodeFileId); do
		if [ $eID -eq 0 ]; then
			continue
		fi
		
        actualPath=$(curl -s -H $AUTH $URL/episodefile/$eID | jq -r .path | sed s/mnt/volume1/)
		while [[ "${actualPath}" == "null" ]]; do
			sleep 5
			actualPath=$(curl -s -H $AUTH $URL/episodefile/$eID | jq -r .path | sed s/mnt/volume1/)
		done
        linkPath=$(echo "${actualPath}" | sed 's/tv/sync\/tv/')
        if [ ! -e "${linkPath}" ]; then
            mkdir -p $(dirname "${linkPath}")
            ln "${actualPath}" "${linkPath}"
        fi
    done
done
