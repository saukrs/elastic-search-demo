#!/usr/bin/env sh

step()
{
    local      GREEN="\e[32m"
    local COLOR_STOP="\e[0m"

    echo "${GREEN}- $1:${COLOR_STOP}"
}

kill_after()
{
    sleep $1
    kill `pidof $2` 2>/dev/null
}

clear

echo; step 'TODO: Refactor printing step names + asking a confirmation to continue (after the step name is announced) into a fn'

# step "- Starting main site:" ask

echo; step 'TODO: Building containers for two sites'

echo; step 'Starting main site'
echo; elrun cluster__up
echo; echo Next?; read REPLY

echo; step 'Waiting for ES cluster'
      kill_after 60 watch &
echo; elrun cluster_watch
echo

echo; step 'Initial ES cluster state'
echo; elrun list_cluster_settings
echo; elrun list_disk
echo; elrun list_indices
echo; elrun list_shards
echo; echo Next?; read REPLY

echo; step 'TODO: Creating ES indices'

echo; step 'TODO: Changing ES replicas number'

# health status index        uuid                   pri rep docs.count docs.deleted store.size pri.store.size
# green  open   sampleindex2 OoN6uwOdS9ueoWw1Zuw1Xg   1   1          0            0       416b           208b
# yellow open   sampleindex  vcsIbSLYSzu7YNtBfNXUNg   1   2          0            0       416b           208b
# yellow open   hehe-index   WNaN5TZTQ92Vr81lgJQQlQ   1   3          0            0       416b           208b
# yellow open   laba-diena   nGeFJqc3QrKjVmpeL1XvzA   1   4          0            0       416b           208b

echo; step 'Exclude the node'
echo; elrun exclude_node es03
echo; elrun list_disk
echo; elrun list_indices
echo; echo Next?; read REPLY

echo; step 'Shutdown the node'
echo; elrun cluster_es03_down
echo; elrun cluster_es03_offsite_down
echo

echo; step 'Reduced ES cluster'
echo; elrun list_disk
echo; elrun list_indices
echo; elrun list_shards
echo; echo Next?; read REPLY

echo; step 'Bring up the backup node'
echo; elrun cluster_es03_offsite_up
echo; elrun list_disk
echo; elrun list_indices
echo; echo Next?; read REPLY

echo; step 'Wait for the node to join the cluster'
      kill_after 25 watch &
echo; elrun cluster_watch
echo

echo; step 'Restored ES cluster'
echo; elrun list_disk
echo; elrun list_indices
echo; echo Next?; read REPLY

echo; step 'Allow node to be routed again'
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
echo; echo Next?; read REPLY

echo; step 'TODO: List the rebalanced Docker containers'

echo; step 'Destroy the containers'
echo; elrun cluster_es03_offsite_down
echo; elrun cluster__down

echo; step 'TODO: Cleanup the used Docker Compose volumes too (a change in `elrun`)'

echo; step 'Demo is over.'
