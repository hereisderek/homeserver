# Home script
-----
Utilize Docker to create automation tasks for home media server. this is heavily inspired by [animosity22/homescripts](https://github.com/animosity22/homescripts/) and [DockSTARTer](https://dockstarter.com/) (just everything in a docker), special thanks!


## Features

- remote media library with local mount/cache
  - [rclone](https://rclone.org/)
  - [mergerfs](https://github.com/trapexit/mergerfs)
- torrent clients 
  - [qbittorrent](https://hotio.dev/containers/qbittorrent/)
  - nzbget
  - transmission
- *arr (*choose whatever you need*)
  - sonarr: series
  - radarr: movies
  - bazarr: subtitles
  - lidarr: music
  - readarr: books
  - prowlarr: indexter
- other plugin/helpers for *aar
  - Jackett: indexer
  - [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr): Bypass Cloudflare protection in Jackett. This runs a firefox in headless mode, and turns out to be too much for my cpu to handle *Optional*
- media server
  - Jellyfin
  - *Plex*
  - *Emby*
- other downloaders
  - Calibre
  - YoutubeDL
- Utilities
  - [samba](https://hub.docker.com/r/dperson/samba)
  - portainer: for docker management
  - ddclient
  - file management, such as File Browser, h5ai, nextcloud etc.
  - Duplicati
  - 


### To be added
- Proxy/VPN
  - Wireguard
- Cabby


## Environment
I personally am running all this setup on my mining rig with a super low end celeron process with 8GB of ram, running ubuntu bionic 64bit. 

Configurations are mostly stored in the `.env`, they are all prefixed by `BASE_`, all the persistent data are devided into three category
1.  config: neccess configuration to get things going from a clean plate. Mostly what this repo contains and required user settings such as `rclong.conf`
2.  data: Mostly docker persistent data, such as docker settings, download progress etc.
3.  cache: (bulky) temporary files, such as jellyfin metadatam video transcode, and local directory for mergerfs

## Installation

1. Install docker 
2. Install your graphic driver and their docker componments for hardware en/de-coding in jellyfin. check [Jellyfin support link](https://jellyfin.org/docs/general/administration/hardware-acceleration.html)
   1. Nvidia [Driver](https://phoenixnap.com/kb/install-nvidia-drivers-ubuntu) and [Docker](https://github.com/NVIDIA/nvidia-docker) support (this is what I'm using, anything else is not supported) [^1].
      
   2. AMD (No idea)
   3. Intel (Intel Quick Sync Video) (No idea)
3. I don't know yet. 


     
[^1]: I'm running on a disribution with pre-installed graphic driver (MinerOS) instead of having to set it up from scratch, mostly because that I couldn't find a good overclocking (downclocking) solution. But as far as I remember, there are some gotchas, for examples

* Multi-GPU support. 
  * This is more of an OS issue, which you can find more looking at the `dmesg` logs. The solution, as far as i remember, you need to firstly enable above 4g decoding in BIOS, then add something like pcie=preallocate (i can't find it anymore so good luck and if anyone knows, PR is welcomed)
* Nvidia docker cgroup issue. [see this](https://github.com/NVIDIA/nvidia-docker/issues/1447#issuecomment-757034464)



## Useful links

- [DockSTARTer](https://dockstarter.com/) beginner friendly easy setup
  - https://dockstarter.com/advanced/macvlan/
- [animosity22/homescripts](https://github.com/animosity22/homescripts/)
- [wiki.servarr](https://wiki.servarr.com/docker-guide) General guid on *aar, very useful
- [Setup Guide: Multi GPU Ubuntu Server AMD & nvidia](https://foldingforum.org/viewtopic.php?f=106&t=33090) (never tried myself, not looks promissing so have a read)
- [Ubuntu with multiple GPU for mining](https://gist.github.com/ernestp/83bfd1667b1f5c3905b5c15dc9031811) (I didn't actually see this until now, might give stock ubuntu another go. )