#!/bin/bash

partitions="1 2 3 4 5"  
num=40  
for partition in $partitions  
do  
systemctl stop ceph-osd@$num.service  
ceph-osd -i $num --flush-journal  
((num++))
done 