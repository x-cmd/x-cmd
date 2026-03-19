FROM fedora:latest

RUN dnf update; dnf install -y curl
