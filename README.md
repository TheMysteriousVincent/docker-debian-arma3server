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
Currently available arguments to `entrypoint.sh`:

Argument | Description
--- | ---
`install` | Installs SteamCMD and the ArmA 3 server.
`start` | Starts the ArmA 3 Server.
`updateServer` | Updates the ArmA 3 server.
`updateMods` | Updates all Steam Workshop mods given with environment variables.
`configure` | Updates the config with given environment variables.
`update` | Updates the server itself and connected mods.
`help` | Shows the help of `entrypoint.sh`.

## Variables
Currently available environment variables to `entrypoint.sh`:

### Parameter Variables
Variable | Description | Datatype
--- | --- | ---
`STEAM_PATH_EXEC` | The executable of SteamCMD | `string`
`A3S_PATH` | The path to the main server folder containing the server itself, tools and logs folder. | `string`
`A3S_SERVER_PATH` | The path to only the server itself. | `string`
`A3S_TOOLS_PATH` | The path to the tools folder for the ArmA 3 server folder. | `string`
`A3S_LOGS_PATH` | The logs folder | `string`
`STEAM_USER` | The username of the Steam account. | `string`
`STEAM_PASS` | The password of `STEAM_USER`. | `string`
`A3S_BIN` | Path to the ArmA 3 server executable. | `string`
`A3S_LOGFILE` | The logfile to log. | `string`
`A3S_RCON_PORT` | The RCon port of the ArmA 3 server. | `int`
`A3S_RCON_PASSWORD` | The RCon password of the ArmA 3 server. Default is a random generated password. | `string`
`A3S_PORT` | The port of the ArmA 3 server. | `int`
`A3S_BEPATH` | Battleye server folder path. | `string`
`A3S_PROFILES` | Path to the servers profile folder. | `string`
`A3S_BASIC_CONFIG` | The location of the `basic.cfg` configuration file. | `string`
`A3S_SERVER_CONFIG` | The location of the `server.cfg` configuration file. | `string`
`A3S_NAME` | The profile name of the server. | `string`
`A3S_CLIENT_MODS` | Path(s) relative to the server executable. Can be listed as: `A3S_CLIENT_MODS=mods/test;mods/tester;` | `string`
`A3S_CLIENT_MODS_WORKSHOP` | Workshop ids to download and use on the server. Can be listed as: `A3S_CLIENT_MODS_WORKSHOP=463939057;620019431;` | `string`
`A3S_CLIENT_MODS_COLLECTION` | Workshop collection ids to download all workshop items from. Can be multiple collections. Can be listed as: `A3S_CLIENT_MODS=970045117;1337018549` | `string`
`A3S_SERVER_MODS` | Same as `A3S_CLIENT_MODS` but only for the server. | `string`
`A3S_SERVER_MODS_WORKSHOP` | Same as `A3S_SERVER_MODS_WORKSHOP` but only for the server. | `string`
`A3S_SERVER_MODS_COLLECTION` | Same as `A3S_SERVER_MODS_COLLECTION` but only for the server. | `string`
`A3S_BANDWIDTH_ALG` | Alias to server parameter `-bandwidthAlg`. | `int` 
`A3S_IP` | Alias to server parameter `-ip` | `string`
`A3S_AUTOINIT` | Alias to server parameter `-autoInit`. Activated with: `A3S_AUTOINIT=true` | `bool`
`A3S_LOAD_MISSION_TO_MEMORY` | Alias to server parameter `-loadMissionToMemory`. Activated with: `A3S_LOAD_MISSION_TO_MEMORY=true` | `bool`
`A3S_PAR` | Alias to server parameter `-par`. | `string`
`A3S_WORLD` | Alias to server parameter `-world`. | `string`
`A3S_WORLD_CFG` | Alias to server parameter `-worldCfg`. | `string`
`A3S_MAX_MEM` | Alias to server parameter `-maxMem`. | `int`
`A3S_CPU_COUNT` | Alias to server parameter `-cpuCount`. | `int`
`A3S_EX_THREADS` | Alias to server parameter `-exThreads`. | `int`
`A3S_MALLOC` | Alias to server parameter `-malloc`. | `string`
`A3S_ENABLE_HT` | Alias to server parameter `-enableHT`. Activated with: `A3S_ENABLE_HT=true` | `bool`
`A3S_HUGEPAGES` | Alias to server parameter `-hugepages`. Activated with: `A3S_HUGEPAGES=true` | `bool`
`A3S_SHOW_SCRIPT_ERRORS` | Alias to server parameter `-showScriptErrors`. Activated with: `A3S_SHOW_SCRIPT_ERRORS=true` | `bool` 
`A3S_FILE_PATCHING` | Alias to server parameter `-filePatching`. Activated with: `A3S_FILE_PATCHING=true` | `bool`
`A3S_INIT` | Alias to server parameter `-init`. | `string`
`A3S_AUTOTEST` | Alias to server parameter `-autotest`. Activated with: `A3S_AUTOTEST=true` | `bool`
`A3S_BETA` | Alias to server parameter `-beta`. | `string`
`A3S_CHECK_SIGNATURES` | Alias to server parameter `-checkSignatures`. Activated with: `A3S_CHECK_SIGNATURES=true` | `bool`
`A3S_CRASHDIAG` | Alias to server parameter `-crashdiag`. Activated with: `A3S_CRASHDIAG=true` | `bool`
`A3S_NO_FILE_PATCHING` | Alias to server paramter `-noFilePatching`. Activated with: `A3S_NO_FILE_PATCHING=true` | `bool`
`A3S_DEBUG_CALL_EXTENSION` | Alias to server parameter `-debugCallExtension`. Activated with: `A3S_DEBUG_CALL_EXTENSION=true` | `bool`
`A3S_NO_LAND` | Alias to server parameter `-noLand`. Activated with: `A3S_NO_LAND=true` | `bool`
`A3S_BULDOZER` | Alias to server parameter `-buldozer`. Activated with: `A3S_BULDOZER=true` | `bool`
`A3S_CONNECT` | The ip address to connect to as (for example headless-) client. | `string`
`A3S_PASSWORD` | The password for a client to connect to a server. | `string`
`A3S_SERVER` | Activates the server part of the ArmA 3 server. Activated with: `A3S_SERVER=true`. (default `true`) | `bool` 
`A3S_CLIENT` | Activates the client part (for headless clients e.g.) of the ArmA 3 server. Activated with: `A3S_CLIENT=true`. (default `true`) | `bool`
`A3S_PID` | The pid file for the ArmA 3 server. | `string`
`A3S_RANKING` | ArmA 3 server ranking file path. | `string`
`A3S_NETLOG` | Alias to server parameter `-netlog`. Activated with: `A3S_NETLOG=true` | `bool`
`A3S_DISABLE_SERVER_THREAD` | Alias to server parameter `-disableServerThread`. Activated with `A3S_DISABLE_SERVER_THREAD=true` | `bool`

