FROM		ubuntu:16.04
MAINTAINER	technopreneural@yahoo.com

			# Install latest updates (security best practice)
RUN			apt-get update \
			&& apt-get upgrade -y \

			# Install packages (without asking for user input)
			&& DEBIAN_FRONTEND=noninteractive apt-get install -y \
				debconf-utils \
				openssl \
				apache2 \
				apache2-utils \

			# Fix warnings
			&& echo "ServerName localhost" >> /etc/apache2/conf-available/servername.conf && a2enconf servername \

			# Create self-signed SSL certificate
			&& mkdir /etc/apache2/ssl \
			&& openssl req \
				-x509 \
				-nodes \
				-days 365 \
				-newkey rsa:2048 \
				-keyout /etc/apache2/ssl/apache2.key \ 
				-out /etc/apache2/ssl/apache2.crt \
				-subj "/CN=docker-ubuntu-14.04-apache2" \

			# Install SSL certificate
			&& sed -i -e "s|/etc/ssl/certs/ssl-cert-snakeoil.pem|/etc/apache2/ssl/apache2.crt|g" /etc/apache2/sites-available/default-ssl.conf \
			&& sed -i -e "s|/etc/ssl/private/ssl-cert-snakeoil.key|/etc/apache2/ssl/apache2.key|g" /etc/apache2/sites-available/default-ssl.conf \

			# Enable SSL
			&& a2enmod ssl \
			&& a2ensite default-ssl \

			# Enable URL rewriting for pretty URLs
			&& a2enmod rewrite \
			&& sed -i -e '/^<Directory \/var\/www\/>/,/^<\/Directory>/s/\(AllowOverride \)None/\1All/' /etc/apache2/apache2.conf \

			# Remove repo lists (reduce image size)
			&& rm -rf /var/lib/apt/lists/* \

			# Virtualhosts, site/app folder, and logs
VOLUME		["/var/www/html"]

			# Expose default ports for HTTP and HTTPS
EXPOSE		80 443
			
ENTRYPOINT	["/usr/sbin/apache2ctl", "-D FOREGROUND"]
