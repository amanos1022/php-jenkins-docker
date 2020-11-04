FROM bitnami/minideb:buster

ARG SSH_PRIVATE_KEY
RUN apt-get update; apt-get install -y \
    nginx php-fpm php-curl php-dom php-igbinary php-intl \
    php-mbstring php-mysql php-redis php-pgsql git ssh unzip curl; \
    #ssh key
    mkdir /root/.ssh/; \
    echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa; \
    chmod 600 /root/.ssh/id_rsa; \
    ssh-keyscan github.com >> /root/.ssh/known_hosts; \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer;


COPY ./php/pool.d /etc/php/7.3/fpm/pool.d
COPY ./nginx/conf.d /etc/nginx/conf.d 
COPY ./app /app

COPY ./start.sh /start.sh 
RUN chmod +x /start.sh

# allows shell scripts to be ran
RUN echo "exit 0" > /usr/sbin/policy-rc.d 
RUN cd /app; /usr/local/bin/composer install --no-scripts --ignore-platform-reqs;
RUN chown -R www-data:www-data /app; chmod +w /app/storage/logs /app/storage/framework;

CMD ["/start.sh"]
