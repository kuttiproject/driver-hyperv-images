variable "kube-version" {
    type = string
    default = env("KUBE_VERSION")
}

variable "vm-version" {
    type = string
    default = "latest"
}

variable "vm-description" {
    type = string
    default = "Kutti Hyper-V Image"
}

source "hyperv-vmcx" "kutti-hyperv" {
    clone_from_vmcx_path="output-kutti-base"

    headless = "true"

    ssh_username = "kuttiadmin"
    ssh_password = "Pass@word1"
    ssh_timeout = "20m"

    shutdown_command = "sudo poweroff"


    cpus = "2"
    memory = "2048"
    disk_block_size = "1"
    generation = "1"

    vm_name = "kutti-hyperv"

    switch_name = "Default Switch"

    # This will export only the vhdx
    skip_export = "true"
}

build {
    sources = [
        "sources.hyperv-vmcx.kutti-hyperv"
    ]

    provisioner "shell" {
        # The setup-base script sets up:
        #   - GRUB settings
        #   - Some system utilities
        #   - containerd
        # The setup-kubernetes script sets up
        # kubelet, kubeadm and kubectl. The 
        # variable KUBE_VERSION controls which
        # version gets set up. Its value must
        # match the apt pin version published 
        # in the google debian repositry for 
        # Kubernetes. If it is left blank, the
        # latest version is used.
        scripts = [
            "buildscripts/setup-base.sh",
            "buildscripts/setup-kubernetes.sh"
        ]
        # These scripts must be run with sudo access
        execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
        valid_exit_codes = [0,2,2300218]
        expect_disconnect = true

        # Ensure the KUBE_VERSION variable.
        environment_vars = [
            "KUBE_VERSION=${ var.kube-version }"
        ]
    }

    provisioner "file" {
        # Files in the kutti-installscripts folder 
        # define the interface between the driver
        # and the OS in the VMs.
        sources = [
            "attachments/kutti-installscripts/"
        ]

        destination = "/home/kuttiadmin/kutti-installscripts"
    }

    provisioner "shell" {
        # The process-scripts script processes the
        # the tools installed in the prior step
        # as follows:
        #   * converts line endings to Linux/UNIX
        #   * makes them executable
        #   * makes symbolic links in /usr/local/bin.
        # The cleanup script removes unneeded stuff.
        # The stamp-kuttirelease script creates a 
        # file /etc/kutti-release, which contains
        # the versions of the components. 
        # The pre-compact script fills the VM hard
        # disk with zeroes, and the deletes the file.
        # This allows Hyper-V to compact the disk.
        scripts = [
            "buildscripts/process-scripts.sh",
            "buildscripts/cleanup.sh",
            "buildscripts/stamp-kuttirelease.sh",
            "buildscripts/pre-compact.sh"
        ]
        # These scripts must be run with sudo access
        execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
        valid_exit_codes = [0, 2300218]
        expect_disconnect = true

       # Ensure the VM_VERSION variable.
        environment_vars = [
            "VM_VERSION=${ var.vm-version }"
        ]
 
    }
}