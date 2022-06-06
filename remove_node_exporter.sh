#!/bin/bash

DIR_INSTALL=/opt/prometheus

if [[ $EUID -ne 0 ]]; then 
    echo "Please run as root"
    exit 1
fi

echo "Remove nodexporter"


echo "Stop and disable systemd service"
systemctl stop node_exporter.service
systemctl disable node_exporter.service

echo "Remove file"
rm /etc/systemd/system/node_exporter.service
rm -rf $DIR_INSTALL/node_exporter

echo "Delete user and group"
userdel prometheus
groupdel prometheus

