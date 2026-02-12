# FROM ubuntu:latest


# RUN apt install -y jq yq sqlite curl git

# RUN eval "$(curl https://get.x-cmd.com)" && x pixi --install && x env use claude-code


FROM ubuntu
USER root
WORKDIR /root

RUN apt update
RUN apt install -y curl

RUN curl https://get.x-cmd.com | bash

RUN ___X_CMD_ROOTBIN_SLEEP=0 x-cmd || true

RUN /root/.x-cmd.root/bin/___x_cmdexe env use claude-code
