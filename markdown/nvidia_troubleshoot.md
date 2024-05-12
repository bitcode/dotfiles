```bash

issue when lauching apps:

nvidia-smi                                                                                                                                                                               
NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver. Make sure that the latest NVIDIA driver is installed and running.


lspci -k | grep -A 2 -E "(VGA|3D)"                                                                                                                               
03:00.0 VGA compatible controller: NVIDIA Corporation TU104 [GeForce RTX 2070 SUPER] (rev a1)
        Subsystem: Micro-Star International Co., Ltd. [MSI] TU104 [GeForce RTX 2070 SUPER]
        Kernel modules: nvidiafb, nouveau, nvidia_drm, nvidia
--
05:00.0 VGA compatible controller: NVIDIA Corporation TU104 [GeForce RTX 2070 SUPER] (rev a1)
        Subsystem: Gigabyte Technology Co., Ltd TU104 [GeForce RTX 2070 SUPER]
        Kernel modules: nvidiafb, nouveau, nvidia_drm, nvidia


grep -i 'nvidia' /pro/modules
                                                         

cat /etc/default/grub                                                                                                 
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'

GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nouveau.modeset=1"
GRUB_CMDLINE_LINUX=""

# Uncomment to enable BadRAM filtering, modify to suit your needs
# This works with Linux (no patch required) and with any kernel that obtains
# the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
#GRUB_BADRAM="0x01234567,0xfefefefe,0x89abcdef,0xefefefef"

# Uncomment to disable graphical terminal (grub-pc only)
#GRUB_TERMINAL=console

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command `vbeinfo'
#GRUB_GFXMODE=640x480

# Uncomment if you don't want GRUB to pass "root=UUID=xxx" parameter to Linux
#GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
#GRUB_DISABLE_RECOVERY="true"

# Uncomment to get a beep at grub start
#GRUB_INIT_TUNE="480 440 1"


glxinfo | grep "OpenGL version"                                                                                                                                      at   02:20:17 PM
OpenGL version string: 4.5 (Compatibility Profile) Mesa 23.2.1-1ubuntu3.1~22.04.2



  dpkg --list | grep nvidia                                                                                                                            
