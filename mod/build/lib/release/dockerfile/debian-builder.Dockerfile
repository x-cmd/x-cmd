FROM debian:latest

RUN apt-get update && apt-get install -y dpkg-dev
RUN useradd -m builder
USER builder
WORKDIR /home/builder
