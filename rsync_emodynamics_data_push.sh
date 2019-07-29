#!/bin/bash

echo "==========================================================================="
echo "Syncing Emodynamics Data: LOCAL to CLUSTER"
echo "==========================================================================="

#if [ -d "G:\" ]; then
#    #local_path="G:\emodynamics\data\"
#    #user="chenku"
if [ -d "/Volumes/hoycw_clust/" ]; then
    local_path="/Volumes/hoycw_clust/emodynamics/data/"
    user="hoycw"
else
    echo "Kuan and Colin root_dirs not available, exiting..."
    exit 1
fi

rsync -vrltD --update --progress ${local_path} ${user}@nx2.neuro.berkeley.edu:/home/knight/emodynamics/data/
