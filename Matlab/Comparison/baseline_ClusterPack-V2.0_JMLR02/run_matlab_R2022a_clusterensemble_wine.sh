#!/bin/bash

/usr/local/MATLAB/R2022a/bin/matlab -nodisplay -nosplash -nodesktop -r "run('clusterensemble_wine.m');exit;" | tail -n +11
