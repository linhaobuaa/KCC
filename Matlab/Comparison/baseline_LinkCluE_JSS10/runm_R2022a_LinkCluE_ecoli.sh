#!/bin/bash

/usr/local/MATLAB/R2022a/bin/matlab -nodisplay -nosplash -nodesktop -r "run('LinkCluE_ecoli.m');exit;" | tail -n +11
