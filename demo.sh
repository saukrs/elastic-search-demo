elrun list_cluster_settings
elrun list_disk
elrun list_indices

elrun exclude_node es03
elrun list_disk
elrun list_indices

elrun cluster_es03_down
elrun list_disk
elrun list_indices

elrun cluster_es03_offsite_up
elrun list_nodes
elrun list_disk
elrun list_indices

sleep 5
elrun list_nodes
elrun list_disk
elrun list_indices

elrun exclude_node
elrun list_disk
elrun list_indices
