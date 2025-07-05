# Task 5

## Prerequisites

Ensure you have the following installed on your system:

- [libvirt](https://libvirt.org/) (latest version recommended)
- [Terraform](https://developer.hashicorp.com/terraform) (latest version recommended)
- [Wireshark](https://www.wireshark.org/) (latest version recommended)

## Deploying environment

NOTE: You must have `libvirt` daemon running running

### Goto Terraform directory

```bash
cd terraform
```

### Create and edit dotenv file

```bash
cp .env.template .env
```

### Add client and server records to `/etc/hosts`

```bash
# ...
10.6.6.10 client
10.6.6.20 server
```

### Init Terraform

```bash
terraform init
```

### Start the environment

```bash
terraform apply
```

NOTE: Wait for several minutes until all required things will provided to the vms

## CheatSheet

### Commands for `client`

```bash
# For HTTP/1.1 (TCP)
curl server:80/<size>MB.file -o <size>MB.file

# For HTTP/2 (TCP)
curl --http2-prior-knowledge server:81/<size>MB.file -o <size>MB.file

# For HTTP/3 (UDP)
./curl --http3-only --insecure https://server:443/<size>MB.file -o <size>MB.file

# For TFTP (UDP)
tftp server -c get /var/www/<size>MB.file
```

### Run benchmarks

```bash
./scripts/run_benchmarks
```

This script does the following things

#### Change CC (on vms, 4 combinations for `tcp` protocols)

```bash
sysctl net.ipv4.tcp_congestion_control=bbr|reno -w
```

#### Starts `tcpdump` on hypervisor with filters according to protocol

```bash
tcpdump -i "$interface" -w "$pcap_file" "$filter"
```

#### Runs download command according to protocol

Refer to [this](#commands-for-client)

#### Stops `tcpdump`

### Merge `pcap` files

```bash
mergecap -w merged.pcap dump1 dump2 ...
```

### Change link profile

```bash
./scripts/change_profile
```

And follow the instructions

This script just executes this command on `server` vm

```bash
tc qdisc replace dev $interface root netem delay ${delay}ms loss ${loss}%
```

OR:

```bash
tc qdisc del dev $interface root
```
