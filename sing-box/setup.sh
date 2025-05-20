#!/bin/bash
# -----------------------------------------------------------------------------
# setup_tproxy.sh
#
# Enable transparent proxying via TPROXY **only** for incoming TCP traffic
# whose destination is 198.18.0.0/15, redirecting it to local port 7893.
# -----------------------------------------------------------------------------

set -e

# 1. Enable IPv4 forwarding (required for policy routing)
echo "Enabling IPv4 forwarding..."
sysctl -w net.ipv4.ip_forward=1

# 2. Create policy routing: packets marked “1” use table 100
echo "Configuring policy routing..."
ip rule add fwmark 1 lookup 100
ip route add local 0.0.0.0/0 dev lo table 100

# 3. Prepare mangle table and DIVERT chain
echo "Setting up mangle table and DIVERT chain..."
iptables -t mangle -N DIVERT

# 3a. For TCP packets to 198.18.0.0/15 that already have a local socket,
#     divert them to avoid re-marking loops
iptables -t mangle -A PREROUTING \
    -p tcp \
    -d 198.18.0.0/15 \
    -m socket \
    -j DIVERT

# 3b. In DIVERT chain: mark packet and ACCEPT so it gets routed
iptables -t mangle -A DIVERT \
    -j MARK --set-mark 1
iptables -t mangle -A DIVERT \
    -j ACCEPT

# 4. TPROXY rule: mark **all other** TCP PREROUTING packets to 198.18.0.0/15
#    and send them to local port 7893
echo "Adding TPROXY rule for 198.18.0.0/15 → port 7893..."
iptables -t mangle -A PREROUTING \
    -p tcp \
    -d 198.18.0.0/15 \
    -j TPROXY \
        --tproxy-mark 0x1/0x1 \
        --on-port 7893

echo "Setup complete. Only TCP → 198.18.0.0/15 will be transparently proxied on port 7893."
