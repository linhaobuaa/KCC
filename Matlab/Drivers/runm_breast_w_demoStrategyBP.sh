#!/bin/bash

nice /usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "run('demoStrategyBP_breast_w.m');exit;" | tail -n +11
