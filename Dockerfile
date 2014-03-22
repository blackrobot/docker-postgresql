# damon/base

FROM damon/base

ENV LANGUAGE en_US.UTF-8

# Add the repository to our sources list
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update -qq

# Install postgresql
RUN update-locale LANG=en_US.UTF-8 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -qq postgresql-9.3 postgresql-server-dev-9.3 postgresql-contrib-9.3 && \
    /etc/init.d/postgresql stop

# Cleanup
RUN apt-get clean

# Add our config files
ADD postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
ADD run /scripts/run

# Create the data directory, copy existing pg data, and set permissions
RUN mkdir /data && \
    cp -R /var/lib/postgresql/9.3/main/* /data/ && \
    touch /.provision-me && \
    chown -Rf postgres:postgres /data/ /scripts/run && \
    chmod -Rf 700 /data/ /scripts/run /.provision-me

VOLUME ["/data"]
EXPOSE 5432
CMD /scripts/run
