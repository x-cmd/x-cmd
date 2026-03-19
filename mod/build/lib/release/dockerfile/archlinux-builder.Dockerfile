FROM archlinux:latest

RUN echo 'Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN echo y | pacman -Sy --needed base-devel
RUN useradd -m builder
RUN echo "builder:123456" | chpasswd
RUN echo "builder ALL=(ALL) ALL" >> /etc/sudoers
USER builder
WORKDIR /home/builder
