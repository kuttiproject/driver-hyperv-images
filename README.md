# driver-hyperv-images

VM images for the kutti Microsoft Hyper-V driver

![GitHub release (latest by date)](https://img.shields.io/github/v/release/kuttiproject/driver-hyperv-images?include_prereleases)

This repository contains build instructions for building images for the kutti Hyper-V driver. For now, its releases are the download source of these images for the kutti system.

## Image Kubernetes Versions

We will try and maintain images for the current Kubernetes version, and two earlier minor versions. Versions older than that will be deprecated, but not removed. In time, there will be a strategy for image removal.

## Building Images

Images can be built by manually following the instructions in [BUILDING.md](BUILDING.md).

## Releases

Details of creating releases can be found in [RELEASE.md](RELEASE.md).

## Release Versioning

Releases will usually follow the major and minor version number of the [driver-hyperv](https://github.com/kuttiproject/driver-hyperv) project. Sometimes, this repository's releases may lag by a version.

## Components

The images in this repository are built from open source components. Details can be found in [COMPONENTS.md](COMPONENTS.md).
