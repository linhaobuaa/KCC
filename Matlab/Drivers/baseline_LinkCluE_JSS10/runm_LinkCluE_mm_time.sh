#!/bin/bash

nice /usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "run('compare_LinkCluE_mm_time.m');exit;" | tail -n +11