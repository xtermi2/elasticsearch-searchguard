# Instructions to build this image
FROM docker.elastic.co/elasticsearch/elasticsearch-oss:7.10.2

ARG VCS_REF
ARG BUILD_DATE
ARG MICROSCANNER_TOKEN

LABEL description="elasticsearch secured with search-guard"
LABEL org.label-schema.name="elasticsearch-searchguard"
LABEL org.label-schema.description="elasticsearch secured with search-guard"
LABEL org.label-schema.usage="https://github.com/xtermi2/elasticsearch-searchguard/tree/master/example"
LABEL org.label-schema.url="https://github.com/xtermi2/elasticsearch-searchguard"
LABEL org.label-schema.vcs-url="https://github.com/xtermi2/elasticsearch-searchguard"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE

ENV ES_VERSION "7.10.2"
ENV SG_VERSION "48.0.0"
ENV PROMETHEUS_EXPORTER_VERSION "7.10.2.0"

ENV ELASTIC_PWD "changeme"
ENV KIBANA_PWD "changeme"
ENV BEATS_PWD "changeme"
ENV ADMIN_KEY_PASS "changeme"

ENV SG_CONFIG_DIR "/usr/share/elasticsearch/sg_config"
ENV SG_CERT_DIR "/usr/share/elasticsearch/config/certificates"
ENV ROOT_CA "root-ca.pem"
ENV ADMIN_PEM "admin.pem"
ENV ADMIN_KEY "admin.key"

RUN mkdir -p $SG_CONFIG_DIR $SG_CERT_DIR \
    && chmod -R 0775 $SG_CONFIG_DIR $SG_CERT_DIR

COPY --chown=elasticsearch:0 ./src/main/resources/sg_config $SG_CONFIG_DIR
COPY --chown=elasticsearch:0 ./src/main/resources/bin /usr/local/bin

RUN echo "===> Installing search-guard..." \
    && chmod -R +x /usr/local/bin \
    && elasticsearch-plugin install -b https://maven.search-guard.com/search-guard-suite-release/com/floragunn/search-guard-suite-plugin/$ES_VERSION-$SG_VERSION/search-guard-suite-plugin-$ES_VERSION-$SG_VERSION.zip \
    && echo "===> Installing elasticsearch-prometheus-exporter..." \
    && elasticsearch-plugin install -b https://github.com/vvanholl/elasticsearch-prometheus-exporter/releases/download/${PROMETHEUS_EXPORTER_VERSION}/prometheus-exporter-${PROMETHEUS_EXPORTER_VERSION}.zip

#run Aqua MicroScanner - scan for vulnerabilities
RUN [ -z "$MICROSCANNER_TOKEN" ] && echo "skip Aqua MicroScanner because no token is given!" || ( \
    curl -L -o /tmp/microscanner https://get.aquasec.com/microscanner \
        && chmod +x /tmp/microscanner \
        && /tmp/microscanner $MICROSCANNER_TOKEN --continue-on-failure \
        && rm -rf /tmp/microscanner \
    )

ENTRYPOINT ["/usr/local/bin/searchguard-entrypoint.sh"]
# Dummy overridable parameter parsed by entrypoint
CMD ["eswrapper"]