#Use CxFlow Base image
FROM checkmarx/cx-flow

#install sbt
ENV SBT_VERSION 1.8.2
RUN apk add --no-cache bash curl && \
    curl -sL "https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local && \
    ln -s /usr/local/sbt/bin/sbt /usr/local/bin/sbt && \
    chmod 0755 /usr/local/bin/sbt

#SCA Resolver Logs
RUN mkdir /scar
COPY ScaResolver.sh /scar/ScaResolver.sh
RUN chmod +x /scar/ScaResolver.sh

#Copy the entrypoint script and properties used for the action
COPY entrypoint.sh /app/entrypoint.sh

#Make it executable
RUN chmod +x /app/entrypoint.sh
RUN ls -l /scar && ls -l /app
ENTRYPOINT ["/app/entrypoint.sh"]
