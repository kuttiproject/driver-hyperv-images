Param(
    $VersionMajor  = (property VERSION_MAJOR  0),
    $VersionMinor  = (property VERSION_MINOR 1),
    $BuildNumber   = (property BUILD_NUMBER  3),
    $PatchString   = (property PATCH_NUMBER  ""),
    $OSISOPath     = (property OS_ISO_PATH "iso/debian-12.7.0-amd64-netinst.iso"),
    $OSISOChecksum = (property OS_ISO_CHECKSUM "sha256:8fde79cfc6b20a696200fc5c15219cf6d721e8feb367e9e0e33a79d1cb68fa83"),
    $KubeVersion   = (property KUBE_VERSION "1.32")
)

$VersionString = "$($VersionMajor).$($VersionMinor).$($BuildNumber)$($PatchString)" 
If ($KubeVersion -eq "") {
    $KubeVersionDescription = "latest"
} Else {
    $KubeVersionDescription = $KubeVersion
}


$VMDescription = @"
Kutti Hyper-V Image version: $($VersionString)

Debian base image: $($OSISOPath)
Kubernetes version: $($KubeVersionDescription)
"@

# Synopsis: Show usage
task . {
    Write-Host "Usage: Invoke-Build step1|step2|clean-step1|clean-step2|clean"
}

# Synopsis: Build debian base image
task step1 -Outputs "output-kutti-base/Virtual Machines/box.xml" -Inputs kutti.step1.pkr.hcl {
    exec {
        packer build -var "iso-url=$($OSISOPath)" -var "iso-checksum=$($OSISOChecksum)" $Inputs    
    }
} 

# Synopsis: Build kutti image
task step2 -Outputs "output-kutti-hyperv/Virtual Hard Disks/kutti-base.vhdx" -Inputs kutti.step2.pkr.hcl, "output-kutti-base/Virtual Machines/box.xml" {
    Write-Host "Building..."
    Write-Host $VMDescription
    exec {
        packer build -var "vm-version=$($VersionString)" -var "kube-version=$($KubeVersion)" kutti.step2.pkr.hcl
    }
}

# Synopsis: Build everything
task all step1, step2

# Synopsis: Delete built debian base image
task clean-step1 {
    Remove-Item -Recurse -Force output-kutti-base
}

# Synopsis: Delete built kutti image
task clean-step2 {
    Remove-Item -Recurse -Force output-kutti-hyperv
}

# Synopsis: Delete all output
task clean clean-step2, clean-step1
