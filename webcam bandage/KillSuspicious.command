#!/bin/bash

#  Script.command
#  webcam bandage
#
#  Created by Luis on 4/2/17.
#  Copyright © 2017 Luis Toledo. All rights reserved.
#
# lsof find open files
#   we are looking for VDC stream file
# then extract process name and PID
# lastly return the unique elements

kill $( lsof | grep "VDC" | awk '{print $2}' | awk '!seen[$0]++' )
