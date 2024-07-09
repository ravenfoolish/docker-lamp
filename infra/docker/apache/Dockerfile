FROM httpd:2.4.61-bookworm AS base

# timezone environment
ENV TZ=UTC

# apache configuration
COPY ./infra/docker/apache/httpd.conf /usr/local/apache2/conf/httpd.conf
