# Home script
-----
Utilize Docker to create automation tasks for home media server. this is heavily inspired by [animosity22/homescripts](https://github.com/animosity22/homescripts/) and [DockSTARTer](https://dockstarter.com/) (just everything in a docker), special thanks!


## Features

- remote media library with local mount/cache
  - [rclone](https://rclone.org/)
  - [mergerfs](https://github.com/trapexit/mergerfs)
- downloader/torrent clients 
  - [qbittorrent](https://hotio.dev/containers/qbittorrent/)
  - nzbget
  - transmission
  - [metube](https://github.com/alexta69/metube)
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
  - Plex
  - *Emby*
  - [deemix](https://gitlab.com/Bockiii/deemix-docker) music player
- other downloaders
  - Calibre
  - YoutubeDL
  - [alexta69/metube]
- File management
  - [h5ai](https://github.com/awesometic/docker-h5ai)
  - [nextcloud](https://github.com/nextcloud/docker)
- Network/Vpn
  - squid (salrashid123/squidproxy)
  - [wireguard](https://docs.linuxserver.io/images/docker-wireguard)
  - [*wireguard-ui*](https://github.com/ngoduykhanh/wireguard-ui)

- Utilities
  - [samba](https://hub.docker.com/r/dperson/samba)
  - portainer: for docker management
  - ddclient
  - file management, such as File Browser, h5ai, nextcloud etc.
  - Duplicati
- DDNS
  - [ddns-updater](https://github.com/qdm12/ddns-updater)
  - [traefik](https://hub.docker.com/_/traefik)


### To be added
- Cabby
- 

### Players:
To run without nvidia driver (with profile):

`./docker-compose.sh -p profile -f docker-compose.player.yml  config`

Optional: local caching mount"
```
${BASE_CACHE_DIR}/radarr/MediaCover:radarr/MediaCover
${BASE_CACHE_DIR}/sonarr/MediaCover:sonarr/MediaCover
${BASE_CACHE_DIR}/lidarr/MediaCover:lidarr/MediaCover
${BASE_CACHE_DIR}/plex/Library:plex/Library
${BASE_CACHE_DIR}/jellyfin/metadata:jellyfin/metadata
```

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


## Default ports
  * http://prowlarr:9696
  * http://readarr:8686
  * http://bazarr:6767
  * http://lidarr:8686
  * http://sonarr:8989
  * http://radarr:7878

## downloader
**Important:** Remember to double check the download/incomplete location for the downloaders or you could flood your hard drive/docker volumes real quick

`mkdir -p {qbittorrent,transmission,nzbget,aria2}/{watch,torrents,torrents_done,{sonarr,radarr,lidarr,readarr,others}/{complete,incomplete}}`

```
.
├── aria2
│   ├── lidarr
│   │   ├── complete
│   │   └── incomplete
│   ├── others
│   │   ├── complete
│   │   └── incomplete
│   ├── radarr
│   │   ├── complete
│   │   └── incomplete
│   ├── readarr
│   │   ├── complete
│   │   └── incomplete
│   ├── sonarr
│   │   ├── complete
│   │   └── incomplete
│   ├── torrents
│   ├── torrents_done
│   └── watch
├── nzbget
│   ├── lidarr
│   │   ├── complete
│   │   └── incomplete
│   ├── others
│   │   ├── complete
│   │   └── incomplete
│   ├── radarr
│   │   ├── complete
│   │   └── incomplete
│   ├── readarr
│   │   ├── complete
│   │   └── incomplete
│   ├── sonarr
│   │   ├── complete
│   │   └── incomplete
│   ├── torrents
│   ├── torrents_done
│   └── watch
├── qbittorrent
│   ├── lidarr
│   │   ├── complete
│   │   └── incomplete
│   ├── others
│   │   ├── complete
│   │   └── incomplete
│   ├── radarr
│   │   ├── complete
│   │   └── incomplete
│   ├── readarr
│   │   ├── complete
│   │   └── incomplete
│   ├── sonarr
│   │   ├── complete
│   │   └── incomplete
│   ├── torrents
│   ├── torrents_done
│   └── watch
└── transmission
    ├── lidarr
    │   ├── complete
    │   └── incomplete
    ├── others
    │   ├── complete
    │   └── incomplete
    ├── radarr
    │   ├── complete
    │   └── incomplete
    ├── readarr
    │   ├── complete
    │   └── incomplete
    ├── sonarr
    │   ├── complete
    │   └── incomplete
    ├── torrents
    ├── torrents_done
    └── watch
```

## wireguard
To enable ipv4 and ipv6
```
sudo cat > /etc/sysctl.d/99-sysctl.conf << EOF
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding=1
EOF
```

## Other services 
 * [aria2-ariang-docker](https://github.com/wahyd4/aria2-ariang-docker) Aria2 + AriaNg + Filebrowser
 * [SuperNG6/docker-aria2](https://github.com/SuperNG6/docker-aria2) Docker Aria2的最佳实践

## Useful links

- [DockSTARTer](https://dockstarter.com/) beginner friendly easy setup
  - https://dockstarter.com/advanced/macvlan/
- [animosity22/homescripts](https://github.com/animosity22/homescripts/)
- [wiki.servarr](https://wiki.servarr.com/docker-guide) General guid on *aar, very useful
- [Setup Guide: Multi GPU Ubuntu Server AMD & nvidia](https://foldingforum.org/viewtopic.php?f=106&t=33090) (never tried myself, not looks promissing so have a read)
- [Ubuntu with multiple GPU for mining](https://gist.github.com/ernestp/83bfd1667b1f5c3905b5c15dc9031811) (I didn't actually see this until now, might give stock ubuntu another go. )



## FAQ
  1. unable to scrub movie/show information?

  It's possible that the dns has been polluted, go on to [this site](https://dnschecker.org/#AAAA/api.themoviedb.org) go get the right IPs for the calling api and paste it in your local hosts file (usually /etc/hosts), and mount into the container. 
  For example, saving the following into your hosts file (might require root permission)

  ```
  13.227.219.32									api.themoviedb.org
  13.227.219.43									api.themoviedb.org
  13.227.219.97									api.themoviedb.org
  13.227.219.100									api.themoviedb.org
  2600:9000:21c7:2000:c:174a:c400:93a1			api.themoviedb.org
  2600:9000:21c7:4e00:c:174a:c400:93a1			api.themoviedb.org
  2600:9000:21c7:c00:c:174a:c400:93a1				api.themoviedb.org
  2600:9000:21c7:3600:c:174a:c400:93a1			api.themoviedb.org
  2600:9000:21c7:a000:c:174a:c400:93a1			api.themoviedb.org
  2600:9000:21c7:fe00:c:174a:c400:93a1			api.themoviedb.org
  2600:9000:21c7:3e00:c:174a:c400:93a1			api.themoviedb.org
  2600:9000:21c7:0:c:174a:c400:93a1				api.themoviedb.org
  ```

  and then in the yml file:

  ```
    overseerr:
    image: cr.hotio.dev/hotio/overseerr
    # unrelavent lines are omitted..
    volumes:
      - /etc/hosts:/etc/hosts:ro # <- add this
  ```
