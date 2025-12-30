# driver-hyperv-images

VM images for the kutti Microsoft Hyper-V driver

![GitHub release (latest by date)](https://img.shields.io/github/v/release/kuttiproject/driver-hyperv-images?include_prereleases)

This repository contains build instructions for building images for the kutti Hyper-V driver. Its releases are the download source of these images for the kutti system.

## Building Images

Images can be built by manually following the instructions in [BUILDING.md](BUILDING.md), or by running the Packer scripts as detailed in [PACKER.md](PACKER.md).

## Releases

Details of creating releases can be found in [RELEASE.md](RELEASE.md).

## Release Versioning

Releases will usually follow the major and minor version number of the [driver-hyperv](https://github.com/kuttiproject/driver-hyperv) project. Sometimes, this repository's releases may lag by a version.

## Image Kubernetes Versions

The latest release in this repository contains images for the current version of Kubernetes, and upto five versions before that. The current version and two versions before that are supported, the three before that are deprecated (You can run existing clusters created using them, but not create new clusters). Images of versions before that are deleted. 

Images in releases earlier than the latest are also deleted.

## Components

The images in this repository are built from open source components. Details can be found in [COMPONENTS.md](COMPONENTS.md).
