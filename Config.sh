
# Download ISO file
cd /tmp
wget http://192.168.56.1/sw/OS/OEL7U1.iso
wget http://192.168.56.1/sw/OS/ubuntu-14.04.2-server-amd64.iso

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

cobbler profile edit --name ubuntu-14.04.2-server-x86_64 --kickstart ''
