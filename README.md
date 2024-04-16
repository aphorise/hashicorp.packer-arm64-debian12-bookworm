
# HashiCrop `packer` Template of Arm64 Debian 12 (bookworm) 
This repo contains a `packer` template for building an ARM64 Vagrant Base Box of [Debian 12.2.2](https://www.debian.org/releases/bookworm/) (aka Bookworm) that was built on :apple: MacOS & M3 (aka Apple Silicon).

You can also find these boxes on Vagrant cloud:
 - [vagrantup.com/aphorise/boxes/debian12-arm64](https://app.vagrantup.com/aphorise/boxes/debian12-arm64)

For x86-64 / AMD64 builds see: [github.com/aphorise/hashicorp.packer-debian12-bookworm](https://github.com/aphorise/hashicorp.packer-debian12-bookworm).

### Prerequisites
Ensure that you already have the following applications installed & working:
 - [:apple: **macOS** (aka OSX) Fusion 13](https://www.vmware.com/products/fusion.html) for Apple Silicon (M1, M2 / M3).
 - [**Vagrant**](https://www.vagrantup.com/)
 - [**Packer**](https://www.packer.io/)


## Usage
1. Verify or set `sha512` that's used in `"iso_checksum": "sha512:..."`. Version specific values of SHASUM can be found on the URL path for that version - eg:
   - [https://cdimage.debian.org/cdimage/release/:warning:_***12.5.0***_:warning:/arm64/iso-cd/SHA512SUMS](https://cdimage.debian.org/cdimage/release/12.5.0/arm64/iso-cd/SHA512SUMS)

2. Make all changes as required (eg: `d-i mirror/country string Netherlands` in `ui-input.http/pressed_debian12-bookworm.cfg`) and thereafter commence with build using `packer` CLI:
    ```bash
    packer validate debian12-bookworm.json ;
    # // if output: Template validated successfully.
    packer build debian12-bookworm.json
    ```
3. Add Box & Test using Vagrant when box is produced:
    ```bash
    vagrant box add --name debian_arm vmware-debian-arm64-12.5.0.box ;
    vagrant init debian_arm ;
    vagrant up ;
    # // when done:
    vagrant destroy -f && vagrant box remove debian_arm
    ```

The resulting Vagrant Base **\*.box** file will be produced in the root of the repository (if no issues / errors).


## Install Notes

```bash
brew tap hashicorp/tap ;
brew install hashicorp/tap/hashicorp-vagrant && brew install hashicorp/tap/packer ;
vagrant plugin install vagrant-vmware-desktop ;
packer plugins install github.com/hashicorp/vmware && packer plugins install github.com/hashicorp/vagrant ;
```

## Last Run

```
  # Build 'vmware-iso.vmware-debian-arm64-12.5.0' finished after 8 minutes 39 seconds.
```

```bash
date '+%Y-%m-%d %H:%M:%S' && uname -a && sw_vers && \
 /Applications/VMware\ Fusion.app/Contents/Library/vmware-vmx-stats -v && \
 packer version && vagrant version ;
  # 2024-04-11 12:53:19
  # Darwin ... 23.4.0 Darwin Kernel Version 23.4.0: Wed Feb 21 21:44:54 PST 2024; root:xnu-10063.101.15~2/RELEASE_ARM64_T6030 arm64 arm Darwin
  # ProductName:		macOS
  # ProductVersion:		14.4
  # BuildVersion:		23E214
  # VMware Fusion Information:
  # VMware Fusion 13.5.0 build-22583790 STATS
  # Installed Version: 2.4.0
  # Latest Version: 2.4.1
```


## Reference & Credits:
Accreditation of other material used:
 * [aphorise/hashicorp.packer-debian10-buster](https://github.com/aphorise/hashicorp.packer-debian10-buster/) - x86 / AMD64 based Debian Bullseye.
 * [hashicorp/packer-plugin-vmware/example/](https://github.com/hashicorp/packer-plugin-vmware/tree/main/example) - official packer vmware plugin example.
 * [vmware-iso: Allow Architecture configuration for arm64/aarch64 #45](https://github.com/hashicorp/packer-plugin-vmware/issues/45#issuecomment-970316046)
------
