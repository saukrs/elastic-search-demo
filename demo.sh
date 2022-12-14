#!/usr/bin/env sh

# SPDX-FileCopyrightText: 2022 Saulius Krasuckas
# SPDX-License-Identifier: BlueOak-1.0.0

step()
{
    local        RED="\e[31m"
    local      GREEN="\e[32m"
    local     PURPLE="\e[35m"
    local COLOR_STOP="\e[0m"
    local   COLORING=$GREEN
    local      PUNCT=":"
    local    CONFIRM=""

    [ -z "${1##TODO*}" ] && COLORING=$PURPLE

    [ -z "${1##*.}" ] && PUNCT=""

    [ "$2" = 1 ] && CONFIRM="^C or go?"

    echo
    echo "${COLORING}- $1${PUNCT}${COLOR_STOP} ${CONFIRM}"
    echo

    [ "$2" = 1 ] && read REPLY || echo
}

# Run the DIY helper script from the same dir:
elrun()
{
    /usr/bin/env ./elrun "$@"
    echo
}

kill_after()
{
    sleep $1
    kill `pidof $2` 2>/dev/null
}

ask=1

clear # --------------------------------------------------------------------------------------------------------------

step 'Building containers for two sites' $ask

elrun cluster_build

step 'Starting main site' $ask

elrun cluster__up

step 'Waiting for ES cluster' $ask

kill_after 60 watch &
elrun cluster_watch

step 'See the initial ES cluster state' $ask

elrun list_cluster_settings
elrun list_disk
elrun list_indices
elrun list_shards

step 'Creating ES indices' $ask

elrun create_index sampleindex2
elrun create_index sampleindex
elrun create_index hehe-index
elrun create_index laba-diena

step 'See the updated ES cluster state' $ask

elrun list_disk
elrun list_indices
elrun list_shards

step 'Changing ES replicas number' $ask

# health status index        uuid                   pri rep docs.count docs.deleted store.size pri.store.size
# green  open   sampleindex2 OoN6uwOdS9ueoWw1Zuw1Xg   1   1          0            0       416b           208b
# yellow open   sampleindex  vcsIbSLYSzu7YNtBfNXUNg   1   2          0            0       416b           208b
# yellow open   hehe-index   WNaN5TZTQ92Vr81lgJQQlQ   1   3          0            0       416b           208b
# yellow open   laba-diena   nGeFJqc3QrKjVmpeL1XvzA   1   4          0            0       416b           208b

elrun set_index_replicas sampleindex 2
elrun set_index_replicas hehe-index 3
elrun set_index_replicas laba-diena 4

step 'See the updated ES cluster state' $ask

elrun list_disk
elrun list_indices
elrun list_shards

step 'Exclude the node' $ask

elrun exclude_node es03
elrun list_disk
elrun list_indices

step 'Shutdown the node' $ask

elrun cluster_es03_down
elrun cluster_es03_offsite_down
elrun cluster_ps

step 'See reduced ES cluster' $ask

elrun list_disk
elrun list_indices
elrun list_shards

step 'Bring up the backup node' $ask

elrun cluster_es03_offsite_up
elrun cluster_ps
elrun list_disk
elrun list_indices

step 'Wait for the node to join the cluster' $ask

kill_after 25 watch &
elrun cluster_watch

step 'See restored ES cluster' $ask

elrun list_disk
elrun list_indices

step 'Allow node to be routed again' $ask

elrun exclude_node
elrun list_disk
elrun list_indices

step 'Wait for the replicas to distribute'

kill_after 10 watch &
elrun cluster_watch

step 'See the final ES state' $ask

elrun list_disk
elrun list_indices
elrun list_shards

step 'List the rebalanced Docker containers'

elrun cluster_ps

step 'Destroy the containers and the volumes' $ask

elrun cluster_es03_offsite_down
elrun cluster__down -v

step 'Demo is over.'
