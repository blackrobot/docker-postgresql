# damon/postgresql

FROM postgres:9.3

ENV GIS_VERSION 2.1

# Update sources, and install dependencies
RUN apt-get update \
    && apt-get install -y \
          postgresql-$PG_MAJOR-postgis-$GIS_VERSION \
          postgresql-contrib-$PG_MAJOR \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Defaults
ENV DB_USER super_user
ENV DB_PASS super_user
ENV DB_NAME default

COPY ./custom.postgresql.conf /
COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["postgres"]
