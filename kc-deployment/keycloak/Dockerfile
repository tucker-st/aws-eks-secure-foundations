# This is a customised docker file. You can use this to create your own settings. Not all settings in the file
# are required to build a docker container image.

# Create container image for keycloak
FROM quay.io/keycloak/keycloak:latest AS builder

# Enable health and metrics support

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Database Source
ENV KC_DB=postgres

# Set these values to running postgres instance

ENV KC_DB=postgres
ENV KC_DB_URL_HOST=postgres
ENV KC_DB_URL_DATABASE=keycloak
ENV KC_DB_USERNAME=keycloak


# Passwords should not be in here. Instead use Docker secrets 
# function or pass in variables during build.

# You will pass default account via command line when using docker run
# or via environmental settings.

WORKDIR /opt/keycloak

# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

# Expose default port to listen on
# EXPOSE 8080

CMD [ "start-dev" ]

