#!/bin/bash

nice /usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "run('compare_LinkCluE_iris_time.m');exit;" | tail -n +11