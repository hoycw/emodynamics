#!/bin/bash

echo "==========================================================================="
echo "Syncing Emodynamics Results: CLUSTER to LOCAL"
echo "==========================================================================="

#if [ -d "G:\" ]; then
#    #local_path="G:\emodynamics\results\"
#    #user="chenku"
if [ -d "/Volumes/hoycw_clust/" ]; then
    local_path="/Volumes/hoycw_clust/emodynamics/results/"
    user="hoycw"
else
    echo "Kuan and Colin root_dirs not available, exiting..."
    exit 1
fi

rsync -av --update --progress ${user}@nx2.neuro.berkeley.edu:/home/knight/emodynamics/results/ ${local_path}
