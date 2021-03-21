# [Elasticsearch](https://www.elastic.co/products/elasticsearch) [Docker Image](https://www.docker.elastic.co/) with integrated [search guard](https://search-guard.com) and [elasticsearch-prometheus-exporter](https://github.com/vvanholl/elasticsearch-prometheus-exporter) plugin

[![](https://images.microbadger.com/badges/version/xtermi2/elasticsearch-searchguard.svg)](https://microbadger.com/images/xtermi2/elasticsearch-searchguard)
[![](https://images.microbadger.com/badges/image/xtermi2/elasticsearch-searchguard.svg)](https://microbadger.com/images/xtermi2/elasticsearch-searchguard)
[![](https://images.microbadger.com/badges/commit/xtermi2/elasticsearch-searchguard.svg)](https://microbadger.com/images/xtermi2/elasticsearch-searchguard)
[![Build Status](https://travis-ci.org/xtermi2/elasticsearch-searchguard.svg?branch=master)](https://travis-ci.org/xtermi2/elasticsearch-searchguard)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/b2a9a55db2b245c4b0e69e21b9e196b6)](https://app.codacy.com/app/xtermi2/elasticsearch-searchguard?utm_source=github.com&utm_medium=referral&utm_content=xtermi2/elasticsearch-searchguard&utm_campaign=Badge_Grade_Dashboard)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![LICENSE](https://img.shields.io/badge/license-Anti%20996-blue.svg)](https://github.com/996icu/996.ICU/blob/master/LICENSE)
[![996.icu](https://img.shields.io/badge/link-996.icu-red.svg)](https://996.icu)

Have a look at [xtermi2/kibana-searchguard](https://github.com/xtermi2/kibana-searchguard) for a fitting kibana.

For a complete example with 2 elasticsearch nodes, [kibana](https://www.elastic.co/products/kibana), [prometheus](https://prometheus.io) and [grafana](https://grafana.com) have a look at [xtermi2/elasticsearch-searchguard/example/README.md](https://github.com/xtermi2/elasticsearch-searchguard/tree/master/example)

This docker image is hosted on docker hub: [https://hub.docker.com/r/xtermi2/elasticsearch-searchguard](https://hub.docker.com/r/xtermi2/elasticsearch-searchguard)

## Image detail description

This docker image extends the original elastic image and installs [search guard](https://search-guard.com) and [elasticsearch-prometheus-exporter](https://github.com/vvanholl/elasticsearch-prometheus-exporter) plugin. 

At startup search-guard is configured with 3 default users:

-   elastic: A admin user which has no restrictions
-   kibana: A user which can be used by kibana
-   beats: A user which can be used by beats

The [searchguard user config](https://github.com/xtermi2/elasticsearch-searchguard/tree/master/src/main/resources/sg_config) is baked into the image, but can be overwritten. 
Just mount your custom configuration in the container at `/usr/share/elasticsearch/sg_config/`.

Searchguard requires certificates. In this image you need 3 types:

-   a CA certificate, which signed the other 2 certificates. This has to be named `root-ca.pem` by default.
-   a certificate + private key for the elasticsearch nodes which is used at REST and transport API. This has to be named `node.pem` and `node.key` by default.
-   a admin certificate + private key to configure searchguard. This has to be named `admin.pem` and `admin.key` by default.

These Certificates have to be mounted in the container at `/usr/share/elasticsearch/config/certificates/` 

## [File Descriptors and MMap](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html)

Elasticsearch uses a mmapfs directory by default to store its indices. The default operating system limits on mmap counts is likely to be too low, which may result in out of memory exceptions.
The host has to run this command:

```bash
sudo sysctl -w vm.max_map_count=262144
```

You can set it permanently by modifying `vm.max_map_count` setting in your `/etc/sysctl.conf`.

## Environment Configuration

-   **ROOT_CA** (default=root-ca.pem): The name of the CA certificate which signed the other 2 certificates (node.pem and admin.pem).
-   **ADMIN_PEM** (default=admin.pem): The name of the admin certificate to configure searchguard.
-   **ADMIN_KEY** (default=): The name of the admin private key to configure searchguard.
-   **ADMIN_KEY_PASS** (default=changeme): The password of the admin private key.
-   **ELASTIC_PWD** (default=changeme): The password of the pre defined admin user '**elastic**'. This user has no restrictions.
-   **KIBANA_PWD** (default=changeme): The password of the pre defined '**kibana**' user. This user has read access to all indices and can write to kibanas index.
-   **BEATS_PWD** (default=changeme): The password of the pre defined '**beats**' user. This user can manage `*beat-*` indices.

You also have to set the searchguard related TLS [configuration](https://docs.search-guard.com/latest/configuring-tls). 
All followin paths in this paragraph are relative to `/usr/share/elasticsearch/config/`:

-   **xpack.security.enabled: "false"**: since elasticsearch 7.11 this is required, because elasticsearch stopped providing the OSS image and the non-OSS image, which is now used as base image, contains the x-pack-security plugin, which clashes with search-guard. If you get a `IllegalArgumentException: Cannot have additional setting [http.type] in plugin [search-guard-7], already added in plugin [x-pack-security]` you have forgotten to disable the x-pack-security plugin.
-   **searchguard.ssl.transport.pemcert_filepath** (example=certificates/node.pem): path to node certificate
-   **searchguard.ssl.transport.pemkey_filepath** (example=certificates/node.key): path to node private key
-   **searchguard.ssl.transport.pemkey_password** (example=default-secret): password for node private key
-   **searchguard.ssl.transport.pemtrustedcas_filepath** (example=certificates/root-ca.pem): path to root CA certificate
-   **searchguard.ssl.transport.enforce_hostname_verification** (example=false): should the hostname in the certificate be verified?
-   **searchguard.ssl.transport.resolve_hostname** (example=false): should the hostname in the certificate be resolved?
-   **searchguard.ssl.http.enabled** (example=true): should the REST API be secured via TLS?
-   **searchguard.ssl.http.pemcert_filepath** (example=certificates/node.pem): path to node certificate
-   **searchguard.ssl.http.pemkey_filepath** (example=certificates/node.key): path to node private key
-   **searchguard.ssl.http.pemkey_password** (example=default-secret): password for node private key
-   **searchguard.ssl.http.pemtrustedcas_filepath** (example=certificates/root-ca.pem): path to root CA certificate

There is also a searchguard configuration which can't be set via environment variables because it's a list:

```yaml
searchguard:
  nodes_dn:
  # example value:
  - CN=node.es.local,OU=Ops,O=test,DC=es,DC=local
  authcz.admin_dn:
  # example value:
  - CN=admin.es.local,OU=Ops,O=test,DC=es,DC=local
```

This has to be set via a custom elasticsearch.yml in the container at `/usr/share/elasticsearch/config/elasticsearch.yml`.
Here is an example custom [elasticsearch.yml](https://github.com/xtermi2/elasticsearch-searchguard/blob/master/example/es_config/elasticsearch.yml). 

## User Feedback

### Issues

If you have any problems with or questions about this image, please ask for help through a [GitHub issue](https://github.com/xtermi2/elasticsearch-searchguard/issues).
