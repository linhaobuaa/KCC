#!/bin/bash

nice /usr/applic/bin/matlab -nodisplay -nosplash -nodesktop -r "run('compare_ecoli_time_space_ablation.m');exit;" | tail -n +11