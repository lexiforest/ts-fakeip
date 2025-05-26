#!/bin/bash
# -----------------------------------------------------------------------------
# reset_iptables.sh
#
# Remove all iptables rules and routing entries added by setup_tproxy.sh.
# -----------------------------------------------------------------------------

set -e

# 1. (Optional) Disable IPv4 forwarding
echo "Disabling IPv4 forwarding..."
sysctl -w net.ipv4.ip_forward=0

# 2. Flush only the rules in mangle PREROUTING and remove DIVERT chain
echo "Flushing mangle PREROUTING chain..."
iptables -t mangle -F PREROUTING

# 3. Remove DIVERT
echo "Removing DIVERT chain..."
iptables -t mangle -F DIVERT
iptables -t mangle -X DIVERT

# 4. Remove policy routing entries (table 100)
echo "Removing policy routing entries..."
ip rule del fwmark 1 lookup 100 2>/dev/null || true
ip route del local 0.0.0.0/0 dev lo table 100 2>/dev/null || true

echo "Cleanup complete. All TPROXY-related rules are gone."
