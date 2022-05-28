# Kutti Hyper-V Driver Interface

The kutti Hyper-V driver interacts with Hyper-V VMs created by this image via the following interface:

## SSH

The driver uses SSH to communicate with the VM and run the scripts defined below.

## User

Kutti uses a user called `kuttiadmin` with a hardcoded password to run commands inside VMs. This user has sudo privileges without the need of a password.

## Scripts

Kutti uses a number of scripts to perform common operations inside VMs. These are all installed in a subdirectory called `kutti-installscripts` under the home directory of the `kuttiadmin` user. Symbolic links to these are added in the `/usr/local/bin` directory.

The scripts are listed below:

## set-hostname.sh

This changes the hostname of a VM. It is invoked when a new node is added to a kutti cluster.

## capture-ca-certificates.sh

This captures or removes CA certificates. To capture, it uses openssl to make a call to a known HTTPS server, and saves the certificates it receives in a file called `/etc/ssl/certs/ca.crt`. To remove, it deletes that file.

## set-proxy.sh

This sets or removes node-wide proxy settings. To set, it adds lines defining `http_proxy`, `https_proxy` and `no_proxy` lines to `/etc/environment`. To remove, it deletes these lines.

## set-proxy-2.sh

This is an alternate method for setting or removing node-wide proxy settings. To set, it adds two files containing proxy settings: `/etc/profile.d/kutti-proxy.sh` for interactive programs, and `/etc/systemd/system.conf.d/kutti-proxy.conf` for daemons. To remove, it deletes these files.

## add-ca-certificate.sh

This adds a certificate to the operating system's trusted store.
