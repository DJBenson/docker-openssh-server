FROM lsiobase/alpine:3.12

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENSSH_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

RUN \
 echo "**** install runtime packages ****" && \
 apk add --no-cache --upgrade \
	curl \
	logrotate \
	nano \
	alpine-sdk \
	libffi-dev \
	libressl-dev \
	python3 \
	python3-dev \
	py3-setuptools \
	ca-certificates \
	sudo && \
 echo "**** install openssh-server ****" && \
 if [ -z ${OPENSSH_RELEASE+x} ]; then \
	OPENSSH_RELEASE=$(curl -s http://dl-cdn.alpinelinux.org/alpine/v3.12/main/x86_64/ \
	| awk -F '(openssh-server-|.apk)' '/openssh-server.*.apk/ {print $2; exit}'); \
 fi && \
 apk add --no-cache \
	openssh-server==${OPENSSH_RELEASE} \
	openssh-sftp-server==${OPENSSH_RELEASE} && \
 echo "**** setup openssh environment ****" && \
 sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
 usermod --shell /bin/bash abc && \
 rm -rf \
	/tmp/* && \
 easy_install pip && \
 pip install --upgrade setuptools && \
 echo "**** install butterfly-server ****" && \
 pip install butterfly && \
 pip install butterfly[themes]

ADD docker/run.sh /opt/run.sh

EXPOSE 57575

CMD ["butterfly.server.py", "--unsecure", "--login", "--host=0.0.0.0", "--port=57575", "--pam_profile=sshd"]
ENTRYPOINT ["docker/run.sh"]

# add local files
COPY /root /
