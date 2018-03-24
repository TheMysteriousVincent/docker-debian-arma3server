#!/bin/bash

main () {
	init_vars

	for arg in $@; do
		case $arg in
		"install")
			install
			;;
		"start")
			start
			exit
			;;
		"updateServer")
			stop
			updateServer
			;;
		"updateMods")
			stop
			updateMods
			;;
		"update")
			update
			;;
		"help"|*)
			help
			exit
			;;
		esac
	done
}

help () {
	echo -e "Usage: ./entrypoint.sh <arg>"
	echo -e "\tinstall\t\tInstalls the the whole server."
	echo -e "\tstart\t\tStarts the server."
	echo -e "\tupdateServer\t\tUpdates the server."
	echo -e "\tupdateMods\t\tUpdates all mods given by environment variables."
	echo -e "\tconfigure\t\tCreates all necessary config files by environment variables."
	echo -e "\tupdate\t\tUpdates the server and all needed mods from the Steam Workshop."
	echo -e "\tstop\t\tStops the server. (currently unused)"
	echo -e "\trestart\t\tRestarts the server. (currently unused)"
	echo -e "\thelp\t\tDisplays this helpful help information."
}

install () {
	if [ ! -d ~/.steam ]; then
		mkdir -p ~/.steam
		wget -P ~/.steam https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
		tar -xzf ~/.steam/steamcmd_linux.tar.gz -C ~/.steam/
	fi

	update
}

init_vars () {
	: ${STEAM_PATH_EXEC:=/home/arma3server/.steam/steamcmd.sh}
	: ${A3S_PATH:=/home/arma3server}
	: ${A3S_SERVER_PATH:=$A3S_PATH/server}
	: ${A3S_TOOLS_PATH:=$A3S_PATH/tools}
	: ${A3S_LOGS_PATH:=$A3S_PATH/logs}
	: ${STEAM_USER:=anonymous}
	: ${STEAM_PASS:=anonymous}
	: ${STEAM_APP_ID:=233780}
	: ${STEAM_API_KEY:=}

	: ${A3S_BIN:=$A3S_SERVER_PATH/arma3server}
	: ${A3S_LOGFILE:=/dev/stdout}
	: ${A3S_RCON_PORT:=2306}
	: ${A3S_RCON_PASSWORD:=$(cat /dev/urandom | tr -d -c a-z0-9- | dd bs=1 count=$((RANDOM%(24-16+1)+16)) 2> /dev/null)}
	: ${A3S_OPTS:=}

	: ${A3S_PORT:=2302}
	: ${A3S_BEPATH:=$A3S_SERVER_PATH/battleye}
	: ${A3S_PROFILES:=$A3S_SERVER_PATH/profiles}
	: ${A3S_BASIC_CONFIG:=$A3S_SERVER_PATH/basic.cfg}
	: ${A3S_SERVER_CONFIG:=$A3S_SERVER_PATH/server.cfg}
	: ${A3S_NAME:=default}
	: ${A3S_CLIENT_MODS:=NULL}
	: ${A3S_CLIENT_MODS_WORKSHOP:=NULL}
	: ${A3S_CLIENT_MODS_COLLECTION:=NULL}
	: ${A3S_SERVER_MODS:=NULL}
	: ${A3S_SERVER_MODS_WORKSHOP:=NULL}
	: ${A3S_SERVER_MODS_COLLECTION:=NULL}
	: ${A3S_BANDWIDTH_ALG:=NULL}
	: ${A3S_IP:=NULL}
	: ${A3S_AUTOINIT:=NULL}
	: ${A3S_LOAD_MISSION_TO_MEMORY:=NULL}
	: ${A3S_PAR:=NULL}
	: ${A3S_WORLD:=NULL}
	: ${A3S_WORLD_CFG:=NULL}
	: ${A3S_MAX_MEM:=NULL}
	: ${A3S_CPU_COUNT:=NULL}
	: ${A3S_EX_THREADS:=NULL}
	: ${A3S_MALLOC:=NULL}
	: ${A3S_ENABLE_HT:=NULL}
	: ${A3S_HUGEPAGES:=NULL}
	: ${A3S_SHOW_SCRIPT_ERRORS:=NULL}
	: ${A3S_FILE_PATCHING:=NULL}
	: ${A3S_INIT:=NULL}
	: ${A3S_AUTOTEST:=NULL}
	: ${A3S_BETA:=NULL}
	: ${A3S_CHECK_SIGNATURES:=NULL}
	: ${A3S_CRASHDIAG:=NULL}
	: ${A3S_NO_FILE_PATCHING:=NULL}
	: ${A3S_DEBUG_CALL_EXTENSION:=NULL}
	: ${A3S_NO_LAND:=NULL}
	: ${A3S_BULDOZER:=NULL}
	: ${A3S_CONNECT:=NULL}
	: ${A3S_PASSWORD:=NULL}
	: ${A3S_SERVER:=NULL}
	: ${A3S_CLIENT:=NULL}
	: ${A3S_PID:=NULL}
	: ${A3S_RANKING:=NULL}
	: ${A3S_NETLOG:=NULL}
	: ${A3S_DISABLE_SERVER_THREAD:=NULL}

	: ${A3S_HOSTNAME:=arma3server@docker_container}

	return
}

