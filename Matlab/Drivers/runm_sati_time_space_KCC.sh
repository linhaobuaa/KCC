#!/bin/bash

nice /usr/applic/bin/matlab -nodisplay -nosplash -nodesktop -r "run('compare_sati_time_space_KCC.m');exit;" | tail -n +11