#!/bin/bash
export DEBIAN_FRONTEND=noninteractive ;
set -eu ; # abort this script when a command fails or an unset variable is used.
#set -x ; # echo all the executed commands.

# Remove history file
unset HISTFILE ;

# reset the random-seed.
# NB systemd-random-seed re-generates it on every boot and shutdown.
# NB you can prove that random-seed file does not exist on the image with:
#       sudo virt-filesystems -a ~/.vagrant.d/boxes/debian-9-amd64/0/libvirt/box.img
#       sudo guestmount -a ~/.vagrant.d/boxes/debian-9-amd64/0/libvirt/box.img -m /dev/sda1 --pid-file guestmount.pid --ro /mnt
#       sudo ls -laF /mnt/var/lib/systemd
#       sudo guestunmount /mnt
#       sudo bash -c 'while kill -0 $(cat guestmount.pid) 2>/dev/null; do sleep .1; done; rm guestmount.pid' # wait for guestmount to finish.
# see https://www.freedesktop.org/software/systemd/man/systemd-random-seed.service.html
# see https://manpages.debian.org/buster/manpages/random.4.en.html
# see https://manpages.debian.org/buster/manpages/random.7.en.html
# see https://github.com/systemd/systemd/blob/master/src/random-seed/random-seed.c
# see https://github.com/torvalds/linux/blob/master/drivers/char/random.c
systemctl stop systemd-random-seed ;
rm -f /var/lib/systemd/random-seed ;

# // remove temporary files
if [[ -f /home/vagrant/.sudo_as_admin_successful ]] ; then rm -rf /home/vagrant/.sudo_as_admin_successful ; fi ;

# clean packages.
apt-get -yq --purge remove linux-headers-$(uname -r) build-essential ;
apt-get -yq --purge autoremove ;
apt-get -yq purge $(dpkg --list |grep '^rc' |awk '{print $2}') ;
apt-get -yq purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}') ;
apt-get -y autoremove ;
apt-get -y clean ;

# zero the free disk space -- for better compression of the box file.
# NB prefer discard/trim (safer; faster) over creating a big zero filled file
#    (somewhat unsafe as it has to fill the entire disk, which might trigger
#    a disk (near) full alarm; slower; slightly better compression).
if [ "$(lsblk -no DISC-GRAN $(findmnt -no SOURCE /) | awk '{print $1}')" != '0B' ]; then
    fstrim -v / ;
else
    dd if=/dev/zero of=/EMPTY bs=1M || true; rm -f /EMPTY ;
fi

sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub ;
update-grub ;

# sync data to disk (fix packer)
sync ;
