#!/bin/bash

echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-tailscale-mihomo.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale-mihomo.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale-mihomo.conf
