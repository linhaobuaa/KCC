#!/bin/bash

nice /usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "run('compare_iris_time_space_KCC.m');exit;" | tail -n +11