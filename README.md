# LiteIDE Docker image

A [LiteIDE](https://github.com/visualfc/liteide) redistribution as
[Docker](https://www.docker.com) container image providing a
portable, reproducible [Go](https://golang.org/) development
environment.


## Usage

In order to run a container using this image you need to provide several
options to Docker or use the `liteide.sh` provided with the git repository.  

The following options need to be provided when using Docker directly:

- provide your host UID/GID (`-u`) in order to make LiteIDE write as your user (not required when using [podman](https://podman.io/))
- pass through your host's `DISPLAY` environment variable
- mount your host's `/etc/machine-id`
- mount your host's `$GOPATH` into the container's `/work` directory
- optionally you can also mount your project's `liteide.ini` to `/tmp/liteide/.config/liteide/liteide.ini` within the container (see `liteite-example.ini`)

Example:
```
docker run --name liteide --rm \
	-u $(id -u):$(id -g) \
	-e DISPLAY="${DISPLAY}" \
	--mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix \
	--mount type=bind,src=/etc/machine-id,dst=/etc/machine-id \
	--mount "type=bind,src=${GOPATH},dst=/work" \
	mgoltzsche/liteide:latest \
	/work
```


### LiteIDE usage

This section explains how to manage LiteIDE's build configuration.  

In order to build the whole project independent of your currently
opened file and with the root package's `BUILDFLAGS` you may want
to lock the build path as follows:

- Using the root package's context menu select `Build Path Configuration`
- Make sure `Inherit System GOPATH` is checked!
- Configure the `BUILDFLAGS` variable if required
- `Lock Build Path` to the top-level directory

If you want keep your configuration across IDE restarts or ship it with
your project you need to enter the LiteIDE Docker container and copy 
`/tmp/liteide/.config/liteide/liteide.ini` to `/work/liteide.ini`.


## License

- This project (Docker build + script): Apache License 2.0
- [LiteIDE](https://github.com/visualfc/liteide): GNU Lesser General Public License v2.1
