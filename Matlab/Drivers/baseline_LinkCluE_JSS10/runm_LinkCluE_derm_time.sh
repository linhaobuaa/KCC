#!/bin/bash

nice /usr/applic/bin/matlab -nodisplay -nosplash -nodesktop -r "run('compare_LinkCluE_derm_time.m');exit;" | tail -n +11