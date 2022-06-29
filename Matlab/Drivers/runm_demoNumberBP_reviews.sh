#!/bin/bash

nice /usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "run('demoNumberBP_reviews.m');exit;" | tail -n +11
