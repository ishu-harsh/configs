
## Connect Node To Teleport Server
```shell
sudo mkdir teleport

cd teleport

sudo wget https://get.gravitational.com/teleport_6.0.3_amd64.deb

dpkg -i teleport_6.0.3_amd64.deb

sudo cp teleport-node.yaml /etc/teleport.yaml
teleport start --roles=node --token="token value" --ca-pin=sha256:"pin value" --auth-server="fqdn":3025
```