FROM debian:stable-slim

USER root

RUN apt-get update && apt-get install sudo
RUN adduser --disabled-password --gecos '' arma3server \
    && adduser arma3server sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER arma3server

RUN mkdir -p /home/arma3server/tools \
    && mkdir -p /home/arma3server/server \
    && mkdir -p /home/arma3server/logs

WORKDIR /home/arma3server/tools
COPY arma3.sh ./ \
    && getCollectionMods.py ./ \
    && entrypoint.sh ./
# RUN cd /home/arma3server/tools && ./arma3.sh install
# RUN cd /home/arma3server/tools && ./arma3.sh restart

ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "install" ]
