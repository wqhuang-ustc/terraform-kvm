A linux bridge behaves like a network switch. It forwards packets between interfaces that are connected to it. It is used for forwarding packets on routers, on gateways, or between VMs and network namespaces on a host.

This bridge network will be used by guest VMs to connected directly to the LAN, so that those guest VMs are reachable within the internal network.

An example of creating a bridge network on top of a bonding network with static IP is shown below using netplan:
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
Notes:

Reasons for using bonding if possible:
Network Interface Bonding is a mechanism used in Linux servers which consists of binding more physical network interfaces in order to provide more bandwidth than a single interface can provide or provide link redundancy in case of a cable failure.

![Image of bridge network for VMs]
(https://github.com/wqhuang-ustc/terraform-kvm/blob/main/docs/images/bridge-network.png)
    
If you need to configure other network using netplan, check this link: https://netplan.io/examples/