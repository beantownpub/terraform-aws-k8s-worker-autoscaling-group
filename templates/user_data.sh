#!/bin/bash

# disable shellcheck for terraform template vars
# shellcheck disable=SC2154

sudo su -
swapoff -a
yum update -y
yum install -y iproute-tc bind-utils jq nmap

cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
amazon-linux-extras install -y docker

mkdir -p /etc/docker
cat <<EOF | tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "50m"
    },
    "storage-driver": "overlay2"
}
EOF

service docker start
usermod -a -G docker ec2-user
systemctl enable --now docker
systemctl daemon-reload
systemctl restart docker

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

export CERT_HASH="${ca_cert_hash}"
echo "CERT_HASH: $${CERT_HASH}" > ca_cert_hash.txt

cat <<EOF | tee cluster-join-with-hash.yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: ${kubernetes_join_token}
    apiServerEndpoint: "${control_plane_ip}:6443"
    caCertHashes:
      - ${ca_cert_hash}
nodeRegistration: {}
EOF

cat <<EOF | tee cluster-join.yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: ${kubernetes_join_token}
    apiServerEndpoint: "${control_plane_ip}:6443"
    caCertHashes: []
nodeRegistration: {}
EOF

if [[ "${ca_cert_hash}" != "" ]]; then
    echo "No cert hash" >> ca_cert_hash.txt
    kubeadm join --config cluster-join.yaml
else
    echo "Joining with cert hash" >> ca_cert_hash.txt
    kubeadm join --config cluster-join-with-hash.yaml
fi