create_opts () {
	if [ "${A3S_PORT}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -port=${A3S_PORT}"
	fi

	if [ "${A3S_BEPATH}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -bepath=${A3S_BEPATH}"
	fi

	if [ "${A3S_PROFILES}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -profiles=${A3S_PROFILES}"
	fi

	if [ "${A3S_BASIC_CONFIG}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -cfg=${A3S_BASIC_CONFIG}"
	fi

	if [ "${A3S_SERVER_CONFIG}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -config=${A3S_SERVER_CONFIG}"
	fi

	if [ "${A3S_NAME}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -name=${A3S_NAME}"
	fi

	if [ "${A3S_BANDWIDTH_ALG}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -bandwidthAlg=${A3S_BANDWIDTH_ALG}"
	fi

	if [ "${A3S_IP}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -ip=${A3S_IP}"
	fi

	if [ "${A3S_AUTOINIT}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -autoInit"
	fi

	if [ "${A3S_LOAD_MISSION_TO_MEMORY}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -loadMissionToMemory"
	fi

	if [ "${A3S_PAR}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -par=${A3S_PAR}"
	fi

	if [ "${A3S_WORLD}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -world=${A3S_WORLD}"
	fi

	if [ "${A3S_WORLD_CFG}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -worldCfg=${A3S_WORLD_CFG}"
	fi

	if [ "${A3S_MAX_MEM}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -maxMem=${A3S_MAX_MEM}"
	fi

	if [ "${A3S_CPU_COUNT}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -cpuCount=${A3S_CPU_COUNT}"
	fi

	if [ "${A3S_EX_THREADS}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -exThreads=${A3S_EX_THREADS}"
	fi

	if [ "${A3S_MALLOC}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -malloc=${A3S_MALLOC}"
	fi

	if [ "${A3S_ENABLE_HT}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -enableHT"
	fi

	if [ "${A3S_HUGEPAGES}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -hugepages"
	fi

	if [ "${A3S_SHOW_SCRIPT_ERRORS}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -showScriptErrors"
	fi

	if [ "${A3S_FILE_PATCHING}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -filePatching"
	fi

	if [ "${A3S_INIT}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -init=${A3S_INIT}"
	fi

	if [ "${A3S_AUTOTEST}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -autotest"
	fi

	if [ "${A3S_BETA}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -beta=${A3S_BETA}"
	fi

	if [ "${A3S_CHECK_SIGNATURES}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -checkSignatures"
	fi

	if [ "${A3S_CRASHDIAG}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -crashDiag"
	fi

	if [ "${A3S_NO_FILE_PATCHING}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -noFilePatching"
	fi

	if [ "${A3S_DEBUG_CALL_EXTENSION}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -debugCallExtension"
	fi

	if [ "${A3S_NO_LAND}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -noLand"
	fi

	if [ "${A3S_BULDOZER}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -buldozer"
	fi

	if [ "${A3S_CONNECT}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -connect=${A3S_CONNECT}"
	fi

	if [ "${A3S_PASSWORD}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -password=${A3S_PASSWORD}"
	fi

	if [ "${A3S_SERVER}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -server"
	fi

	if [ "${A3S_CLIENT}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -client"
	fi

	if [ "${A3S_PID}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -pid=${A3S_PID}"
	fi

	if [ "${A3S_RANKING}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -ranking=${A3S_RANKING}"
	fi

	if [ "${A3S_NETLOG}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -netlog"
	fi

	if [ "${A3S_DISABLE_SERVER_THREAD}" == "true" ]; then
		A3S_OPTS="${A3S_OPTS} -disableServerThread"
	fi

	if [ "${A3S_CLIENT_MODS}" != NULL ]; then
		tmpMods="$A3S_CLIENT_MODS"
	fi

	if [ "${A3S_CLIENT_MODS_WORKSHOP}" != NULL ]; then
		for mod in $(${A3S_CLIENT_MODS_WORKSHOP} | sed -e 's/;//'); do
			tmpMods="steamapps/workshop/content/107410/$mod;$tmpMods"
		done
	fi

	if [ "${A3S_CLIENT_MODS_COLLECTION}" != NULL ]; then
		for collection in $(${A3S_CLIENT_MODS_COLLECTION} | sed -e 's/;//'); do
			for mod in $(getCollectionMods $collection); do
				tmpMods="steamapps/workshop/content/107410/$mod;$tmpMods"
			done
		done
	fi

	if [ -v tmpMods ]; then
		A3S_OPTS="${A3S_OPTS} -mod=$tmpMods"
	fi
	unset tmpMods

	if [ "${A3S_SERVER_MODS}" != NULL ]; then
		tmpMods="$A3S_CLIENT_MODS"
	fi

	if [ "${A3S_SERVER_MODS_WORKSHOP}" != NULL ]; then
		for mod in $(${A3S_SERVER_MODS_WORKSHOP} | sed -e 's/;//'); do
			tmpMods="steamapps/workshop/content/107410/$mod;$tmpMods"
		done
	fi

	if [ "${A3S_SERVER_MODS_COLLECTION}" != NULL ]; then
		for collection in $(${A3S_SERVER_MODS_COLLECTION} | sed -e 's/;//'); do
			for mod in $(getCollectionMods $collection); do
				tmpMods="steamapps/workshop/content/107410/$mod;$tmpMods"
			done
		done
	fi

	if [ -v tmpMods ]; then
		A3S_OPTS="${A3S_OPTS} -serverMod=$tmpMods"
	fi
	unset tmpMods

	return
}

configure () {
	create_config_basic $A3S_BASIC_CONFIG
	create_config_server $A3S_SERVER_CONFIG

	if [ ! -d $A3S_SERVER_PATH/battleye/launch ]; then
		mkdir -m 770 -p $A3S_SERVER_PATH/battleye/lauch
	fi

	if [ ! -f $A3S_SERVER_PATH/battleye/launch/beserver.cfg ]; then
		create_config_battleye $A3S_SERVER_PATH/battleye/launch/beserver.cfg
	fi

	if [ ! -f $A3S_SERVER_PATH/battleye/beserver.cfg ]; then
		create_config_battleye $A3S_SERVER_PATH/battleye/beserver.cfg
	fi
}

writeConfigEntry () {
        if [ ! -f $1 ]; then
		echo -e "// Configuration file generated by a Docker container:\n" >> ${1}
        fi
	if [ "$(grep "^$2\s*=.*" $1)" != "" ]; then
		sed -i "s/^$2\s*=.*/${2/\\\[\\\]/[]}=$3;/" $1
	else
		echo -e "${2/\\\[\\\]/[]} = $3;" >> $1
	fi
}

create_config_server () {
	if [ ! -d $(dirname ${1}) ]; then
		mkdir -m 770 -p $(dirname ${1})
	fi

	if [ -v A3S_PASSWORD_ADMIN ]; then
		writeConfigEntry $1 "passwordAdmin" "\"$A3S_PASSWORD_ADMIN\""
	fi

	if [ -v A3S_PASSWORD ]; then
		writeConfigEntry $1 "password" "\"$A3S_PASSWORD\""
	fi

	if [ -v A3S_PASSWORD_SERVER_COMMAND ]; then
		writeConfigEntry $1 "serverCommandPassword" "\"$A3S_PASSWORD_SERVER_COMMAND\""
	fi

	if [ -v A3S_HOSTNAME ]; then
		writeConfigEntry $1 "hostname" "\"$A3S_HOSTNAME\""
	fi

	if [ -v A3S_MAX_PLAYERS ]; then
		writeConfigEntry $1 "maxPlayers" "$A3S_MAX_PLAYERS"
	fi

	if [ -v A3S_MOTD ]; then
		writeConfigEntry $1 "motd\[\]" "$A3S_MOTD"
	fi

	if [ -v A3S_ADMINS ]; then
		writeConfigEntry $1 "admins\[\]" "$A3S_ADMINS"
	fi

	if [ -v A3S_HEADLESS_CLIENTS ]; then
		writeConfigEntry $1 "headlessClients\[\]" "$A3S_HEADLESS_CLIENTS"
	fi

	if [ -v A3S_LOCAL_CLIENT ]; then
		writeConfigEntry $1 "localClient\[\]" "$A3S_LOCAL_CLIENT"
	fi

	if [ -v A3S_VOTE_THRESHOLD ]; then
		writeConfigEntry $1 "voteThreshold" "$A3S_VOTE_THRESHOLD"
	fi

	if [ -v A3S_VOTE_MISSION_PLAYERS ]; then
		writeConfigEntry $1 "voteMissionPlayers" "$A3S_MISSION_PLAYERS"
	fi

	if [ -v A3S_KICK_DUPLICATE ]; then
		writeConfigEntry $1 "kickDuplicate" "$A3S_KICK_DUPLICATE"
	fi

	if [ -v A3S_LOOPBACK ]; then
		writeConfigEntry $1 "loopback" "$A3S_LOOPBACK"
	fi

	if [ -v A3S_UPNP ]; then
		writeConfigEntry $1 "upnp" "$A3S_UPNP"
	fi

	if [ -v A3S_ALLOWED_FILE_PATCHING ]; then
		writeConfigEntry $1 "allowedFilePatching" "$A3S_ALLOWED_FILE_PATCHING"
	fi

	if [ -v A3S_DISCONNECT_TIMEOUT ]; then
		writeConfigEntry $1 "disconnectTimeout" "$A3S_DISCONNECT_TIMEOUT"
	fi

	if [ -v A3S_MAX_DESYNC ]; then
		writeConfigEntry $1 "maxDesync" "$A3S_MAX_DESYNC"
	fi

	if [ -v A3S_MAX_PING ]; then
		writeConfigEntry $1 "maxPing" "$A3S_PING"
	fi

	if [ -v A3S_MAX_PACKET_LOSS ]; then
		writeConfigEntry $1 "maxPacketLoss" "$A3S_MAX_PACKET_LOSS"
	fi

	if [ -v A3S_KICK_CLIENTS_ON_SLOW_NETWORK ]; then
		writeConfigEntry $1 "kickClientsOnSlowNetwork" "$A3S_KICK_CLIENTS_ON_SLOW_NETWORK"
	fi

	if [ -v A3S_VERIFY_SIGNATURES ]; then
		writeConfigEntry $1 "verifySignatures" "$A3S_VERIFY_SIGNATURES"
	fi

	if [ -v A3S_DRAWING_IN_MAP ]; then
		writeConfigEntry $1 "drawingInMap" "$A3S_DRAWING_IN_MAP"
	fi

	if [ -v A3S_DISABLE_VON ]; then
		writeConfigEntry $1 "disableVoN" "$A3S_DISABLE_VON"
	fi

	if [ -v A3S_VON_CODEC_QUALITY ]; then
		writeConfigEntry $1 "vonCodecQuality" "$A3S_VON_CODEC_QUALITY"
	fi

	if [ -v A3S_VON_CODEC ]; then
		writeConfigEntry $1 "vonCodec" "$A3S_VON_CODEC"
	fi

	if [ -v A3S_DOUBLE_ID_DETECTED ]; then
		writeConfigEntry $1 "doubleIdDetected" "\"$A3S_DOUBLE_ID_DETECTED\""
	fi

	if [ -v A3S_ON_USER_CONNECTED ]; then
		writeConfigEntry $1 "onUserConnected" "\"$A3S_ON_USER_CONNECTED\""
	fi

	if [ -v A3S_ON_USER_DISCONNECTED ]; then
		writeConfigEntry $1 "onUserDisconnected" "\"$A3S_ON_USER_DISCONNECTED\""
	fi

	if [ -v A3S_ON_HACKED_DATA ]; then
		writeConfigEntry $1 "onHackedData" "\"$A3S_ON_HACKED_DATA\""
	fi

	if [ -v A3S_ON_DIFFERENT_DATA ]; then
		writeConfigEntry $1 "onDifferentData" "\"$A3S_ON_DIFFERENT_DATA\""
	fi

	if [ -v A3S_ON_UNSIGNED_DATA ]; then
		writeConfigEntry $1 "onUnsignedData" "\"$A3S_ON_UNSIGNED_DATA\""
	fi

	if [ -v A3S_REGULAR_CHECK ]; then
		writeConfigEntry $1 "regularCheck" "$A3S_REGULAR_CHECK"
	fi

	if [ -v A3S_BATTLEYE ]; then
		writeConfigEntry $1 "battleye" "$A3S_BATTLEYE"
	fi

	if [ -v A3S_TIME_STAMP_FORMAT ]; then
		writeConfigEntry $1 "timeStampFormat" "\"$A3S_TIME_STAMP_FORMAT\""
	fi

	if [ -v A3S_FORCE_ROTOR_LIB_SIMULATION ]; then
		writeConfigEntry $1 "forceRotorLibSimulation" "$A3S_FORCE_ROTOR_LIB_SIMULATION"
	fi

	if [ -v A3S_PERSISTENT ]; then
		writeConfigEntry $1 "persistent" "$A3S_PERSISTENT"
	fi

	if [ -v A3S_REQUIRED_BUILD ]; then
		writeConfigEntry $1 "requiredBuild" "$A3S_REQUIRED_BUILD"
	fi

	if [ -v A3S_FORCED_DIFFICULTY ]; then
		writeConfigEntry $1 "forcedDifficulty" "\"$A3S_FORCED_DIFFICULTY\""
	fi

	if [ -v A3S_MISSION_WHITELIST ]; then
		writeConfigEntry $1 "missionWhitelist\[\]" "$A3S_MISSION_WHITELIST"
	fi

	if [ -v A3S_MISSIONS ]; then
		if [ "$(grep "^class Missions {.*};" $1)" != "" ]; then
			sed -i "s/^class Missions {.*};/class Missions {$A3S_MISSIONS};/" $1
		else
			echo -e "class Missions {$A3S_MISSIONS};" >> $1
		fi
	fi
}

create_config_basic () {
	if [ ! -d $(dirname ${1}) ]; then
		mkdir -m 770 -p $(dirname ${1})
	fi

	echo -e "// Configuration file generated by a Docker container:\n" >> ${1}

	if [ -v A3S_MAX_MSG_SEND ]; then
		writeConfigEntry $1 "maxMsgSend" "$A3S_MAX_MSG_SEND"
	fi

	if [ -v A3S_MAX_SIZE_GUARANTEED ]; then
		writeConfigEntry $1 "maxSizeGuaranteed" "$A3S_MAX_SIZE_GUARANTEED"
	fi

	if [ -v A3S_MAX_SIZE_NONGUARANTEED ]; then
		writeConfigEntry $1 "maxSizeNonguaranteed" "$A3S_MAX_SIZE_NONGUARANTEED"
	fi

	if [ -v A3S_MAX_BANDWIDTH ]; then
		writeConfigEntry $1 "maxBandwidth" "$A3S_MAX_BANDWIDTH"
	fi

	if [ -v A3S_MIN_BANDWIDTH ]; then
		writeConfigEntry $1 "minBandwidth" "$A3S_MIN_BANDWIDTH"
	fi

	if [ -v A3S_MIN_ERROR_TO_SEND ]; then
		writeConfigEntry $1 "minErrorToSend" "$A3S_MIN_ERROR_TO_SEND"
	fi

	if [ -v A3S_MIN_ERROR_TO_SEND_NEAR ]; then
		writeConfigEntry $1 "minErrorToSendNear" "$A3S_MIN_ERROR_TO_SEND_NEAR"
	fi

	if [ -v A3S_MAX_CUSTOM_FILE_SIZE ]; then
		writeConfigEntry $1 "maxCustomFileSize" "$A3S_MAX_CUSTOM_FILE_SIZE"
	fi

	if [ -v A3S_MAX_PACKET_SIZE ]; then
		if [ "$(grep "maxPacketSize\s*=.*;" $1)" != "" ]; then
			sed -i "s/maxPacketSize\s*=.*;/maxPacketSize=$A3S_MAX_PACKET_SIZE;/" $1
		else
			echo -e "class Socket { maxPacketSize=$A3S_MAX_PACKET_SIZE; };" >> $1
		fi
	fi
}

writeBattleyeEntry () {
        if [ ! -f $1 ]; then
                touch $1
        fi
        if [ "$(grep "^$2\s.*" $1)" != "" ]; then
                sed -i "s/^$2\s.*/$2 $3/" $1
        else
                echo -e "$2 $3" >> $1
        fi
}

create_config_battleye () {
	if [ ! -d $(dirname ${1}) ]; then
		mkdir -m 770 -p $(dirname ${1})
	fi

	echo -e "// Configuration file generated by a Docker container:\n" >> ${1}

	if [ -v A3S_RCON_PORT ]; then
		writeBattleyeEntry $1 "RConPort" "$A3S_RCON_PORT"
	fi

	if [ -v A3S_RCON_PASSWORD ]; then
		writeBattleyeEntry $1 "RConPassword" "$A3S_RCON_PASSWORD"
	fi

	if [ -v A3S_MAX_PING ]; then
		writeBattleyeEntry $1 "RConMaxPing" "$A3S_MAX_PING"
	fi
}

getCollectionMods () {
	echo $(python3 $A3S_TOOLS_PATH/getCollectionMods.py $STEAM_API_KEY $1)
}

start () {
	create_opts
	configure
	$(cd $A3S_SERVER_PATH && $A3S_BIN $A3S_OPTS)
}

updateServer () {
	$STEAM_PATH_EXEC \
		+login $STEAM_USER $STEAM_PASS \
		+force_install_dir $A3S_SERVER_PATH \
		+app_update $STEAM_APP_ID validate \
		+quit
}

updateMods () {
	local mods=("")

	if [ "${A3S_CLIENT_MODS_WORKSHOP}" != "NULL" ]; then
		mods=("$(echo "${A3S_CLIENT_MODS_WORKSHOP}" | sed -e 's/;//')")
	fi

	if [ "${A3S_SERVER_MODS_WORKSHOP}" != "NULL" ]; then
		mods=("$mods" "$(echo "${A3S_SERVER_MODS_WORKSHOP}" | sed -e 's/;//')")
	fi

	if [ "${A3S_CLIENT_MODS_COLLECTION}" != "NULL" ]; then
		for collection in $(echo "${A3S_CLIENT_MODS_COLLECTION}" | sed -e 's/;//'); do
			mods=("$mods" "$(getCollectionMods $collection)")
		done
	fi

	if [ "${A3S_SERVER_MODS_COLLECTION}" != "NULL" ]; then
		for collection in $(echo "${A3S_SERVER_MODS_COLLECTION}" | sed -e 's/;//'); do
			mods=("$mods" "$(getCollectionMods $collection)")
		done
	fi

	local opts=" "
	for mod in ${mods[@]}; do
		opts="$opts+workshop_download_item 107410 $mod validate "
	done

	$STEAM_PATH_EXEC +login $STEAM_USER $STEAM_PASS +force_install_dir $A3S_SERVER_PATH $opts +quit

	toLower $A3S_SERVER_PATH/steamapps/workshop/content/107410/
}

toLower () {
	find $1 -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
}

update () {
    updateServer

    if [ -v STEAM_API_KEY ]; then
    	updateMods
    fi
}


main $@
