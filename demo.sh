#!/usr/bin/env sh

clear

echo; echo - Initial Docker state:
echo; elrun cluster_ps
echo; echo Next?; read REPLY

echo; echo - Initial ES cluster state:
echo; elrun list_cluster_settings
echo; elrun list_disk
echo; elrun list_indices
echo; echo Next?; read REPLY

echo; echo - Exclude the node
echo; elrun exclude_node es03
echo; elrun list_disk
echo; elrun list_indices
echo; echo Next?; read REPLY

echo; echo - Shutdown the node
echo; elrun cluster_es03_down
echo; elrun cluster_es03_offsite_down
echo; elrun list_disk
echo; elrun list_indices
echo; echo Next?; read REPLY

echo; echo - Bring up the backup node
echo; elrun cluster_es03_offsite_up
echo; elrun list_nodes
echo; elrun list_disk
echo; elrun list_indices
echo; echo Next?; read REPLY

echo; echo - Wait for the node to join the cluster:
echo; sleep 5
echo; elrun list_nodes
echo; elrun list_disk
echo; elrun list_indices
echo; echo Next?; read REPLY

echo; echo - Allow node to be routed again
echo; elrun exclude_node
echo; elrun list_disk
echo; elrun list_indices
echo; echo - Demo is over.
