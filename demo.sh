#!/usr/bin/env sh

# SPDX-FileCopyrightText: 2022 Saulius Krasuckas
# SPDX-License-Identifier: BlueOak-1.0.0

step()
{
    local        EOL=""
    local        RED="\e[31m"
    local      GREEN="\e[32m"
    local     PURPLE="\e[35m"
    local COLOR_STOP="\e[0m"

    [ -z "${1##TODO*}" ] && COLORING=$PURPLE || COLORING=$GREEN

    [ "$2" = 1 ] && EOL="^C or go?"

    echo "${COLORING}- $1:${COLOR_STOP} ${EOL}"

    [ "$2" = 1 ] && read REPLY
}

kill_after()
{
    sleep $1
    kill `pidof $2` 2>/dev/null
}

ask=1

clear # --------------------------------------------------------------------------------------------------------------

echo; step 'TODO: Refactor printing step names + asking a confirmation to continue (after the step name is announced) into a fn'

echo; step 'TODO: Building containers for two sites'

echo; step 'Starting main site' $ask
echo; elrun cluster__up

echo; step 'Waiting for ES cluster' $ask
      kill_after 60 watch &
echo; elrun cluster_watch
echo

echo; step 'Initial ES cluster state'
echo; elrun list_cluster_settings
echo; elrun list_disk
echo; elrun list_indices
echo; elrun list_shards

echo; step 'TODO: Creating ES indices'

echo; step 'TODO: Changing ES replicas number'

# health status index        uuid                   pri rep docs.count docs.deleted store.size pri.store.size
# green  open   sampleindex2 OoN6uwOdS9ueoWw1Zuw1Xg   1   1          0            0       416b           208b
# yellow open   sampleindex  vcsIbSLYSzu7YNtBfNXUNg   1   2          0            0       416b           208b
# yellow open   hehe-index   WNaN5TZTQ92Vr81lgJQQlQ   1   3          0            0       416b           208b
# yellow open   laba-diena   nGeFJqc3QrKjVmpeL1XvzA   1   4          0            0       416b           208b

echo; step 'Exclude the node' $ask
echo; elrun exclude_node es03
echo; elrun list_disk
echo; elrun list_indices

echo; step 'Shutdown the node' $ask
echo; elrun cluster_es03_down
echo; elrun cluster_es03_offsite_down
echo

echo; step 'Reduced ES cluster'
echo; elrun list_disk
echo; elrun list_indices
echo; elrun list_shards

echo; step 'Bring up the backup node' $ask
echo; elrun cluster_es03_offsite_up
echo; elrun list_disk
echo; elrun list_indices

echo; step 'Wait for the node to join the cluster' $ask
      kill_after 25 watch &
echo; elrun cluster_watch
echo

echo; step 'Restored ES cluster'
echo; elrun list_disk
echo; elrun list_indices

echo; step 'Allow node to be routed again' $ask
echo; elrun exclude_node
echo; elrun list_disk
echo; elrun list_indices
echo

echo; step 'Wait for the replicas to distribute'
      kill_after 10 watch &
echo; elrun cluster_watch
echo

echo; step 'The final ES state'
echo; elrun list_disk
echo; elrun list_indices
echo; elrun list_shards

echo; step 'TODO: List the rebalanced Docker containers'

echo; step 'Destroy the containers' $ask
echo; elrun cluster_es03_offsite_down
echo; elrun cluster__down

echo; step 'TODO: Cleanup the used Docker Compose volumes too (a change in `elrun`)'

echo; step 'Demo is over.'
