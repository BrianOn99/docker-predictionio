FROM ubuntu:16.04

ENV PIO_VERSION 0.11.0

ENV PIO_HOME /PredictionIO-${PIO_VERSION}-incubating
ENV PATH=${PIO_HOME}/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PIO_BUILD /pio_build

RUN apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends curl openjdk-8-jdk libgfortran3 python-pip postgresql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir ${PIO_BUILD} && cd ${PIO_BUILD} \
    && curl -O http://apache.communilink.net/incubator/predictionio/0.11.0-incubating/apache-predictionio-0.11.0-incubating.tar.gz \
    && tar -xvzf apache-predictionio-${PIO_VERSION}-incubating.tar.gz \
    && rm apache-predictionio-${PIO_VERSION}-incubating.tar.gz \
    && ./make-distribution.sh

RUN tar zxvfC ${PIO_BUILD}/PredictionIO-${PIO_VERSION}-incubating.tar.gz /

#&& sed -i 's;\$PIO_HOME/lib/postgresql-42\.0\.0\.jar;$PIO_HOME/lib/postgresql-42.1.4.jar;' /${PIO_HOME}/conf/pio-env.sh

RUN mkdir /${PIO_HOME}/vendors
#COPY files/pio-env.sh ${PIO_HOME}/conf/pio-env.sh

RUN curl -O http://d3kbcqa49mib13.cloudfront.net/spark-1.6.3-bin-hadoop2.6.tgz \
    && tar zxvfC spark-1.6.3-bin-hadoop2.6.tgz /${PIO_HOME}/vendors \
    && rm spark-1.6.3-bin-hadoop2.6.tgz

# Install ppostgres
RUN /etc/init.d/postgresql start \
    && su - postgres -c "createdb pio && psql -c \"create user pio with password 'pio'\""

RUN curl -o ${PIO_HOME}/lib/postgresql-42.0.0.jar https://jdbc.postgresql.org/download/postgresql-42.0.0.jar
