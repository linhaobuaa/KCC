#!/bin/bash

nice /usr/applic/bin/matlab -nodisplay -nosplash -nodesktop -r "run('compare_LinkCluE_ecoli_time.m');exit;" | tail -n +11