#!/bin/bash

DIR_INSTALL=/opt
# install prometheus 
if [[ $EUID -ne 0 ]]
    then echo "Please run as root"
    exit 1
fi

echo "Install NodeEXporter\n"

# node exporter
echo "Create directory"
mkdir -p $DIR_INSTALL/node_exporter 
if [[ $? -eq 0 ]]; then
    echo "Directory create"
    echo "$DIR_INSTALL/node_exporter"
else
    echo "Directory not create: $DIR_INSTALL/node_exporter"
    exit 1
fi
echo "-----"

echo "Download file"
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz -O - | tar -xzv -C /tmp
cp  /tmp/node_exporter-1.3.1.linux-amd64/node_exporter $DIR_INSTALL/node_exporter/

echo "-------"

# run sql for create exporter user
# here script for execure sql-query

# create users and group

echo "Add user and group prometheus"
groupadd --system prometheus
useradd --system -g prometheus -s /bin/false prometheus
chown -R prometheus:prometheus $DIR_INSTALL 
echo "-----"

# copy files node_exporter
echo "Copy systemd file"
echo "[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
Restart=always
User=prometheus
Group=prometheus
ExecStart=/opt/node_exporter/node_exporter

[Install]
WantedBy=multi-user.target" >  /etc/systemd/system/node_exporter.service

echo "-----"

# enable systemd  services
echo "Enable and run systemd services"
systemctl daemon-reload
systemctl start node_exporter.service
systemctl enable node_exporter.service
echo "-------"

# delete temporary files
echo "Delete temporary files"
rm -rf /tmp/node_exporter-1.3.1.linux-amd64
echo "-----"

echo "Done!\n"
