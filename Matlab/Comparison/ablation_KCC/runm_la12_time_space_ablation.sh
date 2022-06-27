#!/bin/bash

# for 224
# /usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "run('compare_la12_time_space_ablation.m');exit;" | tail -n +11

# for lxhalle
nice /usr/applic/bin/matlab -nodisplay -nosplash -nodesktop -r "run('compare_la12_time_space_ablation.m');exit;" | tail -n +11
