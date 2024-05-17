#!/bin/bash

#     Purpose:  Basic commands to check cluster health
#        Date:
#      Status:  Work in Progress
# Assumptions:
#        Todo:
#  References:
#       Notes: 

kubectl get events -A --sort-by=.lastTimestamp
