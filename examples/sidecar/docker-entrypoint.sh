#!/bin/sh

curl -s  https://stream.wikimedia.org/v2/stream/recentchange | grep data | sed 's/^data: //g' | jq -rc 'with_entries(if .key == "$schema" then .key = "schema" else . end)'

exit 1