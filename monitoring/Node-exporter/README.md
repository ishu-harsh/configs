# Run Node Expoter in Node 

```shell
docker run -d -p 9100:9100 --name=node-exporter --user 995:995 -v "/:/hostfs" prom/node-exporter --path.rootfs=/hostfs

```

## Now Add Target to the Prometheus 

`prometheus.yaml`

```
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter_metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100','prometheus-target-1:9100','prometheus-target-2:9100']
```

