#!/bin/bash

nice /usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "run('demoStrategyBP_wine.m');exit;" | tail -n +11
