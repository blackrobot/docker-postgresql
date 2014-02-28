# damon/base

FROM damon/base

# Add the repository to our sources list
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update -qq

# Install postgresql
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -qq inotify-tools postgresql-9.3 && \
    /etc/init.d/postgresql stop

# Add our config files
ADD postgresql.conf /config/postgresql.conf
ADD pg_hba.conf /config/pg_hba.conf

# Create the data directory, copy existing pg data, and set permissions
RUN mkdir /data/ && \
    cp -R /var/lib/postgresql/9.3/main/* /data/ && \
    chown postgres:postgres /data/ /config/ && \
    chmod 700 /data/ /config/

# Start postgresql and create a user/database
ENV DB_USERNAME database_user
ADD setup-db /setup-db
RUN chmod +x /setup-db && /etc/init.d/postgresql start && /setup-db

# Cleanup
RUN apt-get clean && rm /setup-db

VOLUME ["/data"]
EXPOSE 5432
USER postgres
CMD /usr/lib/postgresql/9.3/bin/postgres -D /etc/postgresql/9.3/main
