# LiteIDE Docker image

A [LiteIDE](https://github.com/visualfc/liteide) redistribution as
[Docker](https://www.docker.com) container image providing a fast,
portable, reproducible [Go](https://golang.org/) development
environment.


## Usage

This image can be run using the launcher script `liteide.sh` or using
Docker directly.

### Install the launcher script

Install the launcher script on your host:
```
curl -fsSL https://raw.githubusercontent.com/mgoltzsche/liteide-docker/master/liteide.sh -o /tmp/run-liteide &&
chmod +x /tmp/run-liteide &&
sudo mv /tmp/run-liteide /usr/local/bin/run-liteide
```

### Launcher script usage

The launcher can be used as follows:
```
run-liteide PROJECTDIR [PACKAGE]
```

| Argument     | Description |
| ------------ | ----------- |
| `PROJECTDIR` | The project directory that should be opened with LiteIDE |
| `PACKAGE`    | Optional: the package your `PROJECTDIR` should be mounted to |

| Environment variable | Description |
| -------------------- | ----------- |
| `LITEIDE_INI`     | Path to a `liteide.ini` file that should be used. Default: `$PROJECTDIR/liteide.ini` |
| `LITEIDE_VERSION` | LiteIDE version |
| `LITEIDE_IMAGE`   | full LiteIDE Docker image name (overwrites `LITEIDE_VERSION`) |
| `LITEIDE_CACHE`   | if set to `on` the directory `.liteide-cache` is mounted to the container's `GOPATH` |


### Using Docker directly (optional)

In order to run a container using this image directly you need to
provide several options:

- provide your host UID/GID as `CHOWN` environment variable in order to run LiteIDE as your user (not required when using [podman](https://podman.io/))
- pass through your host's `DISPLAY` environment variable
- mount your host's `/etc/machine-id`
- mount your project directory into the container's `/go` directory (`GOPATH` points to `/go`)
- optionally you can also mount your project's `liteide.ini` to `/tmp/liteide/.config/liteide/liteide.ini` within the container (see `liteite-example.ini`)

Example:
```
docker run --name liteide --rm \
	-e CHUSR=$(id -u):$(id -g) \
	-e DISPLAY="${DISPLAY}" \
	--mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix \
	--mount type=bind,src=/etc/machine-id,dst=/etc/machine-id \
	--mount "type=bind,src=${PROJECTDIR:-.},dst=/go/src/github.com/example/project" \
	mgoltzsche/liteide:latest \
	/go/src/github.com/example/project
```


### LiteIDE usage

This section explains how to manage LiteIDE's build configuration.  

In order to build the whole project independent of your currently
opened file and with the root package's `BUILDFLAGS` you may want
to lock the build path as follows:

- Using the root package's context menu select `Build Path Configuration`
- Configure the `BUILDFLAGS` variable if required
- `Lock Build Path` to the top-level directory

If you want keep your configuration across IDE restarts or ship it with
your project you need to enter the LiteIDE Docker container and copy 
`/tmp/liteide/.config/liteide/liteide.ini` to your project dir at
`/go/liteide.ini`.


## License

- This project (Docker build + script): Apache License 2.0
- [LiteIDE](https://github.com/visualfc/liteide): GNU Lesser General Public License v2.1
