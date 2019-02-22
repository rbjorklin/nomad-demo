#!/bin/bash

#http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

UUIDS=("3b65cdf2-367f-4bbf-a8a8-69c3c3171fe2" "bae6e1c2-dacc-4cb9-a1af-44af0afddb0d" "78b59047-2cbb-4412-9231-0be4cb146767" "48f612ae-c240-4be2-87bc-b0ccad451d3f")
IPS=("10.10.10.13" "10.10.10.14")

CURL_OPT="time_appconnect: %{time_appconnect}\ntime_connect: %{time_connect}\ntime_namelookup: %{time_namelookup}\ntime_pretransfer: %{time_pretransfer}\ntime_redirect: %{time_redirect}\ntime_starttransfer: %{time_starttransfer}\ntime_total: %{time_total}\n\n"


for ip in ${IPS[*]} ; do
    for uuid in ${UUIDS[*]} ; do
        for i in $(seq 1 10) ; do
            url="http://$ip/?session=$uuid"
            echo "$url"
            curl -w "${CURL_OPT}" -so /dev/null "$url"
        done
    done
done
