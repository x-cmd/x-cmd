#! /bin/sh

mkdir -p /run/sshd
mkdir -p /var/run/sshd; chmod 0755 /var/run/sshd;

while true; do
    /usr/sbin/sshd -D
    case "$?" in        130)        return 130 ;;   esac
    sleep 10
    case "$?" in        130)        return 130 ;;   esac
done >/root/sshd.log.txt
