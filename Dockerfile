FROM centos:latest
MAINTAINER sanjay.dahiya332@gmail.com
RUN yum install -y httpd \
  zip \
 unzip 
ADD https://www.free-css.com/assets/files/free-css-templates/download/page258/beauty.zip /var/www/html/
WORKDIR /var/www/html
RUN unzip beauty.zip
RUN cp -rvf beauty/* .
RUN rm -rf beauty.zip 
CMD ["/usr/sbin/httpd", "-D",  "FOREGROUND"]
EXPOSE 80 
