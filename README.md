# docker-debian-arma3server
A simple Docker Debian ArmA 3 Server image

## Prerequisites
### Building Docker image from source
Can you trust me? If not, you can build this Docker image by yourself.

First, you have to download `git` if it isn't installed already.
```sh
apt-get install git
```

The next part is to download this GitHub repository.
```sh
git clone https://github.com/TheMysteriousVincent/docker-debian-arma3server.git
```

Also you have to move in the directory of the downloaded folder.
```sh
cd docker-debian-arma3server/
```

And finally, you can build this small Docker image yourself.
```sh
docker build -t themysteriousvincent/docker-debian-arma3server .
```

### Pull Docker Image
For those who trust me can pull the Docker image themselves.
```
docker pull themysteriousvincent/docker-debian-arma3server:latest
```

## Installation
Now that you have downloaded all necessary prerequisites, you can continue the installation of the ArmA 3 server.

To commit a very minimal installation + start, you have to add a little amount of variables.
```sh
docker run [-d] \
    -it \
    -e STEAM_USER=<steam username> \
    -e STEAM_PASS=<steam password> \
    -p 2301-2306:2301-2306 -p 2301-2306:2301-2306/udp \
    themysteriousvincent/docker-debian-arma3server:latest \
    install \
    configure \
    start
```
Noticed the three parameter `install`, `configure` and `start`? There are parameter to the Docker entrypoint available to control the actions executed in the container.
More down below.

But there are several other ways to create a "custom" image.

For example you can create an image from Steam Workshop content by passing those variables: `A3S_CLIENT_MODS_WORKSHOP`, `A3S_CLIENT_MODS_COLLECTION`, `A3S_SERVER_MODS_WORKSHOP` and `A3S_SERVER_MODS_COLLECTION`.

Thus, if you have an existing (comitted Docker container) available, you can update this image really fast, by executing the following command(s):
```sh
docker run -it --name temp_container \
    -e STEAM_USER=<steam username> \
    -e STEAM_PASS=<steam password> \
    -e A3S_CLIENT_MODS_COLLECTION=<collection id> \
    <your image> \
    updateMods
docker commit temp_container <your image>:<new version>
docker rm temp_container
```

So the container gets updated and thankfully the layered filesystem (AuFS) does its job and just adds different data to its save.

If something is missing, I please you to create an issue for that.

## Arguments

## Variables
