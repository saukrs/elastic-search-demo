#!/usr/bin/env sh

clear
echo
echo - Initial state
echo
elrun list_cluster_settings
elrun list_disk
elrun list_indices
echo
echo Next?; read

echo
echo - Exclude the node
echo
elrun exclude_node es03
elrun list_disk
elrun list_indices
echo
echo Next?; read

echo
echo - Shutdown the node
echo
elrun cluster_es03_down
elrun list_disk
elrun list_indices
echo
echo Next?; read

echo
echo - Bring up the backup node
echo
elrun cluster_es03_offsite_up
elrun list_nodes
elrun list_disk
elrun list_indices
echo
echo Next?; read

echo
echo - Wait for the node to joing the cluster
echo
sleep 5
elrun list_nodes
elrun list_disk
elrun list_indices
echo
echo Next?; read

echo
echo - Allow node to be routed again
echo
elrun exclude_node
elrun list_disk
elrun list_indices
echo
echo - Demo is over.
