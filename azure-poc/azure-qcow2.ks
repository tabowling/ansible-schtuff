# For the Azure POC, this currently requires modifying
# composer's kickstart template files.  Put this file in
# /usr/share/lorax/composer.  Then do the following
# cd /usr/share/lorax/composer
# mv partitioned-disk.ks orig-partitioned-disk.ks
# mv qcow2.ks orig-qcow2.ks
# ln -s orig-partitioned-disk.ks partitioned-disk.ks
# ln -s orig-qcow2.ks qcow2.ks

# Lorax Composer qcow2 output kickstart template

# Basic services
services --enabled=sshd,chronyd
skipx
auth --passalgo=sha512 --useshadow
# Firewall configuration
firewall --enabled --ssh

# Firewall configuration
#firewall --enabled

# NOTE: The root account is locked by default
# Network information
network  --bootproto=dhcp --onboot=on --activate --device=eth0
# System keyboard
keyboard --xlayouts=us --vckeymap=us
# System language
lang en_US.UTF-8
# SELinux configuration
selinux --enforcing
# Installation logging level
logging --level=info
# Shutdown after installation
shutdown
# System timezone
timezone  US/Eastern
# System bootloader configuration
bootloader --location=mbr
# Clear the Master Boot Record
zerombr

%post
# Remove random-seed
rm /var/lib/systemd/random-seed

# Clear /etc/machine-id
rm /etc/machine-id
touch /etc/machine-id

# Added for Azure bare metal https://projects.engineering.redhat.com/browse/RHELPLAN-15346
mpathconf --enable --with_multipathd y
dracut --force --add multipath

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'
%end

%packages
kernel
-dracut-config-rescue
selinux-policy-targeted
grub2
@base
kexec-tools

# Make sure virt guest agents are installed
qemu-guest-agent
spice-vdagent

# NOTE lorax-composer will add the blueprint packages below here, including the final %end
