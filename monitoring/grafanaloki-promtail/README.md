# Run Docker Compose

```shell
dockercompose up -d
```

# Changes in promtail/promtail-config.yml

```
__path__: /var/log/**/*log
```

## Change according you your log path in host machine (recommended to put logs in /var/logs/* )