# Task 5

## Prerequisites

Ensure you have the following installed on your system:

- [libvirt](https://libvirt.org/) (latest version recommended)
- [Terraform](https://developer.hashicorp.com/terraform) (latest version recommended)

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

### Merge `pcap` files

```bash
mergecap -w merged.pcap http1.1-bbr.pcapng http1.1-reno.pcapng http3.pcapng tftp.pcapng
```

### Change CC

```bash
sysctl net.ipv4.tcp_congestion_control=bbr|reno -w
```

### Change link profile

```bash
./scripts/change_profile
```

And follow the instructions
