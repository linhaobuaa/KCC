#!/bin/bash

nice /usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "run('compare_mm_time_space_ablation.m');exit;" | tail -n +11