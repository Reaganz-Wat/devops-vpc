#!/bin/bash

# Demo script to test VPC functionality
# This script demonstrates all features of vpcctl

echo "=== VPC Demo Script ==="
echo ""

# Get internet interface (auto-detect)
IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
echo "Using internet interface: $IFACE"
echo ""

# Test 1: Create VPC1
echo "Test 1: Creating VPC1..."
sudo ./vpcctl create-vpc vpc1 10.0.0.0/16 $IFACE
echo ""

# Test 2: Add subnets to VPC1
echo "Test 2: Adding subnets to VPC1..."
sudo ./vpcctl add-subnet vpc1 public 10.0.1.0/24 public
sudo ./vpcctl add-subnet vpc1 private 10.0.2.0/24 private
echo ""

# Test 3: Create VPC2
echo "Test 3: Creating VPC2..."
sudo ./vpcctl create-vpc vpc2 192.168.0.0/16 $IFACE
sudo ./vpcctl add-subnet vpc2 public 192.168.1.0/24 public
echo ""

# Test 4: List VPCs
echo "Test 4: Listing all VPCs..."
sudo ./vpcctl list
echo ""

# Test 5: Test connectivity within VPC1
echo "Test 5: Testing connectivity within VPC1..."
echo "From public subnet pinging private subnet:"
sudo ip netns exec ns-vpc1-public ping -c 2 10.0.2.10
echo ""

# Test 6: Test internet access from public subnet
echo "Test 6: Testing internet access from public subnet..."
sudo ip netns exec ns-vpc1-public ping -c 2 8.8.8.8
echo ""

# Test 7: Test isolation between VPCs (should fail)
echo "Test 7: Testing VPC isolation (VPC1 -> VPC2, should fail)..."
sudo ip netns exec ns-vpc1-public ping -c 2 192.168.1.10 && echo "FAIL: VPCs not isolated!" || echo "PASS: VPCs are isolated"
echo ""

# Test 8: Peer VPCs
echo "Test 8: Creating VPC peering..."
sudo ./vpcctl peer-vpcs vpc1 vpc2
echo ""

# Test 9: Test connectivity after peering (should work)
echo "Test 9: Testing connectivity after peering (VPC1 -> VPC2)..."
sudo ip netns exec ns-vpc1-public ping -c 2 192.168.1.10
echo ""

# Test 10: Deploy web server in public subnet
echo "Test 10: Deploying web server in VPC1 public subnet..."
sudo ip netns exec ns-vpc1-public python3 -m http.server 8080 > /dev/null 2>&1 &
WEB_PID=$!
sleep 2
echo "Web server started (PID: $WEB_PID)"
echo ""

# Test 11: Access web server from private subnet
echo "Test 11: Accessing web server from private subnet..."
sudo ip netns exec ns-vpc1-private curl -s http://10.0.1.10:8080 | head -n 3
echo ""

# Stop web server
kill $WEB_PID 2>/dev/null

# Test 12: Apply firewall policy
echo "Test 12: Applying firewall policy..."
sudo ./vpcctl apply-policy policy-example.json
echo ""

# Test 13: Cleanup
echo "Test 13: Cleaning up VPCs..."
sudo ./vpcctl delete-vpc vpc1
sudo ./vpcctl delete-vpc vpc2
echo ""

echo "=== Demo Complete ==="
echo "Check logs at: /var/tmp/vpcctl.log"
