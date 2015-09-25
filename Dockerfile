FROM ubuntu:trusty

EXPOSE 4000

ENV ES_VERSION 1.7.1
ENV MYSQL_VERSION 5.6
ENV NODE_MODULES /usr/local/lib/node_modules/
ENV DISPLAY :99.0

RUN apt-get -y update && apt-get install -y \
redis-server \
rabbitmq-server \
git \
wget \
curl \
unzip \
nodejs \
npm \
default-jre \
libmysqlclient-dev \
libxml2-dev \
libxslt-dev \
libjpeg-dev \
libfreetype6-dev \
libtiff-dev \
libffi-dev \
software-properties-common \
python-dev \
python-pip \
# Only for testing
firefox \
chromium-browser \
xvfb \
libblas-dev \
liblapack-dev \
gfortran \
imagemagick

# Download ElasticSearch
RUN wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-"${ES_VERSION}".zip && \
    unzip elasticsearch-"${ES_VERSION}".zip && \
    rm elasticsearch-"${ES_VERSION}".zip

# Download chromedriver
RUN wget http://chromedriver.storage.googleapis.com/2.12/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip -d /usr/bin && \
    chmod 755 /usr/bin/chromedriver

# For the new Nodejs to work
RUN ln -s /usr/bin/nodejs /usr/bin/node

# Configure and install MySQL
RUN { \
    echo mysql-community-server mysql-community-server/data-dir select ''; \
    echo mysql-community-server mysql-community-server/root-pass password ''; \
    echo mysql-community-server mysql-community-server/re-root-pass password ''; \
    echo mysql-community-server mysql-community-server/remove-test-db select false; \
} | debconf-set-selections
RUN apt-get install -y mysql-server-"${MYSQL_VERSION}"

# NPM dependencies (installed in /usr/local/bin)
RUN npm update && npm install -g bower less clean-css uglify-js requirejs

# Beard
RUN pip install git+https://github.com/inveniosoftware/beard@master#egg=beard

# Invenio
RUN mkdir /src && \
    cd /src/ && \
    git clone --branch=labs https://github.com/inspirehep/invenio.git && \
    cd invenio && \
    pip install -e .
