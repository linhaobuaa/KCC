#!/bin/bash

nice /usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "run('demoStrategyBP_pendigits.m');exit;" | tail -n +11
