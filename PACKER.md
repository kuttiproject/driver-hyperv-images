# Packer Build Instructions

The images for this repository can be built using HashiCorp [Packer](https://www.packer.io/).

> **NOTE:** On 2023-03-08, a problem was noticed while using packer 1.8.1 on Windows 11 Pro 22H2. Newly created VMs would not get IP addresses from Hyper-V. Issues [#45](https://github.com/hashicorp/packer-plugin-hyperv/issues/45) and [#65](https://github.com/hashicorp/packer-plugin-hyperv/issues/65) describe the problem. The solution found to work was to build the [packer hyper-v plugin](https://github.com/hashicorp/packer-plugin-hyperv) from the main branch on that date (commit hash 07b09589d78ee583891abc064d16f8edbbd8c13d), and place the compiled executable in the project directory, as described in [this comment](https://github.com/hashicorp/packer-plugin-hyperv/issues/65#issuecomment-1420237055) of issue #65.

The build is done in two steps. The first step builds a base operating system image. The
second step can be run multiple times to generate images for different versions of Kubernetes.

## Build Prerequisites

1. Hyper-V, installed and enabled. The PowerShell Hyper-V module should be available.
2. HashiCorp Packer, version 1.7.2 or above.
3. A Debian netinst ISO image. This has to be downloaded into a folder called `iso` in this directory, and its name and checksum updated in the `kutti.step1.pkr.hcl` file.

## Build Instructions

1. Create a folder called `iso` in the current directory.
2. Download a Debian netinst ISO file into this directory.
3. Obtain the path and SHA256 checksum of this file.
4. Run `packer build -var iso-url=PATH -var iso-checksum=CHECKSUM kutti.step1.pkr.hcl` to generate an exported VM for a bare OS image.
5. Run `packer build -var "kube-version=DESIREDVERSION" kutti.step2.pkr.hcl`. Here, DESIREDVERSION is the kubernetes version, as it is published in the google debian repository for Kubernetes. 

## Details

### Step 1

The first step is the script `kutti.step1.pkr.hcl`, which builds an exported Hyper-V VM from a Debian netinst CD ISO image. It uses a preseed file to configure the installation. Some important settings are as follows:

* US keyboard layout and language is US
* Locale and timezone are India
* The root password is "Pass@word1"
* A user called "kuttiadmin" is created with the password "Pass@word1"
* The entire hard disk is made into a single data partition, _no swap_.
* `sudo` and `openssh` are installed.
* The kuttiadmin user is given sudo rights without a password.

### Step 2

The second step is the script `kutti.step.pkr.hcl`. This starts from a VM imported from the output of the previous step, and does the following:

* Configures GRUB for zero wait at boot
* Adds a user called `user1` with sudo access.
* Adds driver interface scripts to the image
* Installs and configures `containerd` from the Docker debian repositories
* Installs kubernetes. The version is controlled by a variable called KUBE_VERSION
* Uninstalls unneeded software installed during the build process
* Writes a huge file filled with zeroes to fill the virtual HDD, and deletes it
* Compacts the virtual hard disk
* Adds an icon
* Exports to the final VHDX.

## Makefile or Invoke-Build script

The steps described above can be performed via a supplied makefile and GNU make.
`make step1` and `make step2` can be used.

They can also be performed via the supplied build script **invoke.build.ps1** and
[Invoke-Build](https://github.com/nightroman/Invoke-Build). You can use
`Invoke-Build step1` and `Invoke-Build step1`.

## Compressing the .vhdx file

The .vhdx file produced by the second step should be renamed to **kutti-\<kubernetes version\>.vhdx**, and then compressed to a file called **kutti-\<kubernetes version\>.vhdx.zip**. **NOTE:** Do not use Windows Explorer to create the .zip file. On Windows, use 7Zip instead.

## Publishing a release

Collect the .zip files for the supported versions, and create a `driver-hyperv-images.json` file describing them. Then publish a GitHub release, and upload the `driver-hyperv-images.json` file and the .vhdx files to it. Details can be found in [RELEASE.md](RELEASE.md).
