# Here is described how to start the example

## Requirements

-   docker-compose installed
-   some basic unix tolls like _wget_, _unzip_, _curl_

## First get some certificates

Here is described how to generate self signed certificates with the search-guard [offline TLS Tool](https://docs.search-guard.com/latest/offline-tls-tool), which is save for production.

1.  download the latest version of [offline TLS Tool](https://search.maven.org/#search%7Cga%7C1%7Ca%3A%22search-guard-tlstool%22)
    -   `wget "https://search.maven.org/remotecontent?filepath=com/floragunn/search-guard-tlstool/1.7/search-guard-tlstool-1.7.zip" -O search-guard-tlstool.zip`

2.  unzip it
    -   `unzip search-guard-tlstool.zip`

3.  configure your certificates   
    -   the tool brings an _config_ directory with example configs   
    -   we will use `tls-tool_certificate_config.yml` for this example here without any modifications (but of course, you should at least change the passwords when you use this example in production)

4.  execute TLS tool to generate certificates
    ```bash
    rm -rf out && ./tools/sgtlstool.sh -c tls-tool_certificate_config.yml -ca -crt
    ```
    -   root-ca: is a self signed CA 
    -   node: is a certificate for all nodes
    -   admin: is a certificate which is used to configure search guard

## start elasticsearch, kibana, prometheus and grafana with docker-compose

1.  set required kernel flags (<https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html>)
    -   `sudo sysctl -w vm.max_map_count=262144`
        -   this setting is only temporary, to set this permanently add the parameter in `/etc/sysctl.conf`

2.  start docker-compose
    -   `docker-compose up`   

3.  test if elasticsearch cluster is up and running: 

    -   `curl -k -u 'elastic:elastic' "https://localhost:9200/_cluster/health?pretty"`
        -   you should see **status: green** and **number_of_nodes: 2**.

    -   `curl -k -u 'elastic:elastic' "https://localhost:9200/_searchguard/license?pretty"`
        -   here you can also see some cluster information + searchguard license information.

    -   `curl -k -u 'elastic:elastic' https://localhost:9200/_prometheus/metrics`
        -   here you can see raw prometheus metrics data.

4.  put a document to elasticsearch  
    ```bash
    curl -k -u 'elastic:elastic' -X PUT https://localhost:9200/myindex/_doc/1 -H 'Content-Type: application/json' -d '{"user" : "kimchy", "post_date" : "2009-11-15T14:12:12", "message" : "trying out Elasticsearch"}'
    ```

5.  try it out

    -   with kibana <http://localhost:5601> and login with `kibana:kibana`
        -   Add the previously created index "myindex" to kibana via **Management** -> **Index Patterns**.
        -   Now you are able to explore your elasticsearch index via kibana in the **Discover** view.

    -   with prometheus <http://localhost:9090/targets> to see all prometheus targets

    -   with grafana <http://localhost:3000> and login with `admin:admin`
        -   There exists a provisioned dashboard called "ElasticSearch" from <https://grafana.com/dashboards/266>
