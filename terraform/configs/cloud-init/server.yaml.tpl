#cloud-config
hostname: server
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
  - tftpd-hpa
  - nginx
  - caddy

write_files:
  - path: /etc/nginx/nginx.conf
    owner: root:root
    permissions: '0644'
    encoding: b64
    content: ${nginx_conf}
  - path: /etc/default/tftpd-hpa
    owner: root:root
    permissions: '0644'
    encoding: b64
    content: ${tftpd_conf}
  - path: /etc/caddy/Caddyfile
    owner: root:root
    permissions: '0644'
    encoding: b64
    content: ${caddy_conf}
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
    dd if=/dev/random of=/var/www/1MB.file bs=1024K count=1
    dd if=/dev/random of=/var/www/10MB.file bs=1024K count=10
    dd if=/dev/random of=/var/www/100MB.file bs=1024K count=100

  - systemctl enable nginx caddy tftpd-hpa && systemctl restart nginx caddy tftpd-hpa
