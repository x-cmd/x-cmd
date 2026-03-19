FROM ubuntu:latest

ADD entrypoint.sh /bin/entrypoint.sh
ADD build.sh /bin/build.sh

RUN /bin/sh /bin/build.sh

ENTRYPOINT [ "/bin/sh", "/bin/entrypoint.sh" ]