## `server.cfg` Variables
Nearly all available config entries can be added with environment variables.
This are the current ones:

Variable | Alias
--- | ---
`A3S_PASSWORD_ADMIN` | `passwordAdmin`
`A3S_PASSWORD` | `password`
`A3S_PASSWORD_SERVER_COMMAND` | `serverCommandPassword`
`A3S_HOSTNAME` | `hostname`
`A3S_MAX_PLAYERS` | `maxPlayers`
`A3S_MOTD` | `motd`
`A3S_ADMINS` | `admins`
`A3S_HEADLESS_CLIENTS` | `headlessClients`
`A3S_LOCAL_CLIENT` | `localClient`
`A3S_VOTE_THRESHOLD` | `voteThreshold`
`A3S_VOTE_MISSION_PLAYERS` | `voteMissionPlayers`
`A3S_KICK_DUPLICATE` | `kickDuplicate`
`A3S_LOOPBACK` | `loopback`
`A3S_UPNP` | `upnp`
`A3S_ALLOWED_FILE_PATCHING` | `allowedFilePatching`
`A3S_DISCONNECT_TIMEOUT` | `disconnectTimeout`
`A3S_MAX_DESYNC` | `maxDesync`
`A3S_MAX_PING` | `maxPing`
`A3S_MAX_PACKET_LOSS` | `maxPacketLoss`
`A3S_KICK_CLIENTS_ON_SLOW_NETWORK` | `kickClientsOnSlowNetwork`
`A3S_VERIFY_SIGNATURES` | `verifySignatures`
`A3S_DRAWING_IN_MAP` | `drawingInMap`
`A3S_DISABLE_VON` | `disableVoN`
`A3S_VON_CODEC_QUALITY` | `vonCodecQuality`
`A3S_VON_CODEC` | `vonCodec`
`A3S_DOUBLE_ID_DETECTED` | `doubleIdDetected`
`A3S_ON_USER_CONNECTED` | `onUserConnected`
`A3S_ON_USER_DISCONNECTED` | `onUserDisconnected`
`A3S_ON_HACKED_DATA` | `onHackedData`
`A3S_ON_DIFFERENT_DATA` | `onDifferentData`
`A3S_ON_UNSIGNED_DATA` | `onUnsignedData`
`A3S_REGULAR_CHECK` | `regularCheck`
`A3S_BATTLEYE` | `battleye`
`A3S_TIME_STAMP_FORMAT` | `timeStampFormat`
`A3S_FORCE_ROTOR_LIB_SIMULATION` | `forceRotorLibSimulation`
`A3S_PERSISTENT` | `persistent`
`A3S_REQUIRED_BUILD` | `requiredBuild`
`A3S_FORCED_DIFFICULTY` | `forcedDifficulty`
`A3S_MISSION_WHITELIST` | `missionWhitelist`
`A3S_MISSIONS` | `class Missions`

## `basic.cfg` Variables
This are the current ones of the `basic.cfg` file:

Variable | Alias
--- | ---
`A3S_MAX_MSG_SEND` | `maxMsgSend`
`A3S_MAX_SIZE_GUARANTEED` | `maxSizeGuaranteed`
`A3S_MAX_SIZE_NONGUARANTEED` | `maxSizeNonguaranteed`
`A3S_MAX_BANDWIDTH` | `maxBandwidth`
`A3S_MIN_BANDWIDTH` | `minBandwidth`
`A3S_MIN_ERROR_TO_SEND` | `minErrorToSend`
`A3S_MIN_ERROR_TO_SEND_NEAR` | `minErrorToSendNear`
`A3S_MAX_CUSTOM_FILE_SIZE` | `maxCustomFileSize`
`A3S_MAX_PACKET_SIZE` | `maxPacketSize`
