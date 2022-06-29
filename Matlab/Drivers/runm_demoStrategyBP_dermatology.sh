#!/bin/bash

nice /usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "run('demoStrategyBP_dermatology.m');exit;" | tail -n +11
