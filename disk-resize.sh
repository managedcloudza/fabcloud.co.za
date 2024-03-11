#!/bin/bash
# Rescan disks after increase on Vmware
for disk in /sys/class/block/sd*/device
do
   echo 1>$disk/rescan
done

# Get location of disk that needs to be resized
echo "Which disk needs to be resized? ie: /dev/sda"
fdisk -l | grep "Disk /dev/sd"
read DISK

# Create new partition on disk with free space
fdisk $DISK <<EEOF
p
n
p



w
EEOF

# Find partition to add
DEVICE=$(fdisk -l | grep $DISK | grep -v "Disk" | tail -1 | awk '{print $1}')

# Find which vole group to add to
VOLUMEGROUP=$(vgdisplay | grep "VG Name" | awk '{print $3}')

# Extend the volume group
vgextend $VOLUMEGROUP $DEVICE

# Extend the Logical Volume
echo "How much will we be increasing the volume by? ie: 10G"
echo "Free space available:"
vgdisplay | grep "Free" | awk '{print $7}'
read SIZE

# Increase specific logical volume
echo "Which Logical Volume needs the additional space?"
ls /dev/$VOLUMEGROUP
read LOGICALVOLUME

lvextend -L+$SIZE $VOLUMEGROUP/$LOGICALVOLUME

# Increase size of the XFS filesystem
echo "Which mount point do you want to increase?"
mount | grep /dev/mapper | awk '{print $3}'
read MOUNTPOINT
xfs_growfs $MOUNTPOINT
