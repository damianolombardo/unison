# Unison
A docker volume container using [Unison](http://www.cis.upenn.edu/~bcpierce/unison/) for fast two-way folder sync. 

This image is trying to be as minimal as possible and it only weights `14.41MB`.

This is **Heavily** on [https://github.com/onnimonni/docker-unison](https://github.com/onnimonni/docker-unison).

The docker image is available on Docker Hub:
[registry.hub.docker.com/u/damianolombardo/unison/](https://registry.hub.docker.com/u/damianolombardo/unison/)

## Usage

The intended usage is for this to act as a fast automatic file sync of a USB device on [unraid](https://unraid.net/) using the [Unassigned Devices](https://forums.unraid.net/topic/44104-unassigned-devices-managing-disk-drives-and-remote-shares-outside-of-the-unraid-array/) plugin.

A sample script for automating this is available in this repository [Here](https://github.com/damianolombardo/unison/blob/master/General_UDisk.sh)

The following are the original usage notes from [Omnimonnis](https://github.com/onnimonni) repository. 

### Docker

First, you can launch a volume container exposing a volume with Unison.

```bash
$ CID=$(docker run -d -p 5000:5000 -e UNISON_DIR=/data -v /data onnimonni/unison)
```

You can then sync a local folder to `$UNISON_DIR` (default value: `/data`) in the container with:

```bash
$ unison . socket://<docker>:5000/ -auto -batch
```

Next, you can launch a container connected with the volume under `/data`.

```bash
$ docker run -it --volumes-from $CID ubuntu /bin/sh
```

### Configuration
This container has few envs that you can alter.

`UNISON_DIR` - This is the directory which receives data from unison inside the container.
This is also the directory which you can use in other containers with `volumes_from` directive.

`UNISON_GID` - Group ID for the user running unison inside container.

`UNISON_UID` - User ID for the user running unison inside container.

`UNISON_USER` - User name for the sync user ( UID matters more )

`UNISON_GROUP` - Group name for the sync user ( GID matters more )

### Docker Compose

If you are using Docker Compose to manage a dev environment, use the `volumes_from` directive.

The following `docker-compose.yml` would mount the `/var/www/project` folder from the `unison` container inside your `mywebserver` container.

```yaml
mywebserver:
  build: .
  volumes_from:
    - unison
unison:
  image: onnimonni/unison
  environment:
    - UNISON_DIR=/var/www/project
    - UNISON_UID=10000
    - UNISON_GID=10000
  ports:
    - "5000:5000"
  volumes:
    - /var/www/project
```

You can then sync a local folder, using the unison client, to `/var/www/project` in the container with:

```bash
$ unison . socket://<docker>:5000/ -ignore 'Path .git' -auto -batch
```

You can use `-repeat watch` to sync everytime when files change:

```bash
$ unison . socket://<docker>:5000/ -repeat watch -ignore 'Path .git' -auto -batch
```

**NOTE: In order to use `-repeat` option you need to install unison-fsmonitor.**

## Installing Unison Locally
Unison requires the version of the client (running on the host) and server (running in the container) to match.

Docker images are versioned with the version of unison which is installed in the container.
You can use `onnimonni/unison:2.51.2` image to use unison with 2.51.2 version.

* 2.40.102 (available via `apt-get install unison` on Ubuntu 14.04, 14.10, 15.04)
* 2.48.4 (available via `apt install unison` on Ubuntu 18.04)
* 2.51.2 (available via `brew install unison` on Mac OS X) [default]

Additional versions can be added easily on request. Open an Issue if you need another version.

## Installing unison-fsmonitor on OSX (unox)
```
# This is dependency for unox
$ pip install MacFSEvents

# unox is unison-fsmonitor script for Mac
$ curl -o /usr/local/bin/unison-fsmonitor -L https://raw.githubusercontent.com/hnsl/unox/master/unox.py
$ chmod +x /usr/local/bin/unison-fsmonitor
```
## Credits
Thanks for [leighmcculloch](https://github.com/leighmcculloch/docker-unison) for showing me how to use unison with docker.

## License
This docker image is licensed under GPLv3 because Unison is licensed under GPLv3 and is included in the image. See LICENSE.
