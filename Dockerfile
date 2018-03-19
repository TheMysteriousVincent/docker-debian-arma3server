FROM debian:stable-slim

USER root

RUN apt-get update \
	&& apt-get install -y sudo tmux lib32stdc++6 lib32gcc1 python3 wget python3-pip \
	&& pip3 install requests
RUN adduser --disabled-password --gecos '' arma3server \
    && adduser arma3server sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER arma3server

RUN mkdir -p /home/arma3server/tools \
    && mkdir -p /home/arma3server/server/steamapps/workshop/content/107410/ \
    && mkdir -p /home/arma3server/logs

WORKDIR /home/arma3server/tools
COPY getCollectionMods.py entrypoint.sh ./
RUN sudo chmod 777 /home/arma3server/tools/*

ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "install" ]
