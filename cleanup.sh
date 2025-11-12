#!/bin/bash

# Cleanup script to remove all VPCs and resources

echo "=== VPC Cleanup Script ==="
echo ""

if [ ! -f /var/tmp/vpcctl_state.json ]; then
    echo "No VPCs found to clean up"
    exit 0
fi

# Get list of all VPCs
VPCS=$(jq -r '.vpcs | keys[]' /var/tmp/vpcctl_state.json 2>/dev/null)

if [ -z "$VPCS" ]; then
    echo "No VPCs found to clean up"
    exit 0
fi

echo "Found VPCs to delete:"
for vpc in $VPCS; do
    echo "  - $vpc"
done
echo ""

# Delete each VPC
for vpc in $VPCS; do
    echo "Deleting VPC: $vpc"
    sudo ./vpcctl delete-vpc $vpc
done

echo ""
echo "Cleanup complete!"
echo "Removing state and log files..."
sudo rm -f /var/tmp/vpcctl_state.json
sudo rm -f /var/tmp/vpcctl.log

echo "All resources cleaned up successfully"
