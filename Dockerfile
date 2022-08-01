FROM alpine:latest
WORKDIR /var/www/html

EXPOSE 80
CMD ["httpd-foreground"]