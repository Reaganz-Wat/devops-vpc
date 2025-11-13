#!/bin/bash

echo "=== Full System Cleanup ==="

# Delete all network namespaces
echo "Deleting namespaces..."
for ns in $(ip netns list | awk '{print $1}'); do
    sudo ip netns del "$ns" 2>/dev/null
    echo "  Deleted: $ns"
done

# Delete all bridges starting with br-
echo "Deleting bridges..."
for br in $(ip link show type bridge | grep "^[0-9]" | grep "br-" | awk '{print $2}' | cut -d: -f1); do
    sudo ip link set "$br" down 2>/dev/null
    sudo ip link del "$br" 2>/dev/null
    echo "  Deleted: $br"
done

# Delete all veth pairs created by vpcctl (pattern: v{vpc}{subnet}-h)
echo "Deleting veth pairs..."
for veth in $(ip link show type veth 2>/dev/null | grep "^[0-9]" | awk '{print $2}' | cut -d: -f1 | cut -d@ -f1); do
    sudo ip link del "$veth" 2>/dev/null
    echo "  Deleted: $veth"
done

# Clean up NAT rules
echo "Cleaning NAT rules..."
sudo iptables -t nat -F POSTROUTING 2>/dev/null

# Remove state and log files
echo "Removing state files..."
sudo rm -f /var/tmp/vpcctl_state.json
sudo rm -f /var/tmp/vpcctl.log

echo ""
echo "=== Cleanup Complete ==="
echo "Verification:"
echo "Namespaces: $(ip netns list | wc -l)"
echo "Bridges: $(ip link show type bridge | grep "br-" | wc -l)"
echo "Veth pairs: $(ip link show type veth 2>/dev/null | wc -l)"
