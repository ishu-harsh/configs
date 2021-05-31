
# 1
## Run Composefile

```shell
docker-compose -f teleport-quickstart-ssl.yml up  -d
```
When we start this compose file, it will automatically create a default configuration and obtains self-signed certificates. Let’s make some adjustments in the configuration file, which is located in `teleport/config/teleport.yaml`

`teleport.yml` will look like

```
# A Sample Teleport configuration file.
# Creates a single proxy, auth and node server.
#
# Things to update:
#  1. license.pem: You only need a license from https://dashboard.goteleport.com
#     if you are an Enterprise customer.
#
teleport:
  nodename:  <your-fqdn>
  data_dir: /var/lib/teleport
  log:
    output: stderr
    severity: INFO
  ca_pin: "sha256:be53f45ec37c4fa7d6343dbcf9f58a1207999e5965ecee185108acf4f57ec846"
auth_service:
  enabled: "yes"
  listen_addr: 0.0.0.0:3025
  public_addr:  <your-fqdn>:3025
ssh_service:
  enabled: "yes"
  labels:
    env: example
  commands:
  - name: hostname
    command: [hostname]
    period: 10m0s
proxy_service:
  enabled: "yes"
  listen_addr: 0.0.0.0:3023
  #https_keypairs: []
  acme: {}
  public_addr:  <your-fqdn>
  ssh_public_addr:  <your-fqdn>

```

Make sure you add the “public_addr” and “ssh_public_addr” on the proxy_service 
and  “public_addr” on auth_service. Replace the <your-fqdn> with your FQDN of your teleport server or reverse-proxy/load-balancer.

Also You have to replace your ca_pin, you can obtain by executing the following command.

```shell
docker container exec teleport tctl status
```
After that restart your docker container with the following command.

```shell
  docker-compose -f teleport-quickstart-ssl.yml up  -d --force-recreate
```

# 2 

## Create User in Teleport 

user Guide : `https://goteleport.com/docs/admin-guide/#adding-and-deleting-users`

To Add Admin Role Account 

```shell
docker container exec teleport tctl users add admin --logins=joe,root --roles=admin
```

`output` Should be

```shell
[root@cache teleport-server]# docker container exec teleport tctl users add admin --logins=joe,root --roles=admin
User "admin" has been created but requires a password. Share this URL with the user to complete user setup, link is valid for 1h:
https://cache.mail250.com:3080/web/invite/a5526e09b50f6eb3a32654c424069e56

NOTE: Make sure cache.mail250.com:3080 points at a Teleport proxy which users can access.


```
Then copy the token to the browser and register it with google 2FA 

Note : If Invite URl is not works then remove the port from the url 

# 3

## Creatin Roles and adding Uers by Roles 

 For infrastructure teams have to figure out how to define access control policies that don't require manual configuration every time people join, leave, and form new teams.

We can create two roles, one for each user in file `roles.yaml`:


Example `roles.yaml`

```
 ---
kind: role
version: v3
metadata:
  name: bob
spec:
  allow:
    logins: ['ubuntu']
    kubernetes_groups: ['view']
    node_labels:
      '*': '*'
    kubernetes_labels:
      '*': '*'
  client_idle_timeout: 15m
  disconnect_expired_cert: true
```
Now Run the Following Commad to apply Roles and Add user

Note : You can use lables here for maping server to the roles

```shell
 tctl create -f roles.yaml
 tctl users add alice --roles=alice
```