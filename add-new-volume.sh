#!/bin/bash
# Rescan disks after increase on Vmware
for disk in /sys/class/block/sd*/device
do
   echo 1>$disk/rescan
done

# Get name of new volume Ie: data
echo "What is the name of the new volume? Ie: data"
read NEWVOLUME

# Get mount point
echo "What is the mount point going to be? Ie: /mnt/data"
read MOUNTPOINT

# Get location of disk that needs to be resized
echo "Which disk needs to be added to new volume? ie: /dev/sda"
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
echo "How much disk space will the new volume have? ie: 10G"
echo "Free space available:"
vgdisplay | grep "Free" | awk '{print $7}'
read SIZE

# Create new volume
lvcreate -n $NEWVOLUME -L $SIZE $VOLUMEGROUP

# Format new partition to xfs
mkfs.xfs /dev/$VOLUMEGROUP/$NEWVOLUME

# Create directory for mount point
mkdir $MOUNTPOINT

# Mount new volume to mountpoint
mount -o defaults,nodev /dev/$VOLUMEGROUP/$NEWVOLUME $MOUNTPOINT

# Add entry to fstab
echo "/dev/$VOLUMEGROUP/$NEWVOLUME      $MOUNTPOINT              xfs     defaults,nodev     0 0" >> /etc/fstab
