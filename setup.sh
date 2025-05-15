#!/bin/bash

set -e

# Prompt for confirmation
echo "⚠️  This will format your external hard drive. Continue? (y/n)"
read CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo "Aborted."
    exit 1
fi

# Prompt for the device (default to /dev/sda)
read -p "Enter the device name (e.g., /dev/sda): " DEVICE
DEVICE=${DEVICE:-/dev/sda}

# Prompt for mount name and build full mount path
read -p "Enter the name to use for the mount folder (default: samsung): " MOUNTNAME
MOUNTNAME=${MOUNTNAME:-samsung}
MOUNTPOINT="/mnt/$MOUNTNAME"

# Remove existing partitions
echo "Removing existing partitions..."
sudo parted "$DEVICE" --script mklabel gpt
sudo parted -a optimal "$DEVICE" --script mkpart primary ext4 0% 100%

PARTITION="${DEVICE}1"

# Format the new partition
echo "Formatting $PARTITION as ext4..."
sudo mkfs.ext4 "$PARTITION"

# Create mount point and mount
echo "Creating mount point $MOUNTPOINT and mounting..."
sudo mkdir -p "$MOUNTPOINT"
sudo mount "$PARTITION" "$MOUNTPOINT"

# Set permissions
echo "Setting permissions to allow all users to write..."
sudo chmod -R 777 "$MOUNTPOINT"

# Get UUID and add to /etc/fstab
UUID=$(sudo blkid -s UUID -o value "$PARTITION")
echo "Adding to /etc/fstab..."
echo "UUID=$UUID $MOUNTPOINT ext4 defaults,nofail,umask=000 0 0" | sudo tee -a /etc/fstab

echo "✅ Drive formatted, mounted at $MOUNTPOINT, and set to auto-mount at boot."
