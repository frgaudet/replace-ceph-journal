#!/bin/bash

partitions="1 2 3 4 5"
# First OSD number
num=40
# Disk
disk=sda
for partition in $partitions
do
journal_uuid=$(uuidgen)
sgdisk --new=$partition:0:+5120M --change-name=$partition:'ceph journal' --partition-guid=$partition:$journal_uuid --typecode=$partition:45b0969e-9b03-4f30-b4c6-b4b80ceff106 --mbrtogpt -- /dev/$disk
partprobe /dev/$disk

systemctl stop ceph-osd@$num.service

ceph-osd -i $num --flush-journal

mv /var/lib/ceph/osd/ceph-$num/journal /var/lib/ceph/osd/ceph-$num/journal.old
ln -s /dev/disk/by-partuuid/$journal_uuid /var/lib/ceph/osd/ceph-$num/journal

mv /var/lib/ceph/osd/ceph-$num/journal_uuid /var/lib/ceph/osd/ceph-$num/journal_uuid.old
echo $journal_uuid > /var/lib/ceph/osd/ceph-$num/journal_uuid

chown -R ceph. /var/lib/ceph/osd/ceph-$num/journal
chown ceph. /var/lib/ceph/osd/ceph-$num/journal_uuid

ceph-osd -i $num --mkjournal
chown ceph. /dev/$disk$partition
systemctl start ceph-osd@$num.service
((num++))
done
