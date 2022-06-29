#!/bin/bash

nice /usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "run('demoStrategyBP_iris.m');exit;" | tail -n +11
