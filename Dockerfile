FROM registry.access.redhat.com/rhel7
MAINTAINER jjyoo@rockplace.co.kr
LABEL summary="RHEL7 base reposync image"

### Timezone
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

### Source IP
ENV sip=""

#ENV Path
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir -p /repo1 > /dev/null

### Package Update
RUN yum update -y > /dev/null

### Package Install
RUN yum install cronie createrepo -y > /dev/null
RUN yum repolist --disablerepo=* && \
    yum-config-manager --disable \* > /dev/null && \
    yum-config-manager --enable rhel-7-server-rhv-4.3-manager-rpms --enable rhel-7-server-rhv-4.2-manager-rpms --enable rhel-7-server-rhv-4.1-manager-rpms --enable rhel-7-server-rhv-4-manager-rpms --enable rhel-7-server-rhv-4-manager-tools-rpms > /dev/null 
RUN yum clean all -y > /dev/null

### Cron Setting
# Seems like a container specific issue on Centos: https://github.com/CentOS/CentOS-Dockerfiles/issues/31 
RUN sed -i '/session    required   pam_loginuid.so/d' /etc/pam.d/crond

### Cron Add
ADD start-cron.txt /tmp/start-cron.txt
RUN crontab /tmp/start-cron.txt 
RUN rm -f /tmp/start-cron.txt

### reposync file Add
RUN mkdir -p /root/reposync
ADD rhv_reposync.sh /root/reposync
ADD rhv_channel.txt /root/reposync
RUN chmod +x /root/reposync/rhv_reposync.sh

##custom entry point — needed by cron
COPY entrypoint /entrypoint
RUN chmod +x /entrypoint
ENTRYPOINT ["/entrypoint"]
