FROM centos:latest
MAINTAINER rutikkapadnis123@gmail.com
RUN yum install -y httpd \
zip \
unzip
ADD https://nicepage.com/s/42512/crafting-digital-experiences-css-template#
