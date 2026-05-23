FROM php:8.3-apache

# Enable mod_rewrite (used by .htaccess) and allow .htaccess overrides
RUN a2enmod rewrite \
 && sed -ri -e 's!AllowOverride None!AllowOverride All!g' /etc/apache2/apache2.conf \
 && echo "ServerName portfolio-php" >> /etc/apache2/apache2.conf
