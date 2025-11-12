# VPC Control Tool (vpcctl)

A simple Linux-based VPC management tool that creates virtual private clouds using network namespaces, bridges, and iptables.

## Requirements

- Linux operating system
- Root/sudo privileges
- `jq` package installed (`sudo apt install jq`)
- Basic networking tools (ip, iptables, bridge)

## Installation

```bash
chmod +x vpcctl
```

## Usage

### 1. Create a VPC

```bash
sudo ./vpcctl create-vpc <vpc-name> <cidr> [internet-interface]
```

Example:
```bash
sudo ./vpcctl create-vpc myvpc 10.0.0.0/16 eth0
```

### 2. Add Subnets

Add a public subnet (with internet access):
```bash
sudo ./vpcctl add-subnet <vpc-name> <subnet-name> <cidr> public
```

Add a private subnet (no internet access):
```bash
sudo ./vpcctl add-subnet <vpc-name> <subnet-name> <cidr> private
```

Examples:
```bash
sudo ./vpcctl add-subnet myvpc public-subnet 10.0.1.0/24 public
sudo ./vpcctl add-subnet myvpc private-subnet 10.0.2.0/24 private
```

### 3. List VPCs

```bash
sudo ./vpcctl list
```

### 4. Peer VPCs

Connect two VPCs to allow communication:
```bash
sudo ./vpcctl peer-vpcs <vpc1-name> <vpc2-name>
```

Example:
```bash
sudo ./vpcctl peer-vpcs myvpc anothervpc
```

### 5. Apply Firewall Policy

Create a policy JSON file (see `policy-example.json`) and apply it:
```bash
sudo ./vpcctl apply-policy <policy-file.json>
```

Example:
```bash
sudo ./vpcctl apply-policy policy-example.json
```

### 6. Delete VPC

```bash
sudo ./vpcctl delete-vpc <vpc-name>
```

Example:
```bash
sudo ./vpcctl delete-vpc myvpc
```

## Testing Connectivity

### Access a subnet namespace

```bash
sudo ip netns exec ns-<vpc>-<subnet> bash
```

Example:
```bash
sudo ip netns exec ns-myvpc-public-subnet bash
```

### Test connectivity

```bash
# From within a namespace
ping 8.8.8.8
curl http://example.com
```

### Run a web server in a subnet

```bash
sudo ip netns exec ns-myvpc-public-subnet python3 -m http.server 80
```

### Test from another subnet

```bash
sudo ip netns exec ns-myvpc-private-subnet curl http://10.0.1.10
```

## Example Workflow

```bash
# Create first VPC
sudo ./vpcctl create-vpc vpc1 10.0.0.0/16 eth0
sudo ./vpcctl add-subnet vpc1 public 10.0.1.0/24 public
sudo ./vpcctl add-subnet vpc1 private 10.0.2.0/24 private

# Create second VPC
sudo ./vpcctl create-vpc vpc2 192.168.0.0/16 eth0
sudo ./vpcctl add-subnet vpc2 public 192.168.1.0/24 public

# List VPCs
sudo ./vpcctl list

# Peer VPCs
sudo ./vpcctl peer-vpcs vpc1 vpc2

# Apply firewall policy
sudo ./vpcctl apply-policy policy-example.json

# Clean up
sudo ./vpcctl delete-vpc vpc1
sudo ./vpcctl delete-vpc vpc2
```

## Logs

All operations are logged to `/var/tmp/vpcctl.log`

## State File

VPC state is stored in `/var/tmp/vpcctl_state.json`

## Troubleshooting

- Make sure you have jq installed: `sudo apt install jq`
- Check logs at `/var/tmp/vpcctl.log`
- Verify namespace creation: `ip netns list`
- Check bridge status: `ip link show type bridge`
- View routes: `ip route`
- Check NAT rules: `sudo iptables -t nat -L -n -v`
