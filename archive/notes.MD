
[mikenye/youtube-dl](https://hub.docker.com/r/mikenye/youtube-dl)

```
docker run \
    --rm -i \
    -e PGID=$(id -g) \
    -e PUID=$(id -u) \
    -v /path/to/downloaded/videos:/workdir:rw \
    -v /path/to/youtube-dl.conf:/etc/youtube-dl.conf:ro \
    mikenye/youtube-dl
    
```

