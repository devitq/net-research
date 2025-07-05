#cloud-config
hostname: client
manage_etc_hosts: false

users:
  - name: ubuntu
    gecos: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    ssh_pwauth: true
    shell: /bin/bash

ssh_pwauth: true
chpasswd:
  list: |
    ubuntu:ubuntu
  expire: false

growpart:
  mode: auto
  devices: ["/"]

package_update: true
package_upgrade: false
packages:
  - tftp-hpa

write_files:
  - path: /etc/hosts
    append: true
    encoding: b64
    content: ${hosts_file}

runcmd:
  - |
    cat << 'EOF' > /etc/network/if-up.d/disable-offload
    #!/bin/bash
    ethtool -K enp1s0 rx off tx off sg off tso off ufo off gso off gro off lro off ntuple off rxhash off rx-gro-hw off
    EOF
    chmod +x /etc/network/if-up.d/disable-offload
  - /etc/network/if-up.d/disable-offload
  - modprobe tcp_bbr sch_netem

  - |
    wget https://github.com/stunnel/static-curl/releases/download/8.14.1/curl-linux-x86_64-dev-8.14.1.tar.xz \
    -O /tmp/curl-linux-x86_64-dev-8.14.1.tar.xz \
    && cd /tmp && tar xf curl-linux-x86_64-dev-8.14.1.tar.xz && rm curl-linux-x86_64-dev-8.14.1.tar.xz \
    && mv ./curl-x86_64/bin/curl /home/ubuntu/

  - chown -R ubuntu /home/ubuntu/ && chgrp -R ubuntu /home/ubuntu/
