FROM debian:stable-slim

USER root

RUN apt-get update && apt-get install -y sudo tmux lib32stdc++6 lib32gcc1 python3 wget
RUN adduser --disabled-password --gecos '' arma3server \
    && adduser arma3server sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER arma3server

RUN mkdir -p /home/arma3server/tools \
    && mkdir -p /home/arma3server/server \
    && mkdir -p /home/arma3server/logs

WORKDIR /home/arma3server/tools
COPY getCollectionMods.py entrypoint.sh ./
# RUN cd /home/arma3server/tools && ./arma3.sh install
# RUN cd /home/arma3server/tools && ./arma3.sh restart

ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "install" ]