ii  libnvidia-cfg1-550:amd64                   550.54.15-0ubuntu1                      amd64        NVIDIA binary OpenGL/GLX configuration library
ii  libnvidia-common-550                       550.54.15-0ubuntu1                      all          Shared files used by the NVIDIA libraries
rc  libnvidia-compute-535:amd64                535.161.07-0ubuntu0.22.04.1             amd64        NVIDIA libcompute package
ii  libnvidia-compute-550:amd64                550.54.15-0ubuntu1                      amd64        NVIDIA libcompute package
ii  libnvidia-compute-550:i386                 550.54.15-0ubuntu1                      i386         NVIDIA libcompute package
ii  libnvidia-decode-550:amd64                 550.54.15-0ubuntu1                      amd64        NVIDIA Video Decoding runtime libraries
ii  libnvidia-decode-550:i386                  550.54.15-0ubuntu1                      i386         NVIDIA Video Decoding runtime libraries
ii  libnvidia-encode-550:amd64                 550.54.15-0ubuntu1                      amd64        NVENC Video Encoding runtime library
ii  libnvidia-encode-550:i386                  550.54.15-0ubuntu1                      i386         NVENC Video Encoding runtime library
ii  libnvidia-extra-550:amd64                  550.54.15-0ubuntu1                      amd64        Extra libraries for the NVIDIA driver
ii  libnvidia-fbc1-550:amd64                   550.54.15-0ubuntu1                      amd64        NVIDIA OpenGL-based Framebuffer Capture runtime library
ii  libnvidia-fbc1-550:i386                    550.54.15-0ubuntu1                      i386         NVIDIA OpenGL-based Framebuffer Capture runtime library
ii  libnvidia-gl-550:amd64                     550.54.15-0ubuntu1                      amd64        NVIDIA OpenGL/GLX/EGL/GLES GLVND libraries and Vulkan ICD
ii  libnvidia-gl-550:i386                      550.54.15-0ubuntu1                      i386         NVIDIA OpenGL/GLX/EGL/GLES GLVND libraries and Vulkan ICD
rc  linux-modules-nvidia-535-6.5.0-18-generic  6.5.0-18.18~22.04.1                     amd64        Linux kernel nvidia modules for version 6.5.0-18
rc  linux-modules-nvidia-535-6.5.0-26-generic  6.5.0-26.26~22.04.1+1                   amd64        Linux kernel nvidia modules for version 6.5.0-26
ii  linux-objects-nvidia-535-6.5.0-18-generic  6.5.0-18.18~22.04.1                     amd64        Linux kernel nvidia modules for version 6.5.0-18 (objects)
ii  linux-objects-nvidia-535-6.5.0-26-generic  6.5.0-26.26~22.04.1+1                   amd64        Linux kernel nvidia modules for version 6.5.0-26 (objects)
ii  linux-signatures-nvidia-6.5.0-18-generic   6.5.0-18.18~22.04.1                     amd64        Linux kernel signatures for nvidia modules for version 6.5.0-18-generic
ii  linux-signatures-nvidia-6.5.0-26-generic   6.5.0-26.26~22.04.1+1                   amd64        Linux kernel signatures for nvidia modules for version 6.5.0-26-generic
rc  nvidia-compute-utils-535                   535.161.07-0ubuntu0.22.04.1             amd64        NVIDIA compute utilities
ii  nvidia-compute-utils-550                   550.54.15-0ubuntu1                      amd64        NVIDIA compute utilities
ii  nvidia-dkms-550-open                       550.54.15-0ubuntu1                      amd64        NVIDIA DKMS package (open kernel module)
ii  nvidia-driver-550-open                     550.54.15-0ubuntu1                      amd64        NVIDIA driver (open kernel) metapackage
ii  nvidia-firmware-535-535.154.05             535.154.05-0ubuntu0.22.04.1             amd64        Firmware files used by the kernel module
ii  nvidia-firmware-535-535.161.07             535.161.07-0ubuntu0.22.04.1             amd64        Firmware files used by the kernel module
ii  nvidia-firmware-550-550.54.15              550.54.15-0ubuntu1                      amd64        Firmware files used by the kernel module
rc  nvidia-kernel-common-535                   535.161.07-0ubuntu0.22.04.1             amd64        Shared files used with the kernel module
ii  nvidia-kernel-common-550                   550.54.15-0ubuntu1                      amd64        Shared files used with the kernel module
ii  nvidia-kernel-source-550-open              550.54.15-0ubuntu1                      amd64        NVIDIA kernel source package
ii  nvidia-prime                               0.8.17.1                                all          Tools to enable NVIDIA's Prime
ii  nvidia-settings                            510.47.03-0ubuntu1                      amd64        Tool for configuring the NVIDIA graphics driver
ii  nvidia-utils-550                           550.54.15-0ubuntu1                      amd64        NVIDIA driver support binaries
ii  screen-resolution-extra                    0.18.2                                  all          Extension for the nvidia-settings control panel
ii  xserver-xorg-video-nvidia-550              550.54.15-0ubuntu1                      amd64        NVIDIA binary Xorg driver

cat /etc/X11/xorg.conf                                                                                                                                     
cat: /etc/X11/xorg.conf: No such file or directory

which Xorg                                                                                                                                                 
/usr/bin/Xorg

sudo Xorg -version                                                                                                                                         

