# Instructions to build this image
FROM docker.elastic.co/elasticsearch/elasticsearch-oss:6.2.3

LABEL description="elasticsearch secured with search-guard"

ENV ES_VERSION "6.5.1"
ENV SG_VERSION "23.2"

ENV ELASTIC_PWD "changeme"
ENV KIBANA_PWD "changeme"
ENV BEATS_PWD "changeme"
ENV ADMIN_KEY_PASS "changeme"

ENV SG_CONFIG_DIR "/usr/share/elasticsearch/sg_config"
ENV SG_CERT_DIR "/usr/share/elasticsearch/config/certificates"

RUN mkdir -p $SG_CONFIG_DIR $SG_CERT_DIR \
    && chmod -R 0775 $SG_CONFIG_DIR $SG_CERT_DIR

COPY --chown=elasticsearch:0 ./src/main/resources/sg_config $SG_CONFIG_DIR
COPY --chown=elasticsearch:0 ./src/main/resources/bin /usr/local/bin

RUN echo "===> Installing search-guard..." \
    && chmod -R +x /usr/local/bin \
    && elasticsearch-plugin install -b "com.floragunn:search-guard-6:$ES_VERSION-$SG_VERSION"

ENTRYPOINT ["/usr/local/bin/searchguard-entrypoint.sh"]
# Dummy overridable parameter parsed by entrypoint
CMD ["eswrapper"]