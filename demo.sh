#!/usr/bin/env sh

# SPDX-FileCopyrightText: 2022 Saulius Krasuckas
# SPDX-License-Identifier: BlueOak-1.0.0

step()
{
    local      PUNCT=":"
    local        EOL=""
    local        RED="\e[31m"
    local      GREEN="\e[32m"
    local     PURPLE="\e[35m"
    local COLOR_STOP="\e[0m"
    local   COLORING=$GREEN

    [ -z "${1##TODO*}" ] && COLORING=$PURPLE

    [ -z "${1##*.}" ] && PUNCT=""

    [ "$2" = 1 ] && EOL="^C or go?"

    echo
    echo "${COLORING}- $1${PUNCT}${COLOR_STOP} ${EOL}"

    [ "$2" = 1 ] && read REPLY
}

kill_after()
{
    sleep $1
    kill `pidof $2` 2>/dev/null
}

ask=1

clear # --------------------------------------------------------------------------------------------------------------

step 'Building containers for two sites' $ask
echo; elrun cluster_build

step 'Starting main site' $ask
echo; elrun cluster__up

step 'Waiting for ES cluster' $ask
      kill_after 60 watch &
echo; elrun cluster_watch
echo

step 'See the initial ES cluster state' $ask
echo; elrun list_cluster_settings
echo; elrun list_disk
echo; elrun list_indices
echo; elrun list_shards

step 'TODO: Creating ES indices'

step 'TODO: Changing ES replicas number'

# health status index        uuid                   pri rep docs.count docs.deleted store.size pri.store.size
# green  open   sampleindex2 OoN6uwOdS9ueoWw1Zuw1Xg   1   1          0            0       416b           208b
# yellow open   sampleindex  vcsIbSLYSzu7YNtBfNXUNg   1   2          0            0       416b           208b
# yellow open   hehe-index   WNaN5TZTQ92Vr81lgJQQlQ   1   3          0            0       416b           208b
# yellow open   laba-diena   nGeFJqc3QrKjVmpeL1XvzA   1   4          0            0       416b           208b

step 'Exclude the node' $ask
echo; elrun exclude_node es03
echo; elrun list_disk
echo; elrun list_indices

step 'Shutdown the node' $ask
echo; elrun cluster_es03_down
echo; elrun cluster_es03_offsite_down
echo; elrun cluster_ps
echo

step 'See reduced ES cluster' $ask
echo; elrun list_disk
echo; elrun list_indices
echo; elrun list_shards

step 'Bring up the backup node' $ask
echo; elrun cluster_es03_offsite_up
echo; elrun cluster_ps
echo; elrun list_disk
echo; elrun list_indices

step 'Wait for the node to join the cluster' $ask
      kill_after 25 watch &
echo; elrun cluster_watch
echo

step 'See restored ES cluster' $ask
echo; elrun list_disk
echo; elrun list_indices

step 'Allow node to be routed again' $ask
echo; elrun exclude_node
echo; elrun list_disk
echo; elrun list_indices
echo

step 'Wait for the replicas to distribute'
      kill_after 10 watch &
echo; elrun cluster_watch
echo

step 'See the final ES state' $ask
echo; elrun list_disk
echo; elrun list_indices
echo; elrun list_shards

step 'List the rebalanced Docker containers'
echo; elrun cluster_ps

step 'Destroy the containers' $ask
echo; elrun cluster_es03_offsite_down
echo; elrun cluster__down

step 'TODO: Cleanup the used Docker Compose volumes too (a change in `elrun`)'

step 'Demo is over.'