X.Org X Server 1.21.1.4
X Protocol Version 11, Revision 0
Current Operating System: Linux mlops 6.5.0-26-generic #26~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Tue Mar 12 10:22:43 UTC 2 x86_64
Kernel command line: BOOT_IMAGE=/boot/vmlinuz-6.5.0-26-generic root=UUID=f551b55d-4e21-4737-add1-a62de5ed044f ro quiet splash vt.handoff=7
xorg-server 2:21.1.4-2ubuntu1.7~22.04.9 (For technical support please see http://www.ubuntu.com/support) 
Current version of pixman: 0.40.0
	Before reporting problems, check http://wiki.x.org
	to make sure that you have the latest version.

glxgears                                                                                                                                                  took   5s at   02:23:14 PM
20505 frames in 5.0 seconds = 4100.921 FPS
21136 frames in 5.0 seconds = 4227.139 FPS
21081 frames in 5.0 seconds = 4216.042 FPS


grep -i 'drm' /proc/modules                                                                                                                              took   16s at   02:23:52 PM
drm 765952 1 typec_displayport, Live 0x0000000000000000


grep -i 'nouveau' /proc/modules
 "returns empty"

nvidia-xconfig                                                                                                                                             at   12:39:41 PM

WARNING: Unable to locate/open X configuration file.


WARNING: Unable to parse X.Org version string.

Package xorg-server was not found in the pkg-config search path.
Perhaps you should add the directory containing `xorg-server.pc'
to the PKG_CONFIG_PATH environment variable
No package 'xorg-server' found

ERROR: Unable to write to directory '/etc/X11'.

uname -m && cat /etc/*release                                                                                                                              at   12:39:54 PM
x86_64
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=22.04
DISTRIB_CODENAME=jammy
DISTRIB_DESCRIPTION="Ubuntu 22.04.4 LTS"
PRETTY_NAME="Ubuntu 22.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.4 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy

                                                                                                                                           at   12:50:29 PM
modinfo nvidia                                                                                                                                                       at   02:25:17 PM
filename:       /lib/modules/6.5.0-26-generic/updates/dkms/nvidia.ko
import_ns:      DMA_BUF
alias:          char-major-195-*
version:        550.54.15
supported:      external
license:        Dual MIT/GPL
firmware:       nvidia/550.54.15/gsp_tu10x.bin
firmware:       nvidia/550.54.15/gsp_ga10x.bin
softdep:        pre: ecdh_generic,ecdsa_generic
srcversion:     A9C4C4C468CDED5BB5E2224
alias:          pci:v000010DEd*sv*sd*bc06sc80i00*
alias:          pci:v000010DEd*sv*sd*bc03sc02i00*
alias:          pci:v000010DEd*sv*sd*bc03sc00i00*
depends:        ecc,drm
retpoline:      Y
name:           nvidia
vermagic:       6.5.0-26-generic SMP preempt mod_unload modversions
sig_id:         PKCS#7
signer:         mlops Secure Boot Module Signature key
sig_key:        29:80:51:1E:7D:08:C7:7C:BD:8D:DF:82:64:3F:F4:5F:32:8F:3F:DE
sig_hashalgo:   sha512
signature:      36:97:C3:AA:30:BC:E2:4E:83:78:13:76:25:3C:E5:AD:C8:0B:01:79:
                86:9B:BB:8D:38:7F:FF:36:C2:0B:6F:8D:33:64:75:6C:78:92:87:79:
                48:BB:46:7E:50:3C:5E:4A:4B:97:BA:3B:00:09:28:DB:44:53:C7:02:
                C6:E4:74:8D:AE:2B:4E:17:73:96:C5:32:99:04:2B:8F:63:7E:95:C2:
                1A:59:73:74:9C:21:D7:97:86:DA:67:25:CB:70:B8:B2:4F:4F:EE:33:
                2C:14:BE:CC:1A:B8:26:65:1C:19:67:9B:F2:83:7D:36:E6:50:4A:57:
                A5:67:7D:41:99:0A:BA:99:8B:2C:EE:8F:34:82:5F:1A:E4:D5:F1:70:
                E3:79:74:4F:B5:EF:53:D2:5E:00:65:89:B1:9B:42:7E:26:FB:77:4B:
                1C:08:D1:DC:9A:DE:E8:B6:35:B3:2C:96:EB:DB:63:CD:3A:AB:71:CE:
                05:56:17:C7:5A:31:EC:C4:D4:2E:8C:11:AB:97:9C:21:04:76:D3:DA:
                D7:A7:78:5D:7B:AB:41:8C:D9:A1:0E:08:DF:BE:7C:ED:C3:AC:4E:27:
                55:B2:4A:EF:CB:CF:53:C3:21:F6:46:F2:79:5E:2F:75:45:0E:5E:61:
                E4:4A:BE:4A:13:9F:C7:6E:8D:02:A9:7A:EA:E3:5B:E1
parm:           NvSwitchRegDwords:NvSwitch regkey (charp)
parm:           NvSwitchBlacklist:NvSwitchBlacklist=uuid[,uuid...] (charp)
parm:           NVreg_ResmanDebugLevel:int
parm:           NVreg_RmLogonRC:int
parm:           NVreg_ModifyDeviceFiles:int
parm:           NVreg_DeviceFileUID:int
parm:           NVreg_DeviceFileGID:int
parm:           NVreg_DeviceFileMode:int
parm:           NVreg_InitializeSystemMemoryAllocations:int
parm:           NVreg_UsePageAttributeTable:int
parm:           NVreg_EnablePCIeGen3:int
parm:           NVreg_EnableMSI:int
parm:           NVreg_TCEBypassMode:int
parm:           NVreg_EnableStreamMemOPs:int
parm:           NVreg_RestrictProfilingToAdminUsers:int
parm:           NVreg_PreserveVideoMemoryAllocations:int
parm:           NVreg_EnableS0ixPowerManagement:int
parm:           NVreg_S0ixPowerManagementVideoMemoryThreshold:int
parm:           NVreg_DynamicPowerManagement:int
parm:           NVreg_DynamicPowerManagementVideoMemoryThreshold:int
parm:           NVreg_EnableGpuFirmware:int
parm:           NVreg_EnableGpuFirmwareLogs:int
parm:           NVreg_OpenRmEnableUnsupportedGpus:int
parm:           NVreg_EnableUserNUMAManagement:int
parm:           NVreg_MemoryPoolSize:int
parm:           NVreg_KMallocHeapMaxSize:int
parm:           NVreg_VMallocHeapMaxSize:int
parm:           NVreg_IgnoreMMIOCheck:int
parm:           NVreg_NvLinkDisable:int
parm:           NVreg_EnablePCIERelaxedOrderingMode:int
parm:           NVreg_RegisterPCIDriver:int
parm:           NVreg_EnableResizableBar:int
parm:           NVreg_EnableDbgBreakpoint:int
parm:           NVreg_EnableNonblockingOpen:int
parm:           NVreg_RegistryDwords:charp
parm:           NVreg_RegistryDwordsPerDevice:charp
parm:           NVreg_RmMsg:charp
parm:           NVreg_GpuBlacklist:charp
parm:           NVreg_TemporaryFilePath:charp
parm:           NVreg_ExcludedGpus:charp
parm:           NVreg_DmaRemapPeerMmio:int
parm:           NVreg_RmNvlinkBandwidth:charp
parm:           NVreg_ImexChannelCount:int
parm:           rm_firmware_active:charp


cat /proc/driver/nvidia/version
"returns empty"

lsmod | grep nouveau 
"returns empty"

sudo modprobe nouveau                                                                                                                                                              
modprobe: ERROR: ../libkmod/libkmod-module.c:838 kmod_module_insert_module() could not find module by name='off'
modprobe: ERROR: could not insert 'off': Unknown symbol in module, or unknown parameter (see dmesg)

sudo dmesg | grep nouveau                                                                                                                                                          
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-6.5.0-26-generic root=UUID=f551b55d-4e21-4737-add1-a62de5ed044f ro quiet splash nouveau.modoset=1 vt.handoff=7
[    0.045633] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-6.5.0-26-generic root=UUID=f551b55d-4e21-4737-add1-a62de5ed044f ro quiet splash nouveau.modoset=1 vt.handoff=7

nvcc --version                                                                                                                                                                           at   02:28:13 PM
zsh: command not found: nvcc

nvidia-driver-version                                                                                                                                                                    
zsh: command not found: nvidia-driver-version



```