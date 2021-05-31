
## Connect Node To Teleport Server

### Ubuntu

```shell
sudo mkdir teleport

cd teleport

sudo wget https://get.gravitational.com/teleport_6.0.3_amd64.deb

dpkg -i teleport_6.0.3_amd64.deb

sudo cp teleport-node.yaml /etc/teleport.yaml
teleport start --roles=node --token="token value" --ca-pin=sha256:"pin value" --auth-server="fqdn":3025
```
### centos

```shell 

yum-config-manager --add-repo https://rpm.releases.teleport.dev/teleport.repo 
yum install teleport

```

# Connect a Node To Teleport Server Node 


## Generate Node Token from Teleport Server by running following command in your teleport Docker container

```shell
tctl nodes add
```
`output will be`

```shell
The invite token: 84be7ada2e4c7a325c4636fd015c0495
This token will expire in 30 minutes

Run this on the new node to join the cluster:

> teleport start \
   --roles=node \
   --token=84be7ada2e4c7a325c4636fd015c0495 \
   --ca-pin=sha256:7628a8bdf4ad3dc8d67ca5e252ae5f99ac5410eb5f5e575f6677414187ba533c \
   --auth-server=172.31.0.2:3025

Please note:

  - This invitation token will expire in 30 minutes
  - 172.31.0.2:3025 must be reachable from the new node
```

copy the `token` and `ca-pin` for Node server


## Now create `teleport.yaml` in  Node Server  

`etc/teleport.yml` 


```shell
teleport:
  nodename: teleport-node-1
  data_dir: /var/lib/teleport
  auth_token: <your-auth-token>
  auth_servers:
    - <your-fqdn>:3025
  log:
  output: stderr
  severity: INFO
  ca_pin: <your-ca-pin-hash>
auth_service:
  enabled: no
ssh_service:
  enabled: yes
  labels:
    environment: test
proxy_service:
  enabled: no
```

Paste your `ca-pin` and `token` in the Node file to `ca-pin` and `auth_token` field

 
## Labels

```shell
ssh_service:
  # ..
  labels:
    environment: test
```
Add lables to your Node according to your roles mapping 

Note : Lables are usefull when you divide roles and access to team users

Role Reference : https://goteleport.com/docs/access-controls/guides/role-templates/

