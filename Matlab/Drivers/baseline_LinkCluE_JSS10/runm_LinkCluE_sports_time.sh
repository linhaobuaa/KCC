#!/bin/bash

nice /usr/applic/bin/matlab -nodisplay -nosplash -nodesktop -r "run('compare_LinkCluE_sports_time.m');exit;" | tail -n +11