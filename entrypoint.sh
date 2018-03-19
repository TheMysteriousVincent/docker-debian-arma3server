#!/bin/bash

STEAM_PATH_EXEC=/home/arma3server/Steam/steamcmd.sh
A3S_PATH=/home/arma3server/server/
A3S_TOOLS_PATH=/home/arma3server/tools/
A3S_LOGS_PATH=/home/arma3server/logs/

main () {
	init_vars
	case $1 in
	"install")
		install
		;;
	"start")
		start
		;;
	"updateServer")
		stop
		updateServer
		start
		;;
	"updateMods")
		stop
		updateMods
		start
		;;
	"configure")
		configure
		;;
	"update")
		stop
		update
		start
		;;
	"stop")
		stop
		;;
	"restart")
		restart
		;;
	"help")
		help
		;;
	esac
}

help () {
	echo -e "Usage: ./entrypoint.sh <arg>"
	echo -e "\tinstall\tInstalls the the whole server."
}

install () {
	if [ ! -f ~/Steam ]; then
		if [ ! -f ~/Steam/steamcmd.sh ]; then
			mkdir ~/Steam && cd ~/Steam
			wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
			tar -xzf steamcmd_linux.tar.gz
			rm steamcmd_linux.tar.gz
		fi
	fi

	update
}

