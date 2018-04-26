FROM inspirehep/python-base
USER root
WORKDIR /etc/pki/ca-trust/source/anchors/
RUN curl https://raw.githubusercontent.com/inspirehep/inspire-mitmproxy/master/mitmproxy-ca.pem > mitmproxy-ca.crt
RUN update-ca-trust extract
ENV REQUESTS_CA_BUNDLE=/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
WORKDIR /code
USER test
