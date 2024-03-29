# Image based on Ubuntu.
FROM ubuntu

# Define user, user id and group id for a new account to work within container.
ARG USER=docker
ARG UID=1000
ARG GID=1000

# Install PHP, composer and all extensions needed for Magento.
RUN apt-get update && apt-get install -y software-properties-common curl



## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

## preesed tzdata, update package index, upgrade packages and install needed software
RUN echo "tzdata tzdata/Areas select America" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/America select Chicago" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt && \
    apt-get update && \
    apt-get install -y tzdata



RUN add-apt-repository ppa:ondrej/php
RUN apt-get update && apt-get install -y php7.4
RUN apt-get update && apt-get install -y \
    php7.4-mysql php7.4-xml php7.4-intl php7.4-curl \
    php7.4-bcmath php7.4-gd php7.4-mbstring php7.4-soap php7.4-zip \
    composer

# Install Xdebug for a better developer experience.
RUN apt-get update && apt-get install -y php7.4-xdebug
RUN echo "xdebug.remote_enable=on" >> /etc/php/7.4/mods-available/xdebug.ini
RUN echo "xdebug.remote_autostart=on" >> /etc/php/7.4/mods-available/xdebug.ini

# Install mysql CLI client.
RUN apt-get update && apt-get install -y mysql-client

# Set up a non-root user with sudo access.
RUN groupadd --gid $GID $USER \
    && useradd -s /bin/bash --uid $UID --gid $GID -m $USER \
    && apt-get install -y sudo \
    && echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER

# Use the non-root user to log in as into the container.
USER ${UID}:${GID}

# Set this as the default directory when we connect to the container.
WORKDIR /workspaces/magento

# This is a quick hack to make sure the container has something to run
# when it starts, preventing it from closing itself automatically when created.
CMD ["sleep", "infinity"]
