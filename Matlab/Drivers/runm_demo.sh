#!/bin/bash

/usr/local/MATLAB/R2022a/bin/matlab -nodisplay -nosplash -nodesktop -r "run('/mnt/data1/home/linhao/KCC/Matlab/Drivers/demo.m');exit;" | tail -n +11
