# Raspberry Pi: Mount & Format External Hard Drive (Headless Setup)

This guide walks you through connecting and formatting an external USB hard drive on a headless Raspberry Pi (no screen), with the drive mounted as `/mnt/samsung`.

---

## 🧰 Prerequisites
- A Raspberry Pi running Raspberry Pi OS (Lite or full)
- SSH access to the Pi
- A connected external USB hard drive

---

## 🪛 Step 1: Identify the Drive
SSH into the Raspberry Pi and run:

```bash
lsblk
```

Look for a device like `/dev/sda` or `/dev/sda1`. If you're unsure, run:

```bash
sudo fdisk -l
```

---

## 💣 Step 2: Wipe Existing Partitions (if needed)
> ⚠️ This will erase the entire drive!

```bash
sudo parted /dev/sda
```

Inside the parted prompt:
```bash
(parted) print
(parted) rm 1       # Repeat if multiple partitions exist
(parted) quit
```

---

## 🧱 Step 3: Create New Partition Table & Partition
```bash
sudo parted /dev/sda mklabel gpt
sudo parted -a optimal /dev/sda mkpart primary ext4 0% 100%
```

---

## 🧽 Step 4: Format the Partition
Assuming the new partition is `/dev/sda1`:
```bash
sudo mkfs.ext4 /dev/sda1
```

---

## 📂 Step 5: Create a Mount Point
```bash
sudo mkdir -p /mnt/samsung
```

---

## 🔗 Step 6: Mount the Drive
```bash
sudo mount /dev/sda1 /mnt/samsung
```

Verify it works:
```bash
ls /mnt/samsung
```

---

## 🔁 Step 7: Auto-Mount at Boot
Get the UUID:
```bash
sudo blkid /dev/sda1
```

Example output:
```
/dev/sda1: UUID="1234-5678" TYPE="ext4"
```

Edit fstab:
```bash
sudo nano /etc/fstab
```

Add this line (replace UUID accordingly):
```
UUID=1234-5678 /mnt/samsung ext4 defaults,nofail 0 0
```

Then test it:
```bash
sudo mount -a
```

---

## 🔐 Step 8: Set Permissions
To allow the `pi` user to write:
```bash
sudo chown -R pi:pi /mnt/samsung
```

---

## ✅ Done!
- Your drive is mounted at `/mnt/samsung`
- It will auto-mount at startup
- You can now use it for file storage, sharing, backups, etc.

