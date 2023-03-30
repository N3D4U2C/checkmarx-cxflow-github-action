#Use CxFlow Base image
FROM checkmarx/cx-flow

#ENV SBT_VERSION 1.8.2

#RUN apk add --no-cache bash curl && \
#    curl -sL "https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local && \
#    ln -s /usr/local/sbt/bin/sbt /usr/local/bin/sbt && \
#    chmod 0755 /usr/local/bin/sbt
    
ARG SCALA_VERSION=2.12.11
ARG SBT_VERSION=1.3.9
ENV SCALA_HOME=/usr/share/scala

RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
  apk add --no-cache bash && \
  cd "/tmp" && \
  wget "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
  tar xzf "scala-${SCALA_VERSION}.tgz" && \
  mkdir "${SCALA_HOME}" && \
  rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
  mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
  ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
  apk del .build-dependencies && \
  rm -rf "/tmp/"*

RUN \
  apk add --no-cache --virtual=.build-dependencies bash curl bc ca-certificates && \
  cd "/tmp" && \
  update-ca-certificates && \
  scala -version && \
  scalac -version && \
  curl -fsL https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz | tar xfz - -C /usr/local && \
  $(mv /usr/local/sbt-launcher-packaging-$SBT_VERSION /usr/local/sbt || true) && \
  ln -s /usr/local/sbt/bin/* /usr/local/bin/ && \
  apk del .build-dependencies && \
  rm -rf "/tmp/"*

RUN \
  sbt -Dsbt.rootdir=true -batch sbtVersion && \
  rm -rf project target

#Copy the entrypoint script and properties used for the action
COPY entrypoint.sh /app/entrypoint.sh
#Make it executable
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
