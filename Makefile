VERSION_MAJOR ?= 0
VERSION_MINOR ?= 1
BUILD_NUMBER  ?= 4
PATCH_NUMBER  ?= 
VERSION_STRING = $(VERSION_MAJOR).$(VERSION_MINOR).$(BUILD_NUMBER)$(PATCH_NUMBER)

OS_ISO_PATH ?= "iso/debian-12.10.0-amd64-netinst.iso"
OS_ISO_CHECKSUM ?= "sha256:ee8d8579128977d7dc39d48f43aec5ab06b7f09e1f40a9d98f2a9d149221704a"

KUBE_VERSION ?= 1.33
KUBE_VERSION_DESCRIPTION = $(or $(KUBE_VERSION),"latest")

define VM_DESCRIPTION
Kutti Hyper-V Image version $(VERSION_STRING)

Debian base image: $(OS_ISO_PATH)
Kubernetes version: $(KUBE_VERSION_DESCRIPTION)
endef
export VM_DESCRIPTION

.PHONY: usage
usage:
	@echo "Usage: make step1|step2|clean-step1|clean-step2|clean"

output-kutti-base/Virtual\ Machines/box.xml: kutti.step1.pkr.hcl
	packer build -var "iso-url=$(OS_ISO_PATH)" -var "iso-checksum=$(OS_ISO_CHECKSUM)" $<

output-kutti-hyperv/Virtual\ Hard\ Disks/kutti-base.vhdx: kutti.step2.pkr.hcl output-kutti-base/Virtual\ Machines/box.xml
	packer build -var "vm-version=$(VERSION_STRING)" -var "kube-version=$KUBE_VERSION" $<

.PHONY: step1
step1: output-kutti-base/Virtual\ Machines/box.xml

.PHONY: step2
step2: output-kutti-hyperv/Virtual\ Hard\ Disks/kutti-base.vhdx

.PHONY: all
all: step1 step2

.PHONY: clean-step1
clean-step1:
	rd /s output-kutti-base

.PHONY: clean-step2
clean-step2:
	rd /s output-kutti-hyperv

.PHONY: clean
clean: clean-step2 clean-step1