#!/bin/bash

nice /usr/applic/bin/matlab -nodisplay -nosplash -nodesktop -r "run('draw_boxplot_NumberBP.m');exit;" | tail -n +11
