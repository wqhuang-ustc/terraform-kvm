# terraform-kvm
This is a demo project to show how to create virtual machines on bare metal following Infrastructure As Code. We will use the classical and cheap virtualisation infrastructure provided by Linux and KVM together with Terrafrom, so that you can use Terraform to manage your on-premise servers.

## Introduction and Goals
6 virtual machines will be created as Kubernetes nodes. This Kubernetes cluster consists of 3 master and 3 worker nodes. These 6 Kubernetes nodes will be initialized using cloud-init to satisfy to requirements of being  Kubernetes nodes.

## Prerequisites
1. Physical machine with ubuntu:18.04 operation system.
2. IP address for the virtual machine within the internal network.
3. [Create bridge network on the host machine](https://github.com/wqhuang-ustc/terraform-kvm/blob/main/docs/bridge-network.md)
4. Manage the disk allocation to isolate different environments

## Step 1: Install and configure KVM hypervisor on ubuntu:18.04 host machine
### Verify system support hardward virtualization
[Before installing, make sure your Ubuntu host machine supports KVM virtualization. ](https://www.linuxtechi.com/install-configure-kvm-ubuntu-18-04-server/)
### Install KVM and its required packages
For the ubuntu system, all packages required to run KVM are available in official upstream repositories. Run the following command to install KVM and additional virtualization management packages:
```
sudo apt-get -y install qemu qemu-kvm libvirt-bin bridge-utils virt-manager
```
Qemu and libvirt packages in Ubuntu 18.04 will be automatically start and enabled after installation. In case libvirtd service is not started and enabled, run below commands:
```
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```
Now verify the status of libvirtd service:
```
sudo systemctl status libvirtd
```
On Ubuntu distros SELinux is enforced by qemu even if it is disabled globally, this might cause unexpected Could not open '/var/lib/libvirt/images/<FILE_NAME>': Permission denied errors. Double check that `security_driver = "none" ` is uncommented in /etc/libvirt/qemu.conf and issue `sudo systemctl restart libvirt-bin` to restart the daemon.

### Configure Network Bridge for KVM virtual machines
Network bridge is required to access the KVM based virtual machines outside the KVM hypervisor or host. In Ubuntu 18.04, network is managed by netplan utility. We will configure the bridge network via /etc/netplan/50-cloud-init.yaml. An example can be found below:

```
network:
    version: 2
    bonds:
        bond0:
            addresses:
            - 192.168.1.23/24 # static IP address assigned to this host
            gateway4: 192.168.1.1
            nameservers:
                search: [example.com]
                addresses: [1.1.1.1, 1.0.0.1] 
            interfaces:
            - enp3s0
            - enp4s0
            parameters:
                mode: balance-rr
    ethernets:
        enp3s0: {} # name of the network physical interfaces
        enp4s0: {}
    bridges:
        br0:
            interfaces: [bond0]
            addresses:
            - 192.168.1.23/24
            gateway4: 192.168.1.1
            nameservers:
                search: [example.com]
                addresses: [1.1.1.1, 1.0.0.1]
```
Run below command to apply the changes we made to the netplan configuration file.
```
sudo netplan apply
```             
To know more about bridge-network, click the [link.](docs/bridge-network.md)

## Step 2: Install Terraform
Terraform installation is much easier. You just need to download a binary archive, extract and place the binary file in a directory in your $PATH.
Ensure wget and unzip are installed.
```
sudo apt-get install wget unzip
```
Then, download the terraform archive. Change the version number according to the need.
```
export VER="0.12.9" 
wget https://releases.hashicorp.com/terraform/${VER}/terraform_${VER}_linux_amd64.zip
unzip terraform_${VER}_linux_amd64.zip
```
This will create a terraform binary file on your working directory. Move this file to the directory /usr/local/bin.
```
sudo mv terraform /usr/local/bin/
```
Confirm the version installed and verify that Terraform works:
```
terraform -v
terraform -help
```
If you need to install Terraform in another way, check the [official installation guide.](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

## Step 3: Install Terraform KVM provider plugin terraform-provider-libvirt
This provider is available for auto-installation from the Terraform Registry, you can install it by specifying your main.tf file.
```
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  # Configuration options
}
```
If you cannot downloading this plugin directly from its origin registry, due to firewall restrictions within your organization, you can use alternative `Implied Local Mirror Directories` below:
We can install third-party provider by placing their plugin executables in the `filesystem_mirror` directory. For Linux and other Unix-like systems, this directory is $HOME/terraform.d/plugin. Or put the plugin executable in `your_terraform_project/terraform.d/plugin/linux_amd64/` directory under your Terraform project.

Check this [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt), to know how to download or build this plugin executable.

## Step 4: Create VM using the provider with Terraform configuration files
Prerequisites: Download the ubuntu cloud image,resize the image to desired size and put it under libvirt volume directory specified in the main.tf.
```
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
sudo qemu-img resize bionic-server-cloudimg-amd64.img +100G
```
Before launching virtual machines via terraform, modify the network_config_*.cfg, cloud_init_*.cfg and main.tf accordingly. Use below terraform to lauch virtual machines:
```
cd your_terraform_project_directory
sudo terraform init # initialize a working directory containing Terraform configuration files.
sudo terraform plan # create an execution plan.
sudo terraform apply # apply the changes required to reach the desired state of the configuration.
```
To destroy the terraform-managed infrastructure.
``` 
sudo terraform destroy
```

## Some useful commands
1. List all running VMs by "virsh list", or use "virsh list --all" to list all VMs.
2. To access the vm, use "virsh console vm_name", then provide the user name and password as defined in cloud-init.cfg. To exit the console, use shortcut "Ctrl + Shift + ]".
3. To delete a bridge network, use "ip link set bridge_name down", then "brctl delbr bridge_name"
4. To destroy a single libvirt resource, use the command "terraform destroy -target=resource_type.resource_name"

## References

