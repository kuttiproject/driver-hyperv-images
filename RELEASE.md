# Releases

Each release from this repository contains .zip files for supported versions of Kubernetes, and a file called **driver-hyperv-images.json** which describes these releases. The location on these files in the GitHub release is burned into the corresponding version of the hyperv driver.

## .zip files

These files can be built by manually following the instructions in [BUILDING.md](BUILDING.md).

## driver-hyperv-images.json

The schema for this file is as follows:

```json
{
    "KUBERNETES VERSION": {
        "ImageK8sVersion": "KUBERNETES VERSION (must match key above)",
        "ImageChecksum": "SHA256 CHECKSUM OF VHDX FILE INSIDE ZIP FILE",
        "ImageStatus": "NotDownloaded",
        "ImageSourceURL": "PATH TO ZIP FILE IN RELEASE",
        "ImageDeprecated": false
    },...
}
```

**NOTE:** The ImageChecksum property contains the SHA256 hash of the .vhdx file inside the .zip file, and _not_ the hash of the .zip file itself.

A sample is provided below:

```json
{
    "1.24":{
        "ImageK8sVersion": "1.24",
        "ImageChecksum": "21e182e60388cd3f168fd6990ac7a2e0dc9790f48c5a54d1fb39649a4f5d1401",
        "ImageStatus": "NotDownloaded",
        "ImageSourceURL":"https://github.com/kuttiproject/driver-hyperv-images/releases/download/v0.1/kutti-k8s-1.24.vhdx.zip"
    }
}
```
