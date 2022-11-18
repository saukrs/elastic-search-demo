#!/usr/bin/env sh

kill_after()
{
    sleep $1
    kill `pidof $2`
}

clear

echo; echo - TODO: Refactor printing step names + asking a confirmation to continue \(after the step name is announced\) into a fn:

# step "- Starting main site:" ask

echo; echo - TODO: Building containers for two sites:

echo; echo - Starting main site:
echo; elrun cluster__up
echo; echo Next?; read REPLY

echo; echo - Waiting for ES cluster:
      kill_after 60 watch &
echo; elrun cluster_watch
echo

echo; echo - Initial ES cluster state:
echo; elrun list_cluster_settings
echo; elrun list_disk
echo; elrun list_indices
echo; elrun list_shards
echo; echo Next?; read REPLY

echo; echo - TODO: Creating ES indices:

echo; echo - TODO: Changing ES replicas number:

# health status index        uuid                   pri rep docs.count docs.deleted store.size pri.store.size
# green  open   sampleindex2 OoN6uwOdS9ueoWw1Zuw1Xg   1   1          0            0       416b           208b
# yellow open   sampleindex  vcsIbSLYSzu7YNtBfNXUNg   1   2          0            0       416b           208b
# yellow open   hehe-index   WNaN5TZTQ92Vr81lgJQQlQ   1   3          0            0       416b           208b
# yellow open   laba-diena   nGeFJqc3QrKjVmpeL1XvzA   1   4          0            0       416b           208b

echo; echo - Exclude the node
echo; elrun exclude_node es03
echo; elrun list_disk
echo; elrun list_indices
echo; echo Next?; read REPLY

echo; echo - Shutdown the node
echo; elrun cluster_es03_down
echo; elrun cluster_es03_offsite_down
echo

echo; echo - Reduced ES cluster:
echo; elrun list_disk
echo; elrun list_indices
echo; elrun list_shards
echo; echo Next?; read REPLY

echo; echo - Bring up the backup node
echo; elrun cluster_es03_offsite_up
echo; elrun list_disk
echo; elrun list_indices
echo; echo Next?; read REPLY

echo; echo - Wait for the node to join the cluster:
      kill_after 25 watch &
echo; elrun cluster_watch
echo

echo; echo - Restored ES cluster:
echo; elrun list_disk
echo; elrun list_indices
echo; echo Next?; read REPLY

echo; echo - Allow node to be routed again
echo; elrun exclude_node
echo; elrun list_disk
echo; elrun list_indices
echo

echo; echo - Wait for the replicas to distribute:
      kill_after 10 watch &
echo; elrun cluster_watch
echo

echo; echo - The final ES state:
echo; elrun list_disk
echo; elrun list_indices
echo; elrun list_shards
echo; echo Next?; read REPLY

echo; echo - TODO: List the rebalanced Docker containers

echo; echo - Destroy the containers:
echo; elrun cluster_es03_offsite_down
echo; elrun cluster__down

echo; echo - TODO: Cleanup the used Docker Compose volumes too \(a change in \`elrun\`\).

echo; echo - Demo is over.
