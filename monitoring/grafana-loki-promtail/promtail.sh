#!/bin/bash
echo ">$>$>$>$>$"
echo ">$>$>$>$>$ Downloading promtail-linux-amd64.zip"
echo ">$>$>$>$>$"
curl -s https://api.github.com/repos/grafana/loki/releases/latest | grep browser_download_url |  cut -d '"' -f 4 | grep promtail-linux-amd64.zip | wget -i -
echo ">$>$>$>$>$"
echo ">$>$>$>$>$ Extracting promtail"
echo ">$>$>$>$>$"
unzip promtail-linux-amd64.zip
echo ">$>$>$>$>$"
echo ">$>$>$>$>$ Moving promtail to /usr/local/bin/promtail"
echo ">$>$>$>$>$"
sudo mv promtail-linux-amd64 /usr/local/bin/promtail
echo ">$>$>$>$>$"
echo ">$>$>$>$>$ Checking the promtail version "
echo ">$>$>$>$>$"
promtail --version
echo ">$>$>$>$>$"
echo ">$>$>$>$>$ Creating promtail config & systemd file"
echo ">$>$>$>$>$"
echo ">$>$>$>$>$ /etc/promtail-config.yaml"
echo ">$>$>$>$>$ /etc/systemd/system/promtail.service"
echo ">$>$>$>$>$"
sudo touch /etc/promtail-config.yaml
sudo touch /etc/systemd/system/promtail.service
