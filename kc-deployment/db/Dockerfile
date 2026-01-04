# This is a customised docker file. You can use this to create your own settings. Not all settings in the file
# are required to build a docker container image.

FROM  postgres:latest AS builder


# Set environment variables

ENV PGDATA=/var/lib/postgresql/data
ENV POSTGRES_DB=keycloak
ENV POSTGRES_USER=keycloak
 
EXPOSE 5432