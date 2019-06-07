#!/bin/bash

genome=$1

bash TEanno01_straight.sh $genome > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)

