FROM 555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-php7.2-apache:ubuntu-16.04

WORKDIR /var/www
COPY . ./

# Installing dependencies which look to be in the dev config and causing failures
# RUN composer install --ignore-platform-reqs --optimize-autoloader --no-suggest