packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = "~> 1"
    }
  }
}

variable "iso-url" {
    # Location of the base debian netinst iso
    type = string
    default = "./iso/debian-12.2.0-amd64-netinst.iso"
}

variable "iso-checksum" {
    # Checksum of the base debian netinst iso
    type = string
    default = "sha256:23ab444503069d9ef681e3028016250289a33cc7bab079259b73100daee0af66"
}

source "hyperv-iso" "kutti-base" {
    # Before using this script, you need to obtain a debian
    # netinst ISO, and put it in a folder called "iso".
    # The iso name and its checksum should be updated here.
    # The last build used debian 12.2.0.
    iso_url = "${ var.iso-url }"
    iso_checksum = "${ var.iso-checksum }"

    # Create a VM with 
    #  - 2 cpu cores
    #  - 2 GiB RAM
    #  - 100 GiB hard disk
    cpus = "2"
    memory = "2048"
    disk_size = "102400"
    generation = "1"

    # Hyper-V Switch to connect to
    switch_name = "Default Switch"

    # HTTP serve the preseed file
    http_directory = "buildhttp"

    # Set up a boot command for the Debian Netinst CD.
    # Important aspects are:
    #   - DEBIAN_FRONTEND and priority ensure no chatter
    #   - fb ensures no framebuffer, which we don't need
    #   - auto specifies a preseeded installation
    #   - url specifies the location of the preseed file
    #   - domain and hostname must be specified here,
    #     because an automatic installation sets up the
    #     network first, and needs these parameters to 
    #     be set in the boot command.
    # Also see the commented preseed file to see what 
    # exactly gets installed and configured.
    boot_wait = "30s"
    boot_command = [
        "<esc><wait><esc><wait>",
        "install <wait>",
#        "DEBIAN_FRONTEND=noninteractive <wait>",
#        "priority=critical <wait>",
        "fb=false <wait>",
        "auto=true <wait>",
        "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed_bullseye.cfg <wait>",
        "domain=kuttiproject.org <wait>",
        "hostname=kutti <wait>",
        "<enter><wait>"
    ]

    # Although this step needs no ssh, these settings must be
    # specified.
    ssh_username = "kuttiadmin"
    ssh_password = "Pass@word1"
    ssh_timeout = "20m"

    shutdown_command = "sudo poweroff"
    

    # The output file should be called kutti-base.ova
    vm_name = "kutti-base"
}

build {
    sources = [
        "sources.hyperv-iso.kutti-base"
    ]
}