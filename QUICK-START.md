# Quick Start Guide

## Setup

1. Install required package:
```bash
sudo apt install jq
```

2. Make scripts executable:
```bash
chmod +x vpcctl test-demo.sh cleanup.sh
```

## Quick Demo

Run the automated demo:
```bash
./test-demo.sh
```

## Manual Testing

### Create a simple VPC with subnets

```bash
# Create VPC
sudo ./vpcctl create-vpc myvpc 10.0.0.0/16 eth0

# Add public subnet
sudo ./vpcctl add-subnet myvpc web 10.0.1.0/24 public

# Add private subnet
sudo ./vpcctl add-subnet myvpc db 10.0.2.0/24 private

# List VPCs
sudo ./vpcctl list
```

### Test connectivity

```bash
# Access public subnet namespace
sudo ip netns exec ns-myvpc-web bash

# From there, test internet
ping -c 2 8.8.8.8

# Test internal connectivity
ping -c 2 10.0.2.10

# Exit namespace
exit
```

### Run a web server

```bash
# Start server in public subnet
sudo ip netns exec ns-myvpc-web python3 -m http.server 80 &

# Access from private subnet
sudo ip netns exec ns-myvpc-db curl http://10.0.1.10
```

### Cleanup

```bash
# Delete specific VPC
sudo ./vpcctl delete-vpc myvpc

# Or clean everything
./cleanup.sh
```

## Common Commands

```bash
# List all namespaces
ip netns list

# List all bridges
ip link show type bridge

# Check routing table
ip route

# View NAT rules
sudo iptables -t nat -L -n -v

# Check logs
cat /var/tmp/vpcctl.log

# Check state
cat /var/tmp/vpcctl_state.json | jq
```

## Troubleshooting

If things don't work:

1. Check you're running as root/sudo
2. Verify jq is installed: `which jq`
3. Check network interface name: `ip link`
4. View logs: `cat /var/tmp/vpcctl.log`
5. Clean up everything: `./cleanup.sh`