init_vars () {
	: ${STEAM_LOGIN:=anonymous}
	: ${STEAM_PASSWORD:=anonymous}
	: ${STEAM_APP_ID:=233780}
	: ${STEAM_API_KEY:=}

	: ${A3S_PATH:=/home/arma3server/server}
	: ${A3S_BIN:=$A3S_PATH/arma3server}
	: ${A3S_LOGFILE:=/dev/stdout}
	: ${A3S_RCON_PORT:=2306}
	: ${A3S_RCON_PASSWORD:=$(cat /dev/urandom | tr -d -c a-z0-9- | dd bs=1 count=$((RANDOM%(24-16+1)+16)) 2> /dev/null)}
	: ${A3S_OPTS:=}

	: ${A3S_PORT:=2302}
	: ${A3S_BEPATH:=$A3S_PATH/battleye}
	: ${A3S_PROFILES:=$A3S_PATH/profiles}
	: ${A3S_BASIC_CONFIG:=$A3S_PATH/basic.cfg}
	: ${A3S_SERVER_CONFIG:=$A3S_PATH/server.cfg}
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

	if [ "${A3S_AUTOINIT}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -autoInit"
	fi

	if [ "${A3S_LOAD_MISSION_TO_MEMORY}" != NULL ]; then
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

	if [ "${A3S_ENABLE_HT}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -enableHT"
	fi

	if [ "${A3S_HUGEPAGES}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -hugepages"
	fi

	if [ "${A3S_SHOW_SCRIPT_ERRORS}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -showScriptErrors"
	fi

	if [ "${A3S_FILE_PATCHING}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -filePatching"
	fi

	if [ "${A3S_INIT}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -init=${A3S_INIT}"
	fi

	if [ "${A3S_AUTOTEST}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -autotest"
	fi

	if [ "${A3S_BETA}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -beta=${A3S_BETA}"
	fi

	if [ "${A3S_CHECK_SIGNATURES}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -checkSignatures"
	fi

	if [ "${A3S_CRASHDIAG}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -crashDiag"
	fi

	if [ "${A3S_NO_FILE_PATCHING}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -noFilePatching"
	fi

	if [ "${A3S_DEBUG_CALL_EXTENSION}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -debugCallExtension"
	fi

	if [ "${A3S_NO_LAND}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -noLand"
	fi

	if [ "${A3S_BULDOZER}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -buldozer"
	fi

	if [ "${A3S_CONNECT}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -connect=${A3S_CONNECT}"
	fi

	if [ "${A3S_PASSWORD}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -password=${A3S_PASSWORD}"
	fi

	if [ "${A3S_SERVER}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -server"
	fi

	if [ "${A3S_CLIENT}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -client"
	fi

	if [ "${A3S_PID}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -pid=${A3S_PID}"
	fi

	if [ "${A3S_RANKING}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -ranking=${A3S_RANKING}"
	fi

	if [ "${A3S_NETLOG}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -netlog=${A3S_NETLOG}"
	fi

	if [ "${A3S_DISABLE_SERVER_THREAD}" != NULL ]; then
		A3S_OPTS="${A3S_OPTS} -disableServerThread=${A3S_DISABLE_SERVER_THREAD}"
	fi

	local tmpMods=""
	if [ "${A3S_CLIENT_MODS}" != NULL ]; then
		tmpMods="$A3S_CLIENT_MODS"
	fi

	if [ "${A3S_CLIENT_WORKSHOP}" != NULL ]; then
		for mod in $(${A3S_CLIENT_WORKSHOP} | sed -e 's/;//'); do
			tmpMods="steamapps/workshop/content/107410/$mod;$tmpMods"
		done
	fi

	if [ "${A3S_CLIENT_COLLECTION}" != NULL ]; then
		for collection in $(${A3S_CLIENT_COLLECTION} | sed -e 's/;//'); do
			for mod in $(getCollectionMods $collection); do
				tmpMods="steamapps/workshop/content/107410/$mod;$tmpMods"
			done
		done
	fi

	if [ -v "$tmpMods" ]; then
		A3S_OPTS="${A3S_OPTS} -mod=$tmpMods"
	fi
	unset tmpMods

	local tmpMods=""
	if [ "${A3S_SERVER_MODS}" != NULL ]; then
		tmpMods="$A3S_CLIENT_MODS"
	fi

	if [ "${A3S_SERVER_WORKSHOP}" != NULL ]; then
		for mod in $(${A3S_SERVER_WORKSHOP} | sed -e 's/;//'); do
			tmpMods="steamapps/workshop/content/107410/$mod;$tmpMods"
		done
	fi

	if [ "${A3S_SERVER_COLLECTION}" != NULL ]; then
		for collection in $(${A3S_SERVER_COLLECTION} | sed -e 's/;//'); do
			for mod in $(getCollectionMods $collection); do
				tmpMods="steamapps/workshop/content/107410/$mod;$tmpMods"
			done
		done
	fi

	if [ -v "$tmpMods" ]; then
		A3S_OPTS="${A3S_OPTS} -serverMod=$tmpMods"
	fi
	unset tmpMods

	return
}

configure () {
	create_config_basic $A3S_BASIC_CONFIG
	create_config_server $A3S_SERVER_CONFIG

	if [ ! -d $A3S_PATH/battleye/launch ]; then
		mkdir -m 770 -p $A3S_PATH/battleye/lauch
	fi

	if [ ! -f $A3S_PATH/battleye/launch/beserver.cfg ]; then
		create_config_battleye $A3S_PATH/battleye/launch/beserver.cfg
	fi

	if [ ! -f $A3S_PATH/battleye/beserver.cfg ]; then
		create_config_battleye $A3S_PATH/battleye/beserver.cfg
	fi
}

create_config_server () {
	if [ ! -f ${1} ]; then
		if [ ! -d $(dirname ${1}) ]; then
			mkdir -m 770 -p $(dirname ${1})
		fi

		echo -e "// Configuration file generated by a Docker container:\n" >> ${1}

		if [ -v A3S_PASSWORD_ADMIN ]; then
			echo -e "passwordAdmin=\"$A3S_PASSWORD_ADMIN\";" >> ${1}
		fi

		if [ -v A3S_PASSWORD ]; then
			echo -e "password=\"$A3S_PASSWORD\";" >> ${1}
		fi

		if [ -v A3S_PASSWORD_SERVER_COMMAND ]; then
			echo -e "serverCommandPassword=\"$A3S_PASSWORD_SERVER_COMMAND\";" >> ${1}
		fi

		if [ -v A3S_HOSTNAME ]; then
			echo -e "hostname=\"$A3S_HOSTNAME\";" >> ${1}
		fi

		if [ -v A3S_MAX_PLAYERS ]; then
			echo -e "maxPlayers=$A3S_MAX_PLAYERS;" >> ${1}
		fi

		if [ -v A3S_MOTD ]; then
			echo -e "motd[]=$A3S_MOTD;" >> ${1}
		fi

		if [ -v A3S_ADMINS ]; then
			echo -e "admins[]=$A3S_ADMINS;" >> ${1}
		fi

		if [ -v A3S_HEADLESS_CLIENTS ]; then
			echo -e "headlessClients[]=$A3S_HEADLESS_CLIENTS;" >> ${1}
		fi

		if [ -v A3S_LOCAL_CLIENT ]; then
			echo -e "localClient[]=$A3S_LOCAL_CLIENT;" >> ${1}
		fi

		if [ -v A3S_VOTE_THRESHOLD ]; then
			echo -e "voteThreshold=$A3S_VOTE_THRESHOLD;" >> ${1}
		fi

		if [ -v A3S_VOTE_MISSION_PLAYERS ]; then
			echo -e "voteMissionPlayers=$A3S_MISSION_PLAYERS;" >> ${1}
		fi

		if [ -v A3S_KICK_DUPLICATE ]; then
			echo -e "kickDuplicate=$A3S_KICK_DUPLICATE;" >> ${1}
		fi

		if [ -v A3S_LOOPBACK ]; then
			echo -e "loopback=$A3S_LOOPBACK;" >> ${1}
		fi

		if [ -v A3S_UPNP ]; then
			echo -e "upnp=$A3S_UPNP;" >> ${1}
		fi

		if [ -v A3S_ALLOWED_FILE_PATCHING ]; then
			echo -e "allowedFilePatching=$A3S_ALLOWED_FILE_PATCHING;" >> ${1}
		fi

		if [ -v A3S_DISCONNECT_TIMEOUT ]; then
			echo -e "disconnectTimeout=$A3S_DISCONNECT_TIMEOUT;" >> ${1}
		fi

		if [ -v A3S_MAX_DESYNC ]; then
			echo -e "maxDesync=$A3S_MAX_DESYNC;" >> ${1}
		fi

		if [ -v A3S_MAX_PING ]; then
			echo -e "maxPing=$A3S_PING;" >> ${1}
		fi

		if [ -v A3S_MAX_PACKET_LOSS ]; then
			echo -e "maxPacketLoss=$A3S_MAX_PACKET_LOSS;" >> ${1}
		fi

		if [ -v A3S_KICK_CLIENTS_ON_SLOW_NETWORK ]; then
			echo -e "kickClientsOnSlowNetwork=$A3S_KICK_CLIENTS_ON_SLOW_NETWORK;" >> ${1}
		fi

		if [ -v A3S_VERIFY_SIGNATURES ]; then
			echo -e "verifySignatures=$A3S_VERIFY_SIGNATURES;" >> ${1}
		fi

		if [ -v A3S_DRAWING_IN_MAP ]; then
			echo -e "drawingInMap=$A3S_DRAWING_IN_MAP;" >> ${1}
		fi

		if [ -v A3S_DISABLE_VON ]; then
			echo -e "disableVoN=$A3S_DISABLE_VON;" >> ${1}
		fi

		if [ -v A3S_VON_CODEC_QUALITY ]; then
			echo -e "vonCodecQuality=$A3S_VON_CODEC_QUALITY;" >> ${1}
		fi

		if [ -v A3S_VON_CODEC ]; then
			echo -e "vonCodec=$A3S_VON_CODEC;" >> ${1}
		fi

		if [ -v A3S_DOUBLE_ID_DETECTED ]; then
			echo -e "doubleIdDetected=\"$A3S_DOUBLE_ID_DETECTED\";" >> ${1}
		fi

		if [ -v A3S_ON_USER_CONNECTED ]; then
			echo -e "onUserConnected=\"$A3S_ON_USER_CONNECTED\";" >> ${1}
		fi

		if [ -v A3S_ON_USER_DISCONNECTED ]; then
			echo -e "onUserDisconnected=\"$A3S_ON_USER_DISCONNECTED\";" >> ${1}
		fi

		if [ -v A3S_ON_HACKED_DATA ]; then
			echo -e "onHackedData=\"$A3S_ON_HACKED_DATA;\"" >> ${1}
		fi

		if [ -v A3S_ON_DIFFERENT_DATA ]; then
			echo -e "onDifferentData=\"$A3S_ON_DIFFERENT_DATA\";" >> ${1}
		fi

		if [ -v A3S_ON_UNSIGNED_DATA ]; then
			echo -e "onUnsignedData=\"$A3S_ON_UNSIGNED_DATA\";" >> ${1}
		fi

		if [ -v A3S_REGULAR_CHECK ]; then
			echo -e "regularCheck=$A3S_REGULAR_CHECK;" >> ${1}
		fi

		if [ -v A3S_BATTLEYE ]; then
			echo -e "battleye=$A3S_BATTLEYE;" >> ${1}
		fi

		if [ -v A3S_TIME_STAMP_FORMAT ]; then
			echo -e "timeStampFormat=$A3S_TIME_STAMP_FORMAT;" >> ${1}
		fi

		if [ -v A3S_FORCE_ROTOR_LIB_SIMULATION ]; then
			echo -e "forceRotorLibSimulation=$A3S_FORCE_ROTOR_LIB_SIMULATION;" >> ${1}
		fi

		if [ -v A3S_PERSISTENT ]; then
			echo -e "persistent=$A3S_PERSISTENT;" >> ${1}
		fi

		if [ -v A3S_REQUIRED_BUILD ]; then
			echo -e "requiredBuild=$A3S_REQUIRED_BUILD;" >> ${1}
		fi

		if [ -v A3S_FORCED_DIFFICULTY ]; then
			echo -e "forcedDifficulty=\"$A3S_FORCED_DIFFICULTY\";" >> ${1}
		fi

		if [ -v A3S_MISSION_WHITELIST ]; then
			echo -e "missionWhitelist[]=$A3S_MISSION_WHITELIST;" >> ${1}
		fi

		if [ -v A3S_MISSIONS ]; then
			echo -e "class Missions { $A3S_MISSIONS };" >> ${1}
		fi
	fi
}

create_config_basic () {
	if [ ! -f ${1} ]; then
		if [ ! -d $(dirname ${1}) ]; then
			mkdir -m 770 -p $(dirname ${1})
		fi

		echo -e "// Configuration file generated by a Docker container:\n" >> ${1}

		if [ -v A3S_MAX_MSG_SEND ]; then
			echo -e "maxMsgSend=$A3S_MAX_MSG_SEND;" >> ${1}
		fi

		if [ -v A3S_MAX_SIZE_GUARANTEED ]; then
			echo -e "maxSizeGuaranteed=$A3S_MAX_SIZE_GUARANTEED;" >> ${1}
		fi

		if [ -v A3S_MAX_SIZE_NONGUARANTEED ]; then
			echo -e "maxSizeNonguaranteed=$A3S_MAX_SIZE_NONGUARANTEED;" >> ${1}
		fi

		if [ -v A3S_MAX_BANDWIDTH ]; then
			echo -e "maxBandwidth=$A3S_MAX_BANDWIDTH;" >> ${1}
		fi

		if [ -v A3S_MIN_BANDWIDTH ]; then
			echo -e "minBandwidth=$A3S_MIN_BANDWIDTH;" >> ${1}
		fi

		if [ -v A3S_MIN_ERROR_TO_SEND ]; then
			echo -e "minErrorToSend=$A3S_MIN_ERROR_TO_SEND;" >> ${1}
		fi

		if [ -v A3S_MIN_ERROR_TO_SEND_NEAR ]; then
			echo -e "minErrorToSendNear=$A3S_MIN_ERROR_TO_SEND_NEAR;" >> ${1}
		fi

		if [ -v A3S_MAX_CUSTOM_FILE_SIZE ]; then
			echo -e "maxCustomFileSize=$A3S_MAX_CUSTOM_FILE_SIZE;" >> ${1}
		fi

		if [ -v A3S_MAX_PACKET_SIZE ]; then
			echo -e "class Socket {maxPacketSize=$A3S_MAX_PACKET_SIZE;};" >> ${1}
		fi
	fi
}

create_config_battleye () {
	if [ ! -f ${1} ]; then
		if [ ! -d $(dirname ${1}) ]; then
			mkdir -m 770 -p $(dirname ${1})
		fi

		echo -e "// Configuration file generated by a Docker container:\n" >> ${1}

		if [ -v A3S_RCON_PORT ]; then
			echo -e "RConPort $A3S_RCON_PORT" >> ${1}
		fi

		if [ -v A3S_RCON_PASSWORD ]; then
			echo -e "RConPassword $A3S_RCON_PASSWORD" >> ${1}
		fi

		if [ -v A3S_MAX_PING ]; then
			echo -e "RConMaxPing $A3S_MAX_PING" >> ${1}
		fi
	fi
}

getCollectionMods () {
	echo $(python3 $A3S_TOOLS_PATH/getCollectionMods.py $STEAM_API_KEY $1)
}

start () {
	if ! status; then
		create_opts
		tmux new -d -s arma3server "$A3S_BIN $A3S_OPTS"
	fi
}

status () {
	if ! $(tmux list-sessions | grep -q arma3server); then
		return 1
	fi
	return 0
}

stop () {
	if status; then
		tmux kill-session -t arma3server
	fi
}

restart () {
	stop
	start
}

updateServer () {
	$STEAM_PATH_EXEC \
		+login $STEAM_USER $STEAM_PASS \
		+force_install_dir $A3S_PATH \
		+app_update 233780 validate \
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

	echo $mods
	local opts=" "
	for mod in ${mods[@]}; do
		opts="$opts+workshop_download_item 107410 $mod validate "
	done

	echo "$opts"
	echo "$STEAM_PATH_EXEC +login $STEAM_USER $STEAM_PASS +force_install_dir $A3S_PATH $opts +quit"
	$STEAM_PATH_EXEC +login $STEAM_USER $STEAM_PASS +force_install_dir $A3S_PATH $opts +quit

	toLower $A3S_PATH/steamapps/workshop/content/107410/
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
