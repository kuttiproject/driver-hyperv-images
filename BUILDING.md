# VM Images for kutti Hyper-V driver

The following instructions are for manual building of images. For automated building, see [PACKER.md](PACKER.md).

## Base Setup

1. Download **debian-11.3.0-amd64-netinst.iso** (Debian "bullseye" _"stable"_ release, _"netinst"_ image) via [https://www.debian.org/releases/](https://www.debian.org/releases/).
2. Create a virtual machine with at least 2 cores, 2GB RAM, 8MB video memory and 100GB hard disk. Connect it to the Default switch. Disable checkpoints. Mount the iso from step 1 on the CDROM device. Boot. From the installer, choose "Install".
3. In the "Set up users and passwords" step, provide "Pass@word1" as the password for the root user. Next, create a user with the Full Name set as "Kutti Admin" and username as "kuttiadmin". The password should again be "Pass@word1".
4. In the "Partition Disks" step, choose "Manual". Select the hard disk. Create a new, empty partition table on it. Select the "Free Space" on the hard disk. Create a new partition, using the maximum space available, type Primary. Set the Bootable flag to on. Finish partitioning and write the changes to disk. **Confirm that you do not want swap space**, and continue the installation.
5. In the "Software Selection" step, choose _only_ "SSH server".
6. Install GRUB to the hard disk, and complete the installation. Reboot.
7. **Note:** To prevent history from being recorded during setup, run `unset HISTFILE` on every login from this step onwards.
8. Log on as root. Edit **/etc/default/grub**, and set the variable **GRUB_TIMEOUT** to 0. Run `update-grub`. Reboot.
9. Log on as root. Run `apt update && apt install sudo`.
10. Run `adduser kuttiadmin sudo`.
11. Run `adduser --gecos "User 1" user1`. Set the password to **Pass@word1**.
12. Run `adduser user1 sudo`.
13. Run `visudo -f /etc/sudoers.d/kutti`. In the editor, paste `%kuttiadmin ALL=(ALL:ALL) NOPASSWD:ALL`. Save and close the file. Log out.
14. Log on as user1. Run `sudo ls` to deal with first-time sudo message. Verify that it asks for a password. Log out.
15. Log on as kuttiadmin. Run `sudo ls`. Verify that it does not ask for a password. Log out.
16. Log on as root. Run `apt install apt-transport-https bash-completion vim curl gnupg`

## motd

17. Edit the file **/etc/motd**. Replace its contents with: `Welcome to kutti.`

## DHClient configuration for long lease

18. Edit the file **/etc/dhcp/dhclient.conf**. Add the following to the end: `send dhcp-lease-time 604800;`. This is required because the driver uses the Default Switch in Hyper-V for all nodes, and receives IP addresses via DHCP. We want to avoid IP clashes if possible.

## Clean up uneeded software

19. Run `apt-get purge -y vim-tiny installation-report`

## For compacting the VM

20. Log on as root. Run `dd if=/dev/zero of=zerofillfile bs=1G`
21. Run `rm zerofillfile`.
22. Run `poweroff`.
23. On the host, run `Optimize-VHD "[drive]:\[path_to_image_file]\[name_of_image_file].vhdx" -Mode Full`.

## Install Kubernetes

24. Start the VM. Copy the included **attachments/kutti-installscripts** directory  to **/home/kuttiadmin/kutti-installscripts** in the VM using `scp`. Then, copy the included **buildscripts/setup-kubernetes.sh** file to the same directory in the VM. The files should have UNIX line endings after the copy. Verify that, and rectify if needed.
25. Use SSH to log on to the installation VM as kuttiadmin. Go to the **kutti-installscripts** directory and run `chmod +x *.sh`. Then, run `ln -v -s -t /usr/local/bin/ /home/kuttiadmin/kutti-installscripts/*.sh`.
26. Run `KUBE_VERSION=<version> ./setup-kubernetes.sh` to install kubernetes with containderd. Currently suppported versions are:

* 1.24\* (The '*' is important)
* 1.23*
* 1.22*

27. Verify that kubeadm is installed by running `kubeadm`. Verify the kubectl autocomplete works.

## DHClient configuration (optional)

28. Edit the file **/etc/dhcp/dhclient.conf**. Add the following to the end: `prepend domain-name-servers 1.1.1.1, 8.8.8.8;`

Compact the VM once more, and export it. Collect the VHDX file from the exported VM location, and compress it into a .zip file named **kutti-\<kubernetes version\>.vhdx.zip**. **NOTE:** Do not use Windows Explorer to create the .zip file. On Windows, use 7Zip instead.

## Publishing a release

Collect the .zip files for the supported versions, and create a `driver-hyperv-images.json` file describing them. Then publish a GitHub release, and upload the `driver-hyperv-images.json` file and the .zip files to it. Details can be found in [RELEASE.md](RELEASE.md).
