
-- Download ISO file

-- Mount media on server
mount -o loop /tmp/ubuntu-14.04.2-server-amd64.iso /mnt
cobbler import --name=ubuntu-14.04.2-server-amd64 --path=/mnt
umount /mnt
rm /tmp/ubuntu-14.04.2-server-amd64.iso

-- Mount media on server
mount -o loop /tmp/OEL7U1.iso /mnt
cobbler import --name=oracle-el7-amd64 --path=/mnt
umount /mnt
rm /tmp/OEL7U1.iso

